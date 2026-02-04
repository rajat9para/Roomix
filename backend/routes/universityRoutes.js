const express = require('express');
const {
  getAllUniversities,
  getUniversityById,
  searchUniversities,
  getNearbyUniversities,
  createUniversity,
  updateUniversity,
  deleteUniversity,
} = require('../controllers/universityController');

const router = express.Router();

// Public routes
router.get('/', getAllUniversities);
router.get('/search', searchUniversities);
router.get('/nearby', getNearbyUniversities);
router.get('/:id', getUniversityById);

// Admin routes (would need authentication middleware in production)
router.post('/', createUniversity);
router.put('/:id', updateUniversity);
router.delete('/:id', deleteUniversity);

module.exports = router;
