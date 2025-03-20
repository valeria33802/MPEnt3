const express = require('express');
const router = express.Router();
const servicios = require('./servicios'); //
const transporter = require('../frontend/confignodemailer');
const pool = require('../datos/configdb');
const speakeasy = require('speakeasy');

// Endpoint para login
router.post('/login', async (req, res) => {
    const { nombreusuario, contrasenia } = req.body;

    try {
        const resultado = await servicios.loginService(nombreusuario, contrasenia);

        if (resultado.length === 0) {
            return res.status(401).json({ error: 'Usuario no reconocido o contraseña incorrecta' });
        }

        const mensaje = resultado[0].Mensaje; // Mensaje del SP
        const posicion = resultado[0].Posicion; // Tipo de usuario

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

// Endpoint para insertar comprador
router.post('/insertarcomprador', async (req, res) => {
  try {
    const {nombreusuario, correo, contrasenia, pais, provincia, canton, distrito } = req.body;
    const response = await servicios.insertarCompradorService(nombreusuario, correo, contrasenia, pais, provincia, canton, distrito);
    res.json(response);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Endpoint para modificar comprador
router.put('/comprador/:id', async (req, res) => {
  try {
    // const id = req.params.id;
    const { ncorreo, ncontrasenia, nnombre, napellido, ndireccion } = req.body;
    const response = await servicios.modificarCompradorService(id, ncorreo, ncontrasenia, nnombre, napellido, ndireccion);
    res.json(response);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Endpoint para generar datos del cliente (por ejemplo, usando el ID)
router.get('/cliente/:id', async (req, res) => {
  try {
    const id = req.params.id;
    const response = await servicios.generarDatoClienteService(id);
    res.json(response);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Endpoint para insertar feedback
router.post('/feedback', async (req, res) => {
  try {
    const { calificacion, comentario } = req.body;
    const response = await servicios.insertFeedbackService(calificacion, comentario);
    res.json(response);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Endpoint para modificar empleado
router.put('/empleado/:id', async (req, res) => {
  try {
    const id = req.params.id;
    const { ncorreo, ncontrasenia, npuesto, nestado, nnombre, napellido, nhorario } = req.body;
    const response = await servicios.modificarEmpleadoService(id, ncorreo, ncontrasenia, npuesto, nestado, nnombre, napellido, nhorario);
    res.json(response);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Endpoint para insertar proyecto final
router.post('/proyecto', async (req, res) => {
  try {
    const { idarticulo, idcomprador, p_modificaciones } = req.body;
    const response = await servicios.insertProyectoFinalService(idarticulo, idcomprador, p_modificaciones);
    res.json(response);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Endpoint para sumar stock
router.put('/stock', async (req, res) => {
  try {
    const { id, incremento } = req.body;
    const response = await servicios.sumarStockService(id, incremento);
    res.json(response);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Endpoint para filtrar servicios
router.get('/servicios/:id', async (req, res) => {
  try {
    const id = req.params.id;
    const response = await servicios.filtrarServiciosService(id);
    res.json(response);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// // Endpoint para obtener periféricos (vista)
// router.get('/perifericos', async (req, res) => {
//   try {
//     const perifericos = await servicios.obtenerPerifericosService();
//     res.json(perifericos);
//   } catch (error) {
//     console.error('Error en /perifericos:', error);
//     res.status(500).json({ error: 'Error al obtener los periféricos' });
//   }
// });

router.get('/compradorlogin', async (req, res) => {
  try {
      const response = await servicios.obtenerCompradorLoginService();
      
      if (!response || response.length === 0) {
          return res.status(404).json({ error: 'No hay datos disponibles.' });
      }
      
      res.json(response);
  } catch (error) {
      console.error('Error en /compradorlogin:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// Endpoint para obtener información del comprador (vista)
router.get('/infocomprador', async (req, res) => {
  try {
    const response = await servicios.generar_info_compradorService();
    res.json(response);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Endpoint para obtener historial del comprador
router.get('/historialcomprador', async (req, res) => {
  try {
    const response = await servicios.historial_compra_ultimo_usuarioService();
    res.json(response);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// // Endpoint para obtener perifericos
// router.get('/perifericos', async (req, res) => {
//   try {
//     const perifericos = await servicios.obtenerPerifericosService();
//     res.json(perifericos);
//   } catch (error) {
//     console.error('Error en /perifericos:', error);
//     res.status(500).json({ error: 'Error al obtener los periféricos' });
//   }
// });

// Endpoint para obtener perifericos
router.get('/perifericos', async (req, res) => {
  try {
    const perifericos = await servicios.obtenerPerifericosService();
    res.json(perifericos);
  } catch (error) {
    console.error('Error en /perifericos:', error);
    res.status(500).json({ error: 'Error al obtener los periféricos' });
  }
});


// Endpoint para obtener faq
router.get('/faq', async (req, res) => {
  try {
    const perifericos = await servicios.vistaFAQService();
    res.json(perifericos);
  } catch (error) {
    console.error('Error en /faq:', error);
    res.status(500).json({ error: 'Error al obtener los periféricos' });
  }
});

// Endpoint para obtener perifericos
router.get('/calificaciones', async (req, res) => {
  try {
    const perifericos = await servicios.vistacalificacionesService();
    res.json(perifericos);
  } catch (error) {
    console.error('Error en /perifericos:', error);
    res.status(500).json({ error: 'Error al obtener los periféricos' });
  }
});


router.post('/insertarcodigo', async (req, res) => {
  try {
    const {codigo, tiempocreacion, tiempovencimiento } = req.body;
    const response = await servicios.sp_insert_codigoService(codigo, tiempocreacion, tiempovencimiento);
    res.json(response);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});


router.post('/cambiocontrasenia', async (req, res) => {
  try {
    const {npass} = req.body;
    const response = await servicios.sp_cambio_contraseniaService(npass);
    res.json(response);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get('/obtenercorreo', async (req, res) => {
  try {
    const perifericos = await servicios.sp_obtener_correo_usuarioService();
    res.json(perifericos);
  } catch (error) {
    console.error('Error en /perifericos:', error);
    res.status(500).json({ error: 'Error al obtener los periféricos' });
  }
});

// // Endpoint GET o POST, según prefieras
// router.get('/generarcodigo', async (req, res) => {
//   try {
//     // 1) Llamar a la función que genera el TOTP y lo inserta en BD
//     const token = await servicios.generarCodigoTOTP();

//     // 2) Responder con éxito
//     res.json({ success: true, codigo: token });
//   } catch (error) {
//     console.error('Error generando código:', error);
//     res.status(500).json({ success: false, error: error.message });
//   }
// });


//api para obtener correo del usuario

router.post('/enviar-codigo-recuperacion', async (req, res) => {
  try {
    // 1. Obtener el correo del último usuario logueado mediante SP
    const [rowsCorreo] = await pool.query('CALL sp_obtener_correo_usuario()');
    const emailUsuario = rowsCorreo[0] && rowsCorreo[0][0] && rowsCorreo[0][0].US_Correo;
    if (!emailUsuario) {
      return res.status(400).json({ success: false, error: 'No se encontró un correo para el último usuario logueado.' });
    }

    // 2. Generar el código. Usamos speakeasy para un TOTP de 6 dígitos.
    const secret = speakeasy.generateSecret({ length: 10 });
    const code = speakeasy.totp({
      secret: secret.base32,
      encoding: 'base32'
    });

    // 3. Calcular tiempos: ahora y vencimiento (+5 minutos)
    const ahora = new Date();
    const vence = new Date(ahora.getTime() + 5 * 60 * 1000);

    // 4. Insertar el código en la BD llamando al SP sp_insert_codigo
    await pool.query('CALL sp_insert_codigo(?, ?, ?)', [code, ahora, vence]);

    // 5. Enviar el código por correo (usando el transporter de nodemailer)
    const mailOptions = {
      from: '"MODP Soporte" <modp.noreply01@gmail.com>',
      to: emailUsuario,
      subject: 'Código de recuperación de contraseña',
      text: `Tu código de recuperación es: ${code}. Es válido por 5 minutos.`
    };

    await transporter.sendMail(mailOptions);

    // 6. Responder al frontend
    res.json({ success: true, message: 'Código enviado a tu correo.' });
  } catch (error) {
    console.error('Error en /enviar-codigo-recuperacion:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});


// api verificar el código
router.post('/verificar-codigo-cambiar-pass', async (req, res) => {
  try {
    const { codigo, nuevaPassword } = req.body;

    // 1) Buscar el código en la tabla "Codigo", ver si está activo, no vencido, etc.
    const [rows] = await pool.query(`
      SELECT *
      FROM Codigo
      WHERE codigo = ?
        AND estado = 'A'
        AND NOW() < tiempo_vencimiento
      ORDER BY tiempo_creacion DESC
      LIMIT 1
    `, [codigo]);

    if (!rows.length) {
      // Código no encontrado o expirado
      return res.json({ success: false, error: 'Código inválido o expirado.' });
    }

    // 2) Si es válido, llamamos al SP que cambia la contraseña en la tabla Usuarios
    await pool.query('CALL sp_cambio_contrasenia(?)', [nuevaPassword]);
    
    
    const codigoId = rows[0].id; 
    await pool.query(`
      UPDATE Codigo SET estado = 'U'
      WHERE id = ?
    `, [codigoId]);

    // 4) Responder éxito
    return res.json({ success: true });
  } catch (error) {
    console.error('Error en /verificar-codigo-cambiar-pass:', error);
    return res.json({ success: false, error: error.message });
  }
});

router.get('/ubicaciones', async (req, res) => {
  try {
    const ubicaciones = await servicios.obtenerUbicacionesService();
    // Si es necesario, parsea el resultado:
    // res.json({ success: true, ubicaciones: JSON.parse(ubicaciones) });
    res.json({ success: true, ubicaciones });
  } catch (error) {
    console.error('Error en /ubicaciones:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;
