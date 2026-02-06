const express = require('express');
const { getMarketItems, createMarketItem } = require('../controllers/marketController');
const { protect, requireRole } = require('../middleware/authMiddleware');
const router = express.Router();

router.route('/').get(getMarketItems).post(protect, requireRole('student', 'owner'), createMarketItem);

module.exports = router;
