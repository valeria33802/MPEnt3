
CREATE DATABASE IF NOT EXISTS MODPtest;
USE MODPtest;


CREATE TABLE Catalogo_Tipos (
    ID_Tipo CHAR(2) PRIMARY KEY,
    CATI_Nombre VARCHAR(50)
    -- Campos adicionales (comentados):
    -- CATI_Descripcion VARCHAR(200),
    -- CATI_Cantidad INT,
    -- CATI_Venta INT,
    -- CATI_Precio FLOAT
);


CREATE TABLE Catalogo (
    ID_Articulo VARCHAR(20) PRIMARY KEY,
    CAT_Tipo CHAR(2),
    CAT_Nombre VARCHAR(50) NOT NULL,
    CATI_Descripcion VARCHAR(200),
    CATI_Cantidad INT,
    CATI_Venta INT,
    CATI_Precio FLOAT,
    CONSTRAINT fk_catalogo_tipos 
        FOREIGN KEY (CAT_Tipo) 
        REFERENCES Catalogo_Tipos(ID_Tipo)
);


CREATE TABLE ServicioPorProducto (
    ID_Servicio VARCHAR(20) PRIMARY KEY,
    SE_Descripcion VARCHAR(200),
    Precio FLOAT,
    CAT_Tipo CHAR(2),
    CONSTRAINT fk_servicio_catalogo_tipos 
        FOREIGN KEY (CAT_Tipo) 
        REFERENCES Catalogo_Tipos(ID_Tipo)
);


CREATE TABLE Usuarios (
    ID_Usuario INT PRIMARY KEY AUTO_INCREMENT,
    US_Nombre_Usuario VARCHAR(50) UNIQUE NOT NULL,
    US_Correo VARCHAR(50) NOT NULL,
    US_Contrasenia VARBINARY(255) NOT NULL,
    US_Puesto CHAR(10),
    US_Estado CHAR(2)
);



CREATE TABLE Horarios (
    ID_Horario INT PRIMARY KEY AUTO_INCREMENT,
    H_Hora_inicio TIME,
    H_Hora_salida TIME,
    H_Descripcion VARCHAR(100)
);


CREATE TABLE Compradores (
    ID_Comprador INT PRIMARY KEY,
    COM_Nombre VARCHAR(50),
    COM_Apellido VARCHAR(50),
    COM_Direccion VARCHAR(200),
    CONSTRAINT fk_compradores_usuarios 
        FOREIGN KEY (ID_Comprador) 
        REFERENCES Usuarios(ID_Usuario)
);

CREATE TABLE Empleados (
    EMP_ID INT PRIMARY KEY,
    EMP_ID_Horario INT,
    EMP_Nombre VARCHAR(50) NOT NULL,
    EMP_Apellido VARCHAR(50) NOT NULL,
    CONSTRAINT fk_empleados_usuarios 
        FOREIGN KEY (EMP_ID) 
        REFERENCES Usuarios(ID_Usuario),
    CONSTRAINT fk_empleados_horarios 
        FOREIGN KEY (EMP_ID_Horario) 
        REFERENCES Horarios(ID_Horario)
);


CREATE TABLE Tarjetas (
    ID_Tarjeta INT PRIMARY KEY AUTO_INCREMENT,
    ID_Comprador INT,
    TAR_Nombre VARCHAR(25) NOT NULL,
    TAR_Num_Tarjeta VARBINARY(255) NOT NULL,
    TAR_Fecha_Vencimiento DATE, 
    TAR_Codigo_Seguridad VARBINARY(255), 
    TAR_Saldo FLOAT,
    CONSTRAINT fk_tarjetas_compradores 
        FOREIGN KEY (ID_Comprador) 
        REFERENCES Compradores(ID_Comprador)
);


CREATE TABLE FAQ (
    ID_Preguntas INT PRIMARY KEY AUTO_INCREMENT,
    F_Pregunta VARCHAR(100)
);


CREATE TABLE Comentarios (
    ID_Comentario INT PRIMARY KEY AUTO_INCREMENT,
    CO_Calificacion CHAR(2),
    Descripcion VARCHAR(200)
);

CREATE TABLE Progreso_Proyecto (
    ID_Proyecto_Progreso INT PRIMARY KEY AUTO_INCREMENT,
    Descripcion VARCHAR(150),
    Detalles VARCHAR(100)
);


