select * from con.mc_sl_fac_sel  WHERE mc_____numdocsop_b = 'NM12772_1' --where creation_date = '2018-03-07 16:18:48.124949';

SELECT * FROM OPAV.sl_traslado_facturas_apoteosys  where traslado_fintra=''
update OPAV.sl_traslado_facturas_apoteosys set traslado_fintra = '1' where traslado_fintra=''

select * from con.mc_sl_fac_sel order by creation_date desc limit 10;

update opav.sl_traslado_facturas_apoteosys set traslado_fintra = '2' where documento in ('NM12759_6',
'NM12759_4',
'NM12759_2',
'NM12785_2',
'NM12759_7',
'NM12785_12',
'NM12785_4',
'NM12785_6',
'NM12785_8',
'NM12785_9',
'NM12785_11',
'NM12759_9',
'NM12759_5',
'NM12759_1',
'NM12785_3',
'NM12759_8',
'NM12785_10',
'NM12785_5',
'NM12785_7',
'NM12785_1',
'NM12759_10',
'NM12759_11',
'NM12759_3',
'NM12759_12',
'NM12756_1');


where creation_date::date = now()::date and periodo = '201701'

