USE modp;

-- Eliminar triggers existentes (si existen)
DROP TRIGGER IF EXISTS trg_validar_empleado;
DROP TRIGGER IF EXISTS trg_validar_comprador;


DELIMITER //

CREATE TRIGGER trg_validar_empleado
BEFORE INSERT ON Empleados
FOR EACH ROW
BEGIN
   -- Validar que EMP_Nombre contenga solo letras (sin espacios o números)
   IF NEW.EMP_Nombre NOT REGEXP '^[A-Za-z]+$' THEN
       SIGNAL SQLSTATE '45000'
         SET MESSAGE_TEXT = 'El nombre debe contener solo letras sin espacios ni números.';
   END IF;
   
   -- Validar que EMP_Apellido contenga solo letras (sin espacios o números)
   IF NEW.EMP_Apellido NOT REGEXP '^[A-Za-z]+$' THEN
       SIGNAL SQLSTATE '45000'
         SET MESSAGE_TEXT = 'El apellido debe contener solo letras sin espacios ni números.';
   END IF;
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER trg_validar_comprador
BEFORE INSERT ON Compradores
FOR EACH ROW
BEGIN
   -- Validar que COM_Nombre contenga solo letras (sin espacios o números)
   IF NEW.COM_Nombre NOT REGEXP '^[A-Za-z]+$' THEN
       SIGNAL SQLSTATE '45000'
         SET MESSAGE_TEXT = 'El nombre debe contener solo letras sin espacios ni números.';
   END IF;
   
   -- Validar que COM_Apellido contenga solo letras (sin espacios o números)
   IF NEW.COM_Apellido NOT REGEXP '^[A-Za-z]+$' THEN
       SIGNAL SQLSTATE '45000'
         SET MESSAGE_TEXT = 'El apellido debe contener solo letras sin espacios ni números.';
   END IF;
END //

DELIMITER ;
