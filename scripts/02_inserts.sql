
USE modp;


INSERT INTO pais (id, nombre) VALUES 
    (1, 'Costa Rica'),
    (2, 'República Dominicana'),
    (3, 'Argentina');


INSERT INTO provincia (id, nombre, pais_id) VALUES
    -- Costa Rica
    (1, 'San José', 1),
    (2, 'Cartago', 1),
    (3, 'Heredia', 1),
    -- República Dominicana
    (4, 'Distrito Nacional', 2),
    (5, 'Santiago', 2),
    (6, 'La Vega', 2),
    (7, 'Puerto Plata', 2),
    -- Argentina
    (8, 'Buenos Aires', 3),
    (9, 'Córdoba', 3),
    (10, 'Mendoza', 3),
    (11, 'Santa Fe', 3);


INSERT INTO cantones (id, nombre, provincia_id) VALUES
    -- Costa Rica - Provincia San José
    (1, 'Escazú', 1),
    (2, 'Desamparados', 1),
    (3, 'Tibás', 1),
    (4, 'Moravia', 1),
    -- Costa Rica - Provincia Cartago
    (5, 'Cartago', 2),
    (6, 'Paraíso', 2),
    (7, 'La Unión', 2),
    (8, 'Turrialba', 2),
    -- Costa Rica - Provincia Heredia
    (9, 'Barva', 3),
    (10, 'Santo Domingo', 3),
    (11, 'San Rafael', 3),
    (12, 'San Isidro', 3),
    -- República Dominicana
    (13, 'Santo Domingo', 4),  -- para los barrios de Santo Domingo (Distrito Nacional)
    (14, 'Santiago', 5),
    (15, 'La Vega', 6),
    (16, 'Puerto Plata', 7),
    -- Argentina
    (17, 'Buenos Aires', 8),
    (18, 'Córdoba', 9),
    (19, 'Mendoza', 10),
    (20, 'Santa Fe', 11);


INSERT INTO distritos (id, nombre, canton_id) VALUES
    -- Provincia San José
    (1, 'Escazú', 1),
    (2, 'Desamparados', 2),
    (3, 'San Juan', 3),
    (4, 'San Vicente', 4),
    -- Provincia Cartago
    (5, 'Oriental', 5),
    (6, 'Paraíso', 6),
    (7, 'Tres Ríos', 7),
    (8, 'Turrialba', 8),
    -- Provincia Heredia
    (9, 'Barva', 9),
    (10, 'Santo Domingo', 10),
    (11, 'San Rafael', 11),
    (12, 'San Isidro', 12);


INSERT INTO distritos (id, nombre, canton_id) VALUES
    -- Cantón Santo Domingo (Distrito Nacional)
    (13, 'Los Mina', 13),
    (14, 'Alma Rosa', 13),
    (15, 'Ensanche Ozama', 13),
    (16, 'Villa Faro', 13),
    -- Cantón Santiago
    (17, 'Centro Histórico', 14),
    (18, 'Gurabito', 14),
    (19, 'Pekín', 14),
    (20, 'Los Jardines', 14),
    -- Cantón La Vega
    (21, 'Villa Rosa', 15),
    (22, 'Palmarito', 15),
    (23, 'El Pontón', 15),
    (24, 'Las Carmelitas', 15),
    -- Cantón Puerto Plata
    (25, 'Centro', 16),
    (26, 'Ensanche Miramar', 16),
    (27, 'Costámbar', 16),
    (28, 'Cofresí', 16);


INSERT INTO distritos (id, nombre, canton_id) VALUES
    -- Cantón Buenos Aires
    (29, 'Centro', 17),
    (30, 'Tolosa', 17),
    (31, 'City Bell', 17),
    (32, 'Gonnet', 17),
    -- Cantón Córdoba
    (33, 'Nueva Córdoba', 18),
    (34, 'Centro', 18),
    (35, 'Alberdi', 18),
    (36, 'General Paz', 18),
    -- Cantón Mendoza
    (37, 'Centro', 19),
    (38, 'Cuarta Sección', 19),
    (39, 'La Favorita', 19),
    (40, 'Sexta Sección', 19),
    -- Cantón Santa Fe
    (41, 'Centro', 20),
    (42, 'Barrio Candioti', 20),
    (43, 'Barranquitas', 20),
    (44, 'Guadalupe', 20);


