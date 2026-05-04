const express = require('express');
const { authenticateToken, authorizeRoles } = require('../middleware/auth');
const { createClient, getClients, getClient, updateClient, deleteClient } = require('../controllers/clientController');
const router = express.Router();

router.use(authenticateToken);

// Lawyer+ can CRUD clients
router.post('/', authorizeRoles(['lawyer', 'partner', 'admin']), createClient);
router.get('/', authorizeRoles(['lawyer', 'partner', 'admin', 'secretary']), getClients);
router.get('/:id', getClient);
router.put('/:id', authorizeRoles(['lawyer', 'partner', 'admin']), updateClient);
router.delete('/:id', authorizeRoles(['partner', 'admin']), deleteClient);

module.exports = router;

