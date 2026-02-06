const mongoose = require('mongoose');

const messSchema = mongoose.Schema({
    name: { type: String, required: true },
    monthlyPrice: { type: Number, required: true },
    timings: { type: String, required: true },
    menuPreview: { type: String, required: true },
    image: { type: String, required: true },
    latitude: { type: Number },
    longitude: { type: Number },
    createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', default: null },
}, {
    timestamps: true,
});

const Mess = mongoose.model('Mess', messSchema);
module.exports = Mess;
