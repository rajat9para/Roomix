const cloudinary = require('cloudinary').v2;
const multer = require('multer');
const CloudinaryStorage = require('multer-storage-cloudinary');
const dotenv = require('dotenv');

dotenv.config();

// Configure Cloudinary
cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET,
});

// CloudinaryStorage for multer-storage-cloudinary v2.x (no destructuring)
const storage = CloudinaryStorage({
    cloudinary: cloudinary,
    folder: 'pg_finer_app',
    allowedFormats: ['jpg', 'png', 'jpeg'],
    transformation: [{ width: 500, height: 500, crop: 'limit' }],
});

const upload = multer({ storage });

module.exports = { cloudinary, upload };
