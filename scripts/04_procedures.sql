USE modp;

----------------------------------------
-- Procedimiento: spd_login
----------------------------------------
DROP PROCEDURE IF EXISTS spd_login;
DELIMITER //

CREATE PROCEDURE spd_login(
    IN p_usuario VARCHAR(50),
    IN p_contrasenia VARCHAR(25)
)
BEGIN
    DECLARE vPosicion VARCHAR(50) DEFAULT '';
    DECLARE vEstado CHAR(5) DEFAULT '';
    DECLARE vMensaje VARCHAR(100) DEFAULT '';
    DECLARE vStoredPass VARBINARY(255) DEFAULT NULL;
    DECLARE vID INT DEFAULT 0;
    DECLARE vFallos INT DEFAULT 0;

    -- Manejador de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
       DECLARE vErrorMsg TEXT;
       GET DIAGNOSTICS CONDITION 1 vErrorMsg = MESSAGE_TEXT;
       SELECT vErrorMsg AS Mensaje, NULL AS Posicion;
       ROLLBACK;
    END;

    /* Paso 1: Obtener datos del usuario */
    SELECT ID_Usuario, US_Puesto, US_Contrasenia, US_Estado
      INTO vID, vPosicion, vStoredPass, vEstado
      FROM Usuarios
      WHERE US_Nombre_Usuario = p_usuario
      LIMIT 1;

    /* Paso 2: Validar existencia del usuario */
    IF vID IS NULL OR vID = 0 THEN
        SET vMensaje = 'Nombre de usuario o contraseña incorrecta';
    ELSE
        /* Paso 3: Consultar intentos fallidos */
        SELECT COUNT(*) INTO vFallos
        FROM Login_Attempts
        WHERE user_id = vID AND success = FALSE;

        IF vFallos >= 3 THEN
            UPDATE Usuarios 
              SET US_Estado = 'I'
            WHERE ID_Usuario = vID;
            SET vMensaje = 'Usuario inactivo por demasiados intentos fallidos';
        ELSEIF vEstado = 'I' THEN
            SET vMensaje = 'Usuario inactivo';
        ELSE
            /* Paso 4: Verificar la contraseña */
            IF p_contrasenia <> CAST(AES_DECRYPT(vStoredPass, 'clave_secreta') AS CHAR) THEN
                INSERT INTO Login_Attempts(user_id, success) 
                VALUES (vID, FALSE);
                SELECT COUNT(*) INTO vFallos
                FROM Login_Attempts
                WHERE user_id = vID AND success = FALSE;
                SET vMensaje = 'Nombre de usuario o contraseña incorrecta.';
            ELSE
                /* Contraseña correcta */
                INSERT INTO Login_Attempts(user_id, success) 
                VALUES (vID, TRUE);
                IF vPosicion = 'Empleado' THEN
                    SET vMensaje = 'Empleado ha hecho sesión';
                ELSEIF vPosicion = 'Admin' THEN
                    SET vMensaje = 'Admin ha hecho sesión';
                ELSEIF vPosicion = 'Compra' THEN
                    SET vMensaje = 'Comprador ha hecho sesión';
                ELSE
                    SET vMensaje = 'Usuario válido pero posición desconocida';
                END IF;
                INSERT INTO Historial_Login (US_Nombre_Usuario, US_Contrasenia, US_Puesto, US_Tiempo)
                VALUES (p_usuario, p_contrasenia, vPosicion, NOW());
            END IF;
        END IF;
    END IF;

    /* Paso 5: Devolver resultado */
    SELECT vMensaje AS Mensaje, vPosicion AS Posicion;
END //

DELIMITER ;

----------------------------------------
-- Procedimiento: sp_insert_comprador
----------------------------------------
DROP PROCEDURE IF EXISTS sp_insert_comprador;
DELIMITER //

