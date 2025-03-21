/*CREATE DATABASE MODP;
USE MODP;*/

USE modp;

CREATE DATABASE MODPtest;
USE MODPtest;
DROP DATABASE MODPtest;
-- categorías del periferico 

create table Catalogo_Tipos(
ID_Tipo char(2) primary key,
CATI_Nombre varchar(50)
/*CATI_Descripcion varchar(200),
CATI_Cantidad int,
CATI_Venta int,
CATI_Precio float*/);

-- artículos y modelos del catálogo
create table Catalogo(
ID_Articulo VARCHAR(20) PRIMARY KEY,
CAT_Tipo char(2) references Catalogo_Tipos(ID_Tipo),
CAT_Nombre VARCHAR(50) NOT NULL,
CATI_Descripcion varchar(200),
CATI_Cantidad int,
CATI_Venta int,
CATI_Precio float
);

-- estos son los servicios de prsonalizacion por el tipo de periferico
Create table ServicioPorProducto(
ID_Servicio varchar(20) primary key,
SE_Descripcion varchar(200),
Precio float,
CAT_Tipo char(2) references Catalogo_Tipos(ID_Tipo)
);

/* table ServicioPorProducto
ADD COLUMN CAT_Tipo char(2) references Catalogo_Tipos(ID_Tipo);*/

-- usuarios en general
Create table Usuarios(
ID_Usuario int primary key auto_increment,
US_Nombre_Usuario varchar(50) NOT NULL,
US_Correo varchar(50) NOT NULL,
US_Contrasenia VARBINARY(255) NOT NULL,
US_Puesto char(10),
US_Estado char(2)
);

-- horarios de los empleados
Create table Horarios(
ID_Horario int primary key auto_increment,
H_Hora_inicio time,
H_Hora_salida time,
H_Descripcion varchar (100));

-- son los compradores de la tienda
Create table Compradores(
ID_Comprador int PRIMARY KEY references Usuarios(ID_Usuario),
COM_Nombre varchar(50) NULL,
COM_Apellido varchar(50) NULL,
COM_Direccion varchar(200) NULL

);

-- empleados
Create table Empleados(
EMP_ID int PRIMARY KEY references Usuarios(ID_Usuario),
EMP_ID_Horario int references Horarios(ID_Horario),
EMP_Nombre varchar(50) NOT NULL,
EMP_Apellido varchar(50) NOT NULL

);

-- tarjetas de los compradores
create table Tarjetas(
ID_Tarjeta INT PRIMARY KEY auto_increment,
ID_Comprador int references Compradores(ID_Comprador),
TAR_Nombre varchar(25) NOT NULL,
TAR_Num_Tarjeta VARBINARY(255) NOT NULL,
TAR_Fecha_Vencimiento date, 
TAR_Codigo_Seguridad VARBINARY(255), 
TAR_Saldo float

);

-- preguntas frecuentes
Create table FAQ(
ID_Preguntas int primary key auto_increment,
F_Pregunta varchar(100));




/*Create table Factura(
ID_Factura INT PRIMARY KEY auto_increment,
ID_Comprador INT REFERENCES Usuario(ID_Usuario),
ID_Tarjeta int references Tarjetas(ID_Tarjeta),
FA_Detalle varchar(100),
FA_Fecha date,
FA_Monto_final float
);*/

-- Calificacion y comentarios
Create table Comentarios(
ID_Comentario INT PRIMARY KEY AUTO_INCREMENT,
CO_Calificacion char(2),
Descripción varchar(200));

-- progreso del proyecto diferenciado por números 
Create table Progreso_Proyecto(
ID_Proyecto_Progreso INT PRIMARY KEY AUTO_INCREMENT,
Descripcion varchar(150),
Detalles varchar(100)
);

-- proyecto 

Create table Proyectos(
ID_Empleado INT REFERENCES Empleados(ID_Empleado),
ID_Proyecto INT PRIMARY KEY AUTO_INCREMENT,
PRO_Progreso int references Progreso_Proyecto(ID_Proyecto_Progreso),
ID_Articulo varchar(20) references Catalogo(ID_Articulo),
ID_Comprador int references Compradores(ID_Comprador)
/*PRO_Estado char(2)*/);

-- se le asignan las modificaciones al proyecto

Create table Proyecto_Modificaciones(
ID_Proyecto int references Proyectos(ID_Proyecto),
ID_Servicio varchar(20) references ServicioPorProducto(ID_Servicio));

Create table Feedback(ID_Feedback int primary key auto_increment,
FE_Estrellas smallint,
FE_Comentario varchar(100));

CREATE TABLE Factura_Detalle (
    ID_Factura INT,
    -- Identifies if this line is a standard catalog item or a custom project
    ID_Proyecto INT NOT NULL,
    ID_Articulo VARCHAR(20) NOT NULL,
    ID_Tarjeta INT NOT NULL,
    ID_Comprador INT NOT NULL,
    FD_Cantidad INT DEFAULT 1,
    FA_Fecha date,
    FD_Precio FLOAT,
    FD_Precio_Final FLOAT,
    FA_Detalle varchar(100),
    PRIMARY KEY (id_Factura, ID_Proyecto, ID_Articulo),

    -- Optional FK to Proyectos
    FOREIGN KEY (ID_Proyecto) REFERENCES Proyectos(ID_Proyecto),
    -- Optional FK to Catalogo
    FOREIGN KEY (ID_Articulo) REFERENCES Catalogo(ID_Articulo), 
    FOREIGN KEY (ID_Tarjeta) REFERENCES Tarjetas(ID_Tarjeta),
    FOREIGN KEY (ID_Comprador) REFERENCES Compradores(ID_Comprador)
    
);


CREATE TABLE Historial_Login(
ID_Login int primary key auto_increment,
US_Nombre_Usuario varchar(50) references Usuarios(US_Nombre_Usuario),
US_Contrasenia varchar(30) NOT NULL,
US_Puesto char(10),
US_Tiempo DATETIME);

CREATE TABLE Login_Attempts (
    attempt_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT references Usuarios(ID_Usuario),
    attempt_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    success BOOLEAN
);

Create table Codigo(
ID_Codigo int primary key auto_increment,
user_id INT references Usuarios(ID_Usuario), 
codigo varchar(20),
tiempo_creacion DATETIME,
tiempo_vencimiento DATETIME,
estado char(1)
)




