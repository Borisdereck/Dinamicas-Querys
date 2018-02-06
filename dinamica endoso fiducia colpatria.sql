﻿--"PM09975_36"

SELECT 
		CPD.CUENTA 				AS CODIGO_CUENTA, 
		CPD.DETALLE || ' '||CPD.REFERENCIA_1 	AS DESCRIPCION, 
		SUM(CPD.VALOR_DEBITO) 			AS DEBITO,
		SUM(CPD.VALOR_CREDITO)			AS CREDITO,
		'A1111F32201' 				AS CENTRO_COSTO,
		CPD.TIPODOC 				AS DOCUMENTO_SOPORTE,
		CPD.NUMDOC				AS DOC_SOPORTE,
		CPD.DOCUMENTO_REL		AS REF	
	
 FROM 		CON.COMPROBANTE 	AS CP
 INNER JOIN 	CON.COMPRODET  		AS CPD 		ON (CP.NUMDOC = CPD.NUMDOC)
 WHERE 
		--CPD.PERIODO 		= '201701'
		--AND CPD.TIPODOC		= 'CDIAR' 
		--AND CPD.CUENTA 		= 16252115
		CP.REG_STATUS 	= ''
		AND CPD.REG_STATUS 	= ''
		--AND SUBSTRING(CPD.DETALLE,1,2) = 'SV'
		--AND CPD.cuenta = '16252115'
		and CP.NUMDOC = ''
	
GROUP BY 
		CPD.CUENTA,
		CPD.DETALLE,
		CPD.TIPODOC, 
		CPD.NUMDOC,
		CPD.DOCUMENTO_REL,
		CPD.REFERENCIA_1 


-- SELECT * FROM CON.COMPRODET  WHERE NUMDOC = 'PM09975_36' ;

/*COMPROBAMOS Q LAS CUENTAS ENTEN EN 
  COMPRODET
*/
   -- SELECT  *
--    FROM CON.COMPRODET 
--    WHERE CUENTA IN ('16252115') 
--          AND SUBSTRING(NUMDOC,1,2) = 'PM' 
--    ORDER BY PERIODO DESC 
--    LIMIT 100 ;


/***********************************/
--QUERY PRINCIPAL
SELECT 
		fac.documento ,--
		fac.fecha_factura , 
		fac.fecha_vencimiento ,
		fac.periodo,
		fac.nit  ,
		fac.referencia_1 as id_solicitud,--
		fac.descripcion,
		CPD.DOCUMENTO_REL AS NUM_OS
FROM CON.FACTURA as fac
INNER JOIN CON.COMPRODET AS CPD ON (FAC.DOCUMENTO = CPD.numdoc )
WHERE 
		FAC.REG_STATUS 		= ''
		AND CPD.PERIODO		>= '201701'
		AND fac.endoso_fiducia = 'S'
	
	--AND SUBSTRING(CPD.DETALLE,1,2) = tipo_
GROUP BY 
		fac.documento ,--
		fac.fecha_factura , 
		fac.fecha_vencimiento ,
		fac.periodo,
		fac.nit  ,
		fac.referencia_1,--
		fac.descripcion,
		CPD.DOCUMENTO_REL 

--END QUERY PRINCIPAL
/***********************************/


-- SELECT * FROM CON.COMPRODET LIMIT 1;

-- SELECT * FROM CON.COMPROBANTE WHERE ENDOSO_FIDUCIA = 'S'  ORDER BY PERIODO DESC LIMIT 1;	

--SELECT  * FROM CON.COMPRODET CPD WHERE CPD.REG_STATUS = '' AND CPD.CODIGO_CUENTA = '13050708' AND CPD.DOC_SOPORTE LIKE 'DM%'    "PM12743_10"

/**********************************/
--DOCUMENTO DE SOPORTE
SELECT  NUMDOC 
FROM CON.COMPRODET CPD 
WHERE CPD.NUMDOC LIKE 'DM%' 
      AND CPD.CUENTA IN ('16252115','13050708') 
      AND CPD.DOCUMENTO_REL = 'PM12743_10' 
