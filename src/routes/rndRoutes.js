const express = require("express");
const router = express.Router();

const {
  insertDesign,
  updateDesign,
  softDeleteDesign,
  getAllDesigns,
  getDesignById,
  getDesignByName,
  insertDesignMaterial,
  updateDesignMaterial,
  softDeleteDesignMaterial,
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
  getRawMaterialById,
  getRawMaterialByName,
  getAllLogs,
  getLogById,
  getLogsByActionType,
  getLogsByTableName,
  getLogsByActionTime,
  getLogsByActionUser,
  insertUser,
  updateUser,
  softDeleteUser,
  getAllUsers,
  getUserById,
  getUserByUsername
} = require("../controllers/rndController");

router.post("/design", async (req, res) => {
  try {
    const { name, image } = req.body;
    await insertDesign(name, image);
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
    const { designId, materialId, qty } = req.body;
    await insertDesignMaterial(designId, materialId, qty);
    res.status(201).json({ message: "Design material inserted successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.put("/design-material", updateDesignMaterial);

router.delete("/design-material", softDeleteDesignMaterial);

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

router.post("/user", async (req, res) => {
  try {
    const { user_id, username, password, full_name, email, phone_number, role } = req.body;
    await insertUser(user_id, username, password, full_name, email, phone_number, role);
    res.status(201).json({ message: "User inserted successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

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

module.exports = router;
