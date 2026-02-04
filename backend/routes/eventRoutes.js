const express = require('express');
const { getEvents, createEvent } = require('../controllers/eventController');
const { protect } = require('../middleware/authMiddleware');
const router = express.Router();

router.route('/').get(getEvents).post(protect, createEvent);

module.exports = router;
