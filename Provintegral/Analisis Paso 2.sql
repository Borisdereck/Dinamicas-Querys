-----------------QUERY DETALLE-----------------
SELECT TIPO_DOCUMENTO,
	CMC.CUENTA AS CUENTA,
	CASE WHEN VALOR_FACTURA>0 THEN VALOR_FACTURA ELSE 0 END AS VALOR_DEB ,	
        CASE WHEN VALOR_FACTURA<0 THEN VALOR_FACTURA*-1 ELSE 0 END AS VALOR_CREDT,	
	DESCRIPCION AS DESCRIPCION,
	DOCUMENTO AS DOCUMENTO 
FROM CON.FACTURA FAC
INNER JOIN CON.CMC_DOC AS CMC  ON (CMC.CMC = FAC.CMC AND CMC.TIPODOC = FAC.TIPO_DOCUMENTO) 
WHERE DOCUMENTO = 'R0032227'
 AND TIPO_DOCUMENTO = 'FAC'
 AND FAC.REG_STATUS = ''
 AND NIT = '9000742958'

UNION ALL

SELECT TIPO_DOCUMENTO,
	CODIGO_CUENTA_CONTABLE AS CUENTA,
        CASE WHEN VALOR_UNITARIO<0 THEN VALOR_UNITARIO*-1 ELSE 0 END AS VALOR_DEB,
	CASE WHEN VALOR_UNITARIO>0 THEN VALOR_UNITARIO ELSE 0 END AS  VALOR_CREDT,	
	DESCRIPCION AS DESCRIPCION,
	DOCUMENTO AS DOCUMENTO 
FROM CON.FACTURA_DETALLE FAC
WHERE DOCUMENTO = 'R0032227' 
  AND TIPO_DOCUMENTO = 'FAC'
  AND REG_STATUS = ''
  AND NIT = '9000742958'

-------QUERY PRINCIPAL------
SELECT
	f.dstrct,
	f.tipo_documento,
	f.codcli,
	f.nit,
	get_nombrecliente( f.codcli ) AS nombre_cliente,
	f.reg_status,
	f.documento,
	f.valor_facturame AS valor_factura,
	f.valor_abonome AS valor_abono,
	f.valor_saldome AS valor_saldo,
	f.moneda,	
	f.fecha_factura,
	f.fecha_vencimiento,
	f.fecha_ultimo_pago,
	f.descripcion,
	f.creation_user,
	TO_CHAR ( f.fecha_impresion, 'YYYY-MM-DD HH24:MI') AS fecha_impresion,
	TO_CHAR ( f.fecha_anulacion, 'YYYY-MM-DD HH24:MI') AS fecha_anulacion,
	TO_CHAR ( f.fecha_contabilizacion, 'YYYY-MM-DD HH24:MI') AS fecha_contabilizacion,
	f.transaccion, 
	array_to_string( array_accum( det.numero_remesa ), ', ' ) AS ots,
	usuario_anulo,
	get_tel(f.codcli) AS tel,
	get_dir(f.codcli) AS dir 
	,f.negasoc                           
   FROM con.factura f 
   LEFT JOIN con.factura_detalle det ON ( det.dstrct = f.dstrct AND det.tipo_documento = f.tipo_documento AND det.documento = f.documento  )
   WHERE /*f.codcli = '802421' AND*/ f.NIT='9000742958' AND REPLACE(SUBSTRING(f.creation_date,1,7),'-','') ='201701'
    GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,f.negasoc
    ORDER BY f.fecha_factura ASC

