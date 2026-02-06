const User = require('../models/User');
const Room = require('../models/Room');
const Mess = require('../models/Mess');

// @desc    Get dashboard stats
// @route   GET /api/stats
// @access  Public
const getDashboardStats = async (req, res) => {
  try {
    const studentsPromise = User.countDocuments({ role: 'student' });
    const pgOwnersPromise = Room.distinct('createdBy', { createdBy: { $ne: null } });
    const messOwnersPromise = Mess.distinct('createdBy', { createdBy: { $ne: null } });

    const [students, pgOwnerIds, messOwnerIds] = await Promise.all([
      studentsPromise,
      pgOwnersPromise,
      messOwnersPromise,
    ]);

    res.json({
      students,
      pgOwners: pgOwnerIds.length,
      messOwners: messOwnerIds.length,
    });
  } catch (error) {
    res.status(500).json({ message: 'Failed to fetch stats' });
  }
};

module.exports = { getDashboardStats };
