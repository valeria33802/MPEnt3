drop PROCEDURE spd_login

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

    /* Paso 1: Obtener datos del usuario a partir del nombre de usuario */
    SELECT ID_Usuario, US_Puesto, US_Contrasenia, US_Estado
      INTO vID, vPosicion, vStoredPass, vEstado
      FROM Usuarios
      WHERE US_Nombre_Usuario = p_usuario
      LIMIT 1;

    /* Paso 2: Validar existencia del usuario */
    IF vID IS NULL OR vID = 0 THEN
        SET vMensaje = 'Nombre de usuario o contraseña incorrecta';
    ELSE
        /* Paso 3: Consultar los intentos fallidos en Login_Attempts */
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
            /* Paso 4: Verificar la contraseña (descifrando la almacenada) */
            IF p_contrasenia <> CAST(AES_DECRYPT(vStoredPass, 'clave_secreta') AS CHAR) THEN
                INSERT INTO Login_Attempts(user_id, success) 
                VALUES (vID, FALSE);
                SELECT COUNT(*) INTO vFallos
                FROM Login_Attempts
                WHERE user_id = vID AND success = FALSE;
                SET vMensaje = CONCAT('Nombre de usuario o contraseña incorrecta.');
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

    /* Paso 5: Devolver el resultado final */
    SELECT vMensaje AS Mensaje, vPosicion AS Posicion;
END //

DELIMITER ;

drop procedure sp_insert_comprador
DELIMITER //

CREATE PROCEDURE sp_insert_comprador(
    IN p_usuario VARCHAR(50),
    IN p_correo VARCHAR(50),
    IN p_contrasenia VARCHAR(255) ,
    IN p_pais int,
    IN p_provincia int,
    IN p_canton int,
    In p_distrito int
    /*IN p_nombre VARCHAR(50),
    IN p_apellido VARCHAR(50),
    IN p_direccion VARCHAR(200)*/
)
BEGIN
  DECLARE new_user_id INT;
  
  IF (SELECT COUNT(*) FROM Usuarios WHERE US_Nombre_Usuario = p_usuario) > 0 THEN
  SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'El nombre de usuario ya existe';
END IF;
  
  -- Validar que la contraseña tenga al menos 14 caracteres y cumpla con mayúsculas, minúsculas, números y caracteres especiales.
  IF LENGTH(p_contrasenia) < 14 OR 
     p_contrasenia NOT REGEXP '^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[^a-zA-Z0-9]).+$' THEN
       SIGNAL SQLSTATE '45000' 
         SET MESSAGE_TEXT = 'La contraseña debe tener mínimo 14 caracteres e incluir mayúsculas, minúsculas, números y caracteres especiales.';
  END IF;

  -- Insertar en Usuarios con cifrado de contraseña (por ejemplo, utilizando AES_ENCRYPT)
  INSERT INTO Usuarios (US_Nombre_Usuario, US_Correo, US_Contrasenia, US_Puesto, US_Estado)
  VALUES (p_usuario, p_correo, AES_ENCRYPT(p_contrasenia, 'clave_secreta'), 'Compra', 'A');

  SET new_user_id = LAST_INSERT_ID();

  -- Insertar en Compradores usando el ID de Usuarios generado
  INSERT INTO Compradores (ID_Comprador, COM_Nombre, COM_Apellido, COM_Direccion, COM_Pais, COM_Provincia, COM_Canton, COM_Distrito)
  VALUES (new_user_id, null, null, null, p_pais, p_provincia, p_canton, p_distrito);
END //

DELIMITER ;

/*--------------------------------
--------------------*/

-- CALL sp_insert_comprador(
--     'xYZ099', 
--     'oso.huesos@gmail.com', 
--     'Segur@1234567890', 
--     'Maria', 
--     'Robles', 
--     'Av. Siempre Viva 123'
-- );


