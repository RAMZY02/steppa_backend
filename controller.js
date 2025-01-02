const oracledb = require('oracledb');

// Aktifkan Thick Mode
oracledb.initOracleClient({ libDir: 'D:/instantclient_23_6' });

async function getConnection() {
    try {
        return await oracledb.getConnection({
            user: 'rama',
            password: 'rama',
            connectString: 'localhost:1521/steppa_rnd',
        });
    } catch (err) {
        console.error('Error saat koneksi:', err);
        throw err;
    }
}

// Fungsi untuk mendapatkan data desain
async function getDesignData(req, res) {
    let connection;
    try {
        connection = await getConnection();
        // Ganti query di bawah ini dengan query yang relevan untuk data desain
        const result = await connection.execute('SELECT * FROM design');
        res.json(result.rows); // Kirimkan data desain dalam format JSON
    } catch (err) {
        console.error('Error saat query:', err);
        res.status(500).send('Terjadi kesalahan saat mengambil data desain');
    } finally {
        if (connection) {
            await connection.close();
        }
    }
}

// Fungsi untuk mendapatkan data produk
async function getProductData(req, res) {
    let connection;
    try {
        connection = await getConnection();
        const result = await connection.execute('SELECT * FROM products');
        res.json(result.rows); // Kirimkan data produk dalam format JSON
    } catch (err) {
        console.error('Error saat query:', err);
        res.status(500).send('Terjadi kesalahan saat mengambil data produk');
    } finally {
        if (connection) {
            await connection.close();
        }
    }
}

module.exports = { getDesignData, getProductData };
