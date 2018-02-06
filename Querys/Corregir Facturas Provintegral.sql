
--Fase 1
	SELECT *  from opav.sl_solicitud_ocs   where id_solicitud in(926048);
	select * from opav.sl_solicitud_ocs_detalle  where id_solicitud in(925467) and descripcion_insumo ilike '%CABLE DE COBRE DESNUDO%' order by descripcion_insumo;

--Fase 2
	SELECT * FROM opav.sl_orden_compra_servicio where cod_ocs ilike '%OC00030%'
	SELECT * FROM opav.sl_ocs_detalle  where id_ocs = '672' and descripcion_insumo ilike '%Yee 4 sanitaria pavco%'  order by descripcion_insumo;
	--delete from  opav.sl_ocs_detalle  where id in(5314)




--Actualizar Cantidad Solicitada en detalle de la orden de compra
UPDATE opav.sl_ocs_detalle
SET cantidad_solicitada = 10 
WHERE id = 5255;

--Visualizar los datos de la orden de compra
select * from opav.sl_ocs_detalle where id = 5255