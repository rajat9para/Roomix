const express = require('express');
const { getLostItems, createLostItem } = require('../controllers/lostController');
const { protect, requireRole } = require('../middleware/authMiddleware');
const router = express.Router();

router.route('/').get(getLostItems).post(protect, requireRole('student'), createLostItem);

module.exports = router;
