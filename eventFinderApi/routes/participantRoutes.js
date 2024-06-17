const express = require('express');
const router = express.Router();
const { addParticipant, getParticipants, updateParticipantStatus,getParticipantById,deleteParticipant,getParticipantsByUser,fetchUserParticipatingEventsHandler } = require('../controllers/participantController');

// Menambahkan peserta ke acara
router.post('/:eventId/participants', addParticipant);

// Mendapatkan peserta suatu acara
router.get('/:eventId/participants', getParticipants);
// Mendapatkan peserta suatu acara
router.get('/:eventId/participants/:participantId', getParticipantById);
router.get('/participants/user/:uid', getParticipantsByUser);
router.get('/participant/on/:uid', fetchUserParticipatingEventsHandler);

router.delete('/:eventId/participants/:participantId', deleteParticipant);

// Mengupdate status peserta
router.put('/participants/:participantId/status', updateParticipantStatus);

module.exports = router;