-- DROP PROCEDURE sp_modificar_comprador
-- DELIMITER //

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

    -- Obtener el correo del login más reciente
    SELECT US_Correo 
      INTO v_loginEmail
      FROM Historial_Login
      ORDER BY ID_Login DESC
      LIMIT 1;

    -- Obtener el ID del usuario usando el correo obtenido
    SELECT ID_Usuario 
      INTO v_userID
      FROM Usuarios
      WHERE US_Correo = v_loginEmail
      LIMIT 1;

    -- Verificar que el comprador exista en la tabla Compradores
    SELECT COUNT(*) INTO vCount
    FROM Compradores
    WHERE ID_Comprador = v_userID;
    
    IF vCount = 0 THEN
        SET vMensaje = 'Comprador no encontrado';
        SELECT vMensaje AS Mensaje;
        LEAVE proc;
    END IF;
    
    -- Actualizar el correo en Usuario, si se suministra
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
    
    -- Actualizar la contraseña en Usuario, si se suministra
    IF p_nuevaContrasenia IS NOT NULL THEN
        UPDATE Usuarios
        SET US_Contrasenia = p_nuevaContrasenia
        WHERE ID_Usuario = v_userID;
    END IF;
    
    -- Actualizar el nombre en Compradores, si se suministra
    IF p_nuevoNombre IS NOT NULL THEN
        UPDATE Compradores
        SET COM_Nombre = p_nuevoNombre
        WHERE ID_Comprador = v_userID;
    END IF;
    
    -- Actualizar el apellido en Compradores, si se suministra
    IF p_nuevoApellido IS NOT NULL THEN
        UPDATE Compradores
        SET COM_Apellido = p_nuevoApellido
        WHERE ID_Comprador = v_userID;
    END IF;
    
    -- Actualizar la dirección en Compradores, si se suministra
    IF p_nuevaDireccion IS NOT NULL THEN
        UPDATE Compradores
        SET COM_Direccion = p_nuevaDireccion
        WHERE ID_Comprador = v_userID;
    END IF;
    
    SET vMensaje = 'Datos actualizados correctamente';
    
    SELECT vMensaje AS Mensaje;
    SELECT * FROM tmp_info_comprador;
END proc //

-- DELIMITER ;

-- CALL sp_modificar_comprador(6, 'nuevo.correo@example.com', NULL, 'Carlos', NULL, 'Avenida 10, Barrio Escalante, San José');
-- CALL sp_modificar_comprador('test.mod@ejemplo.com', 'NuevaPass123', 'Franco', 'Ramírez', 'Avenida Central, San José');
-- select * from usuario

/*--------------------------------
--------------------*/

DELIMITER //

CREATE PROCEDURE sp_generar_datos_cliente(
    IN p_ID INT
)
BEGIN
    -- Elimina la tabla temporal si ya existe
    DROP TEMPORARY TABLE IF EXISTS datos_cliente;
    
    -- Crea la tabla temporal con las columnas que deseamos mostrar
    CREATE TEMPORARY TABLE datos_cliente (
        ID_Usuario INT,
        US_Correo VARCHAR(50),
        US_Puesto VARCHAR(50),
        US_Estado CHAR(5),
        COM_Nombre VARCHAR(50),
        COM_Apellido VARCHAR(50),
        COM_Direccion VARCHAR(200)
    );
    
    -- Inserta en la tabla temporal los datos del comprador especificado
    INSERT INTO datos_cliente (ID_Usuario, US_Correo, US_Puesto, US_Estado, COM_Nombre, COM_Apellido, COM_Direccion)
    SELECT u.ID_Usuario, u.US_Correo, u.US_Puesto, u.US_Estado, c.COM_Nombre, c.COM_Apellido, c.COM_Direccion
    FROM Usuarios u
    JOIN Compradores c ON u.ID_Usuario = c.ID_Comprador
    WHERE u.ID_Usuario = p_ID;
    
    -- Retorna los datos de la tabla temporal
    SELECT * FROM datos_cliente;