INSERT INTO Catalogo_Tipos (ID_Tipo, CATI_Nombre) VALUES
    ('TE', 'Teclado'),
    ('MI', 'Microfono'),
    ('RA', 'Raton'),
    ('PA', 'Parlante'),
    ('CA', 'Camara Web');


-- TECLADOS
INSERT INTO Catalogo (ID_Articulo, CAT_Tipo, CAT_Nombre, CATI_Descripcion, CATI_Cantidad, CATI_Venta, CATI_Precio) VALUES
    ('TE001', 'TE', 'Keychron Q1', 'Teclado personalizable de 75% con chasis de aluminio, hot-swap y opciones QMK/VIA.', 10, 5, 150 * 505.82),
    ('TE002', 'TE', 'GMMK Pro', 'Teclado popular de 75% con chasis de aluminio, hot-swap y software para retroiluminación.', 8, 3, 170 * 505.82),
    ('TE003', 'TE', 'Drop CTRL', 'Teclado tenkeyless de aluminio con retroiluminación RGB y firmware configurable.', 5, 2, 250 * 505.82),
    ('TE004', 'TE', 'Drop ALT', 'Teclado 65% de aluminio, hot-swap y personalización QMK, compacto y elegante.', 7, 4, 230 * 505.82),
    ('TE005', 'TE', 'Anne Pro 2', 'Teclado 60% portátil con conectividad Bluetooth y opciones de personalización.', 12, 6, 100 * 505.82),
    ('TE006', 'TE', 'KBD67 Lite', 'Teclado 65% con carcasa de plástico, hot-swap y estabilizadores de buena calidad.', 9, 4, 130 * 505.82),
    ('TE007', 'TE', 'Rama Works M65-B', 'Teclado premium de 65% con chasis de aluminio macizo y acabado de alta calidad.', 3, 1, 500 * 505.82),
    ('TE008', 'TE', 'Ducky One 2 Mini', 'Teclado 60% gamer con excelente retroiluminación RGB y gran durabilidad.', 15, 7, 120 * 505.82),
    ('TE009', 'TE', 'Keychron K6', 'Teclado inalámbrico 65% con hot-swap y compatibilidad con macOS y Windows.', 10, 5, 90 * 505.82),
    ('TE010', 'TE', 'Niz Plum Atom 68', 'Teclado 65% con switches capacitivos que ofrecen una pulsación suave.', 6, 3, 150 * 505.82),
    ('TE011', 'TE', 'GK64', 'Teclado 60% compacto con flechas integradas, hot-swap y precio económico.', 20, 10, 80 * 505.82),
    ('TE012', 'TE', 'KBDFans D65', 'Teclado premium de 65% con construcción en aluminio/policarbonato y compatibilidad QMK.', 4, 2, 250 * 505.82),
    ('TE013', 'TE', 'Leopold FC750R', 'Teclado tenkeyless clásico con keycaps PBT de alta calidad, no hot-swap.', 8, 4, 130 * 505.82),
    ('TE014', 'TE', 'Hexgears Nova', 'Teclado TKL o 60% con hot-swap y retroiluminación RGB en diseño moderno.', 10, 5, 100 * 505.82),
    ('TE015', 'TE', 'Durgod Taurus K320', 'Teclado TKL robusto, compatible con múltiples interruptores Cherry MX y keycaps PBT.', 7, 3, 120 * 505.82),
    ('TE016', 'TE', 'Keydous NJ80', 'Teclado de 80% compacto con carcasa robusta y opción hot-swap para casi layout completo.', 5, 2, 200 * 505.82),
    ('TE017', 'TE', 'MelGeek Mojo68', 'Teclado 65% en policarbonato translúcido con firmware QMK/VIA y diseño moderno.', 6, 3, 230 * 505.82),
    ('TE018', 'TE', 'Akko 3068B Plus', 'Teclado inalámbrico de 65% con Bluetooth 5.0, USB-C y opción hot-swap.', 9, 4, 110 * 505.82);

