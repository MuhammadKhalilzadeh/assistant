import jwt from 'jsonwebtoken';
import { v4 as uuidv4 } from 'uuid';
import { logger } from '../config/logger';

const JWT_SECRET = process.env.JWT_SECRET || 'dev-jwt-secret-change-in-production';
const JWT_REFRESH_SECRET = process.env.JWT_REFRESH_SECRET || 'dev-jwt-refresh-secret-change-in-production';

const ACCESS_TOKEN_EXPIRY = '15m';
const REFRESH_TOKEN_EXPIRY = '30d';

export interface AccessTokenPayload {
  userId: string;
  email: string;
  tokenId: string;
}

export interface RefreshTokenPayload {
  userId: string;
  tokenId: string;
}

export const jwtService = {
  createAccessToken(userId: string, email: string): { token: string; tokenId: string } {
    const tokenId = uuidv4();
    const token = jwt.sign(
      { userId, email, tokenId } satisfies AccessTokenPayload,
      JWT_SECRET,
      { expiresIn: ACCESS_TOKEN_EXPIRY }
    );
    return { token, tokenId };
  },

  createRefreshToken(userId: string): { token: string; tokenId: string } {
    const tokenId = uuidv4();
    const token = jwt.sign(
      { userId, tokenId } satisfies RefreshTokenPayload,
      JWT_REFRESH_SECRET,
      { expiresIn: REFRESH_TOKEN_EXPIRY }
    );
    return { token, tokenId };
  },

  verifyAccessToken(token: string): AccessTokenPayload | null {
    try {
      return jwt.verify(token, JWT_SECRET) as AccessTokenPayload;
    } catch (err) {
      logger.debug({ err }, 'Access token verification failed');
      return null;
    }
  },

  verifyRefreshToken(token: string): RefreshTokenPayload | null {
    try {
      return jwt.verify(token, JWT_REFRESH_SECRET) as RefreshTokenPayload;
    } catch (err) {
      logger.debug({ err }, 'Refresh token verification failed');
      return null;
    }
  },

  getAccessTokenExpirySeconds(): number {
    return 15 * 60; // 15 minutes
  },
};
