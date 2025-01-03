const express = require("express");
const router = express.Router();

const {
  insertSupplier,
  updateSupplier,
  softDeleteSupplier,
  getAllSupplier,
  getSupplierById,
  getSupplierByName,
  getSupplierByLocation,
  insertRawMaterial,
  updateRawMaterial,
  softDeleteRawMaterial,
  getAllRawMaterial,
  getRawMaterialByName,
  getRawMaterialById,
  getRawMaterialBySupplier,
  insertTransactionAndDetail,
  softDeleteTransaction,
  updateTransactionStatus,
  updateTransaction,
  getAllTransaction,
  getTransactionById,
  getPendingTransaction,
  getCompletedTransaction,
  getPendingTransactionByDate,
  getCompletedTransactionByDate,
  getPendingTransactionBySupplier,
  getCompletedTransactionBySupplier,
  updateTransactionDetail,
  softDeleteTransactionDetail,
} = require("../controllers/pengepulController"); // Ganti dengan nama file controller yang sesuai

// Supplier - Insert
router.post("/supplier", async (req, res) => {
  const { name, location, contactInfo } = req.body;
  await insertSupplier(name, location, contactInfo);
  res.status(201).json({ message: "Supplier inserted successfully" });
});

// Supplier - Update
router.put("/supplier", updateSupplier);

// Supplier - Delete
router.delete("/supplier", softDeleteSupplier);

// Supplier - Get All
router.get("/supplier", async (req, res) => {
  const suppliers = await getAllSupplier();
  res.status(200).json(suppliers);
});

// Supplier - Get by ID
router.get("/supplier/:supplierId", async (req, res) => {
  const supplierId = req.params.supplierId;
  const supplier = await getSupplierById(supplierId);
  res.status(200).json(supplier);
});

// Supplier - Get by Name
router.get("/supplier/byname/:supplierName", async (req, res) => {
  const supplierName = req.params.supplierName;
  const supplier = await getSupplierByName(supplierName);
  res.status(200).json(supplier);
});

// Supplier - Get by Location
router.get("/supplier/bylocation/:location", async (req, res) => {
  const location = req.params.location;
  const suppliers = await getSupplierByLocation(location);
  res.status(200).json(suppliers);
});

// Routes for Raw Materials
// Material - Insert
router.post("/material", async (req, res) => {
  const { materialName, stockQuantity, supplierId } = req.body;
  await insertRawMaterial(materialName, stockQuantity, supplierId);
  res.status(201).json({ message: "Raw material inserted successfully" });
});

// Material - Update
router.put("/material", updateRawMaterial);

// Material - Delete
router.delete("/material", softDeleteRawMaterial);

// Material - Get All
router.get("/material", async (req, res) => {
  const materials = await getAllRawMaterial();
  res.status(200).json(materials);
});

// Material - Get by ID
router.get("/material/:materialId", async (req, res) => {
  const materialId = req.params.materialId;
  const material = await getRawMaterialById(materialId);
  res.status(200).json(material);
});

// Material - Get by Name
router.get("/material/byname/:materialName", async (req, res) => {
  const materialName = req.params.materialName;
  const material = await getRawMaterialByName(materialName);
  res.status(200).json(material);
});

// Material - Get by Supplier ID
router.get("/material/bysupplier/:supplierId", async (req, res) => {
  const supplierId = req.params.supplierId;
  const materials = await getRawMaterialBySupplier(supplierId);
  res.status(200).json(materials);
});

// Routes for Transaction
// Transaction & Detail - Insert
router.post("/transactions", async (req, res) => {
  const transactionData = req.body;
  const response = await insertTransactionAndDetail(transactionData);
  res.status(201).json(response);
});

// Transaction & Detail - Delete
router.delete("/transaction", softDeleteTransaction);

// Transaction - Status ( Pending -> Completed)
router.put("/transaction/status", updateTransactionStatus);

// Transaction - Update
router.put("/transaction", updateTransaction);

// Transaction - Get All
router.get("/transaction", async (req, res) => {
  const transactions = await getAllTransaction();
  res.status(200).json(transactions);
});

// Transaction - Get All Pending
router.get("/transaction/pending", async (req, res) => {
  const pendingTransactions = await getPendingTransaction();
  res.status(200).json(pendingTransactions);
});

// Transaction - Get Pending by ID
router.get("/transaction/:id", async (req, res) => {
  const { id: transactionId } = req.params;
  try {
    const transaction = await getTransactionById(transactionId);
    res.status(200).json(transaction);
  } catch (error) {
    console.error("Error in /transaction/:id route:", error);
    res.status(500).json({
      error: "An error occurred while fetching the transaction by ID.",
    });
  }
});

// Transaction - Get All Completed
router.get("/transaction/completed", async (req, res) => {
  const pendingTransactions = await getCompletedTransaction();
  res.status(200).json(pendingTransactions);
});

// Transaction - Get Pending by Date
router.get(
  "/transaction/pending/bydate/:startDate/:endDate",
  async (req, res) => {
    const { startDate, endDate } = req.params;
    try {
      if (!startDate || !endDate) {
        return res
          .status(400)
          .json({ error: "Start date and end date are required." });
      }
      const transactions = await getPendingTransactionByDate(
        startDate,
        endDate
      );
      res.status(200).json(transactions);
    } catch (error) {
      console.error("Error in /transaction/pending/date route:", error);
      res.status(500).json({
        error: "An error occurred while fetching pending transactions by date.",
      });
    }
  }
);

// Transaction - Get Completed by Date
router.get(
  "/transaction/completed/bydate/:startDate/:endDate",
  async (req, res) => {
    const { startDate, endDate } = req.params;
    try {
      if (!startDate || !endDate) {
        return res
          .status(400)
          .json({ error: "Start date and end date are required." });
      }
      const transactions = await getCompletedTransactionByDate(
        startDate,
        endDate
      );
      res.status(200).json(transactions);
    } catch (error) {
      console.error("Error in /transaction/completed/date route:", error);
      res.status(500).json({
        error:
          "An error occurred while fetching completed transactions by date.",
      });
    }
  }
);

// Transaction - Get Pending by Supplier ID
router.get("/transaction/pending/bysupplier/:supplierId", async (req, res) => {
  const { supplierId } = req.params;
  try {
    const transactions = await getPendingTransactionBySupplier(supplierId);
    res.status(200).json(transactions);
  } catch (error) {
    console.error(
      "Error in /transaction/pending/supplier/:supplierId route:",
      error
    );
    res.status(500).json({
      error:
        "An error occurred while fetching pending transactions by supplier ID.",
    });
  }
});

// Transaction - Get Completed by Supplier ID
router.get(
  "/transaction/completed/bysupplier/:supplierId",
  async (req, res) => {
    const { supplierId } = req.params;
    try {
      const transactions = await getCompletedTransactionBySupplier(supplierId);
      res.status(200).json(transactions);
    } catch (error) {
      console.error(
        "Error in /transaction/completed/supplier/:supplierId route:",
        error
      );
      res.status(500).json({
        error:
          "An error occurred while fetching completed transactions by supplier ID.",
      });
    }
  }
);

// Routes for Transaction Details
// Detail - Update
router.put("/detail", updateTransactionDetail);

// Detail - Delete
router.put("/detail/delete", softDeleteTransactionDetail);

module.exports = router;