END //

DELIMITER ;
/*--------------------------------
--------------------*/
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

-- CALL sp_insert_feedback(4, 'El servicio fue excelente.');

/*--------------------------------
--------------------*/

drop procedure sp_modificar_empleado

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

    -- Verificar que el empleado exista en la tabla Empleados
    SELECT COUNT(*) INTO vCount
    FROM Empleados
    WHERE EMP_ID = p_EMP_ID;
    
    IF vCount = 0 THEN
        SET vMensaje = 'Empleado no encontrado';
        SELECT vMensaje AS Mensaje;
        LEAVE proc;
    END IF;
    
    -- Si se desea actualizar el correo, validar que no exista para otro usuario
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
    
    -- Actualizar la contraseña en Usuario
    IF p_nuevaContrasenia IS NOT NULL THEN
        UPDATE Usuarios
        SET US_Contrasenia = p_nuevaContrasenia
        WHERE ID_Usuario = p_EMP_ID;
    END IF;
    
    -- Actualizar el puesto en Usuario
    IF p_nuevoPuesto IS NOT NULL THEN
        UPDATE Usuarios
        SET US_Puesto = p_nuevoPuesto
        WHERE ID_Usuario = p_EMP_ID;
    END IF;
    
    -- Actualizar el estado en Usuario
    IF p_nuevoEstado IS NOT NULL THEN
        UPDATE Usuarios
        SET US_Estado = p_nuevoEstado
        WHERE ID_Usuario = p_EMP_ID;
    END IF;
    
    -- Actualizar el nombre en Empleados
    IF p_nuevoNombre IS NOT NULL THEN
        UPDATE Empleados
        SET EMP_Nombre = p_nuevoNombre
        WHERE EMP_ID = p_EMP_ID;
    END IF;
    
    -- Actualizar el apellido en Empleados
    IF p_nuevoApellido IS NOT NULL THEN
        UPDATE Empleados
        SET EMP_Apellido = p_nuevoApellido
        WHERE EMP_ID = p_EMP_ID;
    END IF;
    
    -- Actualizar el horario en Empleados
    IF p_nuevoID_Horario IS NOT NULL THEN
        UPDATE Empleados
        SET EMP_ID_Horario = p_nuevoID_Horario
        WHERE EMP_ID = p_EMP_ID;
    END IF;
    
    SET vMensaje = 'Datos del empleado actualizados correctamente';
    SELECT vMensaje AS Mensaje;
END proc //

DELIMITER ;

-- CALL sp_modificar_empleado(1, 'nuevo.correo@modp.co.cr', NULL, NULL,'A', 'Alejandro', NULL, NULL);

-- select * from catalogo


/*--------------------------------
--------------------*/

