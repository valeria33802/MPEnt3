const mysql = require('mysql2/promise');
require('dotenv').config(); // Esto carga las variables de entorno del .env

const pool = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT || 3306, 
    waitForConnections: true, 
    connectionLimit: 10,
    queueLimit: 0 
});




// Probar la conexión
(async () => {
    try {
        const connection = await pool.getConnection();
        console.log('Conectado a la base de datos MySQL');
        connection.release(); // Liberar conexión al pool
    } catch (error) {
        console.error('Error al conectar con la base de datos:', error);
    }
})();

module.exports = pool;