const MarketItem = require('../models/MarketItem');

// @desc    Get all market items with pagination
// @route   GET /api/market?page=1&limit=10
// @access  Public
const getMarketItems = async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const skip = (page - 1) * limit;

        // Filter for unsold items
        const query = { sold: { $ne: true } };

        const total = await MarketItem.countDocuments(query);
        const items = await MarketItem.find(query)
            .skip(skip)
            .limit(limit)
            .sort({ createdAt: -1 })
            .populate('user', 'name email');

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

// @desc    Create a market item
// @route   POST /api/market
// @access  Private
const createMarketItem = async (req, res) => {
    const { title, price, condition, image, sellerContact, sellerName } = req.body;

    try {
        const item = new MarketItem({
            title, price, condition, image, sellerContact, sellerName, user: req.user._id
        });
        const createdItem = await item.save();
        res.status(201).json(createdItem);
    } catch (error) {
        console.log(error);
        res.status(400).json({ message: 'Invalid data' });
    }
};

module.exports = { getMarketItems, createMarketItem };
