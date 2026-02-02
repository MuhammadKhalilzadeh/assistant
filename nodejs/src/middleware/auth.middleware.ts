import { Request, Response, NextFunction } from 'express';
import { UnauthorizedError } from '../utils/errors';

const API_KEY = process.env.API_KEY;

export function authMiddleware(req: Request, _res: Response, next: NextFunction): void {
  // Skip auth for health check endpoint
  if (req.path === '/api/health') {
    return next();
  }

  // If no API_KEY is configured, skip authentication (development mode)
  if (!API_KEY) {
    return next();
  }

  const providedKey = req.headers['x-api-key'] as string | undefined;

  if (!providedKey) {
    return next(new UnauthorizedError('API key is required'));
  }

  if (providedKey !== API_KEY) {
    return next(new UnauthorizedError('Invalid API key'));
  }

  next();
}
