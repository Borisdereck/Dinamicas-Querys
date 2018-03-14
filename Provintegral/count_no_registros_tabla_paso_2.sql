-- Function: number_records_mc_egre_prov_provint(character varying)

-- DROP FUNCTION number_records_mc_egre_prov_provint(character varying);

CREATE OR REPLACE FUNCTION number_records_mc_egre_prov_provint(OUT total integer, IN per character varying)
  RETURNS integer AS
$BODY$
BEGIN
	SELECT INTO total COUNT(*)
	FROM 	CON.MC_EGRE_PROV_PROVINT 
	WHERE REPLACE(SUBSTRING(CREATION_DATE,1,7),'-','') =PER;

	IF (total = 0) THEN
		RAISE NOTICE 'Tabla vacia Careverga';		
	END IF;	 

END;
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION number_records_mc_egre_prov_provint(character varying)
  OWNER TO postgres;


