const express = require('express');
const { authenticateToken, authorizeRoles } = require('../middleware/auth');
const { createArrearsCase, getArrearsCases, updateArrearsStage } = require('../controllers/arrearsController');
const router = express.Router();

router.use(authenticateToken);

router.post('/', authorizeRoles(['lawyer', 'partner', 'admin']), createArrearsCase);
router.get('/', getArrearsCases);
router.put('/:id/stage', authorizeRoles(['lawyer', 'partner', 'admin']), updateArrearsStage);

module.exports = router;