CREATE PROCEDURE sp_insert_comprador(
    IN p_usuario VARCHAR(50),
    IN p_correo VARCHAR(50),
    IN p_contrasenia VARCHAR(255),
    IN p_pais INT,
    IN p_provincia INT,
    IN p_canton INT,
    IN p_distrito INT
)
BEGIN
  DECLARE new_user_id INT;

  -- Validar existencia de nombre de usuario
  IF (SELECT COUNT(*) FROM Usuarios WHERE US_Nombre_Usuario = p_usuario) > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre de usuario ya existe';
  END IF;
  
  -- Validar formato de contraseña
  IF LENGTH(p_contrasenia) < 14 OR 
     p_contrasenia NOT REGEXP '^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[^a-zA-Z0-9]).+$' THEN
       SIGNAL SQLSTATE '45000' 
         SET MESSAGE_TEXT = 'La contraseña debe tener mínimo 14 caracteres e incluir mayúsculas, minúsculas, números y caracteres especiales.';
  END IF;

  -- Insertar en Usuarios (con cifrado)
  INSERT INTO Usuarios (US_Nombre_Usuario, US_Correo, US_Contrasenia, US_Puesto, US_Estado)
  VALUES (p_usuario, p_correo, AES_ENCRYPT(p_contrasenia, 'clave_secreta'), 'Compra', 'A');

  SET new_user_id = LAST_INSERT_ID();

  -- Insertar en Compradores usando el ID generado
  INSERT INTO Compradores (ID_Comprador, COM_Nombre, COM_Apellido, COM_Direccion, COM_Pais, COM_Provincia, COM_Canton, COM_Distrito)
  VALUES (new_user_id, NULL, NULL, NULL, p_pais, p_provincia, p_canton, p_distrito);
END //

DELIMITER ;

----------------------------------------
-- Procedimiento: sp_modificar_comprador
----------------------------------------
DROP PROCEDURE IF EXISTS sp_modificar_comprador;
DELIMITER //

CREATE PROCEDURE sp_modificar_comprador(
    IN p_nuevoCorreo VARCHAR(50),
    IN p_nuevaContrasenia VARCHAR(25),
    IN p_nuevoNombre VARCHAR(50),
    IN p_nuevoApellido VARCHAR(50),
    IN p_nuevaDireccion VARCHAR(200)
)
proc: BEGIN
    DECLARE vCount INT DEFAULT 0;
    DECLARE vMensaje VARCHAR(200) DEFAULT '';
    DECLARE v_userID INT;
    DECLARE v_loginEmail VARCHAR(50);

    -- Obtener el correo del último login
    SELECT US_Correo 
      INTO v_loginEmail
      FROM Historial_Login
      ORDER BY ID_Login DESC
      LIMIT 1;

    -- Obtener el ID del usuario a partir del correo
    SELECT ID_Usuario 
      INTO v_userID
      FROM Usuarios
      WHERE US_Correo = v_loginEmail
      LIMIT 1;

    -- Verificar que el comprador exista
    SELECT COUNT(*) INTO vCount
    FROM Compradores
    WHERE ID_Comprador = v_userID;
    
    IF vCount = 0 THEN
        SET vMensaje = 'Comprador no encontrado';
        SELECT vMensaje AS Mensaje;
        LEAVE proc;
    END IF;
    
    -- Actualizar correo si se suministra y es único
    IF p_nuevoCorreo IS NOT NULL THEN
        SELECT COUNT(*) INTO vCount
        FROM Usuarios
        WHERE US_Correo = p_nuevoCorreo
          AND ID_Usuario <> v_userID;
        IF vCount > 0 THEN
            SET vMensaje = 'El correo ya existe para otro usuario';
            SELECT vMensaje AS Mensaje;
            LEAVE proc;
        END IF;
        UPDATE Usuarios
        SET US_Correo = p_nuevoCorreo
        WHERE ID_Usuario = v_userID;
    END IF;
    
    -- Actualizar contraseña si se suministra
    IF p_nuevaContrasenia IS NOT NULL THEN
        UPDATE Usuarios
        SET US_Contrasenia = p_nuevaContrasenia
        WHERE ID_Usuario = v_userID;
    END IF;
    
    -- Actualizar nombre en Compradores
    IF p_nuevoNombre IS NOT NULL THEN
        UPDATE Compradores
        SET COM_Nombre = p_nuevoNombre
        WHERE ID_Comprador = v_userID;
    END IF;
    
    -- Actualizar apellido en Compradores
    IF p_nuevoApellido IS NOT NULL THEN
        UPDATE Compradores
        SET COM_Apellido = p_nuevoApellido
        WHERE ID_Comprador = v_userID;
    END IF;
    
    -- Actualizar dirección en Compradores
    IF p_nuevaDireccion IS NOT NULL THEN
        UPDATE Compradores
        SET COM_Direccion = p_nuevaDireccion
        WHERE ID_Comprador = v_userID;
    END IF;
    
    SET vMensaje = 'Datos actualizados correctamente';
    
    SELECT vMensaje AS Mensaje;
    SELECT * FROM tmp_info_comprador;
