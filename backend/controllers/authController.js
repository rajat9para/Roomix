const User = require('../models/User');
const generateToken = require('../utils/generateToken');
const sendEmail = require('../utils/sendEmail');
const crypto = require('crypto');
const admin = require('../config/firebaseAdmin');

// @desc    Auth user & get token (Login)
// @route   POST /api/auth/login
// @access  Public
const authUser = async (req, res) => {
    const { email, password, role } = req.body;

    const user = await User.findOne({ email });

    // 1. Check if user exists
    if (!user) {
        return res.status(401).json({ message: 'Invalid email or password' });
    }

    // 2. Check if role matches (user cannot login as admin if they are student)
    if (role && user.role !== role) {
        return res.status(401).json({ message: `Access denied. You are not a ${role}.` });
    }

    // 3. ADMIN LOGIN FLOW (Strict OTP Check)
    if (user.role === 'admin') {
        const adminEmail = process.env.ADMIN_EMAIL;

        // Strict Email Check
        if (email !== adminEmail) {
            return res.status(403).json({ message: 'Access Denied: Not an authorized Admin email.' });
        }

        // Verify Password first
        if (await user.matchPassword(password)) {
            // Generate OTP
            const otp = Math.floor(100000 + Math.random() * 900000).toString();

            // Hash OTP and save to DB
            const salt = crypto.randomBytes(16).toString('hex');
            const hashedOtp = crypto.createHmac('sha256', salt).update(otp).digest('hex');

            user.otp = `${salt}:${hashedOtp}`; // Store salt and hash
            user.otpExpires = Date.now() + 10 * 60 * 1000; // 10 Minutes
            await user.save();

            // Send Email
            try {
                await sendEmail({
                    email: user.email,
                    subject: 'Roomix App - Admin Login OTP',
                    message: `Your OTP for Admin access is: ${otp}. It expires in 10 minutes.`,
                });

                return res.status(200).json({
                    message: 'OTP sent to admin email.',
                    requiresOtp: true,
                    email: user.email
                });
            } catch (error) {
                user.otp = undefined;
                user.otpExpires = undefined;
                await user.save();
                return res.status(500).json({ message: 'Email could not be sent.' });
            }
        } else {
            return res.status(401).json({ message: 'Invalid email or password' });
        }
    }

    // 4. STUDENT / OWNER LOGIN FLOW
    if (await user.matchPassword(password)) {
        res.json({
            _id: user._id,
            name: user.name,
            email: user.email,
            role: user.role,
            photoUrl: user.photoUrl,
            token: generateToken(user._id, user.tokenVersion || 0),
        });
    } else {
        res.status(401).json({ message: 'Invalid email or password' });
    }
};

// @desc    Google Authentication with Firebase
// @route   POST /api/auth/google
// @access  Public
const googleAuth = async (req, res) => {
    const { idToken, email, name, photoUrl, role } = req.body;

    try {
        // For development/testing, we'll verify the token structure
        // In production, use admin.auth().verifyIdToken(idToken)
        if (!idToken || !email || !name) {
            return res.status(400).json({ message: 'Missing required fields' });
        }

        // Block admin role for Google Sign-In
        if (role === 'admin') {
            return res.status(403).json({
                message: 'Admin login requires email/password authentication with OTP'
            });
        }

        // Check if user exists
        let user = await User.findOne({ email });

        if (user) {
            // User exists, check role match
            if (user.role !== role) {
                return res.status(401).json({
                    message: `This email is registered as ${user.role}. Please select the correct role.`
                });
            }

            // Update photo URL if provided
            if (photoUrl && !user.photoUrl) {
                user.photoUrl = photoUrl;
                await user.save();
            }
        } else {
            // Create new user with Google Sign-In
            user = await User.create({
                name,
                email,
                password: crypto.randomBytes(32).toString('hex'), // Random password for Google users
                role: role || 'student',
                photoUrl: photoUrl,
                isGoogleUser: true,
            });
        }

        // Return user data with JWT token
        res.json({
            _id: user._id,
            name: user.name,
            email: user.email,
            role: user.role,
            photoUrl: user.photoUrl,
            token: generateToken(user._id, user.tokenVersion || 0),
        });

    } catch (error) {
        console.error('Google Auth Error:', error);
        res.status(500).json({ message: 'Google authentication failed. Please try again.' });
    }
};

