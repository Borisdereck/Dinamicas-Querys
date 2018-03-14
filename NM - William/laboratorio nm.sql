select sum(a.valor_unitario) from (
select * from con.factura_detalle where documento='NM12756_1'
) a

SELECT * FROM con.comprodet where  documento_rel='NM12756_1' numdoc='IA487432'

select * from con.ingreso where num_ingreso='IA483940'
select * from con.ingreso_detalle where num_ingreso='IA483940'

select * from con.factura_detalle where documento = 'NM12756_1' and descripcion not like 'Cuota inicial%'


--tabla de traslado hacia apoteosys
select * from con.mc_sl_fac_sel limit 100;

--tabla de control
select * from opav.sl_traslado_facturas_apoteosys;