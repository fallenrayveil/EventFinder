// controllers/authController.js
const { createUser, loginWithEmail,db } = require('../services/firebase');

const register = async (req, res, next) => {
  const { email, password } = req.body;
  console.log(req.body);

  try {
    const userRecord = await createUser({
      email,
      password,
    });

    const uid = userRecord.uid;

    await db.collection('userProfile').doc(uid).set({
      name: `anonym-${uid}`,
      phone: '',
      address: '',
      profileImage: 'profileImage/default.jpeg',
    });
    res.status(201).json(userRecord);
  } catch (error) {
    console.log(error.message);
    error.status = 400; // Bad Request
    next(error); // Pass the error to the error handler
  }
};

const login = async (req, res, next) => {
  const { email, password } = req.body;

  try {
   
    const userCredential = await loginWithEmail({ email, password });
    const UserSafeCredential = {
      uid: userCredential.user.uid,
      accessToken: userCredential.user.accessToken,
      refreshToken: userCredential.user.refreshToken,
      email: userCredential.user.email,
      emailVerified: userCredential.user.emailVerified,
      lastLoginAt: userCredential.user.metadata.lastLoginAt,
      createdAt: userCredential.user.metadata.createdAt
    };
    console.log(UserSafeCredential)
    res.status(200).json({ UserSafeCredential });
  } catch (error) {
    error.status = 401; // Unauthorized
    next(error); // Pass the error to the error handler
  }
};

module.exports = {
  register,
  login,
};
