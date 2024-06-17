// routes/reviewRoutes.js
const express = require('express');
const router = express.Router();
const reviewHandler = require('../controllers/reviewsController');

router.post('/events/:eventId/reviews', reviewHandler.createReview);
router.get('/events/:eventId/reviews', reviewHandler.getReviewsByEventId);
router.get('/events/:eventId/reviews/:id', reviewHandler.getReviewById);
router.put('/events/:eventId/reviews/:id', reviewHandler.updateReview);
router.delete('/events/:eventId/reviews/:id', reviewHandler.deleteReview);

module.exports = router;
