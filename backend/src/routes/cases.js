const express = require('express');
const { authenticateToken, authorizeRoles } = require('../middleware/auth');
const { createCase, getCases, getCase, updateCase, deleteCase } = require('../controllers/caseController');
const router = express.Router();

router.use(authenticateToken);

router.post('/', authorizeRoles(['lawyer', 'partner', 'admin']), createCase);
router.get('/', getCases);
router.get('/:id', getCase);
router.put('/:id', authorizeRoles(['lawyer', 'partner', 'admin']), updateCase);
router.delete('/:id', authorizeRoles(['partner', 'admin']), deleteCase);

module.exports = router;