-- MICRÓFONOS
INSERT INTO Catalogo (ID_Articulo, CAT_Tipo, CAT_Nombre, CATI_Descripcion, CATI_Cantidad, CATI_Venta, CATI_Precio) VALUES
    ('MI001', 'MI', 'Audio-Technica AT2020USB+', 'Micrófono condensador USB con patrón cardioide y monitoreo sin latencia.', 10, 5, 95 * 505.82),
    ('MI002', 'MI', 'Samson G-Track Pro', 'Micrófono USB profesional con interfaz integrada y múltiples patrones polares.', 8, 4, 209.71 * 505.82),
    ('MI003', 'MI', 'Blue Yeti', 'Micrófono USB versátil con múltiples patrones y controles integrados para sonido profesional.', 12, 6, 129 * 505.82),
    ('MI004', 'MI', 'Rode NT-USB', 'Micrófono condensador USB de alta calidad, con filtro anti-pop y soporte de escritorio.', 7, 3, 129 * 505.82),
    ('MI005', 'MI', 'HyperX SoloCast', 'Micrófono condensador USB compacto con sensor táctil para silenciar y patrón cardioide.', 15, 7, 29.37 * 505.82),
    ('MI006', 'MI', 'FIFINE AmpliGame A6T', 'Micrófono USB para gaming/streaming con brazo articulado, filtro anti-pop y botón de silencio.', 10, 5, 39.99 * 505.82),
    ('MI007', 'MI', 'TONOR', 'Micrófono condensador omnidireccional ideal para videoconferencias y grabaciones caseras.', 12, 6, 24.59 * 505.82);

-- RATONES
INSERT INTO Catalogo (ID_Articulo, CAT_Tipo, CAT_Nombre, CATI_Descripcion, CATI_Cantidad, CATI_Venta, CATI_Precio) VALUES
    ('RA001', 'RA', 'Logitech G502 Lightspeed', 'Ratón inalámbrico para juegos con sensor HERO 25K, pesos ajustables y LIGHTSYNC RGB.', 15, 7, 69.03 * 505.82),
    ('RA002', 'RA', 'Razer Basilisk V3', 'Ratón ergonómico con 11 botones programables, Chroma RGB y sensor óptico de 26K DPI.', 12, 6, 34.99 * 505.82),
    ('RA003', 'RA', 'Logitech G305 LIGHTSPEED', 'Ratón inalámbrico ligero con sensor HERO 12K, 6 botones y batería de hasta 250 horas.', 20, 10, 27.59 * 505.82),
    ('RA004', 'RA', 'Logitech G PRO X SUPERLIGHT', 'Ratón inalámbrico ultraligero con sensor HERO 25K y 5 botones programables, diseño minimalista.', 10, 5, 70.88 * 505.82),
    ('RA005', 'RA', 'Razer Naga V2 Pro', 'Ratón MMO inalámbrico con placas laterales intercambiables y sensor Focus+ de 20K DPI.', 8, 4, 157.23 * 505.82),
    ('RA006', 'RA', 'Corsair Dark Core RGB Pro SE', 'Ratón inalámbrico con respuesta en <1 ms, 9 botones programables e iluminación RGB personalizable.', 10, 5, 89.99 * 505.82),
    ('RA007', 'RA', 'Redragon M908 Impact RGB', 'Ratón con cable para MMO, 12 botones laterales programables, sensor hasta 12.4K DPI e iluminación RGB.', 12, 6, 32.56 * 505.82),
    ('RA008', 'RA', 'Logitech G502 X Plus', 'Ratón inalámbrico con interruptores híbridos LIGHTFORCE, sensor HERO 25K y LIGHTSYNC RGB.', 9, 4, 106.61 * 505.82),
    ('RA009', 'RA', 'Razer Viper V3 Pro', 'Ratón inalámbrico para eSports con sensor óptico de 35K DPI y hasta 95 horas de batería.', 11, 5, 108.30 * 505.82),
    ('RA010', 'RA', 'Redragon M913 Impact Elite', 'Ratón inalámbrico MMO con 16 botones, sensor de 16K DPI y retroiluminación RGB.', 10, 5, 46.52 * 505.82);

