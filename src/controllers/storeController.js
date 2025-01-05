const oracledb = require("oracledb");

// Aktifkan Thick Mode
oracledb.initOracleClient({
  libDir: "D:/KULIAH/Semester7/flutter/steppa_backend/instantclient_23_6",
});

async function getConnection() {
  try {
    return await oracledb.getConnection({
      user: "reki",
      password: "reki",
      connectString: "192.168.1.6:1521/steppa_store",
    });
  } catch (err) {
    console.error("Error saat koneksi:", err);
    throw err;
  }
}

// Products - Insert
async function insertProduct(product) {
  let connection;
  try {
    connection = await getConnection();
    const query = `
      INSERT INTO products (product_id, product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
      VALUES (:product_id, :product_name, :product_description, :product_category, :product_size, :product_gender, :product_image, :stok_qty, :price)
    `;
    await connection.execute(query, product, { autoCommit: true });
    console.log("Product added successfully.");
  } catch (error) {
    console.error("Error inserting product:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Products - Update
async function updateProduct(product) {
  let connection;
  try {
    connection = await getConnection();
    const query = `
      UPDATE products
      SET product_name = :product_name, product_description = :product_description, product_category = :product_category,
          product_size = :product_size, product_gender = :product_gender, product_image = :product_image, stok_qty = :stok_qty, price = :price
      WHERE product_id = :product_id
    `;
    await connection.execute(query, product, { autoCommit: true });
    console.log("Product updated successfully.");
  } catch (error) {
    console.error("Error updating product:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Products - Delete
async function softDeleteProduct(productId) {
  let connection;
  try {
    connection = await getConnection();
    const query = `UPDATE products SET deleted_at = SYSDATE WHERE product_id = :product_id`;
    await connection.execute(
      query,
      { product_id: productId },
      { autoCommit: true }
    );
    console.log("Product marked as deleted successfully.");
  } catch (error) {
    console.error("Error deleting product:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Products - Get All
async function getAllProducts() {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT 
        product_name,
        product_description,
        product_category,
        product_gender,
        price,
        MAX(product_image)
      FROM products
      WHERE deleted_at IS NULL
      GROUP BY product_name, product_description, product_category, product_gender, price`
    );

    const products = result.rows.map((row) => {
      return {
        product_name: row[0],
        product_category: row[1],
        product_gender: row[2],
        price: row[3],
        product_image: row[4],
      };
    });
    console.log(products);
    return products;
  } catch (error) {
    console.error("Error fetching products:", error);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Products - Get Catalog

// Products - Get New Releases
async function getNewReleaseProducts() {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT * FROM products 
       WHERE deleted_at IS NULL 
       AND created_at >= SYSDATE - 30`
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching new release products", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Products - Get Stock
async function getProductStock(productName, productSize) {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT stok_qty
       FROM products
       WHERE product_name = :product_name AND product_size = :product_size AND deleted_at IS NULL`,
      { product_name: productName, product_size: productSize }
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching product details:", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Products - Add Stock
async function addStock(productId, quantity) {
  let connection;
  try {
    connection = await getConnection();
    const query = `
      UPDATE products
      SET stok_qty = stok_qty + :quantity
      WHERE product_id = :product_id AND deleted_at IS NULL
    `;
    await connection.execute(
      query,
      { product_id: productId, quantity },
      { autoCommit: true }
    );
    console.log("Stock added successfully.");
  } catch (error) {
    console.error("Error adding stock:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Sales - Insert
async function insertSale(sale) {
  let connection;
  try {
    connection = await getConnection();
    const query = `
      INSERT INTO sales (sale_id, sale_channel, sale_date, total)
      VALUES (:sale_id, :sale_channel, :sale_date, :total)
    `;
    await connection.execute(query, sale, { autoCommit: true });
    console.log("Sale added successfully.");
  } catch (error) {
    console.error("Error inserting sale:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Sales - Update
async function updateSale(sale) {
  let connection;
  try {
    connection = await getConnection();
    const query = `
      UPDATE sales
      SET sale_channel = :sale_channel, sale_date = :sale_date, total = :total
      WHERE sale_id = :sale_id
    `;
    await connection.execute(query, sale, { autoCommit: true });
    console.log("Sale updated successfully.");
  } catch (error) {
    console.error("Error updating sale:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Sales - Delete
async function softDeleteSale(saleId) {
  let connection;
  try {
    connection = await getConnection();
    const query = `UPDATE sales SET deleted_at = SYSDATE WHERE sale_id = :sale_id`;
    await connection.execute(query, { sale_id: saleId }, { autoCommit: true });
    console.log("Sale marked as deleted successfully.");
  } catch (error) {
    console.error("Error deleting sale:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Sales - Get All
async function getAllSales() {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT * FROM sales WHERE deleted_at IS NULL`
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching sales", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Sale Items - Insert
async function insertSaleItem(saleItem) {
  let connection;
  try {
    connection = await getConnection();
    const query = `
      INSERT INTO sale_items (sale_item_id, sale_id, product_id, quantity, price, subtotal)
      VALUES (:sale_item_id, :sale_id, :product_id, :quantity, :price, :subtotal)
    `;
    await connection.execute(query, saleItem, { autoCommit: true });
    console.log("Sale item added successfully.");
  } catch (error) {
    console.error("Error inserting sale item:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Sale Items - Update
async function updateSaleItem(saleItem) {
  let connection;
  try {
    connection = await getConnection();
    const query = `
      UPDATE sale_items
      SET sale_id = :sale_id, product_id = :product_id, quantity = :quantity, price = :price, subtotal = :subtotal
      WHERE sale_item_id = :sale_item_id
    `;
    await connection.execute(query, saleItem, { autoCommit: true });
    console.log("Sale item updated successfully.");
  } catch (error) {
    console.error("Error updating sale item:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Sale Items - Delete
async function softDeleteSaleItem(saleItemId) {
  let connection;
  try {
    connection = await getConnection();
    const query = `UPDATE sale_items SET deleted_at = SYSDATE WHERE sale_item_id = :sale_item_id`;
    await connection.execute(
      query,
      { sale_item_id: saleItemId },
      { autoCommit: true }
    );
    console.log("Sale item marked as deleted successfully.");
  } catch (error) {
    console.error("Error deleting sale item:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Sale Items - Get All
async function getAllSaleItems() {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT * FROM sale_items WHERE deleted_at IS NULL`
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching sale items", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Customers - Insert
async function insertCustomer(customer) {
  let connection;
  try {
    connection = await getConnection();
    const query = `
      INSERT INTO customers (customer_id, name, email, phone_number, address, city, country, zip_code)
      VALUES (:customer_id, :name, :email, :phone_number, :address, :city, :country, :zip_code)
    `;
    await connection.execute(query, customer, { autoCommit: true });
    console.log("Customer added successfully.");
  } catch (error) {
    console.error("Error inserting customer:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Customers - Update
async function updateCustomer(customer) {
  let connection;
  try {
    connection = await getConnection();
    const query = `
      UPDATE customers
      SET name = :name, email = :email, phone_number = :phone_number, address = :address, city = :city, country = :country, zip_code = :zip_code
      WHERE customer_id = :customer_id
    `;
    await connection.execute(query, customer, { autoCommit: true });
    console.log("Customer updated successfully.");
  } catch (error) {
    console.error("Error updating customer:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Customers - Delete
async function softDeleteCustomer(customerId) {
  let connection;
  try {
    connection = await getConnection();
    const query = `UPDATE customers SET deleted_at = SYSDATE WHERE customer_id = :customer_id`;
    await connection.execute(
      query,
      { customer_id: customerId },
      { autoCommit: true }
    );
    console.log("Customer marked as deleted successfully.");
  } catch (error) {
    console.error("Error deleting customer:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Customers - Get All
async function getAllCustomers() {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT * FROM customers WHERE deleted_at IS NULL`
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching customers", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Carts - Insert
async function insertCart(cart) {
  let connection;
  try {
    connection = await getConnection();
    const query = `
      INSERT INTO carts (cart_id, customer_id)
      VALUES (:cart_id, :customer_id)
    `;
    await connection.execute(query, cart, { autoCommit: true });
    console.log("Cart added successfully.");
  } catch (error) {
    console.error("Error inserting cart:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Carts - Update
async function updateCart(cart) {
  let connection;
  try {
    connection = await getConnection();
    const query = `
      UPDATE carts
      SET customer_id = :customer_id
      WHERE cart_id = :cart_id
    `;
    await connection.execute(query, cart, { autoCommit: true });
    console.log("Cart updated successfully.");
  } catch (error) {
    console.error("Error updating cart:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Carts - Delete
async function softDeleteCart(cartId) {
  let connection;
  try {
    connection = await getConnection();
    const query = `UPDATE carts SET deleted_at = SYSDATE WHERE cart_id = :cart_id`;
    await connection.execute(query, { cart_id: cartId }, { autoCommit: true });
    console.log("Cart marked as deleted successfully.");
  } catch (error) {
    console.error("Error deleting cart:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Carts - Get All
async function getAllCarts() {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT * FROM carts WHERE deleted_at IS NULL`
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching carts", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Cart Items - Insert
async function insertCartItem(cartItem) {
  let connection;
  try {
    connection = await getConnection();
    const query = `
      INSERT INTO cart_items (cart_item_id, cart_id, product_id, quantity, price, status)
      VALUES (:cart_item_id, :cart_id, :product_id, :quantity, :price, :status)
    `;
    await connection.execute(query, cartItem, { autoCommit: true });
    console.log("Cart item added successfully.");
  } catch (error) {
    console.error("Error inserting cart item:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Cart Items - Update
async function updateCartItem(cartItem) {
  let connection;
  try {
    connection = await getConnection();
    const query = `
      UPDATE cart_items
      SET cart_id = :cart_id, product_id = :product_id, quantity = :quantity, price = :price, status = :status
      WHERE cart_item_id = :cart_item_id
    `;
    await connection.execute(query, cartItem, { autoCommit: true });
    console.log("Cart item updated successfully.");
  } catch (error) {
    console.error("Error updating cart item:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Cart Items - Delete
async function softDeleteCartItem(cartItemId) {
  let connection;
  try {
    connection = await getConnection();
    const query = `UPDATE cart_items SET deleted_at = SYSDATE WHERE cart_item_id = :cart_item_id`;
    await connection.execute(
      query,
      { cart_item_id: cartItemId },
      { autoCommit: true }
    );
    console.log("Cart item marked as deleted successfully.");
  } catch (error) {
    console.error("Error deleting cart item:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Cart Items - Get All
async function getAllCartItems() {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT * FROM cart_items WHERE deleted_at IS NULL`
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching cart items", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Revenue Reports - Insert
async function insertRevenueReport(report) {
  let connection;
  try {
    connection = await getConnection();
    const query = `
      INSERT INTO revenue_reports (report_id, report_period, total_revenue, total_expenses, net_profit)
      VALUES (:report_id, :report_period, :total_revenue, :total_expenses, :net_profit)
    `;
    await connection.execute(query, report, { autoCommit: true });
    console.log("Revenue report added successfully.");
  } catch (error) {
    console.error("Error inserting revenue report:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Revenue Reports - Update
async function updateRevenueReport(report) {
  let connection;
  try {
    connection = await getConnection();
    const query = `
      UPDATE revenue_reports
      SET report_period = :report_period, total_revenue = :total_revenue, total_expenses = :total_expenses, net_profit = :net_profit
      WHERE report_id = :report_id
    `;
    await connection.execute(query, report, { autoCommit: true });
    console.log("Revenue report updated successfully.");
  } catch (error) {
    console.error("Error updating revenue report:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Revenue Reports - Delete
async function softDeleteRevenueReport(reportId) {
  let connection;
  try {
    connection = await getConnection();
    const query = `UPDATE revenue_reports SET deleted_at = SYSDATE WHERE report_id = :report_id`;
    await connection.execute(
      query,
      { report_id: reportId },
      { autoCommit: true }
    );
    console.log("Revenue report marked as deleted successfully.");
  } catch (error) {
    console.error("Error deleting revenue report:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Revenue Reports - Get All
async function getAllRevenueReports() {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT * FROM revenue_reports WHERE deleted_at IS NULL`
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching revenue reports", error);
    throw error;
  } finally {
    connection.close();
  }
}

module.exports = {
  insertProduct,
  updateProduct,
  softDeleteProduct,
  getAllProducts,
  getNewReleaseProducts,
  getProductStock,
  addStock,
  insertSale,
  updateSale,
  softDeleteSale,
  getAllSales,
  insertSaleItem,
  updateSaleItem,
  softDeleteSaleItem,
  getAllSaleItems,
  insertCustomer,
  updateCustomer,
  softDeleteCustomer,
  getAllCustomers,
  insertCart,
  updateCart,
  softDeleteCart,
  getAllCarts,
  insertCartItem,
  updateCartItem,
  softDeleteCartItem,
  getAllCartItems,
  insertRevenueReport,
  updateRevenueReport,
  softDeleteRevenueReport,
  getAllRevenueReports,
};
