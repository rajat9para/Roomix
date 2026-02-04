const express = require('express');
const { getMess, createMess } = require('../controllers/messController');
const { protect } = require('../middleware/authMiddleware');
const router = express.Router();

router.route('/').get(getMess).post(protect, createMess);

module.exports = router;
