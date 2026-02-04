const mongoose = require('mongoose');

const universitySchema = mongoose.Schema({
  name: {
    type: String,
    required: true,
    unique: true,
  },
  location: {
    type: {
      type: String,
      enum: ['Point'],
      default: 'Point',
    },
    coordinates: {
      type: [Number],
      required: true,
      validate: {
        validator: function(v) {
          return v.length === 2 && v[0] >= -180 && v[0] <= 180 && v[1] >= -90 && v[1] <= 90;
        },
        message: 'Coordinates must be [longitude, latitude]',
      },
    },
  },
  campusBounds: {
    northEast: {
      latitude: { type: Number, required: true },
      longitude: { type: Number, required: true },
    },
    southWest: {
      latitude: { type: Number, required: true },
      longitude: { type: Number, required: true },
    },
  },
  address: {
    type: String,
    required: true,
  },
  description: {
    type: String,
    default: '',
  },
  city: {
    type: String,
    required: true,
  },
  state: {
    type: String,
    required: true,
  },
  zipCode: {
    type: String,
  },
  imageUrl: {
    type: String,
  },
  isActive: {
    type: Boolean,
    default: true,
  },
}, {
  timestamps: true,
});

// Create 2dsphere index for geospatial queries
universitySchema.index({ 'location': '2dsphere' });

const University = mongoose.model('University', universitySchema);
module.exports = University;
