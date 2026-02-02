import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { Server } from 'http';

dotenv.config();

import todoRoutes from './routes/todo.routes';
import categoryRoutes from './routes/category.routes';
import habitRoutes from './routes/habit.routes';
import { errorHandler, notFoundHandler } from './middleware/error.middleware';
import { authMiddleware } from './middleware/auth.middleware';
import { securityHeaders, rateLimiter } from './middleware/security.middleware';
import { requestLogger } from './middleware/request-logger.middleware';
import { checkDatabaseHealth, closeDatabasePool, initializeDatabase } from './config/database';
import { logger } from './config/logger';

const app = express();
const PORT = process.env.PORT || 3000;

// Security middleware
app.use(securityHeaders);
app.use(rateLimiter);

// Request logging
app.use(requestLogger);

// CORS and body parsing
app.use(cors());
app.use(express.json({ limit: '1mb' }));

// Authentication middleware (skips health check)
app.use(authMiddleware);

// Routes
app.use('/api/todos', todoRoutes);
app.use('/api/categories', categoryRoutes);
app.use('/api/habits', habitRoutes);

// Enhanced health check with database status
app.get('/api/health', async (_req, res) => {
  const dbHealth = await checkDatabaseHealth();

  const status = dbHealth.healthy ? 'ok' : 'degraded';
  const statusCode = dbHealth.healthy ? 200 : 503;

  res.status(statusCode).json({
    status,
    timestamp: new Date().toISOString(),
    version: process.env.npm_package_version || '1.0.0',
    database: {
      healthy: dbHealth.healthy,
      latency: dbHealth.latency,
      error: dbHealth.error,
    },
  });
});

// Error handling
app.use(notFoundHandler);
app.use(errorHandler);

// Server instance for graceful shutdown
let server: Server;

// Initialize database and start server
async function startServer(): Promise<void> {
  try {
    // Initialize database schema
    await initializeDatabase();

    // Start HTTP server
    server = app.listen(PORT, () => {
      logger.info({ port: PORT }, 'Server started');
      logger.info('API endpoints:');
      logger.info('  GET    /api/health');
      logger.info('  GET    /api/todos');
      logger.info('  POST   /api/todos');
      logger.info('  GET    /api/todos/:id');
      logger.info('  PUT    /api/todos/:id');
      logger.info('  DELETE /api/todos/:id');
      logger.info('  PATCH  /api/todos/:id/toggle');
      logger.info('  GET    /api/todos/stats');
      logger.info('  GET    /api/categories');
      logger.info('  GET    /api/habits');
      logger.info('  POST   /api/habits');
      logger.info('  GET    /api/habits/stats');
      logger.info('  GET    /api/habits/:id');
      logger.info('  PUT    /api/habits/:id');
      logger.info('  DELETE /api/habits/:id');
      logger.info('  PATCH  /api/habits/:id/toggle');
    });
  } catch (err) {
    logger.fatal({ err }, 'Failed to start server');
    process.exit(1);
  }
}

startServer();

// Graceful shutdown handling
const shutdown = async (signal: string) => {
  logger.info({ signal }, 'Received shutdown signal, starting graceful shutdown...');

  // Stop accepting new connections
  server.close(async (err) => {
    if (err) {
      logger.error({ err }, 'Error closing HTTP server');
      process.exit(1);
    }

    logger.info('HTTP server closed');

    // Close database connections
    try {
      await closeDatabasePool();
      logger.info('Graceful shutdown completed');
      process.exit(0);
    } catch (dbErr) {
      logger.error({ err: dbErr }, 'Error closing database pool');
      process.exit(1);
    }
  });

  // Force shutdown after 30 seconds
  setTimeout(() => {
    logger.error('Forced shutdown after timeout');
    process.exit(1);
  }, 30000);
};

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
  logger.fatal({ err }, 'Uncaught exception');
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  logger.error({ reason, promise }, 'Unhandled rejection');
});

export default app;
