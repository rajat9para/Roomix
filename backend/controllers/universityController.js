const University = require('../models/University');

// Get all universities
exports.getAllUniversities = async (req, res) => {
  try {
    const universities = await University.find({ isActive: true }).sort({ name: 1 });
    res.status(200).json({
      success: true,
      count: universities.length,
      data: universities,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch universities',
      error: error.message,
    });
  }
};

// Get university by ID
exports.getUniversityById = async (req, res) => {
  try {
    const { id } = req.params;
    const university = await University.findById(id);
    
    if (!university) {
      return res.status(404).json({
        success: false,
        message: 'University not found',
      });
    }
    
    res.status(200).json({
      success: true,
      data: university,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch university',
      error: error.message,
    });
  }
};

// Search universities by name or location
exports.searchUniversities = async (req, res) => {
  try {
    const { query } = req.query;
    
    if (!query) {
      return res.status(400).json({
        success: false,
        message: 'Search query is required',
      });
    }
    
    const universities = await University.find({
      $or: [
        { name: { $regex: query, $options: 'i' } },
        { city: { $regex: query, $options: 'i' } },
        { state: { $regex: query, $options: 'i' } },
      ],
      isActive: true,
    }).sort({ name: 1 });
    
    res.status(200).json({
      success: true,
      count: universities.length,
      data: universities,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Search failed',
      error: error.message,
    });
  }
};

// Get nearby universities based on coordinates
exports.getNearbyUniversities = async (req, res) => {
  try {
    const { latitude, longitude, radiusKm = 50 } = req.query;
    
    if (!latitude || !longitude) {
      return res.status(400).json({
        success: false,
        message: 'Latitude and longitude are required',
      });
    }
    
    const lat = parseFloat(latitude);
    const lng = parseFloat(longitude);
    const radiusMeters = radiusKm * 1000;
    
    const universities = await University.find({
      'location': {
        $near: {
          $geometry: {
            type: 'Point',
            coordinates: [lng, lat],
          },
          $maxDistance: radiusMeters,
        },
      },
      isActive: true,
    });
    
    res.status(200).json({
      success: true,
      count: universities.length,
      data: universities,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch nearby universities',
      error: error.message,
    });
  }
};

// Create university (Admin only)
exports.createUniversity = async (req, res) => {
  try {
    const { name, latitude, longitude, campusBounds, address, description, city, state, zipCode, imageUrl } = req.body;
    
    // Validate required fields
    if (!name || latitude === undefined || longitude === undefined || !campusBounds || !address || !city || !state) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields (name, latitude, longitude, campusBounds, address, city, state)',
      });
    }
    
    // Check if university already exists
    const existingUniversity = await University.findOne({ name });
    if (existingUniversity) {
      return res.status(400).json({
        success: false,
        message: 'University with this name already exists',
      });
    }
    
    // Convert latitude/longitude to GeoJSON Point coordinates [lng, lat]
    const coordinates = [parseFloat(longitude), parseFloat(latitude)];
    
    const university = new University({
      name,
      location: {
        type: 'Point',
        coordinates,
      },
      campusBounds,
      address,
      description,
      city,
      state,
      zipCode,
      imageUrl,
    });
    
    await university.save();
    
    res.status(201).json({
      success: true,
      message: 'University created successfully',
      data: university,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to create university',
      error: error.message,
    });
  }
};

// Update university (Admin only)
exports.updateUniversity = async (req, res) => {
  try {
    const { id } = req.params;
    const updates = { ...req.body };
    
    // If latitude and longitude are provided, convert to GeoJSON coordinates
    if (updates.latitude !== undefined && updates.longitude !== undefined) {
      updates.location = {
        type: 'Point',
        coordinates: [parseFloat(updates.longitude), parseFloat(updates.latitude)],
      };
      delete updates.latitude;
      delete updates.longitude;
    }
    
    const university = await University.findByIdAndUpdate(id, updates, { new: true, runValidators: true });
    
    if (!university) {
      return res.status(404).json({
        success: false,
        message: 'University not found',
      });
    }
    
    res.status(200).json({
      success: true,
      message: 'University updated successfully',
      data: university,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to update university',
      error: error.message,
    });
  }
};

// Delete university (Admin only)
exports.deleteUniversity = async (req, res) => {
  try {
    const { id } = req.params;
    
    const university = await University.findByIdAndUpdate(id, { isActive: false }, { new: true });
    
    if (!university) {
      return res.status(404).json({
        success: false,
        message: 'University not found',
      });
    }
    
    res.status(200).json({
      success: true,
      message: 'University deleted successfully',
      data: university,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to delete university',
      error: error.message,
    });
  }
};
