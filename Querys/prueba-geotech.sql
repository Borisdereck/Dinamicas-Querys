--tabla de mensjes de errores
SELECT *
FROM APOTEOSYS.MENSAJ
WHERE MENSAJ_NUMEMENS__B IN (2124);

--Validacion error 2124
SELECT MCTE.MCTEMP_CADERRVAL_B,
  MCTE.MC_____NUMDOCSOP_B,
  MCTE.MC_____CODIGO____CPC____B,
  mcte.mc_____codigo____cu_____b,
  MCTE.MC_____FECHA_____B,
  MCTE.MC_____FECHEMIS__B,
  MCTE.MC_____FECHVENC__B,
  MCTE.MC_____FECHDESC__B,
  MCTE.MC_____VALODESC__B,
  MCTE.MC_____PORCDESC__B,
  MCTE.MC_____REFERENCI_B,
  MCTE.MC_____DEBMONLOC_B,
  MCTE.MC_____CREMONLOC_B
 -- MCTE.MC_____OBSERVACI_B,
--mcte.*
FROM APOTEOSYS.MCTEMP MCTE
WHERE mcte.MCTEMP_SECUINTE__CEP____B = '15068' order by MCTEMP_SECUCARG__B;

--Tabla de saldos
SELECT SCD.SCD____CODIGO____CONTAB_B,
  SCD.SCD____CODIGO____CPC____B,
  SCD.SCD____CODIGO____CU_____B,
  SCD.SCD____NUMDOCSOP_B,
  SCD.SCD____FECHA_____B,
  SCD.SCD____FECHEMIS__B,
  SCD.SCD____FECHVENC__B,
  SCD.SCD____REFERENCI_B,
  SCD.SCD____SALINILOC_B,
  SCD.SCD____ACUDEBLOC_B,
  SCD.SCD____ACUCRELOC_B
  --SCD.*
FROM APOTEOSYS.SCD___ SCD
WHERE SCD____NUMDOCSOP_B      = 'NM12729_1'
AND SCD____CODIGO____CONTAB_B = 'SELE';

--Tabla de centros de costos
SELECT *
FROM APOTEOSYS.cu____
WHERE CU_____NOMBRE____B LIKE '%FOMS13086-17%';

SELECT * FROM APOTEOSYS.CPC___ WHERE CPC____CODIGO____B = 28151004;

SELECT * FROM APOTEOSYS.SCD___ WHERE SCD____NUMDOCSOP_B = 'NM12790_1';

Falló la creación del asiento: 28151001, A1111S1100015601, 800112084, CXPA, NM12790_1, 1, 2296. Mensaje original: %%1. El documento no puede ser creado con saldo negativo


--verificar concepto en tabla de apoteosys
SELECT *
FROM APOTEOSYS.MC____
WHERE MC_____CODIGO____CD_____B = 'IN'
AND MC_____NUMERO____B          ='3104'
AND MC_____CODIGO____CD_____B   ='CCSL';
--AND MC_____NUMERO____B=57194;

--verificar SI CONCEPTO ESTA CREADO
SELECT *
FROM APOTEOSYS.CD____
WHERE CD_____CODIGO____B ='CPFI';
--CD_____CODIGO____TD_____B = 'CXPN';
--CD_____CODIGO____B        ='CPFI';

--verificar registros asociados al concepto de los documento en un periodo
SELECT *
FROM APOTEOSYS.MC____
WHERE MC_____CODIGO____CONTAB_B = 'SELE'
AND MC_____CODIGO____TD_____B   = 'CXCN'
AND MC_____CODIGO____CD_____B   = 'NMSL'
AND MC_____CODIGO____PF_____B   = '2017'
AND MC_____NUMERO____PERIOD_B   = '1';
--AND MC_____OBSERVACI_B LIKE 'EGRESO PAGO  PROVEEDOR PROVINTEGRAL => %';   Este filtro es de egresos provintegral

SELECT *
FROM APOTEOSYS.DS____
WHERE DS_____CODIGO____B='FAPR';

SELECT *
FROM APOTEOSYS.MC____
WHERE MC_____CODIGO____CONTAB_B = 'PROV' --AND MC_____CODIGO____CD_____B=''
AND MC_____NUMDOCSOP_B          = '1218';

SELECT *
FROM APOTEOSYS.MC____
WHERE MC_____CODIGO____CD_____B='CPFI'
AND MC_____NUMDOCSOP_B         = ''
AND MC_____NUMERO____PERIOD_B  = '4';
