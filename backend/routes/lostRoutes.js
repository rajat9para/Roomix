const express = require('express');
const { getLostItems, createLostItem } = require('../controllers/lostController');
const { protect } = require('../middleware/authMiddleware');
const router = express.Router();

router.route('/').get(getLostItems).post(protect, createLostItem);

module.exports = router;
