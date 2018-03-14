SELECT * 
FROM CON.MC_EGRE_PROV_PROVINT 
WHERE MC_____CODIGO____CD_____B='IN' 
AND MC_____NUMERO____PERIOD_B=11
AND MC_____NUMDOCSOP_B in ('0035','0036','0033','1275')
AND mc_____fecha_____b = '2017-12-20 00:00:00' --AND mc_____codigo____cu_____b= 'A1111S1200020502' AND MC_____NUMERO____PERIOD_B=1;


UPDATE CON.MC_EGRE_PROV_PROVINT 
SET mc_____numero____period_b = 11
WHERE MC_____CODIGO____CD_____B='IN' 
AND MC_____NUMERO____PERIOD_B=12 
AND MC_____NUMDOCSOP_B = '1275' 
-- AND mc_____fecha_____b = '2017-12-20 00:00:00' --AND mc_____codigo____cu_____b= 'A1111S1200020502'


25/11/17

--SELECT * FROM EGRESODET WHERE PROCESADO = 'R' AND TIPO_DOCUMENTO = 'FAP' AND REPLACE(SUBSTRING(CREATION_DATE,1,7),'-','') = '201711' and document_no in('0035','0036','0033','1275'); 
select * from egresodet where procesado = 'S' AND REPLACE(SUBSTRING(CREATION_DATE,1,7),'-','') = '201712'
and documento in('0035','0036','0033','1275')  

select * from egresodet where procesado = 'S' AND REPLACE(SUBSTRING(CREATION_DATE,1,7),'-','') = '201712'
and documento in('0035','0036','0033','1275')  
