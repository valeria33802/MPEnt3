CREATE VIEW vista_perifericos_compradores AS
    SELECT 
        ct.CATI_Nombre AS 'Tipo Periferico',
        c.CAT_Nombre AS 'Nombre',
        c.CATI_Descripcion AS 'Descripcion',
        c.CATI_Precio as 'Precio'
    FROM Catalogo c
    JOIN Catalogo_Tipos ct ON c.CAT_Tipo = ct.ID_Tipo;
    
    select * from vista_perifericos_compradores;
    
    
    
    create view faq_preguntas as
    select FAQ.F_Pregunta AS Pregunta
    from FAQ FAQ;
    
    call sp_historial_compra_ultimo_usuario();
    
    select * from vista_evaluaciones;
    Create view vista_evaluaciones AS 
    SELECT
		Co.CO_Calificacion AS 'Calificacion',
        Co.Descripción AS 'Descripción'
        from Comentarios CO;
        
        
create view ver_paises as
select pa.nombre as 'Paises'
from pais pa
    select * from ver_paises