-- drop procedure sp_insert_proyecto_final

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
    
    -- 1. Obtener la categoría y precio base del artículo
    SELECT CAT_Tipo, CATI_Precio 
      INTO v_art_cat, v_art_price
      FROM Catalogo
      WHERE ID_Articulo = p_ID_Articulo;
      
    IF v_art_cat IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Artículo no encontrado';
    END IF;
    
    -- 2. Seleccionar un empleado aleatorio activo
    SELECT ID_Usuario 
      INTO v_employee
      FROM Usuarios
      WHERE US_Puesto = 'Empleado' AND US_Estado = 'A'
      ORDER BY RAND()
      LIMIT 1;
      
    IF v_employee IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay empleados activos disponibles';
    END IF;
    
    -- 3. Insertar el nuevo proyecto con progreso por defecto (se asume PRO_Progreso = 1)
    INSERT INTO Proyectos (ID_Empleado, PRO_Progreso, ID_Articulo, ID_Comprador)
    VALUES (v_employee, 1, p_ID_Articulo, p_ID_Comprador);
    
    SET v_proyecto_id = LAST_INSERT_ID();
    
    -- 4. Procesar la cadena de modificaciones (IDs separados por comas)
    WHILE LENGTH(p_modificaciones) > 0 DO
        SET v_comma = INSTR(p_modificaciones, ',');
        IF v_comma > 0 THEN
            SET v_mod = TRIM(SUBSTRING(p_modificaciones, 1, v_comma - 1));
            SET p_modificaciones = SUBSTRING(p_modificaciones, v_comma + 1);
        ELSE
            SET v_mod = TRIM(p_modificaciones);
            SET p_modificaciones = '';
        END IF;
        
        -- Validar que el servicio pertenezca a la misma categoría que el artículo
        SELECT IFNULL(Precio, 0) 
          INTO v_mod_price
          FROM ServicioPorProducto
          WHERE ID_Servicio = v_mod AND CAT_Tipo = v_art_cat
          LIMIT 1;
        
        IF v_mod_price > 0 THEN
            -- Acumular el precio del servicio
            SET v_mod_sum = v_mod_sum + v_mod_price;
            -- Registrar la modificación en la tabla intermedia
            INSERT INTO Proyecto_Modificaciones (ID_Proyecto, ID_Servicio)
            VALUES (v_proyecto_id, v_mod);
        END IF;
    END WHILE;
    
    -- 5. Calcular el precio final (precio base + suma de modificaciones)
    SET v_final_price = v_art_price + v_mod_sum;
    
    -- 6. Actualizar el stock y la cantidad vendida en la tabla Catalogo
    UPDATE Catalogo
    SET CATI_Cantidad = CATI_Cantidad - 1,
        CATI_Venta = CATI_Venta + 1
    WHERE ID_Articulo = p_ID_Articulo;
    
    -- 7. Retornar el ID del proyecto y el precio final
    SELECT v_proyecto_id AS ProyectoID, v_final_price AS PrecioFinal;
END //

DELIMITER ;


-- CALL sp_insert_proyecto_final('TE002', 6, 'TESE1,TESE3,TESE10');

DELIMITER //

CREATE PROCEDURE sp_filtrar_servicios(
    IN p_ID_Articulo VARCHAR(20)
)
BEGIN
    DECLARE v_cat CHAR(2);

    -- Obtener la categoría del artículo seleccionado
    SELECT CAT_Tipo 
      INTO v_cat 
      FROM Catalogo 
      WHERE ID_Articulo = p_ID_Articulo
      LIMIT 1;
    
    IF v_cat IS NULL THEN
        SIGNAL SQLSTATE '45000' 
          SET MESSAGE_TEXT = 'Artículo no encontrado';
    END IF;
    
    -- Elimina la tabla temporal si ya existe
    DROP TEMPORARY TABLE IF EXISTS tmp_servicios;
    
    -- Crear la tabla temporal con los servicios filtrados por categoría
    CREATE TEMPORARY TABLE tmp_servicios AS
    SELECT *
    FROM ServicioPorProducto
    WHERE CAT_Tipo = v_cat;
    
    -- Retornar los registros de la tabla temporal
    SELECT * FROM tmp_servicios;
END //

DELIMITER ;

/*--------------------------------
--------------------*/
-- drop procedure sp_actualizar_stock



DELIMITER //

CREATE PROCEDURE sp_sumar_stock(
    IN p_ID_Articulo VARCHAR(20),
    IN p_incremento INT
)
BEGIN
    DECLARE v_stock INT;

    -- Obtener el stock actual del artículo
    SELECT CATI_Cantidad 
      INTO v_stock
      FROM Catalogo
      WHERE ID_Articulo = p_ID_Articulo;
    
    -- Validar que el artículo exista
    IF v_stock IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Artículo no encontrado';
    END IF;
    
    -- Validar que la suma no exceda el máximo permitido (70)
    IF v_stock + p_incremento > 70 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La cantidad resultante excede el máximo permitido (70)';
    ELSE
        -- Actualizar el stock sumando la cantidad solicitada
        UPDATE Catalogo
        SET CATI_Cantidad = v_stock + p_incremento
        WHERE ID_Articulo = p_ID_Articulo;
    END IF;
    
    -- Retornar el stock actualizado
    SELECT CATI_Cantidad AS StockActual
      FROM Catalogo
      WHERE ID_Articulo = p_ID_Articulo;