END proc //

DELIMITER ;

----------------------------------------
-- Procedimiento: sp_generar_datos_cliente
----------------------------------------
DROP PROCEDURE IF EXISTS sp_generar_datos_cliente;
DELIMITER //

CREATE PROCEDURE sp_generar_datos_cliente(
    IN p_ID INT
)
BEGIN
    -- Eliminar tabla temporal si existe
    DROP TEMPORARY TABLE IF EXISTS datos_cliente;
    
    -- Crear tabla temporal con los datos del comprador
    CREATE TEMPORARY TABLE datos_cliente (
        ID_Usuario INT,
        US_Correo VARCHAR(50),
        US_Puesto VARCHAR(50),
        US_Estado CHAR(5),
        COM_Nombre VARCHAR(50),
        COM_Apellido VARCHAR(50),
        COM_Direccion VARCHAR(200)
    );
    
    INSERT INTO datos_cliente (ID_Usuario, US_Correo, US_Puesto, US_Estado, COM_Nombre, COM_Apellido, COM_Direccion)
    SELECT u.ID_Usuario, u.US_Correo, u.US_Puesto, u.US_Estado, c.COM_Nombre, c.COM_Apellido, c.COM_Direccion
    FROM Usuarios u
    JOIN Compradores c ON u.ID_Usuario = c.ID_Comprador
    WHERE u.ID_Usuario = p_ID;
    
    SELECT * FROM datos_cliente;
END //

DELIMITER ;

----------------------------------------
-- Procedimiento: sp_insert_feedback
----------------------------------------
DROP PROCEDURE IF EXISTS sp_insert_feedback;
DELIMITER //

CREATE PROCEDURE sp_insert_feedback(
    IN p_calificacion SMALLINT,
    IN p_comentario VARCHAR(100)
)
BEGIN
    DECLARE vMensaje VARCHAR(200);

    -- Validar que la puntuación esté entre 0 y 5
    IF p_calificacion < 0 OR p_calificacion > 5 THEN
        SET vMensaje = 'Error: La puntuación debe estar entre 0 y 5.';
        SELECT vMensaje AS Mensaje;
    ELSE
        INSERT INTO Feedback (FE_Estrellas, FE_Comentario)
        VALUES (p_calificacion, p_comentario);
        SET vMensaje = 'Feedback insertado correctamente.';
        SELECT vMensaje AS Mensaje;
    END IF;
END //

DELIMITER ;

----------------------------------------
-- Procedimiento: sp_modificar_empleado
----------------------------------------
DROP PROCEDURE IF EXISTS sp_modificar_empleado;
DELIMITER //

CREATE PROCEDURE sp_modificar_empleado(
    IN p_EMP_ID INT,
    IN p_nuevoCorreo VARCHAR(50),
    IN p_nuevaContrasenia VARCHAR(25),
    IN p_nuevoPuesto VARCHAR(10),
    IN p_nuevoEstado VARCHAR(10),
    IN p_nuevoNombre VARCHAR(50),
    IN p_nuevoApellido VARCHAR(50),
    IN p_nuevoID_Horario INT
)
proc: BEGIN
    DECLARE vCount INT DEFAULT 0;
    DECLARE vMensaje VARCHAR(200) DEFAULT '';

    -- Verificar que el empleado exista
    SELECT COUNT(*) INTO vCount
    FROM Empleados
    WHERE EMP_ID = p_EMP_ID;
    
    IF vCount = 0 THEN
        SET vMensaje = 'Empleado no encontrado';
        SELECT vMensaje AS Mensaje;
        LEAVE proc;
    END IF;
    
    -- Actualizar correo (si se suministra y es único)
    IF p_nuevoCorreo IS NOT NULL THEN
        SELECT COUNT(*) INTO vCount
        FROM Usuarios
        WHERE US_Correo = p_nuevoCorreo
          AND ID_Usuario <> p_EMP_ID;
        IF vCount > 0 THEN
            SET vMensaje = 'El correo ya existe para otro usuario';
            SELECT vMensaje AS Mensaje;
            LEAVE proc;
        END IF;
        UPDATE Usuarios
        SET US_Correo = p_nuevoCorreo
        WHERE ID_Usuario = p_EMP_ID;
    END IF;
    
    -- Actualizar contraseña, puesto y estado en Usuarios
    IF p_nuevaContrasenia IS NOT NULL THEN
        UPDATE Usuarios
        SET US_Contrasenia = p_nuevaContrasenia
        WHERE ID_Usuario = p_EMP_ID;
    END IF;
    IF p_nuevoPuesto IS NOT NULL THEN
        UPDATE Usuarios
        SET US_Puesto = p_nuevoPuesto
        WHERE ID_Usuario = p_EMP_ID;
    END IF;
    IF p_nuevoEstado IS NOT NULL THEN
        UPDATE Usuarios
        SET US_Estado = p_nuevoEstado
        WHERE ID_Usuario = p_EMP_ID;
    END IF;
    
    -- Actualizar nombre y apellido en Empleados
    IF p_nuevoNombre IS NOT NULL THEN
        UPDATE Empleados
        SET EMP_Nombre = p_nuevoNombre
        WHERE EMP_ID = p_EMP_ID;
    END IF;
    IF p_nuevoApellido IS NOT NULL THEN
        UPDATE Empleados
        SET EMP_Apellido = p_nuevoApellido
        WHERE EMP_ID = p_EMP_ID;
    END IF;
    
    -- Actualizar horario en Empleados
    IF p_nuevoID_Horario IS NOT NULL THEN
        UPDATE Empleados
        SET EMP_ID_Horario = p_nuevoID_Horario
        WHERE EMP_ID = p_EMP_ID;
    END IF;
    
    SET vMensaje = 'Datos del empleado actualizados correctamente';
    SELECT vMensaje AS Mensaje;
