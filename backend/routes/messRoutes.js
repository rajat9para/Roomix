const express = require('express');
const { getMess, createMess } = require('../controllers/messController');
const { protect, requireRole } = require('../middleware/authMiddleware');
const router = express.Router();

router.route('/').get(getMess).post(protect, requireRole('owner', 'admin'), createMess);

module.exports = router;
