const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();

app.use(cors());
app.use(express.json());

// Importa el controlador de la API que contiene múltiples endpoints
const apiController = require('./negocios/controller');

app.get('/ping', (req, res) => {
    res.json({ message: 'pong' });
  });
  
app.use('/', apiController);

app.use(express.static('frontend'));

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => console.log(`Servidor corriendo en http://0.0.0.0:${PORT}`));