END proc //

DELIMITER ;

----------------------------------------
-- Procedimiento: sp_insert_proyecto_final
----------------------------------------
DROP PROCEDURE IF EXISTS sp_insert_proyecto_final;
DELIMITER //

CREATE PROCEDURE sp_insert_proyecto_final(
    IN p_ID_Articulo VARCHAR(20),
    IN p_ID_Comprador INT,
    IN p_modificaciones VARCHAR(255)
)
BEGIN
    DECLARE v_proyecto_id INT;
    DECLARE v_employee INT;
    DECLARE v_art_cat CHAR(2);
    DECLARE v_art_price FLOAT;
    DECLARE v_mod_price FLOAT;
    DECLARE v_mod_sum FLOAT DEFAULT 0;
    DECLARE v_mod VARCHAR(20);
    DECLARE v_comma INT;
    DECLARE v_final_price FLOAT;
    
    -- 1. Obtener categoría y precio base del artículo
    SELECT CAT_Tipo, CATI_Precio 
      INTO v_art_cat, v_art_price
      FROM Catalogo
      WHERE ID_Articulo = p_ID_Articulo;
      
    IF v_art_cat IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Artículo no encontrado';
    END IF;
    
    -- 2. Seleccionar un empleado activo aleatorio
    SELECT ID_Usuario 
      INTO v_employee
      FROM Usuarios
      WHERE US_Puesto = 'Empleado' AND US_Estado = 'A'
      ORDER BY RAND()
      LIMIT 1;
      
    IF v_employee IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay empleados activos disponibles';
    END IF;
    
    -- 3. Insertar el nuevo proyecto (PRO_Progreso se asume en 1)
    INSERT INTO Proyectos (ID_Empleado, PRO_Progreso, ID_Articulo, ID_Comprador)
    VALUES (v_employee, 1, p_ID_Articulo, p_ID_Comprador);
    
    SET v_proyecto_id = LAST_INSERT_ID();
    
    -- 4. Procesar cadena de modificaciones (IDs separados por comas)
    WHILE LENGTH(p_modificaciones) > 0 DO
        SET v_comma = INSTR(p_modificaciones, ',');
        IF v_comma > 0 THEN
            SET v_mod = TRIM(SUBSTRING(p_modificaciones, 1, v_comma - 1));
            SET p_modificaciones = SUBSTRING(p_modificaciones, v_comma + 1);
        ELSE
            SET v_mod = TRIM(p_modificaciones);
            SET p_modificaciones = '';
        END IF;
        
        -- Validar que el servicio pertenezca a la misma categoría
        SELECT IFNULL(Precio, 0) 
          INTO v_mod_price
          FROM ServicioPorProducto
          WHERE ID_Servicio = v_mod AND CAT_Tipo = v_art_cat
          LIMIT 1;
        
        IF v_mod_price > 0 THEN
            SET v_mod_sum = v_mod_sum + v_mod_price;
            INSERT INTO Proyecto_Modificaciones (ID_Proyecto, ID_Servicio)
            VALUES (v_proyecto_id, v_mod);
        END IF;
    END WHILE;
    
    -- 5. Calcular precio final (precio base + modificaciones)
    SET v_final_price = v_art_price + v_mod_sum;
    
    -- 6. Actualizar stock y cantidad vendida en Catalogo
    UPDATE Catalogo
    SET CATI_Cantidad = CATI_Cantidad - 1,
        CATI_Venta = CATI_Venta + 1
    WHERE ID_Articulo = p_ID_Articulo;
    
    -- 7. Retornar ID del proyecto y precio final
    SELECT v_proyecto_id AS ProyectoID, v_final_price AS PrecioFinal;
