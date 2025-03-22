USE modp;


DROP VIEW IF EXISTS vista_perifericos_compradores;
CREATE VIEW vista_perifericos_compradores AS
    SELECT 
        ct.CATI_Nombre AS 'Tipo Periferico',
        c.CAT_Nombre AS 'Nombre',
        c.CATI_Descripcion AS 'Descripcion',
        c.CATI_Precio AS 'Precio'
    FROM Catalogo c
    JOIN Catalogo_Tipos ct ON c.CAT_Tipo = ct.ID_Tipo;


DROP VIEW IF EXISTS faq_preguntas;
CREATE VIEW faq_preguntas AS
    SELECT F_Pregunta AS Pregunta
    FROM FAQ;


CALL sp_historial_compra_ultimo_usuario();

DROP VIEW IF EXISTS vista_evaluaciones;
CREATE VIEW vista_evaluaciones AS 
    SELECT
        Co.CO_Calificacion AS 'Calificacion',
        Co.Descripción AS 'Descripción'
    FROM Comentarios Co;

-- Consulta de la vista Evaluaciones
SELECT * FROM vista_evaluaciones;

DROP VIEW IF EXISTS ver_paises;
CREATE VIEW ver_paises AS
    SELECT pa.nombre AS 'Paises'
    FROM pais pa;

-- Consulta de la vista Paises
SELECT * FROM ver_paises;