GROUP BY 1 
LIMIT 50;


/**********************************************************************************************/
--BUSCAMOS LA INFORMACION COMPLETA QUE CONFORMARA EL ASIENTO CONTABLE PARA MANDARLO A APOTEOSYS

SELECT 
	CPD.CUENTA 				AS CODIGO_CUENTA, 
	CPD.DETALLE || ' '||CPD.REFERENCIA_1 	AS DESCRIPCION, 
	SUM(CPD.VALOR_DEBITO) 			AS DEBITO,
	SUM(CPD.VALOR_CREDITO)			AS CREDITO,
	'A1111F32201' 				AS CENTRO_COSTO,
	CPD.TIPODOC 				AS DOCUMENTO_SOPORTE,
	CPD.NUMDOC				AS DOC_SOPORTE,
	CPD.DOCUMENTO_REL		AS REF	
	
 FROM 		CON.COMPROBANTE 	AS CP
 INNER JOIN 	CON.COMPRODET  		AS CPD 		ON (CP.NUMDOC = CPD.NUMDOC)
 WHERE 
	 CPD.TIPODOC		= 'CDIAR' 
	AND CPD.CUENTA 		= '16252115'
	AND CP.REG_STATUS 	= ''
	AND CPD.REG_STATUS 	= ''
	--AND SUBSTRING(CPD.DETALLE,1,2) = 'SV'
	AND CPD.NUMDOC = (SELECT  CPD.NUMDOC 
				FROM CON.COMPRODET CPD 
				WHERE CPD.NUMDOC LIKE 'DM%' 
				      AND CPD.CUENTA IN ('16252115','13050708') 
				      AND CPD.DOCUMENTO_REL = 'PM12743_10' 
				GROUP BY 1 )

GROUP BY 
	CPD.CUENTA,
	CPD.DETALLE,
	CPD.TIPODOC, 
	CPD.NUMDOC,
	CPD.DOCUMENTO_REL,
	CPD.REFERENCIA_1 
union all
SELECT 
	CPD.CUENTA 		AS CODIGO_CUENTA, 
	CPD.DETALLE || ' '||CPD.REFERENCIA_1 	AS DESCRIPCION, 
	SUM(CPD.VALOR_DEBITO) 	AS DEBITO,
	SUM(CPD.VALOR_CREDITO)	AS CREDITO,
	'A1111F32201' 		AS CENTRO_COSTO,
	CPD.TIPODOC 		AS DOCUMENTO_SOPORTE,
	CPD.NUMDOC		AS DOC_SOPORTE,
	CPD.DOCUMENTO_REL	AS REF	
	
 FROM 		CON.COMPROBANTE 	AS CP
 INNER JOIN 	CON.COMPRODET  		AS CPD 	ON (CP.NUMDOC = CPD.NUMDOC)	
 WHERE 	
	 CPD.TIPODOC		= 'CDIAR' 
	AND CPD.CUENTA 		= 13050708
	AND CP.REG_STATUS 	= ''
	AND CPD.REG_STATUS 	= ''
	--AND SUBSTRING(CPD.DETALLE,1,2) = 'SV'
	AND CPD.NUMDOC = (SELECT  CPD.NUMDOC 
				FROM CON.COMPRODET CPD 
				WHERE CPD.NUMDOC LIKE 'DM%' 
				      AND CPD.CUENTA IN ('16252115','13050708') 
				      AND CPD.DOCUMENTO_REL = 'PM12743_10' 
				GROUP BY 1 )		

GROUP BY 
	CPD.CUENTA,
	CPD.DETALLE,
	CPD.TIPODOC, 
	CPD.NUMDOC,
	CPD.DOCUMENTO_REL,
	CPD.REFERENCIA_1

--BUSCAMOS LA INFORMACION COMPLETA QUE CONFORMARA EL ASIENTO CONTABLE PARA MANDARLO A APOTEOSYS
/**********************************************************************************************/



			