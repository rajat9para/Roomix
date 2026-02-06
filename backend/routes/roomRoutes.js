const express = require('express');
const { getRooms, createRoom } = require('../controllers/roomController');
const { protect, requireRole } = require('../middleware/authMiddleware');
const router = express.Router();

router.route('/').get(getRooms).post(protect, requireRole('owner', 'admin'), createRoom);

module.exports = router;
