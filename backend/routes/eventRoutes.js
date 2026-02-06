const express = require('express');
const { getEvents, createEvent } = require('../controllers/eventController');
const { protect, admin } = require('../middleware/authMiddleware');
const router = express.Router();

router.route('/').get(getEvents).post(protect, admin, createEvent);

module.exports = router;
