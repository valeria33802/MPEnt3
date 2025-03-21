require('dotenv').config();
const mysql = require('mysql2/promise');

const pool = mysql.createPool({
    host: 'mysql', // ya que el contenedor MySQL se llama "mysql" en docker-compose
    user: 'root',  // Usar root ya que MYSQL_USER fue removido
    password: process.env.MYSQL_ROOT_PASSWORD,
    database: process.env.MYSQL_DATABASE,
    port: 3306,
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