const express = require('express');
const { protect, admin } = require('../middleware/authMiddleware');
const {
  getUsers,
  blockUser,
  unblockUser,
  createNotification,
  getNotifications,
  deleteRoom,
  deleteMess,
  deleteLostItem,
  deleteMarketItem,
} = require('../controllers/adminController');

const router = express.Router();

router.get('/users', protect, admin, getUsers);
router.put('/users/:id/block', protect, admin, blockUser);
router.put('/users/:id/unblock', protect, admin, unblockUser);

router.get('/notifications', protect, admin, getNotifications);
router.post('/notifications', protect, admin, createNotification);

// Moderation endpoints
router.delete('/rooms/:id', protect, admin, deleteRoom);
router.delete('/mess/:id', protect, admin, deleteMess);
router.delete('/lost/:id', protect, admin, deleteLostItem);
router.delete('/market/:id', protect, admin, deleteMarketItem);

module.exports = router;
