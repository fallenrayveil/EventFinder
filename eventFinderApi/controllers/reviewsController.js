// controllers/reviewsController.js
const {db} = require('../services/firebase');
const { v4: uuidv4 } = require('uuid'); // Untuk membuat ID unik

const createReview = async (req, res) => {
  const { eventId } = req.params;
  console.log('memek');
  console.log(eventId)
  const review = {
    id: uuidv4(),
    userId: req.body.userId,
    eventId: eventId,
    userName: req.body.userName,
    comment: req.body.comment,
    rating: req.body.rating,
    date: new Date(),
  };

  try {
    await db.collection('reviews').doc(review.id).set(review);
    res.status(201).send(review);
  } catch (error) {
    console.log(error)
    res.status(500).send({ message: 'Failed to create review', error });
  }
};

const getReviewsByEventId = async (req, res) => {
  const { eventId } = req.params;
  try {
    const snapshot = await db.collection('reviews').where('eventId', '==', eventId).get();
    const reviews = snapshot.docs.map((doc) => doc.data());
    res.status(200).send(reviews);
  } catch (error) {
    res.status(500).send({ message: 'Failed to fetch reviews', error });
  }
};

const getReviewById = async (req, res) => {
  const { eventId, id } = req.params;
  try {
    const doc = await db.collection('reviews').doc(id).get();
    if (!doc.exists) {
      res.status(404).send({ message: 'Review not found' });
    } else {
      res.status(200).send(doc.data());
    }
  } catch (error) {
    res.status(500).send({ message: 'Failed to fetch review', error });
  }
};

const updateReview = async (req, res) => {
  const { id } = req.params;
  const updatedReview = req.body;

  try {
    await db.collection('reviews').doc(id).update(updatedReview);
    res.status(200).send({ message: 'Review updated successfully' });
  } catch (error) {
    res.status(500).send({ message: 'Failed to update review', error });
  }
};

const deleteReview = async (req, res) => {
  const { id } = req.params;

  try {
    await db.collection('reviews').doc(id).delete();
    res.status(200).send({ message: 'Review deleted successfully' });
  } catch (error) {
    res.status(500).send({ message: 'Failed to delete review', error });
  }
};

module.exports = {
  createReview,
  getReviewsByEventId,
  getReviewById,
  updateReview,
  deleteReview,
};
