import pinoHttp from 'pino-http';
import { logger } from '../config/logger';

export const requestLogger = pinoHttp({
  logger,
  autoLogging: {
    ignore: (req) => {
      // Don't log health check requests to reduce noise
      return req.url === '/api/health';
    },
  },
  customLogLevel: (_req, res, err) => {
    if (res.statusCode >= 500 || err) {
      return 'error';
    }
    if (res.statusCode >= 400) {
      return 'warn';
    }
    return 'info';
  },
  customSuccessMessage: (req, res) => {
    return `${req.method} ${req.url} ${res.statusCode}`;
  },
  customErrorMessage: (req, res) => {
    return `${req.method} ${req.url} ${res.statusCode} - Error`;
  },
  serializers: {
    req: (req) => ({
      method: req.method,
      url: req.url,
      query: req.query,
    }),
    res: (res) => ({
      statusCode: res.statusCode,
    }),
  },
});
