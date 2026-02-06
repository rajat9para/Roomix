const express = require('express');
const { getActiveNotifications } = require('../controllers/notificationController');

const router = express.Router();

router.get('/', getActiveNotifications);

module.exports = router;
