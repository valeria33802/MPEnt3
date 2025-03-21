const express = require('express');
const router = express.Router();
const servicios = require('../servicios'); //
// const transporter = require('../frontend/confignodemailer');
// const pool = require('../datos/configdb');
// const speakeasy = require('speakeasy');

router.post('/', async (req, res) => {
    try {
      const { nombreusuario, contrasenia } = req.body;
      const resultado = await servicios.loginService(nombreusuario, contrasenia);
      if (!resultado || resultado.length === 0) {
        return res.status(401).json({ error: 'Usuario no reconocido o contraseña incorrecta' });
      }
      const mensaje = resultado[0].Mensaje;
      const posicion = resultado[0].Posicion;
      if (mensaje.includes('ha hecho sesión')) {
        res.json({ success: true, mensaje, posicion });
      } else {
        res.status(401).json({ success: false, mensaje });
      }
    } catch (error) {
      console.error('Error en login:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    }
  });
  
  module.exports = router;