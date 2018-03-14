﻿SELECT 
	FAC.FECHA_FACTURA , 
	FAC.FECHA_VENCIMIENTO ,
	FAC.PERIODO,
	FAC.NIT  ,
	FAC.REFERENCIA_1 AS ID_SOLICITUD,
	SLT.centro_costo_ingreso AS CENTRO_COSTOS_INGRESO,
	SLT.centro_costo_gasto AS CENTRO_COSTOS_GASTOS,
	'DOCUMENTO TRASLADO NMTR FACTURA: '||INGD.NUM_INGRESO||' SV: '||FAC.REF2 AS DESCRIPCION,
	INGD.TIPO_DOC AS TIPO_DOCUMENTO,
	'DPM-'||CMC.CUENTA AS CUENTA,
	sum(FACD.VALOR_ITEM) as VALOR_CREDT,
	--INGD.VALOR_INGRESO AS VALOR_DEB,
	0  AS VALOR_CREDT,
	FAC.DOCUMENTO AS DOCUMENTO
FROM CON.FACTURA AS FAC
INNER JOIN CON.FACTURA_DETALLE 	AS FACD ON ( FACD.DSTRCT = FAC.DSTRCT AND FACD.TIPO_DOCUMENTO = FAC.TIPO_DOCUMENTO AND FACD.DOCUMENTO = FAC.DOCUMENTO )
INNER JOIN CON.SL_TRASLADO_FACTURAS_APOTEOSYS	AS SLT	ON (FAC.REFERENCIA_1 = SLT.ID_SOLICITUD  AND FAC.DOCUMENTO = SLT.DOCUMENTO)
INNER JOIN CON.INGRESO_DETALLE  AS INGD  ON (FAC.DOCUMENTO = INGD.NUM_INGRESO  AND FAC.DOCUMENTO=INGD.DOCUMENTO AND FAC.TIPO_DOCUMENTO=INGD.TIPO_DOC) 
INNER JOIN CON.CMC_DOC AS CMC	ON (INGD.TIPO_DOC= CMC.TIPODOC AND FAC.CMC = CMC.CMC )		
WHERE 
---INGD.NUM_INGRESO =FACTURA_NM.DOCUMENTO
--AND FAC.REFERENCIA_1 =FACTURA_NM.ID_SOLICITUD
--AND FAC.REF1 =FACTURA_NM.NUM_OS
FAC.DOCUMENTO=FACTURA_NM.DOCUMENTO
AND FACD.CODIGO_CUENTA_CONTABLE ='13050702' --VALIDAR LO DE LA CUENTA
AND FAC.REG_STATUS =''	
AND FAC.TIPO_DOCUMENTO='FAC'
GROUP BY 
	FAC.FECHA_FACTURA , 
	FAC.FECHA_VENCIMIENTO ,
	FAC.PERIODO,
	FAC.NIT  ,
	FAC.REFERENCIA_1 ,
	SLT.centro_costo_ingreso ,
	SLT.centro_costo_gasto ,
	INGD.NUM_INGRESO,
	FAC.REF2 ,
	INGD.TIPO_DOC ,
	CMC.CUENTA ,
	--INGD.VALOR_INGRESO AS VALOR_DEB,	
	FAC.DOCUMENTO AS DOCUMENTO
			
UNION ALL
		
SELECT 
	FAC.FECHA_FACTURA , 
	FAC.FECHA_VENCIMIENTO ,
	FAC.PERIODO,
	FAC.NIT  ,
	FAC.REFERENCIA_1 AS ID_SOLICITUD,
	SLT.centro_costo_ingreso AS CENTRO_COSTOS_INGRESO,
	SLT.centro_costo_gasto AS CENTRO_COSTOS_GASTOS,
	'DOCUMENTO TRASLADO NMTR FACTURA: '||INGD.NUM_INGRESO||' SV: '||FAC.REF2 AS DESCRIPCION,
	INGD.TIPO_DOC AS TIPO_DOCUMENTO,
	CMC.CUENTA,
	0 AS VALOR_DEB,
	sum(FACD.VALOR_ITEM) AS VALOR_DEB,
	--INGD.VALOR_INGRESO  AS VALOR_CREDT,
	FAC.DOCUMENTO AS DOCUMENTO
FROM CON.FACTURA AS FAC
INNER JOIN CON.FACTURA_DETALLE 	AS FACD ON ( FACD.DSTRCT = FAC.DSTRCT AND FACD.TIPO_DOCUMENTO = FAC.TIPO_DOCUMENTO AND FACD.DOCUMENTO = FAC.DOCUMENTO )
INNER JOIN CON.SL_TRASLADO_FACTURAS_APOTEOSYS	AS SLT	ON (FAC.REFERENCIA_1 = SLT.ID_SOLICITUD  AND FAC.DOCUMENTO = SLT.DOCUMENTO)
INNER JOIN CON.INGRESO_DETALLE  AS INGD  ON (FAC.DOCUMENTO = INGD.NUM_INGRESO  AND FAC.DOCUMENTO=INGD.DOCUMENTO AND FAC.TIPO_DOCUMENTO=INGD.TIPO_DOC) 
INNER JOIN CON.CMC_DOC AS CMC	ON (INGD.TIPO_DOC= CMC.TIPODOC AND FAC.CMC = CMC.CMC )		
WHERE 					 
--INGD.NUM_INGRESO =FACTURA_NM.DOCUMENTO
--AND FAC.REFERENCIA_1 =FACTURA_NM.ID_SOLICITUD
--AND FAC.REF1 =FACTURA_NM.NUM_OS
FAC.DOCUMENTO=FACTURA_NM.DOCUMENTO
AND INGD.CUENTA ='13050701' --VALIDAR LO DE LA CUENTA
AND FAC.REG_STATUS =''	
AND FAC.TIPO_DOCUMENTO='FAC'
GROUP BY 
	FAC.FECHA_FACTURA , 
	FAC.FECHA_VENCIMIENTO ,
	FAC.PERIODO,
	FAC.NIT  ,
	FAC.REFERENCIA_1 ,
	SLT.centro_costo_ingreso ,
	SLT.centro_costo_gasto ,
	INGD.NUM_INGRESO,
	FAC.REF2 ,
	INGD.TIPO_DOC ,
	CMC.CUENTA,
	--INGD.VALOR_INGRESO  AS VALOR_CREDT,
	FAC.DOCUMENTO 
