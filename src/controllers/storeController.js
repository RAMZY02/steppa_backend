const oracledb = require("oracledb");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const midtransClient = require("midtrans-client");

// Melvin
// oracledb.initOracleClient({
//   libDir: "D:/KULIAH/Semester7/flutter/steppa_backend/instantclient_23_6",
// });

// Rama & Steven
oracledb.initOracleClient({
  libDir: "D:/instantclient_23_6",
});

async function getConnection() {
  try {
    return await oracledb.getConnection({
      user: "reki",
      password: "reki",
      connectString: "192.168.195.213:1521/steppa_store",
    });
  } catch (err) {
    console.error("Error saat koneksi:", err);
    throw err;
  }
}

// User Registration
async function registerUser(user) {
  let connection;
  try {
    connection = await getConnection();

    const plsqlQuery = `
      DECLARE
        v_customer_id VARCHAR2(20);
      BEGIN
        INSERT INTO customers (name, email, phone_number, password, address, city, country, zip_code)
        VALUES (:name, :email, :phone_number, :password, :address, :city, :country, :zip_code)
        RETURNING customer_id INTO v_customer_id; 

        INSERT INTO carts (customer_id)
        VALUES (v_customer_id);

        DBMS_OUTPUT.PUT_LINE('Customer ID: ' || v_customer_id);
      END;
    `;

    const binds = {
      name: user.name,
      email: user.email,
      phone_number: user.phone_number,
      password: await bcrypt.hash(user.password, 10),
      address: user.address,
      city: user.city,
      country: user.country,
      zip_code: user.zip_code,
    };

    // Commit transaksi
    await connection.execute(plsqlQuery, binds);

    // Commit transaksi
    await connection.execute("COMMIT");
  } catch (error) {
    console.error("Error registering user:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// User Login
async function loginUser(email, password) {
  let connection;
  try {
    connection = await getConnection();
    const query = `SELECT customer_id, password FROM customers WHERE email = :email AND deleted_at IS NULL`;
    const result = await connection.execute(query, { email });
    if (result.rows.length === 0) {
      throw new Error("User not found.");
    }
    const user = result.rows[0];
    const isPasswordValid = await bcrypt.compare(password, user[1]);
    if (!isPasswordValid) {
      throw new Error("Invalid password.");
    }
    const token = jwt.sign({ customer_id: user[0] }, "your_jwt_secret", {
      expiresIn: "1h",
    });
    console.log("User logged in successfully.");
    return { token };
  } catch (error) {
    console.error("Error logging in user:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Products - Insert
async function insertProduct(product) {
  let connection;
  try {
    connection = await getConnection();
    const query = `
      BEGIN
      
      INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
      VALUES (:product_name, :product_description, :product_category, '40', :product_gender, :product_image, 0, :price)
      
      INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
      VALUES (:product_name, :product_description, :product_category, '41', :product_gender, :product_image, 0, :price)
      
      INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
      VALUES (:product_name, :product_description, :product_category, '42', :product_gender, :product_image, 0, :price)
      
      INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
      VALUES (:product_name, :product_description, :product_category, '43', :product_gender, :product_image, 0, :price)
      
      INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
      VALUES (:product_name, :product_description, :product_category, '44', :product_gender, :product_image, 0, :price)
      
      INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
      VALUES (:product_name, :product_description, :product_category, '45', :product_gender, :product_image, 0, :price)

      END;
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

// Products - Get Catalog
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
        product_description: row[1],
        product_category: row[2],
        product_gender: row[3],
        price: row[4],
        product_image: row[5],
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

// Products - Get New Releases
async function getNewReleaseProducts() {
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
       AND TRUNC(created_at) >= TRUNC(SYSDATE - 30)
       GROUP BY product_name, product_description, product_category, product_gender, price`
    );

    const newReleases = result.rows.map((row) => {
      return {
        product_name: row[0],
        product_description: row[1],
        product_category: row[2],
        product_gender: row[3],
        price: row[4],
        product_image: row[5],
      };
    });
    return newReleases;
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
      `SELECT product_id, stok_qty
       FROM products
       WHERE product_name like :product_name AND product_size = :product_size AND deleted_at IS NULL`,
      { product_name: `%${productName}%`, product_size: productSize }
    );

    const productStock = result.rows.map((row) => {
      return {
        product_id: row[0],
        stok_qty: row[1],
      };
    });
    return productStock;
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

// Sales -------------------------------------------------------------------------------
// Sales - Insert
async function insertSale(sale) {
  let connection;
  try {
    connection = await getConnection();
    const query = `
      INSERT INTO sales (sale_channel, sale_date, total)
      VALUES (:sale_channel, :sale_date, :total)
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

    const sales = result.rows.map((row) => {
      return {
        sale_id: row[0],
        sale_channel: row[1],
        sale_date: row[2],
        total: row[3],
        created_at: row[4],
      };
    });
    return sales;
  } catch (error) {
    console.error("Error fetching sales", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Sales - Get by ID
async function getSaleById(saleId) {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT * FROM sales WHERE sale_id = :sale_id AND deleted_at IS NULL`,
      { sale_id: saleId }
    );

    if (result.rows.length === 0) {
      throw new Error("Sale not found.");
    }

    const sale = result.rows[0];
    return {
      sale_id: sale[0],
      sale_channel: sale[1],
      sale_date: sale[2],
      total: sale[3],
    };
  } catch (error) {
    console.error("Error fetching sale by ID:", error);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Sale Items -------------------------------------------------------------------------------
// Sale Items - Insert
async function insertSaleItem(saleItem) {
  let connection;
  try {
    connection = await getConnection();
    const query = `
      INSERT INTO sale_items (sale_id, product_id, quantity, price, subtotal)
      VALUES (:sale_id, :product_id, :quantity, :price, :subtotal)
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

    const saleItems = result.rows.map((row) => {
      return {
        sale_item_id: row[0],
        sale_id: row[1],
        product_id: row[2],
        quantity: row[3],
        price: row[4],
        subtotal: row[5],
      };
    });
    return saleItems;
  } catch (error) {
    console.error("Error fetching sale items", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Sale Items - Get by ID
async function getSaleItemById(saleItemId) {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT * FROM sale_items WHERE sale_item_id = :sale_item_id AND deleted_at IS NULL`,
      { sale_item_id: saleItemId }
    );

    if (result.rows.length === 0) {
      throw new Error("Sale item not found.");
    }

    const saleItem = result.rows[0];
    return {
      sale_item_id: saleItem[0],
      sale_id: saleItem[1],
      product_id: saleItem[2],
      quantity: saleItem[3],
      price: saleItem[4],
      subtotal: saleItem[5],
    };
  } catch (error) {
    console.error("Error fetching sale item by ID:", error);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// get sale by channel
async function getSaleByChannel(channel) {
  let connection;
  try {
    connection = await getConnection();
    const result = await connection.execute(
      `BEGIN get_sale_by_channel(:channel, :sales); END;`,
      {
        channel,
        sales: { dir: oracledb.BIND_OUT, type: oracledb.CURSOR },
      }
    );
    const sales = await result.outBinds.sales.getRows();
    return sales.map((sale) => ({
      sale_id: sale[0],
      sale_channel: sale[1],
      sale_date: sale[2],
      total: sale[3],
    }));
  } catch (error) {
    console.error("Error fetching sales by channel:", error);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// get sale by date
async function getSaleByDate(sale_date) {
  let connection;
  try {
    connection = await getConnection();

    const result = await connection.execute(
      `SELECT sale_id, sale_channel, sale_date, total
       FROM sales
       WHERE TRUNC(sale_date) = TO_DATE(:sale_date, 'DD-MM-YYYY')`,
      { sale_date }
    );

    return result.rows.map((sale) => ({
      sale_id: sale[0],
      sale_channel: sale[1],
      sale_date: sale[2],
      total: sale[3],
    }));
  } catch (error) {
    console.error("Error fetching sales by date:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// get sale by date range
async function getSaleByDateRange(startDate, endDate) {
  let connection;
  try {
    connection = await getConnection();
    const result = await connection.execute(
      `SELECT sale_id, sale_channel, sale_date, total
       FROM sales
       WHERE TRUNC(sale_date) BETWEEN TO_DATE(:startDate, 'DD-MM-YYYY') AND TO_DATE(:endDate, 'DD-MM-YYYY')`,
      { startDate, endDate }
    );

    return result.rows.map((sale) => ({
      sale_id: sale[0],
      sale_channel: sale[1],
      sale_date: sale[2],
      total: sale[3],
    }));
  } catch (error) {
    console.error("Error fetching sales by date range:", error);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// get sale item by sale id
async function getSaleItemBySaleId(saleId) {
  let connection;
  try {
    connection = await getConnection();
    const result = await connection.execute(
      `BEGIN get_sale_item_by_sale_id(:saleId, :saleItems); END;`,
      {
        saleId,
        saleItems: { dir: oracledb.BIND_OUT, type: oracledb.CURSOR },
      }
    );
    const saleItems = await result.outBinds.saleItems.getRows();
    return saleItems.map((item) => ({
      sale_item_id: item[0],
      sale_id: item[1],
      product_id: item[2],
      quantity: item[3],
      price: item[4],
      subtotal: item[5],
    }));
  } catch (error) {
    console.error("Error fetching sale items by sale ID:", error);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// get sale item by product id
async function getSaleItemByProductId(productId) {
  let connection;
  try {
    connection = await getConnection();
    const result = await connection.execute(
      `BEGIN get_sale_item_by_product_id(:productId, :saleItems); END;`,
      {
        productId,
        saleItems: { dir: oracledb.BIND_OUT, type: oracledb.CURSOR },
      }
    );
    const saleItems = await result.outBinds.saleItems.getRows();
    return saleItems.map((item) => ({
      sale_item_id: item[0],
      sale_id: item[1],
      product_id: item[2],
      quantity: item[3],
      price: item[4],
      subtotal: item[5],
    }));
  } catch (error) {
    console.error("Error fetching sale items by product ID:", error);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Customers -------------------------------------------------------------------------------
// Customers - Insert
async function insertCustomer(customer) {
  let connection;
  try {
    connection = await getConnection();

    // Mulai transaksi
    await connection.execute("BEGIN");

    // Query untuk memasukkan data ke tabel customers
    const insertCustomerQuery = `
      INSERT INTO customers (name, email, phone_number, address, city, country, zip_code)
      VALUES (:name, :email, :phone_number, :address, :city, :country, :zip_code)
      RETURNING customer_id INTO :customer_id
    `;

    const binds = {
      name: customer.name,
      email: customer.email,
      phone_number: customer.phone_number,
      address: customer.address,
      city: customer.city,
      country: customer.country,
      zip_code: customer.zip_code,
      customer_id: { dir: oracledb.BIND_OUT, type: oracledb.NUMBER },
    };

    // Menjalankan query dan mendapatkan customer_id yang baru dibuat
    await connection.execute(insertCustomerQuery, binds);

    const customerId = binds.customer_id.val;
    console.log("Customer added with ID:", customerId);

    // Setelah berhasil menambah customer, insert cart untuk customer yang baru
    const insertCartQuery = `
      INSERT INTO carts (customer_id)
      VALUES (:customer_id)
    `;

    await connection.execute(insertCartQuery, { customer_id: customerId });
    console.log("Cart added successfully for customer with ID:", customerId);

    // Commit transaksi
    await connection.execute("COMMIT");
  } catch (error) {
    console.error("Error inserting customer and creating cart:", error.message);

    // Rollback transaksi jika terjadi kesalahan
    if (connection) {
      await connection.execute("ROLLBACK");
    }
    throw error;
  } finally {
    // Tutup koneksi
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

    const customers = result.rows.map((row) => {
      return {
        customer_id: row[0],
        name: row[1],
        email: row[2],
        phone_number: row[3],
        address: row[4],
        city: row[5],
        country: row[6],
        zip_code: row[7],
      };
    });
    return customers;
  } catch (error) {
    console.error("Error fetching customers", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Customers - Get by ID
async function getCustomerById(customerId) {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT * FROM customers WHERE customer_id = :customer_id AND deleted_at IS NULL`,
      { customer_id: customerId }
    );

    if (result.rows.length === 0) {
      throw new Error("Customer not found.");
    }

    const customer = result.rows[0];
    return {
      customer_id: customer[0],
      name: customer[1],
      email: customer[2],
      phone_number: customer[3],
      address: customer[4],
      city: customer[5],
      country: customer[6],
      zip_code: customer[7],
    };
  } catch (error) {
    console.error("Error fetching customer by ID:", error);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Carts -------------------------------------------------------------------------------
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

    const carts = result.rows.map((row) => {
      return {
        cart_id: row[0],
        customer_id: row[1],
      };
    });
    return carts;
  } catch (error) {
    console.error("Error fetching carts", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Cart Items - Get All
async function getAllCartItems() {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT * FROM cart_items WHERE deleted_at IS NULL`
    );

    const cartItems = result.rows.map((row) => {
      return {
        cart_item_id: row[0],
        cart_id: row[1],
        product_id: row[2],
        quantity: row[3],
        price: row[4],
        status: row[5],
      };
    });
    return cartItems;
  } catch (error) {
    console.error("Error fetching cart items", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Cart Items - Get Purchased Items for a specific user
async function getPurchasedCartItems(customerId) {
  const connection = await getConnection();
  console.log("Customer ID:", customerId);

  try {
    const result = await connection.execute(
      `SELECT ci.cart_item_id, ci.cart_id, ci.product_id, ci.quantity, ci.price, ci.status,
              p.product_name, p.product_description, p.product_category, p.product_size, p.product_gender, p.product_image, p.stok_qty, p.price
       FROM cart_items ci
       JOIN products p ON ci.product_id = p.product_id
       JOIN carts c ON ci.cart_id = c.cart_id
       WHERE ci.status = 'purchased' AND ci.deleted_at IS NULL AND c.customer_id = :customer_id`,
      { customer_id: customerId }
    );

    const purchasedCartItems = result.rows.map((item) => ({
      cart_item_id: item[0],
      cart_id: item[1],
      product_id: item[2],
      quantity: item[3],
      price: item[4],
      status: item[5],
      product_name: item[6],
      product_description: item[7],
      product_category: item[8],
      product_size: item[9],
      product_gender: item[10],
      product_image: item[11],
      stok_qty: item[12],
      product_price: item[13],
    }));
    return purchasedCartItems;
  } catch (error) {
    console.error("Error fetching purchased cart items:", error);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Cart - Add to Cart
async function addToCart(cartId, productId, quantity, price) {
  let connection;
  try {
    connection = await getConnection();
    const query = `BEGIN add_to_cart(:cart_id, :product_id, :quantity, :price); END;`;
    await connection.execute(
      query,
      { cart_id: cartId, product_id: productId, quantity, price },
      { autoCommit: true }
    );
    console.log("Item added to cart successfully.");
  } catch (error) {
    console.error("Error adding item to cart:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Cart - Update Cart Item Quantity
async function updateCartItemQuantity(cartItemId, quantity) {
  let connection;
  try {
    connection = await getConnection();
    const query = `BEGIN update_cart_item_quantity(:cart_item_id, :quantity); END;`;
    await connection.execute(
      query,
      { cart_item_id: cartItemId, quantity },
      { autoCommit: true }
    );
    console.log("Cart item quantity updated successfully.");
  } catch (error) {
    console.error("Error updating cart item quantity:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Cart - Remove Item from Cart
async function removeItemFromCart(cartItemId) {
  let connection;
  try {
    connection = await getConnection();
    const query = `BEGIN remove_item_from_cart(:cart_item_id); END;`;
    await connection.execute(
      query,
      { cart_item_id: cartItemId },
      { autoCommit: true }
    );
    console.log("Item removed from cart successfully.");
  } catch (error) {
    console.error("Error removing item from cart:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Create Snap API instance
const snap = new midtransClient.Snap({
  isProduction: false,
  serverKey: "SB-Mid-server-3o0aKsOiaojIGTnxC0iUw_xu",
  clientKey: "SB-Mid-client-UZjYV-a03fWcJDo8",
});

async function createTransaction(orderId, grossAmount, customerDetails) {
  try {
    const parameter = {
      transaction_details: {
        order_id: orderId,
        gross_amount: grossAmount,
      },
      credit_card: {
        secure: true,
      },
      customer_details: customerDetails,
    };

    const transaction = await snap.createTransaction(parameter);
    return transaction;
  } catch (error) {
    console.error("Error creating transaction:", error.message);
    throw error;
  }
}

// Cart - Checkout
async function checkout(cartId, customerDetails) {
  let connection;
  try {
    connection = await getConnection();

    const total = await calculateCartSubtotal(cartId);

    const query = `BEGIN checkout(:cart_id); END;`;
    await connection.execute(query, { cart_id: cartId }, { autoCommit: true });

    // Calculate the total amount for the transaction
    console.log("Total amount for transaction:", total);

    // Create a Midtrans transaction
    const orderId = `ORDER-${Date.now()}`;
    const transaction = await createTransaction(
      orderId,
      total,
      customerDetails
    );

    console.log("Checkout completed successfully.");
    return transaction;
  } catch (error) {
    console.error("Error during checkout:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Cart - Calculate Cart Subtotal
async function calculateCartSubtotal(cartId) {
  let connection;
  try {
    connection = await getConnection();
    const query = `BEGIN calculate_cart_subtotal(:cart_id, :total); END;`;
    const result = await connection.execute(query, {
      cart_id: cartId,
      total: { dir: oracledb.BIND_OUT, type: oracledb.NUMBER },
    });
    console.log(
      "Cart subtotal calculated successfully. Total:",
      result.outBinds.total
    );
    return result.outBinds.total;
  } catch (error) {
    console.error("Error calculating cart subtotal:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Cart - get cart by customer id
async function getCartByCustomerId(customerId) {
  let connection;
  try {
    connection = await getConnection();
    const result = await connection.execute(
      `SELECT cart_id FROM carts WHERE customer_id = :customerId`,
      [customerId]
    );

    const carts = result.rows.map((row) => {
      return {
        cart_id: row[0],
      };
    });
    return carts;
  } catch (error) {
    console.error("Error fetching carts by customer ID:", error);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

//  Cart - get cart items by cart id
async function getCartItemsByCartId(cartId) {
  let connection;
  try {
    connection = await getConnection();
    const result = await connection.execute(
      `SELECT ci.cart_item_id, ci.cart_id, ci.product_id, ci.quantity, ci.price, ci.status,
              p.product_name, p.product_description, p.product_category, p.product_size, p.product_gender, p.product_image, p.stok_qty, p.price
       FROM cart_items ci
       JOIN products p ON ci.product_id = p.product_id
       WHERE ci.cart_id = :cartId AND ci.deleted_at IS NULL AND ci.status = 'active'`,
      { cartId }
    );

    const cartItems = result.rows.map((item) => ({
      cart_item_id: item[0],
      cart_id: item[1],
      product_id: item[2],
      quantity: item[3],
      price: item[4],
      status: item[5],
      product_name: item[6],
      product_description: item[7],
      product_category: item[8],
      product_size: item[9],
      product_gender: item[10],
      product_image: item[11],
      stok_qty: item[12],
      product_price: item[13],
    }));
    return cartItems;
  } catch (error) {
    console.error("Error fetching cart items by cart ID:", error);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Cart - Offline Transaction Member
async function offlineTransactionMember(
  customerId,
  saleChannel,
  products,
  quantities,
  prices
) {
  let connection;
  try {
    connection = await getConnection();
    const query = `BEGIN offline_transaction_member(:customer_id, :sale_channel, :products, :quantities, :prices, :total); END;`;
    const result = await connection.execute(query, {
      customer_id: customerId,
      sale_channel: saleChannel,
      products: { type: oracledb.STRING, dir: oracledb.BIND_IN, val: products },
      quantities: {
        type: oracledb.NUMBER,
        dir: oracledb.BIND_IN,
        val: quantities,
      },
      prices: { type: oracledb.NUMBER, dir: oracledb.BIND_IN, val: prices },
      total: { dir: oracledb.BIND_OUT, type: oracledb.NUMBER },
    });
    console.log("Offline transaction completed successfully.");
    return result.outBinds.total;
  } catch (error) {
    console.error("Error during offline transaction:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Cart - Offline Transaction Non Member
async function offlineTransactionNonMember(
  saleChannel,
  products,
  quantities,
  prices
) {
  let connection;
  try {
    connection = await getConnection();
    const query = `BEGIN offline_transaction_non_member(:sale_channel, :products, :quantities, :prices, :total); END;`;
    const result = await connection.execute(query, {
      sale_channel: saleChannel,
      products: { type: oracledb.STRING, dir: oracledb.BIND_IN, val: products },
      quantities: {
        type: oracledb.NUMBER,
        dir: oracledb.BIND_IN,
        val: quantities,
      },
      prices: { type: oracledb.NUMBER, dir: oracledb.BIND_IN, val: prices },
      total: { dir: oracledb.BIND_OUT, type: oracledb.NUMBER },
    });
    console.log("Offline transaction completed successfully.");
    return result.outBinds.total;
  } catch (error) {
    console.error("Error during offline transaction:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Revenue Reports -------------------------------------------------------------------------------
// Revenue Reports - Insert
async function insertRevenueReport(report) {
  let connection;
  try {
    connection = await getConnection();
    const query = `
      INSERT INTO revenue_reports (report_period, total_revenue, total_expenses, net_profit)
      VALUES (:report_period, :total_revenue, :total_expenses, :net_profit)
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

    const revenueReports = result.rows.map((row) => {
      return {
        report_id: row[0],
        report_period: row[1],
        total_revenue: row[2],
        total_expenses: row[3],
        net_profit: row[4],
      };
    });
    return revenueReports;
  } catch (error) {
    console.error("Error fetching revenue reports", error);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Revenue Reports - Get by ID
async function getRevenueReportById(reportId) {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT * FROM revenue_reports WHERE report_id = :report_id AND deleted_at IS NULL`,
      { report_id: reportId }
    );

    if (result.rows.length === 0) {
      throw new Error("Revenue report not found.");
    }

    const revenueReport = result.rows[0];
    return {
      report_id: revenueReport[0],
      report_period: revenueReport[1],
      total_revenue: revenueReport[2],
      total_expenses: revenueReport[3],
      net_profit: revenueReport[4],
    };
  } catch (error) {
    console.error("Error fetching revenue report by ID:", error);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Users - Insert
async function insertUser(user) {
  let connection;
  try {
    connection = await getConnection();
    const hashedPassword = await bcrypt.hash(user.password, 10);
    const query = `
      INSERT INTO users (username, email, password)
      VALUES (:username, :email, :password)
    `;
    await connection.execute(
      query,
      {
        ...user,
        password: hashedPassword,
      },
      { autoCommit: true }
    );
    console.log("User added successfully.");
  } catch (error) {
    console.error("Error inserting user:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Users - Update
async function updateUser(user) {
  let connection;
  try {
    connection = await getConnection();
    const query = `
      UPDATE users
      SET username = :username, email = :email, password = :password
      WHERE user_id = :user_id
    `;
    await connection.execute(query, user, { autoCommit: true });
    console.log("User updated successfully.");
  } catch (error) {
    console.error("Error updating user:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Users - Delete
async function softDeleteUser(userId) {
  let connection;
  try {
    connection = await getConnection();
    const query = `UPDATE users SET deleted_at = SYSDATE WHERE user_id = :user_id`;
    await connection.execute(query, { user_id: userId }, { autoCommit: true });
    console.log("User marked as deleted successfully.");
  } catch (error) {
    console.error("Error deleting user:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Users - Get by ID
async function getUserById(userId) {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT * FROM users WHERE user_id = :user_id AND deleted_at IS NULL`,
      { user_id: userId }
    );

    if (result.rows.length === 0) {
      throw new Error("User not found.");
    }

    const user = result.rows[0];
    return {
      user_id: user[0],
      username: user[1],
      password: user[2],
      full_name: user[3],
      email: user[4],
      phone_number: user[5],
      role: user[6],
    };
  } catch (error) {
    console.error("Error fetching user by ID:", error);
    throw error;
  } finally {
    if (connection) await connection.close();
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
  getSaleById,
  insertSaleItem,
  updateSaleItem,
  softDeleteSaleItem,
  getAllSaleItems,
  getSaleItemById,
  insertCustomer,
  updateCustomer,
  softDeleteCustomer,
  getAllCustomers,
  getCustomerById,
  softDeleteCart,
  getAllCarts,
  getAllCartItems,
  insertRevenueReport,
  updateRevenueReport,
  softDeleteRevenueReport,
  getAllRevenueReports,
  getRevenueReportById,
  addToCart,
  updateCartItemQuantity,
  removeItemFromCart,
  checkout,
  calculateCartSubtotal,
  offlineTransactionMember,
  offlineTransactionNonMember,
  registerUser,
  loginUser,
  insertUser,
  updateUser,
  softDeleteUser,
  getUserById,
  getSaleByChannel,
  getSaleByDate,
  getSaleByDateRange,
  getSaleItemBySaleId,
  getSaleItemByProductId,
  getCartByCustomerId,
  getCartItemsByCartId,
  createTransaction,
  getPurchasedCartItems,
};
