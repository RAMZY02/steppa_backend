const express = require("express");
const router = express.Router();

const {
  insertDesign,
  updateDesign,
  softDeleteDesign,
  getAllDesigns,
  getAllDesign,
  getDesignById,
  getDesignByName,
  insertDesignMaterial,
  updateDesignMaterial,
  softDeleteDesignMaterial,
  softDeleteDesignMaterialByDesignId,
  getAllDesignMaterials,
  getDesignMaterialById,
  getDesignMaterialByDesignId,
  getDesignMaterialByMaterialId,
  insertProduction,
  updateProduction,
  softDeleteProduction,
  getAllProductions,
  getProductionById,
  getProductionByDesignId,
  updateProductionStatus,
  insertProduct,
  updateProduct,
  softDeleteProduct,
  getAllProducts,
  getProductById,
  getProductByName,
  insertRawMaterial,
  updateRawMaterial,
  softDeleteRawMaterial,
  getAllRawMaterials,
  getFilteredRawMaterials,
  getRawMaterialById,
  getRawMaterialByName,
  getAllLogs,
  getLogById,
  getLogsByActionType,
  getLogsByTableName,
  getLogsByActionTime,
  getLogsByActionUser,
  updateUser,
  softDeleteUser,
  login,
  register,
  getAllUsers,
  getUserById,
  getUserByUsername,
  insertOrUpdateProduct,
  insertProductShipment,
  updateProductShipment,
  softDeleteProductShipment,
  getAllProductShipments,
  getProductShipmentById,
  getProductShipmentByDate,
  getProductShipmentByStatus,
  insertProductShipmentDetail,
  updateProductShipmentDetail,
  softDeleteProductShipmentDetail,
  getAllProductShipmentDetails,
  getProductShipmentDetailByShipmentId,
  getProductShipmentDetailByProductId,
  getProductShipmentDetailById,
  getAllMaterialShipments,
  getMaterialShipmentDetailByShipmentId,
  acceptMaterialShipment,
  getAllMaterialsFromSupplier,
  getMaterialData
} = require("../controllers/rndController");

