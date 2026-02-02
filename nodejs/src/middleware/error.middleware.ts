import { Request, Response, NextFunction } from 'express';
import { AppError, ValidationError } from '../utils/errors';
import { logger } from '../config/logger';

interface ErrorResponse {
  error: string;
  code: string;
  message?: string;
  details?: Record<string, unknown>[];
}

export function errorHandler(
  err: Error,
  req: Request,
  res: Response,
  _next: NextFunction
): void {
  // Log the error
  logger.error({
    err,
    req: {
      method: req.method,
      url: req.url,
      params: req.params,
      query: req.query,
    },
  }, 'Request error');

  // Handle known AppError types
  if (err instanceof AppError) {
    const response: ErrorResponse = {
      error: err.message,
      code: err.code,
    };

    // Include validation details in development
    if (err instanceof ValidationError && err.details) {
      response.details = err.details.errors.map((e) => ({
        field: e.path.join('.'),
        message: e.message,
        code: e.code,
      }));
    }

    res.status(err.statusCode).json(response);
    return;
  }

  // Handle unknown errors
  const isDev = process.env.NODE_ENV === 'development';

  res.status(500).json({
    error: 'Internal server error',
    code: 'INTERNAL_ERROR',
    message: isDev ? err.message : undefined,
  });
}

export function notFoundHandler(req: Request, res: Response): void {
  logger.warn({ method: req.method, url: req.url }, 'Route not found');
  res.status(404).json({
    error: 'Not found',
    code: 'NOT_FOUND',
  });
}
