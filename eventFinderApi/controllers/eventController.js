const { db } = require('../services/firebase');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { deleteImageFile } = require('../helper/helper');

// Setup multer for file upload
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/eventPosters');
  },
  filename: function (req, file, cb) {
    cb(null, file.fieldname + '-' + Date.now() + path.extname(file.originalname));
  }
});

const upload = multer({ storage: storage });

const postEventHandler = async (req, res) => {
  try {
    const { title, description, date, capacity, mapsUrl, organizerType, category, uid, location } = req.body;

    let imageUrl = '';
    if (req.file) {
      imageUrl = `/eventPosters/${req.file.filename}`;
    }

    const event = {
      title,
      description,
      date,
      capacity,
      mapsUrl,
      organizerType,
      imageUrl,
      rating: 0,
      status: "Upcoming",
      category,
      location,
      uid,
    };

    // Save the event to Firestore
    const eventRef = db.collection('events').doc();
    await eventRef.set(event);

    res.status(200).send('Event created successfully');
  } catch (error) {
    console.error(error);
    res.status(500).send('Server error');
  }
};

const updateEventHandler = async (req, res) => {
  try {
    const { eventId } = req.params;
    const { title, description, date, capacity, mapsUrl, organizerType, status, category,location, uid } = req.body;

    const eventRef = db.collection('events').doc(eventId);
    const eventDoc = await eventRef.get();

    if (!eventDoc.exists) {
      return res.status(404).send('Event not found');
    }

    const event = eventDoc.data();

    let imageUrl = event.imageUrl;

    if (req.file) {
      if (event.imageUrl) {
        fs.unlink(path.join(__dirname, '..', imageUrl), (err) => {
          if (err) {
            console.error('Error deleting old profile image:', err);
          }
        });
      }
      imageUrl = `/eventPosters/${req.file.filename}`;
    }

    const updatedEvent = {
      title,
      description,
      date,
      capacity,
      mapsUrl,
      location,
      organizerType,
      category,
      status,
      imageUrl,
      uid,
    };

    await eventRef.update(updatedEvent);

    res.status(200).send('Event updated successfully');
  } catch (error) {
    console.error(error);
    res.status(500).send('Server error');
  }
};

const deleteEventHandler = async (req, res) => {
  try {
    const { eventId } = req.params;

    const eventRef = db.collection('events').doc(eventId);
    const eventDoc = await eventRef.get();

    if (!eventDoc.exists) {
      return res.status(404).send('Event not found');
    }

    const event = eventDoc.data();

    if (event.imageUrl) {
      deleteImageFile(path.join(__dirname, '..', event.imageUrl));
    }

    await eventRef.delete();

    res.status(200).send('Event deleted successfully');
  } catch (error) {
    console.error(error);
    res.status(500).send('Server error');
  }
};

const getAllEventsHandler = async (req, res) => {
  try {
    const eventsSnapshot = await db.collection('events').get();
    const events = eventsSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));

    res.status(200).json(events);
  } catch (error) {
    console.error(error);
    res.status(500).send('Server error');
  }
};

const getEventDetailHandler = async (req, res) => {
  try {
    const { eventId } = req.params;

    const eventRef = db.collection('events').doc(eventId);
    const eventDoc = await eventRef.get();

    if (!eventDoc.exists) {
      return res.status(404).send('Event not found');
    }

    res.status(200).json(eventDoc.data());
  } catch (error) {
    console.error(error);
    res.status(500).send('Server error');
  }
};

const getUserEventsHandler = async (req, res) => {
  try {
    const { uid } = req.params;

    const eventsSnapshot = await db.collection('events').where('uid', '==', uid).get();
    const events = eventsSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));

    res.status(200).json(events);
  } catch (error) {
    console.error(error);
    res.status(500).send('Server error');
  }
};

const getEventOwnerIdHandler = async (req, res) => {
  try {
    const { eventId } = req.params;

    const eventRef = db.collection('events').doc(eventId);
    const eventDoc = await eventRef.get();

    if (!eventDoc.exists) {
      return res.status(404).send('Event not found');
    }

    const event = eventDoc.data();
    res.status(200).json({ uid: event.uid });
  } catch (error) {
    console.error(error);
    res.status(500).send('Server error');
  }
};

// Fetch events by status
const fetchEventByStatusHandler = async (req, res) => {
  try {
    const { status } = req.params;

    const eventsSnapshot = await db.collection('events').where('status', '==', status).get();

    if (eventsSnapshot.empty) {
      return res.status(404).json({ message: 'No events found' });
    }

    const events = eventsSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    res.status(200).json(events);
  } catch (error) {
    console.error('Error fetching events by status:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

const searchEventsHandler = async (req, res) => {
  try {
    const { search } = req.query;

    if (!search) {
      return res.status(400).json({ message: 'Search query is required' });
    }

    const normalizedSearch = search.toLowerCase();

    // Fetch all events (this might be inefficient for large datasets)
    const eventsSnapshot = await db.collection('events').get();

    if (eventsSnapshot.empty) {
      return res.status(404).json({ message: 'No events found' });
    }

    const events = eventsSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));

    // Filter events based on the search query
    const filteredEvents = events.filter(event => {
      const title = event.title.toLowerCase();
      const category = event.category.toLowerCase();
      const location = event.location.toLowerCase();

      return (
        title.includes(normalizedSearch) ||
        category.includes(normalizedSearch) ||
        location.includes(normalizedSearch)
      );
    });

    if (filteredEvents.length === 0) {
      return res.status(404).json({ message: 'No events found' });
    }

    res.status(200).json(filteredEvents);
  } catch (error) {
    console.error('Error searching events:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};


module.exports = {
  postEventHandler,
  updateEventHandler,
  deleteEventHandler,
  getAllEventsHandler,
  getEventDetailHandler,
  getUserEventsHandler,
  getEventOwnerIdHandler,
  fetchEventByStatusHandler,
  searchEventsHandler,
  upload
};
