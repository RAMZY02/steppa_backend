const express = require("express");
const cors = require("cors"); // Import CORS middleware
const app = express();
const port = 3000;

const pengepulRoutes = require("./src/routes/pengepulRoutes");
const storeRoutes = require("./src/routes/storeRoutes");
const rndRoutes = require("./src/routes/rndRoutes");

app.use(
  cors({
    origin: "*", // Izinkan semua domain
  })
);

app.use(express.urlencoded({ extended: true }));
app.use(express.json());

// Gunakan routes yang telah dibuat
app.use("/api/pengepul", pengepulRoutes);
app.use("/api/store", storeRoutes);
app.use("/api/rnd", rndRoutes);

// Mulai server
app.listen(port, () => {
  console.log(`Server berjalan di http://192.168.195.5:${port}`);
});
