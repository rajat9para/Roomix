const express = require('express');
const router = express.Router();
const { getProfile, updateProfile, updateSettings, uploadProfilePicture } = require('../controllers/profileController');
const { protect } = require('../middleware/authMiddleware');
const { upload } = require('../config/cloudinary');

router.get('/', protect, getProfile);
router.put('/', protect, updateProfile);
router.put('/settings', protect, updateSettings);
// multipart/form-data with field name 'image'
router.post('/upload', protect, upload.single('image'), uploadProfilePicture);

module.exports = router;
