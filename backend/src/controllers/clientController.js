const pool = require('../config/db');
const { v4: uuidv4 } = require('uuid'); // add uuid to deps later

const createClient = async (req, res) => {
  try {
    const { full_name, nrc_number, phone, email, address } = req.body;
    const id = uuidv4();
    const result = await pool.query(
      'INSERT INTO clients (id, full_name, nrc_number, phone, email, address) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
      [id, full_name, nrc_number, phone, email, address]
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

const getClients = async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM clients ORDER BY created_at DESC');
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const getClient = async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('SELECT * FROM clients WHERE id = $1', [id]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Client not found' });
    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const updateClient = async (req, res) => {
  try {
    const { id } = req.params;
    const { full_name, phone, email, address } = req.body;
    const result = await pool.query(
      'UPDATE clients SET full_name = $1, phone = $2, email = $3, address = $4, updated_at = NOW() WHERE id = $5 RETURNING *',
      [full_name, phone, email, address, id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'Client not found' });
    res.json(result.rows[0]);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

const deleteClient = async (req, res) => {
  try {
    const { id } = req.params;
    await pool.query('DELETE FROM clients WHERE id = $1', [id]);
    res.json({ message: 'Client deleted' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

module.exports = { createClient, getClients, getClient, updateClient, deleteClient };

