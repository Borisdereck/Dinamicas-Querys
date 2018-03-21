-------------------------------------------------------------
----Backup tabla traslado dinamica contratista selectrik-----
-------------------------------------------------------------
create table tem.con_mc_sl_fac_cc_sel____backup as
SELECT * From con.mc_sl_fac_cc_sel 

select count(0) from tem.con_mc_sl_fac_cc_sel____backup

--truncate table con.mc_sl_fac_cc_sel;



--------------------------------------------------------------
----------Backup tabla traslado dinamica NM selectrik---------
--------------------------------------------------------------
create table tem.con_mc_sl_fac_sel_nm____backup as
SELECT * From con.mc_sl_fac_sel 

select * from tem.con_mc_sl_fac_sel_nm____backup limit 100

--truncate table con.mc_sl_fac_sel;

select count(*) from con.mc_sl_fac_sel limit 100;
