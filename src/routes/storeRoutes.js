const express = require("express");
const router = express.Router();
const storeController = require("../controllers/storeController");
const authenticateToken = require("../middleware/authenticateToken");

// User Registration
router.post("/register", async (req, res) => {
  try {
    await storeController.registerUser(req.body);
    res.status(201).json({ message: "Customers registered successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// User Login
router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    const { token } = await storeController.loginUser(email, password);
    res.status(200).json({ message: "User logged in successfully.", token });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Product routes ------------------------------------------------------------------------------------
// Insert product
router.post("/products", async (req, res) => {
  try {
    await storeController.insertProduct(req.body);
    res.status(201).json({ message: "Product added successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update product
router.put("/products", async (req, res) => {
  try {
    await storeController.updateProduct(req.body);
    res.status(200).json({ message: "Product updated successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Soft delete product
router.put("/products/delete", async (req, res) => {
  try {
    await storeController.softDeleteProduct(req.body.product_id);
    res
      .status(200)
      .json({ message: "Product marked as deleted successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get All Products
router.get("/products", async (req, res) => {
  try {
    const products = await storeController.getAllProducts();
    res.status(200).json(products);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get All Products
router.get("/products/cashier", async (req, res) => {
  try {
    const products = await storeController.getAllProductsCashier();
    res.status(200).json(products);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get New Releases
router.get("/products/new_releases", async (req, res) => {
  try {
    const newReleases = await storeController.getNewReleaseProducts();
    res.status(200).json(newReleases);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get Stock
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

// Get All Product Shipments with Details and Product Names
router.get("/product-shipments", authenticateToken, async (req, res) => {
  try {
    const shipments = await storeController.getAllProductShipments();
    res.status(200).json(shipments);
  } catch (error) {
    console.error(
      "Error fetching product shipments with details and product names:",
      error.message
    );
    res.status(500).json({
      error:
        "An error occurred while fetching product shipments with details and product names",
    });
  }
});

// Sale routes
// Insert sale
router.post("/sales", authenticateToken, async (req, res) => {
  try {
    await storeController.insertSale(req.body);
    res.status(201).json({ message: "Sale added successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update sale
router.put("/sales", authenticateToken, async (req, res) => {
  try {
    await storeController.updateSale(req.body);
    res.status(200).json({ message: "Sale updated successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Soft delete sale
router.put("/sales/delete", authenticateToken, async (req, res) => {
  try {
    await storeController.softDeleteSale(req.body.sale_id);
    res.status(200).json({ message: "Sale marked as deleted successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get All Sales
router.get("/sales", authenticateToken, async (req, res) => {
  try {
    const sales = await storeController.getAllSales();
    res.status(200).json(sales);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get Sale by ID
router.get("/sales/:id", authenticateToken, async (req, res) => {
  try {
    const sale = await storeController.getSaleById(req.params.id);
    res.status(200).json(sale);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get sale by channel
router.get("/sales/channel/:channel", authenticateToken, async (req, res) => {
  const { channel } = req.params;
  try {
    const sales = await storeController.getSaleByChannel(channel);
    res.status(200).json(sales);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get sale by date
router.get("/sales/date/:date", authenticateToken, async (req, res) => {
  const { date } = req.params;
  try {
    const sales = await storeController.getSaleByDate(date);
    res.status(200).json(sales);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get sale by date range
router.get(
  "/sales/daterange/:startDate/:endDate",
  authenticateToken,
  async (req, res) => {
    const { startDate, endDate } = req.params;
    try {
      const sales = await storeController.getSaleByDateRange(
        startDate,
        endDate
      );
      res.status(200).json(sales);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
);

// Sale Item routes
// Insert sale item
router.post("/sale_items", authenticateToken, async (req, res) => {
  try {
    await storeController.insertSaleItem(req.body);
    res.status(201).json({ message: "Sale item added successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update sale item
router.put("/sale_items", authenticateToken, async (req, res) => {
  try {
    await storeController.updateSaleItem(req.body);
    res.status(200).json({ message: "Sale item updated successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Soft delete sale item
router.put("/sale_items/delete", authenticateToken, async (req, res) => {
  try {
    await storeController.softDeleteSaleItem(req.body.sale_item_id);
    res
      .status(200)
      .json({ message: "Sale item marked as deleted successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get All Sale Items
router.get("/sale_items", authenticateToken, async (req, res) => {
  try {
    const saleItems = await storeController.getAllSaleItems();
    res.status(200).json(saleItems);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get Sale Item by ID
router.get("/sale_items/:id", authenticateToken, async (req, res) => {
  try {
    const saleItem = await storeController.getSaleItemById(req.params.id);
    res.status(200).json(saleItem);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get sale item by sale id
router.get("/saleitems/sale/:saleId", authenticateToken, async (req, res) => {
  const { saleId } = req.params;
  try {
    const saleItems = await storeController.getSaleItemBySaleId(saleId);
    res.status(200).json(saleItems);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get sale item by product id
router.get(
  "/saleitems/product/:productId",
  authenticateToken,
  async (req, res) => {
    const { productId } = req.params;
    try {
      const saleItems = await storeController.getSaleItemByProductId(productId);
      res.status(200).json(saleItems);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
);

// Customer routes
// Insert customer
router.post("/customers", authenticateToken, async (req, res) => {
  try {
    await storeController.insertCustomer(req.body);
    res.status(201).json({ message: "Customer added successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update customer
router.put("/customers", authenticateToken, async (req, res) => {
  try {
    await storeController.updateCustomer(req.body);
    res.status(200).json({ message: "Customer updated successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Soft delete customer
router.put("/customers/delete", authenticateToken, async (req, res) => {
  try {
    await storeController.softDeleteCustomer(req.body.customer_id);
    res
      .status(200)
      .json({ message: "Customer marked as deleted successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get All Customers
router.get("/customers", async (req, res) => {
  try {
    const customers = await storeController.getAllCustomers();
    res.status(200).json(customers);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get Customer by ID
router.get("/customers/:id", authenticateToken, async (req, res) => {
  try {
    const customer = await storeController.getCustomerById(req.params.id);
    res.status(200).json(customer);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Soft delete cart
router.put("/carts/delete", authenticateToken, async (req, res) => {
  try {
    await storeController.softDeleteCart(req.body.cart_id);
    res.status(200).json({ message: "Cart marked as deleted successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get All Carts
router.get("/carts", authenticateToken, async (req, res) => {
  try {
    const carts = await storeController.getAllCarts();
    res.status(200).json(carts);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get Cart by ID
router.get("/carts/:id", authenticateToken, async (req, res) => {
  try {
    const cart = await storeController.getCartById(req.params.id);
    res.status(200).json(cart);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get cart by customer id
router.get(
  "/carts/customer/:customerId",
  authenticateToken,
  async (req, res) => {
    const { customerId } = req.params;
    try {
      const carts = await storeController.getCartByCustomerId(customerId);
      res.status(200).json(carts);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
);

// Get cart items by cart id
router.get("/cartitems/cart/:cartId", authenticateToken, async (req, res) => {
  const { cartId } = req.params;
  try {
    const cartItems = await storeController.getCartItemsByCartId(cartId);
    res.status(200).json(cartItems);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get All Cart Items
router.get("/cart_items", authenticateToken, async (req, res) => {
  try {
    const cartItems = await storeController.getAllCartItems();
    res.status(200).json(cartItems);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get History
router.get(
  "/customer/history/:customerId",
  authenticateToken,
  async (req, res) => {
    try {
      const purchasedCartItems = await storeController.getPurchasedCartItems(
        req.params.customerId
      );
      res.status(200).json(purchasedCartItems);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
);

// Get Cart Item by ID
router.get("/cart_items/:id", authenticateToken, async (req, res) => {
  try {
    const cartItem = await storeController.getCartItemById(req.params.id);
    res.status(200).json(cartItem);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Cart - Add to Cart
router.post("/cart/add", authenticateToken, async (req, res) => {
  try {
    const { cart_id, product_id, quantity, price } = req.body;
    await storeController.addToCart(cart_id, product_id, quantity, price);
    res.status(201).json({ message: "Item added to cart successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Cart - Update Cart Item Quantity
router.put("/cart/update_quantity", authenticateToken, async (req, res) => {
  try {
    const { cart_item_id, quantity } = req.body;
    await storeController.updateCartItemQuantity(cart_item_id, quantity);
    res
      .status(200)
      .json({ message: "Cart item quantity updated successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Cart - Remove Item from Cart
router.put("/cart/remove_item", authenticateToken, async (req, res) => {
  try {
    const { cart_item_id } = req.body;
    await storeController.removeItemFromCart(cart_item_id);
    res.status(200).json({ message: "Item removed from cart successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Cart - Checkout
router.post("/cart/checkout", authenticateToken, async (req, res) => {
  try {
    const { cart_id, customerDetails } = req.body;
    const transaction = await storeController.checkout(
      cart_id,
      customerDetails
    );
    res
      .status(200)
      .json({ message: "Checkout completed successfully.", transaction });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Cart - Calculate Cart Subtotal
router.get("/cart/subtotal", authenticateToken, async (req, res) => {
  try {
    const { cart_id } = req.query;
    const total = await storeController.calculateCartSubtotal(cart_id);
    res.status(200).json({ total });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Cart - Offline Transaction
router.post(
  "/cart/offline_transaction_non_member",
  authenticateToken,
  async (req, res) => {
    try {
      const { sale_channel, products, quantities, prices } = req.body;
      const total = await storeController.offlineTransactionNonMember(
        sale_channel,
        products,
        quantities,
        prices
      );
      res.status(200).json({ total });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
);

// Cart - Offline Transaction
router.post(
  "/cart/offline_transaction_member",
  authenticateToken,
  async (req, res) => {
    try {
      const { customer_id, sale_channel, products, quantities, prices } =
        req.body;
      const total = await storeController.offlineTransactionMember(
        customer_id,
        sale_channel,
        products,
        quantities,
        prices
      );
      res.status(200).json({ total });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
);

// Revenue Report routes
// Insert revenue report
router.post("/revenue_reports", authenticateToken, async (req, res) => {
  try {
    await storeController.insertRevenueReport(req.body);
    res.status(201).json({ message: "Revenue report added successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update revenue report
router.put("/revenue_reports", authenticateToken, async (req, res) => {
  try {
    await storeController.updateRevenueReport(req.body);
    res.status(200).json({ message: "Revenue report updated successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Soft delete revenue report
router.put("/revenue_reports/delete", authenticateToken, async (req, res) => {
  try {
    await storeController.softDeleteRevenueReport(req.body.report_id);
    res
      .status(200)
      .json({ message: "Revenue report marked as deleted successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get All Revenue Reports
router.get("/revenue_reports", authenticateToken, async (req, res) => {
  try {
    const revenueReports = await storeController.getAllRevenueReports();
    res.status(200).json(revenueReports);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get Revenue Report by ID
router.get("/revenue_reports/:id", authenticateToken, async (req, res) => {
  try {
    const revenueReport = await storeController.getRevenueReportById(
      req.params.id
    );
    res.status(200).json(revenueReport);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// User routes
// Insert user
router.post("/users", async (req, res) => {
  try {
    await storeController.insertUser(req.body);
    res.status(201).json({ message: "User added successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update user
router.put("/users", async (req, res) => {
  try {
    await storeController.updateUser(req.body);
    res.status(200).json({ message: "User updated successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Soft delete user
router.put("/users/delete", async (req, res) => {
  try {
    await storeController.softDeleteUser(req.body.user_id);
    res.status(200).json({ message: "User marked as deleted successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get user by ID
router.get("/users/:id", async (req, res) => {
  try {
    const user = await storeController.getUserById(req.params.id);
    res.status(200).json(user);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Accept Product Shipment
router.put("/accept-shipment", authenticateToken, async (req, res) => {
  const { shipmentId } = req.body;
  try {
    await storeController.acceptProductShipment(shipmentId);
    res.status(200).json({ message: "Product shipment accepted successfully" });
  } catch (error) {
    console.error("Error accepting product shipment:", error.message);
    res.status(500).json({
      error: "An error occurred while accepting the product shipment",
    });
  }
});

module.exports = router;
