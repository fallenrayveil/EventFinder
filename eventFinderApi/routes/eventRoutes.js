const express = require('express');
const router = express.Router();
const eventController = require('../controllers/eventController');

router.post('/events', eventController.upload.single('eventImage'), eventController.postEventHandler);

router.put('/events/:eventId', eventController.upload.single('eventImage'), eventController.updateEventHandler);

router.delete('/events/:eventId', eventController.deleteEventHandler);

router.get('/events', eventController.getAllEventsHandler);

router.get('/events/:eventId', eventController.getEventDetailHandler);

router.get('/events/user/:uid', eventController.getUserEventsHandler);

router.get('/events/:eventId/owner', eventController.getEventOwnerIdHandler);

router.get('/events/status/:status', eventController.fetchEventByStatusHandler);

router.get('/searchEvents/', eventController.searchEventsHandler);

module.exports = router;