CREATE TABLE Proyectos (
    ID_Empleado INT,
    ID_Proyecto INT PRIMARY KEY AUTO_INCREMENT,
    PRO_Progreso INT,
    ID_Articulo VARCHAR(20),
    ID_Comprador INT,
    CONSTRAINT fk_proyectos_empleados 
        FOREIGN KEY (ID_Empleado) 
        REFERENCES Empleados(EMP_ID),
    CONSTRAINT fk_proyectos_progreso 
        FOREIGN KEY (PRO_Progreso) 
        REFERENCES Progreso_Proyecto(ID_Proyecto_Progreso),
    CONSTRAINT fk_proyectos_catalogo 
        FOREIGN KEY (ID_Articulo) 
        REFERENCES Catalogo(ID_Articulo),
    CONSTRAINT fk_proyectos_compradores 
        FOREIGN KEY (ID_Comprador) 
        REFERENCES Compradores(ID_Comprador)
    -- Campo PRO_Estado omitido (comentado en el script original)
);


CREATE TABLE Proyecto_Modificaciones (
    ID_Proyecto INT,
    ID_Servicio VARCHAR(20),
    CONSTRAINT fk_proy_modif_proyectos 
        FOREIGN KEY (ID_Proyecto) 
        REFERENCES Proyectos(ID_Proyecto),
    CONSTRAINT fk_proy_modif_servicios 
        FOREIGN KEY (ID_Servicio) 
        REFERENCES ServicioPorProducto(ID_Servicio)
);


CREATE TABLE Feedback (
    ID_Feedback INT PRIMARY KEY AUTO_INCREMENT,
    FE_Estrellas SMALLINT,
    FE_Comentario VARCHAR(100)
);


CREATE TABLE Factura_Detalle (
    ID_Factura INT,
    -- Indica si la línea corresponde a un artículo estándar o a un proyecto personalizado
    ID_Proyecto INT NOT NULL,
    ID_Articulo VARCHAR(20) NOT NULL,
    ID_Tarjeta INT NOT NULL,
    ID_Comprador INT NOT NULL,
    FD_Cantidad INT DEFAULT 1,
    FA_Fecha DATE,
    FD_Precio FLOAT,
    FD_Precio_Final FLOAT,
    FA_Detalle VARCHAR(100),
    PRIMARY KEY (ID_Factura, ID_Proyecto, ID_Articulo),
    CONSTRAINT fk_factura_detalle_proyectos 
        FOREIGN KEY (ID_Proyecto) 
        REFERENCES Proyectos(ID_Proyecto),
    CONSTRAINT fk_factura_detalle_catalogo 
        FOREIGN KEY (ID_Articulo) 
        REFERENCES Catalogo(ID_Articulo), 
    CONSTRAINT fk_factura_detalle_tarjetas 
        FOREIGN KEY (ID_Tarjeta) 
        REFERENCES Tarjetas(ID_Tarjeta),
    CONSTRAINT fk_factura_detalle_compradores 
        FOREIGN KEY (ID_Comprador) 
        REFERENCES Compradores(ID_Comprador)
);

CREATE TABLE Historial_Login(
    ID_Login INT PRIMARY KEY AUTO_INCREMENT,
    ID_Usuario INT,
    US_Contrasenia VARCHAR(30) NOT NULL,
    US_Puesto CHAR(10),
    US_Tiempo DATETIME,
    CONSTRAINT fk_historial_login_usuarios 
        FOREIGN KEY (ID_Usuario) 
        REFERENCES Usuarios(ID_Usuario)
);


CREATE TABLE Login_Attempts (
    attempt_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    attempt_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    success BOOLEAN,
    CONSTRAINT fk_login_attempts_usuarios 
        FOREIGN KEY (user_id) 
        REFERENCES Usuarios(ID_Usuario)
);


CREATE TABLE Codigo (
    ID_Codigo INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    codigo VARCHAR(20),
    tiempo_creacion DATETIME,
    tiempo_vencimiento DATETIME,
    estado CHAR(1),
    CONSTRAINT fk_codigo_usuarios 
        FOREIGN KEY (user_id) 
        REFERENCES Usuarios(ID_Usuario)
);

-- Fin del script
