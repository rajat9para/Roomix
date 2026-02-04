const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const connectDB = require('./config/db');

dotenv.config();

connectDB();

const app = express();

app.use(cors());
app.use(express.json());

// Routes
app.get('/', (req, res) => {
    res.send('API is running...');
});

app.use('/api/auth', require('./routes/authRoutes'));
app.use('/api/rooms', require('./routes/roomRoutes'));
app.use('/api/mess', require('./routes/messRoutes'));
app.use('/api/lost', require('./routes/lostRoutes'));
app.use('/api/events', require('./routes/eventRoutes'));
app.use('/api/market', require('./routes/marketRoutes'));
app.use('/api/upload', require('./routes/uploadRoutes'));
app.use('/api/universities', require('./routes/universityRoutes'));
app.use('/api/roommates', require('./routes/roommateRoutes'));
app.use('/api/chat', require('./routes/chatRoutes'));
app.use('/api/utilities', require('./routes/utilityRoutes'));
// Profile routes
app.use('/api/profile', require('./routes/profileRoutes'));

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
