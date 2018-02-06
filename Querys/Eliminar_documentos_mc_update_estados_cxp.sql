
delete from con.mc_sl_fac_cc_sel where MC_____CODIGO____CD_____B = 'NCSL' and mc_____numdocsop_b = 'CC707-001099'; 

delete from con.mc_sl_fac_cc_sel where MC_____CODIGO____CD_____B = 'NCSL' and mc_____numdocsop_b = 'CC707-001101'; 


update fin.cxp_doc set procesado = 'N' where documento = 'CC707-001099' and periodo = '201710';
select * from fin.cxp_doc where documento = 'CC707-001099' and periodo = '201710';

update fin.cxp_doc set procesado = 'N' where documento = 'CC707-001101' and periodo = '201710';
select * from fin.cxp_doc where documento = 'CC707-001101' and periodo = '201710';


