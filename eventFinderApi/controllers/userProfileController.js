const { db } = require('../services/firebase');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Setup multer for file upload
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/profileImage');
  },
  filename: function (req, file, cb) {
    cb(null, file.fieldname + '-' + Date.now() + path.extname(file.originalname));
  }
});

const upload = multer({ storage: storage });

const getUserProfile = async (req, res) => {
  const { uid } = req.params;

  try {
    const userDoc = await db.collection('userProfile').doc(uid).get();

    if (!userDoc.exists) {
      return res.status(404).json({ message: 'User not found' });
    }

    const userProfile = userDoc.data();
    return res.status(200).json(userProfile);
  } catch (error) {
    console.error('Error getting user profile:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

const updateUserProfile = async (req, res) => {
  const { uid } = req.params;
  const { name, phone, address } = req.body;
  const profileImage = req.file ? req.file.path : null;

  try {
    const userDoc = db.collection('userProfile').doc(uid);
    const userDocSnapshot = await userDoc.get();
    
    if (!userDocSnapshot.exists) {
      return res.status(404).json({ message: 'User not found' });
    }

    const userProfile = userDocSnapshot.data();
    const oldProfileImage = userProfile.profileImage;

    // Update the fields that are provided
    const updateData = {
      name: name || userProfile.name,
      phone: phone || userProfile.phone,
      address: address || userProfile.address,
    };

    if (profileImage) {
      // Delete old profile image if it exists and is not the default image
      if (oldProfileImage && oldProfileImage !== 'profileImage/default.jpeg') {
        fs.unlink(path.join(__dirname, '..', `uploads/${oldProfileImage}`), (err) => {
          if (err) {
            console.error('Error deleting old profile image:', err);
          }
        });
      }
      console.log(profileImage);
      // Save the new profile image path
      updateData.profileImage = profileImage.slice(8);
    }

    await userDoc.update(updateData);

    return res.status(200).json({ message: 'Profile updated successfully' });
  } catch (error) {
    console.error('Error updating user profile:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

// Export the upload middleware to use in your route
module.exports = { updateUserProfile, upload };


module.exports = {
  getUserProfile,
  updateUserProfile,
  upload,
};
