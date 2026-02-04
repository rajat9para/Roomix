const Mess = require('../models/Mess');

// @desc    Get all mess menus with pagination
// @route   GET /api/mess?page=1&limit=10
// @access  Public
const getMess = async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const skip = (page - 1) * limit;

        const total = await Mess.countDocuments({});
        const mess = await Mess.find({})
            .skip(skip)
            .limit(limit)
            .sort({ createdAt: -1 });

        res.json({
            mess,
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

// @desc    Create a mess listing
// @route   POST /api/mess
// @access  Private
const createMess = async (req, res) => {
    const { name, monthlyPrice, timings, menuPreview, image } = req.body;

    try {
        const mess = new Mess({
            name, monthlyPrice, timings, menuPreview, image
        });
        const createdMess = await mess.save();
        res.status(201).json(createdMess);
    } catch (error) {
        res.status(400).json({ message: 'Invalid mess data' });
    }
};

module.exports = { getMess, createMess };
