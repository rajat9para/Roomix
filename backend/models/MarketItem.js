const mongoose = require('mongoose');

const marketItemSchema = mongoose.Schema({
    title: { type: String, required: true },
    price: { type: Number, required: true },
    condition: { type: String, required: true }, // New, Used
    image: { type: String, required: true },
    sellerContact: { type: String, required: true },
    sellerName: { type: String, required: true },
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    sold: { type: Boolean, default: false },
    soldTo: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    soldDate: { type: Date },
}, {
    timestamps: true,
});

const MarketItem = mongoose.model('MarketItem', marketItemSchema);
module.exports = MarketItem;