-- PARLANTES
INSERT INTO Catalogo (ID_Articulo, CAT_Tipo, CAT_Nombre, CATI_Descripcion, CATI_Cantidad, CATI_Venta, CATI_Precio) VALUES
    ('PA001', 'PA', 'Creative Pebble X Plus 2.1', 'Altavoces 2.1 con 30W, iluminación RGB, USB-C, Bluetooth 5.3 y entrada AUX.', 8, 4, 119.99 * 505.82),
    ('PA002', 'PA', 'Creative Pebble X 2.0', 'Altavoces 2.0 compactos con drivers de 2.75" y 15W RMS, con USB-C, Bluetooth 5.3 y entrada AUX.', 10, 5, 79.99 * 505.82),
    ('PA003', 'PA', 'Razer Nommo V2 Pro', 'Sistema de altavoces gaming con dos altavoces de 3" y un subwoofer de 5.5", controlado vía Synapse.', 5, 2, 449.99 * 505.82),
    ('PA004', 'PA', 'Logitech G560 LIGHTSYNC', 'Altavoces 2.1 para gamers con 240W, RGB sincronizado y conectividad Bluetooth, USB y AUX.', 7, 3, 199.99 * 505.82);

-- CÁMARAS WEB
INSERT INTO Catalogo (ID_Articulo, CAT_Tipo, CAT_Nombre, CATI_Descripcion, CATI_Cantidad, CATI_Venta, CATI_Precio) VALUES
    ('CA001', 'CA', 'Creative Pebble X Plus 2.1', 'Cámara web: Sistema 2.1 con 30W, RGB, USB-C, Bluetooth 5.3 y entrada AUX.', 5, 2, 119.99 * 505.82),
    ('CA002', 'CA', 'Creative Pebble X 2.0', 'Cámara web: Diseño compacto 2.0 con drivers de 2.75" y 15W RMS, USB-C, Bluetooth y AUX.', 6, 3, 79.99 * 505.82),
    ('CA003', 'CA', 'Razer Nommo V2 Pro', 'Cámara web: Sistema con dos altavoces de 3" y subwoofer de 5.5", en oferta a $294 USD.', 4, 2, 294 * 505.82),
    ('CA004', 'CA', 'Logitech G560 LIGHTSYNC', 'Cámara web: Sistema 2.1 con 240W, RGB sincronizado y conectividad Bluetooth, USB y AUX.', 5, 2, 199.99 * 505.82);


INSERT INTO ServicioPorProducto (ID_Servicio, SE_Descripcion, Precio, CAT_Tipo) VALUES
    ('TESE1', 'Keycaps - Material ABS, PBT, POM', 10000, 'TE'),
    ('TESE2', 'Keycaps - Legends personalizadas', 20000, 'TE'),
    ('TESE3', 'Keycaps - Shine-through', 15000, 'TE'),
    ('TESE4', 'Carcasa - Material personalizado', 20000, 'TE'),
    ('TESE5', 'Carcasa - Color y acabado', 10000, 'TE'),
    ('TESE6', 'Carcasa - Diseño personalizado', 15000, 'TE'),
    ('TESE7', 'Switches - Colores personalizados', 5000, 'TE'),
    ('TESE8', 'Switches - Lubricación y films', 5000, 'TE'),
    ('TESE9', 'Switches - Stickers', 2000, 'TE'),
    ('TESE10', 'Retroiluminación - Per-key RGB', 15000, 'TE'),
    ('TESE11', 'Retroiluminación - Diodos de colores', 5000, 'TE'),
    ('TESE12', 'Retroiluminación - Underglow', 10000, 'TE'),
    ('TESE13', 'Cable - Material trenzado o paracord', 5000, 'TE'),
    ('TESE14', 'Cable - Forma en espiral', 5000, 'TE'),
    ('TESE15', 'Plate - Material de aluminio, acero', 10000, 'TE'),
    ('TESE16', 'PCB - Colores personalizados', 15000, 'TE'),
    ('TESE17', 'PCB - LEDs adicionales', 5000, 'TE'),
    ('TESE18', 'Estabilizadores - Color de housings', 5000, 'TE'),
    ('TESE19', 'Estabilizadores - Cable modificado', 2000, 'TE'),
    ('TESE20', 'Espuma - Reducción de sonido', 5000, 'TE'),
    ('TESE21', 'Dampers - Set de amortiguadores', 2000, 'TE'),
    ('TESE22', 'Accesorios - Reposamuñecas', 10000, 'TE'),
    ('TESE23', 'Accesorios - Artisan Keycaps', 5000, 'TE'),
    ('TESE24', 'Accesorios - Stickers o skins', 1000, 'TE'),
    ('TESE25', 'Accesorios - Feet del teclado', 2000, 'TE');

