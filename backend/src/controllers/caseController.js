const pool = require('../config/db');
const { v4: uuidv4 } = require('uuid');

const generateCaseId = async () => {
  // Simple sequential-like ID, e.g. CASE-2024-0001
  const result = await pool.query("SELECT count(*) as count FROM cases WHERE date_part('year', created_at) = date_part('year', NOW())");
  const year = new Date().getFullYear();
  const seq = (result.rows[0].count + 1).toString().padStart(4, '0');
  return `CASE-${year}-${seq}`;
};

const createCase = async (req, res) => {
  try {
    const { type, status, priority, clients, tags, timeline = [] } = req.body;
    const case_id = await generateCaseId();
    const id = uuidv4();
    const result = await pool.query(
      'INSERT INTO cases (id, case_id, type, status, priority, clients, tags, timeline) VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *',
      [id, case_id, type, status, priority, JSON.stringify(clients || []), JSON.stringify(tags || []), JSON.stringify(timeline)]
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

const getCases = async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM cases ORDER BY created_at DESC');
    result.rows.forEach(row => {
      row.clients = JSON.parse(row.clients);
      row.tags = JSON.parse(row.tags);
      row.timeline = JSON.parse(row.timeline);
    });
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const getCase = async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('SELECT * FROM cases WHERE id = $1', [id]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Case not found' });
    const row = result.rows[0];
    row.clients = JSON.parse(row.clients);
    row.tags = JSON.parse(row.tags);
    row.timeline = JSON.parse(row.timeline);
    res.json(row);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const updateCase = async (req, res) => {
  try {
    const { id } = req.params;
    const { type, status, priority, clients, tags, timeline } = req.body;
    const result = await pool.query(
      'UPDATE cases SET type = $1, status = $2, priority = $3, clients = $4, tags = $5, timeline = $6 WHERE id = $7 RETURNING *',
      [type, status, priority, JSON.stringify(clients), JSON.stringify(tags), JSON.stringify(timeline), id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'Case not found' });
    const row = result.rows[0];
    row.clients = JSON.parse(row.clients);
    row.tags = JSON.parse(row.tags);
    row.timeline = JSON.parse(row.timeline);
    res.json(row);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

const deleteCase = async (req, res) => {
  try {
    const { id } = req.params;
    await pool.query('DELETE FROM cases WHERE id = $1', [id]);
    res.json({ message: 'Case deleted' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

module.exports = { createCase, getCases, getCase, updateCase, deleteCase };