// @desc    Verify OTP and Login Admin
// @route   POST /api/auth/verify-otp
// @access  Public
const verifyAdminOtp = async (req, res) => {
    const { email, otp } = req.body;

    const user = await User.findOne({ email, role: 'admin' });

    if (!user || !user.otp || !user.otpExpires) {
        return res.status(400).json({ message: 'Invalid Request or OTP expired' });
    }

    if (user.otpExpires < Date.now()) {
        return res.status(400).json({ message: 'OTP expired' });
    }

    // Verify Hash
    const [salt, storedHash] = user.otp.split(':');
    const hash = crypto.createHmac('sha256', salt).update(otp).digest('hex');

    if (hash === storedHash) {
        // Clear OTP
        user.otp = undefined;
        user.otpExpires = undefined;
        await user.save();

        res.json({
            _id: user._id,
            name: user.name,
            email: user.email,
            role: user.role,
            token: generateToken(user._id, user.tokenVersion || 0),
        });
    } else {
        res.status(400).json({ message: 'Invalid OTP' });
    }
};

// @desc    Register a new user
// @route   POST /api/auth/register
// @access  Public
const registerUser = async (req, res) => {
    const { name, email, password, role } = req.body;

    // Block Admin Registration
    if (role === 'admin') {
        return res.status(403).json({ message: 'Admin registration is restricted.' });
    }

    // Default to student if not provided
    const userRole = role || 'student';

    const userExists = await User.findOne({ email });

    if (userExists) {
        res.status(400).json({ message: 'User already exists' });
        return;
    }

    const user = await User.create({
        name,
        email,
        password,
        role: userRole
    });

        if (user) {
        res.status(201).json({
            _id: user._id,
            name: user.name,
            email: user.email,
            role: user.role,
            token: generateToken(user._id, user.tokenVersion || 0),
        });
    } else {
        res.status(400).json({ message: 'Invalid user data' });
    }
};

// @desc    Send Password Reset OTP
// @route   POST /api/auth/forgot-password
// @access  Public
const forgotPassword = async (req, res) => {
    const { email } = req.body;

    try {
        if (!email) {
            return res.status(400).json({ message: 'Email is required' });
        }

        const user = await User.findOne({ email });

        if (!user) {
            return res.status(404).json({ message: 'User with this email does not exist' });
        }

        // Generate 6-digit OTP
        const otp = Math.floor(100000 + Math.random() * 900000).toString();

        // Hash OTP with salt
        const salt = crypto.randomBytes(16).toString('hex');
        const hashedOtp = crypto.createHmac('sha256', salt).update(otp).digest('hex');

        // Store reset OTP and expiry
        user.resetOtp = `${salt}:${hashedOtp}`;
        user.resetOtpExpires = Date.now() + 15 * 60 * 1000; // 15 Minutes
        await user.save();

        // Send OTP via email
        try {
            await sendEmail({
                email: user.email,
                subject: 'Roomix App - Password Reset OTP',
                message: `Your OTP for password reset is: ${otp}. It expires in 15 minutes. Do not share this OTP with anyone.`,
            });

            res.status(200).json({
                message: 'OTP sent to your email address',
                email: user.email,
            });
        } catch (emailError) {
            // Clear OTP if email fails
            user.resetOtp = undefined;
            user.resetOtpExpires = undefined;
            await user.save();

            return res.status(500).json({ message: 'Failed to send email. Please try again.' });
        }
    } catch (error) {
        console.error('Forgot Password Error:', error);
        res.status(500).json({ message: 'Server error. Please try again later.' });
    }
};