-- Servicios para Ratón (RASE)
INSERT INTO ServicioPorProducto (ID_Servicio, SE_Descripcion, Precio, CAT_Tipo) VALUES
    ('RASE1', 'Carcasa - Colores personalizados', 5000, 'RA'),
    ('RASE2', 'Carcasa - Materiales modificados', 10000, 'RA'),
    ('RASE3', 'Carcasa - Diseños temáticos', 5000, 'RA'),
    ('RASE4', 'Carcasa - Texturas personalizadas', 5000, 'RA'),
    ('RASE5', 'Botones - Colores y materiales', 2000, 'RA'),
    ('RASE6', 'Botones - Superficie personalizada', 2000, 'RA'),
    ('RASE7', 'Iluminación - Efectos RGB personalizados', 5000, 'RA'),
    ('RASE8', 'Iluminación - Modding LED', 5000, 'RA'),
    ('RASE9', 'Scroll - Material personalizado', 2000, 'RA'),
    ('RASE10', 'Scroll - Color y diseño', 2000, 'RA'),
    ('RASE11', 'Cable - Material trenzado o paracord', 5000, 'RA'),
    ('RASE12', 'Cable - Forma en espiral', 5000, 'RA'),
    ('RASE13', 'Patines - Material personalizado', 2000, 'RA'),
    ('RASE14', 'Peso - Modificación de peso', 5000, 'RA'),
    ('RASE15', 'Base - Iluminación underglow', 5000, 'RA'),
    ('RASE16', 'Logo - Stickers o vinilos', 1000, 'RA'),
    ('RASE17', 'Logo - Grabado láser', 5000, 'RA'),
    ('RASE18', 'Accesorios - Grip tapes', 2000, 'RA'),
    ('RASE19', 'Accesorios - Reposamuñecas', 5000, 'RA');

-- Servicios para Micrófonos (MISE)
INSERT INTO ServicioPorProducto (ID_Servicio, SE_Descripcion, Precio, CAT_Tipo) VALUES
    ('MISE1', 'Filtro anti-pop personalizado', 5000, 'MI'),
    ('MISE2', 'Soporte de escritorio mejorado', 10000, 'MI'),
    ('MISE3', 'Brazo articulado premium', 20000, 'MI'),
    ('MISE4', 'Atenuador de ruido', 15000, 'MI'),
    ('MISE5', 'Iluminación LED en micrófono', 5000, 'MI');

-- Servicios para Parlantes (PASE)
INSERT INTO ServicioPorProducto (ID_Servicio, SE_Descripcion, Precio, CAT_Tipo) VALUES
    ('PASE1', 'Modificación de bass boost', 10000, 'PA'),
    ('PASE2', 'Ajuste de ecualización personalizada', 15000, 'PA'),
    ('PASE3', 'Carcasa de parlante personalizada', 20000, 'PA'),
    ('PASE4', 'Iluminación RGB en parlantes', 5000, 'PA');

