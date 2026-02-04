const mongoose = require('mongoose');

const roommateProfileSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      unique: true,
    },
    bio: {
      type: String,
      required: true,
      maxlength: 500,
    },
    interests: {
      type: [String],
      default: [],
    },
    preferences: {
      budget: {
        min: {
          type: Number,
          default: 5000,
        },
        max: {
          type: Number,
          default: 50000,
        },
      },
      location: {
        type: [String],
        default: [],
      },
      lifestyle: {
        type: [String],
        enum: ['early_riser', 'night_owl', 'quiet', 'social', 'clean', 'relaxed'],
        default: [],
      },
    },
    profileComplete: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('RoommateProfile', roommateProfileSchema);
