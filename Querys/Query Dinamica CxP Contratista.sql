--buscamos los documentos 
select * from fin.cxp_doc where tipo_documento = 'FAP' AND PERIODO = '201703' AND DOCUMENTO ILIKE 'CC%';
--detalle de los documentos
select * from fin.cxp_items_doc where documento = 'CC763-000111' and tipo_documento = 'FAP';

--buscamos a q accion se refiere
SELECT * FROM opav.acciones where id_accion = '9038989'


SELECT * FROM opav.acciones where id_solicitud = '923475'


