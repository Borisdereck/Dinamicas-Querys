
	
SELECT ACC.ID_SOLICITUD, OFE.ID_SOLICITUD, OFE.CENTRO_COSTOS_INGRESO, OFE.CENTRO_COSTOS_GASTOS, OFE.NUM_OS
FROM 		OPAV.OFERTAS 	AS OFE
INNER JOIN	OPAV.ACCIONES 	AS ACC  ON (OFE.ID_SOLICITUD = ACC.ID_SOLICITUD) 
WHERE centro_costos_ingreso != '' and centro_costos_gastos != '';

--db link ofertas y acciones
SELECT 		cc_selectrick.ID_SOLICITUD, 
	   		cc_selectrick.CENTRO_COSTOS_INGRESO,
	   		cc_selectrick.CENTRO_COSTOS_GASTOS,
	   		cc_selectrick.NUM_OS
    FROM dblink('dbname=selectrik 
   				port=5432 
   				host=localhost
   				user=postgres 
   				password=bdversion17'::text,
   				'SELECT OFE.ID_SOLICITUD, OFE.CENTRO_COSTOS_INGRESO, OFE.CENTRO_COSTOS_GASTOS, OFE.NUM_OS
				 FROM 		OPAV.OFERTAS 	AS OFE
				 INNER JOIN	OPAV.ACCIONES 	AS ACC  ON (OFE.ID_SOLICITUD = ACC.ID_SOLICITUD) 
				 WHERE centro_costos_ingreso != '''' and centro_costos_gastos != '''''::text ) 
    cc_selectrick(ID_SOLICITUD character varying,
		  CENTRO_COSTOS_INGRESO character varying,
		  CENTRO_COSTOS_GASTOS character varying,
		  NUM_OS character varying);
