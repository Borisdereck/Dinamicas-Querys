select * from con.mc_sl_fac_sel  WHERE mc_____numdocsop_b = 'NM12772_1' --where creation_date = '2018-03-07 16:18:48.124949';

SELECT * FROM OPAV.sl_traslado_facturas_apoteosys  where traslado_fintra=''
update OPAV.sl_traslado_facturas_apoteosys set traslado_fintra = '1' where traslado_fintra=''

select * from con.mc_sl_fac_sel order by creation_date desc limit 10;

