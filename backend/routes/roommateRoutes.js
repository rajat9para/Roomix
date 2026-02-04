const express = require('express');
const roommateController = require('../controllers/roommateController');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

// Protect all routes with auth middleware
router.use(authMiddleware);

// Create or update profile
router.post('/profile', roommateController.createProfile);

// Get current user's profile
router.get('/profile', roommateController.getMyProfile);

// Get all profiles
router.get('/all', roommateController.getAllProfiles);

// Get profile by user ID
router.get('/profile/:userId', roommateController.getProfileById);

// Get compatible matches
router.get('/matches', roommateController.getMatches);

// Delete profile
router.delete('/profile', roommateController.deleteProfile);

module.exports = router;
