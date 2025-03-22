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




DROP VIEW IF EXISTS vista_evaluaciones;
CREATE VIEW vista_evaluaciones AS 
    SELECT
        Co.CO_Calificacion AS 'Calificacion',
        Co.Descripcion AS 'Descripción'
    FROM Comentarios Co;


-- Consulta de la vista Paises

