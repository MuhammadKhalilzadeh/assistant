import { Request, Response, NextFunction } from 'express';
import bcrypt from 'bcrypt';
import { userModel } from '../models/user.model';
import { jwtService } from '../services/jwt.service';
import { googleAuthService } from '../services/google-auth.service';
import { cryptoService } from '../services/crypto.service';
import { UnauthorizedError, DatabaseError, ValidationError } from '../utils/errors';
import { logger } from '../config/logger';

export const authController = {
  async googleAuth(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { idToken, authCode } = req.body;

      // Verify Google ID token
      const googleUser = await googleAuthService.verifyIdToken(idToken);
      if (!googleUser) {
        return next(new UnauthorizedError('Invalid Google ID token'));
      }

      // Upsert user
      let user = await userModel.findByGoogleId(googleUser.googleId);
      if (!user) {
        user = await userModel.create({
          googleId: googleUser.googleId,
          email: googleUser.email,
          displayName: googleUser.displayName,
          photoUrl: googleUser.photoUrl,
        });
        logger.info({ userId: user.id, email: user.email }, 'New user registered');
      } else {
        await userModel.update(user.id, {
          displayName: googleUser.displayName || undefined,
          photoUrl: googleUser.photoUrl || undefined,
        });
        await userModel.updateLastLogin(user.id);
        user = (await userModel.findById(user.id))!;
        logger.info({ userId: user.id }, 'User signed in');
      }

      // Exchange auth code for Gmail tokens if provided
      if (authCode) {
        const gmailTokens = await googleAuthService.exchangeAuthCode(authCode);
        if (gmailTokens) {
          await userModel.updateGmailTokens(user.id, {
            accessToken: cryptoService.encrypt(gmailTokens.accessToken),
            refreshToken: cryptoService.encrypt(gmailTokens.refreshToken),
            expiry: gmailTokens.expiry,
          });
          user = (await userModel.findById(user.id))!;
        }
      }

      // Generate JWT tokens
      const accessToken = jwtService.createAccessToken(user.id, user.email);
      const refreshToken = jwtService.createRefreshToken(user.id);

      // Store refresh token hash
      const refreshHash = await bcrypt.hash(refreshToken.token, 10);
      await userModel.updateRefreshTokenHash(user.id, refreshHash);

      res.json({
        user: {
          id: user.id,
          email: user.email,
          displayName: user.displayName,
          photoUrl: user.photoUrl,
          nickname: user.nickname,
          gmailConnected: user.gmailConnected,
        },
        accessToken: accessToken.token,
        refreshToken: refreshToken.token,
        expiresIn: jwtService.getAccessTokenExpirySeconds(),
      });
    } catch (error) {
      logger.error({ err: error }, 'Google auth failed');
      next(new DatabaseError('Authentication failed'));
    }
  },

  async refreshToken(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { refreshToken } = req.body;

      // Verify refresh token
      const payload = jwtService.verifyRefreshToken(refreshToken);
      if (!payload) {
        return next(new UnauthorizedError('Invalid or expired refresh token'));
      }

      // Check stored hash matches
      const storedHash = await userModel.getRefreshTokenHash(payload.userId);
      if (!storedHash) {
        return next(new UnauthorizedError('Refresh token has been revoked'));
      }

      const isValid = await bcrypt.compare(refreshToken, storedHash);
      if (!isValid) {
        return next(new UnauthorizedError('Invalid refresh token'));
      }

      // Get user
      const user = await userModel.findById(payload.userId);
      if (!user) {
        return next(new UnauthorizedError('User not found'));
      }

      // Rotate tokens
      const newAccessToken = jwtService.createAccessToken(user.id, user.email);
      const newRefreshToken = jwtService.createRefreshToken(user.id);

      const newHash = await bcrypt.hash(newRefreshToken.token, 10);
      await userModel.updateRefreshTokenHash(user.id, newHash);

      res.json({
        accessToken: newAccessToken.token,
        refreshToken: newRefreshToken.token,
        expiresIn: jwtService.getAccessTokenExpirySeconds(),
      });
    } catch (error) {
      logger.error({ err: error }, 'Token refresh failed');
      next(new DatabaseError('Token refresh failed'));
    }
  },

  async logout(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      await userModel.updateRefreshTokenHash(userId, null);
      logger.info({ userId }, 'User logged out');
      res.json({ message: 'Logged out successfully' });
    } catch (error) {
      logger.error({ err: error }, 'Logout failed');
      next(new DatabaseError('Logout failed'));
    }
  },

  async getMe(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const user = await userModel.findById(userId);

      if (!user) {
        return next(new UnauthorizedError('User not found'));
      }

      res.json({
        id: user.id,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoUrl,
        nickname: user.nickname,
        gmailConnected: user.gmailConnected,
        hasApiKeys: {
          openai: !!user.apiKeys.openai,
          anthropic: !!user.apiKeys.anthropic,
          googleai: !!user.apiKeys.googleai,
        },
      });
    } catch (error) {
      logger.error({ err: error }, 'Failed to get user profile');
      next(new DatabaseError('Failed to get user profile'));
    }
  },

  async updateMe(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { nickname, apiKeys } = req.body;

      // Update nickname if provided
      if (nickname !== undefined) {
        const user = await userModel.update(userId, { nickname });
        if (!user) {
          return next(new UnauthorizedError('User not found'));
        }
      }

      // Update API keys if provided (encrypt each key before storing)
      if (apiKeys) {
        const encryptedKeys: { openai?: string; anthropic?: string; googleai?: string } = {};
        if (apiKeys.openai !== undefined) {
          encryptedKeys.openai = apiKeys.openai ? cryptoService.encrypt(apiKeys.openai) : '';
        }
        if (apiKeys.anthropic !== undefined) {
          encryptedKeys.anthropic = apiKeys.anthropic ? cryptoService.encrypt(apiKeys.anthropic) : '';
        }
        if (apiKeys.googleai !== undefined) {
          encryptedKeys.googleai = apiKeys.googleai ? cryptoService.encrypt(apiKeys.googleai) : '';
        }
        await userModel.updateApiKeys(userId, encryptedKeys);
      }

      // Fetch updated user
      const updatedUser = await userModel.findById(userId);
      if (!updatedUser) {
        return next(new UnauthorizedError('User not found'));
      }

      res.json({
        id: updatedUser.id,
        email: updatedUser.email,
        displayName: updatedUser.displayName,
        photoUrl: updatedUser.photoUrl,
        nickname: updatedUser.nickname,
        gmailConnected: updatedUser.gmailConnected,
        hasApiKeys: {
          openai: !!updatedUser.apiKeys.openai,
          anthropic: !!updatedUser.apiKeys.anthropic,
          googleai: !!updatedUser.apiKeys.googleai,
        },
      });
    } catch (error) {
      logger.error({ err: error }, 'Failed to update profile');
      next(new DatabaseError('Failed to update profile'));
    }
  },

  async gmailConnect(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user!.userId;
      const { authCode } = req.body;

      const gmailTokens = await googleAuthService.exchangeAuthCode(authCode);
      if (!gmailTokens) {
        return next(new ValidationError('Failed to exchange auth code for Gmail tokens'));
      }

      await userModel.updateGmailTokens(userId, {
        accessToken: cryptoService.encrypt(gmailTokens.accessToken),
        refreshToken: cryptoService.encrypt(gmailTokens.refreshToken),
        expiry: gmailTokens.expiry,
      });

      const user = await userModel.findById(userId);
      logger.info({ userId }, 'Gmail connected');

      res.json({
        gmailConnected: true,
        email: user?.email,
      });
    } catch (error) {
      logger.error({ err: error }, 'Gmail connect failed');
      next(new DatabaseError('Gmail connect failed'));
    }
  },
};
