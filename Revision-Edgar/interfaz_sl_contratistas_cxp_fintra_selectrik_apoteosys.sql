﻿-- Function: con.interfaz_sl_contratistas_cxp_fintra_selectrik_apoteosys()

-- DROP FUNCTION con.interfaz_sl_contratistas_cxp_fintra_selectrik_apoteosys();

CREATE OR REPLACE FUNCTION con.interfaz_sl_contratistas_cxp_fintra_selectrik_apoteosys()
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
LONGITUD NUMERIC;
SECUENCIA_GEN INTEGER;
SECUENCIA_INT INTEGER:= 1;
CUENTAS_IVA VARCHAR[] := '{}';
FECHADOC_ VARCHAR:= '';
MCTYPE CON.TYPE_INSERT_MC;
SW TEXT:='N';
VALIDACIONES TEXT;
_EXISTE CHARACTER VARYING :='';
DOC_REL	CHARACTER VARYING :='';

BEGIN
	/**SACAMOS EL LISTADO DE NC*/
	--paso 6
	FOR FACTURA_NM IN 

			SELECT 
				CXP.TIPO_DOCUMENTO, 
				CXP.FECHA_DOCUMENTO AS FECHA_FACTURA,
				CXP.FECHA_VENCIMIENTO,
				CXP.PROVEEDOR AS NIT,
				CXP.PERIODO, 					
				CXP.DESCRIPCION,
				CXP.DOCUMENTO				
			FROM FIN.CXP_DOC     AS CXP
			INNER JOIN PROVEEDOR AS PROV ON (CXP.PROVEEDOR = PROV.NIT )
			WHERE CXP.HANDLE_CODE		='TF'
			AND   CXP.TIPO_DOCUMENTO	='FAP' 			 	 
			AND   CXP.PERIODO		='201712'
			AND   CXP.REG_STATUS		=''
			AND   CXP.DESCRIPCION 		LIKE 'CXP A FINTRA TRASLADO ING MS%'
			AND   COALESCE(CXP.PROCESADO, 'N') = 'N'
			AND   DOCUMENTO NOT IN (SELECT DOCUMENTO FROM FIN.CXP_DOC WHERE DOCUMENTO IN ('T00000425','T00000417','T00000419','T00000428','T00000440','T00000441','T00000447','T00000448','T00000635','T00000747'))
			ORDER BY CXP.DOCUMENTO


			--SELECT CON.INTERFAZ_SL_CONTRATISTAS_CXP_FINTRA_SELECTRIK_APOTEOSYS();			
					

	LOOP					
			DOC_REL := (SELECT referencia_1 FROM fin.cxp_items_doc WHERE documento = FACTURA_NM.DOCUMENTO AND  CODIGO_CUENTA = '11050524');
			
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
			WHERE NIT = FACTURA_NM.NIT;

			----SECUENCIA GENERAL
			SELECT INTO SECUENCIA_GEN  NEXTVAL('CON.INTERFAZ_SECUENCIA_R_APOTEOSYS');		

			MCTYPE.MC_____CODIGO____CONTAB_B := 'SELE'; 
			MCTYPE.MC_____CODIGO____TD_____B := 'CXPN'; 
			MCTYPE.MC_____CODIGO____CD_____B := 'CPFI'; 
			MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN; --SECUENCIA GENERAL

			/**BUSCAMOS LA INFORMACION COMPLETA QUE CONFORMARA EL ASIENTO CONTABLE PARA MANDARLO A APOTEOSYS*/

			FOR INFOITEMS_ IN 

				
				SELECT * FROM(
				SELECT 
					FACTURA_NM.DOCUMENTO,--TT.DOCUMENTO,
					T1.TIPO_DOCUMENTO,
					T1.CODIGO_CUENTA AS CUENTA,	
					T1.PROVEEDOR,	
					T1.ID_ACCION,
					T1.NUM_OS,	
					T1.CENTRO_COSTOS_INGRESO,
					T1.CENTRO_COSTOS_GASTOS,
					T1.VLR-((T1.VLR*(T1.TOTAL_DESCUENTO_FACTORING/100))) AS VALOR_DEB,
					0.00::NUMERIC AS VALOR_CREDT,
					UPPER(T1.DESCRIPCION)AS  DESCRIPCION
				      FROM (
				      SELECT CXP.PROVEEDOR,
					     CXP.TIPO_DOCUMENTO,
					     CXP.DOCUMENTO,
					     'CANCELA FACTURA CONTRATISTA POR TRASLADO A FINTRA : '||ACC.ID_ACCION AS DESCRIPCION,
					     (SUM(CXPDET.VLR)) AS VLR,
					     CXPDET.CODIGO_CUENTA,
					     ACC.ID_ACCION,
					     OFER.NUM_OS, 
					     OFER.CENTRO_COSTOS_INGRESO,
					     OFER.CENTRO_COSTOS_GASTOS,
					     ACC.POR_FACTORING_CONTRATISTA,
					     ACC.POR_FORMULA_CONTRATISTA,
					     (ACC.POR_FACTORING_CONTRATISTA+ACC.POR_FORMULA_CONTRATISTA) AS TOTAL_DESCUENTO_FACTORING,
					     CXP.FECHA_DOCUMENTO,
					     CXP.FECHA_VENCIMIENTO           
				      FROM FIN.CXP_ITEMS_DOC CXPDET
				      INNER JOIN FIN.CXP_DOC CXP ON (CXP.DOCUMENTO=CXPDET.DOCUMENTO AND CXP.TIPO_DOCUMENTO=CXPDET.TIPO_DOCUMENTO AND CXP.PROVEEDOR=CXPDET.PROVEEDOR)
				      INNER JOIN OPAV.ACCIONES ACC ON (ACC.ID_ACCION=CXPDET.REFERENCIA_1 AND ACC.REG_STATUS!='A')
				      INNER JOIN OPAV.OFERTAS AS OFER ON (ACC.ID_SOLICITUD = OFER.ID_SOLICITUD)
				      INNER JOIN PROVEEDOR AS PRV  ON (CXP.PROVEEDOR=PRV.NIT)
				      WHERE 
				      CXP.DOCUMENTO= DOC_REL--FACTURA_NM.DOCUMENTO   ---?
				      AND CXP.PROVEEDOR = FACTURA_NM.NIT ---?
				      AND CXP.TIPO_DOCUMENTO='FAP' 
				      AND CXP.HANDLE_CODE ='CD' 
				      AND CXP.DESCRIPCION LIKE 'Reunifica facturas internas:%'
				      AND COALESCE(PROCESADO,'N')  = 'S' 
				      GROUP BY 
				      CXP.PROVEEDOR,
				      CXP.TIPO_DOCUMENTO,
				      CXP.DOCUMENTO,
				      CXPDET.CODIGO_CUENTA,
				      ACC.ID_ACCION, 
				      ACC.POR_FACTORING_CONTRATISTA,
				      ACC.POR_FORMULA_CONTRATISTA,
				      OFER.CENTRO_COSTOS_INGRESO,
				      OFER.CENTRO_COSTOS_GASTOS,
				      OFER.NUM_OS,
				      CXP.FECHA_DOCUMENTO,
				      CXP.FECHA_VENCIMIENTO
				      
				     )T1
				UNION ALL
				SELECT 
					FACTURA_NM.DOCUMENTO ,--TT.DOCUMENTO,
					CXP.TIPO_DOCUMENTO,
					CXPDET.CODIGO_CUENTA AS CUENTA,	
					CXP.PROVEEDOR,	
					ACC.ID_ACCION,
					OFER.NUM_OS,	
					OFER.CENTRO_COSTOS_INGRESO,
					OFER.CENTRO_COSTOS_GASTOS,
					SUM(CXPDET.VLR) AS VALOR_DEB,
					0::NUMERIC AS VALOR_CREDT,
					UPPER(CXPDET.DESCRIPCION)AS  DESCRIPCION
					--CXPDET.*
				FROM FIN.CXP_ITEMS_DOC CXPDET
				INNER JOIN FIN.CXP_DOC CXP ON (CXPDET.DOCUMENTO =CXP.DOCUMENTO AND CXPDET.TIPO_DOCUMENTO=CXP.TIPO_DOCUMENTO )
				LEFT JOIN OPAV.ACCIONES ACC ON (ACC.ID_ACCION=CXPDET.REFERENCIA_1 AND ACC.REG_STATUS!='A')
				LEFT JOIN OPAV.OFERTAS AS OFER	ON (ACC.ID_SOLICITUD = OFER.ID_SOLICITUD)
				WHERE CXP.TIPO_DOCUMENTO= 'FAP'--FACTURA_NM.TIPO_DOCUMENTO
				AND   CXP.HANDLE_CODE = 'TF'
				AND   CXP.DOCUMENTO 	= FACTURA_NM.DOCUMENTO  --FACTURA_NM.DOCUMENTO
				AND   CXPDET.CODIGO_CUENTA != '11050524'
				--AND   CXP.REG_STATUS		=''
				GROUP BY 
				      CXPDET.CODIGO_CUENTA, 
				      CXPDET.DESCRIPCION,
				      CXP.DOCUMENTO, 
				      CXP.TIPO_DOCUMENTO,	
				      CXP.PROVEEDOR,	
				      ACC.ID_ACCION,
				      OFER.NUM_OS,	
				      OFER.CENTRO_COSTOS_INGRESO,
				      OFER.CENTRO_COSTOS_GASTOS

				UNION ALL

				SELECT
					FACTURA_NM.DOCUMENTO ,--TT.DOCUMENTO,
					TT.TIPO_DOCUMENTO,
					'22050803' AS CUENTA,	
					TT.PROVEEDOR,	
					TT.ID_ACCION,
					TT.NUM_OS,	
					TT.CENTRO_COSTOS_INGRESO,
					TT.CENTRO_COSTOS_GASTOS,
					0.00::NUMERIC AS VALOR_DEB,
					SUM(TT.VALOR_DEB) AS VALOR_CREDT,
					'CXP A FINTRA TRASLADO ING MS' AS  DESCRIPCION
					
				FROM(
					SELECT 
						T1.DOCUMENTO,
						T1.TIPO_DOCUMENTO,
						T1.CODIGO_CUENTA AS CUENTA,	
						T1.PROVEEDOR,	
						T1.ID_ACCION,
						T1.NUM_OS,	
						T1.CENTRO_COSTOS_INGRESO,
						T1.CENTRO_COSTOS_GASTOS,
						T1.VLR-((T1.VLR*(T1.TOTAL_DESCUENTO_FACTORING/100))) AS VALOR_DEB,
						0.00::NUMERIC AS VALOR_CREDT,
						UPPER(T1.DESCRIPCION)AS  DESCRIPCION
					      FROM (
					      SELECT CXP.PROVEEDOR,
						     CXP.TIPO_DOCUMENTO,
						     CXP.DOCUMENTO,
						     'CANCELA FACTURA CONTRATISTA POR TRASLADO A FINTRA : '||ACC.ID_ACCION AS DESCRIPCION,
						     (SUM(CXPDET.VLR)) AS VLR,
						     CXPDET.CODIGO_CUENTA,
						     ACC.ID_ACCION,
						     OFER.NUM_OS, 
						     OFER.CENTRO_COSTOS_INGRESO,
						     OFER.CENTRO_COSTOS_GASTOS,
						     ACC.POR_FACTORING_CONTRATISTA,
						     ACC.POR_FORMULA_CONTRATISTA,
						     (ACC.POR_FACTORING_CONTRATISTA+ACC.POR_FORMULA_CONTRATISTA) AS TOTAL_DESCUENTO_FACTORING,
						     CXP.FECHA_DOCUMENTO,
						     CXP.FECHA_VENCIMIENTO           
					      FROM FIN.CXP_ITEMS_DOC CXPDET
					      INNER JOIN FIN.CXP_DOC CXP ON (CXP.DOCUMENTO=CXPDET.DOCUMENTO AND CXP.TIPO_DOCUMENTO=CXPDET.TIPO_DOCUMENTO AND CXP.PROVEEDOR=CXPDET.PROVEEDOR)
					      INNER JOIN OPAV.ACCIONES ACC ON (ACC.ID_ACCION=CXPDET.REFERENCIA_1 AND ACC.REG_STATUS!='A')
					      INNER JOIN OPAV.OFERTAS AS OFER ON (ACC.ID_SOLICITUD = OFER.ID_SOLICITUD)
					      INNER JOIN PROVEEDOR AS PRV  ON (CXP.PROVEEDOR=PRV.NIT)
					      WHERE 
					      CXP.DOCUMENTO = DOC_REL  --FACTURA_NM.DOCUMENTO   ---?
					      AND CXP.PROVEEDOR = FACTURA_NM.NIT ---?
					      AND CXP.TIPO_DOCUMENTO='FAP' 
					      AND CXP.HANDLE_CODE ='CD' 
					      AND CXP.DESCRIPCION LIKE 'Reunifica facturas internas:%'
					      AND COALESCE(PROCESADO,'N')  = 'S' 
					      GROUP BY 
					      CXP.PROVEEDOR,
					      CXP.TIPO_DOCUMENTO,
					      CXP.DOCUMENTO,
					      CXPDET.CODIGO_CUENTA,
					      ACC.ID_ACCION, 
					      ACC.POR_FACTORING_CONTRATISTA,
					      ACC.POR_FORMULA_CONTRATISTA,
					      OFER.CENTRO_COSTOS_INGRESO,
					      OFER.CENTRO_COSTOS_GASTOS,
					      OFER.NUM_OS,
					      CXP.FECHA_DOCUMENTO,
					      CXP.FECHA_VENCIMIENTO
					      
					     )T1
					UNION ALL
					SELECT 
						CXP.DOCUMENTO, 
						CXP.TIPO_DOCUMENTO,
						CXPDET.CODIGO_CUENTA AS CUENTA,	
						CXP.PROVEEDOR,	
						ACC.ID_ACCION,
						OFER.NUM_OS,	
						OFER.CENTRO_COSTOS_INGRESO,
						OFER.CENTRO_COSTOS_GASTOS,
						SUM(CXPDET.VLR) AS VALOR_DEB,
						0::NUMERIC AS VALOR_CREDT,
						UPPER(CXPDET.DESCRIPCION)AS  DESCRIPCION
						--CXPDET.*
					FROM FIN.CXP_ITEMS_DOC CXPDET
					INNER JOIN FIN.CXP_DOC CXP ON (CXPDET.DOCUMENTO =CXP.DOCUMENTO AND CXPDET.TIPO_DOCUMENTO=CXP.TIPO_DOCUMENTO )
					LEFT JOIN OPAV.ACCIONES ACC ON (ACC.ID_ACCION=CXPDET.REFERENCIA_1 AND ACC.REG_STATUS!='A')
					LEFT JOIN OPAV.OFERTAS AS OFER	ON (ACC.ID_SOLICITUD = OFER.ID_SOLICITUD)
					WHERE CXP.TIPO_DOCUMENTO= 'FAP'--FACTURA_NM.TIPO_DOCUMENTO
					AND   CXP.HANDLE_CODE = 'TF'
					AND   CXP.DOCUMENTO 	= FACTURA_NM.DOCUMENTO  --FACTURA_NM.DOCUMENTO
					AND   CXPDET.CODIGO_CUENTA != '11050524'
					--AND   CXP.REG_STATUS		=''
					GROUP BY 
					      CXPDET.CODIGO_CUENTA, 
					      CXPDET.DESCRIPCION,
					      CXP.DOCUMENTO, 
					      CXP.TIPO_DOCUMENTO,	
					      CXP.PROVEEDOR,	
					      ACC.ID_ACCION,
					      OFER.NUM_OS,	
					      OFER.CENTRO_COSTOS_INGRESO,
					      OFER.CENTRO_COSTOS_GASTOS
				)AS TT 
					GROUP BY 
					TT.DOCUMENTO,
					TT.TIPO_DOCUMENTO,
					TT.PROVEEDOR,	
					TT.ID_ACCION,
					TT.NUM_OS,	
					TT.CENTRO_COSTOS_INGRESO,
					TT.CENTRO_COSTOS_GASTOS
					) AS X where X.VALOR_CREDT!=0 OR X.VALOR_DEB!=0				
					ORDER BY NUM_OS , VALOR_DEB DESC
								
						
			LOOP						
				RAISE NOTICE '<<<<==== TERMINO ====>>>> %',INFOITEMS_.CUENTA;

				IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('CXP_SEL','FAP', INFOITEMS_.CUENTA,'', 6)='S')THEN
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
				MCTYPE.MC_____SECUINTE__B := SECUENCIA_INT;       --SECUENCIA INTERNA
				MCTYPE.MC_____REFERENCI_B := '-';   --CAMBIAR A MULTISERVICIO...
				MCTYPE.MC_____CODIGO____PF_____B := SUBSTRING( FACTURA_NM.PERIODO,1,4)::INT; 
				MCTYPE.MC_____NUMERO____PERIOD_B := SUBSTRING( FACTURA_NM.PERIODO,5,2)::INT;
				MCTYPE.MC_____CODIGO____PC_____B :=  'PUCF'; 
				MCTYPE.MC_____CODIGO____CPC____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('CXP_SEL', 'FAP', INFOITEMS_.CUENTA,'', 1); 
				MCTYPE.MC_____CODIGO____CU_____B := INFOITEMS_.CENTRO_COSTOS_INGRESO;
				MCTYPE.MC_____IDENTIFIC_TERCER_B := SUBSTRING(REPLACE(FACTURA_NM.NIT,'-',''),1,9);
				MCTYPE.MC_____DEBMONORI_B := 0; 
				MCTYPE.MC_____CREMONORI_B := 0;
				MCTYPE.MC_____DEBMONLOC_B := INFOITEMS_.VALOR_DEB::NUMERIC;
				MCTYPE.MC_____CREMONLOC_B := INFOITEMS_.VALOR_CREDT::NUMERIC;
				MCTYPE.MC_____INDTIPMOV_B := 4;
				MCTYPE.MC_____INDMOVREV_B := 'N';
				MCTYPE.MC_____OBSERVACI_B := SUBSTRING(INFOITEMS_.NUM_OS||' : '||INFOITEMS_.DESCRIPCION,1,249);
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
				MCTYPE.MC_____CODIGO____DS_____B := CON.OBTENER_HOMOLOGACION_APOTEOSYS('CXP_SEL','FAP', INFOITEMS_.CUENTA,'', 3);
				MCTYPE.MC_____BASE______B:=0;

				IF(MCTYPE.MC_____FECHEMIS__B > MCTYPE.MC_____FECHA_____B) THEN
					MCTYPE.MC_____FECHEMIS__B :=  MCTYPE.MC_____FECHA_____B;
				END IF;

				
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

				IF(CON.OBTENER_HOMOLOGACION_APOTEOSYS('CXP_SEL', 'FAP', INFOITEMS_.CUENTA,'', 5)::INT=1)THEN
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
			--UPDATE FIN.CXP_DOC SET PROCESADO = 'S' WHERE DOCUMENTO =  FACTURA_NM.DOCUMENTO AND TIPO_DOCUMENTO = 'FAP' AND HANDLE_CODE = 'TF';

			UPDATE FIN.CXP_DOC SET PROCESADO = 'S'
			WHERE DOCUMENTO = FACTURA_NM.DOCUMENTO 
			AND TIPO_DOCUMENTO = 'FAP'				
			AND HANDLE_CODE	='TF'
			AND PROVEEDOR=FACTURA_NM.NIT 
			AND REG_STATUS =''
			AND DESCRIPCION LIKE 'CXP A FINTRA TRASLADO ING MS%'
			AND COALESCE(PROCESADO, 'N' ) = 'N';
			
		END IF;

		SECUENCIA_INT:=1;		

	END LOOP;

	
RETURN 'OK';

END
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_sl_contratistas_cxp_fintra_selectrik_apoteosys()
  OWNER TO postgres;
