﻿-- Function: con.interfaz_sl_contratistas_nc_factoring_selectrik_apoteosys()

-- DROP FUNCTION con.interfaz_sl_contratistas_nc_factoring_selectrik_apoteosys();

CREATE OR REPLACE FUNCTION con.interfaz_sl_contratistas_nc_factoring_selectrik_apoteosys()
  RETURNS text AS
$BODY$

DECLARE

 /************************************************
  *DESCRIPCION: ESTA FUNCION BUSCA TODAS LAS NM GENERADAS POR UN PERIODO PARA TRASLADO A APOTEOSYS
  *AUTOR		:=		@BTERRAZA
  *FECHA CREACION	:=		2018-01-12
  *LAST_UPDATE		:=	 	2018-01-12
  *DESCRIPCION DE CAMBIOS Y FECHA
  ************************************************/
FACTURA_NM RECORD;
INFOITEMS_ RECORD;
INFOCLIENTE RECORD;
LONGITUD NUMERIC;
SECUENCIA_GEN INTEGER;
SECUENCIA_INT INTEGER:= 1;
CUENTAS_IVA VARCHAR[] := '{}';
FECHADOC_ VARCHAR:= '';
MCTYPE CON.TYPE_INSERT_MC;
SW TEXT:='N';
VALIDACIONES TEXT;
_EXISTE CHARACTER VARYING :='';

BEGIN
	
	--PASO 4
	FOR FACTURA_NM IN 		

			SELECT 
				AA.TIPO_DOCUMENTO, 
				AA.FECHA_DOCUMENTO AS FECHA_FACTURA,
				AA.FECHA_VENCIMIENTO,
				AA.PERIODO,
				AA.PROVEEDOR AS NIT,
				C.ID_SOLICITUD,
				C.CENTRO_COSTOS_INGRESO,
				C.CENTRO_COSTOS_GASTOS,
				AA.DESCRIPCION,
				C.NUM_OS,
				AA.DOCUMENTO,		 
				A.REFERENCIA_1
			FROM FIN.CXP_DOC 		AS AA
			INNER JOIN PROVEEDOR 		AS PRV  ON (AA.PROVEEDOR=PRV.NIT)
			INNER JOIN FIN.CXP_ITEMS_DOC	AS A	ON (A.DOCUMENTO = AA.DOCUMENTO AND A.TIPO_DOCUMENTO = AA.TIPO_DOCUMENTO)	
			INNER JOIN OPAV.ACCIONES 	AS B	ON (A.REFERENCIA_1 = B.ID_ACCION)
			INNER JOIN OPAV.OFERTAS 	AS C	ON (B.ID_SOLICITUD = C.ID_SOLICITUD)
			WHERE 
				AA.TIPO_DOCUMENTO		=	'NC' 
				AND AA.HANDLE_CODE		=	'CD' 
				AND AA.PERIODO			=	'201712'				
				AND AA.REG_STATUS		=	''
				AND C.CENTRO_COSTOS_INGRESO 	!=  	''
				AND AA.DESCRIPCION LIKE 'Aplica factoring y/o formula de la accion:%'
				--and AA.DOCUMENTO='274'
				AND COALESCE(AA.PROCESADO, 'N' ) = 'N'
			GROUP BY
				AA.TIPO_DOCUMENTO, 
				AA.FECHA_DOCUMENTO,
				AA.FECHA_VENCIMIENTO,
				AA.PERIODO,
				AA.PROVEEDOR,
				C.ID_SOLICITUD,
				C.CENTRO_COSTOS_INGRESO,
				C.CENTRO_COSTOS_GASTOS,
				AA.DESCRIPCION,
				C.NUM_OS,
				AA.DOCUMENTO,		 
				A.REFERENCIA_1


