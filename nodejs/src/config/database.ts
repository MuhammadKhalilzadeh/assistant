import { Pool, PoolClient } from 'pg';
import dotenv from 'dotenv';
import { logger } from './logger';

dotenv.config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 20, // Maximum number of clients in the pool
  idleTimeoutMillis: 30000, // Close idle clients after 30 seconds
  connectionTimeoutMillis: 5000, // Return an error after 5 seconds if connection could not be established
});

pool.on('connect', () => {
  logger.debug('New client connected to PostgreSQL');
});

pool.on('error', (err) => {
  logger.error({ err }, 'Unexpected error on idle PostgreSQL client');
});

// Health check function to verify database connectivity
export async function checkDatabaseHealth(): Promise<{
  healthy: boolean;
  latency?: number;
  error?: string;
}> {
  const start = Date.now();
  let client: PoolClient | null = null;

  try {
    client = await pool.connect();
    await client.query('SELECT 1');
    const latency = Date.now() - start;

    return { healthy: true, latency };
  } catch (err) {
    const error = err instanceof Error ? err.message : 'Unknown database error';
    logger.error({ err }, 'Database health check failed');
    return { healthy: false, error };
  } finally {
    if (client) {
      client.release();
    }
  }
}

// Graceful shutdown function
export async function closeDatabasePool(): Promise<void> {
  logger.info('Closing database pool...');
  await pool.end();
  logger.info('Database pool closed');
}

export default pool;
