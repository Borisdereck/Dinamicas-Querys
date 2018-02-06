-- Function: con.interfaz_sl_cdc_contratistas_selectrik_apoteosys()
-- DROP FUNCTION con.interfaz_sl_cdc_contratistas_selectrik_apoteosys();

CREATE OR REPLACE FUNCTION con.interfaz_sl_cdc_contratistas_selectrik_apoteosys()
  RETURNS text AS
$BODY$

DECLARE
 /************************************************
  *DESCRIPCION: ESTA FUNCION BUSCA TODAS LAS NM GENERADAS POR UN PERIODO PARA TRASLADO A APOTEOSYS
  *AUTOR		:=		@BTERRAZA
  *FECHA CREACION	:=		2018-01-10
  *LAST_UPDATE		:=	 	2018-01-10
  *DESCRIPCION DE CAMBIOS Y FECHA
  ************************************************/


FACTURA_NM RECORD;
INFOITEMS_ RECORD;
INFOCLIENTE RECORD;
LONGITUD numeric;
SECUENCIA_GEN INTEGER;
SECUENCIA_INT integer:= 1;
CUENTAS_IVA VARCHAR[] := '{}';
FECHADOC_ VARCHAR:= '';
MCTYPE CON.TYPE_INSERT_MC;
SW TEXT:='N';
validaciones text;