--SELECT con.interfaz_sl_contratistas_nc_factoring_selectrik_apoteosys();
--UPDATE con.mc_sl_fac_cc_sel SET PROCESADO='N' where MC_____CODIGO____CONTAB_B = 'SELE' AND MC_____CODIGO____CD_____B = 'NCCF' and MC_____NUMERO____PERIOD_B = '1';
--delete from con.mc_sl_fac_cc_sel where MC_____CODIGO____CONTAB_B = 'SELE' AND MC_____CODIGO____CD_____B = 'NCCF' and MC_____NUMERO____PERIOD_B = '1';

	
	LOOP		


		SELECT INTO INFOCLIENTE
			'NIT' AS TIPO_DOC,
			(CASE 
			WHEN GRAN_CONTRIBUYENTE ='N' AND AGENTE_RETENEDOR ='N' THEN 'RCOM' 
			WHEN GRAN_CONTRIBUYENTE ='N' AND AGENTE_RETENEDOR ='S' THEN 'RCAU' 
			WHEN GRAN_CONTRIBUYENTE ='S' AND AGENTE_RETENEDOR ='N' THEN 'GCON' 
			WHEN GRAN_CONTRIBUYENTE ='S' AND AGENTE_RETENEDOR ='S' THEN 'GCAU'
			ELSE 'PNAL' END) AS CODIGO,
			'08001'AS CODIGOCIU,
			(D.NOMBRE1||' '||D.NOMBRE2) AS NOMBRE_CORTO, 
			PAYMENT_NAME AS  NOMBRE,
			(D.APELLIDO1||' '||D.APELLIDO2) AS APELLIDOS,
			DIRECCION,
			TELEFONO
			
		FROM PROVEEDOR PROV
		LEFT JOIN NIT D ON(D.CEDULA=PROV.NIT)
		LEFT JOIN CIUDAD E ON(E.CODCIU=D.CODCIU)
		WHERE NIT =  FACTURA_NM.NIT;	


		----SECUENCIA GENERAL
		SELECT INTO SECUENCIA_GEN  NEXTVAL('CON.INTERFAZ_SECUENCIA_R_APOTEOSYS');		

		MCTYPE.MC_____CODIGO____CONTAB_B := 'SELE'; 
		MCTYPE.MC_____CODIGO____TD_____B := 'CXPN'; 
		MCTYPE.MC_____CODIGO____CD_____B := 'NCCF'; 
		MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN; --SECUENCIA GENERAL

		/**BUSCAMOS LA INFORMACION COMPLETA QUE CONFORMARA EL ASIENTO CONTABLE PARA MANDARLO A APOTEOSYS*/

		FOR INFOITEMS_ IN 

				SELECT 
					A.TIPO_DOCUMENTO,
					CMC.CUENTA AS CUENTA,
					A.PROVEEDOR,
					(SUM(VLR))  AS  VALOR_DEB, 
					0::NUMERIC AS VALOR_CREDT,
					'CXP AL CONTRATISTA ' AS DESCRIPCION
				FROM FIN.CXP_DOC 		AS AA
				INNER JOIN FIN.CXP_ITEMS_DOC	AS A	ON (A.DOCUMENTO = AA.DOCUMENTO AND A.TIPO_DOCUMENTO = AA.TIPO_DOCUMENTO AND AA.PROVEEDOR=A.PROVEEDOR)
				INNER JOIN CON.CMC_DOC          AS CMC  ON (CMC.TIPODOC=AA.TIPO_DOCUMENTO AND  AA.HANDLE_CODE=CMC.CMC)	
				INNER JOIN OPAV.ACCIONES 	AS B	ON (A.REFERENCIA_1 = B.ID_ACCION)
				INNER JOIN OPAV.OFERTAS 	AS C	ON (B.ID_SOLICITUD = C.ID_SOLICITUD)
				WHERE 
					AA.TIPO_DOCUMENTO		=	'NC' 
					AND AA.HANDLE_CODE		=	'CD' 
					AND AA.DESCRIPCION		LIKE 'Aplica factoring y/o formula de la accion:%'
					AND AA.PERIODO			= FACTURA_NM.PERIODO
					AND AA.DOCUMENTO 		= FACTURA_NM.DOCUMENTO 
					AND A.REFERENCIA_1		= FACTURA_NM.REFERENCIA_1
					AND AA.PROVEEDOR 		= FACTURA_NM.NIT 
				GROUP BY 
					A.TIPO_DOCUMENTO,
					A.PROVEEDOR,
					CMC.CUENTA

				UNION ALL
				
				SELECT 
					A.TIPO_DOCUMENTO,
					A.CODIGO_CUENTA AS CUENTA,
					A.PROVEEDOR,					
					CASE WHEN (A.VLR)<0 THEN (A.VLR*-1) ELSE 0 END AS VALOR_DEB, 
					CASE WHEN (A.VLR)>0 THEN (A.VLR) ELSE 0 END AS  VALOR_CREDT,					
					UPPER(A.DESCRIPCION) AS DESCRIPCION
				FROM FIN.CXP_DOC 		AS AA
				INNER JOIN FIN.CXP_ITEMS_DOC	AS A	ON (A.DOCUMENTO = AA.DOCUMENTO AND A.TIPO_DOCUMENTO = AA.TIPO_DOCUMENTO AND AA.PROVEEDOR=A.PROVEEDOR)	
				INNER JOIN OPAV.ACCIONES 	AS B	ON (A.REFERENCIA_1 = B.ID_ACCION)
				INNER JOIN OPAV.OFERTAS 	AS C	ON (B.ID_SOLICITUD = C.ID_SOLICITUD)
				WHERE 
				AA.TIPO_DOCUMENTO		=	'NC' 
				AND AA.HANDLE_CODE		=	'CD' 
				AND AA.DESCRIPCION		LIKE 'Aplica factoring y/o formula de la accion:%'
				AND AA.REG_STATUS		=	''
				AND AA.PERIODO			= FACTURA_NM.PERIODO
				AND AA.DOCUMENTO 		= FACTURA_NM.DOCUMENTO  
				AND A.REFERENCIA_1		= FACTURA_NM.REFERENCIA_1 
				AND AA.PROVEEDOR 		= FACTURA_NM.NIT 


		LOOP						

			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('CXP_SEL','NC', INFOITEMS_.CUENTA,'', 6)='S')THEN

				MCTYPE.MC_____FECHVENC__B = FACTURA_NM.FECHA_VENCIMIENTO; --FECHA VENCIMIENTO
					IF (FACTURA_NM.FECHA_VENCIMIENTO < FACTURA_NM.FECHA_FACTURA)THEN /** SE VALIDA SI LA FECHA DE VENCIMEINTO ES MENOR A LA DE CREACION*/
						MCTYPE.MC_____FECHEMIS__B = FACTURA_NM.FECHA_VENCIMIENTO; --FECHA CREACION
					ELSE 
						MCTYPE.MC_____FECHEMIS__B = FACTURA_NM.FECHA_FACTURA; --FECHA CREACION
					END IF;

			ELSE

				MCTYPE.MC_____FECHEMIS__B='0099-01-01 00:00:00';
				MCTYPE.MC_____FECHVENC__B='0099-01-01 00:00:00';

			END IF;


			--FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(DOCUMENTO.FECHA_FACTURA,1,7),'-','') = DOCUMENTO.PERIODO THEN DOCUMENTO.FECHA_FACTURA::DATE ELSE CON.SP_FECHA_CORTE_MES(SUBSTRING(DOCUMENTO.PERIODO,1,4), SUBSTRING(DOCUMENTO.PERIODO,5,2)::INT)::DATE END;

			FECHADOC_ := CASE WHEN REPLACE(SUBSTRING(FACTURA_NM.FECHA_FACTURA,1,7),'-','') = FACTURA_NM.PERIODO THEN FACTURA_NM.FECHA_FACTURA::DATE ELSE CON.SP_FECHA_CORTE_MES(SUBSTRING(FACTURA_NM.PERIODO,1,4), SUBSTRING(FACTURA_NM.PERIODO,5,2)::INT)::DATE END;

			MCTYPE.MC_____FECHA_____B := CASE WHEN (FACTURA_NM.FECHA_FACTURA::DATE > FECHADOC_::DATE AND REPLACE(SUBSTRING(FACTURA_NM.FECHA_FACTURA,1,7),'-','') = FACTURA_NM.PERIODO)  THEN FACTURA_NM.FECHA_FACTURA::DATE ELSE FECHADOC_::DATE END; 
			MCTYPE.MC_____SECUINTE__DCD____B := SECUENCIA_INT;--SECUENCIA INTERNA
			MCTYPE.MC_____SECUINTE__B := SECUENCIA_INT;--SECUENCIA INTERNA
			MCTYPE.MC_____REFERENCI_B := '-';--FACTURA_NM.NUM_OS; ---CAMBIAR A MULTISERVICIO...
			MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING( FACTURA_NM.PERIODO,1,4)::INT; 
			MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING( FACTURA_NM.PERIODO,5,2)::INT;
			MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF'; 
			MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('CXP_SEL', 'NC', INFOITEMS_.CUENTA,'', 1); 
			MCTYPE.MC_____CODIGO____CU_____B := FACTURA_NM.CENTRO_COSTOS_INGRESO;
			MCTYPE.MC_____IDENTIFIC_TERCER_B := SUBSTRING(REPLACE(FACTURA_NM.NIT,'-',''),1,9);
			MCTYPE.MC_____DEBMONORI_B := 0; 
			MCTYPE.MC_____CREMONORI_B := 0;
			MCTYPE.MC_____DEBMONLOC_B := INFOITEMS_.VALOR_DEB::NUMERIC;
			MCTYPE.MC_____CREMONLOC_B := INFOITEMS_.VALOR_CREDT::NUMERIC;
			MCTYPE.MC_____INDTIPMOV_B := 4;
			MCTYPE.MC_____INDMOVREV_B := 'N';
			MCTYPE.MC_____OBSERVACI_B := SUBSTRING(FACTURA_NM.NUM_OS ||' : '||INFOITEMS_.DESCRIPCION,1,249);
			MCTYPE.MC_____FECHORCRE_B := FACTURA_NM.FECHA_FACTURA::TIMESTAMP;
			MCTYPE.MC_____AUTOCREA__B := 'ADMIN';
			MCTYPE.MC_____FEHOULMO__B := FACTURA_NM.FECHA_FACTURA::TIMESTAMP;
			MCTYPE.MC_____AUTULTMOD_B := '';
			MCTYPE.MC_____VALIMPCON_B := 0;
			MCTYPE.MC_____NUMERO_OPER_B := '';
			MCTYPE.TERCER_CODIGO____TIT____B := INFOCLIENTE.TIPO_DOC;
			MCTYPE.TERCER_NOMBCORT__B := SUBSTRING(INFOCLIENTE.NOMBRE_CORTO,1,32);
			MCTYPE.TERCER_NOMBEXTE__B := SUBSTRING(INFOCLIENTE.NOMBRE,1,64);
			MCTYPE.TERCER_APELLIDOS_B := INFOCLIENTE.APELLIDOS;
			MCTYPE.TERCER_CODIGO____TT_____B := INFOCLIENTE.CODIGO;
			MCTYPE.TERCER_DIRECCION_B := CASE WHEN CHAR_LENGTH(INFOCLIENTE.DIRECCION)>64 THEN SUBSTR(INFOCLIENTE.DIRECCION,1,64) ELSE INFOCLIENTE.DIRECCION END;
			MCTYPE.TERCER_CODIGO____CIUDAD_B := INFOCLIENTE.CODIGOCIU;
			MCTYPE.TERCER_TELEFONO1_B := CASE WHEN CHAR_LENGTH(INFOCLIENTE.TELEFONO)>15 THEN SUBSTR(INFOCLIENTE.TELEFONO,1,15) ELSE INFOCLIENTE.TELEFONO END;
			MCTYPE.TERCER_TIPOGIRO__B := 1;
			MCTYPE.TERCER_CODIGO____EF_____B := '';
			MCTYPE.TERCER_SUCURSAL__B := '';
			MCTYPE.TERCER_NUMECUEN__B := '';
			MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('CXP_SEL','NC', INFOITEMS_.CUENTA,'', 3);
			MCTYPE.MC_____BASE______B:=0;


			IF(MCTYPE.MC_____FECHEMIS__B > MCTYPE.MC_____FECHA_____B) THEN
				MCTYPE.MC_____FECHEMIS__B :=  MCTYPE.MC_____FECHA_____B;
			END IF;

			-- IF(INFOITEMS_.VALOR_CREDT= 0)THEN