-- Servicios para Cámara Web (CASE)
INSERT INTO ServicioPorProducto (ID_Servicio, SE_Descripcion, Precio, CAT_Tipo) VALUES
    ('CASE1', 'Funda protectora personalizada', 5000, 'CA'),
    ('CASE2', 'Mejora de resolución a 4K', 20000, 'CA'),
    ('CASE3', 'Lente intercambiable', 25000, 'CA'),
    ('CASE4', 'Iluminación integrada', 10000, 'CA');


INSERT INTO Usuarios (ID_Usuario, US_Nombre_Usuario, US_Correo, US_Contrasenia, US_Puesto, US_Estado) VALUES
    -- Empleados
    (1, 'EMPa9B2cD', 'alejandro.morales@modp.co.cr', AES_ENCRYPT('Pass@123','clave_secreta'), 'Empleado', 'A'),
    (2, 'EMPf3G8hI', 'valentina.rivas@modp.co.cr', AES_ENCRYPT('Pass@123','clave_secreta'), 'Empleado', 'I'),
    (3, 'EMPl6K7mN', 'diego.pacheco@modp.co.cr', AES_ENCRYPT('Pass@123','clave_secreta'), 'Empleado', 'I'),
    (4, 'ADMz4Q7wX', 'santiago.jimenez@modp.co.cr', AES_ENCRYPT('Pass@123','clave_secreta'), 'Admin', 'A'),
    (5, 'ADMp5R2yT', 'camila.vega@modp.co.cr', AES_ENCRYPT('Pass@123','clave_secreta'), 'Admin', 'A'),
    -- Compradores
    (6, 'TrNt9V3sR', 'juan.perez@example.com', AES_ENCRYPT('A1b2C3d4E5!@#%','clave_secreta'), 'Compra', 'A'),
    (7, 'LpJu8L2kP', 'maria.gonzalez@example.com', AES_ENCRYPT('B2c3D4e5F6#@!$','clave_secreta'), 'Compra', 'A'),
    (8, 'Ssxr5D4mW', 'carlo.martinez@example.com', AES_ENCRYPT('X9y8Z7w6V5!@#$','clave_secreta'), 'Compra', 'A'),
    (9, 'pcSn1S7qZ', 'luis.rodriguez@example.com', AES_ENCRYPT('M3n4O5p6Q7%&*()','clave_secreta'), 'Compra', 'A'),
    (10, 'Yubo3F6jU', 'ana.perez@example.com', AES_ENCRYPT('Z8x7C6v5B4!@#QW','clave_secreta'), 'Compra', 'A');


INSERT INTO Horarios (ID_Horario, H_Hora_inicio, H_Hora_salida, H_Descripcion) VALUES
    (1, '08:00:00', '16:00:00', 'Turno matutino'),
    (2, '09:00:00', '17:00:00', 'Turno estándar'),
    (3, '10:00:00', '18:00:00', 'Inicio tardío'),
    (4, '07:00:00', '15:00:00', 'Turno temprano'),
    (5, '12:00:00', '20:00:00', 'Turno vespertino');


INSERT INTO Compradores (ID_Comprador, COM_Nombre, COM_Apellido, COM_Direccion, COM_Pais, COM_Provincia, COM_Canton, COM_Distrito)
VALUES
    (1, 'Juan', 'Perez', 'Calle 123, San José', 1, 1, 1, 1),
    (2, 'Maria', 'Gonzalez', 'Av. Central 456, Desamparados', 1, 1, 2, 2),
    (3, 'Carlo', 'Martinez', 'Calle Luna, Santo Domingo', 2, 4, 13, 13),
    (4, 'Luis', 'Rodriguez', 'Calle Falsa 789, Buenos Aires', 3, 8, 17, 29),
    (5, 'Ana', 'Perez', 'Av. Libertad 321, Córdoba', 3, 9, 18, 33);


INSERT INTO Empleados (EMP_ID, EMP_ID_Horario, EMP_Nombre, EMP_Apellido) VALUES
    (1, 1, 'Alejandro', 'Morales'),
    (2, 2, 'Valentina', 'Rivas'),
    (3, 3, 'Diego', 'Pacheco'),
    (4, 4, 'Santiago', 'Jiménez'),
    (5, 5, 'Camila', 'Vega');


