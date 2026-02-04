const LostItem = require('../models/LostItem');

// @desc    Get all lost items with pagination
// @route   GET /api/lost?page=1&limit=10
// @access  Public
const getLostItems = async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const skip = (page - 1) * limit;

        // Filter for unclaimed items
        const query = { claimStatus: { $ne: 'Resolved' } };

        const total = await LostItem.countDocuments(query);
        const items = await LostItem.find(query)
            .skip(skip)
            .limit(limit)
            .sort({ createdAt: -1 })
            .populate('user', 'name email')
            .populate('claimedBy', 'name email');

        res.json({
            items,
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

// @desc    Create a lost item post
// @route   POST /api/lostfound
// @access  Private
const createLostItem = async (req, res) => {
    const { title, description, status, image, contact } = req.body;

    try {
        const item = new LostItem({
            title, description, status, image, contact, user: req.user._id
        });
        const createdItem = await item.save();
        res.status(201).json(createdItem);
    } catch (error) {
        res.status(400).json({ message: 'Invalid data' });
    }
};

module.exports = { getLostItems, createLostItem };
