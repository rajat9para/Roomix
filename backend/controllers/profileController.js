const User = require('../models/User');
const asyncHandler = require('express-async-handler');
const { cloudinary } = require('../config/cloudinary');

// @desc    Get current user's profile
// @route   GET /api/profile/
// @access  Private
const getProfile = asyncHandler(async (req, res) => {
    const user = req.user;
    if (!user) {
        res.status(404);
        throw new Error('User not found');
    }

    res.json({
        _id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
        profilePicture: user.profilePicture || user.photoUrl || '',
        notificationSettings: user.notificationSettings,
        privacySettings: user.privacySettings,
        selectedUniversity: user.selectedUniversity,
    });
});

// @desc    Update user profile fields
// @route   PUT /api/profile/
// @access  Private
const updateProfile = asyncHandler(async (req, res) => {
    const user = req.user;
    if (!user) {
        res.status(404);
        throw new Error('User not found');
    }

    const { name, profilePicture, selectedUniversity } = req.body;

    if (name) user.name = name;
    if (typeof profilePicture === 'string') user.profilePicture = profilePicture;
    if (selectedUniversity) user.selectedUniversity = selectedUniversity;

    await user.save();

    res.json({ message: 'Profile updated successfully', user });
});

// @desc    Update notification/privacy settings
// @route   PUT /api/profile/settings
// @access  Private
const updateSettings = asyncHandler(async (req, res) => {
    const user = req.user;
    if (!user) {
        res.status(404);
        throw new Error('User not found');
    }

    const { notificationSettings, privacySettings } = req.body;

    if (notificationSettings && typeof notificationSettings === 'object') {
        user.notificationSettings = {
            ...user.notificationSettings.toObject?.() || user.notificationSettings,
            ...notificationSettings,
        };
    }

    if (privacySettings && typeof privacySettings === 'object') {
        user.privacySettings = {
            ...user.privacySettings.toObject?.() || user.privacySettings,
            ...privacySettings,
        };
    }

    await user.save();

    res.json({ message: 'Settings updated', notificationSettings: user.notificationSettings, privacySettings: user.privacySettings });
});

// @desc    Upload profile picture (Cloudinary via multer)
// @route   POST /api/profile/upload
// @access  Private
const uploadProfilePicture = asyncHandler(async (req, res) => {
    // multer + Cloudinary storage should populate req.file
    if (!req.file || !req.file.path) {
        res.status(400);
        throw new Error('No image uploaded');
    }

    const user = req.user;
    user.profilePicture = req.file.path; // secure_url from Cloudinary storage
    await user.save();

    res.json({ message: 'Profile picture updated', profilePicture: user.profilePicture });
});

module.exports = { getProfile, updateProfile, updateSettings, uploadProfilePicture };
