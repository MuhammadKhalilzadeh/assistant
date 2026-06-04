import { Pool, PoolClient } from 'pg';
import dotenv from 'dotenv';
import { readFileSync } from 'fs';
import { join } from 'path';
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

// Create database if it doesn't exist
async function ensureDatabaseExists(): Promise<void> {
  // Parse the connection URL to get database name
  const dbUrl = process.env.DATABASE_URL || '';
  const dbName = dbUrl.split('/').pop()?.split('?')[0] || 'assistant';

  // Create a connection to the default 'postgres' database
  const adminUrl = dbUrl.replace(`/${dbName}`, '/postgres');
  const adminPool = new Pool({
    connectionString: adminUrl,
    max: 1,
  });

  try {
    const result = await adminPool.query(
      `SELECT 1 FROM pg_database WHERE datname = $1`,
      [dbName]
    );

    if (result.rows.length === 0) {
      logger.info(`Database '${dbName}' does not exist, creating...`);
      await adminPool.query(`CREATE DATABASE ${dbName}`);
      logger.info(`Database '${dbName}' created successfully`);
    } else {
      logger.debug(`Database '${dbName}' already exists`);
    }
  } finally {
    await adminPool.end();
  }
}

// Run pending migrations from sql/migrations/ directory
async function runMigrations(client: PoolClient): Promise<void> {
  // Create migrations tracking table if it doesn't exist
  await client.query(`
    CREATE TABLE IF NOT EXISTS schema_migrations (
      name VARCHAR(255) PRIMARY KEY,
      applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `);

  // Read all migration files
  const migrationsDir = join(__dirname, '../../sql/migrations');
  let migrationFiles: string[];
  try {
    const { readdirSync } = require('fs');
    migrationFiles = (readdirSync(migrationsDir) as string[])
      .filter((f: string) => f.endsWith('.sql'))
      .sort();
  } catch {
    logger.debug('No migrations directory found, skipping migrations');
    return;
  }

  // Check which migrations have already been applied
  const applied = await client.query<{ name: string }>(
    'SELECT name FROM schema_migrations'
  );
  const appliedSet = new Set(applied.rows.map(r => r.name));

  for (const file of migrationFiles) {
    if (appliedSet.has(file)) {
      logger.debug({ migration: file }, 'Migration already applied, skipping');
      continue;
    }

    logger.info({ migration: file }, 'Running migration...');
    const sql = readFileSync(join(migrationsDir, file), 'utf-8');
    await client.query(sql);
    await client.query(
      'INSERT INTO schema_migrations (name) VALUES ($1)',
      [file]
    );
    logger.info({ migration: file }, 'Migration applied successfully');
  }
}

// Initialize database schema from init.sql
export async function initializeDatabase(): Promise<void> {
  let client: PoolClient | null = null;

  try {
    // First ensure the database exists
    await ensureDatabaseExists();

    logger.info('Initializing database schema...');

    client = await pool.connect();

    // Read and execute init.sql first (idempotent CREATE TABLE IF NOT EXISTS)
    // This must run before migrations so tables exist for ALTER statements
    const sqlPath = join(__dirname, '../../sql/init.sql');
    const initSql = readFileSync(sqlPath, 'utf-8');
    await client.query(initSql);

    // Run pending migrations (handles schema changes to existing tables)
    await runMigrations(client);

    logger.info('Database schema initialized successfully');
  } catch (err) {
    const error = err instanceof Error ? err.message : 'Unknown error';
    logger.error({ err }, 'Failed to initialize database schema');
    throw new Error(`Database initialization failed: ${error}`);
  } finally {
    if (client) {
      client.release();
    }
  }
}

export default pool;
