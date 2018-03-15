--Consultar Documentos procesados en apoteosys

SELECT * FROM opav.acciones where id_solicitud = '922634'


--Paso 3
SELECT * 
FROM CON.MC_SL_FAC_CC_SEL 
WHERE MC_____CODIGO____TD_____B = 'CXPN' 
  AND MC_____CODIGO____CONTAB_B = 'SELE' 
  AND MC_____CODIGO____CD_____B = 'CFSL'; 

--Paso 4
SELECT * 
FROM CON.MC_SL_FAC_CC_SEL 
WHERE MC_____CODIGO____TD_____B = 'CXPN' 
AND MC_____CODIGO____CONTAB_B = 'SELE' 
AND MC_____CODIGO____CD_____B = 'NCCF'; 

--Paso 5
SELECT * 
FROM CON.MC_SL_FAC_CC_SEL 
WHERE MC_____CODIGO____TD_____B = 'CXPN' 
AND MC_____CODIGO____CONTAB_B = 'SELE' 
AND MC_____CODIGO____CD_____B = 'NCTR'; 

--Paso 6
SELECT * 
FROM CON.MC_SL_FAC_CC_SEL 
WHERE MC_____CODIGO____TD_____B = 'CXPN' 
AND MC_____CODIGO____CONTAB_B = 'SELE' 
AND MC_____CODIGO____CD_____B = 'CPFI'; 