END //

DELIMITER ;

----------------------------------------
-- Procedimiento: sp_filtrar_servicios
----------------------------------------
DROP PROCEDURE IF EXISTS sp_filtrar_servicios;
DELIMITER //

CREATE PROCEDURE sp_filtrar_servicios(
    IN p_ID_Articulo VARCHAR(20)
)
BEGIN
    DECLARE v_cat CHAR(2);

    -- Obtener la categoría del artículo
    SELECT CAT_Tipo 
      INTO v_cat 
      FROM Catalogo 
      WHERE ID_Articulo = p_ID_Articulo
      LIMIT 1;
    
    IF v_cat IS NULL THEN
        SIGNAL SQLSTATE '45000' 
          SET MESSAGE_TEXT = 'Artículo no encontrado';
    END IF;
    
    -- Eliminar tabla temporal si existe
    DROP TEMPORARY TABLE IF EXISTS tmp_servicios;
    
    -- Crear tabla temporal con servicios filtrados
    CREATE TEMPORARY TABLE tmp_servicios AS
    SELECT *
    FROM ServicioPorProducto
    WHERE CAT_Tipo = v_cat;
    
    SELECT * FROM tmp_servicios;
END //

DELIMITER ;

----------------------------------------
-- Procedimiento: sp_sumar_stock
----------------------------------------
DROP PROCEDURE IF EXISTS sp_sumar_stock;
DELIMITER //

CREATE PROCEDURE sp_sumar_stock(
    IN p_ID_Articulo VARCHAR(20),
    IN p_incremento INT
)
BEGIN
    DECLARE v_stock INT;

    -- Obtener stock actual del artículo
    SELECT CATI_Cantidad 
      INTO v_stock
      FROM Catalogo
      WHERE ID_Articulo = p_ID_Articulo;
    
    IF v_stock IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Artículo no encontrado';
    END IF;
    
    -- Validar que la suma no exceda 70
    IF v_stock + p_incremento > 70 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La cantidad resultante excede el máximo permitido (70)';
    ELSE
        UPDATE Catalogo
        SET CATI_Cantidad = v_stock + p_incremento
        WHERE ID_Articulo = p_ID_Articulo;
    END IF;
    
    SELECT CATI_Cantidad AS StockActual
      FROM Catalogo
      WHERE ID_Articulo = p_ID_Articulo;
END //

DELIMITER ;

----------------------------------------
-- Procedimiento: sp_generar_info_ultimo_comprador
----------------------------------------
DROP PROCEDURE IF EXISTS sp_generar_info_ultimo_comprador;
DELIMITER //

CREATE PROCEDURE sp_generar_info_ultimo_comprador()
BEGIN
    DECLARE v_email VARCHAR(50);
    DECLARE v_id INT;
    DECLARE v_puesto VARCHAR(50);
    
    -- Obtener correo del último login
    SELECT US_Correo
      INTO v_email
      FROM Historial_Login
      ORDER BY ID_Login DESC
      LIMIT 1;
      
    IF v_email IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay registros de login';
    END IF;
    
    -- Obtener ID y puesto del usuario
    SELECT ID_Usuario, US_Puesto
      INTO v_id, v_puesto
      FROM Usuarios
      WHERE US_Correo = v_email
      LIMIT 1;
      
    IF v_puesto = 'Compra' THEN
        DROP TEMPORARY TABLE IF EXISTS tmp_ultimo_comprador;
        CREATE TEMPORARY TABLE tmp_ultimo_comprador AS
        SELECT u.ID_Usuario, u.US_Correo,
               c.COM_Nombre, c.COM_Apellido, c.COM_Direccion
        FROM Usuarios u
        JOIN Compradores c ON u.ID_Usuario = c.ID_Comprador
        WHERE u.ID_Usuario = v_id;
        
        SELECT * FROM tmp_ultimo_comprador;
    ELSE
        SELECT 'El último usuario que hizo login no es comprador' AS Mensaje;
    END IF;
