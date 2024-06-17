const { db } = require('../services/firebase');

// Menambahkan peserta ke acara
const addParticipant = async (req, res) => {
  const { eventId } = req.params;
  const { name, phone,uid,email } = req.body;

  try {
    const participantRef = db.collection('participants').doc();
    await participantRef.set({
      eventId,
      uid,
      email,
      name,
      phone,
      status: 'pending'
    });

    return res.status(201).json({ message: 'Participant added successfully' });
  } catch (error) {
    console.error('Error adding participant:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

// Mendapatkan peserta berdasarkan user ID
const getParticipantsByUser = async (req, res) => {
    const { uid } = req.params;
  
    try {
      const participantsSnapshot = await db.collection('participants').where('uid', '==', uid).get();
  
      if (participantsSnapshot.empty) {
        return res.status(404).json({ message: 'No participants found' });
      }
  
      const participants = participantsSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      return res.status(200).json(participants);
    } catch (error) {
      console.error('Error getting participants by user:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }
  };

// Mendapatkan peserta suatu acara
const getParticipants = async (req, res) => {
  const { eventId } = req.params;
  console.log(eventId)
  console.log('bajingan')

  try {
    const participantsSnapshot = await db.collection('participants').where('eventId', '==', eventId).get();

    if (participantsSnapshot.empty) {
      return res.status(404).json({ message: 'No participants found' });
    }

    const participants = participantsSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    return res.status(200).json(participants);
  } catch (error) {
    console.error('Error getting participants:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};
// Mendapatkan peserta suatu acara
const getParticipantById = async (req, res) => {
    const { eventId, participantId } = req.params;
  
    try {
      const participantsSnapshot = await db.collection('participants')
        .where('eventId', '==', eventId)
        .where('uid', '==', participantId)
        .get();
  
      if (participantsSnapshot.empty) {
        return res.status(404).json({ message: 'No participants found' });
      }
  
      const participants = participantsSnapshot.docs.map(doc => doc.data());
      return res.status(200).json(participants);
    } catch (error) {
      console.error('Error getting participants:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }
  };
  

// Mengupdate status peserta
const updateParticipantStatus = async (req, res) => {
  const { participantId } = req.params;
  const { status } = req.body;

  try {
    const participantRef = db.collection('participants').doc(participantId);
    await participantRef.update({ status });

    return res.status(200).json({ message: 'Participant status updated successfully' });
  } catch (error) {
    console.error('Error updating participant status:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

const deleteParticipant = async (req, res) => {
    const { eventId, participantId } = req.params;
  
    try {
      const participantsSnapshot = await db.collection('participants')
        .where('eventId', '==', eventId)
        .where('uid', '==', participantId)
        .get();
  
      if (participantsSnapshot.empty) {
        return res.status(404).json({ message: 'No participants found' });
      }
  
      const batch = db.batch();
  
      participantsSnapshot.docs.forEach(doc => {
        batch.delete(doc.ref);
      });
  
      await batch.commit();
  
      return res.status(200).json({ message: 'Participant deleted successfully' });
    } catch (error) {
      console.error('Error deleting participant:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }
  };

  const fetchUserParticipatingEventsHandler = async (req, res) => {
    try {
      const { uid } = req.params;
  
      // Fetch participant records for the user
      const participantsSnapshot = await db.collection('participants').where('uid', '==', uid).get();
  
      if (participantsSnapshot.empty) {
        return res.status(404).json({ message: 'No participating events found' });
      }
  
      const events = [];
      const promises = [];
  
      participantsSnapshot.forEach(doc => {
        const participant = doc.data();
        const eventId = participant.eventId;
  
        // Fetch event details from 'events' collection based on eventId
        const eventPromise = db.collection('events').doc(eventId).get()
          .then(eventDoc => {
            if (eventDoc.exists) {
              const eventData = eventDoc.data();
              events.push({
                eventId: eventId,
                participantStatus:participant.status, 
                ...eventData,
              });
            } else {
              console.error(`Event with ID ${eventId} not found`);
            }
          })
          .catch(error => {
            console.error(`Error fetching event with ID ${eventId}:`, error);
          });
  
        promises.push(eventPromise);
      });
  
      // Wait for all event fetch promises to resolve
      await Promise.all(promises);
  
      res.status(200).json(events);
    } catch (error) {
      console.error('Error fetching user participating events:', error);
      res.status(500).json({ message: 'Internal server error' });
    }
  };
  

module.exports = {
  addParticipant,
  getParticipants,
  updateParticipantStatus,
  getParticipantById,
  getParticipantsByUser,
  deleteParticipant,
  fetchUserParticipatingEventsHandler
};
