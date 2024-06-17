// server.js
const express = require('express');
const bodyParser = require('body-parser');
const path = require('path');

const authRoutes = require('./routes/authRoutes');
const userProfileRoutes = require('./routes/userProfileRoutes')
const eventRoutes = require('./routes/eventRoutes')
const participantRoutes = require('./routes/participantRoutes')
const reviewRoutes = require('./routes/reviewRoutes.js')
const errorHandler = require('./middlewares/errorHandler');

const app = express();
app.use(bodyParser.json());

// Define the path to the profile images folder
const profileImagesPath = path.join(__dirname, 'uploads', 'profileImage');
const eventPostersImagePath = path.join(__dirname, 'uploads', 'eventPosters');

// Serve static files from the profile images folder
app.use('/profileImage', express.static(profileImagesPath));
app.use('/eventPosters', express.static(eventPostersImagePath));

app.use('/', authRoutes);
app.use('/', userProfileRoutes);
app.use('/', eventRoutes);
app.use('/events', participantRoutes);
app.use('/', reviewRoutes);

// Global error handler middleware
app.use(errorHandler);

const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running on port ${PORT}`);
});
