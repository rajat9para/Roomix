const RoommateProfile = require('../models/RoommateProfile');
const User = require('../models/User');

// Create or update roommate profile
exports.createProfile = async (req, res) => {
  try {
    const { bio, interests, preferences } = req.body;
    const userId = req.user.id;

    let profile = await RoommateProfile.findOne({ user: userId });

    if (profile) {
      profile.bio = bio || profile.bio;
      profile.interests = interests || profile.interests;
      profile.preferences = preferences || profile.preferences;
      profile.profileComplete = true;
    } else {
      profile = new RoommateProfile({
        user: userId,
        bio,
        interests,
        preferences,
        profileComplete: true,
      });
    }

    await profile.save();
    res.status(200).json({
      success: true,
      message: 'Profile created/updated successfully',
      profile: await profile.populate('user', 'name email'),
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error creating profile',
      error: error.message,
    });
  }
};

// Get all profiles
exports.getAllProfiles = async (req, res) => {
  try {
    const profiles = await RoommateProfile.find({ profileComplete: true })
      .populate('user', 'name email')
      .select('-__v');

    res.status(200).json({
      success: true,
      count: profiles.length,
      profiles,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching profiles',
      error: error.message,
    });
  }
};

// Get current user's profile
exports.getMyProfile = async (req, res) => {
  try {
    const userId = req.user.id;
    const profile = await RoommateProfile.findOne({ user: userId })
      .populate('user', 'name email');

    if (!profile) {
      return res.status(404).json({
        success: false,
        message: 'Profile not found',
      });
    }

    res.status(200).json({
      success: true,
      profile,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching profile',
      error: error.message,
    });
  }
};

// Get profile by user ID
exports.getProfileById = async (req, res) => {
  try {
    const { userId } = req.params;
    const profile = await RoommateProfile.findOne({ user: userId })
      .populate('user', 'name email');

    if (!profile) {
      return res.status(404).json({
        success: false,
        message: 'Profile not found',
      });
    }

    res.status(200).json({
      success: true,
      profile,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching profile',
      error: error.message,
    });
  }
};

// Calculate compatibility score between two profiles
const calculateCompatibility = (profile1, profile2) => {
  let score = 0;
  const maxScore = 100;

  // Budget compatibility
  const budgetDiff = Math.abs(
    (profile1.preferences.budget.max + profile1.preferences.budget.min) / 2 -
    (profile2.preferences.budget.max + profile2.preferences.budget.min) / 2
  );
  const budgetScore = Math.max(0, 30 - (budgetDiff / 1000));
  score += budgetScore;

  // Lifestyle compatibility
  const lifestyleMatches = profile1.preferences.lifestyle.filter((item) =>
    profile2.preferences.lifestyle.includes(item)
  ).length;
  const lifestyleScore = (lifestyleMatches / Math.max(1, profile1.preferences.lifestyle.length)) * 30;
  score += lifestyleScore;

  // Interests compatibility
  const interestMatches = profile1.interests.filter((item) =>
    profile2.interests.includes(item)
  ).length;
  const interestScore = (interestMatches / Math.max(1, profile1.interests.length)) * 25;
  score += interestScore;

  // Location compatibility
  const locationMatches = profile1.preferences.location.filter((item) =>
    profile2.preferences.location.includes(item)
  ).length;
  const locationScore = (locationMatches / Math.max(1, profile1.preferences.location.length)) * 15;
  score += locationScore;

  return Math.min(maxScore, Math.round(score));
};

// Get compatible matches
exports.getMatches = async (req, res) => {
  try {
    const userId = req.user.id;
    const myProfile = await RoommateProfile.findOne({ user: userId });

    if (!myProfile) {
      return res.status(404).json({
        success: false,
        message: 'Your profile not found',
      });
    }

    const allProfiles = await RoommateProfile.find({
      profileComplete: true,
      user: { $ne: userId },
    }).populate('user', 'name email');

    const matches = allProfiles
      .map((profile) => ({
        profile,
        compatibility: calculateCompatibility(myProfile, profile),
      }))
      .sort((a, b) => b.compatibility - a.compatibility)
      .map(({ profile, compatibility }) => ({
        ...profile.toObject(),
        compatibility,
      }));

    res.status(200).json({
      success: true,
      count: matches.length,
      matches,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching matches',
      error: error.message,
    });
  }
};

// Delete profile
exports.deleteProfile = async (req, res) => {
  try {
    const userId = req.user.id;
    await RoommateProfile.findOneAndDelete({ user: userId });

    res.status(200).json({
      success: true,
      message: 'Profile deleted successfully',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error deleting profile',
      error: error.message,
    });
  }
};