INSERT INTO Tarjetas (ID_Tarjeta, ID_Comprador, TAR_Nombre, TAR_Num_Tarjeta, TAR_Fecha_Vencimiento, TAR_Codigo_Seguridad, TAR_Saldo) VALUES
    (1, 6, 'Miguel Soto', AES_ENCRYPT('4532556789012345','clave_secreta'), '2027-06-15', AES_ENCRYPT('123','clave_secreta'), 500000),
    (2, 7, 'Laura Guzmán', AES_ENCRYPT('5500550055005500','clave_secreta'), '2026-11-30', AES_ENCRYPT('456','clave_secreta'), 300000),
    (3, 8, 'Ricardo Molina', AES_ENCRYPT('4024007101234567','clave_secreta'), '2028-03-10', AES_ENCRYPT('789','clave_secreta'), 450000),
    (4, 9, 'Isabella Fuentes', AES_ENCRYPT('6011000990139424','clave_secreta'), '2029-08-20', AES_ENCRYPT('321','clave_secreta'), 600000),
    (5, 10, 'Jorge Cabrera', AES_ENCRYPT('3566002020202020','clave_secreta'), '2027-12-05', AES_ENCRYPT('654','clave_secreta'), 350000);


INSERT INTO FAQ (ID_Preguntas, F_Pregunta) VALUES
    (1, '¿Realizan entregas?'),
    (2, '¿Qué métodos de pago aceptan en línea?'),
    (3, '¿Ofrecen garantía en productos personalizados?'),
    (4, '¿Cuál es la política de devoluciones y reembolsos?');


INSERT INTO Comentarios (ID_Comentario, CO_Calificacion, Descripción) VALUES
    (1, '5', 'Servicio excelente y productos de alta calidad.'),
    (2, '4', 'Buena atención, pero se puede mejorar la rapidez en la entrega.'),
    (3, '3', 'La calidad es aceptable, aunque esperaba más opciones personalizadas.'),
    (4, '2', 'El producto llegó con leves desperfectos.'),
    (5, '1', 'Experiencia negativa, el pedido presentó múltiples inconvenientes.');


INSERT INTO Progreso_Proyecto (ID_Proyecto_Progreso, Descripcion, Detalles) VALUES
    (1, 'Planificación', 'Definiendo requerimientos y estableciendo metas.'),
    (2, 'Desarrollo', 'Implementación en curso con revisiones periódicas.'),
    (3, 'Pruebas', 'Realizando pruebas de calidad y ajustes finales.'),
    (4, 'Finalizado', 'Proyecto completado y entregado al cliente.');


INSERT INTO Proyectos (ID_Empleado, PRO_Progreso, ID_Articulo, ID_Comprador)
VALUES 
    (1, 1, 'TE001', 6),
    (2, 2, 'TE001', 7);


INSERT INTO Proyecto_Modificaciones (ID_Proyecto, ID_Servicio) VALUES
    (1, 'TESE2'),
    (2, 'TESE2');


INSERT INTO Feedback (ID_Feedback, FE_Estrellas, FE_Comentario) VALUES
    (1, 5, 'El proyecto superó mis expectativas.'),
    (2, 4, 'Buen desempeño, aunque hubo algunas demoras.'),
    (3, 3, 'Resultado satisfactorio con áreas de mejora.'),
    (4, 2, 'La calidad final no fue la esperada.'),
    (5, 1, 'Muy insatisfecho con el resultado final.');


INSERT INTO Factura_Detalle 
    (ID_Factura, ID_Proyecto, ID_Articulo, ID_Tarjeta, ID_Comprador, FD_Cantidad, FA_Fecha, FD_Precio, FD_Precio_Final, FA_Detalle)
VALUES 
    (3, 1, 'TE002', 1, 6, 1, '2025-08-01', 85000, 85000, 'Teclado personalizado - Modelo B');
