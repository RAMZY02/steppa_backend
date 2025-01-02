const express = require('express');
const app = express();
const port = 3000;
const routes = require('./routes');

// Gunakan routes yang telah dibuat
app.use('/api', routes);

// Mulai server
app.listen(port, () => {
    console.log(`Server berjalan di http://localhost:${port}`);
});

