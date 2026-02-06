const Room = require('../models/Room');

// @desc    Get all rooms with pagination
// @route   GET /api/rooms?page=1&limit=10
// @access  Public
const getRooms = async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const skip = (page - 1) * limit;

        const total = await Room.countDocuments({});
        const rooms = await Room.find({})
            .skip(skip)
            .limit(limit)
            .sort({ createdAt: -1 });

        res.json({
            rooms,
            pagination: {
                currentPage: page,
                totalPages: Math.ceil(total / limit),
                totalItems: total,
                itemsPerPage: limit
            }
        });
    } catch (error) {
        res.status(500).json({ message: 'Server Error' });
    }
};

// @desc    Create a room listing
// @route   POST /api/rooms
// @access  Private (Admin/User)
const createRoom = async (req, res) => {
    const { title, location, price, type, image, contact, amenities } = req.body;

    try {
        const room = new Room({
            title, location, price, type, image, contact, amenities,
            createdBy: req.user?._id ?? null,
        });
        const createdRoom = await room.save();
        res.status(201).json(createdRoom);
    } catch (error) {
        res.status(400).json({ message: 'Invalid room data' });
    }
};

module.exports = { getRooms, createRoom };
