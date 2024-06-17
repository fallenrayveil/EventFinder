// middleware/validatePayload.js
const { check, validationResult } = require('express-validator');

const validatePayload = (validations) => {
  return async (req, res, next) => {
    await Promise.all(validations.map(validation => validation.run(req)));

    const errors = validationResult(req);
    if (errors.isEmpty()) {
      return next();
    }

    res.status(400).json({ errors: errors.array() });
  };
};

const registerValidation = [
  check('email').isEmail().withMessage('Please provide a valid email'),
  check('password')
    .isLength({ min: 6 })
    .withMessage('Password must be at least 6 characters long'),
];

const loginValidation = [
  check('email').isEmail().withMessage('Please provide a valid email'),
  check('password').exists().withMessage('Password is required'),
];

module.exports = {
  validatePayload,
  registerValidation,
  loginValidation,
};
