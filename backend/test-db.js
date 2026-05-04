require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

async function testDB() {
  try {
    const client = await pool.connect();
    console.log('✅ Neon Connected!');
    
    const tables = await client.query("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name");
    console.log('Tables:', tables.rows.map(r => r.table_name));
    
    const users = await client.query('SELECT * FROM users');
    console.log('Users:', users.rows.length);
    
    client.release();
    process.exit(0);
  } catch (err) {
    console.error('❌ DB Error:', err.message);
    process.exit(1);
  }
}

testDB();

