-- View: sl_centro_costos_selectrik_dblink

-- DROP VIEW sl_centro_costos_selectrik_dblink;

CREATE OR REPLACE VIEW sl_centro_costos_selectrik_dblink AS 

 SELECT 		cc_selectrick.ID_ACCION,
			cc_selectrick.ID_SOLICITUD, 
	   		cc_selectrick.CENTRO_COSTOS_INGRESO,
	   		cc_selectrick.CENTRO_COSTOS_GASTOS,
	   		cc_selectrick.NUM_OS
    FROM dblink('dbname=selectrik 
   				port=5432 
   				host=localhost
   				user=postgres 
   				password=bdversion17'::text,
   				'SELECT ACC.ID_ACCION, OFE.ID_SOLICITUD, OFE.CENTRO_COSTOS_INGRESO, OFE.CENTRO_COSTOS_GASTOS, OFE.NUM_OS
				 FROM 		OPAV.OFERTAS 	AS OFE
				 INNER JOIN	OPAV.ACCIONES 	AS ACC  ON (OFE.ID_SOLICITUD = ACC.ID_SOLICITUD) 
				 '::text ) 
    cc_selectrick(ID_ACCION character varying,
		  ID_SOLICITUD character varying,
		  CENTRO_COSTOS_INGRESO character varying,
		  CENTRO_COSTOS_GASTOS character varying,
		  NUM_OS character varying);
		  
ALTER TABLE sl_centro_costos_selectrik_dblink
  OWNER TO postgres;

--SELECT * FROM sl_centro_costos_selectrik_dblink LIMIT 500;