BEGIN
	/**SACAMOS EL LISTADO DE NC*/

	FOR FACTURA_NM IN 
		
				select 
					A.TIPO_DOCUMENTO, 
					A.FECHA_DOCUMENTO AS FECHA_FACTURA,
					A.FECHA_VENCIMIENTO,
					A.PERIODO,
					A.PROVEEDOR AS NIT,
					C.ID_SOLICITUD,
					C.CENTRO_COSTOS_INGRESO,
					C.CENTRO_COSTOS_GASTOS,
					A.DESCRIPCION,
					C.NUM_OS,
					A.DOCUMENTO
					 
					--A.BANCO , 
					--A.FECHA_DOCUMENTO,
				from fin.cxp_doc 		as A
				inner join opav.acciones 	as B	on (A.REFERENCIA_1 = B.ID_ACCION)
				inner join opav.ofertas 	as C	on (B.ID_SOLICITUD = C.ID_SOLICITUD)
				where 
					TIPO_DOCUMENTO		=	'FAP' 
					and HANDLE_CODE		=	'CD' 
					and PERIODO		=	'201701'
					

	LOOP	
	
				SELECT INTO INFOCLIENTE
						'NIT' AS tipo_doc,
							'GCON' as codigo,
							(CASE 
							WHEN E.CODIGO_DANE2!='' THEN E.CODIGO_DANE2
							ELSE '08001' END) as codigociu,
							nomcli AS nombre_corto, 
							nomcli AS  nombre,
							'' AS apellidos,
							direccion,
							telefono
						FROM CLIENTE cl
						LEFT JOIN CIUDAD E ON(E.CODCIU=cl.ciudad)
						WHERE cl.nit =  FACTURA_NM.NIT;	

		----SECUENCIA GENERAL
		SELECT INTO SECUENCIA_GEN  NEXTVAL('CON.INTERFAZ_SECUENCIA_R_APOTEOSYS');		

		MCTYPE.MC_____CODIGO____CONTAB_B := 'SELE'; 
		MCTYPE.MC_____CODIGO____TD_____B := 'CXPN'; 
		MCTYPE.MC_____CODIGO____CD_____B := 'CCSL'; 
		MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN; --SECUENCIA GENERAL

		/**BUSCAMOS LA INFORMACION COMPLETA QUE CONFORMARA EL ASIENTO CONTABLE PARA MANDARLO A APOTEOSYS*/

		FOR INFOITEMS_ IN 			        

								SELECT 
											tipo_documento,
											codigo_cuenta as cuenta,											
											case when vlr>0 then vlr else 0 end as valor_deb,
											case when vlr<0 then vlr*-1 else 0 end as valor_credt,
											descripcion
								FROM 
											fin.cxp_items_doc
								WHERE tipo_documento	= 	'FAP'
									and documento 			=		FACTURA_NM.documento
								UNION ALL
								SELECT
											tipo_documento,
											'22050801' as cuenta,
											proveedor,		
											0 as valor_deb,
											vlr_neto as valor_credt,
											descripcion
								FROM 
											fin.cxp_doc
								WHERE tipo_documento		=	'FAP' 
									and documento 				=	FACTURA_NM.documento

		LOOP						
			

					iF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('CXP_SEL','FAP', INFOITEMS_.cuenta,'', 6)='S')THEN
						MCTYPE.MC_____FECHVENC__B = FACTURA_NM.FECHA_VENCIMIENTO; --fecha vencimiento
							if (FACTURA_NM.fecha_vencimiento < FACTURA_NM.FECHA_FACTURA)then /** se valida si la fecha de vencimeinto es menor a la de creacion*/
								MCTYPE.MC_____FECHEMIS__B = FACTURA_NM.FECHA_VENCIMIENTO; --fecha creacion
							else 
								MCTYPE.MC_____FECHEMIS__B = FACTURA_NM.FECHA_FACTURA; --fecha creacion
							end if;
					ELSE
						MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
						MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';
					END IF;


			FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(FACTURA_NM.FECHA_FACTURA,1,7),'-','') = FACTURA_NM.periodo THEN FACTURA_NM.FECHA_FACTURA::DATE ELSE con.sp_fecha_corte_mes(SUBSTRING(FACTURA_NM.periodo,1,4), SUBSTRING(FACTURA_NM.periodo,5,2)::INT)::DATE END;
			MCTYPE.MC_____FECHA_____B := CASE WHEN (FACTURA_NM.FECHA_FACTURA::DATE > FECHADOC_::DATE AND REPLACE(SUBSTRING(FACTURA_NM.FECHA_FACTURA,1,7),'-','') = FACTURA_NM.PERIODO)  THEN FACTURA_NM.FECHA_FACTURA::DATE ELSE FECHADOC_::DATE END; 
			MCTYPE.MC_____SECUINTE__DCD____B := SECUENCIA_INT;--secuencia interna
			MCTYPE.MC_____SECUINTE__B := SECUENCIA_INT;--secuencia interna
			MCTYPE.MC_____REFERENCI_B := FACTURA_NM.num_os; ---cambiar a multiservicio...
			MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING( FACTURA_NM.PERIODO,1,4)::INT; 
			MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING( FACTURA_NM.PERIODO,5,2)::INT;
			MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF'; 
			MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('CXP_SEL', 'FAP', INFOITEMS_.cuenta,'', 1); 
			MCTYPE.MC_____CODIGO____CU_____B := FACTURA_NM.CENTRO_COSTOS_INGRESO;
			MCTYPE.MC_____IDENTIFIC_TERCER_B := substring(REPLACE(FACTURA_NM.nit,'-',''),1,9);
			MCTYPE.MC_____DEBMONORI_B := 0; 
			MCTYPE.MC_____CREMONORI_B := 0;
			MCTYPE.MC_____DEBMONLOC_B := INFOITEMS_.valor_deb::NUMERIC;
			MCTYPE.MC_____CREMONLOC_B := INFOITEMS_.valor_credt::NUMERIC;
			MCTYPE.MC_____INDTIPMOV_B := 4;
			MCTYPE.MC_____INDMOVREV_B := 'N';
			MCTYPE.MC_____OBSERVACI_B := SUBSTRING(INFOITEMS_.descripcion,1,249);
			MCTYPE.MC_____FECHORCRE_B := FACTURA_NM.FECHA_FACTURA::TIMESTAMP;
			MCTYPE.MC_____AUTOCREA__B := 'ADMIN';
			MCTYPE.MC_____FEHOULMO__B := FACTURA_NM.FECHA_FACTURA::TIMESTAMP;
			MCTYPE.MC_____AUTULTMOD_B := '';
			MCTYPE.MC_____VALIMPCON_B := 0;
			MCTYPE.MC_____NUMERO_OPER_B := '';
			MCTYPE.TERCER_CODIGO____TIT____B := INFOCLIENTE.tipo_doc;
			MCTYPE.TERCER_NOMBCORT__B := SUBSTRING(INFOCLIENTE.nombre_corto,1,32);
			MCTYPE.TERCER_NOMBEXTE__B := SUBSTRING(INFOCLIENTE.nombre,1,64);
			MCTYPE.TERCER_APELLIDOS_B := INFOCLIENTE.apellidos;
			MCTYPE.TERCER_CODIGO____TT_____B := INFOCLIENTE.codigo;
			MCTYPE.TERCER_DIRECCION_B := CASE WHEN CHAR_LENGTH(INFOCLIENTE.direccion)>64 THEN SUBSTR(INFOCLIENTE.direccion,1,64) ELSE INFOCLIENTE.direccion END;
			MCTYPE.TERCER_CODIGO____CIUDAD_B := INFOCLIENTE.codigociu;
			MCTYPE.TERCER_TELEFONO1_B := CASE WHEN CHAR_LENGTH(INFOCLIENTE.telefono)>15 THEN SUBSTR(INFOCLIENTE.telefono,1,15) ELSE INFOCLIENTE.telefono END;
			MCTYPE.TERCER_TIPOGIRO__B := 1;
			MCTYPE.TERCER_CODIGO____EF_____B := '';
			MCTYPE.TERCER_SUCURSAL__B := '';
			MCTYPE.TERCER_NUMECUEN__B := '';
			MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('CXP_SEL','FAP', INFOITEMS_.cuenta,'', 3);
			MCTYPE.MC_____BASE______B:=0;

			IF(MCTYPE.MC_____FECHEMIS__B > MCTYPE.MC_____FECHA_____B) THEN
				MCTYPE.MC_____FECHEMIS__B :=  MCTYPE.MC_____FECHA_____B;
			END IF;

			IF(INFOITEMS_.VALOR_CREDT= 0)THEN
				IF(INFOITEMS_.VALOR_CREDT)THEN
					CONTINUE; 
				END IF;
			END IF;					

			IF(INFOITEMS_.cuenta = ANY (CUENTAS_IVA))THEN
				IF(INFOITEMS_.VALOR_CREDT>0) THEN
					MCTYPE.MC_____BASE______B:= INFOITEMS_.VALOR_CREDT/0.16;
				ELSE
					MCTYPE.MC_____BASE______B:= INFOITEMS_.VALOR_DEB/0.16;
				END IF;
			END IF;

			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('CXP_SEL','FAP', INFOITEMS_.cuenta,'', 4)='S')THEN
				MCTYPE.MC_____NUMDOCSOP_B := FACTURA_NM.DOCUMENTO;
			ELSE
				MCTYPE.MC_____NUMDOCSOP_B := '';
			END IF;

			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('CXP_SEL', 'FAP', INFOITEMS_.cuenta,'', 5)::INT=1)THEN
				MCTYPE.MC_____NUMEVENC__B := 1;--numero de cuotas
			ELSE
				MCTYPE.MC_____NUMEVENC__B := NULL;
			END IF;
 			

			raise notice 'NC ====>>>> %',INFOITEMS_.CUENTA;	
			SW:=con.mc_sl_fac_cc_sel(MCTYPE);
			SECUENCIA_INT :=SECUENCIA_INT+1;		

		END LOOP;

		raise notice '<<<<==== Termino ====>>>> %',FACTURA_NM.DOCUMENTO;

		--VALIDAMOS VALORES DEBITOS Y CREDITOS DEL COMPROBANTE A TRASLADAR.
		IF CON.SP_VALIDACIONES_SEL(MCTYPE,'FAC_CC') ='N' THEN 
			SW = 'N';
			CONTINUE; 
		END IF;			

		if(SW = 'S')then
							UPDATE fin.cxp_doc SET PROCESADO = 'S' WHERE DOCUMENTO =  FACTURA_NM.DOCUMENTO AND tipo_documento = 'FAP';
			end if;

		SECUENCIA_INT:=1;		

	END LOOP;

	
RETURN 'OK';

END
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_sl_cdc_contratistas_selectrik_apoteosys()
  OWNER TO postgres;

