const express = require('express');
const {
    getUtilities,
    getUtility,
    createUtility,
    updateUtility,
    deleteUtility,
    addReview,
    getUtilitiesByCategory,
    searchUtilities,
    getAllUtilitiesAdmin,
    verifyUtility,
    rejectUtility,
    getPendingUtilities
} = require('../controllers/utilityController');
const { protect, admin } = require('../middleware/authMiddleware');
const router = express.Router();

// Public routes
router.route('/').get(getUtilities).post(protect, createUtility);

// Specific static routes BEFORE dynamic :id routes
router.get('/category/:category', getUtilitiesByCategory);
router.get('/search/:query', searchUtilities);

// Admin routes
router.get('/admin/all', protect, admin, getAllUtilitiesAdmin);
router.get('/admin/pending', protect, admin, getPendingUtilities);
router.put('/admin/:id/verify', protect, admin, verifyUtility);
router.put('/admin/:id/reject', protect, admin, rejectUtility);

// Review route
router.post('/:id/review', protect, addReview);

// Dynamic ID routes LAST to prevent shadowing specific paths
router.route('/:id').get(getUtility).put(protect, updateUtility).delete(protect, deleteUtility);

module.exports = router;
