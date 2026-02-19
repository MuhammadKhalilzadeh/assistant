import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { Server } from 'http';

dotenv.config();

import todoRoutes from './routes/todo.routes';
import categoryRoutes from './routes/category.routes';
import habitRoutes from './routes/habit.routes';
import waterRoutes from './routes/water.routes';
import heartRateRoutes from './routes/heart_rate.routes';
import stepsRoutes from './routes/steps.routes';
import moodRoutes from './routes/mood.routes';
import sleepRoutes from './routes/sleep.routes';
import meditationRoutes from './routes/meditation.routes';
import workoutRoutes from './routes/workout.routes';
import caloriesRoutes from './routes/calories.routes';
import focusTimerRoutes from './routes/focus-timer.routes';
import weatherRoutes from './routes/weather.routes';
import screenTimeRoutes from './routes/screen-time.routes';
import inboxRoutes from './routes/inbox.routes';
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
app.use('/api/water', waterRoutes);
app.use('/api/heart-rate', heartRateRoutes);
app.use('/api/steps', stepsRoutes);
app.use('/api/mood', moodRoutes);
app.use('/api/sleep', sleepRoutes);
app.use('/api/meditation', meditationRoutes);
app.use('/api/workouts', workoutRoutes);
app.use('/api/calories', caloriesRoutes);
app.use('/api/focus-timer', focusTimerRoutes);
app.use('/api/weather', weatherRoutes);
app.use('/api/screen-time', screenTimeRoutes);
app.use('/api/inbox', inboxRoutes);

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
      logger.info('  GET    /api/water');
      logger.info('  POST   /api/water');
      logger.info('  GET    /api/water/stats');
      logger.info('  GET    /api/water/history');
      logger.info('  GET    /api/water/goal');
      logger.info('  PUT    /api/water/goal');
      logger.info('  GET    /api/water/:id');
      logger.info('  PUT    /api/water/:id');
      logger.info('  DELETE /api/water/:id');
      logger.info('  GET    /api/heart-rate');
      logger.info('  POST   /api/heart-rate');
      logger.info('  GET    /api/heart-rate/stats');
      logger.info('  GET    /api/heart-rate/history');
      logger.info('  GET    /api/heart-rate/goal');
      logger.info('  PUT    /api/heart-rate/goal');
      logger.info('  GET    /api/steps');
      logger.info('  POST   /api/steps');
      logger.info('  POST   /api/steps/add');
      logger.info('  GET    /api/steps/stats');
      logger.info('  GET    /api/steps/history');
      logger.info('  GET    /api/steps/goal');
      logger.info('  PUT    /api/steps/goal');
      logger.info('  GET    /api/mood');
      logger.info('  POST   /api/mood');
      logger.info('  GET    /api/mood/stats');
      logger.info('  GET    /api/mood/history');
      logger.info('  GET    /api/mood/goal');
      logger.info('  PUT    /api/mood/goal');
      logger.info('  GET    /api/sleep');
      logger.info('  POST   /api/sleep');
      logger.info('  GET    /api/sleep/stats');
      logger.info('  GET    /api/sleep/history');
      logger.info('  GET    /api/sleep/goal');
      logger.info('  PUT    /api/sleep/goal');
      logger.info('  GET    /api/meditation');
      logger.info('  POST   /api/meditation');
      logger.info('  GET    /api/meditation/stats');
      logger.info('  GET    /api/meditation/history');
      logger.info('  GET    /api/meditation/goal');
      logger.info('  PUT    /api/meditation/goal');
      logger.info('  GET    /api/workouts');
      logger.info('  POST   /api/workouts');
      logger.info('  GET    /api/workouts/stats');
      logger.info('  GET    /api/workouts/history');
      logger.info('  GET    /api/workouts/goal');
      logger.info('  PUT    /api/workouts/goal');
      logger.info('  GET    /api/calories');
      logger.info('  POST   /api/calories');
      logger.info('  GET    /api/calories/stats');
      logger.info('  GET    /api/calories/history');
      logger.info('  GET    /api/calories/goal');
      logger.info('  PUT    /api/calories/goal');
      logger.info('  GET    /api/focus-timer');
      logger.info('  POST   /api/focus-timer');
      logger.info('  GET    /api/focus-timer/stats');
      logger.info('  GET    /api/focus-timer/history');
      logger.info('  GET    /api/focus-timer/goal');
      logger.info('  PUT    /api/focus-timer/goal');
      logger.info('  GET    /api/weather');
      logger.info('  GET    /api/weather/hourly');
      logger.info('  GET    /api/weather/search');
      logger.info('  GET    /api/weather/settings');
      logger.info('  PUT    /api/weather/settings');
      logger.info('  GET    /api/screen-time');
      logger.info('  POST   /api/screen-time');
      logger.info('  GET    /api/screen-time/stats');
      logger.info('  GET    /api/screen-time/history');
      logger.info('  GET    /api/screen-time/goal');
      logger.info('  PUT    /api/screen-time/goal');
      logger.info('  GET    /api/inbox');
      logger.info('  POST   /api/inbox');
      logger.info('  GET    /api/inbox/stats');
      logger.info('  PATCH  /api/inbox/:id/read');
      logger.info('  PATCH  /api/inbox/:id/star');
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