// @desc    Verify Password Reset OTP
// @route   POST /api/auth/verify-reset-otp
// @access  Public
const verifyResetOtp = async (req, res) => {
    const { email, otp } = req.body;

    try {
        if (!email || !otp) {
            return res.status(400).json({ message: 'Email and OTP are required' });
        }

        const user = await User.findOne({ email });

        if (!user || !user.resetOtp || !user.resetOtpExpires) {
            return res.status(400).json({ message: 'Invalid request or OTP expired' });
        }

        // Check if OTP has expired
        if (user.resetOtpExpires < Date.now()) {
            user.resetOtp = undefined;
            user.resetOtpExpires = undefined;
            await user.save();
            return res.status(400).json({ message: 'OTP has expired. Please request a new one.' });
        }

        // Verify OTP hash
        const [salt, storedHash] = user.resetOtp.split(':');
        const hash = crypto.createHmac('sha256', salt).update(otp).digest('hex');

        if (hash !== storedHash) {
            return res.status(400).json({ message: 'Invalid OTP' });
        }

        // Generate reset token (short-lived token for password reset)
        const resetToken = crypto.randomBytes(32).toString('hex');
        const hashedToken = crypto.createHash('sha256').update(resetToken).digest('hex');

        user.resetToken = hashedToken;
        user.resetTokenExpires = Date.now() + 10 * 60 * 1000; // 10 Minutes
        // Keep resetOtp and resetOtpExpires for potential resend
        await user.save();

        res.status(200).json({
            message: 'OTP verified successfully',
            resetToken: resetToken, // Send unhashed token to client
        });
    } catch (error) {
        console.error('Verify Reset OTP Error:', error);
        res.status(500).json({ message: 'Server error. Please try again later.' });
    }
};

// @desc    Reset Password with Token
// @route   POST /api/auth/reset-password
// @access  Public
const resetPassword = async (req, res) => {
    const { email, resetToken, newPassword } = req.body;

    try {
        if (!email || !resetToken || !newPassword) {
            return res.status(400).json({ message: 'Email, reset token, and new password are required' });
        }

        // Validate password
        if (newPassword.length < 8) {
            return res.status(400).json({ message: 'Password must be at least 8 characters long' });
        }

        if (!/(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])/.test(newPassword)) {
            return res.status(400).json({ message: 'Password must contain uppercase, lowercase, and numbers' });
        }

        const user = await User.findOne({ email });

        if (!user || !user.resetToken || !user.resetTokenExpires) {
            return res.status(400).json({ message: 'Invalid reset request or token expired' });
        }

        // Check if token has expired
        if (user.resetTokenExpires < Date.now()) {
            user.resetToken = undefined;
            user.resetTokenExpires = undefined;
            await user.save();
            return res.status(400).json({ message: 'Reset token has expired. Please request a new one.' });
        }

        // Verify reset token
        const hashedToken = crypto.createHash('sha256').update(resetToken).digest('hex');
        if (hashedToken !== user.resetToken) {
            return res.status(400).json({ message: 'Invalid reset token' });
        }

        // Update password
        user.password = newPassword;
        user.resetToken = undefined;
        user.resetTokenExpires = undefined;
        user.resetOtp = undefined;
        user.resetOtpExpires = undefined;
        // Invalidate all existing sessions by incrementing tokenVersion
        user.tokenVersion = (user.tokenVersion || 0) + 1;
        user.passwordChangedAt = new Date();
        await user.save();

        res.status(200).json({
            message: 'Password reset successfully',
        });
    } catch (error) {
        console.error('Reset Password Error:', error);
        res.status(500).json({ message: 'Server error. Please try again later.' });
    }
};

module.exports = { authUser, registerUser, verifyAdminOtp, googleAuth, forgotPassword, verifyResetOtp, resetPassword };
