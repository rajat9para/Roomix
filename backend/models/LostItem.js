const mongoose = require('mongoose');

const lostItemSchema = mongoose.Schema({
    title: { type: String, required: true },
    description: { type: String, required: true },
    status: { type: String, enum: ['Lost', 'Found'], required: true },
    date: { type: Date, default: Date.now },
    image: { type: String, required: true },
    contact: { type: String, required: true },
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    claimStatus: { type: String, enum: ['Unclaimed', 'Claimed', 'Resolved'], default: 'Unclaimed' },
    claimedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    claimDate: { type: Date },
}, {
    timestamps: true,
});

const LostItem = mongoose.model('LostItem', lostItemSchema);
module.exports = LostItem;
