const jwt = require('jsonwebtoken');
const User = require('../models/User');

const protect = async (req, res, next) => {
    let token;

    if (
        req.headers.authorization &&
        req.headers.authorization.startsWith('Bearer')
    ) {
        try {
            token = req.headers.authorization.split(' ')[1];

            const decoded = jwt.verify(token, process.env.JWT_SECRET);
            const user = await User.findById(decoded.id).select('-password');

            // Check if token version matches - reject if user changed password after token issue
            if (decoded.tokenVersion !== undefined && user && decoded.tokenVersion !== user.tokenVersion) {
                return res.status(401).json({ message: 'Token invalidated. Please login again.' });
            }

            if (user?.isBlocked) {
                return res.status(403).json({ message: 'Account blocked. Please contact support.' });
            }

            req.user = user;
            next();
        } catch (error) {
            console.error(error);
            res.status(401);
            throw new Error('Not authorized, token failed');
        }
    }

    if (!token) {
        res.status(401);
        throw new Error('Not authorized, no token');
    }
};

const admin = (req, res, next) => {
    if (req.user && req.user.role === 'admin') {
        next();
    } else {
        res.status(401);
        throw new Error('Not authorized as an admin');
    }
};

const requireRole = (...roles) => (req, res, next) => {
    if (req.user && roles.includes(req.user.role)) {
        return next();
    }
    res.status(403);
    throw new Error('Not authorized for this action');
};

module.exports = { protect, admin, requireRole };
