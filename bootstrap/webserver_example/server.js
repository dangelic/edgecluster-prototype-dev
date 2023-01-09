const express = require('express');
const path = require('path');

const app = express();
const port = 3555;

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'assets', 'tux_v1.txt'));
});

app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});