END //

DELIMITER ;


-- CALL sp_sumar_stock('TE002', 9);

-- drop PROCEDURE sp_generar_info_ultimo_comprador
DELIMITER //

CREATE PROCEDURE sp_generar_info_ultimo_comprador()
BEGIN
    DECLARE v_email VARCHAR(50);
    DECLARE v_id INT;
    DECLARE v_puesto VARCHAR(50);
    
    -- Obtener el correo del último login
    SELECT US_Correo
      INTO v_email
      FROM Historial_Login
      ORDER BY ID_Login DESC
      LIMIT 1;
      
    IF v_email IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No hay registros de login';
    END IF;
    
    -- Obtener el ID y puesto del usuario con ese correo
    SELECT ID_Usuario, US_Puesto
      INTO v_id, v_puesto
      FROM Usuarios
      WHERE US_Correo = v_email
      LIMIT 1;
      
    IF v_puesto = 'Compra' THEN
        -- Crear la tabla temporal con la información del comprador
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

-- drop procedure sp_historial_compra_ultimo_usuario
-- DELIMITER //

CREATE PROCEDURE sp_historial_compra_ultimo_usuario()
BEGIN
    DECLARE v_email VARCHAR(50);
    DECLARE v_userID INT;
    DECLARE v_userPuesto VARCHAR(50);
    
    -- 1. Obtener el correo del último login
    SELECT US_Correo
      INTO v_email
      FROM Historial_Login
      ORDER BY ID_Login DESC
      LIMIT 1;
      
    IF v_email IS NULL THEN
       SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay registros de login';
    END IF;
    
    -- 2. Obtener el ID y puesto del usuario a partir del correo obtenido
    SELECT ID_Usuario, US_Puesto
      INTO v_userID, v_userPuesto
      FROM Usuarios
      WHERE US_Correo = v_email
      LIMIT 1;
      
    IF v_userID IS NULL OR v_userPuesto <> 'Compra' THEN
       SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El último usuario no es un comprador';
    END IF;
    
    -- 3. Crear la tabla temporal "historial_compra" con los detalles de las compras
    DROP TEMPORARY TABLE IF EXISTS historial_compra;
    
    CREATE TEMPORARY TABLE historial_compra AS
    SELECT 
       fd.ID_Factura AS 'ID Factura',
     --  fd.ID_Proyecto,
     --  fd.ID_Articulo,
       c.CAT_Nombre AS 'Articulo',
       fd.FD_Precio_Final AS 'Precio item',
       fd.FA_Fecha AS 'Fecha',
       fd.FA_Detalle AS 'Detalle compra',
       COALESCE(
          (SELECT GROUP_CONCAT(sp.SE_Descripcion SEPARATOR ', ')
           FROM Proyecto_Modificaciones pm
           JOIN ServicioPorProducto sp ON pm.ID_Servicio = sp.ID_Servicio
           WHERE pm.ID_Proyecto = fd.ID_Proyecto),
           'Sin personalización'
       ) AS Personalizaciones
    FROM Factura_Detalle fd
    LEFT JOIN Catalogo c ON fd.ID_Articulo = c.ID_Articulo
    WHERE fd.ID_Comprador = v_userID;
    
    -- 4. Retornar los datos del historial de compras
    SELECT * FROM historial_compra;
END //

DELIMITER ;

