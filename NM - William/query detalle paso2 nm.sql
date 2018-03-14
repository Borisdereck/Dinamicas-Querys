﻿SELECT 
	FAC.FECHA_FACTURA , 
	FAC.FECHA_VENCIMIENTO ,
	FAC.PERIODO,
	FAC.NIT  ,
	FAC.REFERENCIA_1 AS ID_SOLICITUD,
	OFE.CENTRO_COSTOS_INGRESO,
	OFE.CENTRO_COSTOS_GASTOS,
	'DOCUMENTO TRASLADO NMTR FACTURA: '||INGD.NUM_INGRESO||' SV: '||FAC.REF2 AS DESCRIPCION,
	INGD.TIPO_DOC AS TIPO_DOCUMENTO,
	'DTR-'||CMC.CUENTA AS CUENTA,
	sum(FACD.VALOR_ITEM) as VALOR_CREDT,
	--INGD.VALOR_INGRESO AS VALOR_DEB,
	0  AS VALOR_CREDT,
	FAC.DOCUMENTO AS DOCUMENTO
FROM CON.FACTURA AS FAC
INNER JOIN CON.FACTURA_DETALLE 	AS FACD ON ( FACD.DSTRCT = FAC.DSTRCT AND FACD.TIPO_DOCUMENTO = FAC.TIPO_DOCUMENTO AND FACD.DOCUMENTO = FAC.DOCUMENTO )
INNER JOIN OPAV.OFERTAS	AS OFE	ON (FAC.REFERENCIA_1 = OFE.ID_SOLICITUD)
INNER JOIN CON.INGRESO_DETALLE  AS INGD  ON (FAC.NUMERO_NC = INGD.NUM_INGRESO  AND FAC.DOCUMENTO=INGD.DOCUMENTO AND FAC.TIPO_DOCUMENTO=INGD.TIPO_DOC) 
INNER JOIN CON.CMC_DOC AS CMC	ON (INGD.TIPO_DOC= CMC.TIPODOC AND FAC.CMC = CMC.CMC )		
WHERE 
FAC.DOCUMENTO='NM12756_1'  
AND FACD.CODIGO_CUENTA_CONTABLE !='13050702'
AND FAC.REG_STATUS =''	
AND FAC.TIPO_DOCUMENTO='FAC'
GROUP BY 
	FAC.FECHA_FACTURA , 
	FAC.FECHA_VENCIMIENTO ,
	FAC.PERIODO,
	FAC.NIT  ,
	FAC.REFERENCIA_1,
	OFE.CENTRO_COSTOS_INGRESO,
	OFE.CENTRO_COSTOS_GASTOS,
	INGD.NUM_INGRESO,
	FAC.REF2 ,
	INGD.TIPO_DOC,
	CMC.CUENTA ,
	INGD.VALOR_INGRESO ,	
	FAC.DOCUMENTO 
			
UNION ALL
		
SELECT 
	FAC.FECHA_FACTURA , 
	FAC.FECHA_VENCIMIENTO ,
	FAC.PERIODO,
	FAC.NIT  ,
	FAC.REFERENCIA_1 AS ID_SOLICITUD,
	OFE.CENTRO_COSTOS_INGRESO,
	OFE.CENTRO_COSTOS_GASTOS,
	'DOCUMENTO TRASLADO NMTR FACTURA: '||INGD.NUM_INGRESO||' SV: '||FAC.REF2 AS DESCRIPCION,
	INGD.TIPO_DOC AS TIPO_DOCUMENTO,
	CMC.CUENTA,
	0 AS VALOR_DEB,
	sum(FACD.VALOR_ITEM) AS VALOR_DEB,
	--INGD.VALOR_INGRESO  AS VALOR_CREDT,
	FAC.DOCUMENTO AS DOCUMENTO
FROM CON.FACTURA AS FAC
INNER JOIN CON.FACTURA_DETALLE 	AS FACD ON ( FACD.DSTRCT = FAC.DSTRCT AND FACD.TIPO_DOCUMENTO = FAC.TIPO_DOCUMENTO AND FACD.DOCUMENTO = FAC.DOCUMENTO )
INNER JOIN OPAV.OFERTAS	AS OFE	ON (FAC.REFERENCIA_1 = OFE.ID_SOLICITUD)
INNER JOIN CON.INGRESO_DETALLE  AS INGD  ON (FAC.NUMERO_NC = INGD.NUM_INGRESO  AND FAC.DOCUMENTO=INGD.DOCUMENTO AND FAC.TIPO_DOCUMENTO=INGD.TIPO_DOC) 
INNER JOIN CON.CMC_DOC AS CMC	ON (INGD.TIPO_DOC= CMC.TIPODOC AND FAC.CMC = CMC.CMC )		
WHERE 
 FAC.DOCUMENTO='NM12756_1'
AND FACD.CODIGO_CUENTA_CONTABLE !='13050702'
AND FAC.REG_STATUS =''	
AND FAC.TIPO_DOCUMENTO='FAC'
group by FAC.FECHA_FACTURA , 
	FAC.FECHA_VENCIMIENTO ,
	FAC.PERIODO,
	FAC.NIT  ,
	FAC.REFERENCIA_1 ,
	OFE.CENTRO_COSTOS_INGRESO,
	OFE.CENTRO_COSTOS_GASTOS,
	INGD.NUM_INGRESO,
	FAC.REF2 ,
	INGD.TIPO_DOC ,
	CMC.CUENTA,	
	--INGD.VALOR_INGRESO  AS VALOR_CREDT,
	FAC.DOCUMENTO 