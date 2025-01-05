const oracledb = require("oracledb");

// Aktifkan Thick Mode
oracledb.initOracleClient({
  libDir: "D:/instantclient_23_6",
});

async function getConnection() {
  try {
    return await oracledb.getConnection({
      user: "rama",
      password: "rama",
      connectString: "localhost:1521/steppa_rnd",
    });
  } catch (err) {
    console.error("Error saat koneksi:", err);
    throw err;
  }
}

// Insert Design
async function insertDesign(name, image) {
  let connection;
  try {
    connection = await getConnection();
    const query = `
      INSERT INTO design (name, image, created_at)
      VALUES (:name, :image, SYSDATE)
    `;
    await connection.execute(query, { name, image }, { autoCommit: true });
    console.log("Design added successfully.");
  } catch (error) {
    console.error("Error inserting design:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Update Design
async function updateDesign(req, res) {
  let connection;
  try {
    const { id, name, image } = req.body;
    connection = await getConnection();
    
    let query = 'UPDATE design SET ';
    const binds = { id };

    if (name) {
      query += 'name = :name';
      binds.name = name;
    }

    if (image) {
      if (name) query += ', ';
      query += 'image = :image';
      binds.image = image;
    }

    query += ' WHERE id = :id';

    await connection.execute(query, binds, { autoCommit: true });
    res.status(200).json({ message: "Design updated successfully." });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  } finally {
    if (connection) await connection.close();
  }
}

// Soft Delete Design
async function softDeleteDesign(req, res) {
  let connection;
  try {
    const { id } = req.body;
    connection = await getConnection();
    await connection.execute(
      `UPDATE design 
       SET deleted_at = SYSDATE 
       WHERE id = :id AND deleted_at IS NULL`,
      { id },
      { autoCommit: true }
    );
    res.status(200).json({ message: "Design marked as deleted successfully." });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  } finally {
    if (connection) await connection.close();
  }
}

// Get All Designs
async function getAllDesigns() {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT id, name, image 
       FROM design 
       WHERE deleted_at IS NULL`
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching designs", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Get Design by ID
async function getDesignById(id) {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT id, name, image 
       FROM design 
       WHERE id = :id AND deleted_at IS NULL`,
      { id }
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching design by ID", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Get Design by Name
async function getDesignByName(name) {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT id, name, image 
       FROM design 
       WHERE LOWER(name) LIKE LOWER(:name) AND deleted_at IS NULL`,
      [`%${name}%`]
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching design by name", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Insert Design Material
async function insertDesignMaterial(designId, materialId, qty) {
  let connection;
  try {
    connection = await getConnection();
    const query = `
      INSERT INTO design_materials (design_id, material_id, qty, created_at)
      VALUES (:designId, :materialId, :qty, SYSDATE)
    `;
    await connection.execute(query, { designId, materialId, qty }, { autoCommit: true });
    console.log("Design material added successfully.");
  } catch (error) {
    console.error("Error inserting design material:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Update Design Material
async function updateDesignMaterial(req, res) {
  let connection;
  try {
    const { id, designId, materialId, qty } = req.body;
    connection = await getConnection();
    
    let query = 'UPDATE design_materials SET ';
    const binds = { id };

    if (designId) {
      query += 'design_id = :designId';
      binds.designId = designId;
    }

    if (materialId) {
      if (designId) query += ', ';
      query += 'material_id = :materialId';
      binds.materialId = materialId;
    }

    if (qty) {
      if (designId || materialId) query += ', ';
      query += 'qty = :qty';
      binds.qty = qty;
    }

    query += ' WHERE id = :id';

    await connection.execute(query, binds, { autoCommit: true });
    res.status(200).json({ message: "Design material updated successfully." });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  } finally {
    if (connection) await connection.close();
  }
}

// Soft Delete Design Material
async function softDeleteDesignMaterial(req, res) {
  let connection;
  try {
    const { id } = req.body;
    connection = await getConnection();
    await connection.execute(
      `UPDATE design_materials 
       SET deleted_at = SYSDATE 
       WHERE id = :id AND deleted_at IS NULL`,
      { id },
      { autoCommit: true }
    );
    res.status(200).json({ message: "Design material marked as deleted successfully." });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  } finally {
    if (connection) await connection.close();
  }
}

// Get All Design Materials
async function getAllDesignMaterials() {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT id, design_id, material_id, qty 
       FROM design_materials 
       WHERE deleted_at IS NULL`
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching design materials", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Get Design Material by ID
async function getDesignMaterialById(id) {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT id, design_id, material_id, qty 
       FROM design_materials 
       WHERE id = :id AND deleted_at IS NULL`,
      { id }
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching design material by ID", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Get Design Material by Design ID
async function getDesignMaterialByDesignId(designId) {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT id, design_id, material_id, qty 
       FROM design_materials 
       WHERE design_id = :designId AND deleted_at IS NULL`,
      { designId }
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching design material by design ID", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Get Design Material by Material ID
async function getDesignMaterialByMaterialId(materialId) {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT id, design_id, material_id, qty 
       FROM design_materials 
       WHERE material_id = :materialId AND deleted_at IS NULL`,
      { materialId }
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching design material by design ID", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Insert Production
async function insertProduction(designId, expectedQty, status, productionSize) {
  let connection;
  try {
    connection = await getConnection();
    const query = `
      INSERT INTO production (design_id, expected_qty, status, production_size, created_at)
      VALUES (:designId, :expectedQty, :status, :productionSize, SYSDATE)
    `;
    await connection.execute(query, { designId, expectedQty, status, productionSize }, { autoCommit: true });
    console.log("Production added successfully.");
  } catch (error) {
    console.error("Error inserting production:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Update Production
async function updateProduction(req, res) {
  let connection;
  try {
    const { id, designId, expectedQty, actualQty, status, productionSize } = req.body;
    
    connection = await getConnection();
    
    let query = 'UPDATE production SET ';
    const binds = { id };

    if (designId) {
      query += 'design_id = :designId';
      binds.designId = designId;
    }

    if (expectedQty) {
      if (designId) query += ', ';
      query += 'expected_qty = :expectedQty';
      binds.expectedQty = expectedQty;
    }

    if (actualQty) {
      if (designId || expectedQty) query += ', ';
      query += 'actual_qty = :actualQty';
      binds.actualQty = actualQty;
    }

    if (status) {
      if (designId || expectedQty || actualQty) query += ', ';
      query += 'status = :status';
      binds.status = status;
    }

    if (productionSize) {
      if (designId || expectedQty || actualQty || status) query += ', ';
      query += 'production_size = :productionSize';
      binds.productionSize = productionSize;
    }

    query += ' WHERE id = :id';

    await connection.execute(query, binds, { autoCommit: true });
    res.status(200).json({ message: "Production updated successfully." });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  } finally {
    if (connection) await connection.close();
  }
}

// Soft Delete Production
async function softDeleteProduction(req, res) {
  let connection;
  try {
    const { id } = req.body;
    connection = await getConnection();
    await connection.execute(
      `UPDATE production 
       SET deleted_at = SYSDATE 
       WHERE id = :id AND deleted_at IS NULL`,
      { id },
      { autoCommit: true }
    );
    res.status(200).json({ message: "Production marked as deleted successfully." });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  } finally {
    if (connection) await connection.close();
  }
}

// Get All Productions
async function getAllProductions() {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT id, design_id, expected_qty, actual_qty, PRODUCTION_SIZE, status 
       FROM production 
       WHERE deleted_at IS NULL`
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching productions", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Get Production by ID
async function getProductionById(id) {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT id, design_id, expected_qty, actual_qty, PRODUCTION_SIZE, status 
       FROM production 
       WHERE id = :id AND deleted_at IS NULL`,
      { id }
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching production by ID", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Get Production by Design ID
async function getProductionByDesignId(designId) {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT id, design_id, expected_qty, actual_qty, PRODUCTION_SIZE, status 
       FROM production 
       WHERE design_id = :designId AND deleted_at IS NULL`,
      { designId }
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching production by design ID", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Update Production Status
async function updateProductionStatus(req, res) {
  let connection;
  try {
    const { id, actualQty } = req.body;
    connection = await getConnection();
    
    await connection.execute(
      `BEGIN
      update_production_status (:id, :actualQty);
      END;`,
      { id, actualQty },
      { autoCommit: true }
    );
    res.status(200).json({ message: "Production status updated successfully." });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  } finally {
    if (connection) await connection.close();
  }
}

// Insert Product
async function insertProduct(product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price) {
  let connection;
  try {
    connection = await getConnection();
    const query = `
      INSERT INTO products (product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price)
      VALUES (:product_name, :product_description, :product_category, :product_size, :product_gender, :product_image, :stok_qty, :price)
    `;
    await connection.execute(query, {
      product_name,
      product_description,
      product_category,
      product_size,
      product_gender,
      product_image,
      stok_qty,
      price
    }, { autoCommit: true });
    console.log("Product added successfully.");
  } catch (error) {
    console.error("Error inserting product:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Update Product
async function updateProduct(req, res) {
  let connection;
  try {
    const { product_id, product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price } = req.body;
    console.log(req.body);
    
    connection = await getConnection();
    
    let query = 'UPDATE products SET ';
    const binds = { product_id };

    if (product_name) {
      query += 'product_name = :product_name';
      binds.product_name = product_name;
    }

    if (product_description) {
      if (product_name) query += ', ';
      query += 'product_description = :product_description';
      binds.product_description = product_description;
    }

    if (product_category) {
      if (product_name || product_description) query += ', ';
      query += 'product_category = :product_category';
      binds.product_category = product_category;
    }

    if (product_size) {
      if (product_name || product_description || product_category) query += ', ';
      query += 'product_size = :product_size';
      binds.product_size = product_size;
    }

    if (product_gender) {
      if (product_name || product_description || product_category || product_size) query += ', ';
      query += 'product_gender = :product_gender';
      binds.product_gender = product_gender;
    }

    if (product_image) {
      if (product_name || product_description || product_category || product_size || product_gender) query += ', ';
      query += 'product_image = :product_image';
      binds.product_image = product_image;
    }

    if (stok_qty) {
      if (product_name || product_description || product_category || product_size || product_gender || product_image) query += ', ';
      query += 'stok_qty = :stok_qty';
      binds.stok_qty = stok_qty;
    }

    if (price) {
      if (product_name || product_description || product_category || product_size || product_gender || product_image || stok_qty) query += ', ';
      query += 'price = :price';
      binds.price = price;
    }

    query += ', last_update = SYSDATE WHERE product_id = :product_id';

    await connection.execute(query, binds, { autoCommit: true });
    res.status(200).json({ message: "Product updated successfully." });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  } finally {
    if (connection) await connection.close();
  }
}

// Soft Delete Product
async function softDeleteProduct(req, res) {
  let connection;
  try {
    const { product_id } = req.body;
    connection = await getConnection();
    await connection.execute(
      `UPDATE products 
       SET deleted_at = SYSDATE 
       WHERE product_id = :product_id AND deleted_at IS NULL`,
      { product_id },
      { autoCommit: true }
    );
    res.status(200).json({ message: "Product marked as deleted successfully." });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  } finally {
    if (connection) await connection.close();
  }
}

// Get All Products
async function getAllProducts() {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT product_id, product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price 
       FROM products 
       WHERE deleted_at IS NULL`
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching products", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Get Product by ID
async function getProductById(id) {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT product_id, product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price 
       FROM products 
       WHERE product_id = :id AND deleted_at IS NULL`,
      { id }
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching product by ID", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Get Product by Name
async function getProductByName(name) {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT product_id, product_name, product_description, product_category, product_size, product_gender, product_image, stok_qty, price 
       FROM products 
       WHERE LOWER(product_name) LIKE LOWER(:name) AND deleted_at IS NULL`,
      [`%${name}%`]
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching product by name", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Insert Raw Material
async function insertRawMaterial(name, stokQty) {
  let connection;
  try {
    connection = await getConnection();
    const query = `
      INSERT INTO raw_materials (name, stok_qty, last_update)
      VALUES (:name, :stokQty, SYSDATE)
    `;
    await connection.execute(query, { name, stokQty }, { autoCommit: true });
    console.log("Raw material added successfully.");
  } catch (error) {
    console.error("Error inserting raw material:", error.message);
    throw error;
  } finally {
    if (connection) await connection.close();
  }
}

// Update Raw Material
async function updateRawMaterial(req, res) {
  let connection;
  try {
    const { id, name, stokQty } = req.body;
    connection = await getConnection();
    
    let query = 'UPDATE raw_materials SET ';
    const binds = { id };

    if (name) {
      query += 'name = :name';
      binds.name = name;
    }

    if (stokQty) {
      if (name) query += ', ';
      query += 'stok_qty = :stokQty';
      binds.stokQty = stokQty;
    }

    query += ', last_update = SYSDATE WHERE id = :id';

    await connection.execute(query, binds, { autoCommit: true });
    res.status(200).json({ message: "Raw material updated successfully." });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  } finally {
    if (connection) await connection.close();
  }
}

// Soft Delete Raw Material
async function softDeleteRawMaterial(req, res) {
  let connection;
  try {
    const { id } = req.body;
    connection = await getConnection();
    await connection.execute(
      `UPDATE raw_materials 
       SET deleted_at = SYSDATE 
       WHERE id = :id AND deleted_at IS NULL`,
      { id },
      { autoCommit: true }
    );
    res.status(200).json({ message: "Raw material marked as deleted successfully." });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  } finally {
    if (connection) await connection.close();
  }
}

// Get All Raw Materials
async function getAllRawMaterials() {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT id, name, stok_qty, last_update 
       FROM raw_materials 
       WHERE deleted_at IS NULL`
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching raw materials", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Get Raw Material by ID
async function getRawMaterialById(id) {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT id, name, stok_qty, last_update 
       FROM raw_materials 
       WHERE id = :id AND deleted_at IS NULL`,
      { id }
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching raw material by ID", error);
    throw error;
  } finally {
    connection.close();
  }
}

// Get Raw Material by Name
async function getRawMaterialByName(name) {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT id, name, stok_qty, last_update 
       FROM raw_materials 
       WHERE LOWER(name) LIKE LOWER(:name) AND deleted_at IS NULL`,
      [`%${name}%`]
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching raw material by name", error);
    throw error;
  } finally {
    connection.close();
  }
}

const getAllLogs = async () => {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT LOG_ID, ACTION_TYPE, TABLE_NAME, ACTION_DETAILS, ACTION_TIME, ACTION_USER 
       FROM LOG_RND`
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching logs", error);
    throw error;
  } finally {
    connection.close();
  }
};

const getLogById = async (id) => {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT LOG_ID, ACTION_TYPE, TABLE_NAME, ACTION_DETAILS, ACTION_TIME, ACTION_USER 
       FROM LOG_RND 
       WHERE LOG_ID = :id`,
      { id }
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching log by ID", error);
    throw error;
  } finally {
    connection.close();
  }
};

const getLogsByActionType = async (type) => {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT LOG_ID, ACTION_TYPE, TABLE_NAME, ACTION_DETAILS, ACTION_TIME, ACTION_USER 
       FROM LOG_RND 
       WHERE ACTION_TYPE = :type`,
      { type }
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching logs by action type", error);
    throw error;
  } finally {
    connection.close();
  }
};

const getLogsByTableName = async (name) => {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT LOG_ID, ACTION_TYPE, TABLE_NAME, ACTION_DETAILS, ACTION_TIME, ACTION_USER 
       FROM LOG_RND 
       WHERE LOWER(TABLE_NAME) = LOWER(:name)`,
      { name }
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching logs by table name", error);
    throw error;
  } finally {
    connection.close();
  }
};

const getLogsByActionTime = async (time) => {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT LOG_ID, ACTION_TYPE, TABLE_NAME, ACTION_DETAILS, ACTION_TIME, ACTION_USER 
       FROM LOG_RND 
       WHERE TRUNC(ACTION_TIME) = TO_DATE(:time, 'DD-MM-YYYY')`,
      { time }
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching logs by action time", error);
    throw error;
  } finally {
    connection.close();
  }
};

const getLogsByActionUser = async (username) => {
  const connection = await getConnection();
  try {
    const result = await connection.execute(
      `SELECT LOG_ID, ACTION_TYPE, TABLE_NAME, ACTION_DETAILS, ACTION_TIME, ACTION_USER 
       FROM LOG_RND 
       WHERE LOWER(ACTION_USER) = LOWER(:username)`,
      { username }
    );
    return result.rows;
  } catch (error) {
    console.error("Error fetching logs by action user", error);
    throw error;
  } finally {
    connection.close();
  }
};

module.exports = {
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
  getLogsByActionUser
};
