-- Table: tem.traslado_cxp_contratistas_fintra_selectrik

-- DROP TABLE tem.traslado_cxp_contratistas_fintra_selectrik;

CREATE TABLE tem.traslado_cxp_contratistas_fintra_selectrik
(
  id serial NOT NULL,
  periodo character varying(6) NOT NULL DEFAULT ''::character varying,
  documento character varying(17) NOT NULL DEFAULT ''::character varying,
  concepto character varying(4) NOT NULL DEFAULT ''::character varying,
  procesado character varying(1) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp with time zone,
  user_update character varying(16)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tem.traslado_cxp_contratistas_fintra_selectrik
  OWNER TO postgres;
