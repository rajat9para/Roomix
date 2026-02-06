const mongoose = require('mongoose');

const roomSchema = mongoose.Schema({
    title: { type: String, required: true },
    location: { type: String, required: true },
    price: { type: Number, required: true },
    type: { type: String, required: true }, // Single, Shared
    image: { type: String, required: true },
    contact: { type: String, required: true },
    latitude: { type: Number },
    longitude: { type: Number },
    amenities: { type: [String], default: [] },
    verified: { type: Boolean, default: false },
    rating: { type: Number, default: 0, min: 0, max: 5 },
    reviews: [{
        userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
        rating: { type: Number, required: true, min: 1, max: 5 },
        comment: { type: String },
        createdAt: { type: Date, default: Date.now }
    }],
    createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', default: null },
}, {
    timestamps: true,
});

const Room = mongoose.model('Room', roomSchema);
module.exports = Room;
