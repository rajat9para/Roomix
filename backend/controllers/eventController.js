const Event = require('../models/Event');

// @desc    Get all events with pagination
// @route   GET /api/events?page=1&limit=10
// @access  Public
const getEvents = async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const skip = (page - 1) * limit;

        const total = await Event.countDocuments({});
        const events = await Event.find({})
            .skip(skip)
            .limit(limit)
            .sort({ date: 1 });

        res.json({
            events,
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

// @desc    Create an event
// @route   POST /api/events
// @access  Private (Admin usually, but allowing User for now)
const createEvent = async (req, res) => {
    const { title, date, venue, description, image } = req.body;

    try {
        const event = new Event({
            title, date, venue, description, image
        });
        const createdEvent = await event.save();
        res.status(201).json(createdEvent);
    } catch (error) {
        res.status(400).json({ message: 'Invalid event data' });
    }
};

module.exports = { getEvents, createEvent };
