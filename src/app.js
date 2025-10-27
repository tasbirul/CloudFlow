const express = require('express');
const app = express();

app.use(express.json());

app.get('/', (req, res) => {
  res.send({ message: 'Welcome to the Node.js DevOps Demo API 🚀' });
});

app.get('/health', (req, res) => {
  res.status(200).send({ status: 'OK', uptime: process.uptime() });
});

module.exports = app;
