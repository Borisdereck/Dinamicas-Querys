﻿--TABLA DONDE ESTAN LAS CUENTAS CONTABLES 
SELECT * FROM CON.CMC_DOC WHERE TIPODOC = 'FAP';

--TABLA DE COMPROBANTE CONTABLE
SELECT * FROM CON.COMPROBANTE LIMIT 10;

--TABLA DE DETALLE DEL COMPROBANTE CONTABLE
SELECT * FROM CON.COMPRODET LIMIT 10;

--TABLA DE FACTURA
SELECT * FROM CON.FACTURA LIMIT 10;

--TABLA DEL DETALLE DE LA FACTURA
SELECT * FROM CON.FACTURA_DETALLE LIMIT 10;

--TABLA DE INGRESOS, Notas 
SELECT * FROM CON.INGRESO LIMIT 10;

--TABLA DEL DETALLE DE LOS INGRESOS y Notas
SELECT * FROM CON.FACTURA LIMIT 10;

--TABLA DE PERIODOS CONTABLES
SELECT * FROM CON.PERIODO_CONTABLE LIMIT 100

--TABLA DE RECAUDOS
SELECT * FROM CON.RECAUDO LIMIT 100

--TABLA DE TIPOS DE DOCUMENTOS
SELECT * FROM CON.TIPO_DOCTO 

--TABLA DE EGRESO
SELECT * FROM EGRESO WHERE DOCUMENT_NO = 'EG01039';

--TABLA DEL DETALLE DEL EGRESO 
SELECT * FROM EGRESODET WHERE DOCUMENT_NO = 'EG01039';

--TABLA DE HOMOLOGACION INTERFACE APOTEOSYS
SELECT * FROM CON.HOMOLACION_INTERFACE LIMIT 20;

--CABECERA CUENTAS POR PAGAR 
SELECT * FROM FIN.CXP_DOC WHERE DOCUMENTO = '8651479';

--TABLA DE ITEMS DE LOS DOCUMENTOS DE CUENTAS POR PAGAR
SELECT * FROM FIN.CXP_ITEMS_DOC WHERE DOCUMENTO = '8651479';

--TABLA DE ORDEN DE SERVICIO
SELECT * FROM FIN.ORDEN_SERVICIO LIMIT 100;

--TABLA DE DETALLE DE LA ORDEN DE SERVICIO
SELECT * FROM FIN.ORDEN_SERVICIO_DETALLE LIMIT 100;

--TABLA DE ORDEN DE COMPRA
SELECT * FROM ORDENCOMPRA LIMIT 100;

--TABLA DE ORDEN DE RELACION ORDEN DE COMPRA CON FACTURA
SELECT * FROM RELACION_OC_FAC LIMIT 100;

--TABLA DE PROVEEDOR
SELECT * FROM PROVEEDOR LIMIT 100;

--Tabla de configuracion de las operaciones para pasar a apoteosys
select * from con.mc_config_nombre_tabla







