const Notification = require('../models/Notification');

// @desc    Get active notifications
// @route   GET /api/notifications
// @access  Public
const getActiveNotifications = async (req, res) => {
  try {
    const notifications = await Notification.find({ isActive: true })
      .sort({ createdAt: -1 })
      .limit(5);
    res.json({ notifications });
  } catch (error) {
    res.status(500).json({ message: 'Failed to fetch notifications' });
  }
};

module.exports = { getActiveNotifications };
