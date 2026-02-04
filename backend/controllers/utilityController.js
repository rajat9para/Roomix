const Utility = require('../models/Utility');

// @desc    Get all utilities with optional filtering
// @route   GET /api/utilities
// @access  Public
const getUtilities = async (req, res) => {
    try {
        const { category, verified, latitude, longitude, radius } = req.query;
        let query = { isActive: true, verified: true };

        // Filter by category
        if (category) {
            query.category = category;
        }

        // Filter by verification status (admin only - non-admins always see verified only)
        if (verified !== undefined && req.user?.role === 'admin') {
            query.verified = verified === 'true';
        }

        // Geospatial query (within radius)
        if (latitude && longitude && radius) {
            query.location = {
                $near: {
                    $geometry: {
                        type: 'Point',
                        coordinates: [parseFloat(longitude), parseFloat(latitude)]
                    },
                    $maxDistance: parseInt(radius) || 5000 // Default 5km
                }
            };
        }

        const utilities = await Utility.find(query)
            .populate('addedBy', 'name email')
            .populate('reviews.userId', 'name');

        res.json(utilities);
    } catch (error) {
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

// @desc    Get single utility by ID
// @route   GET /api/utilities/:id
// @access  Public
const getUtility = async (req, res) => {
    try {
        const utility = await Utility.findById(req.params.id)
            .populate('addedBy', 'name email')
            .populate('reviews.userId', 'name');

        if (!utility) {
            return res.status(404).json({ message: 'Utility not found' });
        }

        res.json(utility);
    } catch (error) {
        res.status(500).json({ message: 'Server Error' });
    }
};

// @desc    Create a new utility
// @route   POST /api/utilities
// @access  Private
const createUtility = async (req, res) => {
    const { name, category, latitude, longitude, address, contact, description, image, tags, operatingHours } = req.body;

    try {
        const utility = new Utility({
            name,
            category,
            location: {
                type: 'Point',
                coordinates: [parseFloat(longitude), parseFloat(latitude)],
                address
            },
            contact,
            description,
            image,
            addedBy: req.user._id,
            tags,
            operatingHours,
            verified: false
        });

        const createdUtility = await utility.save();
        const populated = await createdUtility.populate('addedBy', 'name email');
        res.status(201).json(populated);
    } catch (error) {
        res.status(400).json({ message: 'Invalid utility data', error: error.message });
    }
};

// @desc    Update utility
// @route   PUT /api/utilities/:id
// @access  Private
const updateUtility = async (req, res) => {
    try {
        let utility = await Utility.findById(req.params.id);

        if (!utility) {
            return res.status(404).json({ message: 'Utility not found' });
        }

        // Check if user is the one who added it or admin
        if (utility.addedBy.toString() !== req.user._id.toString() && req.user.role !== 'admin') {
            return res.status(403).json({ message: 'Not authorized to update this utility' });
        }

        const { name, category, latitude, longitude, address, contact, description, image, tags, operatingHours } = req.body;

        if (name) utility.name = name;
        if (category) utility.category = category;
        if (latitude && longitude) {
            utility.location.coordinates = [parseFloat(longitude), parseFloat(latitude)];
            utility.location.address = address || utility.location.address;
        }
        if (contact) utility.contact = contact;
        if (description) utility.description = description;
        if (image) utility.image = image;
        if (tags) utility.tags = tags;
        if (operatingHours) utility.operatingHours = operatingHours;

        const updatedUtility = await utility.save();
        const populated = await updatedUtility.populate('addedBy', 'name email');
        res.json(populated);
    } catch (error) {
        res.status(400).json({ message: 'Invalid utility data', error: error.message });
    }
};

// @desc    Delete utility
// @route   DELETE /api/utilities/:id
// @access  Private
const deleteUtility = async (req, res) => {
    try {
        const utility = await Utility.findById(req.params.id);

        if (!utility) {
            return res.status(404).json({ message: 'Utility not found' });
        }

        // Check if user is the one who added it or admin
        if (utility.addedBy.toString() !== req.user._id.toString() && req.user.role !== 'admin') {
            return res.status(403).json({ message: 'Not authorized to delete this utility' });
        }

        await Utility.findByIdAndDelete(req.params.id);
        res.json({ message: 'Utility removed' });
    } catch (error) {
        res.status(500).json({ message: 'Server Error' });
    }
};

// @desc    Add review to utility
// @route   POST /api/utilities/:id/review
// @access  Private
const addReview = async (req, res) => {
    try {
        const { rating, comment } = req.body;
        const utility = await Utility.findById(req.params.id);

        if (!utility) {
            return res.status(404).json({ message: 'Utility not found' });
        }

        const review = {
            userId: req.user._id,
            rating,
            comment,
            createdAt: new Date()
        };

        utility.reviews.push(review);

        // Calculate average rating
        const totalRating = utility.reviews.reduce((sum, r) => sum + r.rating, 0);
        const averageRating = totalRating / utility.reviews.length;
        utility.rating = parseFloat(averageRating.toFixed(1));

        const updatedUtility = await utility.save();
        const populated = await updatedUtility.populate('reviews.userId', 'name');
        res.status(201).json(populated);
    } catch (error) {
        res.status(400).json({ message: 'Failed to add review', error: error.message });
    }
};

// @desc    Get utilities by category
// @route   GET /api/utilities/category/:category
// @access  Public
const getUtilitiesByCategory = async (req, res) => {
    try {
        const { category } = req.params;
        const utilities = await Utility.find({ 
            category, 
            isActive: true, 
            verified: true 
        })
            .populate('addedBy', 'name email')
            .populate('reviews.userId', 'name');

        res.json(utilities);
    } catch (error) {
        res.status(500).json({ message: 'Server Error' });
    }
};

// @desc    Search utilities by name/tags
// @route   GET /api/utilities/search/:query
// @access  Public
const searchUtilities = async (req, res) => {
    try {
        const { query } = req.params;
        const utilities = await Utility.find({
            $or: [
                { name: { $regex: query, $options: 'i' } },
                { tags: { $in: [new RegExp(query, 'i')] } },
                { description: { $regex: query, $options: 'i' } }
            ],
            isActive: true,
            verified: true
        })
            .populate('addedBy', 'name email')
            .populate('reviews.userId', 'name');

        res.json(utilities);
    } catch (error) {
        res.status(500).json({ message: 'Server Error' });
    }
};

// ADMIN ENDPOINTS

// @desc    Get all utilities (including unverified) - Admin only
// @route   GET /api/utilities/admin/all
// @access  Private/Admin
const getAllUtilitiesAdmin = async (req, res) => {
    try {
        const utilities = await Utility.find()
            .populate('addedBy', 'name email')
            .populate('reviews.userId', 'name')
            .sort({ createdAt: -1 });

        res.json(utilities);
    } catch (error) {
        res.status(500).json({ message: 'Server Error' });
    }
};

// @desc    Verify utility - Admin only
// @route   PUT /api/utilities/admin/:id/verify
// @access  Private/Admin
const verifyUtility = async (req, res) => {
    try {
        const utility = await Utility.findById(req.params.id);

        if (!utility) {
            return res.status(404).json({ message: 'Utility not found' });
        }

        utility.verified = true;
        utility.rejectionReason = null;
        const updatedUtility = await utility.save();

        res.json({ message: 'Utility verified', utility: updatedUtility });
    } catch (error) {
        res.status(500).json({ message: 'Server Error' });
    }
};

// @desc    Reject utility - Admin only
// @route   PUT /api/utilities/admin/:id/reject
// @access  Private/Admin
const rejectUtility = async (req, res) => {
    try {
        const { reason } = req.body;
        const utility = await Utility.findById(req.params.id);

        if (!utility) {
            return res.status(404).json({ message: 'Utility not found' });
        }

        utility.verified = false;
        utility.rejectionReason = reason;
        const updatedUtility = await utility.save();

        res.json({ message: 'Utility rejected', utility: updatedUtility });
    } catch (error) {
        res.status(500).json({ message: 'Server Error' });
    }
};

// @desc    Get pending utilities for verification - Admin only
// @route   GET /api/utilities/admin/pending
// @access  Private/Admin
const getPendingUtilities = async (req, res) => {
    try {
        const utilities = await Utility.find({ verified: false })
            .populate('addedBy', 'name email')
            .sort({ createdAt: -1 });

        res.json(utilities);
    } catch (error) {
        res.status(500).json({ message: 'Server Error' });
    }
};

module.exports = {
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
};
