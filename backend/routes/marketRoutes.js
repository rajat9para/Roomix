const express = require('express');
const { getMarketItems, createMarketItem } = require('../controllers/marketController');
const { protect } = require('../middleware/authMiddleware');
const router = express.Router();

router.route('/').get(getMarketItems).post(protect, createMarketItem);

module.exports = router;
