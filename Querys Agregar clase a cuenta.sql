 
 --Verificamos la cuenta en apoteosys y su naturaleza

-----------------------------------
-------Productivo Oracle  ---------
------------------------------------
--ver la naturaleza de la cuenta en Apoteosys
SELECT * FROM APOTEOSYS.CPC___ WHERE CPC____CODIGO____B = 28151004;


--Procedemos a actualizar la tabla de homologacion 
 -----------------------------------
 -------Productivo Postgres---------
------------------------------------
select cuenta_apo from con.homolacion_interface WHERE PROCESO='FACT_SEL' group by cuenta_apo;

select * from con.homolacion_interface WHERE PROCESO='FACT_SEL' and cuenta_apo=13050501;

update con.homolacion_interface set clase='D' WHERE PROCESO='FACT_SEL' and cuenta_apo NOT IN(24080102,
28150506,
28150507,
28150508,
28151001,
41503001);

