﻿
------------------Query Principal------------------
SELECT EGRE.PERIODO, 
       T.HANDLE_CODE,
       EGRE.DOCUMENT_NO, 
       T.DOCUMENTO,
       EGDET.DESCRIPTION, 
       T.TIPO_DOCUMENTO, 
       EGRE.BRANCH_CODE AS BANCO, 
       EGRE.BANK_ACCOUNT_NO AS SUCURSAL, 
       EGRE.FECHA_CHEQUE AS FECHA_EGRESO,
       EGRE.CREATION_DATE::DATE,
       --T.FECHA_VENCIMIENTO,
       T.PROVEEDOR AS NIT,
       EGDET.VLR,
       COALESCE(EGDET.PROCESADO,'N') AS PROCESADO,
       T.CENTRO_COSTOS_INGRESO
FROM  EGRESO EGRE
INNER JOIN EGRESODET  EGDET ON (EGRE.DOCUMENT_NO =EGDET.DOCUMENT_NO AND EGRE.BRANCH_CODE=EGDET.BRANCH_CODE AND EGRE.BANK_ACCOUNT_NO=EGDET.BANK_ACCOUNT_NO)
INNER JOIN (SELECT 
		      'NUMOS'::VARCHAR AS TIPO_REFERENCIA_1,
		      ORDENCOMPRA.MULTISERVICIO AS REFERENCIA_1,
		      ORDENCOMPRA.NIT_PROVEEDOR AS  PROVEEDOR,
		      GET_NOMBP(ORDENCOMPRA.NIT_PROVEEDOR) AS NOMBRE_PROVEEDOR,
		      CXP.BANCO,
		      CXP.SUCURSAL,
		      CXP.TIPO_DOCUMENTO,	
		      CXP.DOCUMENTO,
		      ORDENCOMPRA.COD_ORDEN,
		      CXP.VLR_NETO,
		      CXP.HANDLE_CODE,
		      OFE.CENTRO_COSTOS_INGRESO        
		FROM ORDENCOMPRA ORDENCOMPRA
		INNER JOIN (SELECT FAC_PROV,COD_ORDEN FROM RELACION_OC_FAC WHERE REG_STATUS='' GROUP BY FAC_PROV,COD_ORDEN) ROCXP  ON (ROCXP.COD_ORDEN=ORDENCOMPRA.COD_ORDEN)
		INNER JOIN FIN.CXP_DOC CXP ON (CXP.DOCUMENTO=ROCXP.FAC_PROV AND CXP.PROVEEDOR=ORDENCOMPRA.NIT_PROVEEDOR AND CXP.REG_STATUS='')
		INNER JOIN OFERTAS_VIEW_DBLINK_B OFE ON (ORDENCOMPRA.MULTISERVICIO = OFE.ID_SOLICITUD )
		WHERE  ORDENCOMPRA.REG_STATUS='' 
		GROUP BY 
		ORDENCOMPRA.MULTISERVICIO,						--SELECT * FROM OFERTAS_VIEW_DBLINK_B LIMIT 1
		ORDENCOMPRA.NIT_PROVEEDOR,
		CXP.DOCUMENTO,
		CXP.TIPO_DOCUMENTO,
		ORDENCOMPRA.COD_ORDEN,
		CXP.VLR_NETO,
		CXP.BANCO,
		CXP.SUCURSAL,
		CXP.HANDLE_CODE,
		OFE.CENTRO_COSTOS_INGRESO 
          ) T ON (T.TIPO_DOCUMENTO = EGDET.TIPO_DOCUMENTO AND T.DOCUMENTO=EGDET.DOCUMENTO AND T.BANCO = EGDET.BRANCH_CODE AND T.SUCURSAL = EGDET.BANK_ACCOUNT_NO AND T.TIPO_DOCUMENTO=EGDET.TIPO_DOCUMENTO )
WHERE 
EGRE.PERIODO = '201701'
AND SUBSTRING(EGRE.DOCUMENT_NO,1,2) ='BC'
AND EGRE.document_no  ='BC3210'
AND EGRE.REG_STATUS=''
AND EGDET.REG_STATUS=''
--AND COALESCE(EGDET.PROCESADO,'N')='N'
 

------------------Query Detalle Transaccion------------------
SELECT  
	EGREDET.TIPO_DOCUMENTO,
	CMC.CUENTA AS CUENTA,
	CASE WHEN EGREDET.VLR>0 THEN EGREDET.VLR ELSE 0 END AS  VALOR_DEB,
	CASE WHEN EGREDET.VLR<0 THEN EGREDET.VLR*-1 ELSE 0 END AS VALOR_CREDT,
	EGREDET.DESCRIPTION AS DESCRIPCION,
	EGREDET.DOCUMENTO AS DOCUMENTO
FROM EGRESODET AS EGREDET	
INNER JOIN CON.CMC_DOC AS CMC ON (CMC.TIPODOC = EGREDET.TIPO_DOCUMENTO AND 'PD'=CMC.CMC)
WHERE EGREDET.DOCUMENTO = 'BQCR8130425'   --
 AND EGREDET.DOCUMENT_NO = 'BC3210' --
 AND EGREDET.TIPO_DOCUMENTO = 'FAP'
 AND EGREDET.BRANCH_CODE = 'CAJA TEMPORAL' --
 AND EGREDET.BANK_ACCOUNT_NO = 'CAJA FINTRA' 	 --

UNION ALL

SELECT  
	EGREDET.TIPO_DOCUMENTO,
	COALESCE((SELECT CODIGO_CUENTA FROM BANCO  WHERE BRANCH_CODE = 'CAJA TEMPORAL' AND BANK_ACCOUNT_NO = 'CAJA FINTRA'),'00000000') AS CUENTA,
	CASE WHEN EGREDET.VLR<0 THEN EGREDET.VLR*-1 ELSE 0 END AS VALOR_DEB,
	CASE WHEN EGREDET.VLR>0 THEN EGREDET.VLR ELSE 0 END AS  VALOR_CREDT,
	'BANCOS'::TEXT AS DESCRIPCION, 
	EGREDET.DOCUMENT_NO AS DOCUMENTO
FROM EGRESODET AS EGREDET
WHERE EGREDET.DOCUMENTO = 'BQCR8130425'   --
 AND EGREDET.DOCUMENT_NO = 'BC3210' --
 AND EGREDET.TIPO_DOCUMENTO = 'FAP'
 AND EGREDET.BRANCH_CODE = 'CAJA TEMPORAL' --
 AND EGREDET.BANK_ACCOUNT_NO = 'CAJA FINTRA'