router.post("/design", async (req, res) => {
  try {
    const { name, image, description, category, gender, status } = req.body;
    await insertDesign(name, image, description, category, gender, status);
    res.status(201).json({ message: "Design inserted successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.put("/design", updateDesign);

router.delete("/design", softDeleteDesign);

router.get("/design", async (req, res) => {
  try {
    const designs = await getAllDesigns();
    res.status(200).json(designs);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/designs", async (req, res) => {
  try {
    const designs = await getAllDesign();
    res.status(200).json(designs);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/design/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const design = await getDesignById(id);
    res.status(200).json(design);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/design/name/:name", async (req, res) => {
  try {
    const { name } = req.params;
    const design = await getDesignByName(name);
    res.status(200).json(design);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.post("/design-material", async (req, res) => {
  try {
    const { designId, material_id, qty } = req.body;
    await insertDesignMaterial(designId, material_id, qty);
    res.status(201).json({ message: "Design material inserted successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.put("/design-material", updateDesignMaterial);

router.delete("/design-material", softDeleteDesignMaterial);

router.delete("/design-material-by-designId", softDeleteDesignMaterialByDesignId);

router.get("/design-material", async (req, res) => {
  try {
    const designMaterials = await getAllDesignMaterials();
    res.status(200).json(designMaterials);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/design-material/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const designMaterial = await getDesignMaterialById(id);
    res.status(200).json(designMaterial);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/design-material/design/:designId", async (req, res) => {
  try {
    const { designId } = req.params;
    const designMaterial = await getDesignMaterialByDesignId(designId);
    res.status(200).json(designMaterial);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/design-material/material/:materialId", async (req, res) => {
  try {
    const { materialId } = req.params;
    const designMaterial = await getDesignMaterialByMaterialId(materialId);
    res.status(200).json(designMaterial);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.post("/production", async (req, res) => {
  try {
    const { designId, expectedQty, status, productionSize } = req.body;
    await insertProduction(designId, expectedQty, status, productionSize);
    res.status(201).json({ message: "Production inserted successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.put("/production",  updateProduction);

router.delete("/production", softDeleteProduction);

router.get("/production", async (req, res) => {
  try {
    const productions = await getAllProductions();
    res.status(200).json(productions);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/production/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const production = await getProductionById(id);
    res.status(200).json(production);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/production/design/:designId", async (req, res) => {
  try {
    const { designId } = req.params;
    const production = await getProductionByDesignId(designId);
    res.status(200).json(production);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.put("/production/status", updateProductionStatus);

router.post("/product", async (req, res) => {
  try {
    const { product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price } = req.body;
    await insertProduct(product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price);
    res.status(201).json({ message: "Product inserted successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.put("/product", updateProduct);

router.delete("/product", softDeleteProduct);

router.get("/product", async (req, res) => {
  try {
    const products = await getAllProducts();
    res.status(200).json(products);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/product/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const product = await getProductById(id);
    res.status(200).json(product);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/product/name/:name", async (req, res) => {
  try {
    const { name } = req.params;
    const product = await getProductByName(name);
    res.status(200).json(product);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.post("/product/insert-or-update", insertOrUpdateProduct);

router.post("/material", async (req, res) => {
  try {
    const { name, stokQty } = req.body;
    await insertRawMaterial(name, stokQty);
    res.status(201).json({ message: "Raw material inserted successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.put("/material", updateRawMaterial);

router.delete("/material", softDeleteRawMaterial);

router.get("/material", async (req, res) => {
  try {
    const rawMaterials = await getAllRawMaterials();
    res.status(200).json(rawMaterials);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/filtered-material", async (req, res) => {
  try {
    const filteredMaterials = await getFilteredRawMaterials();
    res.status(200).json(filteredMaterials);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/material/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const rawMaterial = await getRawMaterialById(id);
    res.status(200).json(rawMaterial);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/material/name/:name", async (req, res) => {
  try {
    const { name } = req.params;
    const rawMaterial = await getRawMaterialByName(name);
    res.status(200).json(rawMaterial);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/logs", async (req, res) => {
  try {
    const logs = await getAllLogs();
    res.status(200).json(logs);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/logs/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const log = await getLogById(id);
    res.status(200).json(log);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/logs/action-type/:type", async (req, res) => {
  try {
    const { type } = req.params;
    const logs = await getLogsByActionType(type);
    res.status(200).json(logs);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/logs/table-name/:name", async (req, res) => {
  try {
    const { name } = req.params;
    const logs = await getLogsByTableName(name);
    res.status(200).json(logs);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/logs/action-time/:time", async (req, res) => {
  try {
    const { time } = req.params;
    const logs = await getLogsByActionTime(time);
    res.status(200).json(logs);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/logs/action-user/:username", async (req, res) => {
  try {
    const { username } = req.params;
    const logs = await getLogsByActionUser(username);
    res.status(200).json(logs);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.post("/login", login);

router.post("/register", register);

router.put("/user", updateUser);

router.delete("/user", softDeleteUser);

router.get("/user", async (req, res) => {
  try {
    const users = await getAllUsers();
    res.status(200).json(users);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/user/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const user = await getUserById(id);
    res.status(200).json(user);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/user/username/:username", async (req, res) => {
  try {
    const { username } = req.params;
    const user = await getUserByUsername(username);
    res.status(200).json(user);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.post("/product-shipment", insertProductShipment);

router.put("/product-shipment", updateProductShipment);

router.delete("/product-shipment", softDeleteProductShipment);

router.get("/product-shipments", async (req, res) => {
  try {
    const shipments = await getAllProductShipments();
    res.status(200).json(shipments);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/product-shipment/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const shipment = await getProductShipmentById(id);
    res.status(200).json(shipment);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/product-shipment/date/:date", async (req, res) => {
  try {
    const { date } = req.params;
    const shipments = await getProductShipmentByDate(date);
    res.status(200).json(shipments);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/product-shipment/status/:status", async (req, res) => {
  try {
    const { status } = req.params;
    const shipments = await getProductShipmentByStatus(status);
    res.status(200).json(shipments);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.post("/product-shipment-detail", async (req, res) => {
  try {
    const { shipmentDetailId, shipmentId, productId, quantity } = req.body;
    await insertProductShipmentDetail(shipmentDetailId, shipmentId, productId, quantity);
    res.status(201).json({ message: "Product shipment detail inserted successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.put("/product-shipment-detail", updateProductShipmentDetail);

router.delete("/product-shipment-detail", softDeleteProductShipmentDetail);

router.get("/product-shipment-details", async (req, res) => {
  try {
    const shipmentDetails = await getAllProductShipmentDetails();
    res.status(200).json(shipmentDetails);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/product-shipment-detail/shipment/:shipmentId", async (req, res) => {
  try {
    const { shipmentId } = req.params;
    const shipmentDetails = await getProductShipmentDetailByShipmentId(shipmentId);
    res.status(200).json(shipmentDetails);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/product-shipment-detail/product/:productId", async (req, res) => {
  try {
    const { productId } = req.params;
    const shipmentDetails = await getProductShipmentDetailByProductId(productId);
    res.status(200).json(shipmentDetails);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/product-shipment-detail/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const shipmentDetail = await getProductShipmentDetailById(id);
    res.status(200).json(shipmentDetail);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/material-shipments", async (req, res) => {
  try {
    const shipments = await getAllMaterialShipments();
    res.status(200).json(shipments);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/material-shipment-detail/shipment/:shipmentId", async (req, res) => {
  try {
    const { shipmentId } = req.params;
    const shipmentDetails = await getMaterialShipmentDetailByShipmentId(shipmentId);
    res.status(200).json(shipmentDetails);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Accept Material Shipment
router.put("/accept-shipment", async (req, res) => {
  const { shipmentId } = req.body;
  try {
    await acceptMaterialShipment(shipmentId);
    res
      .status(200)
      .json({ message: "Material shipment accepted successfully" });
  } catch (error) {
    console.error("Error accepting material shipment:", error.message);
    res.status(500).json({
      error: "An error occurred while accepting the material shipment",
    });
  }
});

router.get("/materials-from-supplier", async (req, res) => {
  try {
    const materials = await getAllMaterialsFromSupplier();
    res.status(200).json(materials);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/material-data", getMaterialData);

module.exports = router;
