const mongoose = require('mongoose');

const utilitySchema = mongoose.Schema({
    name: { type: String, required: true },
    category: { 
        type: String, 
        required: true,
        enum: ['medical', 'grocery', 'xerox', 'stationary', 'pharmacy', 'cafe', 'laundry', 'salon', 'bank', 'atm', 'restaurant', 'other'],
        default: 'other'
    },
    location: {
        type: {
            type: String,
            enum: ['Point'],
            default: 'Point'
        },
        coordinates: {
            type: [Number], // [longitude, latitude]
            required: true
        },
        address: { type: String }
    },
    contact: { 
        phone: { type: String },
        email: { type: String },
        website: { type: String }
    },
    description: { type: String },
    image: { type: String },
    verified: { 
        type: Boolean, 
        default: false 
    },
    addedBy: { 
        type: mongoose.Schema.Types.ObjectId, 
        ref: 'User',
        required: true
    },
    rating: { 
        type: Number, 
        default: 0,
        min: 0,
        max: 5
    },
    reviews: [{
        userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
        rating: { type: Number, min: 1, max: 5 },
        comment: String,
        createdAt: { type: Date, default: Date.now }
    }],
    operatingHours: {
        monday: { open: String, close: String },
        tuesday: { open: String, close: String },
        wednesday: { open: String, close: String },
        thursday: { open: String, close: String },
        friday: { open: String, close: String },
        saturday: { open: String, close: String },
        sunday: { open: String, close: String }
    },
    tags: [String],
    isActive: { type: Boolean, default: true },
    rejectionReason: { type: String },
}, {
    timestamps: true,
});

// Create geospatial index for location-based queries using GeoJSON
utilitySchema.index({ 'location': '2dsphere' });

const Utility = mongoose.model('Utility', utilitySchema);
module.exports = Utility;
