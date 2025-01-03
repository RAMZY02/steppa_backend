const express = require("express");
const router = express.Router();
const { getDesignData, getProductData } = require("./controller");

// Route untuk mendapatkan data desain
router.get("/design", getDesignData);

// Route untuk mendapatkan data produk
router.get("/products", getProductData);

module.exports = router;
