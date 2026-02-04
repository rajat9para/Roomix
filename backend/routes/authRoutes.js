const express = require('express');
const { authUser, registerUser, verifyAdminOtp, googleAuth, forgotPassword, verifyResetOtp, resetPassword } = require('../controllers/authController');
const router = express.Router();

router.post('/login', authUser);
router.post('/register', registerUser);
router.post('/verify-otp', verifyAdminOtp);
router.post('/google', googleAuth);
router.post('/forgot-password', forgotPassword);
router.post('/verify-reset-otp', verifyResetOtp);
router.post('/reset-password', resetPassword);

module.exports = router;