-- 				IF(INFOITEMS_.VALOR_CREDT)THEN
-- 					CONTINUE; 
-- 				END IF;
-- 			END IF;	

			IF(INFOITEMS_.CUENTA = ANY (CUENTAS_IVA))THEN
				IF(INFOITEMS_.VALOR_CREDT>0) THEN
					MCTYPE.MC_____BASE______B:= INFOITEMS_.VALOR_CREDT/0.16;
				ELSE
					MCTYPE.MC_____BASE______B:= INFOITEMS_.VALOR_DEB/0.16;
				END IF;
			END IF;


			MCTYPE.MC_____NUMDOCSOP_B := FACTURA_NM.DOCUMENTO;

			-- IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('CXP_SEL','NC', INFOITEMS_.CUENTA,'', 4)='S')THEN
-- 				MCTYPE.MC_____NUMDOCSOP_B := FACTURA_NM.DOCUMENTO;
-- 			ELSE
-- 				MCTYPE.MC_____NUMDOCSOP_B := '';
-- 			END IF;


			IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('CXP_SEL', 'NC', INFOITEMS_.CUENTA,'', 5)::INT=1)THEN
				MCTYPE.MC_____NUMEVENC__B := 1;--NUMERO DE CUOTAS
			ELSE
				MCTYPE.MC_____NUMEVENC__B := NULL;
			END IF;

			RAISE NOTICE 'NC ====>>>> %',INFOITEMS_.CUENTA;	

			SW:=CON.SP_INSERT_TABLE_MC_SL_FAC_CC_SEL(MCTYPE);

			SECUENCIA_INT :=SECUENCIA_INT+1;


		END LOOP;

		RAISE NOTICE '<<<<==== TERMINO ====>>>> %',FACTURA_NM.DOCUMENTO;

		--VALIDAMOS VALORES DEBITOS Y CREDITOS DEL COMPROBANTE A TRASLADAR.
		IF CON.SP_VALIDACIONES_SEL(MCTYPE,'FAC_CC') = 'N' THEN 
			SW = 'N';
			CONTINUE;
		END IF;

		IF(SW = 'S')THEN			
			UPDATE FIN.CXP_DOC SET PROCESADO = 'S'
			WHERE DOCUMENTO =FACTURA_NM.DOCUMENTO 
			AND TIPO_DOCUMENTO = 'NC'				
			AND HANDLE_CODE	='CD' 
			AND PROVEEDOR=FACTURA_NM.NIT
			AND REG_STATUS =''
			AND DESCRIPCION LIKE 'Aplica factoring y/o formula de la accion:%'
			AND COALESCE(PROCESADO, 'N' ) = 'N';
		END IF;

		SECUENCIA_INT:=1;		

	END LOOP;	

RETURN 'OK';

END
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_sl_contratistas_nc_factoring_selectrik_apoteosys()
  OWNER TO postgres;
