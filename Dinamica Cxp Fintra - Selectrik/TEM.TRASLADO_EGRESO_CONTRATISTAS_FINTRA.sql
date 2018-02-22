-- Table: tem.traslado_egreso_contratistas_fintra

-- DROP TABLE tem.traslado_egreso_contratistas_fintra;

CREATE TABLE tem.traslado_egreso_contratistas_fintra
(
  periodo character varying(6) NOT NULL,
  branch_code character varying(15) NOT NULL DEFAULT ''::character varying,
  bank_account_no character varying(30) NOT NULL DEFAULT ''::character varying,
  document_no character varying(17) NOT NULL DEFAULT ''::character varying,
  tipo_documento character varying(15),
  handle_code character varying(15) NOT NULL DEFAULT ''::character varying,
  proveedor character varying(15),
  procesado character varying(1) NOT NULL DEFAULT ''::character varying,
  creation_date timestamp without time zone NOT NULL DEFAULT now(),
  creation_user character varying(10) NOT NULL DEFAULT ''::character varying,
  last_update timestamp with time zone,
  user_update character varying(16)
 )
WITH (
  OIDS=FALSE
);
ALTER TABLE tem.traslado_egreso_contratistas_fintra
  OWNER TO postgres;



CREATE INDEX egreso_contratistas_index
ON tem.traslado_egreso_contratistas_fintra (branch_code, bank_account_no,document_no);