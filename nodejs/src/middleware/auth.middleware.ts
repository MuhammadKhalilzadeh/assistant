import { Request, Response, NextFunction } from 'express';
import { UnauthorizedError } from '../utils/errors';
import { jwtService } from '../services/jwt.service';
import { userModel } from '../models/user.model';
import { logger } from '../config/logger';

// Routes that don't require authentication
const PUBLIC_PATHS = [
  '/api/health',
  '/api/auth/google',
  '/api/auth/refresh',
];

const DEV_MODE = process.env.NODE_ENV !== 'production';

// Cached dev user ID to avoid DB lookup on every request
let devUserId: string | null = null;

async function getOrCreateDevUser(): Promise<{ userId: string; email: string }> {
  if (devUserId) {
    return { userId: devUserId, email: 'dev@jarvis.local' };
  }

  const devEmail = 'dev@jarvis.local';
  const devGoogleId = 'dev-bypass-user';

  let user = await userModel.findByGoogleId(devGoogleId);
  if (!user) {
    user = await userModel.create({
      googleId: devGoogleId,
      email: devEmail,
      displayName: 'Dev User',
    });
    logger.info({ userId: user.id }, 'Created dev bypass user');
  }

  devUserId = user.id;
  return { userId: user.id, email: devEmail };
}

export function authMiddleware(req: Request, _res: Response, next: NextFunction): void {
  // Skip auth for public paths
  if (PUBLIC_PATHS.some(path => req.path === path)) {
    return next();
  }

  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    // In dev mode, fall back to dev user instead of rejecting
    if (DEV_MODE) {
      getOrCreateDevUser()
        .then((devUser) => {
          req.user = devUser;
          next();
        })
        .catch(next);
      return;
    }
    return next(new UnauthorizedError('Authorization token is required'));
  }

  const token = authHeader.substring(7);
  const payload = jwtService.verifyAccessToken(token);

  if (!payload) {
    // In dev mode, fall back to dev user for expired/invalid tokens too
    if (DEV_MODE) {
      getOrCreateDevUser()
        .then((devUser) => {
          req.user = devUser;
          next();
        })
        .catch(next);
      return;
    }
    return next(new UnauthorizedError('Invalid or expired token'));
  }

  req.user = {
    userId: payload.userId,
    email: payload.email,
  };

  next();
}
