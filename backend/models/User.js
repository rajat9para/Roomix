const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = mongoose.Schema({
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    role: { type: String, enum: ['student', 'owner', 'admin'], default: 'student' },
    photoUrl: { type: String },
    isGoogleUser: { type: Boolean, default: false },
    otp: { type: String },
    otpExpires: { type: Date },
    resetOtp: { type: String },
    resetOtpExpires: { type: Date },
    resetToken: { type: String },
    resetTokenExpires: { type: Date },
    passwordChangedAt: { type: Date },
    tokenVersion: { type: Number, default: 0 },
    // Profile and settings
    profilePicture: { type: String, default: '' },
    notificationSettings: {
        emailNotifications: { type: Boolean, default: true },
        pushNotifications: { type: Boolean, default: true },
    },
    privacySettings: {
        visibility: { type: String, enum: ['public', 'private', 'friends'], default: 'public' },
        showLastSeen: { type: Boolean, default: true },
    },
    selectedUniversity: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'University',
        default: null,
    },
    isOnboardingComplete: {
        type: Boolean,
        default: false,
    },
    // Student onboarding fields
    course: { type: String, default: '' },
    year: { type: String, default: '' },
    collegeName: { type: String, default: '' },
    contactNumber: { type: String, default: '' },
    campusLatitude: { type: Number, default: null },
    campusLongitude: { type: Number, default: null },
    campusAddress: { type: String, default: '' },
    // Admin controls
    isBlocked: { type: Boolean, default: false },
}, {
    timestamps: true,
});

userSchema.methods.matchPassword = async function (enteredPassword) {
    return await bcrypt.compare(enteredPassword, this.password);
};

userSchema.pre('save', async function (next) {
    if (!this.isModified('password')) {
        next();
    }
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
});

const User = mongoose.model('User', userSchema);
module.exports = User;
