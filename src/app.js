const express = require('express');
const path = require('path');

const app = express();

// Serve static files from "public"
app.use(express.static(path.join(__dirname, 'public')));

// API endpoint
app.get('/api/hello', (req, res) => {
  res.json({ message: 'Hello from Node.js backend!' });
});

module.exports = app;
