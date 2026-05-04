const { Pool } = require('pg');
require('dotenv').config({ path: '../../.env' });

const connectionString = process.env.DATABASE_URL;
const poolConfig = connectionString
  ? {
      connectionString,
      ssl: { rejectUnauthorized: false },
    }
  : {
      host: process.env.DB_HOST || 'localhost',
      port: process.env.DB_PORT || 5432,
      database: process.env.DB_NAME || 'legaldb',
      user: process.env.DB_USER || 'postgres',
      password: process.env.DB_PASS || 'password',
      ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false,
    };

const pool = new Pool(poolConfig);

pool.on('error', (err) => {
  console.error('Unexpected DB error:', err);
});

module.exports = pool;

