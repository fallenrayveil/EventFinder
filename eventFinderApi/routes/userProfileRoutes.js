const express = require('express');
const router = express.Router();
const profileController = require('../controllers/userProfileController');

// Get user profile
router.get('/userProfile/:uid', profileController.getUserProfile);

// Update user profile
router.put('/userProfile/:uid', profileController.upload.single('profileImage'), profileController.updateUserProfile);

module.exports = router;
