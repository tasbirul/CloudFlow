const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());

// Simple routes
app.get('/', (req, res) => {
  res.send({ message: 'Welcome to the Node.js DevOps Demo API 🚀' });
});

app.get('/health', (req, res) => {
  res.status(200).send({ status: 'OK', uptime: process.uptime() });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

module.exports = app; // for testing