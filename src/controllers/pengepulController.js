const oracledb = require("oracledb");

// Aktifkan Thick Mode
oracledb.initOracleClient({
  libDir: "D:/KULIAH/Semester7/flutter/steppa_backend/instantclient_23_6",
});

async function getConnection() {
  try {
    return await oracledb.getConnection({
      user: "reti",
      password: "reti",
      connectString: "localhost:1521/steppa_pengepul",
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
    connection = await oracledb.getConnection(dbConfig);

    const query = `
            INSERT INTO suppliers (name, location, contact_info)
            VALUES (:name, :location, :contactInfo)
        `;

    await connection.execute(
      query,
      { name, location, contactInfo },
      { autoCommit: true }
    );

    console.log("Supplier added successfully.");
  } catch (error) {
    console.error("Error inserting supplier:", error.message);
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

    connection = await oracledb.getConnection(dbConfig);

    await connection.execute(
      `UPDATE suppliers 
            SET name = :name, location = :location, contact_info = :contactInfo 
            WHERE supplier_id = :supplierId`,
      { supplierId, name, location, contactInfo },
      { autoCommit: true }
    );

    res.status(200).json({ message: "Supplier updated successfully." });
  } catch (err) {
    console.error(err);
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

    connection = await oracledb.getConnection(dbConfig);

    // Update is_deleted menjadi 'Y' untuk supplier tertentu
    const result = await connection.execute(
      `UPDATE suppliers 
            SET is_deleted = 'Y' 
            WHERE supplier_id = :supplierId AND is_deleted = 'N'`,
      { supplierId },
      { autoCommit: true }
    );

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
    res.status(500).json({ error: err.message });
  } finally {
    if (connection) {
      await connection.close();
    }
  }
}

// Supplier - Get All
async function getAllSuppliers() {
  const connection = await getDbConnection();
  try {
    const result = await connection.execute(
      `SELECT supplier_id, name, location, contact_info, is_deleted
                FROM suppliers
                WHERE is_deleted = 'N'`
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching suppliers", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Supplier - Get by ID
async function getSupplierById(supplierId) {
  const connection = await getDbConnection();
  try {
    const result = await connection.execute(
      `SELECT supplier_id, name, location, contact_info, is_deleted
                FROM suppliers
                WHERE supplier_id = :supplier_id AND is_deleted = 'N'`,
      [supplierId]
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching supplier by ID", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Supplier - Get by Name
async function getSupplierByName(supplierName) {
  const connection = await getDbConnection();
  try {
    const result = await connection.execute(
      `SELECT supplier_id, name, location, contact_info, is_deleted
                FROM suppliers
                WHERE name = :supplierName AND is_deleted = 'N'`,
      [supplierName]
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching supplier by name", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Supplier - Get by location
async function getSupplierByLocation(location) {
  const connection = await getDbConnection();
  try {
    const result = await connection.execute(
      `SELECT supplier_id, name, location, contact_info, is_deleted
                FROM suppliers
                WHERE name = :location AND is_deleted = 'N'`,
      [location]
    );
    return result.rows;
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
    connection = await oracledb.getConnection(dbConfig);

    const query = `
            INSERT INTO raw_materials (material_name, stock_quantity, supplier_id, last_update)
            VALUES (:materialName, :stockQuantity, :supplierId, SYSDATE)
        `;

    await connection.execute(
      query,
      { materialName, stockQuantity, supplierId },
      { autoCommit: true }
    );

    console.log("Raw material added successfully.");
  } catch (error) {
    console.error("Error inserting raw material:", error.message);
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

    connection = await oracledb.getConnection(dbConfig);

    await connection.execute(
      `UPDATE raw_materials 
            SET material_name = :materialName, stock_quantity = :stockQuantity, 
                supplier_id = :supplierId, last_update = SYSDATE 
            WHERE material_id = :materialId`,
      { materialId, materialName, stockQuantity, supplierId },
      { autoCommit: true }
    );

    res.status(200).json({ message: "Raw material updated successfully." });
  } catch (err) {
    console.error(err);
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

    connection = await oracledb.getConnection(dbConfig);

    // Update is_deleted menjadi 'Y' untuk raw material tertentu
    const result = await connection.execute(
      `UPDATE raw_materials 
            SET is_deleted = 'Y' 
            WHERE material_id = :materialId AND is_deleted = 'N'`,
      { materialId },
      { autoCommit: true }
    );

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
    res.status(500).json({ error: err.message });
  } finally {
    if (connection) {
      await connection.close();
    }
  }
}

// Raw Materials - Get All
async function getAllRawMaterials() {
  const connection = await getDbConnection();
  try {
    const result = await connection.execute(
      `SELECT material_id, material_name, stock_quantity, supplier_id, last_update, is_deleted
                FROM raw_materials
                WHERE is_deleted = 'N'`
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching raw materials", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Raw Materials - Get by ID
async function getRawMaterialById(materialId) {
  const connection = await getDbConnection();
  try {
    const result = await connection.execute(
      `SELECT material_id, material_name, stock_quantity, supplier_id, last_update, is_deleted
                FROM raw_materials
                WHERE material_id = :material_id AND is_deleted = 'N'`,
      [materialId]
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching raw material by ID", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Raw Materials - Get by Name
async function getRawMaterialByName(materialName) {
  const connection = await getDbConnection();
  try {
    const result = await connection.execute(
      `SELECT material_id, material_name, stock_quantity, supplier_id, last_update, is_deleted
                FROM raw_materials
                WHERE materialName = :materialName AND is_deleted = 'N'`,
      [materialName]
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching raw material by name", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Raw Materials - Get by Supplier
async function getRawMaterialBySupplier(supplierId) {
  const connection = await getDbConnection();
  try {
    const result = await connection.execute(
      `SELECT material_id, material_name, stock_quantity, supplier_id, last_update, is_deleted
                FROM raw_materials
                WHERE supplierId = :supplierId AND is_deleted = 'N'`,
      [supplierId]
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching raw material by supplierId", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Transaction & Detail - Insert
async function insertTransactionAndDetails(transactionData) {
  let connection;

  try {
    const { transaction, details } = transactionData;

    connection = await oracledb.getConnection(dbConfig);

    // Begin transaction
    await connection.execute(`BEGIN NULL; END;`); // To start a transaction explicitly

    // Insert into transactions
    const transactionQuery = `
            INSERT INTO transactions (transaction_date, transaction_status, supplier_id, remarks)
            VALUES (SYSDATE, :transactionStatus, :supplierId, :remarks)
            RETURNING transaction_id INTO :transactionId
        `;

    const transactionResult = await connection.execute(transactionQuery, {
      transactionStatus: "Pending",
      supplierId: transaction.supplierId,
      remarks: transaction.remarks,
      transactionId: { type: oracledb.STRING, dir: oracledb.BIND_OUT },
    });

    const transactionId = transactionResult.outBinds.transactionId[0];

    // Insert into transaction_detail
    const detailQuery = `
            INSERT INTO transaction_detail (transaction_id, material_id, quantity)
            VALUES (:transactionId, :materialId, :quantity)
        `;

    for (const detail of details) {
      await connection.execute(detailQuery, {
        transactionId,
        materialId: detail.materialId,
        quantity: detail.quantity,
      });
    }

    // Commit transaction
    await connection.commit();

    return {
      message: "Transaction and details inserted successfully.",
      transactionId,
    };
  } catch (error) {
    if (connection) await connection.rollback();
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

    connection = await oracledb.getConnection(dbConfig);

    // Soft delete transaksi
    await connection.execute(
      `UPDATE transactions SET is_deleted = 'Y' WHERE transaction_id = :transactionId`,
      { transactionId },
      { autoCommit: true }
    );

    // Soft delete semua detail transaksi terkait
    await connection.execute(
      `UPDATE transaction_detail SET is_deleted = 'Y' WHERE transaction_id = :transactionId`,
      { transactionId },
      { autoCommit: true }
    );

    res.status(200).json({
      message: "Transaction and its details marked as deleted successfully.",
    });
  } catch (err) {
    console.error(err);
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

    connection = await oracledb.getConnection(dbConfig);

    // Menjalankan prosedur
    await connection.execute(
      `BEGIN 
            update_transaction_status(:p_transaction_id, :p_new_status); 
            END;`,
      {
        p_transaction_id: transactionId,
        p_new_status: "Completed",
      },
      { autoCommit: true }
    );

    res.status(200).json({
      message: "Transaction status updated successfully.",
      transactionId,
      newStatus,
    });
  } catch (error) {
    console.error("Error updating transaction status:", error);
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

    connection = await oracledb.getConnection(dbConfig);

    await connection.execute(
      `UPDATE transactions 
            SET transaction_status = :transactionStatus, remarks = :remarks, 
                supplier_id = :supplierId, transaction_date = SYSDATE 
            WHERE transaction_id = :transactionId`,
      { transactionId, transactionStatus, remarks, supplierId },
      { autoCommit: true }
    );

    res.status(200).json({ message: "Transaction updated successfully." });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  } finally {
    if (connection) {
      await connection.close();
    }
  }
}

// Transaction - Get All
async function getAllTransactions() {
  const connection = await getDbConnection();
  try {
    const result = await connection.execute(
      `SELECT transaction_id, transaction_date, transaction_status, supplier_id, remarks
                FROM transactions
                WHERE is_deleted = 'N'`
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching pending transactions", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Transaction - Get Pending
async function getPendingTransactions() {
  const connection = await getDbConnection();
  try {
    const result = await connection.execute(
      `SELECT transaction_id, transaction_date, transaction_status, supplier_id, remarks
                FROM transactions
                WHERE transaction_status = 'Pending' AND is_deleted = 'N'`
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching pending transactions", error);
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

    connection = await oracledb.getConnection(dbConfig);

    await connection.execute(
      `UPDATE transaction_detail 
            SET material_id = :materialId, quantity = :quantity 
            WHERE detail_id = :detailId`,
      { detailId, materialId, quantity },
      { autoCommit: true }
    );

    res
      .status(200)
      .json({ message: "Transaction detail updated successfully." });
  } catch (err) {
    console.error(err);
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

    connection = await oracledb.getConnection(dbConfig);

    // Soft delete satu detail transaksi
    const result = await connection.execute(
      `UPDATE transaction_detail SET is_deleted = 'Y' 
            WHERE detail_id = :detailId AND transaction_id = :transactionId`,
      { detailId, transactionId },
      { autoCommit: true }
    );

    if (result.rowsAffected > 0) {
      res.status(200).json({
        message: "Transaction detail marked as deleted successfully.",
      });
    } else {
      res.status(404).json({ message: "Detail not found or already deleted." });
    }
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  } finally {
    if (connection) {
      await connection.close();
    }
  }
}

// Detail - Get by Transaction ID
async function getTransactionDetails(transactionId) {
  const connection = await getDbConnection();
  try {
    const result = await connection.execute(
      `SELECT td.detail_id, td.transaction_id, td.material_id, m.material_name, td.quantity
                FROM transaction_detail td
                JOIN raw_materials m ON td.material_id = m.material_id
                WHERE td.transaction_id = :transaction_id AND td.is_deleted = 'N'`,
      [transactionId]
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching transaction details", error);
    throw error;
  } finally {
    connection.close();
  }
}

module.exports = {
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
};
