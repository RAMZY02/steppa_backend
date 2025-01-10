const oracledb = require("oracledb");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcrypt");

// Aktifkan Thick Mode

// Melvin
// oracledb.initOracleClient({
//   libDir: "D:/KULIAH/Semester7/flutter/steppa_backend/instantclient_23_6",
// });

// Rama & Steven
oracledb.initOracleClient({
  libDir: "D:/instantclient_23_6",
});

// oracledb.initOracleClient({
//   libDir: "C:/Users/HP/Desktop/steppa_backend/instantclient_23_6",
// });

async function getConnection() {
  try {
    return await oracledb.getConnection({
      user: "reti",
      password: "reti",
      connectString: "192.168.195.2131521/steppa_supplier",
    });
  } catch (err) {
    console.error("Error saat koneksi:", err);
    throw err;
  }
}

// Supplier - Insert
async function insertSupplier(name, location, contactInfo) {
  let connection;

  try {
    connection = await getConnection();

    const query = `
            INSERT INTO suppliers (name, location, contact_info)
            VALUES (:name, :location, :contactInfo)
        `;

    await connection.execute(query, { name, location, contactInfo });

    await connection.execute("COMMIT");

    console.log("Supplier added successfully.");
  } catch (error) {
    console.error("Error inserting supplier:", error.message);
    if (connection) await connection.execute("ROLLBACK");
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Supplier - Update
async function updateSupplier(req, res) {
  let connection;

  try {
    const { supplierId, name, location, contactInfo } = req.body;

    connection = await getConnection();

    await connection.execute(
      `UPDATE suppliers 
            SET name = :name, location = :location, contact_info = :contactInfo 
            WHERE supplier_id = :supplierId`,
      { supplierId, name, location, contactInfo }
    );

    await connection.execute("COMMIT");

    res.status(200).json({ message: "Supplier updated successfully." });
  } catch (err) {
    console.error(err);
    if (connection) await connection.execute("ROLLBACK");
    res.status(500).json({ error: err.message });
  } finally {
    if (connection) {
      await connection.close();
    }
  }
}

// Supplier - Delete
async function softDeleteSupplier(req, res) {
  let connection;

  try {
    const { supplierId } = req.body;

    connection = await getConnection();

    const result = await connection.execute(
      `UPDATE suppliers 
            SET deleted_at = SYSDATE 
            WHERE supplier_id = :supplierId AND deleted_at IS NULL`,
      { supplierId }
    );

    await connection.execute("COMMIT");

    if (result.rowsAffected > 0) {
      res
        .status(200)
        .json({ message: "Supplier marked as deleted successfully." });
    } else {
      res
        .status(404)
        .json({ message: "Supplier not found or already deleted." });
    }
  } catch (err) {
    console.error(err);
    if (connection) await connection.execute("ROLLBACK");
    res.status(500).json({ error: err.message });
  } finally {
    if (connection) {
      await connection.close();
    }
  }
}

// Supplier - Get All
async function getAllSupplier() {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT supplier_id, name, location, contact_info
                FROM suppliers
                WHERE deleted_at IS NULL`
    );
    const suppliers = result.rows.map((row) => ({
      supplier_id: row[0],
      name: row[1],
      location: row[2],
      contact_info: row[3],
    }));
    return { suppliers };
  } catch (error) {
    console.error("Error fetching suppliers", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Supplier - Get by ID
async function getSupplierById(supplierId) {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT supplier_id, name, location, contact_info
                FROM suppliers
                WHERE supplier_id = :supplier_id AND deleted_at IS NULL`,
      [supplierId]
    );
    const supplier = result.rows.map((row) => ({
      supplier_id: row[0],
      name: row[1],
      location: row[2],
      contact_info: row[3],
    }));
    return { supplier };
  } catch (error) {
    console.error("Error fetching supplier by ID", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Supplier - Get by Name
async function getSupplierByName(supplierName) {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT supplier_id, name, location, contact_info
                FROM suppliers
                WHERE name like :supplierName AND deleted_at IS NULL`,
      [`%${supplierName}%`]
    );
    const suppliers = result.rows.map((row) => ({
      supplier_id: row[0],
      name: row[1],
      location: row[2],
      contact_info: row[3],
    }));
    return { suppliers };
  } catch (error) {
    console.error("Error fetching supplier by name", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Supplier - Get by location
async function getSupplierByLocation(location) {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT supplier_id, name, location, contact_info
                FROM suppliers
                WHERE location like :location AND deleted_at IS NULL`,
      [`%${location}%`]
    );
    const suppliers = result.rows.map((row) => ({
      supplier_id: row[0],
      name: row[1],
      location: row[2],
      contact_info: row[3],
    }));
    return { suppliers };
  } catch (error) {
    console.error("Error fetching supplier by location", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Raw Materials - Insert
async function insertRawMaterial(materialName, stockQuantity, supplierId) {
  let connection;

  try {
    connection = await getConnection();

    const query = `
            INSERT INTO raw_materials (material_name, stock_quantity, supplier_id, last_update)
            VALUES (:materialName, :stockQuantity, :supplierId, SYSDATE)
        `;

    await connection.execute(query, {
      materialName,
      stockQuantity,
      supplierId,
    });

    await connection.execute("COMMIT");

    console.log("Raw material added successfully.");
  } catch (error) {
    console.error("Error inserting raw material:", error.message);
    if (connection) await connection.execute("ROLLBACK");
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Raw Materials - Update
async function updateRawMaterial(req, res) {
  let connection;

  try {
    const { materialId, materialName, stockQuantity, supplierId } = req.body;

    connection = await getConnection();

    await connection.execute(
      `UPDATE raw_materials 
            SET material_name = :materialName, stock_quantity = :stockQuantity, 
                supplier_id = :supplierId, last_update = SYSDATE 
            WHERE material_id = :materialId`,
      { materialId, materialName, stockQuantity, supplierId }
    );

    await connection.execute("COMMIT");

    res.status(200).json({ message: "Raw material updated successfully." });
  } catch (err) {
    console.error(err);
    if (connection) await connection.execute("ROLLBACK");
    res.status(500).json({ error: err.message });
  } finally {
    if (connection) {
      await connection.close();
    }
  }
}

// Raw Materials - Delete
async function softDeleteRawMaterial(req, res) {
  let connection;

  try {
    const { materialId } = req.body;

    connection = await getConnection();

    const result = await connection.execute(
      `UPDATE raw_materials 
            SET deleted_at = SYSDATE 
            WHERE material_id = :materialId AND deleted_at IS NULL`,
      { materialId }
    );

    await connection.execute("COMMIT");

    if (result.rowsAffected > 0) {
      res
        .status(200)
        .json({ message: "Raw material marked as deleted successfully." });
    } else {
      res
        .status(404)
        .json({ message: "Raw material not found or already deleted." });
    }
  } catch (err) {
    console.error(err);
    if (connection) await connection.execute("ROLLBACK");
    res.status(500).json({ error: err.message });
  } finally {
    if (connection) {
      await connection.close();
    }
  }
}

// Raw Materials - Get All
async function getAllRawMaterial() {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT material_id, material_name, stock_quantity, supplier_id, last_update
                FROM raw_materials
                WHERE deleted_at IS NULL`
    );
    const materials = result.rows.map((row) => ({
      material_id: row[0],
      material_name: row[1],
      stock_quantity: row[2],
      supplier_id: row[3],
      last_update: row[4],
    }));
    return { materials };
  } catch (error) {
    console.error("Error fetching raw materials", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Raw Materials - Get by ID
async function getRawMaterialById(materialId) {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT material_id, material_name, stock_quantity, supplier_id, last_update
                FROM raw_materials
                WHERE material_id = :material_id AND deleted_at IS NULL`,
      [materialId]
    );
    const material = result.rows.map((row) => ({
      material_id: row[0],
      material_name: row[1],
      stock_quantity: row[2],
      supplier_id: row[3],
      last_update: row[4],
    }));
    return { material };
  } catch (error) {
    console.error("Error fetching raw material by ID", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Raw Materials - Get by Name
async function getRawMaterialByName(materialName) {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT material_id, material_name, stock_quantity, supplier_id, last_update
                FROM raw_materials
                WHERE material_name like :materialName AND deleted_at IS NULL`,
      [`%${materialName}%`]
    );
    const materials = result.rows.map((row) => ({
      material_id: row[0],
      material_name: row[1],
      stock_quantity: row[2],
      supplier_id: row[3],
      last_update: row[4],
    }));
    return { materials };
  } catch (error) {
    console.error("Error fetching raw material by name", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Raw Materials - Get by Supplier
async function getRawMaterialBySupplier(supplierId) {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT material_id, material_name, stock_quantity, supplier_id, last_update
                FROM raw_materials
                WHERE supplier_id = :supplierId AND deleted_at IS NULL`,
      [supplierId]
    );
    const materials = result.rows.map((row) => ({
      material_id: row[0],
      material_name: row[1],
      stock_quantity: row[2],
      supplier_id: row[3],
      last_update: row[4],
    }));
    return { materials };
  } catch (error) {
    console.error("Error fetching raw material by supplierId", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Transaction & Detail - Insert
async function insertTransactionAndDetail(transactionData) {
  let connection;

  try {
    const { transaction, details } = transactionData;

    connection = await getConnection();

    const insertTransactionQuery = `    
      INSERT INTO transactions (transaction_date, transaction_status, supplier_id, remarks)
      VALUES (SYSDATE, :transactionStatus, :supplierId, :remarks)
    `;
    await connection.execute(insertTransactionQuery, {
      transactionStatus: "Pending",
      supplierId: transaction.supplierId,
      remarks: transaction.remarks,
    });

    const result = await connection.execute(
      "SELECT MAX(transaction_id) FROM transactions"
    );

    const transactionId = result.rows[0][0];
    console.log("Transaction ID:", transactionId);

    const insertDetailQuery = `
      INSERT INTO transaction_detail (transaction_id, material_id, quantity)
      VALUES (:transaction_id, :material_id, :quantity)
    `;

    for (let i = 0; i < details.length; i++) {
      console.log(
        "Inserting detail:",
        details[i].materialId,
        details[i].quantity
      );

      await connection.execute(insertDetailQuery, {
        transaction_id: transactionId,
        material_id: details[i].materialId,
        quantity: details[i].quantity,
      });
    }

    await connection.execute("COMMIT");
    console.log("Transaction and details inserted successfully.");

    return {
      message: "Transaction and details inserted successfully.",
      transactionId,
    };
  } catch (error) {
    if (connection) await connection.execute("ROLLBACK");
    console.error("Error:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Transaction & Detail - Delete
async function softDeleteTransaction(req, res) {
  let connection;

  try {
    const { transactionId } = req.body;

    connection = await getConnection();

    // Soft delete transaksi
    await connection.execute(
      `UPDATE transactions SET deleted_at = SYSDATE WHERE transaction_id = :transactionId`,
      { transactionId }
    );

    // Soft delete semua detail transaksi terkait
    await connection.execute(
      `UPDATE transaction_detail SET deleted_at = SYSDATE WHERE transaction_id = :transactionId`,
      { transactionId }
    );

    await connection.execute("COMMIT");

    res.status(200).json({
      message: "Transaction and its details marked as deleted successfully.",
    });
  } catch (err) {
    console.error(err);
    if (connection) await connection.execute("ROLLBACK");
    res.status(500).json({ error: err.message });
  } finally {
    if (connection) {
      await connection.close();
    }
  }
}

// Transaction - Status (Pending -> Completed)
async function updateTransactionStatus(req, res) {
  let connection;

  try {
    const { transactionId } = req.body;

    // Validasi input
    if (!transactionId) {
      return res
        .status(400)
        .json({ error: "Transaction ID and new status are required." });
    }

    connection = await getConnection();

    // Menjalankan prosedur
    await connection.execute(
      `BEGIN 
            update_transaction_status(:p_transaction_id, :p_new_status); 
            END;`,
      {
        p_transaction_id: transactionId,
        p_new_status: "Completed",
      }
    );

    await connection.execute("COMMIT");

    res.status(200).json({
      message: "Transaction status updated successfully.",
      transactionId,
    });
  } catch (error) {
    console.error("Error updating transaction status:", error);
    if (connection) await connection.execute("ROLLBACK");
    res.status(500).json({
      error: "Failed to update transaction status.",
      details: error.message,
    });
  } finally {
    if (connection) {
      try {
        await connection.close();
      } catch (err) {
        console.error("Error closing the connection:", err.message);
      }
    }
  }
}

// Transaction - Update
async function updateTransaction(req, res) {
  let connection;

  try {
    const { transactionId, transactionStatus, remarks, supplierId } = req.body;

    connection = await getConnection();

    await connection.execute(
      `UPDATE transactions 
            SET transaction_status = :transactionStatus, remarks = :remarks, 
                supplier_id = :supplierId, transaction_date = SYSDATE 
            WHERE transaction_id = :transactionId`,
      { transactionId, transactionStatus, remarks, supplierId }
    );

    await connection.execute("COMMIT");

    res.status(200).json({ message: "Transaction updated successfully." });
  } catch (err) {
    console.error(err);
    if (connection) await connection.execute("ROLLBACK");
    res.status(500).json({ error: err.message });
  } finally {
    if (connection) {
      await connection.close();
    }
  }
}

// Transaction - Get All
async function getAllTransaction() {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT transaction_id, transaction_date, transaction_status, supplier_id, remarks
                FROM transactions
                WHERE deleted_at IS NULL`
    );
    const transactions = result.rows.map((row) => ({
      transaction_id: row[0],
      transaction_date: row[1],
      transaction_status: row[2],
      supplier_id: row[3],
      remarks: row[4],
    }));
    return { transactions };
  } catch (error) {
    console.error("Error fetching pending transactions", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Transaction - Get by ID
async function getTransactionById(transactionId) {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT t.transaction_id, t.transaction_date, t.transaction_status, t.supplier_id, t.remarks, td.detail_id, td.material_id, td.quantity        
      FROM transactions t
      JOIN transaction_detail td ON t.transaction_id = td.transaction_id
      WHERE t.transaction_id = :transactionId AND t.deleted_at IS NULL AND td.deleted_at IS NULL`,
      [transactionId]
    );
    const transaction = result.rows.map((row) => ({
      transaction_id: row[0],
      transaction_date: row[1],
      transaction_status: row[2],
      supplier_id: row[3],
      remarks: row[4],
      detail_id: row[5],
      material_id: row[6],
      quantity: row[7],
    }));
    return { transaction };
  } catch (error) {
    console.error("Error fetching transaction details", error);
    throw error;
  } finally {
    if (connection) {
      await connection.close();
    }
  }
}

// Transaction - Get Pending
async function getPendingTransaction() {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT transaction_id, transaction_date, transaction_status, supplier_id, remarks
                FROM transactions
                WHERE transaction_status = 'Pending' AND deleted_at IS NULL`
    );
    const transactions = result.rows.map((row) => ({
      transaction_id: row[0],
      transaction_date: row[1],
      transaction_status: row[2],
      supplier_id: row[3],
      remarks: row[4],
    }));
    return { transactions };
  } catch (error) {
    console.error("Error fetching pending transactions", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Transaction - Get Completed
async function getCompletedTransaction() {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT transaction_id, transaction_date, transaction_status, supplier_id, remarks
                FROM transactions
                WHERE transaction_status = 'Completed' AND deleted_at IS NULL`
    );
    const transactions = result.rows.map((row) => ({
      transaction_id: row[0],
      transaction_date: row[1],
      transaction_status: row[2],
      supplier_id: row[3],
      remarks: row[4],
    }));
    return { transactions };
  } catch (error) {
    console.error("Error fetching completed transactions", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Transaction - Get Pending by Date Range
async function getPendingTransactionByDate(startDate, endDate) {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT transaction_id, transaction_date, transaction_status, supplier_id, remarks
         FROM transactions
         WHERE transaction_status = 'Pending'
         AND deleted_at IS NULL
         AND transaction_date BETWEEN TO_DATE(:start_date, 'DD-MM-YYYY') 
                                  AND TO_DATE(:end_date, 'DD-MM-YYYY')`,
      {
        start_date: startDate,
        end_date: endDate,
      }
    );
    const transactions = result.rows.map((row) => ({
      transaction_id: row[0],
      transaction_date: row[1],
      transaction_status: row[2],
      supplier_id: row[3],
      remarks: row[4],
    }));
    return { transactions };
  } catch (error) {
    console.error("Error fetching pending transactions by date", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Transaction - Get Completed by Date Range
async function getCompletedTransactionByDate(startDate, endDate) {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT transaction_id, transaction_date, transaction_status, supplier_id, remarks
         FROM transactions
         WHERE transaction_status = 'Completed'
         AND deleted_at IS NULL
         AND transaction_date BETWEEN TO_DATE(:start_date, 'DD-MM-YYYY') 
                                  AND TO_DATE(:end_date, 'DD-MM-YYYY')`,
      {
        start_date: startDate,
        end_date: endDate,
      }
    );
    const transactions = result.rows.map((row) => ({
      transaction_id: row[0],
      transaction_date: row[1],
      transaction_status: row[2],
      supplier_id: row[3],
      remarks: row[4],
    }));
    return { transactions };
  } catch (error) {
    console.error("Error fetching completed transactions by date", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Transaction - Get Pending by Supplier ID
async function getPendingTransactionBySupplier(supplierId) {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT transaction_id, transaction_date, transaction_status, supplier_id, remarks
         FROM transactions
         WHERE supplier_id = :supplier_id
         AND transaction_status = 'Pending'
         AND deleted_at IS NULL`,
      { supplier_id: supplierId }
    );
    const transactions = result.rows.map((row) => ({
      transaction_id: row[0],
      transaction_date: row[1],
      transaction_status: row[2],
      supplier_id: row[3],
      remarks: row[4],
    }));
    return { transactions };
  } catch (error) {
    console.error("Error fetching pending transactions by supplier", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Transaction - Get Completed by Supplier ID
async function getCompletedTransactionBySupplier(supplierId) {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT transaction_id, transaction_date, transaction_status, supplier_id, remarks
         FROM transactions
         WHERE supplier_id = :supplier_id
         AND transaction_status = 'Completed'
         AND deleted_at IS NULL`,
      { supplier_id: supplierId }
    );
    const transactions = result.rows.map((row) => ({
      transaction_id: row[0],
      transaction_date: row[1],
      transaction_status: row[2],
      supplier_id: row[3],
      remarks: row[4],
    }));
    return { transactions };
  } catch (error) {
    console.error("Error fetching completed transactions by supplier", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Detail - Update
async function updateTransactionDetail(req, res) {
  let connection;

  try {
    const { detailId, materialId, quantity } = req.body;
    console.log("Updating detail with:", req.body);

    connection = await getConnection();

    await connection.execute(
      `UPDATE transaction_detail 
            SET material_id = :materialId, quantity = :quantity 
            WHERE detail_id = :detailId`,
      { detailId, materialId, quantity }
    );

    await connection.execute("COMMIT");

    res
      .status(200)
      .json({ message: "Transaction detail updated successfully." });
  } catch (err) {
    console.error(err);
    if (connection) await connection.execute("ROLLBACK");
    res.status(500).json({ error: err.message });
  } finally {
    if (connection) {
      await connection.close();
    }
  }
}

// Detail - Delete
async function softDeleteTransactionDetail(req, res) {
  let connection;

  try {
    const { transactionId, detailId } = req.body;

    connection = await getConnection();

    // Soft delete satu detail transaksi
    const result = await connection.execute(
      `UPDATE transaction_detail SET deleted_at = SYSDATE 
            WHERE detail_id = :detailId AND transaction_id = :transactionId`,
      { detailId, transactionId }
    );

    await connection.execute("COMMIT");

    if (result.rowsAffected > 0) {
      res.status(200).json({
        message: "Transaction detail marked as deleted successfully.",
      });
    } else {
      res.status(404).json({ message: "Detail not found or already deleted." });
    }
  } catch (err) {
    console.error(err);
    if (connection) await connection.execute("ROLLBACK");
    res.status(500).json({ error: err.message });
  } finally {
    if (connection) {
      await connection.close();
    }
  }
}

async function register(req, res) {
  const { username, password, fullName, email, phoneNumber, role } = req.body;
  const hashedPassword = await bcrypt.hash(password, 10);
  let connection;

  try {
    connection = await getConnection();

    const query = `
      INSERT INTO users (username, password, full_name, email, phone_number, role)
      VALUES (:username, :password, :fullName, :email, :phoneNumber, :role)
    `;

    await connection.execute(query, {
      username,
      password: hashedPassword,
      fullName,
      email,
      phoneNumber,
      role,
    });

    await connection.execute("COMMIT");

    res.status(201).json({ message: "User registered successfully" });
  } catch (error) {
    console.error("Error registering user:", error.message);
    if (connection) await connection.execute("ROLLBACK");
    res.status(500).json({ error: error.message });
  } finally {
    if (connection) await connection.close();
  }
}

async function login(req, res) {
  const { username, password } = req.body;
  let connection;

  try {
    connection = await getConnection();

    const result = await connection.execute(
      `SELECT user_id, password, role FROM users WHERE username = :username`,
      { username }
    );

    if (result.rows.length === 0) {
      return res.status(400).json({ error: "Invalid username or password" });
    }

    const user = result.rows[0];
    const validPassword = await bcrypt.compare(password, user.PASSWORD);

    if (!validPassword) {
      return res.status(400).json({ error: "Invalid username or password" });
    }

    const token = jwt.sign(
      { id: user.USER_ID, role: user.ROLE },
      "your_jwt_secret",
      {
        expiresIn: "1h",
      }
    );

    res.status(200).json({ token });
  } catch (error) {
    console.error("Error logging in:", error.message);
    if (connection) await connection.execute("ROLLBACK");
    res.status(500).json({ error: error.message });
  } finally {
    if (connection) await connection.close();
  }
}

async function insertUser(req, res) {
  const { username, password, fullName, email, phoneNumber, role } = req.body;
  const hashedPassword = await bcrypt.hash(password, 10);
  let connection;

  try {
    connection = await getConnection();

    const query = `
      INSERT INTO users (username, password, full_name, email, phone_number, role)
      VALUES (:username, :password, :fullName, :email, :phoneNumber, :role)
    `;

    await connection.execute(query, {
      username,
      password: hashedPassword,
      fullName,
      email,
      phoneNumber,
      role,
    });

    await connection.execute("COMMIT");

    res.status(201).json({ message: "User inserted successfully" });
  } catch (error) {
    console.error("Error inserting user:", error.message);
    if (connection) await connection.execute("ROLLBACK");
    res.status(500).json({ error: error.message });
  } finally {
    if (connection) await connection.close();
  }
}

async function updateUser(req, res) {
  const { userId, username, password, fullName, email, phoneNumber, role } =
    req.body;
  const hashedPassword = await bcrypt.hash(password, 10);
  let connection;

  try {
    connection = await getConnection();

    const query = `
      UPDATE users
      SET username = :username,
          password = :password,
          full_name = :fullName,
          email = :email,
          phone_number = :phoneNumber,
          role = :role
      WHERE user_id = :userId
    `;

    await connection.execute(query, {
      userId,
      username,
      password: hashedPassword,
      fullName,
      email,
      phoneNumber,
      role,
    });

    await connection.execute("COMMIT");

    res.status(200).json({ message: "User updated successfully" });
  } catch (error) {
    console.error("Error updating user:", error.message);
    if (connection) await connection.execute("ROLLBACK");
    res.status(500).json({ error: error.message });
  } finally {
    if (connection) await connection.close();
  }
}

async function softDeleteUser(req, res) {
  const { userId } = req.body;
  let connection;

  try {
    connection = await getConnection();

    const query = `
      UPDATE users
      SET deleted_at = SYSDATE
      WHERE user_id = :userId AND deleted_at IS NULL
    `;

    const result = await connection.execute(query, { userId });

    await connection.execute("COMMIT");

    if (result.rowsAffected > 0) {
      res.status(200).json({ message: "User marked as deleted successfully" });
    } else {
      res.status(404).json({ message: "User not found or already deleted" });
    }
  } catch (error) {
    console.error("Error deleting user:", error.message);
    if (connection) await connection.execute("ROLLBACK");
    res.status(500).json({ error: error.message });
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
      created_at: user[7],
      deleted_at: user[8],
    };
  } catch (error) {
    console.error("Error fetching user by ID:", error);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Insert Material Shipment
async function insertMaterialShipment(materials, quantities) {
  let connection = await getConnection();
  try {
    const insertShipmentQuery = `    
      INSERT INTO material_shipment (shipment_date, shipment_status)
      VALUES (SYSDATE, 'Shipped')
    `;
    await connection.execute(insertShipmentQuery);

    const result = await connection.execute(
      "select MAX(shipment_id) from material_shipment"
    );

    const shipmentId = result.rows[0][0];
    console.log("Shipment ID:", shipmentId);

    const insertDetailQuery = `
      INSERT INTO material_shipment_detail (shipment_id, material_id, quantity)
      VALUES (:shipment_id, :material_id, :quantity)
    `;

    for (let i = 0; i < materials.length; i++) {
      console.log("Inserting detail:", materials[i], quantities[i]);

      await connection.execute(insertDetailQuery, {
        shipment_id: shipmentId,
        material_id: materials[i],
        quantity: quantities[i],
      });
    }

    await connection.execute("COMMIT");
    console.log("Material shipment inserted successfully.");
  } catch (error) {
    console.error("Error inserting material shipment:", error.message);
    if (connection) await connection.execute("ROLLBACK");
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}
// Update Material Shipment Status
async function updateMaterialShipmentStatus(shipment_id, new_status) {
  let connection;
  try {
    connection = await getConnection();
    const query = `
      UPDATE material_shipment
      SET shipment_status = :new_status
      WHERE shipment_id = :shipment_id
    `;
    await connection.execute(query, { shipment_id, new_status });
    await connection.execute("COMMIT");
    console.log("Material shipment status updated successfully.");
  } catch (error) {
    console.error("Error updating material shipment status:", error.message);
    if (connection) await connection.execute("ROLLBACK");
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Get All Material Shipments
async function getAllMaterialShipments() {
  let connection;
  try {
    connection = await getConnection();
    const query = `SELECT * FROM material_shipment WHERE deleted_at IS NULL`;
    const result = await connection.execute(query);
    const shipments = result.rows.map((row) => ({
      shipment_id: row[0],
      shipment_date: row[1],
      shipment_status: row[2],
      created_at: row[3],
      deleted_at: row[4],
    }));
    return { shipments };
  } catch (error) {
    console.error("Error fetching material shipments:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Get Material Shipment by ID
async function getMaterialShipmentById(shipment_id) {
  let connection;
  try {
    connection = await getConnection();
    const query = `SELECT * FROM material_shipment WHERE shipment_id = :shipment_id AND deleted_at IS NULL`;
    const result = await connection.execute(query, { shipment_id });
    if (result.rows.length === 0) {
      throw new Error("Material shipment not found.");
    }
    const shipment = result.rows[0];
    return {
      shipment_id: shipment[0],
      shipment_date: shipment[1],
      shipment_status: shipment[2],
      created_at: shipment[3],
      deleted_at: shipment[4],
    };
  } catch (error) {
    console.error("Error fetching material shipment by ID:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

module.exports = {
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
  register,
  login,
  insertUser,
  updateUser,
  softDeleteUser,
  getUserById,
  insertMaterialShipment,
  updateMaterialShipmentStatus,
  getAllMaterialShipments,
  getMaterialShipmentById,
};
