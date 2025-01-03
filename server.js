const express = require("express");
const app = express();
const port = 3000;
const pengepulRoutes = require("./src/routes/pengepulRoutes");
const storeRoutes = require("./src/routes/storeRoutes");

// Gunakan routes yang telah dibuat
app.use("/api/pengepul", pengepulRoutes);
app.use("/api/store", storeRoutes);

// Mulai server
app.listen(port, () => {
  console.log(`Server berjalan di http://localhost:${port}`);
});