END //

DELIMITER ;

----------------------------------------
-- Procedimiento: sp_actualizar_estado_proyecto
----------------------------------------
DROP PROCEDURE IF EXISTS sp_actualizar_estado_proyecto;
DELIMITER //

CREATE PROCEDURE sp_actualizar_estado_proyecto(
    IN p_ID_Proyecto INT,
    IN p_NuevoEstado INT
)
BEGIN
    DECLARE v_userPuesto VARCHAR(50);
    DECLARE v_email VARCHAR(50);
    DECLARE v_userID INT;
    DECLARE v_ProyectoExistente INT;
    DECLARE v_EstadoExistente INT;
    DECLARE v_Mensaje VARCHAR(100);
    
    -- Obtener correo del último login
    SELECT US_Correo
      INTO v_email
      FROM Historial_Login
      ORDER BY ID_Login DESC
      LIMIT 1;
      
    IF v_email IS NULL THEN
       SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay registros de login';
    END IF;
    
    -- Obtener ID y puesto del usuario
    SELECT ID_Usuario, US_Puesto
      INTO v_userID, v_userPuesto
      FROM Usuarios
      WHERE US_Correo = v_email
      LIMIT 1;
      
    IF v_userID IS NULL OR v_userPuesto <> 'Empleado' THEN
       SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El último usuario no es un empleado';
    END IF;

    -- Verificar que el proyecto pertenezca al empleado
    SELECT COUNT(*) INTO v_ProyectoExistente
    FROM Proyectos
    WHERE ID_Proyecto = p_ID_Proyecto
      AND ID_Empleado = v_userID;

    IF v_ProyectoExistente = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El proyecto no está asignado a este empleado';
    END IF;

    -- Validar que el nuevo estado existe
    SELECT COUNT(*) INTO v_EstadoExistente
    FROM Progreso_Proyecto
    WHERE ID_Proyecto_Progreso = p_NuevoEstado;

    IF v_EstadoExistente = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El estado especificado no existe';
    END IF;

    -- Actualizar estado del proyecto
    UPDATE Proyectos
    SET PRO_Progreso = p_NuevoEstado
    WHERE ID_Proyecto = p_ID_Proyecto;

    SET v_Mensaje = 'Estado del proyecto actualizado correctamente';
    SELECT v_Mensaje AS Mensaje;
END //

DELIMITER ;

----------------------------------------
-- Procedimientos para ejecutar vistas
----------------------------------------
DROP PROCEDURE IF EXISTS ejecutar_vista_articulos;
DELIMITER //

CREATE PROCEDURE ejecutar_vista_articulos()
BEGIN
    SELECT * FROM vista_perifericos_compradores;
END //

DELIMITER ;

CALL ejecutar_vista_articulos();

DROP PROCEDURE IF EXISTS ejecutar_vista_faq;
DELIMITER //

CREATE PROCEDURE ejecutar_vista_faq()
BEGIN
    SELECT * FROM faq_preguntas;
END //

DELIMITER ;

-- CALL ejecutar_vista_faq();

DROP PROCEDURE IF EXISTS ejecutar_vista_calificaciones;
DELIMITER //

CREATE PROCEDURE ejecutar_vista_calificaciones()
BEGIN
    SELECT * FROM vista_evaluaciones;
END //

DELIMITER ;

-- CALL ejecutar_vista_calificaciones();

----------------------------------------
-- Procedimiento: sp_insert_codigo
----------------------------------------
DROP PROCEDURE IF EXISTS sp_insert_codigo;
DELIMITER //

