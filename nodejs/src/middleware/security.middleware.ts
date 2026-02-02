import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import { Request, Response, NextFunction } from 'express';
import { RateLimitError } from '../utils/errors';

// Helmet middleware for security headers
export const securityHeaders = helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", 'data:', 'https:'],
    },
  },
  crossOriginEmbedderPolicy: false, // Allow cross-origin requests for API
});

// Rate limiter configuration
export const rateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  standardHeaders: true, // Return rate limit info in the `RateLimit-*` headers
  legacyHeaders: false, // Disable the `X-RateLimit-*` headers
  message: { error: 'Too many requests', code: 'RATE_LIMIT_EXCEEDED' },
  handler: (_req: Request, _res: Response, next: NextFunction) => {
    next(new RateLimitError());
  },
  skip: (req: Request) => {
    // Skip rate limiting for health check
    return req.path === '/api/health';
  },
});

// Stricter rate limiter for mutation endpoints
export const mutationRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 50, // Limit mutations to 50 per windowMs
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many requests', code: 'RATE_LIMIT_EXCEEDED' },
  handler: (_req: Request, _res: Response, next: NextFunction) => {
    next(new RateLimitError());
  },
});
