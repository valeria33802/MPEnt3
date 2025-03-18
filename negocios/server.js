const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const apiController = require('./python_api/apicontroller');

app.use(cors());
app.use(express.json());


app.use('/api', apiController);


app.use(express.static('frontend'));

const PORT = process.env.PORT || 3300;
app.listen(PORT, () => console.log(`Servidor corriendo en http://localhost:${PORT}`));


