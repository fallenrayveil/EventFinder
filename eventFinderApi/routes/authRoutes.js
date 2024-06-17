// routes/authRoutes.js
const express = require('express');
const { register, login } = require('../controllers/authController');
const { validatePayload, registerValidation, loginValidation } = require('../middlewares/validatePayload');

const router = express.Router();

router.post('/register', validatePayload(registerValidation), register);
router.post('/login', validatePayload(loginValidation), login);

module.exports = router;