-- CALL sp_generar_info_ultimo_comprador();
-- drop PROCEDURE sp_actualizar_estado_proyecto

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
    
    -- 1. Obtener el correo del último login
    SELECT US_Correo
      INTO v_email
      FROM Historial_Login
      ORDER BY ID_Login DESC
      LIMIT 1;
      
    IF v_email IS NULL THEN
       SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay registros de login';
    END IF;
    
    -- 2. Obtener el ID y puesto del usuario a partir del correo obtenido
    SELECT ID_Usuario, US_Puesto
      INTO v_userID, v_userPuesto
      FROM Usuarios
      WHERE US_Correo = v_email
      LIMIT 1;
      
    IF v_userID IS NULL OR v_userPuesto <> 'Empleado' THEN
       SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El último usuario no es un empleado';
    END IF;

    -- 2. Verificar que el proyecto pertenece a ese empleado
    SELECT COUNT(*) INTO v_ProyectoExistente
    FROM Proyectos
    WHERE ID_Proyecto = p_ID_Proyecto
      AND ID_Empleado = v_userID;

    -- Si el proyecto no pertenece al empleado, se detiene el procedimiento
    IF v_ProyectoExistente = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El proyecto no está asignado a este empleado';
    END IF;

    -- 3. Validar que el nuevo estado existe en la tabla Estados
    SELECT COUNT(*) INTO v_EstadoExistente
    FROM Progreso_Proyecto
    WHERE ID_Proyecto_Progreso = p_NuevoEstado;

    -- Si el estado no existe, se detiene el procedimiento
    IF v_EstadoExistente = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El estado especificado no existe';
    END IF;

    -- 4. Actualizar el estado del proyecto
    UPDATE Proyectos
    SET PRO_Progreso = p_NuevoEstado
    WHERE ID_Proyecto = p_ID_Proyecto;

    -- Retornar mensaje de éxito
    SET v_Mensaje = 'Estado del proyecto actualizado correctamente';
    SELECT v_Mensaje AS Mensaje;
END //

DELIMITER ;

-- CALL sp_actualizar_estado_proyecto(1, 4);

DELIMITER //
create procedure ejecutar_vista_articulos()
begin
	select * from vista_perifericos_compradores;
end //
DELIMITER ;
 call ejecutar_vista_articulos()


-- drop procedure ejecutar_vista_faq
DELIMITER //
create procedure ejecutar_vista_faq()
begin
	select * from faq_preguntas;
end //
DELIMITER ;

-- call ejecutar_vista_faq

-- drop procedure ejecutar_vista_calificaciones
DELIMITER //
create procedure ejecutar_vista_calificaciones()
begin
	select * from vista_evaluaciones;
end //
DELIMITER ;

-- call ejecutar_vista_calificaciones


-- 

DELIMITER //

CREATE PROCEDURE sp_insert_codigo(
    IN p_codigo VARCHAR(20),
    IN p_tiempo_creacion DATETIME,
    IN p_tiempo_vencimiento DATETIME
)
BEGIN
    DECLARE vNombre VARCHAR(50);
    DECLARE v_user_id INT;

    -- Obtener el nombre de usuario del último login (ordenado por US_Tiempo DESC)
    SELECT US_Nombre_Usuario 
      INTO vNombre
      FROM Historial_Login
      ORDER BY US_Tiempo DESC
      LIMIT 1;
    
    -- Obtener el ID del usuario usando el nombre obtenido
    SELECT ID_Usuario
      INTO v_user_id
      FROM Usuarios
      WHERE US_Nombre_Usuario = vNombre
      LIMIT 1;
    
    -- Insertar en la tabla Codigo
    INSERT INTO Codigo (user_id, codigo, tiempo_creacion, tiempo_vencimiento, estado)
    VALUES (v_user_id, p_codigo, p_tiempo_creacion, p_tiempo_vencimiento, 'A');
END //

DELIMITER ;
-- 
DELIMITER //

