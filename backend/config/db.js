const mongoose = require('mongoose');

// Import models to ensure they are registered
require('../models/University');

const connectDB = async () => {
    try {
        const conn = await mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/roomix');
        console.log(`MongoDB Connected: ${conn.connection.host}`);
        
        // Create geospatial index for university location queries
        const University = mongoose.model('University');
        await University.collection.createIndex({ 'location.latitude': 1, 'location.longitude': 1 });
        console.log('Geospatial index created for universities');
    } catch (error) {
        console.error(`MongoDB Connection Error: ${error.message}`);
        console.log('Continuing without database connection...');
    }
};

module.exports = connectDB;
