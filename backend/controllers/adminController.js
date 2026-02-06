const User = require('../models/User');
const Notification = require('../models/Notification');
const Room = require('../models/Room');
const Mess = require('../models/Mess');
const LostItem = require('../models/LostItem');
const MarketItem = require('../models/MarketItem');

// @desc    Get all users
// @route   GET /api/admin/users
// @access  Admin
const getUsers = async (req, res) => {
  try {
    const users = await User.find({})
      .select('-password')
      .sort({ createdAt: -1 });
    res.json({ users });
  } catch (error) {
    res.status(500).json({ message: 'Failed to fetch users' });
  }
};

// @desc    Block a user
// @route   PUT /api/admin/users/:id/block
// @access  Admin
const blockUser = async (req, res) => {
  try {
    const user = await User.findByIdAndUpdate(
      req.params.id,
      { isBlocked: true },
      { new: true }
    ).select('-password');
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.json({ user });
  } catch (error) {
    res.status(500).json({ message: 'Failed to block user' });
  }
};

// @desc    Unblock a user
// @route   PUT /api/admin/users/:id/unblock
// @access  Admin
const unblockUser = async (req, res) => {
  try {
    const user = await User.findByIdAndUpdate(
      req.params.id,
      { isBlocked: false },
      { new: true }
    ).select('-password');
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.json({ user });
  } catch (error) {
    res.status(500).json({ message: 'Failed to unblock user' });
  }
};

// @desc    Create global notification
// @route   POST /api/admin/notifications
// @access  Admin
const createNotification = async (req, res) => {
  try {
    const { message } = req.body;
    if (!message) {
      return res.status(400).json({ message: 'Message is required' });
    }
    const notification = await Notification.create({
      message,
      createdBy: req.user?._id ?? null,
      isActive: true,
    });
    res.status(201).json({ notification });
  } catch (error) {
    res.status(500).json({ message: 'Failed to create notification' });
  }
};

// @desc    Get all notifications (admin)
// @route   GET /api/admin/notifications
// @access  Admin
const getNotifications = async (req, res) => {
  try {
    const notifications = await Notification.find({})
      .sort({ createdAt: -1 });
    res.json({ notifications });
  } catch (error) {
    res.status(500).json({ message: 'Failed to fetch notifications' });
  }
};

module.exports = {
  getUsers,
  blockUser,
  unblockUser,
  createNotification,
  getNotifications,
  deleteRoom: async (req, res) => {
    try {
      await Room.findByIdAndDelete(req.params.id);
      res.json({ message: 'Room deleted' });
    } catch (error) {
      res.status(500).json({ message: 'Failed to delete room' });
    }
  },
  deleteMess: async (req, res) => {
    try {
      await Mess.findByIdAndDelete(req.params.id);
      res.json({ message: 'Mess deleted' });
    } catch (error) {
      res.status(500).json({ message: 'Failed to delete mess' });
    }
  },
  deleteLostItem: async (req, res) => {
    try {
      await LostItem.findByIdAndDelete(req.params.id);
      res.json({ message: 'Lost item deleted' });
    } catch (error) {
      res.status(500).json({ message: 'Failed to delete lost item' });
    }
  },
  deleteMarketItem: async (req, res) => {
    try {
      await MarketItem.findByIdAndDelete(req.params.id);
      res.json({ message: 'Market item deleted' });
    } catch (error) {
      res.status(500).json({ message: 'Failed to delete market item' });
    }
  },
};
