const express = require('express');
const { upload } = require('../config/cloudinary');
const router = express.Router();

router.post('/', upload.single('image'), (req, res) => {
    try {
        res.json({
            message: 'Image uploaded successfully',
            imageUrl: req.file.path,
        });
    } catch (error) {
        res.status(500).json({ message: 'Upload failed' });
    }
});

module.exports = router;