CREATE PROCEDURE sp_obtener_correo_usuario ()
BEGIN
    DECLARE vNombre VARCHAR(50);
    
    -- Obtener el nombre de usuario del último login
    SELECT US_Nombre_Usuario 
      INTO vNombre
      FROM Historial_Login
      ORDER BY US_Tiempo DESC
      LIMIT 1;
    
    -- Retornar el correo del usuario correspondiente
    SELECT US_Correo
      FROM Usuarios
      WHERE US_Nombre_Usuario = vNombre
      LIMIT 1;
END //

DELIMITER ;


-- 

DELIMITER //

CREATE PROCEDURE sp_cambio_contrasenia(
    IN p_new_password VARCHAR(255)
)
BEGIN
    DECLARE vNombre VARCHAR(50);
    DECLARE vID INT DEFAULT 0;

    -- Validar que la nueva contraseña cumpla las reglas:
    -- Mínimo 14 caracteres, con al menos una minúscula, una mayúscula, un número y un carácter especial.
    IF LENGTH(p_new_password) < 14 OR 
       p_new_password NOT REGEXP '^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[^a-zA-Z0-9]).+$' THEN
        SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT = 'La contraseña debe tener mínimo 14 caracteres e incluir mayúsculas, minúsculas, números y caracteres especiales.';
    END IF;

    -- Obtener el nombre de usuario del último login registrado (ordenado por la fecha y hora)
    SELECT US_Nombre_Usuario
      INTO vNombre
      FROM Historial_Login
      ORDER BY US_Tiempo DESC
      LIMIT 1;

    -- Obtener el ID del usuario a partir del nombre de usuario obtenido
    SELECT ID_Usuario
      INTO vID
      FROM Usuarios
      WHERE US_Nombre_Usuario = vNombre
      LIMIT 1;

    -- Actualizar la contraseña del usuario (se almacena cifrada con AES_ENCRYPT)
    UPDATE Usuarios
      SET US_Contrasenia = AES_ENCRYPT(p_new_password, 'clave_secreta')
    WHERE ID_Usuario = vID;

    -- Devolver un mensaje indicando el éxito del cambio de contraseña
    SELECT CONCAT('Contraseña actualizada para el usuario: ', vNombre) AS Mensaje;
END //

DELIMITER ;


-- sp para validar código


DELIMITER //

CREATE PROCEDURE sp_validar_codigo(
    IN p_codigo VARCHAR(20)
)
sp_validar_codigo: BEGIN
    DECLARE v_user_id INT DEFAULT 0;
    DECLARE v_estado CHAR(1) DEFAULT ' ';
    DECLARE v_tiempo_vencimiento DATETIME DEFAULT NULL;
    DECLARE v_mensaje VARCHAR(100) DEFAULT '';

    -- Si no se encuentra el registro, se establece v_user_id a 0
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_user_id = 0;

    -- Buscar el código en la tabla Codigo
    SELECT user_id, estado, tiempo_vencimiento
      INTO v_user_id, v_estado, v_tiempo_vencimiento
      FROM Codigo
      WHERE codigo = p_codigo
      LIMIT 1;

    -- Si no se encontró el código
    IF v_user_id = 0 THEN
         SET v_mensaje = 'Código no encontrado';
         SELECT v_mensaje AS Mensaje;
         LEAVE sp_validar_codigo;
    END IF;

    -- Validar que el código esté activo
    IF v_estado <> 'A' THEN
         SET v_mensaje = 'Código inactivo';
         SELECT v_mensaje AS Mensaje;
         LEAVE sp_validar_codigo;
    END IF;

    -- Validar que el código no haya expirado
    IF NOW() > v_tiempo_vencimiento THEN
         SET v_mensaje = 'Código expirado';
         SELECT v_mensaje AS Mensaje;
         LEAVE sp_validar_codigo;
    END IF;

    SET v_mensaje = 'Código válido';
    SELECT v_mensaje AS Mensaje, v_user_id AS Usuario;
END //

DELIMITER ;




