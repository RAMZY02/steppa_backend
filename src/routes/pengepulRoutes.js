const express = require("express");
const router = express.Router();
const {
  insertSupplier,
  updateSupplier,
  softDeleteSupplier,
  getAllSuppliers,
  getSupplierById,
  getSupplierByName,
  getSupplierByLocation,
  insertRawMaterial,
  updateRawMaterial,
  softDeleteRawMaterial,
  getAllRawMaterials,
  getRawMaterialByName,
  getRawMaterialById,
  getRawMaterialBySupplier,
  insertTransactionAndDetails,
  softDeleteTransaction,
  updateTransactionStatus,
  updateTransaction,
  getAllTransactions,
  getPendingTransactions,
  updateTransactionDetail,
  softDeleteTransactionDetail,
  getTransactionDetails,
} = require("../controllers/pengepulController"); // Ganti dengan nama file controller yang sesuai

// Routes for Supplier
router.post("/suppliers", async (req, res) => {
  const { name, location, contactInfo } = req.body;
  await insertSupplier(name, location, contactInfo);
  res.status(201).json({ message: "Supplier inserted successfully" });
});

router.put("/suppliers", updateSupplier);
router.delete("/suppliers", softDeleteSupplier);
router.get("/suppliers", async (req, res) => {
  const suppliers = await getAllSuppliers();
  res.status(200).json(suppliers);
});

router.get("/suppliers/:supplierId", async (req, res) => {
  const supplierId = req.params.supplierId;
  const supplier = await getSupplierById(supplierId);
  res.status(200).json(supplier);
});

router.get("/suppliers/byname/:supplierName", async (req, res) => {
  const supplierName = req.params.supplierName;
  const supplier = await getSupplierByName(supplierName);
  res.status(200).json(supplier);
});

router.get("/suppliers/bylocation/:location", async (req, res) => {
  const location = req.params.location;
  const suppliers = await getSupplierByLocation(location);
  res.status(200).json(suppliers);
});

// Routes for Raw Materials
router.post("/raw-materials", async (req, res) => {
  const { materialName, stockQuantity, supplierId } = req.body;
  await insertRawMaterial(materialName, stockQuantity, supplierId);
  res.status(201).json({ message: "Raw material inserted successfully" });
});

router.put("/raw-materials", updateRawMaterial);
router.delete("/raw-materials", softDeleteRawMaterial);
router.get("/raw-materials", async (req, res) => {
  const materials = await getAllRawMaterials();
  res.status(200).json(materials);
});

router.get("/raw-materials/:materialId", async (req, res) => {
  const materialId = req.params.materialId;
  const material = await getRawMaterialById(materialId);
  res.status(200).json(material);
});

router.get("/raw-materials/byname/:materialName", async (req, res) => {
  const materialName = req.params.materialName;
  const material = await getRawMaterialByName(materialName);
  res.status(200).json(material);
});

router.get("/raw-materials/bysupplier/:supplierId", async (req, res) => {
  const supplierId = req.params.supplierId;
  const materials = await getRawMaterialBySupplier(supplierId);
  res.status(200).json(materials);
});

// Routes for Transaction
router.post("/transactions", async (req, res) => {
  const transactionData = req.body;
  const response = await insertTransactionAndDetails(transactionData);
  res.status(201).json(response);
});

router.delete("/transactions", softDeleteTransaction);
router.put("/transactions/status", updateTransactionStatus);
router.put("/transactions", updateTransaction);
router.get("/transactions", async (req, res) => {
  const transactions = await getAllTransactions();
  res.status(200).json(transactions);
});

router.get("/transactions/pending", async (req, res) => {
  const pendingTransactions = await getPendingTransactions();
  res.status(200).json(pendingTransactions);
});

// Routes for Transaction Details
router.put("/transaction-details", updateTransactionDetail);
router.delete("/transaction-details", softDeleteTransactionDetail);

router.get("/transaction-details/:transactionId", async (req, res) => {
  const transactionId = req.params.transactionId;
  const details = await getTransactionDetails(transactionId);
  res.status(200).json(details);
});

module.exports = router;
