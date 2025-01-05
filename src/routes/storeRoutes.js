const express = require("express");
const router = express.Router();
const storeController = require("../controllers/storeController");

// Product routes
router.post("/products", async (req, res) => {
  try {
    await storeController.insertProduct(req.body);
    res.status(201).json({ message: "Product added successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.put("/products", async (req, res) => {
  try {
    await storeController.updateProduct(req.body);
    res.status(200).json({ message: "Product updated successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.delete("/products", async (req, res) => {
  try {
    await storeController.softDeleteProduct(req.body.product_id);
    res
      .status(200)
      .json({ message: "Product marked as deleted successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/products", async (req, res) => {
  try {
    const products = await storeController.getAllProducts();
    res.status(200).json(products);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/products/stock", async (req, res) => {
  try {
    const { product_name, product_size } = req.query;
    const productDetail = await storeController.getProductStock(
      product_name,
      product_size
    );
    res.status(200).json(productDetail);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Sale routes
router.post("/sales", async (req, res) => {
  try {
    await storeController.insertSale(req.body);
    res.status(201).json({ message: "Sale added successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.put("/sales", async (req, res) => {
  try {
    await storeController.updateSale(req.body);
    res.status(200).json({ message: "Sale updated successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.delete("/sales", async (req, res) => {
  try {
    await storeController.softDeleteSale(req.body.sale_id);
    res.status(200).json({ message: "Sale marked as deleted successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/sales", async (req, res) => {
  try {
    const sales = await storeController.getAllSales();
    res.status(200).json(sales);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Sale Item routes
router.post("/sale_items", async (req, res) => {
  try {
    await storeController.insertSaleItem(req.body);
    res.status(201).json({ message: "Sale item added successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.put("/sale_items", async (req, res) => {
  try {
    await storeController.updateSaleItem(req.body);
    res.status(200).json({ message: "Sale item updated successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.delete("/sale_items", async (req, res) => {
  try {
    await storeController.softDeleteSaleItem(req.body.sale_item_id);
    res
      .status(200)
      .json({ message: "Sale item marked as deleted successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/sale_items", async (req, res) => {
  try {
    const saleItems = await storeController.getAllSaleItems();
    res.status(200).json(saleItems);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Customer routes
router.post("/customers", async (req, res) => {
  try {
    await storeController.insertCustomer(req.body);
    res.status(201).json({ message: "Customer added successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.put("/customers", async (req, res) => {
  try {
    await storeController.updateCustomer(req.body);
    res.status(200).json({ message: "Customer updated successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.delete("/customers", async (req, res) => {
  try {
    await storeController.softDeleteCustomer(req.body.customer_id);
    res
      .status(200)
      .json({ message: "Customer marked as deleted successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/customers", async (req, res) => {
  try {
    const customers = await storeController.getAllCustomers();
    res.status(200).json(customers);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Cart routes
router.post("/carts", async (req, res) => {
  try {
    await storeController.insertCart(req.body);
    res.status(201).json({ message: "Cart added successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.put("/carts", async (req, res) => {
  try {
    await storeController.updateCart(req.body);
    res.status(200).json({ message: "Cart updated successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.delete("/carts", async (req, res) => {
  try {
    await storeController.softDeleteCart(req.body.cart_id);
    res.status(200).json({ message: "Cart marked as deleted successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/carts", async (req, res) => {
  try {
    const carts = await storeController.getAllCarts();
    res.status(200).json(carts);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Cart Item routes
router.post("/cart_items", async (req, res) => {
  try {
    await storeController.insertCartItem(req.body);
    res.status(201).json({ message: "Cart item added successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.put("/cart_items", async (req, res) => {
  try {
    await storeController.updateCartItem(req.body);
    res.status(200).json({ message: "Cart item updated successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.delete("/cart_items", async (req, res) => {
  try {
    await storeController.softDeleteCartItem(req.body.cart_item_id);
    res
      .status(200)
      .json({ message: "Cart item marked as deleted successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/cart_items", async (req, res) => {
  try {
    const cartItems = await storeController.getAllCartItems();
    res.status(200).json(cartItems);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Revenue Report routes
router.post("/revenue_reports", async (req, res) => {
  try {
    await storeController.insertRevenueReport(req.body);
    res.status(201).json({ message: "Revenue report added successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.put("/revenue_reports", async (req, res) => {
  try {
    await storeController.updateRevenueReport(req.body);
    res.status(200).json({ message: "Revenue report updated successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.delete("/revenue_reports", async (req, res) => {
  try {
    await storeController.softDeleteRevenueReport(req.body.report_id);
    res
      .status(200)
      .json({ message: "Revenue report marked as deleted successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/revenue_reports", async (req, res) => {
  try {
    const revenueReports = await storeController.getAllRevenueReports();
    res.status(200).json(revenueReports);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
