const pool = require('../config/db');
const { v4: uuidv4 } = require('uuid');

const calculateStage = (days_in_arrears) => {
  if (days_in_arrears <= 30) return 'reminder';
  if (days_in_arrears <= 90) return 'demand_notice';
  if (days_in_arrears <= 180) return 'pre_legal';
  if (days_in_arrears <= 364) return 'legal_review';
  return 'service_process';
};

const createArrearsCase = async (req, res) => {
  try {
    const { nrc_number, principal_amount, days_in_arrears } = req.body;
    const stage = calculateStage(days_in_arrears);
    const id = uuidv4();
    const case_id = `ARREARS-${nrc_number}-${Date.now()}`;
    const result = await pool.query(
      'INSERT INTO arrears_cases (id, case_id, nrc_number, principal_amount, days_in_arrears, stage) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
      [id, case_id, nrc_number, principal_amount, days_in_arrears, stage]
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

const getArrearsCases = async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM arrears_cases ORDER BY days_in_arrears DESC');
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const updateArrearsStage = async (req, res) => {
  try {
    const { id } = req.params;
    const { stage, days_in_arrears } = req.body;
    const result = await pool.query(
      'UPDATE arrears_cases SET stage = $1, days_in_arrears = $2 WHERE id = $3 RETURNING *',
      [stage, days_in_arrears, id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'Arrears case not found' });
    res.json(result.rows[0]);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

module.exports = { createArrearsCase, getArrearsCases, updateArrearsStage };

