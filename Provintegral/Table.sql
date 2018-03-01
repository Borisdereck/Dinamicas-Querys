﻿-- Table: con.mc_egre_prov_provint

-- DROP TABLE con.mc_egre_prov_provint;

CREATE TABLE con.mc_egre_prov_provint
(
  mc_____codigo____contab_b character varying(4) NOT NULL,
  mc_____codigo____td_____b character varying(4) NOT NULL,
  mc_____codigo____cd_____b character varying(4) NOT NULL,
  mc_____secuinte__dcd____b integer,
  mc_____fecha_____b timestamp without time zone NOT NULL DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  mc_____numero____b character varying(26) NOT NULL,
  mc_____secuinte__b integer NOT NULL,
  mc_____codigo____pf_____b character varying(4),
  mc_____numero____period_b integer,
  mc_____codigo____pc_____b character varying(4),
  mc_____codigo____cpc____b character varying(26),
  mc_____codigo____pp_____det_b character varying(4),
  mc_____codigo____pf_____det_b character varying(4),
  mc_____codigo____rpppf__det_b character varying(50),
  mc_____codigo____cu_____b character varying(50),
  mc_____identific_tercer_b character varying(50),
  mc_____codigo____refere_b character varying(50),
  mc_____codigo____ds_____b character varying(4),
  mc_____numdocsop_b character varying(40),
  mc_____numevenc__b integer,
  mc_____numecuot__b integer,
  mc_____fechemis__b timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  mc_____fechvenc__b timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  mc_____fechdesc__b timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  mc_____valodesc__b numeric(17,2),
  mc_____porcdesc__b numeric(8,5),
  mc_____referenci_b character varying(50),
  mc_____valoiva___b numeric(17,2),
  mc_____valorete__b numeric(17,2),
  mc_____base______b numeric(17,2),
  mc_____fectascam_b timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  mc_____debmonori_b numeric(17,2),
  mc_____cremonori_b numeric(17,2),
  mc_____debmonloc_b numeric(17,2),
  mc_____cremonloc_b numeric(17,2),
  mc_____numunideb_b numeric(17,2),
  mc_____numunicre_b numeric(17,2),
  mc_____indtipmov_b integer,
  mc_____indmovrev_b character varying(1),
  mc_____observaci_b character varying(255),
  mc_____fechorcre_b timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  mc_____autocrea__b character varying(50),
  mc_____fehoulmo__b timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone,
  mc_____autultmod_b character varying(50),
  mc_____usuaauto__b character varying(50),
  mc_____codigo____tdsp___b character varying(4),
  mc_____numero____dsp____b character varying(50),
  mc_____codigo____pf_____dsp_b character varying(4),
  mc_____baseorig__b numeric(17,2),
  mc_____codigo____pf_____dif_b character varying(4),
  mc_____numero____period_dif_b integer,
  mc_____innoejpr__b integer,
  mc_____prefprov__b character varying(10),
  mc_____tipotran__b integer,
  mc_____numetran__b integer,
  mc_____codigo____client_b integer,
  mc_____codigo____dircli_b character varying(4),
  mc_____codigo____sucurs_b character varying(4),
  mc_____codigo____vended_b integer,
  mc_____codigo____cobrad_b integer,
  mc_____porcomven_b numeric(8,5),
  mc_____porcomcob_b numeric(8,5),
  mc_____valimpcon_b numeric(17,2),
  tercer_codigo____tit____b character varying(4),
  tercer_nombcort__b character varying(32),
  tercer_nombexte__b character varying(64),
  tercer_apellidos_b character varying(32),
  tercer_codigo____tt_____b character varying(4),
  tercer_direccion_b character varying(64),
  tercer_codigo____ciudad_b character varying(8),
  tercer_telefono1_b character varying(50),
  tercer_tipogiro__b character varying(1),
  tercer_codigo____ef_____b character varying(4),
  tercer_sucursal__b character varying(50),
  tercer_numecuen__b character varying(50),
  procesado character varying(1) DEFAULT 'N'::character varying,
  num_proceso character varying(50) DEFAULT ''::character varying,
  creation_date timestamp without time zone DEFAULT (now())::timestamp without time zone,
  fecha_lote_apoteosys timestamp without time zone DEFAULT '0099-01-01 00:00:00'::timestamp without time zone
)
WITH (
  OIDS=FALSE
);
ALTER TABLE con.mc_egre_prov_provint
  OWNER TO postgres;
COMMENT ON TABLE con.mc_egre_prov_provint
  IS 'DOCUMENTOS EGRESO PAGO A PROVEEDORES PROVINTEGRAL';