CREATE PROCEDURE sp_insert_codigo(
    IN p_codigo VARCHAR(20),
    IN p_tiempo_creacion DATETIME,
    IN p_tiempo_vencimiento DATETIME
)
BEGIN
    DECLARE vNombre VARCHAR(50);
    DECLARE v_user_id INT;

    -- Obtener el nombre de usuario del último login
    SELECT US_Nombre_Usuario 
      INTO vNombre
      FROM Historial_Login
      ORDER BY US_Tiempo DESC
      LIMIT 1;
    
    -- Obtener el ID del usuario
    SELECT ID_Usuario
      INTO v_user_id
      FROM Usuarios
      WHERE US_Nombre_Usuario = vNombre
      LIMIT 1;
    
    INSERT INTO Codigo (user_id, codigo, tiempo_creacion, tiempo_vencimiento, estado)
    VALUES (v_user_id, p_codigo, p_tiempo_creacion, p_tiempo_vencimiento, 'A');
END //

DELIMITER ;

----------------------------------------
-- Procedimiento: sp_obtener_correo_usuario
----------------------------------------
DROP PROCEDURE IF EXISTS sp_obtener_correo_usuario;
DELIMITER //

CREATE PROCEDURE sp_obtener_correo_usuario()
BEGIN
    DECLARE vNombre VARCHAR(50);
    
    SELECT US_Nombre_Usuario 
      INTO vNombre
      FROM Historial_Login
      ORDER BY US_Tiempo DESC
      LIMIT 1;
    
    SELECT US_Correo
      FROM Usuarios
      WHERE US_Nombre_Usuario = vNombre
      LIMIT 1;
END //

DELIMITER ;

----------------------------------------
-- Procedimiento: sp_cambio_contrasenia
----------------------------------------
DROP PROCEDURE IF EXISTS sp_cambio_contrasenia;
DELIMITER //

CREATE PROCEDURE sp_cambio_contrasenia(
    IN p_new_password VARCHAR(255)
)
BEGIN
    DECLARE vNombre VARCHAR(50);
    DECLARE vID INT DEFAULT 0;

    -- Validar formato de la nueva contraseña
    IF LENGTH(p_new_password) < 14 OR 
       p_new_password NOT REGEXP '^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[^a-zA-Z0-9]).+$' THEN
        SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT = 'La contraseña debe tener mínimo 14 caracteres e incluir mayúsculas, minúsculas, números y caracteres especiales.';
    END IF;

    -- Obtener nombre de usuario del último login
    SELECT US_Nombre_Usuario
      INTO vNombre
      FROM Historial_Login
      ORDER BY US_Tiempo DESC
      LIMIT 1;

    -- Obtener ID del usuario
    SELECT ID_Usuario
      INTO vID
      FROM Usuarios
      WHERE US_Nombre_Usuario = vNombre
      LIMIT 1;

    -- Actualizar contraseña (cifrada)
    UPDATE Usuarios
      SET US_Contrasenia = AES_ENCRYPT(p_new_password, 'clave_secreta')
    WHERE ID_Usuario = vID;

    SELECT CONCAT('Contraseña actualizada para el usuario: ', vNombre) AS Mensaje;
END //

DELIMITER ;

----------------------------------------
-- Procedimiento: sp_validar_codigo
----------------------------------------
DROP PROCEDURE IF EXISTS sp_validar_codigo;
DELIMITER //

CREATE PROCEDURE sp_validar_codigo(
    IN p_codigo VARCHAR(20)
)
sp_validar_codigo: BEGIN
    DECLARE v_user_id INT DEFAULT 0;
    DECLARE v_estado CHAR(1) DEFAULT ' ';
    DECLARE v_tiempo_vencimiento DATETIME DEFAULT NULL;
    DECLARE v_mensaje VARCHAR(100) DEFAULT '';

    -- Handler para registro no encontrado
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_user_id = 0;

    SELECT user_id, estado, tiempo_vencimiento
      INTO v_user_id, v_estado, v_tiempo_vencimiento
      FROM Codigo
      WHERE codigo = p_codigo
      LIMIT 1;

    IF v_user_id = 0 THEN
         SET v_mensaje = 'Código no encontrado';
         SELECT v_mensaje AS Mensaje;
         LEAVE sp_validar_codigo;
    END IF;

    IF v_estado <> 'A' THEN
         SET v_mensaje = 'Código inactivo';
         SELECT v_mensaje AS Mensaje;
         LEAVE sp_validar_codigo;
    END IF;

    IF NOW() > v_tiempo_vencimiento THEN
         SET v_mensaje = 'Código expirado';
         SELECT v_mensaje AS Mensaje;
         LEAVE sp_validar_codigo;
    END IF;

    SET v_mensaje = 'Código válido';
    SELECT v_mensaje AS Mensaje, v_user_id AS Usuario;
END //

DELIMITER ;
