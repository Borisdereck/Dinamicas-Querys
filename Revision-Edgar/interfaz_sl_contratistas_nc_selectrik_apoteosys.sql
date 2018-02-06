﻿-- Function: con.interfaz_sl_contratistas_nc_selectrik_apoteosys()

-- DROP FUNCTION con.interfaz_sl_contratistas_nc_selectrik_apoteosys();

CREATE OR REPLACE FUNCTION con.interfaz_sl_contratistas_nc_selectrik_apoteosys()
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

BEGIN
	/**SACAMOS EL LISTADO DE NC*/

	FOR FACTURA_NM IN 
		
				SELECT 
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
				FROM FIN.CXP_DOC 		AS A
				INNER JOIN PROVEEDOR 		AS PROV ON (PROV.NIT=A.PROVEEDOR)
				INNER JOIN OPAV.ACCIONES 	AS B	ON (A.REFERENCIA_1 = B.ID_ACCION)
				INNER JOIN OPAV.OFERTAS 	AS C	ON (B.ID_SOLICITUD = C.ID_SOLICITUD)
				WHERE 
					TIPO_DOCUMENTO		=	'NC' 
					AND HANDLE_CODE		=	'CI' 
					AND PERIODO		=	'201711'
					AND DOCUMENTO 		LIKE 	'CC%'
					AND A.REG_STATUS 	= 	''	
					AND C.CENTRO_COSTOS_INGRESO !=  ''
					--AND COALESCE(PROCESADO, 'N' ) = 'N'

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
		MCTYPE.MC_____CODIGO____CD_____B := 'NCSL'; 
		MCTYPE.MC_____NUMERO____B := SECUENCIA_GEN; --SECUENCIA GENERAL

		/**BUSCAMOS LA INFORMACION COMPLETA QUE CONFORMARA EL ASIENTO CONTABLE PARA MANDARLO A APOTEOSYS*/

		FOR INFOITEMS_ IN 			        

				SELECT 
					TIPO_DOCUMENTO,
					CODIGO_CUENTA AS CUENTA,	
					PROVEEDOR,										
					CASE WHEN VLR<0 THEN VLR*-1 ELSE 0 END AS VALOR_DEB,
					CASE WHEN VLR>0 THEN VLR ELSE 0 END AS VALOR_CREDT,
					DESCRIPCION
				FROM 
					FIN.CXP_ITEMS_DOC
				WHERE TIPO_DOCUMENTO	= 	'NC'
					AND DOCUMENTO 	=	FACTURA_NM.DOCUMENTO
				UNION ALL
				SELECT
					TIPO_DOCUMENTO,
					CMC.CUENTA,
					PROVEEDOR,			
					VLR_NETO AS VALOR_DEB,
					0 AS VALOR_CREDT,
					DESCRIPCION
				FROM 
					FIN.CXP_DOC 	CXP
				INNER JOIN CON.CMC_DOC AS CMC  ON (CXP.HANDLE_CODE = CMC.CMC AND CMC.TIPODOC = CXP.TIPO_DOCUMENTO)
				WHERE TIPO_DOCUMENTO	=	'NC' 
					AND DOCUMENTO 	=	FACTURA_NM.DOCUMENTO

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
			MCTYPE.MC_____REFERENCI_B := FACTURA_NM.NUM_OS; ---CAMBIAR A MULTISERVICIO...
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
			MCTYPE.MC_____OBSERVACI_B := SUBSTRING(INFOITEMS_.DESCRIPCION,1,249);
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
			UPDATE FIN.CXP_DOC SET PROCESADO = 'S' WHERE DOCUMENTO =  FACTURA_NM.DOCUMENTO AND TIPO_DOCUMENTO = 'NC' AND HANDLE_CODE = 'CI' ;
		END IF;

		SECUENCIA_INT:=1;		

	END LOOP;

	
RETURN 'OK';

END
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION con.interfaz_sl_contratistas_nc_selectrik_apoteosys()
  OWNER TO postgres;


select con.interfaz_sl_contratistas_nc_selectrik_apoteosys();

--TRUNCATE TABLE CON.MC_SL_FAC_CC_SEL;

SELECT tercer_nombexte__b,COUNT(0) FROM  CON.MC_SL_FAC_CC_SEL WHERE PROCESADO='N' GROUP BY tercer_nombexte__b ;
