-- _______________ENCOURS_______________GEOLLLIBRE
-- D'abord, les tables.

/* vu: {{{

CREATE SCHEMA checks;


ALTER SCHEMA checks OWNER TO pierre;
COMMENT ON SCHEMA checks IS 'Views selecting unconsistent, incoherent, unprobable data';

CREATE SCHEMA gdm;


ALTER SCHEMA gdm OWNER TO pierre;
CREATE SCHEMA input;
ALTER SCHEMA input OWNER TO pierre;
COMMENT ON SCHEMA input IS 'Tables with same structure as in public schema, for data input before validation and dump into final tables (apparently unused on 2013_08_03__11_40_18)';

CREATE SCHEMA pierre;
ALTER SCHEMA pierre OWNER TO pierre;


CREATE SCHEMA stats_reports;
ALTER SCHEMA stats_reports OWNER TO pierre;
COMMENT ON SCHEMA stats_reports IS 'Views with statistics and reports, for daily/weekly/monthly statistics';

CREATE SCHEMA tmp_a_traiter;


ALTER SCHEMA tmp_a_traiter OWNER TO pierre;
CREATE SCHEMA tmp_imports;


ALTER SCHEMA tmp_imports OWNER TO pierre;
CREATE SCHEMA tmp_ntoto;


ALTER SCHEMA tmp_ntoto OWNER TO pierre;
CREATE SCHEMA topology;


ALTER SCHEMA topology OWNER TO postgres;
CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';

CREATE OR REPLACE PROCEDURAL LANGUAGE plpythonu;


ALTER PROCEDURAL LANGUAGE plpythonu OWNER TO postgres;
CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';

CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA topology;

COMMENT ON EXTENSION postgis_topology IS 'PostGIS topology spatial types and functions';


SET search_path = public, pg_catalog;


}}}
vu, du postgis:{{{
--
-- Name: box3d_extent; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE box3d_extent;


ALTER TYPE box3d_extent OWNER TO postgres;
CREATE TYPE chip;


ALTER TYPE chip OWNER TO postgres;
CREATE FUNCTION addgeometrycolumn(character varying, character varying, integer, character varying, integer) RETURNS text
    LANGUAGE plpgsql STRICT
    AS $_$
DECLARE
	ret  text;
BEGIN
	SELECT AddGeometryColumn('','',$1,$2,$3,$4,$5) into ret;
	RETURN ret;
END;
$_$;


ALTER FUNCTION public.addgeometrycolumn(character varying, character varying, integer, character varying, integer) OWNER TO postgres;
CREATE FUNCTION addgeometrycolumn(character varying, character varying, character varying, integer, character varying, integer) RETURNS text
    LANGUAGE plpgsql STABLE STRICT
    AS $_$
DECLARE
	ret  text;
BEGIN
	SELECT AddGeometryColumn('',$1,$2,$3,$4,$5,$6) into ret;
	RETURN ret;
END;
$_$;


ALTER FUNCTION public.addgeometrycolumn(character varying, character varying, character varying, integer, character varying, integer) OWNER TO postgres;

--
-- Name: addgeometrycolumn(character varying, character varying, character varying, character varying, integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--
CREATE FUNCTION addgeometrycolumn(character varying, character varying, character varying, character varying, integer, character varying, integer) RETURNS text
    LANGUAGE plpgsql STRICT
    AS $_$
DECLARE
	catalog_name alias for $1;
	schema_name alias for $2;
	table_name alias for $3;
	column_name alias for $4;
	new_srid alias for $5;
	new_type alias for $6;
	new_dim alias for $7;
	rec RECORD;
	sr text;
	real_schema name;
	sql text;

BEGIN

	-- Verify geometry type
	IF ( NOT ( (new_type = 'GEOMETRY') OR
			   (new_type = 'GEOMETRYCOLLECTION') OR
			   (new_type = 'POINT') OR
			   (new_type = 'MULTIPOINT') OR
			   (new_type = 'POLYGON') OR
			   (new_type = 'MULTIPOLYGON') OR
			   (new_type = 'LINESTRING') OR
			   (new_type = 'MULTILINESTRING') OR
			   (new_type = 'GEOMETRYCOLLECTIONM') OR
			   (new_type = 'POINTM') OR
			   (new_type = 'MULTIPOINTM') OR
			   (new_type = 'POLYGONM') OR
			   (new_type = 'MULTIPOLYGONM') OR
			   (new_type = 'LINESTRINGM') OR
			   (new_type = 'MULTILINESTRINGM') OR
			   (new_type = 'CIRCULARSTRING') OR
			   (new_type = 'CIRCULARSTRINGM') OR
			   (new_type = 'COMPOUNDCURVE') OR
			   (new_type = 'COMPOUNDCURVEM') OR
			   (new_type = 'CURVEPOLYGON') OR
			   (new_type = 'CURVEPOLYGONM') OR
			   (new_type = 'MULTICURVE') OR
			   (new_type = 'MULTICURVEM') OR
			   (new_type = 'MULTISURFACE') OR
			   (new_type = 'MULTISURFACEM')) )
	THEN
		RAISE EXCEPTION 'Invalid type name - valid ones are:
	POINT, MULTIPOINT,
	LINESTRING, MULTILINESTRING,
	POLYGON, MULTIPOLYGON,
	CIRCULARSTRING, COMPOUNDCURVE, MULTICURVE,
	CURVEPOLYGON, MULTISURFACE,
	GEOMETRY, GEOMETRYCOLLECTION,
	POINTM, MULTIPOINTM,
	LINESTRINGM, MULTILINESTRINGM,
	POLYGONM, MULTIPOLYGONM,
	CIRCULARSTRINGM, COMPOUNDCURVEM, MULTICURVEM
	CURVEPOLYGONM, MULTISURFACEM,
	or GEOMETRYCOLLECTIONM';
		RETURN 'fail';
	END IF;


	-- Verify dimension
	IF ( (new_dim >4) OR (new_dim <0) ) THEN
		RAISE EXCEPTION 'invalid dimension';
		RETURN 'fail';
	END IF;

	IF ( (new_type LIKE '%M') AND (new_dim!=3) ) THEN
		RAISE EXCEPTION 'TypeM needs 3 dimensions';
		RETURN 'fail';
	END IF;


	-- Verify SRID
	IF ( new_srid != -1 ) THEN
		SELECT SRID INTO sr FROM spatial_ref_sys WHERE SRID = new_srid;
		IF NOT FOUND THEN
			RAISE EXCEPTION 'AddGeometryColumns() - invalid SRID';
			RETURN 'fail';
		END IF;
	END IF;


	-- Verify schema
	IF ( schema_name IS NOT NULL AND schema_name != '' ) THEN
		sql := 'SELECT nspname FROM pg_namespace ' ||
			'WHERE text(nspname) = ' || quote_literal(schema_name) ||
			'LIMIT 1';
		RAISE DEBUG '%', sql;
		EXECUTE sql INTO real_schema;

		IF ( real_schema IS NULL ) THEN
			RAISE EXCEPTION 'Schema % is not a valid schemaname', quote_literal(schema_name);
			RETURN 'fail';
		END IF;
	END IF;

	IF ( real_schema IS NULL ) THEN
		RAISE DEBUG 'Detecting schema';
		sql := 'SELECT n.nspname AS schemaname ' ||
			'FROM pg_catalog.pg_class c ' ||
			  'JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace ' ||
			'WHERE c.relkind = ' || quote_literal('r') ||
			' AND n.nspname NOT IN (' || quote_literal('pg_catalog') || ', ' || quote_literal('pg_toast') || ')' ||
			' AND pg_catalog.pg_table_is_visible(c.oid)' ||
			' AND c.relname = ' || quote_literal(table_name);
		RAISE DEBUG '%', sql;
		EXECUTE sql INTO real_schema;

		IF ( real_schema IS NULL ) THEN
			RAISE EXCEPTION 'Table % does not occur in the search_path', quote_literal(table_name);
			RETURN 'fail';
		END IF;
	END IF;


	-- Add geometry column to table
	sql := 'ALTER TABLE ' ||
		quote_ident(real_schema) || '.' || quote_ident(table_name)
		|| ' ADD COLUMN ' || quote_ident(column_name) ||
		' geometry ';
	RAISE DEBUG '%', sql;
	EXECUTE sql;


	-- Delete stale record in geometry_columns (if any)
	sql := 'DELETE FROM geometry_columns WHERE
		f_table_catalog = ' || quote_literal('') ||
		' AND f_table_schema = ' ||
		quote_literal(real_schema) ||
		' AND f_table_name = ' || quote_literal(table_name) ||
		' AND f_geometry_column = ' || quote_literal(column_name);
	RAISE DEBUG '%', sql;
	EXECUTE sql;


	-- Add record in geometry_columns
	sql := 'INSERT INTO geometry_columns (f_table_catalog,f_table_schema,f_table_name,' ||
										  'f_geometry_column,coord_dimension,srid,type)' ||
		' VALUES (' ||
		quote_literal('') || ',' ||
		quote_literal(real_schema) || ',' ||
		quote_literal(table_name) || ',' ||
		quote_literal(column_name) || ',' ||
		new_dim::text || ',' ||
		new_srid::text || ',' ||
		quote_literal(new_type) || ')';
	RAISE DEBUG '%', sql;
	EXECUTE sql;


	-- Add table CHECKs
	sql := 'ALTER TABLE ' ||
		quote_ident(real_schema) || '.' || quote_ident(table_name)
		|| ' ADD CONSTRAINT '
		|| quote_ident('enforce_srid_' || column_name)
		|| ' CHECK (ST_SRID(' || quote_ident(column_name) ||
		') = ' || new_srid::text || ')' ;
	RAISE DEBUG '%', sql;
	EXECUTE sql;

	sql := 'ALTER TABLE ' ||
		quote_ident(real_schema) || '.' || quote_ident(table_name)
		|| ' ADD CONSTRAINT '
		|| quote_ident('enforce_dims_' || column_name)
		|| ' CHECK (ST_NDims(' || quote_ident(column_name) ||
		') = ' || new_dim::text || ')' ;
	RAISE DEBUG '%', sql;
	EXECUTE sql;

	IF ( NOT (new_type = 'GEOMETRY')) THEN
		sql := 'ALTER TABLE ' ||
			quote_ident(real_schema) || '.' || quote_ident(table_name) || ' ADD CONSTRAINT ' ||
			quote_ident('enforce_geotype_' || column_name) ||
			' CHECK (GeometryType(' ||
			quote_ident(column_name) || ')=' ||
			quote_literal(new_type) || ' OR (' ||
			quote_ident(column_name) || ') is null)';
		RAISE DEBUG '%', sql;
		EXECUTE sql;
	END IF;

	RETURN
		real_schema || '.' ||
		table_name || '.' || column_name ||
		' SRID:' || new_srid::text ||
		' TYPE:' || new_type ||
		' DIMS:' || new_dim::text || ' ';
END;
$_$;


ALTER FUNCTION public.addgeometrycolumn(character varying, character varying, character varying, character varying, integer, character varying, integer) OWNER TO postgres;
CREATE FUNCTION fix_geometry_columns() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
	mislinked record;
	result text;
	linked integer;
	deleted integer;
	foundschema integer;
BEGIN

	-- Since 7.3 schema support has been added.
	-- Previous postgis versions used to put the database name in
	-- the schema column. This needs to be fixed, so we try to
	-- set the correct schema for each geometry_colums record
	-- looking at table, column, type and srid.
	UPDATE geometry_columns SET f_table_schema = n.nspname
		FROM pg_namespace n, pg_class c, pg_attribute a,
			pg_constraint sridcheck, pg_constraint typecheck
			WHERE ( f_table_schema is NULL
		OR f_table_schema = ''
			OR f_table_schema NOT IN (
					SELECT nspname::text
					FROM pg_namespace nn, pg_class cc, pg_attribute aa
					WHERE cc.relnamespace = nn.oid
					AND cc.relname = f_table_name::name
					AND aa.attrelid = cc.oid
					AND aa.attname = f_geometry_column::name))
			AND f_table_name::name = c.relname
			AND c.oid = a.attrelid
			AND c.relnamespace = n.oid
			AND f_geometry_column::name = a.attname

			AND sridcheck.conrelid = c.oid
		AND sridcheck.consrc LIKE '(srid(% = %)'
			AND sridcheck.consrc ~ textcat(' = ', srid::text)

			AND typecheck.conrelid = c.oid
		AND typecheck.consrc LIKE
		'((geometrytype(%) = ''%''::text) OR (% IS NULL))'
			AND typecheck.consrc ~ textcat(' = ''', type::text)

			AND NOT EXISTS (
					SELECT oid FROM geometry_columns gc
					WHERE c.relname::text = gc.f_table_name
					AND n.nspname::text = gc.f_table_schema
					AND a.attname::text = gc.f_geometry_column
			);

	GET DIAGNOSTICS foundschema = ROW_COUNT;

	-- no linkage to system table needed
	return 'fixed:'||foundschema::text;

END;
$$;

ALTER FUNCTION public.fix_geometry_columns() OWNER TO postgres;


CREATE TABLE spatial_ref_sys_old (
    srid integer NOT NULL,
    auth_name character varying(256),
    auth_srid integer,
    srtext character varying(2048),
    proj4text character varying(2048)
);


ALTER TABLE spatial_ref_sys_old OWNER TO postgres;


}}}
vu, fonction:{{{
--
-- Name: generate_cross_sections_array(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION generate_cross_sections_array() RETURNS trigger
    LANGUAGE plpythonu
    AS $$
#{{{
#{{{
# Cette fonction est appele depuis un TRIGGER de la 
# table sections_definition, sans arguments, et elle 
# renvoie un trigger.
# dfinition du TRIGGER:
#    CREATE TRIGGER sections_definition_change 
#    AFTER INSERT OR UPDATE ON sections_definition 
#    FOR EACH ROW 
#    EXECUTE PROCEDURE generate_cross_sections_array();
#
# @#faire le pendant, qui dtruise les enregistrements de sections_array quand on supprime un enregistrement de sections_definition
#}}}
from math import sin, cos, pi
import string

sep       = "," #"\t"      #dfinition du sparateur: la virgule 
sepchar   = "\'"           #dfinition du sparateur de chane de caractres: le ', en SQL

#Cherchons les paramtres dfinissant les coupes, dans la table sections_definition:
res = plpy.execute("SELECT opid, id, location, srid, ll_corner_x, ll_corner_y, ll_corner_z, azim_ng, interval, num_start, count, length, title FROM sections_definition 
--WHERE opid IN (SELECT opid FROM operation_active)
;")

sql_insert = ""               #on btit une chane sql_insert qui contiendra tout ce qu'il faudra faire, des insertions essentiellement

#on enlve d'abord les coupes existantes dans la table sections_array{{{
sql_insert += "DELETE FROM sections_array WHERE sections_array.opid IN (SELECT opid FROM operation_active) AND sections_array.id IS NOT NULL; "
#non: plutt, on enlve seulement les coupes existantes pour le mme id que celui qui vient d'tre affect:
#sql_insert +="DELETE FROM sections_array WHERE substr(sections_array.title, 1, " + str(NEW["title"].len) + ") = " + sepchar + NEW["title"] + sepchar + ";"
# => marche pas:
#  ERREUR:  PL/python : NameError: global name 'NEW' is not defined
#  CONTEXTE : fonction PL/ generate_cross_sections_array Python 
# =>@#reprendre
#}}}

i = 0
for line in res:
    #le rsultat est fourni sous forme de tuples de dictionnaires:
    opid              = line["opid"]
    id                = line["id"]
    srid              = line["srid"]
    location          = line["location"]
    ll_corner_x       = line["ll_corner_x"]
    ll_corner_y       = line["ll_corner_y"]
    ll_corner_z       = line["ll_corner_z"]
    azim_ng           = line["azim_ng"]
    interval_         = line["interval"]
    num_start         = line["num_start"]
    count             = line["count"]
    length            = line["length"]
    title             = line["title"]
    #num   = 1                                   #pas besoin, on a mis un autoincrment dans la table 
    indice_coupe = num_start                     #l'indice de la coupe 
    sql_insert += "INSERT INTO sections_array (opid, location, id, title, srid, length, x1, y1, z1, x2, y2, z2) VALUES \n"
    for j in range(count):
        #out =  str(opid) + sep + sepchar + location + sepchar + sep + sepchar + location+'_'+str(indice_coupe).zfill(3) + sepchar + sep + sepchar + title + " - section # "+str(indice_coupe)                       + sepchar + sep + str(srid) + sep
        out  =  str(opid) + sep + sepchar + location + sepchar + sep + sepchar + location+'_'+str(indice_coupe).zfill(3) + sepchar + sep + sepchar + title + " - section " + location+'_'+str(indice_coupe).zfill(3) + sepchar + sep + str(srid) + sep
        x2 = ll_corner_x+interval_*(j) * cos((90.0-azim_ng)/180*pi)
        y2 = ll_corner_y+interval_*(j) * sin((90.0-azim_ng)/180*pi)
        x1 = x2 - length * sin((90.0-azim_ng)/180*pi)
        y1 = y2 + length * cos((90.0-azim_ng)/180*pi)
        z  = ll_corner_z
        out += str(length) + sep + str(x1) + sep + str(y1) + sep + str(z) + sep + str(x2) + sep + str(y2) + sep + str(z)
        sql_insert += "("+out+"),\n"
        indice_coupe += 1
    sql_insert = sql_insert[0:len(sql_insert)-2]  #pour enlever le dernier ",\n"
    sql_insert += ";\n"
    i += 1

# au lieu de retourner la chaine (comme dans le scr
res = plpy.execute(sql_insert)
return 'OK'
#}}}
$$;


ALTER FUNCTION public.generate_cross_sections_array() OWNER TO postgres;
CREATE FUNCTION lab_ana_results_sample_id_default_value_num() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
--UPDATE public.lab_ana_results SET sample_id = lab_sampleid WHERE (sample_id IS NULL OR sample_id = '') AND (lab_sampleid IS NOT NULL OR lab_sampleid <> '');
UPDATE public.lab_ana_results SET sample_id_lab = sample_id;
UPDATE public.lab_ana_results SET sample_id = REPLACE(sample_id, 'STD:', '') WHERE sample_id ILIKE 'STD%';

UPDATE public.lab_ana_results SET value_num = 
REPLACE(
REPLACE(
REPLACE(
REPLACE(
REPLACE(
REPLACE(
REPLACE(
REPLACE(value,     'IS',           '-999'), 
                  'NSS',           '-999'), 
                  'LNR',          '-9999'), 
                   'NA',            '-99'), 
                    '<',              '-'),
                    '>',               ''),
                 'Not Received',  '-9999'),
                 'Bag Empty',     '-9999')::numeric WHERE value <> 'NULL' AND value IS NOT NULL AND value_num IS NULL;
RETURN NULL;
END;
$$;


ALTER FUNCTION public.lab_ana_results_sample_id_default_value_num() OWNER TO pierre;
}}}
vu, du postgis:{{{
--
-- Name: populate_geometry_columns(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION populate_geometry_columns() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
	inserted    integer;
	oldcount    integer;
	probed      integer;
	stale       integer;
	gcs         RECORD;
	gc          RECORD;
	gsrid       integer;
	gndims      integer;
	gtype       text;
	query       text;
	gc_is_valid boolean;

BEGIN
	SELECT count(*) INTO oldcount FROM geometry_columns;
	inserted := 0;

	EXECUTE 'TRUNCATE geometry_columns';

	-- Count the number of geometry columns in all tables and views
	SELECT count(DISTINCT c.oid) INTO probed
	FROM pg_class c,
		 pg_attribute a,
		 pg_type t,
		 pg_namespace n
	WHERE (c.relkind = 'r' OR c.relkind = 'v')
	AND t.typname = 'geometry'
	AND a.attisdropped = false
	AND a.atttypid = t.oid
	AND a.attrelid = c.oid
	AND c.relnamespace = n.oid
	AND n.nspname NOT ILIKE 'pg_temp%';

	-- Iterate through all non-dropped geometry columns
	RAISE DEBUG 'Processing Tables.....';

	FOR gcs IN
	SELECT DISTINCT ON (c.oid) c.oid, n.nspname, c.relname
		FROM pg_class c,
			 pg_attribute a,
			 pg_type t,
			 pg_namespace n
		WHERE c.relkind = 'r'
		AND t.typname = 'geometry'
		AND a.attisdropped = false
		AND a.atttypid = t.oid
		AND a.attrelid = c.oid
		AND c.relnamespace = n.oid
		AND n.nspname NOT ILIKE 'pg_temp%'
	LOOP

	inserted := inserted + populate_geometry_columns(gcs.oid);
	END LOOP;

	-- Add views to geometry columns table
	RAISE DEBUG 'Processing Views.....';
	FOR gcs IN
	SELECT DISTINCT ON (c.oid) c.oid, n.nspname, c.relname
		FROM pg_class c,
			 pg_attribute a,
			 pg_type t,
			 pg_namespace n
		WHERE c.relkind = 'v'
		AND t.typname = 'geometry'
		AND a.attisdropped = false
		AND a.atttypid = t.oid
		AND a.attrelid = c.oid
		AND c.relnamespace = n.oid
	LOOP

	inserted := inserted + populate_geometry_columns(gcs.oid);
	END LOOP;

	IF oldcount > inserted THEN
	stale = oldcount-inserted;
	ELSE
	stale = 0;
	END IF;

	RETURN 'probed:' ||probed|| ' inserted:'||inserted|| ' conflicts:'||probed-inserted|| ' deleted:'||stale;
END

$$;


ALTER FUNCTION public.populate_geometry_columns() OWNER TO postgres;
CREATE FUNCTION populate_geometry_columns(tbl_oid oid) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
	gcs         RECORD;
	gc          RECORD;
	gsrid       integer;
	gndims      integer;
	gtype       text;
	query       text;
	gc_is_valid boolean;
	inserted    integer;

BEGIN
	inserted := 0;

	-- Iterate through all geometry columns in this table
	FOR gcs IN
	SELECT n.nspname, c.relname, a.attname
		FROM pg_class c,
			 pg_attribute a,
			 pg_type t,
			 pg_namespace n
		WHERE c.relkind = 'r'
		AND t.typname = 'geometry'
		AND a.attisdropped = false
		AND a.atttypid = t.oid
		AND a.attrelid = c.oid
		AND c.relnamespace = n.oid
		AND n.nspname NOT ILIKE 'pg_temp%'
		AND c.oid = tbl_oid
	LOOP

	RAISE DEBUG 'Processing table %.%.%', gcs.nspname, gcs.relname, gcs.attname;

	DELETE FROM geometry_columns
	  WHERE f_table_schema = quote_ident(gcs.nspname)
	  AND f_table_name = quote_ident(gcs.relname)
	  AND f_geometry_column = quote_ident(gcs.attname);

	gc_is_valid := true;

	-- Try to find srid check from system tables (pg_constraint)
	gsrid :=
		(SELECT replace(replace(split_part(s.consrc, ' = ', 2), ')', ''), '(', '')
		 FROM pg_class c, pg_namespace n, pg_attribute a, pg_constraint s
		 WHERE n.nspname = gcs.nspname
		 AND c.relname = gcs.relname
		 AND a.attname = gcs.attname
		 AND a.attrelid = c.oid
		 AND s.connamespace = n.oid
		 AND s.conrelid = c.oid
		 AND a.attnum = ANY (s.conkey)
		 AND s.consrc LIKE '%srid(% = %');
	IF (gsrid IS NULL) THEN
		-- Try to find srid from the geometry itself
		EXECUTE 'SELECT srid(' || quote_ident(gcs.attname) || ')
				 FROM ONLY ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) || '
				 WHERE ' || quote_ident(gcs.attname) || ' IS NOT NULL LIMIT 1'
			INTO gc;
		gsrid := gc.srid;

		-- Try to apply srid check to column
		IF (gsrid IS NOT NULL) THEN
			BEGIN
				EXECUTE 'ALTER TABLE ONLY ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) || '
						 ADD CONSTRAINT ' || quote_ident('enforce_srid_' || gcs.attname) || '
						 CHECK (srid(' || quote_ident(gcs.attname) || ') = ' || gsrid || ')';
			EXCEPTION
				WHEN check_violation THEN
					RAISE WARNING 'Not inserting ''%'' in ''%.%'' into geometry_columns: could not apply constraint CHECK (srid(%) = %)', quote_ident(gcs.attname), quote_ident(gcs.nspname), quote_ident(gcs.relname), quote_ident(gcs.attname), gsrid;
					gc_is_valid := false;
			END;
		END IF;
	END IF;

	-- Try to find ndims check from system tables (pg_constraint)
	gndims :=
		(SELECT replace(split_part(s.consrc, ' = ', 2), ')', '')
		 FROM pg_class c, pg_namespace n, pg_attribute a, pg_constraint s
		 WHERE n.nspname = gcs.nspname
		 AND c.relname = gcs.relname
		 AND a.attname = gcs.attname
		 AND a.attrelid = c.oid
		 AND s.connamespace = n.oid
		 AND s.conrelid = c.oid
		 AND a.attnum = ANY (s.conkey)
		 AND s.consrc LIKE '%ndims(% = %');
	IF (gndims IS NULL) THEN
		-- Try to find ndims from the geometry itself
		EXECUTE 'SELECT ndims(' || quote_ident(gcs.attname) || ')
				 FROM ONLY ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) || '
				 WHERE ' || quote_ident(gcs.attname) || ' IS NOT NULL LIMIT 1'
			INTO gc;
		gndims := gc.ndims;

		-- Try to apply ndims check to column
		IF (gndims IS NOT NULL) THEN
			BEGIN
				EXECUTE 'ALTER TABLE ONLY ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) || '
						 ADD CONSTRAINT ' || quote_ident('enforce_dims_' || gcs.attname) || '
						 CHECK (ndims(' || quote_ident(gcs.attname) || ') = '||gndims||')';
			EXCEPTION
				WHEN check_violation THEN
					RAISE WARNING 'Not inserting ''%'' in ''%.%'' into geometry_columns: could not apply constraint CHECK (ndims(%) = %)', quote_ident(gcs.attname), quote_ident(gcs.nspname), quote_ident(gcs.relname), quote_ident(gcs.attname), gndims;
					gc_is_valid := false;
			END;
		END IF;
	END IF;

	-- Try to find geotype check from system tables (pg_constraint)
	gtype :=
		(SELECT replace(split_part(s.consrc, '''', 2), ')', '')
		 FROM pg_class c, pg_namespace n, pg_attribute a, pg_constraint s
		 WHERE n.nspname = gcs.nspname
		 AND c.relname = gcs.relname
		 AND a.attname = gcs.attname
		 AND a.attrelid = c.oid
		 AND s.connamespace = n.oid
		 AND s.conrelid = c.oid
		 AND a.attnum = ANY (s.conkey)
		 AND s.consrc LIKE '%geometrytype(% = %');
	IF (gtype IS NULL) THEN
		-- Try to find geotype from the geometry itself
		EXECUTE 'SELECT geometrytype(' || quote_ident(gcs.attname) || ')
				 FROM ONLY ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) || '
				 WHERE ' || quote_ident(gcs.attname) || ' IS NOT NULL LIMIT 1'
			INTO gc;
		gtype := gc.geometrytype;
		--IF (gtype IS NULL) THEN
		--    gtype := 'GEOMETRY';
		--END IF;

		-- Try to apply geometrytype check to column
		IF (gtype IS NOT NULL) THEN
			BEGIN
				EXECUTE 'ALTER TABLE ONLY ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) || '
				ADD CONSTRAINT ' || quote_ident('enforce_geotype_' || gcs.attname) || '
				CHECK ((geometrytype(' || quote_ident(gcs.attname) || ') = ' || quote_literal(gtype) || ') OR (' || quote_ident(gcs.attname) || ' IS NULL))';
			EXCEPTION
				WHEN check_violation THEN
					-- No geometry check can be applied. This column contains a number of geometry types.
					RAISE WARNING 'Could not add geometry type check (%) to table column: %.%.%', gtype, quote_ident(gcs.nspname),quote_ident(gcs.relname),quote_ident(gcs.attname);
			END;
		END IF;
	END IF;

	IF (gsrid IS NULL) THEN
		RAISE WARNING 'Not inserting ''%'' in ''%.%'' into geometry_columns: could not determine the srid', quote_ident(gcs.attname), quote_ident(gcs.nspname), quote_ident(gcs.relname);
	ELSIF (gndims IS NULL) THEN
		RAISE WARNING 'Not inserting ''%'' in ''%.%'' into geometry_columns: could not determine the number of dimensions', quote_ident(gcs.attname), quote_ident(gcs.nspname), quote_ident(gcs.relname);
	ELSIF (gtype IS NULL) THEN
		RAISE WARNING 'Not inserting ''%'' in ''%.%'' into geometry_columns: could not determine the geometry type', quote_ident(gcs.attname), quote_ident(gcs.nspname), quote_ident(gcs.relname);
	ELSE
		-- Only insert into geometry_columns if table constraints could be applied.
		IF (gc_is_valid) THEN
			INSERT INTO geometry_columns (f_table_catalog,f_table_schema, f_table_name, f_geometry_column, coord_dimension, srid, type)
			VALUES ('', gcs.nspname, gcs.relname, gcs.attname, gndims, gsrid, gtype);
			inserted := inserted + 1;
		END IF;
	END IF;
	END LOOP;

	-- Add views to geometry columns table
	FOR gcs IN
	SELECT n.nspname, c.relname, a.attname
		FROM pg_class c,
			 pg_attribute a,
			 pg_type t,
			 pg_namespace n
		WHERE c.relkind = 'v'
		AND t.typname = 'geometry'
		AND a.attisdropped = false
		AND a.atttypid = t.oid
		AND a.attrelid = c.oid
		AND c.relnamespace = n.oid
		AND n.nspname NOT ILIKE 'pg_temp%'
		AND c.oid = tbl_oid
	LOOP
		RAISE DEBUG 'Processing view %.%.%', gcs.nspname, gcs.relname, gcs.attname;

		EXECUTE 'SELECT ndims(' || quote_ident(gcs.attname) || ')
				 FROM ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) || '
				 WHERE ' || quote_ident(gcs.attname) || ' IS NOT NULL LIMIT 1'
			INTO gc;
		gndims := gc.ndims;

		EXECUTE 'SELECT srid(' || quote_ident(gcs.attname) || ')
				 FROM ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) || '
				 WHERE ' || quote_ident(gcs.attname) || ' IS NOT NULL LIMIT 1'
			INTO gc;
		gsrid := gc.srid;

		EXECUTE 'SELECT geometrytype(' || quote_ident(gcs.attname) || ')
				 FROM ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) || '
				 WHERE ' || quote_ident(gcs.attname) || ' IS NOT NULL LIMIT 1'
			INTO gc;
		gtype := gc.geometrytype;

		IF (gndims IS NULL) THEN
			RAISE WARNING 'Not inserting ''%'' in ''%.%'' into geometry_columns: could not determine ndims', quote_ident(gcs.attname), quote_ident(gcs.nspname), quote_ident(gcs.relname);
		ELSIF (gsrid IS NULL) THEN
			RAISE WARNING 'Not inserting ''%'' in ''%.%'' into geometry_columns: could not determine srid', quote_ident(gcs.attname), quote_ident(gcs.nspname), quote_ident(gcs.relname);
		ELSIF (gtype IS NULL) THEN
			RAISE WARNING 'Not inserting ''%'' in ''%.%'' into geometry_columns: could not determine gtype', quote_ident(gcs.attname), quote_ident(gcs.nspname), quote_ident(gcs.relname);
		ELSE
			query := 'INSERT INTO geometry_columns (f_table_catalog,f_table_schema, f_table_name, f_geometry_column, coord_dimension, srid, type) ' ||
					 'VALUES ('''', ' || quote_literal(gcs.nspname) || ',' || quote_literal(gcs.relname) || ',' || quote_literal(gcs.attname) || ',' || gndims || ',' || gsrid || ',' || quote_literal(gtype) || ')';
			EXECUTE query;
			inserted := inserted + 1;
		END IF;
	END LOOP;

	RETURN inserted;
END

$$;


ALTER FUNCTION public.populate_geometry_columns(tbl_oid oid) OWNER TO postgres;
CREATE FUNCTION probe_geometry_columns() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
	inserted integer;
	oldcount integer;
	probed integer;
	stale integer;
BEGIN

	SELECT count(*) INTO oldcount FROM geometry_columns;

	SELECT count(*) INTO probed
		FROM pg_class c, pg_attribute a, pg_type t,
			pg_namespace n,
			pg_constraint sridcheck, pg_constraint typecheck

		WHERE t.typname = 'geometry'
		AND a.atttypid = t.oid
		AND a.attrelid = c.oid
		AND c.relnamespace = n.oid
		AND sridcheck.connamespace = n.oid
		AND typecheck.connamespace = n.oid
		AND sridcheck.conrelid = c.oid
		AND sridcheck.consrc LIKE '(srid('||a.attname||') = %)'
		AND typecheck.conrelid = c.oid
		AND typecheck.consrc LIKE
		'((geometrytype('||a.attname||') = ''%''::text) OR (% IS NULL))'
		;

	INSERT INTO geometry_columns SELECT
		''::text as f_table_catalogue,
		n.nspname::text as f_table_schema,
		c.relname::text as f_table_name,
		a.attname::text as f_geometry_column,
		2 as coord_dimension,
		trim(both  ' =)' from
			replace(replace(split_part(
				sridcheck.consrc, ' = ', 2), ')', ''), '(', ''))::integer AS srid,
		trim(both ' =)''' from substr(typecheck.consrc,
			strpos(typecheck.consrc, '='),
			strpos(typecheck.consrc, '::')-
			strpos(typecheck.consrc, '=')
			))::text as type
		FROM pg_class c, pg_attribute a, pg_type t,
			pg_namespace n,
			pg_constraint sridcheck, pg_constraint typecheck
		WHERE t.typname = 'geometry'
		AND a.atttypid = t.oid
		AND a.attrelid = c.oid
		AND c.relnamespace = n.oid
		AND sridcheck.connamespace = n.oid
		AND typecheck.connamespace = n.oid
		AND sridcheck.conrelid = c.oid
		AND sridcheck.consrc LIKE '(st_srid('||a.attname||') = %)'
		AND typecheck.conrelid = c.oid
		AND typecheck.consrc LIKE
		'((geometrytype('||a.attname||') = ''%''::text) OR (% IS NULL))'

			AND NOT EXISTS (
					SELECT oid FROM geometry_columns gc
					WHERE c.relname::text = gc.f_table_name
					AND n.nspname::text = gc.f_table_schema
					AND a.attname::text = gc.f_geometry_column
			);

	GET DIAGNOSTICS inserted = ROW_COUNT;

	if OLDCOUNT > PROBED theN
		stale = oldcount-probed;
	ELSE
		stale = 0;
	END IF;

	RETURN 'probed:'||probed::text||
		' inserted:'||inserted::text||
		' conflicts:'||(probed-inserted)::text||
		' stale:'||stale::text;
END

$$;


ALTER FUNCTION public.probe_geometry_columns() OWNER TO postgres;
CREATE FUNCTION rename_geometry_table_constraints() RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
SELECT 'rename_geometry_table_constraint() is obsoleted'::text
$$;


ALTER FUNCTION public.rename_geometry_table_constraints() OWNER TO postgres;
CREATE FUNCTION st_asbinary(text) RETURNS bytea
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$ SELECT ST_AsBinary($1::geometry);  $_$;


ALTER FUNCTION public.st_asbinary(text) OWNER TO postgres;

SET search_path = backups, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;
}}}

TABLES VUES:{{{
SET search_path = public, pg_catalog;

CREATE TABLE public.dh_collars (
    id text NOT NULL,
    shid text,
    location text,
    profile text,
    srid integer,
    x numeric(12,3),
    y numeric(12,3),
    z numeric(12,3),
    azim_ng numeric(10,2),
    azim_nm numeric(10,2),
    dip_hz numeric(10,2),
    dh_type text,
    date_start date,
    contractor text,
    geologist text,
    length numeric(10,2),
    nb_samples integer,
    comments text,
    completed boolean DEFAULT false,
    numauto integer NOT NULL,
    date_completed date,
    opid integer NOT NULL,
    purpose text DEFAULT 'EXPLO'::text,
    x_local numeric(12,3),
    y_local numeric(12,3),
    z_local numeric(12,3),
    accusum numeric(10,2),
    id_pject text,
    x_pject numeric(10,3),
    y_pject numeric(10,3),
    z_pject numeric(10,3),
    topo_survey_type text,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"(),
    datasource integer,
    campaign text
);
ALTER TABLE dh_collars OWNER TO data_admin;
COMMENT ON TABLE dh_collars IS 'Drill holes collars or trenches starting points';
COMMENT ON COLUMN dh_collars.id IS 'Full identifier for borehole or trench, may include zone code, type and sequential number';
COMMENT ON COLUMN dh_collars.shid IS 'Short identifier: type _ sequential number';
COMMENT ON COLUMN dh_collars.location IS 'Investigated area code, refers to occurrences table';
COMMENT ON COLUMN dh_collars.profile IS 'Profile number';
COMMENT ON COLUMN dh_collars.srid IS 'Spatial Reference Identifier, or coordinate reference system: see spatial_ref_sys from postgis extension';
COMMENT ON COLUMN dh_collars.x IS 'X coordinate (Easting),  in coordinate system srid';
COMMENT ON COLUMN dh_collars.y IS 'Y coordinate (Northing), in coordinate system srid';
COMMENT ON COLUMN dh_collars.azim_ng IS 'Hole or trench azimuth (°) relative to geographic North';
COMMENT ON COLUMN dh_collars.azim_nm IS 'Hole or trench azimuth (°) relative to Magnetic North';
COMMENT ON COLUMN dh_collars.dip_hz IS 'Drill hole or trench dip relative to horizontal (°)';
COMMENT ON COLUMN dh_collars.dh_type IS 'Type: D for Diamond drill hole, R for RC drill hole, T for Trench, A for Auger drill hole';
COMMENT ON COLUMN dh_collars.date_start IS 'Work start date';
COMMENT ON COLUMN dh_collars.contractor IS 'Drilling contractor';
COMMENT ON COLUMN dh_collars.geologist IS 'Geologist name';
COMMENT ON COLUMN dh_collars.length IS 'Total length (m)';
COMMENT ON COLUMN dh_collars.nb_samples IS 'Number of samples';
COMMENT ON COLUMN dh_collars.comments IS 'Comments';
COMMENT ON COLUMN dh_collars.completed IS 'True: completed; False: planned';
COMMENT ON COLUMN dh_collars.numauto IS 'Automatic integer primary key';
COMMENT ON COLUMN dh_collars.date_completed IS 'Work finish date';
COMMENT ON COLUMN dh_collars.opid IS 'Operation identifier';
COMMENT ON COLUMN dh_collars.purpose IS 'Purpose of hole: exploration, delineation, estimation, grade control, etc.';
COMMENT ON COLUMN dh_collars.x_local IS 'Local x coordinate';
COMMENT ON COLUMN dh_collars.y_local IS 'Local y coordinate';
COMMENT ON COLUMN dh_collars.z_local IS 'Local z coordinate';
COMMENT ON COLUMN dh_collars.accusum IS 'Accumulation sum over various mineralised intervals intersected by drill hole or trench (purpose: quick visualisation on maps (at wide scale ONLY), quick ranking of interesting holes)';
COMMENT ON COLUMN dh_collars.id_pject IS 'PJ for ProJect identifier: provisional identifier; aka peg number';
COMMENT ON COLUMN dh_collars.x_pject IS 'Planned x coordinate';
COMMENT ON COLUMN dh_collars.y_pject IS 'Planned y coordinate';
COMMENT ON COLUMN dh_collars.z_pject IS 'Planned z coordinate';
COMMENT ON COLUMN dh_collars.topo_survey_type IS 'Topographic collar survey type: GPS, GPSD, geometry, theodolite, relative, computed from local coordinate system, etc.';
COMMENT ON COLUMN dh_collars.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_collars.username IS 'User (role) which created data record';
COMMENT ON COLUMN dh_collars.datasource IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN dh_collars.campaign IS 'Campaign: year, type, etc. i.e. DDH exploration 1967';


CREATE TABLE operation_active (
    opid integer,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"(),
    numauto integer NOT NULL
);
ALTER TABLE operation_active OWNER TO data_admin;
COMMENT ON COLUMN operation_active.opid IS 'Operation identifier';
COMMENT ON COLUMN operation_active.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN operation_active.username IS 'User (role) which created data record';
COMMENT ON COLUMN operation_active.numauto IS 'Automatic integer';


SET search_path = public, pg_catalog;

CREATE TABLE dh_litho (
    id text,
    depfrom numeric(10,2),
    depto numeric(10,2),
    description text,
    code1 text,
    code2 text,
    code3 text,
    code4 text,
    value1 integer,
    value2 integer,
    value3 integer,
    value4 integer,
    opid integer,
    colour text,
    numauto integer NOT NULL,
    datasource integer,
    description1 text,
    description2 text,
    value5 integer,
    value6 integer,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"()
);
COMMENT ON TABLE dh_litho IS 'Drill holes or trenches geological descriptions';
COMMENT ON COLUMN dh_litho.id IS 'Identifier, refers to dh_collars';
COMMENT ON COLUMN dh_litho.depfrom IS 'Interval beginning depth';
COMMENT ON COLUMN dh_litho.depto IS 'Interval ending depth';
COMMENT ON COLUMN dh_litho.description IS 'Geological description, naturalist style';
COMMENT ON COLUMN dh_litho.code1 IS 'Conventional use is lithology code, 4 characters, uppercase. Refer to lex_codes table';
COMMENT ON COLUMN dh_litho.code2 IS 'Conventional use is supergene oxidation, 1 character, uppercase. Refer to lex_codes table';
COMMENT ON COLUMN dh_litho.code3 IS 'Conventional use is stratigraphy code, 4 characters, uppercase. Refer to lex_codes table';
COMMENT ON COLUMN dh_litho.code4 IS '4 characters code. Refer to lex_codes table';
COMMENT ON COLUMN dh_litho.value1 IS 'Integer value. Refer to lex_codes table';
COMMENT ON COLUMN dh_litho.value2 IS 'Integer value. Refer to lex_codes table';
COMMENT ON COLUMN dh_litho.value3 IS 'Integer value. Refer to lex_codes table';
COMMENT ON COLUMN dh_litho.value4 IS 'Integer value. Refer to lex_codes table';
COMMENT ON COLUMN dh_litho.opid IS 'Operation identifier';
COMMENT ON COLUMN dh_litho.numauto IS 'Automatic integer primary key';
COMMENT ON COLUMN dh_litho.datasource IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN dh_litho.description1 IS 'Complement to main geological description: metallic minerals';
COMMENT ON COLUMN dh_litho.description2 IS 'Complement to main geological description: alterations';
COMMENT ON COLUMN dh_litho.value5 IS 'Integer value. Refer to lex_codes table';
COMMENT ON COLUMN dh_litho.value6 IS 'Integer value. Refer to lex_codes table';
COMMENT ON COLUMN dh_litho.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_litho.username IS 'User (role) which created data record';

ALTER TABLE dh_litho OWNER TO data_admin;


SET search_path = public, pg_catalog;
CREATE TABLE dh_sampling_grades (
    id text,
    depfrom numeric(10,2),
    depto numeric(10,2),
    core_loss_cm numeric(5,1),
    weight_kg numeric(6,2),
    sample_type text,
    sample_id text,
    comments text,
    opid integer,
    batch_id integer,
    datasource integer,
    au1_ppm numeric(8,3),
    au2_ppm numeric(8,3),
    au3_ppm numeric(8,3),
    au4_ppm numeric(8,3),
    au5_ppm numeric(8,3),
    au6_ppm numeric(8,3),
    ph numeric(4,2),
    moisture numeric(8,4),
    numauto integer NOT NULL,
    au_specks integer,
    quartering integer,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"()
);
COMMENT ON TABLE dh_sampling_grades IS 'Samples along drill holes and trenches, with grades';
COMMENT ON COLUMN dh_sampling_grades.id IS 'Identifier, refers to dh_collars';
COMMENT ON COLUMN dh_sampling_grades.depfrom IS 'Sample beginning depth';
COMMENT ON COLUMN dh_sampling_grades.depto IS 'Sample ending depth';
COMMENT ON COLUMN dh_sampling_grades.core_loss_cm IS 'Cumulated core loss over sampled interval, in cm';
COMMENT ON COLUMN dh_sampling_grades.weight_kg IS 'Sample weight kg';
COMMENT ON COLUMN dh_sampling_grades.sample_type IS 'Sample type: DD: core sample (diamond drill), RC: percussion drilling Reverse Circulation sample, NS: not sampled, CS: channel sample';
COMMENT ON COLUMN dh_sampling_grades.sample_id IS 'Sample identifier: refers to assay results and quality check tables';
COMMENT ON COLUMN dh_sampling_grades.comments IS 'Free comments, if any';
COMMENT ON COLUMN dh_sampling_grades.opid IS 'Operation identifier';
COMMENT ON COLUMN dh_sampling_grades.batch_id IS 'Batch identifier: refers to batch submission table: lab_ana_batches_expedition';
COMMENT ON COLUMN dh_sampling_grades.datasource IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN dh_sampling_grades.au1_ppm IS 'Au grade 1; cf. usage definition in lex_codes for opid';
COMMENT ON COLUMN dh_sampling_grades.au2_ppm IS 'Au grade 2; cf. usage definition in lex_codes for opid';
COMMENT ON COLUMN dh_sampling_grades.au3_ppm IS 'Au grade 3; cf. usage definition in lex_codes for opid';
COMMENT ON COLUMN dh_sampling_grades.au4_ppm IS 'Au grade 4; cf. usage definition in lex_codes for opid';
COMMENT ON COLUMN dh_sampling_grades.au5_ppm IS 'Au grade 5; cf. usage definition in lex_codes for opid';
COMMENT ON COLUMN dh_sampling_grades.au6_ppm IS 'Au grade 6; cf. usage definition in lex_codes for opid';
COMMENT ON COLUMN dh_sampling_grades.ph IS 'pH measurement (for acidic ores)';
COMMENT ON COLUMN dh_sampling_grades.moisture IS 'Moisture content (for percussion drilling samples mainly)';
COMMENT ON COLUMN dh_sampling_grades.numauto IS 'Automatic integer primary key';
COMMENT ON COLUMN dh_sampling_grades.au_specks IS 'Number of gold specks seen in drill hole or trench; typically, after panning destructive drilling chips, also gold specks seen in core drilling';
COMMENT ON COLUMN dh_sampling_grades.quartering IS 'Sample quartering, if any (for percussion drilling samples split on site, mainly)';
COMMENT ON COLUMN dh_sampling_grades.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_sampling_grades.username IS 'User (role) which created data record';

ALTER TABLE dh_sampling_grades OWNER TO data_admin;


SET search_path = public, pg_catalog;
CREATE TABLE topo_points (
    location text,
    num numeric(10,0),
    x numeric(10,3),
    y numeric(10,3),
    z numeric(10,3),
    numauto integer NOT NULL,
    id text,
    datasource integer,
    opid integer,
    survey_date date,
    topo_survey_type text,
    coordsys text,
    surveyor text,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"()
);
COMMENT ON TABLE topo_points IS 'topographical data';
COMMENT ON COLUMN topo_points.location IS 'Topographical zone';
COMMENT ON COLUMN topo_points.num IS 'Topographical point number';
COMMENT ON COLUMN topo_points.x IS 'X coordinate, projected in UTM (m)';
COMMENT ON COLUMN topo_points.y IS 'Y coordinate, projected in UTM (m)';
COMMENT ON COLUMN topo_points.z IS 'Z coordinate, projected in UTM (m)';
COMMENT ON COLUMN topo_points.numauto IS 'Automatic integer primary key';
COMMENT ON COLUMN topo_points.id IS 'Full identifier for borehole or trench, including zone code with type and sequential number';
COMMENT ON COLUMN topo_points.datasource IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN topo_points.opid IS 'Operation identifier';
COMMENT ON COLUMN topo_points.username IS 'User (role) which created data record';

ALTER TABLE topo_points OWNER TO data_admin;



SET search_path = public, pg_catalog;
CREATE TABLE shift_reports (
    opid integer NOT NULL,
    date date,
    shift text,
    no_fichette integer NOT NULL,
    rig text,
    geologist text,
    time_start time without time zone,
    time_end time without time zone,
    id text,
    peg_number text,
    planned_length numeric(10,2),
    tool text,
    drilled_length_during_shift numeric(10,2),
    drilled_length numeric(10,2),
    completed boolean,
    profile text,
    comments text,
    invoice_nr integer,
    drilled_shift_destr numeric,
    drilled_shift_pq numeric,
    drilled_shift_hq numeric,
    drilled_shift_nq numeric,
    recovered_length_shift numeric,
    stdby_time1_h numeric,
    stdby_time2_h numeric,
    stdby_time3_h numeric,
    moving_time_h numeric,
    driller_name text,
    geologist_supervisor text,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"(),
    numauto integer NOT NULL,
    datasource integer
);
ALTER TABLE shift_reports OWNER TO data_admin;
COMMENT ON TABLE shift_reports IS 'Daily reports from rigsites: one report per shift/machine/tool';
COMMENT ON COLUMN shift_reports.opid IS 'Operation identifier';
COMMENT ON COLUMN shift_reports.date IS 'Date of drilling';
COMMENT ON COLUMN shift_reports.shift IS 'Day or night shift';
COMMENT ON COLUMN shift_reports.no_fichette IS 'Number of fichette = field form filled on a shift and borehole basis';
COMMENT ON COLUMN shift_reports.rig IS 'Name/id of drilling (or digging) machine';
COMMENT ON COLUMN shift_reports.geologist IS 'Geologist(s) following the drill hole on the rig site, doing the logging.';
COMMENT ON COLUMN shift_reports.time_start IS 'Drilling starting time';
COMMENT ON COLUMN shift_reports.time_end IS 'Drilling ending time';
COMMENT ON COLUMN shift_reports.id IS 'Drill hole identifier, must match collars.id field, e.g. UMA_R086';
COMMENT ON COLUMN shift_reports.peg_number IS 'Peg number: provisional identifier/number; aka PJ for ProJect identifier';
COMMENT ON COLUMN shift_reports.planned_length IS 'Length of the borehole, as initially planned';
COMMENT ON COLUMN shift_reports.tool IS 'Drilling (digging) tool/size, diameter: RC, RAB, percussion, core, SQ, PQ, HQ, NQ, BQ, AQ, mechanical shovel, hand shovel, banka, etc.';
COMMENT ON COLUMN shift_reports.drilled_length_during_shift IS 'Length of borehole drilled during the shift';
COMMENT ON COLUMN shift_reports.drilled_length IS 'Total length of the borehole drilled at the end of the shift';
COMMENT ON COLUMN shift_reports.completed IS 'Borehole finished or not';
COMMENT ON COLUMN shift_reports.profile IS 'Section identifier';
COMMENT ON COLUMN shift_reports.comments IS 'Comments on drilling (events, presence of water, difficulties, major facies, etc.)';
COMMENT ON COLUMN shift_reports.invoice_nr IS 'Subcontractor invoice number';
COMMENT ON COLUMN shift_reports.drilled_shift_destr IS 'Drilled length during shift in destructive';
COMMENT ON COLUMN shift_reports.drilled_shift_pq IS 'Drilled length during shift in PQ core';
COMMENT ON COLUMN shift_reports.drilled_shift_hq IS 'Drilled length during shift in HQ core';
COMMENT ON COLUMN shift_reports.drilled_shift_nq IS 'Drilled length during shift in NQ core';
COMMENT ON COLUMN shift_reports.recovered_length_shift IS 'Recovered length during shift';
COMMENT ON COLUMN shift_reports.stdby_time1_h IS 'Standby time hours, with machine powered on';
COMMENT ON COLUMN shift_reports.stdby_time2_h IS 'Standby time hours, with machine powered off';
COMMENT ON COLUMN shift_reports.stdby_time3_h IS 'Standby time hours, due to weather conditions';
COMMENT ON COLUMN shift_reports.moving_time_h IS 'Moving time hours';
COMMENT ON COLUMN shift_reports.driller_name IS 'Driller supervisor name';
COMMENT ON COLUMN shift_reports.geologist_supervisor IS 'Geologist supervisor name';
COMMENT ON COLUMN shift_reports.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN shift_reports.username IS 'User (role) which created data record';
COMMENT ON COLUMN shift_reports.numauto IS 'Automatic integer';
COMMENT ON COLUMN shift_reports.datasource IS 'Datasource identifier, refers to lex_datasource';


SET search_path = public, pg_catalog;
CREATE TABLE dh_devia (
    id text,
    depto numeric(10,2),
    azim_nm numeric(10,2),
    dip_hz numeric(10,2),
    temperature numeric(10,2),
    magnetic numeric(10,2),
    date date,
    roll numeric(10,2),
    "time" integer,
    comments text,
    opid integer,
    numauto integer NOT NULL,
    valid boolean DEFAULT true,
    azim_ng numeric(10,2),
    datasource integer,
    device text,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"()
);
ALTER TABLE dh_devia OWNER TO data_admin;
COMMENT ON TABLE dh_devia IS 'Drill holes or trenches deviations measurements';
COMMENT ON COLUMN dh_devia.id IS 'Drill hole identification related to the collars table';
COMMENT ON COLUMN dh_devia.depto IS 'Depth of deviation measurement';
COMMENT ON COLUMN dh_devia.azim_nm IS 'Hole azimuth (°) relative to magnetic North (?)';
COMMENT ON COLUMN dh_devia.dip_hz IS 'Drill hole dip relative to horizontal (°), positive down';
COMMENT ON COLUMN dh_devia.temperature IS 'temperature';
COMMENT ON COLUMN dh_devia.magnetic IS 'Magnetic field intensity measurement';
COMMENT ON COLUMN dh_devia.date IS 'Date of deviation measurement';
COMMENT ON COLUMN dh_devia.roll IS 'Roll angle';
COMMENT ON COLUMN dh_devia."time" IS 'Time of deviation measurement';
COMMENT ON COLUMN dh_devia.comments IS 'Various comments; concerning measurements done with Reflex Gyro, all parameters are concatened as a json-like structure';
COMMENT ON COLUMN dh_devia.opid IS 'Operation identifier';
COMMENT ON COLUMN dh_devia.numauto IS 'Automatic integer primary key';
COMMENT ON COLUMN dh_devia.valid IS 'True when a deviation measurement is usable; queries should take into account only valid records';
COMMENT ON COLUMN dh_devia.azim_ng IS 'Hole azimuth (°) relative to geographic North';
COMMENT ON COLUMN dh_devia.datasource IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN dh_devia.device IS 'Device used for deviation measurement';
COMMENT ON COLUMN dh_devia.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_devia.username IS 'User (role) which created data record';


SET search_path = pierre, pg_catalog;
CREATE TABLE sections_array (
    id text,
    opid integer,
    location text,
    title text,
    srid integer,
    x1 numeric(10,2),
    y1 numeric(10,2),
    z1 numeric(10,2),
    length numeric,
    x2 numeric(10,2),
    y2 numeric(10,2),
    z2 numeric(10,2),
    num integer NOT NULL
);
ALTER TABLE sections_array OWNER TO pierre;


SET search_path = pierre, pg_catalog;
CREATE TABLE ana_det_limit (
    batch_id text,
    elem_code text,
    elem_name text,
    unit text,
    detlim_inf integer,
    detlim_sup integer,
    opid integer
);
ALTER TABLE ana_det_limit OWNER TO pierre;

SET search_path = public, pg_catalog;
CREATE TABLE ancient_workings (
    gid integer NOT NULL,
    description text,
    the_geom geometry,
    opid integer,
    numauto integer NOT NULL,
    datasource integer,
    CONSTRAINT enforce_geotype_the_geom CHECK (((geometrytype(the_geom) = 'POINT'::text) OR (the_geom IS NULL)))
);
ALTER TABLE ancient_workings OWNER TO data_admin;
COMMENT ON TABLE ancient_workings IS 'Ancient workings, either historic or recent';
COMMENT ON COLUMN ancient_workings.gid IS 'Identifier';
COMMENT ON COLUMN ancient_workings.description IS 'Full description';
COMMENT ON COLUMN ancient_workings.the_geom IS 'Geometry, usded in GIS';
COMMENT ON COLUMN ancient_workings.opid IS 'Operation identifier';
COMMENT ON COLUMN ancient_workings.numauto IS 'Automatic integer';
COMMENT ON COLUMN ancient_workings.datasource IS 'Datasource identifier, refers to lex_datasource';


SET search_path = public, pg_catalog;
CREATE TABLE baselines (
    opid integer,
    id integer,
    location text,
    x1 numeric(10,3),
    y1 numeric(10,3),
    z1 numeric(10,3),
    x2 numeric(10,3),
    y2 numeric(10,3),
    z2 numeric(10,3),
    numauto integer NOT NULL,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"(),
    datasource integer
);
ALTER TABLE baselines OWNER TO data_admin;
COMMENT ON TABLE baselines IS 'Baselines, for each prospect, defined as a theoritical line between two points';
COMMENT ON COLUMN baselines.opid IS 'Operation identifier';
COMMENT ON COLUMN baselines.id IS 'Baseline identifier';
COMMENT ON COLUMN baselines.x1 IS 'Baseline starting point x coordinate';
COMMENT ON COLUMN baselines.y1 IS 'Baseline starting point y coordinate';
COMMENT ON COLUMN baselines.z1 IS 'Baseline starting point z coordinate';
COMMENT ON COLUMN baselines.x2 IS 'Baseline ending point x coordinate';
COMMENT ON COLUMN baselines.y2 IS 'Baseline ending point y coordinate';
COMMENT ON COLUMN baselines.z2 IS 'Baseline ending point z coordinate';
COMMENT ON COLUMN baselines.numauto IS 'Automatic integer primary key';
COMMENT ON COLUMN baselines.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN baselines.username IS 'User (role) which created data record';
COMMENT ON COLUMN baselines.datasource IS 'Datasource identifier, refers to lex_datasource';




CREATE TABLE dh_collars_lengths (
    opid integer,
    id text,
    len_destr numeric(10,2),
    len_pq numeric(10,2),
    len_hq numeric(10,2),
    len_nq numeric(10,2),
    len_bq numeric(10,2),
    numauto integer NOT NULL
);
COMMENT ON TABLE dh_collars_lengths IS 'Old data, fields removed from dh_collars table, values stored here';
COMMENT ON COLUMN dh_collars_lengths.len_destr IS 'Destructive (percussion or rotary drilling) length (m)';
COMMENT ON COLUMN dh_collars_lengths.len_pq IS 'Core PQ length (m)';
COMMENT ON COLUMN dh_collars_lengths.len_hq IS 'Core HQ length (m)';
COMMENT ON COLUMN dh_collars_lengths.len_nq IS 'Core NQ length (m)';
COMMENT ON COLUMN dh_collars_lengths.len_bq IS 'Core BQ length (m)';








CREATE TABLE lab_ana_results (
    opid integer,
    labname text,
    jobno text,
    orderno text,
    batch_id integer,
    sample_id text,
    sample_id_lab text,
    sampletype text,
    scheme text,
    analyte text,
    value text,
    value_num numeric,
    unit text,
    detlim numeric,
    uplim numeric,
    valid boolean DEFAULT true,
    datasource integer,
    numauto integer NOT NULL,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"()
);
ALTER TABLE lab_ana_results OWNER TO data_admin;
COMMENT ON TABLE lab_ana_results IS 'Laboratory results table, after laboratory instructions, related to LIMS system';
COMMENT ON COLUMN lab_ana_results.labname IS 'Analytical laboratory';
COMMENT ON COLUMN lab_ana_results.jobno IS 'jcsa.pro_job,           --> Intertek JobNo (text(20))';
COMMENT ON COLUMN lab_ana_results.orderno IS 'pj.orderno,              --> Client Order No (text(40))';
COMMENT ON COLUMN lab_ana_results.sample_id IS 'Sample Identifier';
COMMENT ON COLUMN lab_ana_results.scheme IS 'pjcsa.sch_code,          --> Scheme Code (Intertek Internal Code - which probably reported to Client as well) (text(20))';
COMMENT ON COLUMN lab_ana_results.analyte IS 'pjcsa.analytecode,       --> Analyte Code (Intertek Internal Code - which probably reported to Client as well) (text(20))';
COMMENT ON COLUMN lab_ana_results.value IS 'pjcsa.formattedvalue     --> Reported Value (text(20))';
COMMENT ON COLUMN lab_ana_results.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN lab_ana_results.value_num IS 'Reported value, converted to numeric. IS becomes -999, LNR -9999, < -, > nothing';
COMMENT ON COLUMN lab_ana_results.opid IS 'Operation identifier';
COMMENT ON COLUMN lab_ana_results.batch_id IS 'Batch identifier';
COMMENT ON COLUMN lab_ana_results.sampletype IS 'Sample type: DUP: duplicate, STD: standard, REP: repeat, etc.';
COMMENT ON COLUMN lab_ana_results.unit IS 'Unit: PPM, PPB, KG, G, %, etc.';
COMMENT ON COLUMN lab_ana_results.datasource IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN lab_ana_results.numauto IS 'Automatic integer primary key';
COMMENT ON COLUMN lab_ana_results.sample_id_lab IS 'pjc.sampleident,         --> Client SampleID (text(40)) => sometimes different from REAL sample_id';
COMMENT ON COLUMN lab_ana_results.valid IS 'Analysis is considered as valid or ignored (if QAQC failed, for instance)';
COMMENT ON COLUMN lab_ana_results.detlim IS 'Lower detection limit';
COMMENT ON COLUMN lab_ana_results.uplim IS 'Upper limit';
COMMENT ON COLUMN lab_ana_results.username IS 'User (role) which created data record';


CREATE TABLE doc_postgeol_table_categories (
    category text NOT NULL,
    description_fr text,
    numauto integer NOT NULL
);
ALTER TABLE doc_postgeol_table_categories _table_categories OWNER TO pierre;


}}}
vues inutiles:{{{

SET search_path = pierre, pg_catalog;
CREATE VIEW dh_collars AS
 SELECT dh_collars.id,
    dh_collars.shid,
    dh_collars.location,
    dh_collars.profile,
    dh_collars.srid,
    dh_collars.x,
    dh_collars.y,
    dh_collars.z,
    dh_collars.azim_ng,
    dh_collars.azim_nm,
    dh_collars.dip_hz,
    dh_collars.dh_type,
    dh_collars.date_start,
    dh_collars.contractor,
    dh_collars.geologist,
    dh_collars.length,
    dh_collars.nb_samples,
    dh_collars.comments,
    dh_collars.completed,
    dh_collars.numauto,
    dh_collars.date_completed,
    dh_collars.opid,
    dh_collars.purpose,
    dh_collars.x_local,
    dh_collars.y_local,
    dh_collars.z_local,
    dh_collars.accusum,
    dh_collars.id_pject,
    dh_collars.x_pject,
    dh_collars.y_pject,
    dh_collars.z_pject,
    dh_collars.topo_survey_type,
    dh_collars.creation_ts,
    dh_collars.username,
    dh_collars.datasource
   FROM (public.dh_collars
     JOIN public.operation_active ON ((dh_collars.opid = operation_active.opid)));
ALTER TABLE dh_collars OWNER TO pierre;

--
-- Name: dh_litho; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW dh_litho AS
 SELECT dh_litho.id,
    dh_litho.depfrom,
    dh_litho.depto,
    dh_litho.description,
    dh_litho.code1,
    dh_litho.code2,
    dh_litho.code3,
    dh_litho.code4,
    dh_litho.value1,
    dh_litho.value2,
    dh_litho.value3,
    dh_litho.value4,
    dh_litho.opid,
    dh_litho.colour,
    dh_litho.numauto,
    dh_litho.datasource,
    dh_litho.description1,
    dh_litho.description2,
    dh_litho.value5,
    dh_litho.value6,
    dh_litho.creation_ts,
    dh_litho.username
   FROM (public.dh_litho
     JOIN public.operation_active ON ((dh_litho.opid = operation_active.opid)));
ALTER TABLE dh_litho OWNER TO pierre;




SET search_path = pierre, pg_catalog;
--
-- Name: topo_points; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW topo_points AS
 SELECT topo_points.location,
    topo_points.num,
    topo_points.x,
    topo_points.y,
    topo_points.z,
    topo_points.numauto,
    topo_points.id,
    topo_points.datasource,
    topo_points.opid,
    topo_points.survey_date,
    topo_points.topo_survey_type,
    topo_points.coordsys,
    topo_points.surveyor,
    topo_points.creation_ts,
    topo_points.username
   FROM (public.topo_points
     JOIN public.operation_active ON ((topo_points.opid = operation_active.opid)));
ALTER TABLE topo_points OWNER TO pierre;




SET search_path = pierre, pg_catalog;
--
-- Name: dh_sampling_grades; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW dh_sampling_grades AS
 SELECT dh_sampling_grades.id,
    dh_sampling_grades.depfrom,
    dh_sampling_grades.depto,
    dh_sampling_grades.core_loss_cm,
    dh_sampling_grades.weight_kg,
    dh_sampling_grades.sample_type,
    dh_sampling_grades.sample_id,
    dh_sampling_grades.comments,
    dh_sampling_grades.opid,
    dh_sampling_grades.batch_id,
    dh_sampling_grades.datasource,
    dh_sampling_grades.au1_ppm,
    dh_sampling_grades.au2_ppm,
    dh_sampling_grades.au3_ppm,
    dh_sampling_grades.au4_ppm,
    dh_sampling_grades.au5_ppm,
    dh_sampling_grades.au6_ppm,
    dh_sampling_grades.ph,
    dh_sampling_grades.moisture,
    dh_sampling_grades.numauto,
    dh_sampling_grades.au_specks,
    dh_sampling_grades.quartering,
    dh_sampling_grades.creation_ts,
    dh_sampling_grades.username
   FROM (public.dh_sampling_grades
     JOIN public.operation_active ON ((dh_sampling_grades.opid = operation_active.opid)));
ALTER TABLE dh_sampling_grades OWNER TO pierre;

Vues inutiles:{{{
SET search_path = pierre, pg_catalog;

--
-- Name: shift_reports; Type: VIEW; Schema: pierre; Owner: pierre
--

CREATE VIEW shift_reports AS
 SELECT shift_reports.opid,
    shift_reports.date,
    shift_reports.shift,
    shift_reports.no_fichette,
    shift_reports.rig,
    shift_reports.geologist,
    shift_reports.time_start,
    shift_reports.time_end,
    shift_reports.id,
    shift_reports.peg_number,
    shift_reports.planned_length,
    shift_reports.tool,
    shift_reports.drilled_length_during_shift,
    shift_reports.drilled_length,
    shift_reports.completed,
    shift_reports.profile,
    shift_reports.comments,
    shift_reports.invoice_nr,
    shift_reports.drilled_shift_destr,
    shift_reports.drilled_shift_pq,
    shift_reports.drilled_shift_hq,
    shift_reports.drilled_shift_nq,
    shift_reports.recovered_length_shift,
    shift_reports.stdby_time1_h,
    shift_reports.stdby_time2_h,
    shift_reports.stdby_time3_h,
    shift_reports.moving_time_h,
    shift_reports.driller_name,
    shift_reports.geologist_supervisor,
    shift_reports.creation_ts,
    shift_reports.username,
    shift_reports.numauto,
    shift_reports.datasource
   FROM (public.shift_reports
     JOIN public.operation_active ON ((shift_reports.opid = operation_active.opid)));


ALTER TABLE shift_reports OWNER TO pierre;





SET search_path = pierre, pg_catalog;

--
-- Name: ancient_workings; Type: VIEW; Schema: pierre; Owner: pierre
--

CREATE VIEW ancient_workings AS
 SELECT ancient_workings.gid,
    ancient_workings.description,
    ancient_workings.the_geom,
    ancient_workings.opid,
    ancient_workings.numauto,
    ancient_workings.datasource
   FROM (public.ancient_workings
     JOIN public.operation_active ON ((ancient_workings.opid = operation_active.opid)));


ALTER TABLE ancient_workings OWNER TO pierre;




SET search_path = pierre, pg_catalog;

--
-- Name: baselines; Type: VIEW; Schema: pierre; Owner: pierre
--

CREATE VIEW baselines AS
 SELECT baselines.opid,
    baselines.id,
    baselines.location,
    baselines.x1,
    baselines.y1,
    baselines.z1,
    baselines.x2,
    baselines.y2,
    baselines.z2,
    baselines.numauto,
    baselines.creation_ts,
    baselines.username,
    baselines.datasource
   FROM (public.baselines
     JOIN public.operation_active ON ((baselines.opid = operation_active.opid)));


ALTER TABLE baselines OWNER TO pierre;


}}}

{{{
SET search_path = pierre, pg_catalog;

--
-- Name: dh_devia; Type: VIEW; Schema: pierre; Owner: pierre
--

CREATE VIEW dh_devia AS
 SELECT dh_devia.id,
    dh_devia.depto,
    dh_devia.azim_nm,
    dh_devia.dip_hz,
    dh_devia.temperature,
    dh_devia.magnetic,
    dh_devia.date,
    dh_devia.roll,
    dh_devia."time",
    dh_devia.comments,
    dh_devia.opid,
    dh_devia.numauto,
    dh_devia.valid,
    dh_devia.azim_ng,
    dh_devia.datasource,
    dh_devia.device,
    dh_devia.creation_ts,
    dh_devia.username
   FROM (public.dh_devia
     JOIN public.operation_active ON ((dh_devia.opid = operation_active.opid)));


ALTER TABLE dh_devia OWNER TO pierre;






SET search_path = pierre, pg_catalog;

--
-- Name: lab_ana_results; Type: VIEW; Schema: pierre; Owner: pierre
--

CREATE VIEW lab_ana_results AS
 SELECT lab_ana_results.labname,
    lab_ana_results.jobno,
    lab_ana_results.orderno,
    lab_ana_results.sample_id,
    lab_ana_results.scheme,
    lab_ana_results.analyte,
    lab_ana_results.value,
    lab_ana_results.creation_ts,
    lab_ana_results.value_num,
    lab_ana_results.opid,
    lab_ana_results.batch_id,
    lab_ana_results.sampletype,
    lab_ana_results.unit,
    lab_ana_results.datasource,
    lab_ana_results.numauto,
    lab_ana_results.sample_id_lab,
    lab_ana_results.valid,
    lab_ana_results.detlim,
    lab_ana_results.uplim,
    lab_ana_results.username
   FROM (public.lab_ana_results
     JOIN public.operation_active ON ((lab_ana_results.opid = operation_active.opid)));


ALTER TABLE lab_ana_results OWNER TO pierre;



}}}


SET search_path = pierre, pg_catalog;
--
-- Name: dh_core_boxes; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW dh_core_boxes AS
 SELECT dh_core_boxes.id,
    dh_core_boxes.depfrom,
    dh_core_boxes.depto,
    dh_core_boxes.box_number,
    dh_core_boxes.datasource,
    dh_core_boxes.opid,
    dh_core_boxes.numauto,
    dh_core_boxes.creation_ts,
    dh_core_boxes.username
   FROM (public.dh_core_boxes
     JOIN public.operation_active ON ((dh_core_boxes.opid = operation_active.opid)));
ALTER TABLE dh_core_boxes OWNER TO pierre;


SET search_path = pierre, pg_catalog;
--
-- Name: dh_density; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW dh_density AS
 SELECT dh_density.id,
    dh_density.depfrom,
    dh_density.depto,
    dh_density.density,
    dh_density.opid,
    dh_density.density_humid,
    dh_density.moisture,
    dh_density.method,
    dh_density.numauto,
    dh_density.creation_ts,
    dh_density.username,
    dh_density.datasource
   FROM (public.dh_density
     JOIN public.operation_active ON ((dh_density.opid = operation_active.opid)));
ALTER TABLE dh_density OWNER TO pierre;



SET search_path = pierre, pg_catalog;
--
-- Name: dh_followup; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW dh_followup AS
 SELECT dh_followup.opid,
    dh_followup.id,
    dh_followup.devia,
    dh_followup.quick_log,
    dh_followup.log_tech,
    dh_followup.log_lith,
    dh_followup.sampling,
    dh_followup.results,
    dh_followup.relogging,
    dh_followup.beacon,
    dh_followup.in_gdm,
    dh_followup.creation_ts,
    dh_followup.username,
    dh_followup.numauto
   FROM (public.dh_followup
     JOIN public.operation_active ON ((dh_followup.opid = operation_active.opid)));
ALTER TABLE dh_followup OWNER TO pierre;



SET search_path = pierre, pg_catalog;
--
-- Name: dh_mineralised_intervals; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW dh_mineralised_intervals AS
 SELECT dh_mineralised_intervals.id,
    dh_mineralised_intervals.depfrom,
    dh_mineralised_intervals.depto,
    dh_mineralised_intervals.mine,
    dh_mineralised_intervals.avau,
    dh_mineralised_intervals.stva,
    dh_mineralised_intervals.accu,
    dh_mineralised_intervals.recu,
    dh_mineralised_intervals.dens,
    dh_mineralised_intervals.numauto,
    dh_mineralised_intervals.comments,
    dh_mineralised_intervals.opid,
    dh_mineralised_intervals.creation_ts,
    dh_mineralised_intervals.username,
    dh_mineralised_intervals.datasource
   FROM (public.dh_mineralised_intervals
     JOIN public.operation_active ON ((dh_mineralised_intervals.opid = operation_active.opid)));
ALTER TABLE dh_mineralised_intervals OWNER TO pierre;


}}}
-- vu: @#TODO vue inutile?? (dh_sampling = ??) => non, semble utile, appelée par d'autres vues checks.*:{{{
--
-- Name: dh_sampling; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW dh_sampling AS
 SELECT dh_sampling_grades.id,
    dh_sampling_grades.depfrom,
    dh_sampling_grades.depto,
    dh_sampling_grades.core_loss_cm,
    dh_sampling_grades.weight_kg,
    dh_sampling_grades.sample_type,
    dh_sampling_grades.sample_id,
    dh_sampling_grades.comments,
    dh_sampling_grades.opid,
    dh_sampling_grades.batch_id,
    dh_sampling_grades.datasource
   FROM dh_sampling_grades;
ALTER TABLE dh_sampling OWNER TO pierre;


}}}
vu, vues:{{{


SET search_path = checks, pg_catalog;
--
-- Name: collars_lengths_vs_dh_litho_depths; Type: VIEW; Schema: checks; Owner: pierre
--
CREATE VIEW collars_lengths_vs_dh_litho_depths AS
 SELECT dh_collars.id,
    dh_collars.length,
    max_depto.max_depto_litho,
    (dh_collars.length - max_depto.max_depto_litho) AS diff_should_be_zero
   FROM (pierre.dh_collars
     JOIN ( SELECT dh_litho.id,
            max(dh_litho.depto) AS max_depto_litho
           FROM pierre.dh_litho
          GROUP BY dh_litho.id) max_depto ON (((dh_collars.id)::text = (max_depto.id)::text)))
  WHERE ((dh_collars.length - max_depto.max_depto_litho) <> (0)::numeric)
  ORDER BY dh_collars.id;
ALTER TABLE collars_lengths_vs_dh_litho_depths OWNER TO pierre;


SET search_path = checks, pg_catalog;
--
-- Name: collars_lengths_vs_dh_sampling_depths; Type: VIEW; Schema: checks; Owner: pierre
--
CREATE VIEW collars_lengths_vs_dh_sampling_depths AS
 SELECT dh_collars.id,
    dh_collars.length,
    max_depto.max_depto_sampl,
    (dh_collars.length - max_depto.max_depto_sampl) AS diff_should_be_zero
   FROM (pierre.dh_collars
     JOIN ( SELECT dh_sampling.id,
            max(dh_sampling.depto) AS max_depto_sampl
           FROM pierre.dh_sampling
          GROUP BY dh_sampling.id) max_depto ON (((dh_collars.id)::text = (max_depto.id)::text)))
  WHERE ((dh_collars.length - max_depto.max_depto_sampl) <> (0)::numeric)
  ORDER BY dh_collars.id;
ALTER TABLE collars_lengths_vs_dh_sampling_depths OWNER TO pierre;



}}} */

-- @#TODO vues GDM:{{{
--
-- Name: gdm_dh_devia; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW gdm_dh_devia AS
 SELECT gdm_dh_devia.id,
    gdm_dh_devia.x,
    gdm_dh_devia.y,
    gdm_dh_devia.z,
    gdm_dh_devia.length,
    gdm_dh_devia.azim_ng_collar,
    gdm_dh_devia.dip_collar,
    gdm_dh_devia.depto,
    gdm_dh_devia.azim_ng,
    gdm_dh_devia.dip_hz
   FROM gdm.gdm_dh_devia;
ALTER TABLE gdm_dh_devia OWNER TO pierre;

--
-- Name: gdm_dh_litho; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW gdm_dh_litho AS
 SELECT dh_collars.id,
    dh_collars.location,
    dh_collars.x,
    dh_collars.y,
    dh_collars.z,
    dh_collars.azim_ng,
    dh_collars.dip_hz,
    dh_collars.length,
    dh_litho.depfrom,
    dh_litho.depto,
    dh_litho.code1,
    dh_litho.code2,
    dh_litho.code3,
    dh_litho.code4,
    dh_litho.value1,
    dh_litho.value2,
    dh_litho.value3,
    dh_litho.value4,
    dh_litho.description
   FROM ((gdm.gdm_selection
     JOIN dh_collars ON (((gdm_selection.opid = dh_collars.opid) AND ((gdm_selection.id)::text = (dh_collars.id)::text))))
     JOIN dh_litho ON (((dh_collars.opid = dh_litho.opid) AND ((dh_collars.id)::text = (dh_litho.id)::text))))
  ORDER BY dh_collars.id, dh_litho.depto;
ALTER TABLE gdm_dh_litho OWNER TO pierre;

--
-- Name: gdm_dh_mine_0; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW gdm_dh_mine_0 AS
 SELECT dh_collars.id,
    dh_collars.x,
    dh_collars.y,
    dh_collars.z,
    dh_collars.azim_ng,
    dh_collars.dip_hz,
    dh_collars.length,
    dh_mineralised_intervals.depfrom,
    dh_mineralised_intervals.depto,
    dh_mineralised_intervals.avau,
    dh_mineralised_intervals.stva,
    dh_mineralised_intervals.accu,
    dh_mineralised_intervals.dens,
    dh_mineralised_intervals.recu,
    dh_mineralised_intervals.comments
   FROM ((gdm.gdm_selection
     JOIN dh_collars ON (((gdm_selection.opid = dh_collars.opid) AND ((gdm_selection.id)::text = (dh_collars.id)::text))))
     JOIN dh_mineralised_intervals ON (((dh_collars.opid = dh_mineralised_intervals.opid) AND ((dh_collars.id)::text = (dh_mineralised_intervals.id)::text))))
  WHERE (dh_mineralised_intervals.mine = 0);
ALTER TABLE gdm_dh_mine_0 OWNER TO pierre;

--
-- Name: gdm_dh_mine_1; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW gdm_dh_mine_1 AS
 SELECT dh_collars.id,
    dh_collars.x,
    dh_collars.y,
    dh_collars.z,
    dh_collars.azim_ng,
    dh_collars.dip_hz,
    dh_collars.length,
    dh_mineralised_intervals.depfrom,
    dh_mineralised_intervals.depto,
    dh_mineralised_intervals.avau,
    dh_mineralised_intervals.stva,
    dh_mineralised_intervals.accu,
    dh_mineralised_intervals.dens,
    dh_mineralised_intervals.recu,
    dh_mineralised_intervals.comments
   FROM ((gdm.gdm_selection
     JOIN dh_collars ON (((gdm_selection.opid = dh_collars.opid) AND ((gdm_selection.id)::text = (dh_collars.id)::text))))
     JOIN dh_mineralised_intervals ON (((dh_collars.opid = dh_mineralised_intervals.opid) AND ((dh_collars.id)::text = (dh_mineralised_intervals.id)::text))))
  WHERE (dh_mineralised_intervals.mine = 1);
ALTER TABLE gdm_dh_mine_1 OWNER TO pierre;

--
-- Name: gdm_dh_planned; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW gdm_dh_planned AS
 SELECT dh_collars.id,
    dh_collars.location,
    dh_collars.x,
    dh_collars.y,
    dh_collars.z,
    dh_collars.azim_ng,
    dh_collars.dip_hz,
    dh_collars.length,
    dh_collars.completed,
    dh_collars.comments,
    dh_collars.length AS depto
   FROM (gdm.gdm_selection
     JOIN dh_collars ON (((gdm_selection.opid = dh_collars.opid) AND ((gdm_selection.id)::text = (dh_collars.id)::text))))
  WHERE ((dh_collars.completed = false) OR (dh_collars.completed IS NULL))
  ORDER BY dh_collars.id, dh_collars.length;
ALTER TABLE gdm_dh_planned OWNER TO pierre;

--
-- Name: gdm_dh_sampling_grades; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW gdm_dh_sampling_grades AS
 SELECT dh_collars.id,
    dh_collars.x,
    dh_collars.y,
    dh_collars.z,
    dh_collars.length,
    dh_sampling_grades_nodup.depfrom,
    dh_sampling_grades_nodup.depto,
    dh_sampling_grades_nodup.au1_ppm,
    dh_sampling_grades_nodup.au2_ppm,
    dh_sampling_grades_nodup.au3_ppm,
    dh_sampling_grades_nodup.au4_ppm,
    dh_sampling_grades_nodup.au5_ppm,
    dh_sampling_grades_nodup.au6_ppm
   FROM ((gdm.gdm_selection
     JOIN dh_collars ON (((gdm_selection.opid = dh_collars.opid) AND ((gdm_selection.id)::text = (dh_collars.id)::text))))
     JOIN ( SELECT dh_sampling_grades.id,
            dh_sampling_grades.depfrom,
            dh_sampling_grades.depto,
            dh_sampling_grades.core_loss_cm,
            dh_sampling_grades.weight_kg,
            dh_sampling_grades.sample_type,
            dh_sampling_grades.sample_id,
            dh_sampling_grades.comments,
            dh_sampling_grades.opid,
            dh_sampling_grades.batch_id,
            dh_sampling_grades.datasource,
            dh_sampling_grades.au1_ppm,
            dh_sampling_grades.au2_ppm,
            dh_sampling_grades.au3_ppm,
            dh_sampling_grades.au4_ppm,
            dh_sampling_grades.au5_ppm,
            dh_sampling_grades.au6_ppm,
            dh_sampling_grades.ph,
            dh_sampling_grades.moisture,
            dh_sampling_grades.numauto,
            dh_sampling_grades.au_specks,
            dh_sampling_grades.quartering,
            dh_sampling_grades.creation_ts,
            dh_sampling_grades.username
           FROM dh_sampling_grades
          WHERE ((dh_sampling_grades.sample_type IS NULL) OR ((dh_sampling_grades.sample_type)::text <> 'DUP'::text))) dh_sampling_grades_nodup ON (((dh_collars.id)::text = (dh_sampling_grades_nodup.id)::text)))
  ORDER BY dh_sampling_grades_nodup.id, dh_sampling_grades_nodup.depto;
ALTER TABLE gdm_dh_sampling_grades OWNER TO pierre;

--
-- Name: gdm_dh_sampling_grades_open_ended_au_tail; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW gdm_dh_sampling_grades_open_ended_au_tail AS
 SELECT gdm_dh_sampling_grades.id,
    gdm_dh_sampling_grades.x,
    gdm_dh_sampling_grades.y,
    gdm_dh_sampling_grades.z,
    gdm_dh_sampling_grades.length,
    gdm_dh_sampling_grades.depfrom,
    gdm_dh_sampling_grades.depto,
    gdm_dh_sampling_grades.au1_ppm,
    gdm_dh_sampling_grades.au2_ppm,
    gdm_dh_sampling_grades.au3_ppm,
    gdm_dh_sampling_grades.au4_ppm,
    gdm_dh_sampling_grades.au5_ppm,
    gdm_dh_sampling_grades.au6_ppm
   FROM (gdm_dh_sampling_grades
     JOIN dh_sampling_grades_open_ended_au_tail ON ((((gdm_dh_sampling_grades.id)::text = (dh_sampling_grades_open_ended_au_tail.id)::text) AND (gdm_dh_sampling_grades.depto = dh_sampling_grades_open_ended_au_tail.depto))));
ALTER TABLE gdm_dh_sampling_grades_open_ended_au_tail OWNER TO pierre;

--
-- Name: gdm_dh_sampling_grades_open_ended_au_top; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW gdm_dh_sampling_grades_open_ended_au_top AS
 SELECT gdm_dh_sampling_grades.id,
    gdm_dh_sampling_grades.x,
    gdm_dh_sampling_grades.y,
    gdm_dh_sampling_grades.z,
    gdm_dh_sampling_grades.length,
    gdm_dh_sampling_grades.depfrom,
    gdm_dh_sampling_grades.depto,
    gdm_dh_sampling_grades.au1_ppm,
    gdm_dh_sampling_grades.au2_ppm,
    gdm_dh_sampling_grades.au3_ppm,
    gdm_dh_sampling_grades.au4_ppm,
    gdm_dh_sampling_grades.au5_ppm,
    gdm_dh_sampling_grades.au6_ppm
   FROM (gdm_dh_sampling_grades
     JOIN dh_sampling_grades_open_ended_au_top ON ((((gdm_dh_sampling_grades.id)::text = (dh_sampling_grades_open_ended_au_top.id)::text) AND (gdm_dh_sampling_grades.depto = dh_sampling_grades_open_ended_au_top.depto))));
ALTER TABLE gdm_dh_sampling_grades_open_ended_au_top OWNER TO pierre;

--
-- Name: gdm_selection; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW gdm_selection AS
 SELECT dh_collars.opid,
    dh_collars.id
   FROM (public.dh_collars
     JOIN public.operation_active ON ((dh_collars.opid = operation_active.opid)))
  WHERE (NOT ((dh_collars.x < (1000)::numeric) OR (dh_collars.y < (10000)::numeric)));
ALTER TABLE gdm_selection OWNER TO pierre;

--
-- Name: gdm_sections_array; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW gdm_sections_array AS
 SELECT sections_array.id,
    sections_array.opid,
    sections_array.location,
    sections_array.title,
    sections_array.srid,
    sections_array.x1,
    sections_array.y1,
    sections_array.z1,
    sections_array.length,
    sections_array.x2,
    sections_array.y2,
    sections_array.z2,
    sections_array.num
   FROM sections_array
  WHERE (sections_array.opid IN ( SELECT DISTINCT gdm_selection.opid
           FROM gdm_selection))
  ORDER BY sections_array.id;
ALTER TABLE gdm_sections_array OWNER TO pierre;



--
-- Name: gdm_baselines; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW gdm_baselines AS
 SELECT baselines.opid,
    baselines.id,
    baselines.location,
    baselines.x1,
    baselines.y1,
    baselines.z1,
    baselines.x2,
    baselines.y2,
    baselines.z2,
    baselines.numauto,
    baselines.creation_ts,
    baselines.username,
    baselines.datasource,
    1 AS "order"
   FROM baselines
  ORDER BY baselines.id;
ALTER TABLE gdm_baselines OWNER TO pierre;


}}}
-- @#TODO vues surpac:{{{

--
-- Name: surpac_survey; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW surpac_survey AS
 SELECT dh_collars.id AS hole_id,
    0 AS depth,
    (- dh_collars.dip_hz) AS dip,
    dh_collars.azim_ng AS azimuth
   FROM dh_collars
  WHERE (NOT ((dh_collars.id)::text IN ( SELECT DISTINCT dh_devia.id
           FROM dh_devia
          WHERE ((dh_devia.depto = (0)::numeric) AND (dh_devia.valid IS TRUE)))))
UNION
 SELECT dh_devia.id AS hole_id,
    dh_devia.depto AS depth,
    (- dh_devia.dip_hz) AS dip,
    dh_devia.azim_ng AS azimuth
   FROM dh_devia
  WHERE (dh_devia.valid IS TRUE)
  ORDER BY 1, 2;


ALTER TABLE surpac_survey OWNER TO pierre;



CREATE VIEW tanguysurp_project AS
 SELECT DISTINCT COALESCE(dh_collars.location, 'undefined'::text) AS project_id
   FROM public.dh_collars;


ALTER TABLE tanguysurp_project OWNER TO postgres;

--
-- Name: VIEW tanguysurp_project; Type: COMMENT; Schema: pierre; Owner: postgres
--

COMMENT ON VIEW tanguysurp_project IS 'Vue formatée project pour Surpac';
CREATE VIEW tanguysurp_survey AS
 SELECT dh_devia.id AS hole_id,
    dh_devia.depto AS depth,
    dh_devia.azim_ng AS azimuth,
    (- dh_devia.dip_hz) AS dip,
    dh_devia.temperature,
    dh_devia.magnetic,
    dh_devia.date,
    dh_devia.roll,
    dh_devia."time",
    dh_devia.comments,
    dh_devia.valid,
    dh_devia.azim_nm,
    dh_devia.datasource,
    dh_devia.device
   FROM public.dh_devia
  WHERE dh_devia.valid;


ALTER TABLE tanguysurp_survey OWNER TO postgres;

--
-- Name: VIEW tanguysurp_survey; Type: COMMENT; Schema: pierre; Owner: postgres
--

COMMENT ON VIEW tanguysurp_survey IS 'Vue formatée survey pour Surpac';
CREATE TABLE tmp_xy (
    shid text NOT NULL,
    id integer NOT NULL,
    srid integer,
    x numeric(10,2),
    y numeric(10,2),
    z numeric(10,2),
    val numeric(10,2),
    comment text
);




}}}

-- @#TODO vues checks: à part, pour le moment:{{{

SET search_path = checks, pg_catalog;

--
-- Name: collars_vs_temp_topo_id_topo_sans_collars; Type: VIEW; Schema: checks; Owner: pierre
--

CREATE VIEW collars_vs_temp_topo_id_topo_sans_collars AS
 SELECT topo_points.id AS id_topo,
    dh_collars.id AS id_collars
   FROM (pierre.topo_points
     LEFT JOIN pierre.dh_collars ON (((topo_points.id)::text = (dh_collars.id)::text)))
  WHERE (dh_collars.id IS NULL);


ALTER TABLE collars_vs_temp_topo_id_topo_sans_collars OWNER TO pierre;

--
-- Name: collars_vs_topo_xyz_en_face_et_differences_importantes; Type: VIEW; Schema: checks; Owner: pierre
--

CREATE VIEW collars_vs_topo_xyz_en_face_et_differences_importantes AS
 SELECT tmp.id_topo,
    tmp.id_collars,
    tmp.topo_x,
    tmp.collars_x,
    tmp.diffx,
    tmp.topo_y,
    tmp.collars_y,
    tmp.diffy,
    tmp.topo_z,
    tmp.collars_z,
    tmp.diffz
   FROM ( SELECT topo_points.id AS id_topo,
            dh_collars.id AS id_collars,
            topo_points.x AS topo_x,
            dh_collars.x AS collars_x,
            topo_points.y AS topo_y,
            dh_collars.y AS collars_y,
            topo_points.z AS topo_z,
            dh_collars.z AS collars_z,
            (topo_points.x - dh_collars.x) AS diffx,
            (topo_points.y - dh_collars.y) AS diffy,
            (topo_points.z - dh_collars.z) AS diffz
           FROM (pierre.topo_points
             JOIN pierre.dh_collars ON (((topo_points.id)::text = (dh_collars.id)::text)))) tmp
  WHERE (((abs(tmp.diffx) >= 0.05) OR (abs(tmp.diffy) >= 0.05)) OR (abs(tmp.diffz) >= 0.05));


ALTER TABLE collars_vs_topo_xyz_en_face_et_differences_importantes OWNER TO pierre;

--
-- Name: dh_collars_to_topo_points_lines; Type: VIEW; Schema: checks; Owner: pierre
--

CREATE VIEW dh_collars_to_topo_points_lines AS
 SELECT dh_collars.id,
    topo_points.numauto,
    dh_collars.x AS dh_collars_x,
    topo_points.x AS topo_points_x,
    dh_collars.y AS dh_collars_y,
    topo_points.y AS topo_points_y,
    dh_collars.z AS dh_collars_z,
    topo_points.z AS topo_points_z,
    public.geomfromewkt((((((((((((('LINESTRING ('::text || (dh_collars.x)::text) || ' '::text) || (dh_collars.y)::text) || ' '::text) || (dh_collars.z)::text) || ', '::text) || topo_points.x) || ' '::text) || (topo_points.y)::text) || ' '::text) || topo_points.z) || ')'::text)) AS geometry
   FROM (pierre.topo_points
     JOIN pierre.dh_collars ON (((topo_points.opid = dh_collars.opid) AND ((topo_points.id)::text = (dh_collars.id)::text))));


ALTER TABLE dh_collars_to_topo_points_lines OWNER TO pierre;

--
-- Name: doublons_collars_id; Type: VIEW; Schema: checks; Owner: pierre
--

CREATE VIEW doublons_collars_id AS
 SELECT dh_collars.id AS collars_id_non_uniq,
    count(dh_collars.id) AS count
   FROM pierre.dh_collars
  GROUP BY dh_collars.id
 HAVING (count(dh_collars.id) > 1);


ALTER TABLE doublons_collars_id OWNER TO pierre;

--
-- Name: doublons_collars_xyz; Type: VIEW; Schema: checks; Owner: pierre
--

CREATE VIEW doublons_collars_xyz AS
 SELECT count(*) AS count,
    dh_collars.x,
    dh_collars.y,
    dh_collars.z,
    min((dh_collars.id)::text) AS min,
    max((dh_collars.id)::text) AS max
   FROM pierre.dh_collars
  GROUP BY dh_collars.x, dh_collars.y, dh_collars.z
 HAVING (count(*) > 1);


ALTER TABLE doublons_collars_xyz OWNER TO pierre;

--
-- Name: doublons_collars_xyz_ouvrages_concernes; Type: VIEW; Schema: checks; Owner: pierre
--

CREATE VIEW doublons_collars_xyz_ouvrages_concernes AS
 SELECT dh_collars.id,
    dh_collars.x,
    dh_collars.y,
    dh_collars.z,
    dh_collars.azim_ng,
    dh_collars.dip_hz
   FROM (pierre.dh_collars
     JOIN ( SELECT count(*) AS count,
            dh_collars_1.x,
            dh_collars_1.y
           FROM pierre.dh_collars dh_collars_1
          GROUP BY dh_collars_1.x, dh_collars_1.y
         HAVING (count(*) > 1)) tmp ON (((dh_collars.x = tmp.x) AND (dh_collars.y = tmp.y))));


ALTER TABLE doublons_collars_xyz_ouvrages_concernes OWNER TO pierre;

--
-- Name: doublons_dh_litho_id_depto; Type: VIEW; Schema: checks; Owner: pierre
--

CREATE VIEW doublons_dh_litho_id_depto AS
 SELECT dh_litho.id,
    dh_litho.depto,
    count(*) AS count
   FROM pierre.dh_litho
  GROUP BY dh_litho.id, dh_litho.depto
 HAVING (count(*) > 1);


ALTER TABLE doublons_dh_litho_id_depto OWNER TO pierre;

--
-- Name: doublons_dh_sampling_id_depto; Type: VIEW; Schema: checks; Owner: pierre
--

CREATE VIEW doublons_dh_sampling_id_depto AS
 SELECT dh_sampling.id,
    dh_sampling.depto,
    count(*) AS count
   FROM pierre.dh_sampling
  GROUP BY dh_sampling.id, dh_sampling.depto
 HAVING (count(*) > 1);


ALTER TABLE doublons_dh_sampling_id_depto OWNER TO pierre;





SET search_path = checks, pg_catalog;

--
-- Name: fichettes_infos_incoherentes_drilled_lengths; Type: VIEW; Schema: checks; Owner: pierre
--

CREATE VIEW fichettes_infos_incoherentes_drilled_lengths AS
 SELECT min(shift_reports.no_fichette) AS first_fichette,
    max(shift_reports.no_fichette) AS last_fichette,
    shift_reports.id,
    sum(shift_reports.drilled_length_during_shift) AS sum_drilled_length_during_shift,
    max(shift_reports.drilled_length) AS max_drilled_length
   FROM pierre.shift_reports
  GROUP BY shift_reports.id
 HAVING (sum(shift_reports.drilled_length_during_shift) <> max(shift_reports.drilled_length))
  ORDER BY shift_reports.id;


ALTER TABLE fichettes_infos_incoherentes_drilled_lengths OWNER TO pierre;

--
-- Name: fichettes_infos_incoherentes_heures; Type: VIEW; Schema: checks; Owner: pierre
--

CREATE VIEW fichettes_infos_incoherentes_heures AS
 SELECT shift_reports.date,
    shift_reports.id,
    shift_reports.time_start,
    shift_reports.time_end
   FROM pierre.shift_reports
  WHERE (shift_reports.time_start > shift_reports.time_end);


ALTER TABLE fichettes_infos_incoherentes_heures OWNER TO pierre;

--
-- Name: fichettes_infos_redondantes_incoherentes; Type: VIEW; Schema: checks; Owner: pierre
--

CREATE VIEW fichettes_infos_redondantes_incoherentes AS
 SELECT tmp1.nb_sondages_et_attributs,
    tmp2.nb_sondages,
    (tmp1.nb_sondages_et_attributs - tmp2.nb_sondages) AS diff_should_be_zero
   FROM ( SELECT count(*) AS nb_sondages_et_attributs
           FROM ( SELECT shift_reports.id,
                    shift_reports.planned_length
                   FROM pierre.shift_reports
                  GROUP BY shift_reports.id, shift_reports.planned_length) tmp) tmp1,
    ( SELECT count(DISTINCT shift_reports.id) AS nb_sondages
           FROM pierre.shift_reports) tmp2
  WHERE ((tmp1.nb_sondages_et_attributs - tmp2.nb_sondages) <> 0);


ALTER TABLE fichettes_infos_redondantes_incoherentes OWNER TO pierre;

--
-- Name: fichettes_infos_redondantes_incoherentes_quels_ouvrages; Type: VIEW; Schema: checks; Owner: pierre
--

CREATE VIEW fichettes_infos_redondantes_incoherentes_quels_ouvrages AS
 SELECT shift_reports.id,
    min(shift_reports.planned_length) AS min_planned_length,
    max(shift_reports.planned_length) AS max_planned_length
   FROM pierre.shift_reports
  GROUP BY shift_reports.id
 HAVING (count(DISTINCT shift_reports.planned_length) > 1);


ALTER TABLE fichettes_infos_redondantes_incoherentes_quels_ouvrages OWNER TO pierre;

--
-- Name: fichettes_longueurs_incoherentes; Type: VIEW; Schema: checks; Owner: pierre
--

CREATE VIEW fichettes_longueurs_incoherentes AS
 SELECT tmp.id,
    tmp.max_drilled_length,
    tmp.sum_drilled_length_during_shift
   FROM ( SELECT shift_reports.id,
            max(shift_reports.drilled_length) AS max_drilled_length,
            sum(shift_reports.drilled_length_during_shift) AS sum_drilled_length_during_shift
           FROM pierre.shift_reports
          GROUP BY shift_reports.id
          ORDER BY shift_reports.id) tmp
  WHERE (tmp.max_drilled_length <> tmp.sum_drilled_length_during_shift);


ALTER TABLE fichettes_longueurs_incoherentes OWNER TO pierre;

--
-- Name: fichettes_ouvrages_non_completed; Type: VIEW; Schema: checks; Owner: pierre
--

CREATE VIEW fichettes_ouvrages_non_completed AS
 SELECT shift_reports.id,
    max((shift_reports.completed)::integer) AS max
   FROM pierre.shift_reports
  GROUP BY shift_reports.id
 HAVING (max((shift_reports.completed)::integer) <> 1);


ALTER TABLE fichettes_ouvrages_non_completed OWNER TO pierre;

--
-- Name: fichettes_vs_collars_completed_incoherents; Type: VIEW; Schema: checks; Owner: pierre
--

CREATE VIEW fichettes_vs_collars_completed_incoherents AS
 SELECT tmp.id,
    dh_collars.completed,
    tmp.max_completed_fichettes
   FROM (( SELECT shift_reports.id,
            max((shift_reports.completed)::integer) AS max_completed_fichettes
           FROM pierre.shift_reports
          GROUP BY shift_reports.id) tmp
     JOIN pierre.dh_collars ON (((tmp.id)::text = (dh_collars.id)::text)))
  WHERE ((dh_collars.completed)::integer <> tmp.max_completed_fichettes);


ALTER TABLE fichettes_vs_collars_completed_incoherents OWNER TO pierre;

--
-- Name: fichettes_vs_collars_longueurs_incoherentes; Type: VIEW; Schema: checks; Owner: pierre
--

CREATE VIEW fichettes_vs_collars_longueurs_incoherentes AS
 SELECT tmp.id,
    tmp.max_drilled_length,
    dh_collars.length
   FROM (( SELECT shift_reports.id,
            max(shift_reports.drilled_length) AS max_drilled_length,
            sum(shift_reports.drilled_length_during_shift) AS sum_drilled_length_during_shift
           FROM pierre.shift_reports
          GROUP BY shift_reports.id
          ORDER BY shift_reports.id) tmp
     JOIN pierre.dh_collars ON (((tmp.id)::text = (dh_collars.id)::text)))
  WHERE (tmp.max_drilled_length <> dh_collars.length);


ALTER TABLE fichettes_vs_collars_longueurs_incoherentes OWNER TO pierre;

--
-- Name: fichettes_vs_collars_ouvrages_dans_fichettes_pas_collars; Type: VIEW; Schema: checks; Owner: pierre
--

CREATE VIEW fichettes_vs_collars_ouvrages_dans_fichettes_pas_collars AS
 SELECT shift_reports.id AS shift_reports_id,
    dh_collars.id AS dh_collars_id
   FROM (pierre.shift_reports
     LEFT JOIN pierre.dh_collars ON (((shift_reports.id)::text = (dh_collars.id)::text)))
  WHERE (dh_collars.id IS NULL)
  ORDER BY shift_reports.id, dh_collars.id;


ALTER TABLE fichettes_vs_collars_ouvrages_dans_fichettes_pas_collars OWNER TO pierre;

--
-- Name: tetes_passes_ouvrages_dans_passes_pas_dans_tetes_dh_litho; Type: VIEW; Schema: checks; Owner: pierre
--

CREATE VIEW tetes_passes_ouvrages_dans_passes_pas_dans_tetes_dh_litho AS
 SELECT dh_collars.id,
    dh_litho.id AS litho_id
   FROM (pierre.dh_collars
     RIGHT JOIN pierre.dh_litho ON (((dh_collars.id)::text = (dh_litho.id)::text)))
  WHERE (dh_collars.id IS NULL)
  ORDER BY dh_litho.id;


ALTER TABLE tetes_passes_ouvrages_dans_passes_pas_dans_tetes_dh_litho OWNER TO pierre;

--
-- Name: tetes_passes_ouvrages_dans_passes_pas_dans_tetes_dh_sampling; Type: VIEW; Schema: checks; Owner: pierre
--

CREATE VIEW tetes_passes_ouvrages_dans_passes_pas_dans_tetes_dh_sampling AS
 SELECT DISTINCT tmp.dh_sampling_id
   FROM ( SELECT dh_collars.id,
            dh_sampling.id AS dh_sampling_id
           FROM (pierre.dh_collars
             RIGHT JOIN pierre.dh_sampling ON (((dh_collars.id)::text = (dh_sampling.id)::text)))
          WHERE (dh_collars.id IS NULL)
          ORDER BY dh_sampling.id) tmp;


ALTER TABLE tetes_passes_ouvrages_dans_passes_pas_dans_tetes_dh_sampling OWNER TO pierre;

--
-- Name: tetes_passes_ouvrages_dans_tetes_pas_dans_passes_dh_litho; Type: VIEW; Schema: checks; Owner: pierre
--

CREATE VIEW tetes_passes_ouvrages_dans_tetes_pas_dans_passes_dh_litho AS
 SELECT dh_collars.id AS collars_id_without_litho,
    dh_litho.id AS litho_id_nulls
   FROM (pierre.dh_collars
     LEFT JOIN pierre.dh_litho ON (((dh_collars.id)::text = (dh_litho.id)::text)))
  WHERE (dh_litho.id IS NULL)
  ORDER BY dh_collars.id;


ALTER TABLE tetes_passes_ouvrages_dans_tetes_pas_dans_passes_dh_litho OWNER TO pierre;

--
-- Name: tetes_passes_ouvrages_dans_tetes_pas_dans_passes_dh_sampling; Type: VIEW; Schema: checks; Owner: pierre
--

CREATE VIEW tetes_passes_ouvrages_dans_tetes_pas_dans_passes_dh_sampling AS
 SELECT dh_collars.id AS collars_id_without_samples,
    dh_sampling.id AS samples_id_nulls
   FROM (pierre.dh_collars
     LEFT JOIN pierre.dh_sampling ON (((dh_collars.id)::text = (dh_sampling.id)::text)))
  WHERE (dh_sampling.id IS NULL)
  ORDER BY dh_collars.id;


ALTER TABLE tetes_passes_ouvrages_dans_tetes_pas_dans_passes_dh_sampling OWNER TO pierre;


}}}
-- @#TODO vues pour GDM: à voir plus tard:{{{

SET search_path = gdm, pg_catalog;

--
-- Name: gdm_selection; Type: VIEW; Schema: gdm; Owner: pierre
--

CREATE VIEW gdm_selection AS
 SELECT dh_collars.opid,
    dh_collars.id
   FROM (public.dh_collars
     JOIN public.operation_active ON ((dh_collars.opid = operation_active.opid)))
  WHERE (NOT ((dh_collars.x < (1000)::numeric) OR (dh_collars.y < (10000)::numeric)));


ALTER TABLE gdm_selection OWNER TO pierre;





SET search_path = gdm, pg_catalog;

--
-- Name: gdm_dh_devia; Type: VIEW; Schema: gdm; Owner: pierre
--

CREATE VIEW gdm_dh_devia AS
 SELECT dh_collars.id,
    dh_collars.x,
    dh_collars.y,
    dh_collars.z,
    dh_collars.length,
    dh_collars.azim_ng AS azim_ng_collar,
    dh_collars.dip_hz AS dip_collar,
    dh_collars.length AS depto,
    dh_collars.azim_ng,
    dh_collars.dip_hz
   FROM (pierre.dh_collars
     JOIN gdm_selection ON (((gdm_selection.opid = dh_collars.opid) AND ((gdm_selection.id)::text = (dh_collars.id)::text))))
  WHERE (NOT ((dh_collars.id)::text IN ( SELECT DISTINCT dh_devia.id
           FROM pierre.dh_devia
          WHERE ((dh_devia.depto > (0)::numeric) AND dh_devia.valid))))
UNION
 SELECT dh_devia.id,
    dh_collars.x,
    dh_collars.y,
    dh_collars.z,
    dh_collars.length,
    dh_collars.azim_ng AS azim_ng_collar,
    dh_collars.dip_hz AS dip_collar,
    dh_devia.depto,
    dh_devia.azim_ng,
    dh_devia.dip_hz
   FROM ((pierre.dh_collars
     JOIN gdm_selection ON (((gdm_selection.opid = dh_collars.opid) AND ((gdm_selection.id)::text = (dh_collars.id)::text))))
     JOIN pierre.dh_devia ON (((dh_collars.opid = dh_devia.opid) AND ((dh_collars.id)::text = (dh_devia.id)::text))))
  WHERE ((((dh_devia.azim_ng IS NOT NULL) AND (dh_devia.dip_hz IS NOT NULL)) AND (dh_devia.depto > (0)::numeric)) AND (dh_devia.valid OR (dh_devia.valid IS NULL)))
  ORDER BY 1, 8;


ALTER TABLE gdm_dh_devia OWNER TO pierre;










SET search_path = gdm, pg_catalog;

--
-- Name: gdm_sections_array; Type: VIEW; Schema: gdm; Owner: pierre
--

CREATE VIEW gdm_sections_array AS
 SELECT sections_array.id,
    sections_array.opid,
    sections_array.location,
    sections_array.title,
    sections_array.srid,
    sections_array.x1,
    sections_array.y1,
    sections_array.z1,
    sections_array.length,
    sections_array.x2,
    sections_array.y2,
    sections_array.z2,
    sections_array.num
   FROM pierre.sections_array
  WHERE (sections_array.opid IN ( SELECT DISTINCT gdm_selection.opid
           FROM gdm_selection))
  ORDER BY sections_array.id;


ALTER TABLE gdm_sections_array OWNER TO pierre;



}}}
-- @#TODO poubelle (à moins que GDM ne s'en serve??):{{{

--
-- Name: dh_collars_; Type: VIEW; Schema: pierre; Owner: pierre
--

CREATE VIEW dh_collars_ AS
 SELECT dh_collars.id,
    dh_collars.shid,
    dh_collars.location,
    dh_collars.profile,
    dh_collars.srid,
    dh_collars.x,
    dh_collars.y,
    dh_collars.z,
    dh_collars.azim_ng,
    dh_collars.azim_nm,
    dh_collars.dip_hz,
    dh_collars.dh_type,
    dh_collars.date_start,
    dh_collars.contractor,
    dh_collars.geologist,
    dh_collars.length,
    0 AS len_destr,
    0 AS len_pq,
    0 AS len_hq,
    0 AS len_nq,
    0 AS len_bq,
    dh_collars.nb_samples,
    dh_collars.comments,
    dh_collars.completed,
    dh_collars.datasource,
    dh_collars.numauto,
    dh_collars.date_completed,
    dh_collars.opid,
    dh_collars.purpose,
    dh_collars.x_local,
    dh_collars.y_local,
    dh_collars.z_local
   FROM (dh_collars
     JOIN public.operation_active ON ((dh_collars.opid = operation_active.opid)));
ALTER TABLE dh_collars_ OWNER TO pierre;


}}}
-- @#TODO vues géographiques: à voir plus tard aussi:{{{

--
-- Name: dh_collars_points; Type: VIEW; Schema: pierre; Owner: pierre
--

CREATE VIEW dh_collars_points AS
 SELECT dh_collars.id,
    dh_collars.shid,
    dh_collars.location,
    dh_collars.profile,
    dh_collars.srid,
    dh_collars.x,
    dh_collars.y,
    dh_collars.z,
    dh_collars.azim_ng,
    dh_collars.azim_nm,
    dh_collars.dip_hz,
    dh_collars.dh_type,
    dh_collars.date_start,
    dh_collars.contractor,
    dh_collars.geologist,
    dh_collars.length,
    dh_collars.nb_samples,
    dh_collars.comments,
    dh_collars.completed,
    dh_collars.numauto,
    dh_collars.date_completed,
    dh_collars.opid,
    dh_collars.purpose,
    dh_collars.x_local,
    dh_collars.y_local,
    dh_collars.z_local,
    dh_collars.accusum,
    dh_collars.id_pject,
    dh_collars.x_pject,
    dh_collars.y_pject,
    dh_collars.z_pject,
    dh_collars.topo_survey_type,
    dh_collars.creation_ts,
    dh_collars.username,
    dh_collars.datasource,
    public.geomfromewkt((((((((('SRID='::text || dh_collars.srid) || ';POINT('::text) || dh_collars.x) || ' '::text) || dh_collars.y) || ' '::text) || dh_collars.z) || ')'::text)) AS geomfromewkt
   FROM dh_collars;


ALTER TABLE dh_collars_points OWNER TO pierre;





CREATE VIEW dh_collars_diff_project_actual_line AS
 SELECT dh_collars.id,
    dh_collars.shid,
    dh_collars.location,
    dh_collars.profile,
    dh_collars.srid,
    dh_collars.x,
    dh_collars.y,
    dh_collars.z,
    dh_collars.azim_ng,
    dh_collars.azim_nm,
    dh_collars.dip_hz,
    dh_collars.dh_type,
    dh_collars.date_start,
    dh_collars.contractor,
    dh_collars.geologist,
    dh_collars.length,
    dh_collars.nb_samples,
    dh_collars.comments,
    dh_collars.completed,
    dh_collars.numauto,
    dh_collars.date_completed,
    dh_collars.opid,
    dh_collars.purpose,
    dh_collars.x_local,
    dh_collars.y_local,
    dh_collars.z_local,
    dh_collars.accusum,
    dh_collars.id_pject,
    dh_collars.x_pject,
    dh_collars.y_pject,
    dh_collars.z_pject,
    dh_collars.topo_survey_type,
    dh_collars.creation_ts,
    dh_collars.username,
    dh_collars.datasource,
    public.geomfromewkt((((((((((((((('SRID='::text || dh_collars.srid) || ';LINESTRING ('::text) || dh_collars.x_pject) || ' '::text) || dh_collars.y_pject) || ' '::text) || dh_collars.z_pject) || ', '::text) || dh_collars.x) || ' '::text) || dh_collars.y) || ' '::text) || dh_collars.z) || ')'::text)) AS geomfromewkt
   FROM dh_collars
  WHERE (((dh_collars.x_pject IS NOT NULL) AND (dh_collars.y_pject IS NOT NULL)) AND (dh_collars.z_pject IS NOT NULL));


ALTER TABLE dh_collars_diff_project_actual_line OWNER TO pierre;




--
-- Name: dh_collars_points_last_ana_results; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW dh_collars_points_last_ana_results AS
 SELECT dh_collars_points.id,
    dh_collars_points.shid,
    dh_collars_points.location,
    dh_collars_points.profile,
    dh_collars_points.srid,
    dh_collars_points.x,
    dh_collars_points.y,
    dh_collars_points.z,
    dh_collars_points.azim_ng,
    dh_collars_points.azim_nm,
    dh_collars_points.dip_hz,
    dh_collars_points.dh_type,
    dh_collars_points.date_start,
    dh_collars_points.contractor,
    dh_collars_points.geologist,
    dh_collars_points.length,
    dh_collars_points.nb_samples,
    dh_collars_points.comments,
    dh_collars_points.completed,
    dh_collars_points.numauto,
    dh_collars_points.date_completed,
    dh_collars_points.opid,
    dh_collars_points.purpose,
    dh_collars_points.x_local,
    dh_collars_points.y_local,
    dh_collars_points.z_local,
    dh_collars_points.accusum,
    dh_collars_points.id_pject,
    dh_collars_points.x_pject,
    dh_collars_points.y_pject,
    dh_collars_points.z_pject,
    dh_collars_points.topo_survey_type,
    dh_collars_points.creation_ts,
    dh_collars_points.username,
    dh_collars_points.datasource,
    dh_collars_points.geomfromewkt
   FROM dh_collars_points
  WHERE ((dh_collars_points.id)::text IN ( SELECT DISTINCT dh_sampling_grades.id
           FROM dh_sampling_grades
          WHERE ((dh_sampling_grades.sample_id)::text IN ( SELECT lab_ana_results.sample_id
                   FROM lab_ana_results
                  WHERE (lab_ana_results.datasource = ( SELECT max(lab_ana_results_1.datasource) AS last_datasource
                           FROM lab_ana_results lab_ana_results_1))))))
  ORDER BY dh_collars_points.id;
ALTER TABLE dh_collars_points_last_ana_results OWNER TO pierre;


}}}

-- @#TODO des requêtes pas vraiment utiles:{{{

--
-- Name: collars_selection; Type: VIEW; Schema: pierre; Owner: pierre
--

CREATE VIEW collars_selection AS
 SELECT dh_collars_points.id,
    dh_collars_points.shid,
    dh_collars_points.location,
    dh_collars_points.profile,
    dh_collars_points.srid,
    dh_collars_points.x,
    dh_collars_points.y,
    dh_collars_points.z,
    dh_collars_points.azim_ng,
    dh_collars_points.azim_nm,
    dh_collars_points.dip_hz,
    dh_collars_points.dh_type,
    dh_collars_points.date_start,
    dh_collars_points.contractor,
    dh_collars_points.geologist,
    dh_collars_points.length,
    dh_collars_points.nb_samples,
    dh_collars_points.comments,
    dh_collars_points.completed,
    dh_collars_points.numauto,
    dh_collars_points.date_completed,
    dh_collars_points.opid,
    dh_collars_points.purpose,
    dh_collars_points.x_local,
    dh_collars_points.y_local,
    dh_collars_points.z_local,
    dh_collars_points.accusum,
    dh_collars_points.id_pject,
    dh_collars_points.x_pject,
    dh_collars_points.y_pject,
    dh_collars_points.z_pject,
    dh_collars_points.topo_survey_type,
    dh_collars_points.creation_ts,
    dh_collars_points.username,
    dh_collars_points.datasource,
    dh_collars_points.geomfromewkt
   FROM dh_collars_points
  WHERE ((dh_collars_points.id)::text = ANY (ARRAY[('DA08-650'::text)::text, ('DA08-656'::text)::text]));


ALTER TABLE collars_selection OWNER TO pierre;

CREATE VIEW dh_collars_for_gpx AS
 SELECT dh_collars_points.id AS name
   FROM dh_collars_points
  WHERE (NOT dh_collars_points.completed);


ALTER TABLE dh_collars_for_gpx OWNER TO pierre;


}}}

-- @#TODO utile???{{{

--
-- Name: tmp_xyz_marec; Type: TABLE; Schema: pierre; Owner: pierre; Tablespace: 
--
CREATE TABLE tmp_xyz_marec (
    id text,
    x_local numeric(12,3),
    y_local numeric(12,3),
    z_local numeric(12,3),
    x numeric(12,3),
    y numeric(12,3),
    z numeric(12,3)
);
ALTER TABLE tmp_xyz_marec OWNER TO pierre;




--
-- Name: toudoux_dh_sampling_grades_datasource_979; Type: TABLE; Schema: pierre; Owner: pierre; Tablespace: 
--
CREATE TABLE toudoux_dh_sampling_grades_datasource_979 (
    id text,
    depfrom numeric(10,2),
    depto numeric(10,2),
    core_loss_cm numeric(5,1),
    weight_kg numeric(6,2),
    sample_type text,
    sample_id text,
    comments text,
    opid integer,
    batch_id integer,
    datasource integer,
    au1_ppm numeric(8,3),
    au2_ppm numeric(8,3),
    au3_ppm numeric(8,3),
    au4_ppm numeric(8,3),
    au5_ppm numeric(8,3),
    au6_ppm numeric(8,3),
    ph numeric(4,2),
    ag_ppm numeric(8,3),
    al_perc numeric(8,3),
    as_ppm numeric(8,3),
    ba_ppm numeric(8,3),
    bi_ppm numeric(8,3),
    ca_perc numeric(8,3),
    cd_ppm numeric(8,3),
    co_ppm numeric(8,3),
    cr_ppm numeric(8,3),
    cu_perc numeric,
    fe_perc numeric(8,3),
    ga_ppm numeric(8,3),
    k_perc numeric(8,3),
    la_ppm numeric(8,3),
    li_ppm numeric(8,3),
    mg_perc numeric(8,3),
    mn_ppm numeric(8,3),
    moisture numeric(8,4),
    mo_ppm numeric(8,3),
    na_perc numeric(8,3),
    nb_ppm numeric(8,3),
    ni_ppm numeric(8,3),
    pb_perc numeric,
    sb_ppm numeric(8,3),
    sc_ppm numeric(8,3),
    se_ppm numeric(8,3),
    sn_ppm numeric(8,3),
    sr_ppm numeric(8,3),
    ta_ppm numeric(8,3),
    te_ppm numeric(8,3),
    ti_perc numeric(8,3),
    v_ppm numeric(8,3),
    w_ppm numeric(8,3),
    y_ppm numeric(8,3),
    zn_perc numeric,
    numauto integer,
    th_ppm numeric,
    tl_ppm numeric,
    u_ppm numeric
);
ALTER TABLE toudoux_dh_sampling_grades_datasource_979 OWNER TO pierre;

--
-- Name: tt_bdexplo_lex_datasource_autan; Type: TABLE; Schema: pierre; Owner: pierre; Tablespace: 
--
CREATE TABLE tt_bdexplo_lex_datasource_autan (
    opid integer,
    filename text,
    comments text,
    datasource_id integer
);
ALTER TABLE tt_bdexplo_lex_datasource_autan OWNER TO pierre;

--
-- Name: tt_bdexplo_lex_labo_analysis_autan; Type: TABLE; Schema: pierre; Owner: pierre; Tablespace: 
--
CREATE TABLE tt_bdexplo_lex_labo_analysis_autan (
    lab_id text,
    description text,
    opid integer,
    numauto integer
);
ALTER TABLE tt_bdexplo_lex_labo_analysis_autan OWNER TO pierre;



--
-- Name: occurrences_recup_depuis_dump; Type: TABLE; Schema: public; Owner: data_admin; Tablespace: 
--
CREATE TABLE occurrences_recup_depuis_dump (
    numauto integer,
    name text,
    status text,
    description text,
    w_done text,
    w_todo text,
    geom geometry,
    code text,
    opid integer,
    zone text,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"(),
    datasource integer,
    comments text,
    CONSTRAINT chk_status CHECK (((status)::text = ANY (ARRAY[('OCCUR'::text)::text, ('OREB'::text)::text, ('MINE'::text)::text, ('MINED'::text)::text, ('MCO'::text)::text, ('DISTRICT'::text)::text]))),
    CONSTRAINT enforce_geotype_geom CHECK (((geometrytype(geom) = 'POINT'::text) OR (geom IS NULL)))
);
ALTER TABLE occurrences_recup_depuis_dump OWNER TO data_admin;
COMMENT ON TABLE occurrences_recup_depuis_dump IS 'Occurences table: targets, mines, showings, deposits, mines. Compiled from various tables, and updated.';
COMMENT ON COLUMN occurrences_recup_depuis_dump.numauto IS 'Automatic integer primary key';
COMMENT ON COLUMN occurrences_recup_depuis_dump.name IS 'Occurence name';
COMMENT ON COLUMN occurrences_recup_depuis_dump.status IS 'Status: OCCUR = occurence ; OREB = orebody ; MINE = active mine ; MINED = exploited, depleted mine';
COMMENT ON COLUMN occurrences_recup_depuis_dump.description IS 'Occurence description: geological context, significant figures at current stage of exploration or exploitation';
COMMENT ON COLUMN occurrences_recup_depuis_dump.w_done IS 'Exploration work done, codified field: PROSPection (rock sampling on surface), SOIL geochemistry, MAPping, DECAPage, TRenches, Drill Holes';
COMMENT ON COLUMN occurrences_recup_depuis_dump.w_todo IS 'Exploration work to be done, codified field: PROSPection (rock sampling on surface), SOIL geochemistry, MAPping, DECAPage, TRenches, Drill Holes';
COMMENT ON COLUMN occurrences_recup_depuis_dump.opid IS 'Operation identifier';
COMMENT ON COLUMN occurrences_recup_depuis_dump.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN occurrences_recup_depuis_dump.username IS 'User (role) which created data record';
COMMENT ON COLUMN occurrences_recup_depuis_dump.datasource IS 'Datasource identifier, refers to lex_datasource';



SET search_path = tmp_a_traiter, pg_catalog;
--
-- Name: bondoukou_alain_lambert_acp; Type: TABLE; Schema: tmp_a_traiter; Owner: pierre; Tablespace: 
--
CREATE TABLE bondoukou_alain_lambert_acp (
    indr integer,
    xxxx double precision,
    yyyy double precision,
    f1 double precision,
    f2 double precision,
    f3 double precision,
    f4 double precision
);
ALTER TABLE bondoukou_alain_lambert_acp OWNER TO pierre;
CREATE TABLE bondoukou_alain_lambert_au_ou_icp (
    indr integer,
    xxxx double precision,
    yyyy double precision,
    anal integer
);
ALTER TABLE bondoukou_alain_lambert_au_ou_icp OWNER TO pierre;
CREATE TABLE bondoukou_alain_lambert_cah (
    indr integer,
    cah1 double precision,
    x double precision,
    y double precision,
    gdm1 double precision,
    gdm2 double precision,
    num__ro bigint
);
ALTER TABLE bondoukou_alain_lambert_cah OWNER TO pierre;
CREATE TABLE bondoukou_alain_lambert_cah7 (
    indr integer,
    cah7 double precision,
    gdm1 double precision,
    x double precision,
    y double precision
);
ALTER TABLE bondoukou_alain_lambert_cah7 OWNER TO pierre;
CREATE TABLE bondoukou_alain_lambert_coor (
    xxxx double precision,
    yyyy double precision,
    indr integer,
    numauto integer NOT NULL
);
ALTER TABLE bondoukou_alain_lambert_coor OWNER TO pierre;
CREATE TABLE bondoukou_alain_lambert_coor_icp (
    indr integer,
    xxxx double precision,
    yyyy double precision,
    sio2 double precision,
    al2o3 double precision,
    fe2o3 double precision,
    cao double precision,
    mgo double precision,
    k2o double precision,
    mno double precision,
    tio2 double precision,
    p2o5 double precision,
    li double precision,
    be double precision,
    b double precision,
    v double precision,
    cr double precision,
    co double precision,
    ni double precision,
    cu double precision,
    zn double precision,
    "As" double precision,
    sr double precision,
    y double precision,
    nb double precision,
    mo double precision,
    ag double precision,
    cd double precision,
    sn double precision,
    sb double precision,
    ba double precision,
    la double precision,
    ce double precision,
    w double precision,
    bi double precision,
    zr double precision,
    pb double precision,
    cah1 bigint
);
ALTER TABLE bondoukou_alain_lambert_coor_icp OWNER TO pierre;



ALTER TABLE bondoukou_alain_lambert_tarkw_cah_3 OWNER TO pierre;
--
-- Name: bondoukou_alain_lambert_tout; Type: TABLE; Schema: tmp_a_traiter; Owner: pierre; Tablespace: 
--
CREATE TABLE bondoukou_alain_lambert_tout (
    indr integer,
    xxxx double precision,
    yyyy double precision,
    zzzz double precision,
    au double precision,
    au_m double precision,
    si double precision,
    al double precision,
    fe double precision,
    ca double precision,
    mg double precision,
    k double precision,
    mn double precision,
    ti double precision,
    p double precision,
    li double precision,
    be double precision,
    b double precision,
    v double precision,
    cr double precision,
    co double precision,
    ni double precision,
    cu double precision,
    zn double precision,
    "As" double precision,
    sr double precision,
    y double precision,
    nb double precision,
    mo double precision,
    ag double precision,
    cd double precision,
    sn double precision,
    sb double precision,
    ba double precision,
    la double precision,
    ce double precision,
    w double precision,
    pb double precision,
    bi double precision,
    zr double precision,
    anal text
);
ALTER TABLE bondoukou_alain_lambert_tout OWNER TO pierre;
--
-- Name: bondoukou_alain_lambert_vx_tvx; Type: TABLE; Schema: tmp_a_traiter; Owner: pierre; Tablespace: 
--
CREATE TABLE bondoukou_alain_lambert_vx_tvx (
    num bigint,
    y double precision,
    x double precision,
    numauto integer NOT NULL
);
ALTER TABLE bondoukou_alain_lambert_vx_tvx OWNER TO pierre;



CREATE TABLE soil_geoch_bondoukou (
    zone text,
    ligne text,
    station text,
    nech text,
    x numeric,
    y numeric,
    z numeric,
    au_ppb numeric,
    prof_cm numeric,
    cod_sol text,
    couleur text,
    alteration text,
    litho text,
    description_sol text,
    occ_sol text,
    topo text,
    pente text,
    direction_pente text,
    commentaire text,
    mapinfo_id text,
    numauto integer NOT NULL,
    opid integer
);
ALTER TABLE soil_geoch_bondoukou OWNER TO pierre;





--
-- Name: bondoukou_alain_lambert_or; Type: TABLE; Schema: tmp_a_traiter; Owner: pierre; Tablespace: 
--
CREATE TABLE bondoukou_alain_lambert_or (
    indr integer,
    xxxx double precision,
    yyyy double precision,
    au integer,
    au_m integer
);
ALTER TABLE bondoukou_alain_lambert_or OWNER TO pierre;
--
-- Name: bondoukou_alain_lambert_tarkw_cah_3; Type: TABLE; Schema: tmp_a_traiter; Owner: pierre; Tablespace: 
--
CREATE TABLE bondoukou_alain_lambert_tarkw_cah_3 (
    indr text,
    x double precision,
    y double precision,
    gdm1 double precision,
    _3gr double precision
);




CREATE TABLE tmp_auramines_feb_march_sample_list_xlsx_01_main_list (
    sample_id text,
    latitude text,
    longitude text,
    area_name text,
    block text,
    type text,
    description text,
    mass_kg text,
    photo text,
    mass_duplicate_kg text,
    comments text
);
ALTER TABLE tmp_auramines_feb_march_sample_list_xlsx_01_main_list OWNER TO pierre;
CREATE TABLE tmp_auramines_feb_march_sample_list_xlsx_02_dhl_ireland (
    seq text,
    sample_id text,
    weight_kg text
);
ALTER TABLE tmp_auramines_feb_march_sample_list_xlsx_02_dhl_ireland OWNER TO pierre;
CREATE TABLE tmp_auramines_feb_march_sample_list_xlsx_03_dhl_france (
    seq text,
    sample_id text,
    weight_kg text,
    comments text
);
ALTER TABLE tmp_auramines_feb_march_sample_list_xlsx_03_dhl_france OWNER TO pierre;
CREATE TABLE tmp_auramines_feb_march_sample_list_xlsx_04_sheet_for_omac (
    bag text,
    seq text,
    sample_id text,
    weight_kg text,
    prep_31b text,
    au_icp21 text,
    me_icp41 text,
    me_xrf26 text,
    comments text
);
--
-- Name: tmp_auramines_field_observations; Type: TABLE; Schema: tmp_a_traiter; Owner: pierre; Tablespace: 
--
CREATE TABLE tmp_auramines_field_observations (
    opid text,
    year text,
    obs_id text,
    date text,
    waypoint_name text,
    x text,
    y text,
    z text,
    description text,
    code_litho text,
    code_unit text,
    srid text,
    geologist text,
    icon_descr text,
    comments text,
    sample_id text,
    datasource text,
    numauto text,
    photos text,
    audio text,
    timestamp_epoch_ms text,
    creation_ts text,
    username text,
    device text,
    "time" text
);
ALTER TABLE tmp_auramines_field_observations OWNER TO pierre;

--
-- Name: tmp_bondoukou_geoch_sol; Type: TABLE; Schema: tmp_a_traiter; Owner: pierre; Tablespace: 
--
CREATE TABLE tmp_bondoukou_geoch_sol (
    grid_line text,
    grid_station text,
    sample_id text,
    au_ppb numeric,
    depth_cm numeric,
    soil_code text,
    soil_color text,
    alteration text,
    litho text,
    soil_description text,
    soil_occ text,
    topo text,
    slope text,
    slope_dir text,
    comments text,
    zone text,
    x numeric,
    y numeric,
    mapinfo_id numeric,
    z numeric
);
ALTER TABLE tmp_bondoukou_geoch_sol OWNER TO pierre;
--
-- Name: tmp_bondoukou_sondages_collars; Type: TABLE; Schema: tmp_a_traiter; Owner: pierre; Tablespace: 
CREATE TABLE tmp_bondoukou_sondages_collars (
    datasource text,
    lieu_projet text,
    date text,
    geologue text,
    type text,
    holeid text,
    easting numeric,
    northing numeric,
    rl numeric,
    azimuth numeric,
    dip numeric,
    totdepth numeric
);
ALTER TABLE tmp_bondoukou_sondages_collars OWNER TO pierre;
--
-- Name: tmp_bondoukou_sondages_sampling_grades; Type: TABLE; Schema: tmp_a_traiter; Owner: pierre; Tablespace: 
--
CREATE TABLE tmp_bondoukou_sondages_sampling_grades (
    datasource text,
    holeid text,
    depfrom numeric,
    depto numeric,
    length numeric,
    sample_id text,
    au_gt numeric
);
ALTER TABLE tmp_bondoukou_sondages_sampling_grades OWNER TO pierre;

--
-- Name: tmp_bv130613_gravi_results; Type: TABLE; Schema: tmp_a_traiter; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_bv130613_gravi_results (
    a text,
    b text,
    c text
);


ALTER TABLE tmp_bv130613_gravi_results OWNER TO pierre;

SET search_path = tmp_imports, pg_catalog;

--
-- Name: tmp_cme_sampling_grades_150102_utf8; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_cme_sampling_grades_150102_utf8 (
    hole_id text,
    sample_id text,
    sample_type text,
    depth_from text,
    depth_to text,
    au_ppm text,
    core_loss_m text,
    weight_kg text,
    comments text,
    opid text
);


ALTER TABLE tmp_cme_sampling_grades_150102_utf8 OWNER TO pierre;




--
-- Name: orientation; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--
CREATE TABLE orientation (
    _id numeric,
    poi_id numeric,
    orientationtype text,
    rot1 numeric,
    rot2 numeric,
    rot3 numeric,
    rot4 numeric,
    rot5 numeric,
    rot6 numeric,
    rot7 numeric,
    rot8 numeric,
    rot9 numeric,
    v1 numeric,
    v2 numeric,
    v3 numeric
);






--
-- Name: poi; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE poi (
    _id numeric,
    poiname text,
    poitime numeric,
    elevation numeric,
    poilat numeric,
    poilon numeric,
    photourl text,
    audiourl text,
    note text
);
ALTER TABLE poi OWNER TO pierre;

--
-- Name: tmp_assay_results_auramines_ns30n; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_assay_results_auramines_ns30n (
    batch_id text,
    sample_id text,
    pass2mm_pc text,
    pass75um_pc text,
    ag_ppm text,
    al_pc text,
    as_ppm text,
    b_ppm text,
    ba_ppm text,
    be_ppm text,
    bi_ppm text,
    ca_pc text,
    cd_ppm text,
    co_ppm text,
    cr_ppm text,
    cu_ppm text,
    fe_pc text,
    ga_ppm text,
    hg_ppm text,
    k_pc text,
    la_ppm text,
    mg_pc text,
    mn_ppm text,
    mo_ppm text,
    na_pc text,
    ni_ppm text,
    p_ppm text,
    pb_ppm text,
    s_pc text,
    sb_ppm text,
    sc_ppm text,
    sr_ppm text,
    th_ppm text,
    ti_pc text,
    tl_ppm text,
    u_ppm text,
    v_ppm text,
    w_ppm text,
    zn_ppm text,
    au_inf180um_ppm text,
    au_sup180um_ppm text,
    wt_inf180um_g text,
    wt_sup180um_g text
);


ALTER TABLE tmp_assay_results_auramines_ns30n OWNER TO pierre;

--
-- Name: tmp_auramines_feb_march_sample_list_xlsx_01_main_list_points; Type: VIEW; Schema: tmp_imports; Owner: pierre
--

CREATE VIEW tmp_auramines_feb_march_sample_list_xlsx_01_main_list_points AS
 SELECT tmp_auramines_feb_march_sample_list_xlsx_01_main_list.sample_id,
    tmp_auramines_feb_march_sample_list_xlsx_01_main_list.latitude,
    tmp_auramines_feb_march_sample_list_xlsx_01_main_list.longitude,
    tmp_auramines_feb_march_sample_list_xlsx_01_main_list.area_name,
    tmp_auramines_feb_march_sample_list_xlsx_01_main_list.block,
    tmp_auramines_feb_march_sample_list_xlsx_01_main_list.type,
    tmp_auramines_feb_march_sample_list_xlsx_01_main_list.description,
    tmp_auramines_feb_march_sample_list_xlsx_01_main_list.mass_kg,
    tmp_auramines_feb_march_sample_list_xlsx_01_main_list.photo,
    tmp_auramines_feb_march_sample_list_xlsx_01_main_list.mass_duplicate_kg,
    tmp_auramines_feb_march_sample_list_xlsx_01_main_list.comments,
    public.geomfromewkt((((('SRID=4326 ;POINT ('::text || (tmp_auramines_feb_march_sample_list_xlsx_01_main_list.longitude)::text) || ' '::text) || (tmp_auramines_feb_march_sample_list_xlsx_01_main_list.latitude)::text) || ')'::text)) AS geomfromewkt
   FROM tmp_a_traiter.tmp_auramines_feb_march_sample_list_xlsx_01_main_list;


ALTER TABLE tmp_auramines_feb_march_sample_list_xlsx_01_main_list_points OWNER TO pierre;

--
-- Name: tmp_cme_sampling_grades_150102; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_cme_sampling_grades_150102 (
    hole_id text,
    sample_id text,
    sample_type text,
    depth_from text,
    depth_to text,
    au_ppm text,
    core_loss_m text,
    weight_kg text,
    comments text,
    opid text
);


ALTER TABLE tmp_cme_sampling_grades_150102 OWNER TO pierre;

--
-- Name: tmp_collars_141027_utf8; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_collars_141027_utf8 (
    hole_id text,
    id_pj text,
    location text,
    profil text,
    x text,
    y text,
    z text,
    dh_type text,
    azim_ng text,
    azim_nm text,
    dip_hz text,
    length text,
    date_start text,
    contractor text,
    geologist text,
    nb_samples text,
    comments text,
    completed text,
    date_completed text,
    opid text,
    priorite text,
    purpose text,
    accusum text,
    x_pj text,
    y_pj text,
    z_pj text,
    projection text
);


ALTER TABLE tmp_collars_141027_utf8 OWNER TO pierre;

--
-- Name: tmp_collars_141223; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_collars_141223 (
    hole_id text,
    id_pj text,
    location text,
    profil text,
    x text,
    y text,
    z text,
    dh_type text,
    azim_ng text,
    azim_nm text,
    dip_hz text,
    length text,
    date_start text,
    contractor text,
    geologist text,
    nb_samples text,
    comments text,
    completed text,
    date_completed text,
    opid text,
    priorite text,
    purpose text,
    accusum text,
    x_pj text,
    y_pj text,
    z_pj text,
    projection text
);


ALTER TABLE tmp_collars_141223 OWNER TO pierre;

--
-- Name: tmp_collars_141223_utf8; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_collars_141223_utf8 (
    hole_id text,
    id_pj text,
    location text,
    profil text,
    x text,
    y text,
    z text,
    dh_type text,
    azim_ng text,
    azim_nm text,
    dip_hz text,
    length text,
    date_start text,
    contractor text,
    geologist text,
    nb_samples text,
    comments text,
    completed text,
    date_completed text,
    opid text,
    priorite text,
    purpose text,
    accusum text,
    x_pj text,
    y_pj text,
    z_pj text,
    projection text
);


ALTER TABLE tmp_collars_141223_utf8 OWNER TO pierre;

--
-- Name: tmp_entree_donnees_dh_tech; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_entree_donnees_dh_tech (
    id text,
    depfrom text,
    depto text,
    drillers_depto text,
    reco_len text,
    core_loss_cm text,
    diam text,
    rqd_len text,
    nb_joints text,
    joints_descript text,
    comments text,
    core_loss_chk text,
    percent_reco text,
    percent_rqd text,
    stick_cm text
);


ALTER TABLE tmp_entree_donnees_dh_tech OWNER TO pierre;

--
-- Name: tmp_erreur_z; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_erreur_z (
    id text,
    z_orig text,
    z_proj text
);


ALTER TABLE tmp_erreur_z OWNER TO pierre;

--
-- Name: tmp_esp_pgm_cr_140908_; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_esp_pgm_cr_140908_ (
    hole_id text,
    location text,
    x text,
    y text,
    z text,
    dh_type text,
    azim_ng text,
    dip_hz text,
    length text,
    priorite text,
    purpose text,
    projection text
);


ALTER TABLE tmp_esp_pgm_cr_140908_ OWNER TO pierre;

--
-- Name: tmp_export_geolpda_waypoints_descriptions; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_export_geolpda_waypoints_descriptions (
    opid text,
    year text,
    index text,
    obs_id text,
    waypoint_name text,
    x text,
    y text,
    z text,
    description text,
    srid text,
    geologist text,
    datasource text
);


ALTER TABLE tmp_export_geolpda_waypoints_descriptions OWNER TO pierre;

--
-- Name: tmp_ext1; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_ext1 (
    id text,
    azim_ng_collar text,
    dip_collar text,
    x text,
    y text,
    z text,
    depto text,
    azim_ng text,
    dip_hz text,
    xxxx text,
    yyyy text,
    zzzz text
);


ALTER TABLE tmp_ext1 OWNER TO pierre;

--
-- Name: tmp_ext2; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_ext2 (
    id text,
    azim_ng text,
    dip_hz text,
    length text,
    location text,
    x text,
    y text,
    z text,
    depfrom text,
    depto text,
    value1 text,
    value2 text,
    value3 text,
    value4 text,
    code1 text,
    code2 text,
    code3 text,
    code4 text,
    description_1 text,
    description_2 text,
    xxxx text,
    yyyy text,
    zzzz text
);


ALTER TABLE tmp_ext2 OWNER TO pierre;

--
-- Name: tmp_ext3; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_ext3 (
    id text,
    length text,
    x text,
    y text,
    z text,
    depfrom text,
    depto text,
    au1_ppm text,
    au2_ppm text,
    au3_ppm text,
    au4_ppm text,
    au5_ppm text,
    au6_ppm text,
    xxxx text,
    yyyy text,
    zzzz text
);


ALTER TABLE tmp_ext3 OWNER TO pierre;

--
-- Name: tmp_ext4; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_ext4 (
    id text,
    length text,
    x text,
    y text,
    z text,
    depfrom text,
    depto text,
    au1_ppm text,
    au2_ppm text,
    au3_ppm text,
    au4_ppm text,
    au5_ppm text,
    au6_ppm text,
    xxxx text,
    yyyy text,
    zzzz text
);


ALTER TABLE tmp_ext4 OWNER TO pierre;

--
-- Name: tmp_ext5; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_ext5 (
    id text,
    azim_ng text,
    dip_hz text,
    length text,
    location_1 text,
    location_2 text,
    completed text,
    comments_3 text,
    comments_4 text,
    x text,
    y text,
    z text,
    depto text,
    xxxx text,
    yyyy text,
    zzzz text
);


ALTER TABLE tmp_ext5 OWNER TO pierre;

--
-- Name: tmp_ext6; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_ext6 (
    id text,
    azim_ng text,
    dip_hz text,
    length text,
    x text,
    y text,
    z text,
    depfrom text,
    depto text,
    avau text,
    accu text,
    dens text,
    recu text,
    stva_1 text,
    stva_2 text,
    comments text,
    xxxx text,
    yyyy text,
    zzzz text
);


ALTER TABLE tmp_ext6 OWNER TO pierre;

--
-- Name: tmp_ext7; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_ext7 (
    id text,
    azim_ng text,
    dip_hz text,
    length text,
    x text,
    y text,
    z text,
    depfrom text,
    depto text,
    avau text,
    accu text,
    dens text,
    recu text,
    stva_1 text,
    stva_2 text,
    comments text,
    xxxx text,
    yyyy text,
    zzzz text
);


ALTER TABLE tmp_ext7 OWNER TO pierre;

--
-- Name: tmp_field_observations_struct_measures; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_field_observations_struct_measures (
    numauto text,
    opid text,
    obs_id text,
    measure_type text,
    structure_type text,
    north_ref text,
    direction text,
    dip text,
    dip_quadrant text,
    pitch text,
    pitch_quadrant text,
    movement text,
    valid text,
    comments text,
    description text
);


ALTER TABLE tmp_field_observations_struct_measures OWNER TO pierre;

--
-- Name: tmp_geolpda_orientations; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_geolpda_orientations (
    opid text,
    obs_id text,
    geolpda_id text,
    geolpda_poi_id text,
    measure_type text,
    structure_type text,
    rotation_matrix text,
    rot1 text,
    rot2 text,
    rot3 text,
    rot4 text,
    rot5 text,
    rot6 text,
    rot7 text,
    rot8 text,
    rot9 text,
    v1 text,
    v2 text,
    v3 text,
    device text
);


ALTER TABLE tmp_geolpda_orientations OWNER TO pierre;

--
-- Name: tmp_geolpda_picks; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_geolpda_picks (
    opid text,
    year text,
    date text,
    waypoint_name text,
    obs_id text,
    timestamp_epoch_ms text,
    "timestamp" text,
    z text,
    y text,
    x text,
    photos text,
    audio text,
    description text,
    device text,
    geologist text,
    srid text
);


ALTER TABLE tmp_geolpda_picks OWNER TO pierre;

--
-- Name: tmp_ity_gpspolo_travaux_97et2004; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_ity_gpspolo_travaux_97et2004 (
    indr text,
    xutm29 text,
    yutm29 text,
    zzzz text,
    ttd text,
    azim text,
    incl text,
    zone text,
    datasource integer,
    numauto integer NOT NULL
);


ALTER TABLE tmp_ity_gpspolo_travaux_97et2004 OWNER TO pierre;


--
-- Name: tmp_lr15201855; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_lr15201855 (
    sample_id text,
    cru_qc_pass2mm_pc text,
    pul_qc_pass75um_pc text,
    ag_ppm text,
    al_pc text,
    as_ppm text,
    b_ppm text,
    ba_ppm text,
    be_ppm text,
    bi_ppm text,
    ca_pc text,
    cd_ppm text,
    co_ppm text,
    cr_ppm text,
    cu_ppm text,
    fe_pc text,
    ga_ppm text,
    hg_ppm text,
    k_pc text,
    la_ppm text,
    mg_pc text,
    mn_ppm text,
    mo_ppm text,
    na_pc text,
    ni_ppm text,
    p_ppm text,
    pb_ppm text,
    s_pc text,
    sb_ppm text,
    sc_ppm text,
    sr_ppm text,
    th_ppm text,
    ti_pc text,
    tl_ppm text,
    u_ppm text,
    v_ppm text,
    w_ppm text,
    zn_ppm text,
    au_ppm text
);


ALTER TABLE tmp_lr15201855 OWNER TO pierre;

--
-- Name: tmp_observations_pch_guyane_2011_2014; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_observations_pch_guyane_2011_2014 (
    opid text,
    year text,
    obs_id text,
    date text,
    waypoint_name text,
    x text,
    y text,
    z text,
    description text,
    code_litho text,
    code_unit text,
    srid text,
    geologist text,
    sample_id text
);


ALTER TABLE tmp_observations_pch_guyane_2011_2014 OWNER TO pierre;

--
-- Name: tmp_s001; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_s001 (
    id text,
    depfrom text,
    depto text,
    description text,
    code1 text,
    code2 text
);


ALTER TABLE tmp_s001 OWNER TO pierre;

--
-- Name: tmp_s001_corr; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_s001_corr (
    id text,
    depfrom text,
    depto text,
    description text,
    code1 text,
    code2 text
);


ALTER TABLE tmp_s001_corr OWNER TO pierre;

--
-- Name: tmp_s003_corr; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_s003_corr (
    id text,
    depfrom text,
    depto text,
    description text,
    code1 text,
    code2 text
);


ALTER TABLE tmp_s003_corr OWNER TO pierre;

--
-- Name: tmp_s005_corr; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_s005_corr (
    id text,
    depfrom text,
    depto text,
    description text,
    code1 text,
    code2 text
);


ALTER TABLE tmp_s005_corr OWNER TO pierre;

--
-- Name: tmp_sample_description_and_coords_november_2015_paul; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_sample_description_and_coords_november_2015_paul (
    sample_id text,
    bag_id text,
    sample_type text,
    latitude text,
    longitude text,
    elevation text,
    description text
);


ALTER TABLE tmp_sample_description_and_coords_november_2015_paul OWNER TO pierre;

--
-- Name: tmp_sample_description_and_coords_november_2015_paul_points; Type: VIEW; Schema: tmp_imports; Owner: pierre
--

CREATE VIEW tmp_sample_description_and_coords_november_2015_paul_points AS
 SELECT tmp_sample_description_and_coords_november_2015_paul.sample_id,
    tmp_sample_description_and_coords_november_2015_paul.bag_id,
    tmp_sample_description_and_coords_november_2015_paul.sample_type,
    tmp_sample_description_and_coords_november_2015_paul.latitude,
    tmp_sample_description_and_coords_november_2015_paul.longitude,
    tmp_sample_description_and_coords_november_2015_paul.elevation,
    tmp_sample_description_and_coords_november_2015_paul.description,
    public.geomfromewkt((((('SRID=4326;POINT('::text || (tmp_sample_description_and_coords_november_2015_paul.longitude)::numeric) || ' '::text) || (tmp_sample_description_and_coords_november_2015_paul.latitude)::numeric) || ')'::text)) AS geomfromewkt
   FROM tmp_sample_description_and_coords_november_2015_paul
  WHERE (((tmp_sample_description_and_coords_november_2015_paul.latitude)::text <> ''::text) OR ((tmp_sample_description_and_coords_november_2015_paul.longitude)::text <> ''::text));


ALTER TABLE tmp_sample_description_and_coords_november_2015_paul_points OWNER TO pierre;

--
-- Name: tmp_sondages_est_cavally_resume_fiche_tech; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_sondages_est_cavally_resume_fiche_tech (
    sondages text,
    xxx text,
    yyy text,
    zzz text,
    prof_m text,
    az text,
    incl text,
    secteur text,
    datasource integer
);


ALTER TABLE tmp_sondages_est_cavally_resume_fiche_tech OWNER TO pierre;

--
-- Name: tmp_sondages_est_cavally_resume_mineralisation; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_sondages_est_cavally_resume_mineralisation (
    num_sondage text,
    xx text,
    yy text,
    zz text,
    depfrom text,
    depto text,
    teneur_g_t text,
    moyenne text,
    litho text,
    datasource integer
);


ALTER TABLE tmp_sondages_est_cavally_resume_mineralisation OWNER TO pierre;

--
-- Name: tmp_surface_samples_grades; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_surface_samples_grades (
    opid text,
    sample_id text,
    x text,
    y text,
    z text,
    srid text,
    description text,
    sample_type text,
    outcrop_id text,
    trend text,
    dip text,
    length_m text,
    width_m text,
    au1_ppm text,
    au2_ppm text,
    ag1_ text,
    ag2_ text,
    cu1_ text,
    cu2_ text,
    as_ text,
    pb_ text,
    zn_ text,
    k2o_ text,
    ba_ text,
    sio2_ text,
    al2x_ text,
    fe2x_ text,
    mno_ text,
    tio2_ text,
    p2o5_ text,
    cao_ text,
    mgo_ text,
    mo_ text,
    sn_ text,
    sb_ text,
    w_ text,
    bi_ text,
    zr_ text,
    li_ text,
    b_ text,
    v_ text,
    cr_ text,
    ni_ text,
    co_ text,
    sr_ text,
    y_ text,
    la_ text,
    ce_ text,
    nb_ text,
    be_ text,
    cd_ text,
    spp2 text,
    datasource_id text
);


ALTER TABLE tmp_surface_samples_grades OWNER TO pierre;

--
-- Name: tmp_surface_sampling_141027; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_surface_sampling_141027 (
    sample_id text,
    x text,
    y text,
    z text,
    description text,
    sample_type text,
    opid text,
    comments text,
    au_ppm text,
    ag_ppm text,
    al_pct text,
    as_ppm text,
    b_ppm text,
    ba_ppm text,
    be_ppm text,
    bi_ppm text,
    ca_pct text,
    cd_ppm text,
    ce_ text,
    co_ppm text,
    cr_ppm text,
    cu_ppm text,
    fe_pct text,
    ge_ppm text,
    k_pct text,
    la_ppm text,
    li_ppm text,
    mg_pct text,
    mn_ppm text,
    mo_ppm text,
    na_pct text,
    nb_ppm text,
    ni_ppm text,
    p_pct text,
    pb_ppm text,
    s_pct text,
    sb_ppm text,
    sc_ppm text,
    se_ppm text,
    sio2_ text,
    sn_ppm text,
    sr_ppm text,
    ta_ppm text,
    te_ppm text,
    ti_ppm text,
    tl_ppm text,
    v_ppm text,
    w_ppm text,
    y_ppm text,
    zn_ppm text,
    zr_ppm text
);


ALTER TABLE tmp_surface_sampling_141027 OWNER TO pierre;

--
-- Name: tmp_surface_sampling_141027_utf8; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_surface_sampling_141027_utf8 (
    sample_id text,
    x text,
    y text,
    z text,
    description text,
    sample_type text,
    opid text,
    comments text,
    au_ppm text,
    ag_ppm text,
    al_pct text,
    as_ppm text,
    b_ppm text,
    ba_ppm text,
    be_ppm text,
    bi_ppm text,
    ca_pct text,
    cd_ppm text,
    ce_ text,
    co_ppm text,
    cr_ppm text,
    cu_ppm text,
    fe_pct text,
    ge_ppm text,
    k_pct text,
    la_ppm text,
    li_ppm text,
    mg_pct text,
    mn_ppm text,
    mo_ppm text,
    na_pct text,
    nb_ppm text,
    ni_ppm text,
    p_pct text,
    pb_ppm text,
    s_pct text,
    sb_ppm text,
    sc_ppm text,
    se_ppm text,
    sio2_ text,
    sn_ppm text,
    sr_ppm text,
    ta_ppm text,
    te_ppm text,
    ti_ppm text,
    tl_ppm text,
    v_ppm text,
    w_ppm text,
    y_ppm text,
    zn_ppm text,
    zr_ppm text
);


ALTER TABLE tmp_surface_sampling_141027_utf8 OWNER TO pierre;

--
-- Name: tmp_survey_141027; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_survey_141027 (
    hole_id text,
    depth text,
    az_ng text,
    az_nm text,
    dip_hz text,
    device text,
    comments text,
    opid text,
    numauto text
);


ALTER TABLE tmp_survey_141027 OWNER TO pierre;

--
-- Name: tmp_survey_141223; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_survey_141223 (
    hole_id text,
    depth text,
    az_ng text,
    az_nm text,
    dip_hz text,
    mag text,
    valid text,
    comments text,
    opid text,
    device text
);


ALTER TABLE tmp_survey_141223 OWNER TO pierre;

--
-- Name: tmp_tmp_dactylo_litho; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_tmp_dactylo_litho (
    id text,
    depfrom text,
    depto text,
    description text,
    code2 text,
    code1 text
);


ALTER TABLE tmp_tmp_dactylo_litho OWNER TO pierre;

--
-- Name: tmp_tmp_field_observations_struct_measures; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_tmp_field_observations_struct_measures (
    opid text,
    obs_id text,
    measure_type text,
    structure_type text,
    north_ref text,
    direction text,
    dip text,
    dip_quadrant text,
    pitch text,
    pitch_quadrant text,
    movement text,
    valid text,
    comments text,
    numauto text
);


ALTER TABLE tmp_tmp_field_observations_struct_measures OWNER TO pierre;

--
-- Name: tmp_tmp_structures; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_tmp_structures (
    id text,
    depto text,
    struct_description text
);


ALTER TABLE tmp_tmp_structures OWNER TO pierre;

--
-- Name: tmp_tt; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_tt (
    batch_id text,
    sample_id text,
    pass2mm_pc text,
    pass75um_pc text,
    ag_ppm text,
    al_pc text,
    as_ppm text,
    b_ppm text,
    ba_ppm text,
    be_ppm text,
    bi_ppm text,
    ca_pc text,
    cd_ppm text,
    co_ppm text,
    cr_ppm text,
    cu_ppm text,
    fe_pc text,
    ga_ppm text,
    hg_ppm text,
    k_pc text,
    la_ppm text,
    mg_pc text,
    mn_ppm text,
    mo_ppm text,
    na_pc text,
    ni_ppm text,
    p_ppm text,
    pb_ppm text,
    s_pc text,
    sb_ppm text,
    sc_ppm text,
    sr_ppm text,
    th_ppm text,
    ti_pc text,
    tl_ppm text,
    u_ppm text,
    v_ppm text,
    w_ppm text,
    zn_ppm text,
    au_inf180um_ppm text,
    au_sup180um_ppm text,
    wt_inf180um_g text,
    wt_sup180um_g text
);


ALTER TABLE tmp_tt OWNER TO pierre;

--
-- Name: tmp_tt_omac_sample_list_update; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_tt_omac_sample_list_update (
    seq text,
    sample_id text,
    weight_kg text
);


ALTER TABLE tmp_tt_omac_sample_list_update OWNER TO pierre;

--
-- Name: tmp_tt_pierre_nettoye_uploader_wpt; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_tt_pierre_nettoye_uploader_wpt (
    h text,
    idnt text,
    latitude text,
    longitude text,
    date text,
    "time" text,
    alt text,
    description text,
    proximity text,
    symbol text,
    lat_dd numeric,
    lon_dd numeric,
    numauto integer NOT NULL,
    year integer,
    date_iso text
);


ALTER TABLE tmp_tt_pierre_nettoye_uploader_wpt OWNER TO pierre;

--
-- Name: tmp_tt_programme_esperance; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_tt_programme_esperance (
    id text,
    x text,
    y text,
    z text,
    length text,
    azim_ng text,
    dip_hz text,
    comments text
);


ALTER TABLE tmp_tt_programme_esperance OWNER TO pierre;

--
-- Name: tmp_tt_pts_gps_mdb_copie; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_tt_pts_gps_mdb_copie (
    no text,
    idnt text,
    latitude text,
    longitude text,
    date text,
    "time" text,
    alt text,
    descriptio text,
    proximity text,
    symbol__ text,
    mapinfo_id text,
    lat_dd numeric,
    lon_dd numeric,
    numauto integer NOT NULL
);


ALTER TABLE tmp_tt_pierre_nettoye_uploader_wpt_points OWNER TO pierre;
ALTER TABLE tmp_tt_pts_gps_mdb_copie OWNER TO pierre;

ALTER TABLE tmp_tt_pts_gps_mdb_copie_points OWNER TO pierre;

--
-- Name: tmp_tt_pts_gps_mdb_fichiers; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_tt_pts_gps_mdb_fichiers (
    r text,
    datum text,
    idx text,
    da text,
    df text,
    dx text,
    dy text,
    coordinate_system text,
    no text,
    nomfichier text,
    date text,
    software_name_version text,
    taille text,
    dz text
);


ALTER TABLE tmp_tt_pts_gps_mdb_fichiers OWNER TO pierre;

--
-- Name: tmp_tt_pts_gps_mdb_fsdrg; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_tt_pts_gps_mdb_fsdrg (
    no text,
    idnt text,
    lat_ns text,
    latitude text,
    lon_eo text,
    longitude text,
    date text,
    "time" text,
    alt text,
    descriptio text,
    proximity text,
    symbol__ text,
    mapinfo_id text
);


ALTER TABLE tmp_tt_pts_gps_mdb_fsdrg OWNER TO pierre;

--
-- Name: tmp_tt_pts_gps_mdb_points_latlong; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_tt_pts_gps_mdb_points_latlong (
    idnt text,
    "time" text,
    alt text,
    descriptio text,
    symbol__ text,
    no text,
    date text,
    lat_ns text,
    lon_eo text,
    latitude text,
    longitude text,
    lat_dd numeric,
    lon_dd numeric,
    numauto integer NOT NULL,
    year integer,
    date_iso date
);


ALTER TABLE tmp_tt_pts_gps_mdb_points_latlong OWNER TO pierre;


ALTER TABLE tmp_tt_pts_gps_mdb_points_latlong_points OWNER TO pierre;

--
-- Name: tmp_tt_pts_gps_mdb_sdqrfgadzrg; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_tt_pts_gps_mdb_sdqrfgadzrg (
    no text,
    idnt text,
    latitude text,
    longitude text,
    date text,
    "time" text,
    alt text,
    descriptio text,
    proximity text,
    symbol__ text,
    mapinfo_id text,
    lat_dd numeric,
    lon_dd numeric,
    numauto integer NOT NULL
);


ALTER TABLE tmp_tt_pts_gps_mdb_sdqrfgadzrg OWNER TO pierre;


ALTER TABLE tmp_tt_pts_gps_mdb_sdqrfgadzrg_points OWNER TO pierre;

--
-- Name: tmp_tt_pts_gps_mdb_vireendb; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_tt_pts_gps_mdb_vireendb (
    no text,
    idnt text,
    lat_ns text,
    latitude text,
    lon_eo text,
    longitude text,
    date text,
    "time" text,
    alt text,
    descriptio text,
    proximity text,
    symbol__ text,
    mapinfo_id text,
    lat_dd numeric,
    lon_dd numeric,
    numauto integer NOT NULL
);


ALTER TABLE tmp_tt_pts_gps_mdb_vireendb OWNER TO pierre;


ALTER TABLE tmp_tt_pts_gps_mdb_vireendb_points OWNER TO pierre;

--
-- Name: tmp_tt_surface_samples; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_tt_surface_samples (
    opid text,
    sample_id text,
    sample_type text,
    analysis text,
    description text,
    obs_id text,
    datasource text,
    comments text,
    x text,
    y text,
    z text,
    srid text
);


ALTER TABLE tmp_tt_surface_samples OWNER TO pierre;

--
-- Name: tmp_tt_translation_fr2en; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_tt_translation_fr2en (
    obs_id text,
    description text
);


ALTER TABLE tmp_tt_translation_fr2en OWNER TO pierre;

--
-- Name: tmp_waypoints_blaz_sudan_2015_02; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_waypoints_blaz_sudan_2015_02 (
    id text,
    lat text,
    lon text,
    ele text,
    "time" text,
    name text,
    sym text,
    type text,
    displaymode text
);


ALTER TABLE tmp_waypoints_blaz_sudan_2015_02 OWNER TO pierre;

--
-- Name: tmp_waypoints_descriptions; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_waypoints_descriptions (
    index text,
    name text,
    num_corr text,
    date text,
    opid text,
    latitude text,
    longitude text,
    description text,
    icon_descr text,
    alt_meters text,
    rq text,
    obs_id text
);


ALTER TABLE tmp_waypoints_descriptions OWNER TO pierre;

--
-- Name: tmp_waypoints_descriptions_bricolage; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_waypoints_descriptions_bricolage (
    obs_id text,
    year text,
    date text,
    opid text,
    index text,
    name text,
    latitude text,
    longitude text,
    alt_meters text,
    description text,
    icon_descr text,
    comments text,
    sample_id text
);


ALTER TABLE tmp_waypoints_descriptions_bricolage OWNER TO pierre;

--
-- Name: tmp_xtr_dh_collars; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_xtr_dh_collars (
    id text,
    shid text,
    location text,
    profile text,
    srid text,
    x text,
    y text,
    z text,
    azim_ng text,
    azim_nm text,
    dip_hz text,
    dh_type text,
    date_start text,
    contractor text,
    geologist text,
    length text,
    nb_samples text,
    comments text,
    completed text,
    numauto text,
    date_completed text,
    opid text,
    purpose text,
    x_local text,
    y_local text,
    z_local text,
    accusum text,
    id_pject text,
    x_pject text,
    y_pject text,
    z_pject text,
    topo_survey_type text,
    creation_ts text,
    username text,
    datasource text
);


ALTER TABLE tmp_xtr_dh_collars OWNER TO pierre;

--
-- Name: tmp_xtr_field_observations; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_xtr_field_observations (
    opid text,
    year text,
    obs_id text,
    date text,
    waypoint_name text,
    x text,
    y text,
    z text,
    description text,
    code_litho text,
    code_unit text,
    srid text,
    geologist text,
    icon_descr text,
    comments text,
    sample_id text,
    datasource text,
    numauto text,
    photos text,
    audio text,
    timestamp_epoch_ms text,
    creation_ts text,
    username text,
    device text,
    "time" text
);


ALTER TABLE tmp_xtr_field_observations OWNER TO pierre;

CREATE TABLE brgm_au (
    gid integer NOT NULL,
    samplenr text,
    sample_o text,
    shid text,
    samp numeric(12,0),
    au_brgm double precision
);

CREATE TABLE codes (
    gid integer NOT NULL,
    code text,
    descriptio text,
    "table" text
);

CREATE TABLE contact (
    gid integer NOT NULL,
    shid text,
    xh double precision,
    yh double precision,
    zh double precision,
    x double precision,
    y double precision,
    z double precision
);

CREATE TABLE devia (
    gid integer NOT NULL,
    shid text,
    dept numeric,
    incl numeric,
    azim numeric,
    comments text,
    chk text
);


CREATE TABLE density (
    gid integer NOT NULL,
    shid text,
    samp text,
    depf double precision,
    dept double precision,
    oxid text,
    diam double precision,
    length double precision,
    hweight double precision,
    dweight double precision,
    sg_h double precision,
    sg_d double precision,
    weightsusp double precision,
    weightbott double precision,
    moisture double precision
);

CREATE TABLE formatio (
    gid integer NOT NULL,
    formation text,
    litc text
);

CREATE TABLE geotec (
    gid integer NOT NULL,
    shid text,
    depf double precision,
    dept double precision,
    drilldept double precision,
    runlength double precision,
    core text,
    rctool text,
    rqd double precision,
    jtcnt integer,
    jtdescr text,
    comments text,
    chk text
);

CREATE TABLE kendril2 (
    gid integer NOT NULL,
    shid text,
    left_shid_ text,
    direction numeric(11,0),
    incl integer,
    xt numeric(12,0),
    yt numeric(12,0),
    zt integer,
    eoh integer
);

CREATE TABLE lithaufu (
    gid integer NOT NULL,
    shid text,
    depf numeric,
    dept numeric,
    sili numeric,
    alt numeric,
    brit numeric,
    duct numeric,
    carb numeric,
    sulp numeric,
    au numeric,
    litc text,
    oxid text,
    mine text,
    alty text
);

CREATE TABLE mag (
    gid integer NOT NULL,
    x numeric(10,0),
    y double precision,
    nanotesl double precision,
    val_corr double precision
);




CREATE TABLE tmp_log_tech (
    hole_id text,
    depth_from text,
    depth_to text,
    drilled_len_m text,
    reco_len_m text,
    rqd_len_m text,
    diam text,
    comments text,
    drillers_depto text,
    core_loss_m text,
    joints_description text,
    nb_joints text,
    opid text
);


ALTER TABLE tmp_log_tech OWNER TO pierre;




SET search_path = tmp_ntoto, pg_catalog;

--
-- Name: bound_e; Type: TABLE; Schema: tmp_ntoto; Owner: pierre; Tablespace: 
--

CREATE TABLE bound_e (
    gid integer NOT NULL,
    shid text,
    xh double precision,
    yh double precision,
    zh double precision,
    x double precision,
    y double precision,
    z double precision
);


ALTER TABLE bound_e OWNER TO pierre;


ALTER TABLE brgm_au OWNER TO pierre;


ALTER TABLE codes OWNER TO pierre;


ALTER TABLE contact OWNER TO pierre;


ALTER TABLE density OWNER TO pierre;


ALTER TABLE devia OWNER TO pierre;


ALTER TABLE formatio OWNER TO pierre;


ALTER TABLE geotec OWNER TO pierre;

CREATE TABLE headers (
    gid integer NOT NULL,
    shid text,
    datstart date,
    datend date,
    completed text,
    type text,
    flid text,
    xhed double precision,
    yhed double precision,
    zhed double precision,
    leng double precision,
    phase smallint,
    accusum double precision,
    incl double precision,
    azim double precision,
    xutm double precision,
    yutm double precision,
    devia text,
    quick_log text,
    log_tech text,
    log_lith text,
    sampling text,
    results text,
    relogging text,
    beacon text,
    vchannel text,
    comments text,
    in_gdm text
);


ALTER TABLE headers OWNER TO pierre;


ALTER TABLE kendril2 OWNER TO pierre;


ALTER TABLE lithaufu OWNER TO pierre;

CREATE TABLE litho (
    gid integer NOT NULL,
    shid text,
    depf double precision,
    dept double precision,
    litho text,
    litcode text,
    oxid text,
    sili smallint,
    alt smallint,
    britdef smallint,
    ductdef smallint,
    carb smallint,
    sulph smallint,
    altyp text,
    water text,
    color text,
    chk text
);


ALTER TABLE litho OWNER TO pierre;


ALTER TABLE mag OWNER TO pierre;

CREATE TABLE mask (
    gid integer NOT NULL,
    shid text,
    xh double precision,
    yh double precision,
    zh double precision,
    x double precision,
    y double precision,
    z double precision
);


ALTER TABLE mask OWNER TO pierre;

CREATE TABLE mine (
    gid integer NOT NULL,
    shid text,
    depf double precision,
    dept double precision,
    sampfrom numeric(12,0),
    sampto numeric(12,0),
    yfrom double precision,
    yto double precision,
    mine smallint,
    avau double precision,
    stva text,
    accu double precision,
    chk text
);


ALTER TABLE mine OWNER TO pierre;

CREATE TABLE outline (
    gid integer NOT NULL,
    shid text,
    x integer,
    y integer,
    z integer,
    leng integer,
    azim integer,
    incl integer,
    depto integer
);


ALTER TABLE outline OWNER TO pierre;

CREATE TABLE quicklog (
    gid integer NOT NULL,
    shid text,
    depf double precision,
    dept double precision,
    litho text,
    oxid text,
    codl text,
    alt smallint,
    def smallint,
    chk text
);


ALTER TABLE quicklog OWNER TO pierre;

CREATE TABLE rank (
    gid integer NOT NULL,
    bh text,
    x double precision,
    y double precision,
    z double precision
);


ALTER TABLE rank OWNER TO pierre;

CREATE TABLE sampling (
    gid integer NOT NULL,
    shid text,
    samp numeric(12,0),
    rc_dd text,
    depf double precision,
    dept double precision,
    corloss smallint,
    recv double precision,
    recperc double precision,
    au1 double precision,
    au2 double precision,
    au3 double precision,
    au double precision,
    au_av_sgs double precision,
    au_specks text,
    mine smallint,
    sent text,
    comments text,
    weight double precision,
    moisture double precision,
    pulp text,
    reserve text,
    chk text
);


ALTER TABLE sampling OWNER TO pierre;

CREATE TABLE sgs_au (
    gid integer NOT NULL,
    samplenr text,
    au_sgs1 text,
    au_sgs2 text,
    au_sgs3 text,
    control text,
    shid text,
    sample integer,
    repeat text,
    au1 double precision,
    au2 double precision,
    au3 double precision,
    interfinal text,
    chk date
);


ALTER TABLE sgs_au OWNER TO pierre;

CREATE TABLE sgsrecod (
    gid integer NOT NULL,
    shid text,
    samp integer,
    nrbidon text
);


ALTER TABLE sgsrecod OWNER TO pierre;

CREATE TABLE soil (
    gid integer NOT NULL,
    sample_ text,
    shid text,
    x numeric(10,0),
    y numeric(10,0),
    z integer,
    au_ppb numeric(10,0)
);


ALTER TABLE soil OWNER TO pierre;

CREATE TABLE statrenc (
    gid integer NOT NULL,
    trench text,
    nbsamples numeric(10,0),
    rnbsamples numeric(10,0),
    vcnbsample numeric(10,0),
    volexcam3 double precision,
    avdepth double precision,
    cropscedis double precision,
    costcedis double precision,
    tcostcpm3 double precision
);


ALTER TABLE statrenc OWNER TO pierre;

CREATE TABLE struc (
    gid integer NOT NULL,
    shid text,
    dept double precision,
    descr text,
    tca smallint,
    type text,
    azi integer,
    dip integer,
    dirdip text,
    pitch numeric(10,0),
    dirpi text,
    movt text,
    tri text
);


ALTER TABLE struc OWNER TO pierre;

CREATE TABLE submit (
    gid integer NOT NULL,
    shid text,
    sampfrom smallint,
    sampto smallint,
    nb smallint,
    mspu_sub date,
    sgs_subm date,
    final_inte text,
    results text
);


ALTER TABLE submit OWNER TO pierre;

CREATE TABLE thisecti (
    gid integer NOT NULL,
    shid text,
    dept double precision,
    corequarte text,
    questions text,
    nom text,
    texture text,
    mineralogi text,
    metam_def text,
    mineralisa text,
    origine text
);


ALTER TABLE thisecti OWNER TO pierre;

CREATE TABLE tr_au (
    gid integer NOT NULL,
    shid text,
    sample text,
    x double precision,
    yfrom double precision,
    yto double precision,
    zto double precision,
    zgraph double precision,
    depf double precision,
    dept double precision,
    codlitho text,
    mine smallint,
    auavg double precision,
    auw1 double precision,
    auw2 double precision,
    auw double precision,
    sampleast text,
    aue1 double precision,
    aue2 double precision,
    aue double precision,
    chk text
);


ALTER TABLE tr_au OWNER TO pierre;

CREATE TABLE tr_litho (
    gid integer NOT NULL,
    shid text,
    depf double precision,
    dept double precision,
    xto double precision,
    yfrom double precision,
    yto double precision,
    zto double precision,
    litho text,
    color text,
    codlitho text,
    oxid text,
    alt smallint,
    shear smallint,
    chk text
);


ALTER TABLE tr_litho OWNER TO pierre;

CREATE TABLE vchannau (
    gid integer NOT NULL,
    bhid text,
    shid text,
    sample text,
    x double precision,
    y double precision,
    z double precision,
    depto double precision,
    zto double precision,
    au1 double precision,
    au2 double precision,
    au double precision,
    chk text
);


ALTER TABLE vchannau OWNER TO pierre;

CREATE TABLE vchannel (
    gid integer NOT NULL,
    bhid text,
    x double precision,
    y double precision,
    z double precision,
    depto double precision,
    zto double precision,
    codlitho text,
    chk text
);


ALTER TABLE vchannel OWNER TO pierre;


SET search_path = pierre, pg_catalog;


SET search_path = public, pg_catalog;


SET search_path = pierre, pg_catalog;

--
-- Name: coords_pkey; Type: CONSTRAINT; Schema: pierre; Owner: pierre; Tablespace: 
--

ALTER TABLE ONLY coords
    ADD CONSTRAINT coords_pkey PRIMARY KEY (id);
ALTER TABLE ONLY dh_collars_lengths
    ADD CONSTRAINT dh_collars_lengths_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY grid
    ADD CONSTRAINT grid_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY rock_ana
    ADD CONSTRAINT hammer_ana_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY rock_sampling
    ADD CONSTRAINT hammer_sampling_pkey PRIMARY KEY (hammer_index);
ALTER TABLE ONLY layer_styles
    ADD CONSTRAINT layer_styles_pkey PRIMARY KEY (id);
-- ALTER TABLE ONLY pchgeol_rapports
--     ADD CONSTRAINT pchgeol_rapports_num_rapport PRIMARY KEY (numrap);
ALTER TABLE ONLY program
    ADD CONSTRAINT program_pkey PRIMARY KEY (gid);
ALTER TABLE ONLY sections_array
    ADD CONSTRAINT sections_array_pkey PRIMARY KEY (num);
ALTER TABLE ONLY sections_definition
    ADD CONSTRAINT sections_definition_pkey PRIMARY KEY (id);
-- ALTER TABLE ONLY songs
--     ADD CONSTRAINT songs_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY tmp_xy
    ADD CONSTRAINT tmp_xy_id PRIMARY KEY (id);


SET search_path = public, pg_catalog;

--
-- Name: ancient_workings_pkey; Type: CONSTRAINT; Schema: public; Owner: data_admin; Tablespace: 
--

ALTER TABLE ONLY ancient_workings
    ADD CONSTRAINT ancient_workings_pkey PRIMARY KEY (gid);
ALTER TABLE ONLY baselines
    ADD CONSTRAINT baselines_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY dh_collars
    ADD CONSTRAINT dh_collars_numauto_key UNIQUE (numauto);
ALTER TABLE ONLY dh_core_boxes
    ADD CONSTRAINT dh_core_boxes_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY dh_density
    ADD CONSTRAINT dh_density_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY dh_devia
    ADD CONSTRAINT dh_devia_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY dh_followup
    ADD CONSTRAINT dh_followup_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY dh_litho
    ADD CONSTRAINT dh_litho_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY dh_mineralised_intervals
    ADD CONSTRAINT dh_mine_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY dh_quicklog
    ADD CONSTRAINT dh_quicklog_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY dh_sampling_bottle_roll
    ADD CONSTRAINT dh_sampling_bottle_roll_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY dh_sampling_grades
    ADD CONSTRAINT dh_sampling_grades_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY dh_struct_measures
    ADD CONSTRAINT dh_struct_measures_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY dh_tech
    ADD CONSTRAINT dh_tech_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY dh_thinsections
    ADD CONSTRAINT dh_thinsections_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY doc_bdexplo_table_categories
    ADD CONSTRAINT doc_bdexplo_table_categories_pkey PRIMARY KEY (category);
ALTER TABLE ONLY doc_bdexplo_tables_descriptions
    ADD CONSTRAINT doc_bdexplo_tables_descriptions_pkey PRIMARY KEY (tablename);
ALTER TABLE ONLY shift_reports
    ADD CONSTRAINT fichette_pkey PRIMARY KEY (opid, no_fichette);
ALTER TABLE ONLY field_observations
    ADD CONSTRAINT field_observations_pkey1 PRIMARY KEY (numauto);
ALTER TABLE ONLY field_observations_struct_measures
    ADD CONSTRAINT field_observations_struct_measures_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY field_photos
    ADD CONSTRAINT field_photos_id PRIMARY KEY (pho_id);
ALTER TABLE ONLY formations_group_lithos
    ADD CONSTRAINT formations_group_lithos_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY geoch_ana
    ADD CONSTRAINT geoch_ana_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY geoch_sampling_grades
    ADD CONSTRAINT geoch_sampling_grades_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY geoch_sampling
    ADD CONSTRAINT geoch_sampling_pkey PRIMARY KEY (sampl_index);
ALTER TABLE ONLY geometry_columns_old
    ADD CONSTRAINT geometry_columns_pk PRIMARY KEY (f_table_catalog, f_table_schema, f_table_name, f_geometry_column);
ALTER TABLE ONLY gpy_mag_ground
    ADD CONSTRAINT gpy_mag_ground_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY index_geo_documentation
    ADD CONSTRAINT index_geo_documentation_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY lab_ana_batches_expedition
    ADD CONSTRAINT lab_ana_batches_expedition_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY lab_ana_batches_reception
    ADD CONSTRAINT lab_ana_batches_reception_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY lab_ana_columns_definition
    ADD CONSTRAINT lab_ana_columns_definition_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY lab_ana_qaqc_results
    ADD CONSTRAINT lab_ana_qaqc_results_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY lex_codes
    ADD CONSTRAINT lex_codes_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY lex_datasource
    ADD CONSTRAINT lex_datasource_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY qc_standards
    ADD CONSTRAINT lex_qc_qc_id_key UNIQUE (qc_id);
ALTER TABLE ONLY lex_standard
    ADD CONSTRAINT lex_standard_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY mag_declination
    ADD CONSTRAINT mag_declination_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY surface_samples_grades
    ADD CONSTRAINT numauto_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY field_observations
    ADD CONSTRAINT obs_id_unique UNIQUE (opid, obs_id);
ALTER TABLE ONLY occurrences
    ADD CONSTRAINT occurrences_pkey PRIMARY KEY (numauto_auto);
ALTER TABLE ONLY dh_collars
    ADD CONSTRAINT opid_id PRIMARY KEY (opid, id);
ALTER TABLE ONLY operation_active
    ADD CONSTRAINT opid_unique UNIQUE (opid);
ALTER TABLE ONLY grade_ctrl
    ADD CONSTRAINT preex_sampling_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY qc_sampling
    ADD CONSTRAINT qc_sampling_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY qc_standards
    ADD CONSTRAINT qc_standards_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY spatial_ref_sys_old
    ADD CONSTRAINT spatial_ref_sys_pkey PRIMARY KEY (srid);
ALTER TABLE ONLY survey_lines
    ADD CONSTRAINT survey_lines_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY topo_points
    ADD CONSTRAINT topo_points_pkey PRIMARY KEY (numauto);


SET search_path = tmp_a_traiter, pg_catalog;

--
-- Name: bondoukou_alain_lambert_coor_pkey; Type: CONSTRAINT; Schema: tmp_a_traiter; Owner: pierre; Tablespace: 
--

ALTER TABLE ONLY bondoukou_alain_lambert_coor
    ADD CONSTRAINT bondoukou_alain_lambert_coor_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY bondoukou_alain_lambert_vx_tvx
    ADD CONSTRAINT bondoukou_alain_lambert_vx_tvx_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY soil_geoch_bondoukou
    ADD CONSTRAINT soil_geoch_bondoukou_pkey PRIMARY KEY (numauto);


SET search_path = tmp_imports, pg_catalog;

--
-- Name: tmp_ity_gpspolo_travaux_97et2004_pkey; Type: CONSTRAINT; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

ALTER TABLE ONLY tmp_ity_gpspolo_travaux_97et2004
    ADD CONSTRAINT tmp_ity_gpspolo_travaux_97et2004_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY tmp_tt_pierre_nettoye_uploader_wpt
    ADD CONSTRAINT tmp_tt_pierre_nettoye_uploader_wpt_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY tmp_tt_pts_gps_mdb_copie
    ADD CONSTRAINT tmp_tt_pts_gps_mdb_copie_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY tmp_tt_pts_gps_mdb_points_latlong
    ADD CONSTRAINT tmp_tt_pts_gps_mdb_points_latlong_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY tmp_tt_pts_gps_mdb_sdqrfgadzrg
    ADD CONSTRAINT tmp_tt_pts_gps_mdb_sdqrfgadzrg_pkey PRIMARY KEY (numauto);
ALTER TABLE ONLY tmp_tt_pts_gps_mdb_vireendb
    ADD CONSTRAINT tmp_tt_pts_gps_mdb_vireendb_pkey PRIMARY KEY (numauto);


SET search_path = tmp_ntoto, pg_catalog;

--
-- Name: bound_e_pkey; Type: CONSTRAINT; Schema: tmp_ntoto; Owner: pierre; Tablespace: 
--

ALTER TABLE ONLY bound_e
    ADD CONSTRAINT bound_e_pkey PRIMARY KEY (gid);
ALTER TABLE ONLY brgm_au
    ADD CONSTRAINT brgm_au_pkey PRIMARY KEY (gid);
ALTER TABLE ONLY codes
    ADD CONSTRAINT codes_pkey PRIMARY KEY (gid);
ALTER TABLE ONLY contact
    ADD CONSTRAINT contact_pkey PRIMARY KEY (gid);
ALTER TABLE ONLY density
    ADD CONSTRAINT density_pkey PRIMARY KEY (gid);
ALTER TABLE ONLY devia
    ADD CONSTRAINT devia_pkey PRIMARY KEY (gid);
ALTER TABLE ONLY formatio
    ADD CONSTRAINT formatio_pkey PRIMARY KEY (gid);
ALTER TABLE ONLY geotec
    ADD CONSTRAINT geotec_pkey PRIMARY KEY (gid);
ALTER TABLE ONLY headers
    ADD CONSTRAINT headers_pkey PRIMARY KEY (gid);
ALTER TABLE ONLY kendril2
    ADD CONSTRAINT kendril2_pkey PRIMARY KEY (gid);
ALTER TABLE ONLY lithaufu
    ADD CONSTRAINT lithaufu_pkey PRIMARY KEY (gid);
ALTER TABLE ONLY litho
    ADD CONSTRAINT litho_pkey PRIMARY KEY (gid);
ALTER TABLE ONLY mag
    ADD CONSTRAINT mag_pkey PRIMARY KEY (gid);
ALTER TABLE ONLY mask
    ADD CONSTRAINT mask_pkey PRIMARY KEY (gid);
ALTER TABLE ONLY mine
    ADD CONSTRAINT mine_pkey PRIMARY KEY (gid);
ALTER TABLE ONLY outline
    ADD CONSTRAINT outline_pkey PRIMARY KEY (gid);
ALTER TABLE ONLY quicklog
    ADD CONSTRAINT quicklog_pkey PRIMARY KEY (gid);
ALTER TABLE ONLY rank
    ADD CONSTRAINT rank_pkey PRIMARY KEY (gid);
ALTER TABLE ONLY sampling
    ADD CONSTRAINT sampling_pkey PRIMARY KEY (gid);
ALTER TABLE ONLY sgs_au
    ADD CONSTRAINT sgs_au_pkey PRIMARY KEY (gid);
ALTER TABLE ONLY sgsrecod
    ADD CONSTRAINT sgsrecod_pkey PRIMARY KEY (gid);
ALTER TABLE ONLY soil
    ADD CONSTRAINT soil_pkey PRIMARY KEY (gid);
ALTER TABLE ONLY statrenc
    ADD CONSTRAINT statrenc_pkey PRIMARY KEY (gid);
ALTER TABLE ONLY struc
    ADD CONSTRAINT struc_pkey PRIMARY KEY (gid);
ALTER TABLE ONLY submit
    ADD CONSTRAINT submit_pkey PRIMARY KEY (gid);
ALTER TABLE ONLY thisecti
    ADD CONSTRAINT thisecti_pkey PRIMARY KEY (gid);
ALTER TABLE ONLY tr_au
    ADD CONSTRAINT tr_au_pkey PRIMARY KEY (gid);
ALTER TABLE ONLY tr_litho
    ADD CONSTRAINT tr_litho_pkey PRIMARY KEY (gid);
ALTER TABLE ONLY vchannau
    ADD CONSTRAINT vchannau_pkey PRIMARY KEY (gid);
ALTER TABLE ONLY vchannel
    ADD CONSTRAINT vchannel_pkey PRIMARY KEY (gid);


SET search_path = public, pg_catalog;

--
-- Name: ancient_workings_the_geom_gist; Type: INDEX; Schema: public; Owner: data_admin; Tablespace: 
--

CREATE INDEX ancient_workings_the_geom_gist ON ancient_workings USING gist (the_geom);
CREATE INDEX dh_collars_id ON dh_collars USING btree (id);
CREATE INDEX dh_litho_id_depto ON dh_litho USING btree (id, depto);
CREATE INDEX id_depto_dh_mine ON dh_mineralised_intervals USING btree (id, depto);
CREATE INDEX id_depto_dh_tech ON dh_tech USING btree (id, depto);
CREATE INDEX id_preex_sampling ON grade_ctrl USING btree (id);
CREATE INDEX qc_sampling_sample_id ON qc_sampling USING btree (sample_id);
CREATE INDEX sampl_index_geoch_ana ON geoch_ana USING btree (sampl_index);
CREATE INDEX sampl_index_geoch_sampling ON geoch_sampling USING btree (sampl_index);
CREATE INDEX xyz_preex_sampling ON grade_ctrl USING btree (x, y, z);


SET search_path = tmp_a_traiter, pg_catalog;

--
-- Name: soil_geoch_bondoukou_numauto; Type: INDEX; Schema: tmp_a_traiter; Owner: pierre; Tablespace: 
--

CREATE INDEX soil_geoch_bondoukou_numauto ON soil_geoch_bondoukou USING btree (numauto);


SET search_path = public, pg_catalog;



}}}

TABLES À VOIR 
/* => VU:{{{


SET search_path = public, pg_catalog;
--
-- Name: dh_core_boxes; Type: TABLE; Schema: public; Owner: data_admin; Tablespace: 
--
CREATE TABLE dh_core_boxes (
    id text,
    depfrom numeric(10,2),
    depto numeric(10,2),
    box_number integer,
    datasource integer,
    opid integer,
    numauto integer NOT NULL,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"()
);
ALTER TABLE dh_core_boxes OWNER TO data_admin;
COMMENT ON TABLE dh_core_boxes IS 'Core drill holes boxes';
COMMENT ON COLUMN dh_core_boxes.id IS 'Identifier, refers to dh_collars';
COMMENT ON COLUMN dh_core_boxes.depfrom IS 'Core box contents beginning depth';
COMMENT ON COLUMN dh_core_boxes.depto IS 'Core box contents ending depth';
COMMENT ON COLUMN dh_core_boxes.box_number IS 'Core box number';
COMMENT ON COLUMN dh_core_boxes.datasource IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN dh_core_boxes.opid IS 'Operation identifier';
COMMENT ON COLUMN dh_core_boxes.numauto IS 'Automatic integer primary key';
COMMENT ON COLUMN dh_core_boxes.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_core_boxes.username IS 'User (role) which created data record';




SET search_path = public, pg_catalog;
--
-- Name: dh_density; Type: TABLE; Schema: public; Owner: data_admin; Tablespace: 
--
CREATE TABLE dh_density (
    id text,
    depfrom numeric(10,2),
    depto numeric(10,2),
    density numeric(10,2),
    opid integer,
    density_humid numeric,
    moisture numeric,
    method text,
    numauto integer NOT NULL,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"(),
    datasource integer
);
COMMENT ON TABLE dh_density IS 'Density measurements along drill holes or trenches';
COMMENT ON COLUMN dh_density.id IS 'Identifier, refers to dh_collars';
COMMENT ON COLUMN dh_density.depfrom IS 'Interval beginning depth: if not empty, density measured along an interval; otherwise, density measured on a point';
COMMENT ON COLUMN dh_density.depto IS 'Interval ending depth: if depfrom is empty, depth of ponctual density measurement';
COMMENT ON COLUMN dh_density.density IS 'Density, unitless, or considered as kg/l, or t/m3';
COMMENT ON COLUMN dh_density.opid IS 'Operation identifier';
COMMENT ON COLUMN dh_density.density_humid IS 'Density, unitless, or considered as kg/l, or t/m3, determined on humid sample';
COMMENT ON COLUMN dh_density.moisture IS 'Moisture contents';
COMMENT ON COLUMN dh_density.method IS 'Procedure used to determine specific gravity';
COMMENT ON COLUMN dh_density.numauto IS 'Automatic integer primary key';
COMMENT ON COLUMN dh_density.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_density.username IS 'User (role) which created data record';
COMMENT ON COLUMN dh_density.datasource IS 'Datasource identifier, refers to lex_datasource';
ALTER TABLE dh_density OWNER TO data_admin;




SET search_path = public, pg_catalog;
--
-- Name: dh_followup; Type: TABLE; Schema: public; Owner: data_admin; Tablespace: 
--
CREATE TABLE dh_followup (
    opid integer,
    id text,
    devia text,
    quick_log text,
    log_tech text,
    log_lith text,
    sampling text,
    results text,
    relogging text,
    beacon text,
    in_gdm text,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"(),
    numauto integer NOT NULL
);
ALTER TABLE dh_followup OWNER TO data_admin;
COMMENT ON TABLE dh_followup IS 'Simple table for daily drill holes followup';
COMMENT ON COLUMN dh_followup.opid IS 'Operation identifier';
COMMENT ON COLUMN dh_followup.id IS 'Identifier, refers to dh_collars';
COMMENT ON COLUMN dh_followup.devia IS 'Deviation survey (x: done; xx: done, data entered; xxx: data verified)';
COMMENT ON COLUMN dh_followup.quick_log IS 'Quick geological log, typically done on hole finish, for an A4 log plot (x: done; xx: done, data entered; xxx: data verified)';
COMMENT ON COLUMN dh_followup.log_tech IS 'Core fitting, core measurement, meters marking, RQD, fracture counts, etc. (x: done; xx: done, data entered; xxx: data verified)';
COMMENT ON COLUMN dh_followup.log_lith IS 'Full geological log (x: done; xx: done, data entered; xxx: data verified)';
COMMENT ON COLUMN dh_followup.sampling IS 'Hole sampling (x: done; xx: done, data entered; xxx: data verified)';
COMMENT ON COLUMN dh_followup.results IS 'Assay results back from laboratory (x: received; xx: entered; xxx: verified)';
COMMENT ON COLUMN dh_followup.relogging IS 'Geological log done afterwards on mineralised intervals (x: done; xx: done, data entered; xxx: data verified)';
COMMENT ON COLUMN dh_followup.beacon IS 'Beacon or any other permanent hole marker on field (PVC pipe, concrete beacon, cement, etc.) (x: done)';
COMMENT ON COLUMN dh_followup.in_gdm IS 'Data exported to GDM; implicitely: data clean, checked by GDM procedures (x: done)';
COMMENT ON COLUMN dh_followup.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_followup.username IS 'User (role) which created data record';
COMMENT ON COLUMN dh_followup.numauto IS 'Automatic integer primary key';



SET search_path = public, pg_catalog;
--
-- Name: dh_mineralised_intervals; Type: TABLE; Schema: public; Owner: data_admin; Tablespace: 
--
CREATE TABLE dh_mineralised_intervals (
    id text,
    depfrom numeric(10,2),
    depto numeric(10,2),
    mine integer DEFAULT 1,
    avau numeric(10,2),
    stva text,
    accu numeric(10,2),
    recu numeric(10,2),
    dens numeric(10,2),
    numauto integer NOT NULL,
    comments text,
    opid integer,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"(),
    datasource integer
);
ALTER TABLE dh_mineralised_intervals OWNER TO data_admin;
--
-- Name: TABLE dh_mineralised_intervals; Type: COMMENT; Schema: public; Owner: data_admin
--
COMMENT ON TABLE dh_mineralised_intervals IS 'Drill holes mineralised intercepts: stretch values over mineralised intervals, along drill holes or trenches';
COMMENT ON COLUMN dh_mineralised_intervals.id IS 'Full identifier for borehole or trench';
COMMENT ON COLUMN dh_mineralised_intervals.depfrom IS 'Mineralised interval starting depth';
COMMENT ON COLUMN dh_mineralised_intervals.depto IS 'Mineralised interval ending depth';
COMMENT ON COLUMN dh_mineralised_intervals.mine IS 'Take-out interval class: 1=normal interval, 2=high-grade interval ';
COMMENT ON COLUMN dh_mineralised_intervals.avau IS 'Average grade (g/t)';
COMMENT ON COLUMN dh_mineralised_intervals.stva IS 'Stretch value, X m at Y g/t';
COMMENT ON COLUMN dh_mineralised_intervals.accu IS 'Accumulation in m.g/t over mineralised interval';
COMMENT ON COLUMN dh_mineralised_intervals.recu IS 'recovery';
COMMENT ON COLUMN dh_mineralised_intervals.dens IS 'density';
COMMENT ON COLUMN dh_mineralised_intervals.numauto IS 'Automatic integer primary key';
COMMENT ON COLUMN dh_mineralised_intervals.opid IS 'Operation identifier';
COMMENT ON COLUMN dh_mineralised_intervals.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_mineralised_intervals.username IS 'User (role) which created data record';
COMMENT ON COLUMN dh_mineralised_intervals.datasource IS 'Datasource identifier, refers to lex_datasource';



--
-- Name: dh_photos; Type: TABLE; Schema: pierre; Owner: pierre; Tablespace: 
--
CREATE TABLE dh_photos (
    opid integer,
    pho_id text,
    file text,
    author text,
    datasource integer
);
ALTER TABLE dh_photos OWNER TO pierre;


SET search_path = public, pg_catalog;
--
-- Name: dh_quicklog; Type: TABLE; Schema: public; Owner: data_admin; Tablespace: 
--
CREATE TABLE dh_quicklog (
    opid integer,
    id text,
    depfrom numeric(10,2),
    depto numeric(10,2),
    description text,
    oxid text,
    alt smallint,
    def smallint,
    numauto integer NOT NULL,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"(),
    datasource integer
);
ALTER TABLE dh_quicklog OWNER TO data_admin;
--
-- Name: TABLE dh_quicklog; Type: COMMENT; Schema: public; Owner: data_admin
--
COMMENT ON TABLE dh_quicklog IS 'Quick geological log, typically done on hole finish, for an A4 log plot';
COMMENT ON COLUMN dh_quicklog.opid IS 'Operation identifier';
COMMENT ON COLUMN dh_quicklog.id IS 'Full identifier for borehole or trench';
COMMENT ON COLUMN dh_quicklog.depfrom IS 'Interval beginning depth';
COMMENT ON COLUMN dh_quicklog.depto IS 'Interval ending depth';
COMMENT ON COLUMN dh_quicklog.description IS 'Quick geological description, logging wide intervals and/or only representative portions';
COMMENT ON COLUMN dh_quicklog.oxid IS 'Oxidation state: O, PO, U';
COMMENT ON COLUMN dh_quicklog.alt IS 'Alteration intensity: 0: none, 1: weak, 2: moderate, 3: strong';
COMMENT ON COLUMN dh_quicklog.def IS 'Deformation intensity: 0: none, 1: weak, 2: moderate, 3: strong';
COMMENT ON COLUMN dh_quicklog.numauto IS 'Automatic integer primary key';
COMMENT ON COLUMN dh_quicklog.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_quicklog.username IS 'User (role) which created data record';
COMMENT ON COLUMN dh_quicklog.datasource IS 'Datasource identifier, refers to lex_datasource';



--
-- Name: dh_samples_submission; Type: TABLE; Schema: pierre; Owner: pierre; Tablespace: 
--
CREATE TABLE dh_samples_submission (
    opid integer,
    id text,
    sampfrom smallint,
    sampto smallint,
    nb smallint,
    mspu_sub date,
    sgs_subm date,
    final_interm text,
    results text
);
ALTER TABLE dh_samples_submission OWNER TO pierre;


SET search_path = public, pg_catalog;
--
-- Name: dh_sampling_bottle_roll; Type: TABLE; Schema: public; Owner: data_admin; Tablespace: 
--
CREATE TABLE dh_sampling_bottle_roll (
    opid integer,
    id text,
    depfrom numeric(10,2),
    depto numeric(10,2),
    sample_id text,
    au_total numeric(10,2),
    au_24h numeric(10,2),
    au_48h numeric(10,2),
    au_72h numeric(10,2),
    au_residu numeric(10,2),
    rec_24h_pc numeric(10,2),
    rec_48h_pc numeric(10,2),
    rec_72h_pc numeric(10,2),
    datasource integer,
    numauto integer NOT NULL,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"()
);
ALTER TABLE dh_sampling_bottle_roll OWNER TO data_admin;
COMMENT ON TABLE dh_sampling_bottle_roll IS 'Mineralurgical samples, bottle-roll tests results';
COMMENT ON COLUMN dh_sampling_bottle_roll.opid IS 'Operation identifier';
COMMENT ON COLUMN dh_sampling_bottle_roll.id IS 'Identifier, refers to dh_collars';
COMMENT ON COLUMN dh_sampling_bottle_roll.depfrom IS 'Sample beginning depth';
COMMENT ON COLUMN dh_sampling_bottle_roll.depto IS 'Sample ending depth';
COMMENT ON COLUMN dh_sampling_bottle_roll.sample_id IS 'Sample identifier: refers to assay results and quality check tables';
COMMENT ON COLUMN dh_sampling_bottle_roll.au_total IS 'Total gold recovered';
COMMENT ON COLUMN dh_sampling_bottle_roll.au_24h IS 'Gold recovered after 24 hours';
COMMENT ON COLUMN dh_sampling_bottle_roll.au_48h IS 'Gold recovered after 48 hours';
COMMENT ON COLUMN dh_sampling_bottle_roll.au_72h IS 'Gold recovered after 72 hours';
COMMENT ON COLUMN dh_sampling_bottle_roll.au_residu IS 'Residual gold';
COMMENT ON COLUMN dh_sampling_bottle_roll.rec_24h_pc IS 'Recovery after 24 hours, percent';
COMMENT ON COLUMN dh_sampling_bottle_roll.rec_48h_pc IS 'Recovery after 48 hours, percent';
COMMENT ON COLUMN dh_sampling_bottle_roll.rec_72h_pc IS 'Recovery after 72 hours, percent';
COMMENT ON COLUMN dh_sampling_bottle_roll.datasource IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN dh_sampling_bottle_roll.numauto IS 'Automatic integer primary key';
COMMENT ON COLUMN dh_sampling_bottle_roll.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_sampling_bottle_roll.username IS 'User (role) which created data record';




SET search_path = public, pg_catalog;
--
-- Name: dh_struct_measures; Type: TABLE; Schema: public; Owner: data_admin; Tablespace: 
--
CREATE TABLE dh_struct_measures (
    opid integer,
    id text,
    depto numeric(10,2),
    measure_type text,
    structure_type text,
    alpha_tca numeric,
    beta numeric,
    gamma numeric,
    north_ref text,
    direction integer,
    dip integer,
    dip_quadrant text,
    pitch integer,
    pitch_quadrant text,
    movement text,
    valid boolean,
    struct_description text,
    sortgroup text,
    datasource integer,
    numauto integer NOT NULL,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"()
);
ALTER TABLE dh_struct_measures OWNER TO data_admin;
--
-- Name: TABLE dh_struct_measures; Type: COMMENT; Schema: public; Owner: data_admin
--
COMMENT ON TABLE dh_struct_measures IS 'Structural measurements done on core, or in trenches';
COMMENT ON COLUMN dh_struct_measures.opid IS 'Operation identifier';
COMMENT ON COLUMN dh_struct_measures.id IS 'Full identifier for borehole or trench';
COMMENT ON COLUMN dh_struct_measures.depto IS 'Measurement depth';
COMMENT ON COLUMN dh_struct_measures.measure_type IS 'Type of measurement: [P: plane L: line PL: plane line PLM: plane line movement PLMS: plane line movement sure]';
COMMENT ON COLUMN dh_struct_measures.structure_type IS 'Measured structure type: [VEIN , FRACTURE , C , SCHISTOSITY , FOLIATION , MYLONITE , CONTACT , VEIN_FAULT , FOLD_PAX_AX , FOLIATION_LINE , FAULT , CATACLASE , MINERALISED_STRUCTURE]';
COMMENT ON COLUMN dh_struct_measures.alpha_tca IS 'Alpha angle = To Core Axis (TCA) angle, measured on core';
COMMENT ON COLUMN dh_struct_measures.beta IS 'Beta angle';
COMMENT ON COLUMN dh_struct_measures.gamma IS 'Gamma angle';
COMMENT ON COLUMN dh_struct_measures.north_ref IS 'North reference for azimuths and directions measurements: [Nm: magnetic North, Ng: geographic North, Nu: UTM north, Nl: local grid Y axis]';
COMMENT ON COLUMN dh_struct_measures.direction IS 'Plane direction, 0-180°';
COMMENT ON COLUMN dh_struct_measures.dip IS 'Plane dip, 0-90°';
COMMENT ON COLUMN dh_struct_measures.dip_quadrant IS 'Plane dip quadrant, NESW';
COMMENT ON COLUMN dh_struct_measures.pitch IS 'Pitch of line on plane, 0-90°';
COMMENT ON COLUMN dh_struct_measures.pitch_quadrant IS 'Quadrant of pitch, NESW';
COMMENT ON COLUMN dh_struct_measures.movement IS 'Relative movement of fault/C: [N: normal, I: inverse = R = reverse, D: dextral, S: sinistral]';
COMMENT ON COLUMN dh_struct_measures.valid IS 'Measure is valid or not (impossible cases = not valid)';
COMMENT ON COLUMN dh_struct_measures.struct_description IS 'Naturalist description of measured structure';
COMMENT ON COLUMN dh_struct_measures.sortgroup IS 'Sorting group, for discriminated of various phases: a, b, c, ...';
COMMENT ON COLUMN dh_struct_measures.datasource IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN dh_struct_measures.numauto IS 'Automatic integer primary key';
COMMENT ON COLUMN dh_struct_measures.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_struct_measures.username IS 'User (role) which created data record';



CREATE TABLE dh_tech (
    id text,
    depfrom numeric(10,2),
    depto numeric(10,2),
    drilled_len numeric(10,2),
    reco_len numeric(10,2),
    rqd_len numeric(10,2),
    diam text,
    numauto integer NOT NULL,
    datasource integer,
    opid integer,
    comments text,
    drillers_depto numeric(10,2),
    core_loss_cm integer,
    joints_description text,
    nb_joints integer,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"()
);
ALTER TABLE dh_tech OWNER TO data_admin;
--
-- Name: TABLE dh_tech; Type: COMMENT; Schema: public; Owner: data_admin
--
COMMENT ON TABLE dh_tech IS 'Technical drilling data, and geotechnical parameters';
COMMENT ON COLUMN dh_tech.id IS 'Drill hole identification';
COMMENT ON COLUMN dh_tech.depfrom IS 'Interval begining depth';
COMMENT ON COLUMN dh_tech.depto IS 'Interval ending depth';
COMMENT ON COLUMN dh_tech.drilled_len IS 'Interval length';
COMMENT ON COLUMN dh_tech.reco_len IS 'Recovery length';
COMMENT ON COLUMN dh_tech.rqd_len IS 'Rock Quality Designation "length"';
COMMENT ON COLUMN dh_tech.diam IS 'core diameter';
COMMENT ON COLUMN dh_tech.numauto IS 'Automatic integer primary key';
COMMENT ON COLUMN dh_tech.datasource IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN dh_tech.opid IS 'Operation identifier';
COMMENT ON COLUMN dh_tech.drillers_depto IS 'Driller end-of-run depth, as mentioned on core block';
COMMENT ON COLUMN dh_tech.core_loss_cm IS 'Core loss along drilled run';
COMMENT ON COLUMN dh_tech.joints_description IS 'Joints description: rugosity, fillings, etc.';
COMMENT ON COLUMN dh_tech.nb_joints IS 'Count of natural joints along drilled run';
COMMENT ON COLUMN dh_tech.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_tech.username IS 'User (role) which created data record';




CREATE TABLE dh_thinsections (
    opid integer,
    id text,
    depto numeric(10,2),
    core_quarter text,
    questions text,
    name text,
    texture text,
    mineralogy text,
    metamorphism_deformations text,
    mineralisations text,
    origin text,
    numauto integer NOT NULL,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"(),
    datasource integer
);
COMMENT ON TABLE dh_thinsections IS 'Thin sections for petrological studies';
COMMENT ON COLUMN dh_thinsections.opid IS 'Operation identifier';
COMMENT ON COLUMN dh_thinsections.id IS 'Identifier, refers to dh_collars';
COMMENT ON COLUMN dh_thinsections.depto IS 'Sample taken for thin section: bottom depth';
COMMENT ON COLUMN dh_thinsections.core_quarter IS 'Optional code to identify which core quarter was taken to make thin section; useful for oriented core';
COMMENT ON COLUMN dh_thinsections.questions IS 'Interrogations concerning sample; desired diagnose';
COMMENT ON COLUMN dh_thinsections.name IS 'Result of diagnose: rock name';
COMMENT ON COLUMN dh_thinsections.texture IS 'Result of diagnose: texture';
COMMENT ON COLUMN dh_thinsections.mineralogy IS 'Result of diagnose: mineralogy';
COMMENT ON COLUMN dh_thinsections.metamorphism_deformations IS 'Result of diagnose: metamorphism and/or deformations';
COMMENT ON COLUMN dh_thinsections.mineralisations IS 'Result of diagnose: mineralisations';
COMMENT ON COLUMN dh_thinsections.origin IS 'Result of diagnose: origin: in case of highly transformed rock, protore';
COMMENT ON COLUMN dh_thinsections.numauto IS 'Automatic integer primary key';
COMMENT ON COLUMN dh_thinsections.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_thinsections.username IS 'User (role) which created data record';
COMMENT ON COLUMN dh_thinsections.datasource IS 'Datasource identifier, refers to lex_datasource';
ALTER TABLE dh_thinsections OWNER TO data_admin;



CREATE TABLE field_observations (
    opid integer,
    year integer,
    obs_id text,
    date date,
    waypoint_name text,
    x numeric(20,10),
    y numeric(20,10),
    z numeric(20,2),
    description text,
    code_litho text,
    code_unit text,
    srid integer,
    geologist text,
    icon_descr text,
    comments text,
    sample_id text,
    datasource integer,
    numauto integer NOT NULL,
    photos text,
    audio text,
    timestamp_epoch_ms bigint,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"(),
    device text,
    "time" text
);
ALTER TABLE field_observations OWNER TO data_admin;
COMMENT ON TABLE field_observations IS 'Field observations: geological observations, on outcrops, floats, or any other observations; coherent with GeolPDA';
COMMENT ON COLUMN field_observations.opid IS 'Operation identifier';
COMMENT ON COLUMN field_observations.year IS 'Year when observation is done (TODO DROP COLUMN redundant with date field)';
COMMENT ON COLUMN field_observations.obs_id IS 'Observation identifier: usually composed of: (acronym of person)_(year)_(incremental integer)';
COMMENT ON COLUMN field_observations.date IS 'Observation date';
COMMENT ON COLUMN field_observations.waypoint_name IS 'If relevant, waypoint name from GPS device';
COMMENT ON COLUMN field_observations.x IS 'X coordinate (Easting),  in coordinate system srid';
COMMENT ON COLUMN field_observations.y IS 'Y coordinate (Northing), in coordinate system srid';
COMMENT ON COLUMN field_observations.z IS 'Z coordinate';
COMMENT ON COLUMN field_observations.description IS 'Naturalist description';
COMMENT ON COLUMN field_observations.code_litho IS 'Lithological code';
COMMENT ON COLUMN field_observations.code_unit IS 'Unit code: lithostratigraphic, and/or cartographic';
COMMENT ON COLUMN field_observations.srid IS 'Spatial Reference Identifier, or coordinate reference system: see spatial_ref_sys from postgis extension';
COMMENT ON COLUMN field_observations.geologist IS 'Geologist or prospector name';
COMMENT ON COLUMN field_observations.icon_descr IS 'If relevant, icon description from some GPS devices/programs';
COMMENT ON COLUMN field_observations.comments IS 'Comments';
COMMENT ON COLUMN field_observations.sample_id IS 'If relevant, sample identifier';
COMMENT ON COLUMN field_observations.datasource IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN field_observations.numauto IS 'Automatic integer primary key';
COMMENT ON COLUMN field_observations.photos IS 'List of photographs pictures files, if relevant';
COMMENT ON COLUMN field_observations.audio IS 'Audio recording files, if relevant';
COMMENT ON COLUMN field_observations.timestamp_epoch_ms IS 'Timestamp of observation: as defined in GeolPDA devices, as epoch in ms';
COMMENT ON COLUMN field_observations.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN field_observations.username IS 'User (role) which created data record';




SET search_path = public, pg_catalog;
--
-- Name: field_observations_struct_measures; Type: TABLE; Schema: public; Owner: data_admin; Tablespace: 
--
CREATE TABLE field_observations_struct_measures (
    opid integer,
    obs_id text,
    measure_type text,
    structure_type text,
    north_ref text,
    direction integer,
    dip integer,
    dip_quadrant text,
    pitch integer,
    pitch_quadrant text,
    movement text,
    valid boolean,
    comments text,
    numauto integer NOT NULL,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"(),
    datasource integer,
    rotation_matrix text,
    geolpda_id integer,
    geolpda_poi_id integer,
    sortgroup text,
    device text
);
ALTER TABLE field_observations_struct_measures OWNER TO data_admin;
--
-- Name: TABLE field_observations_struct_measures; Type: COMMENT; Schema: public; Owner: data_admin
--
COMMENT ON TABLE field_observations_struct_measures IS 'Structural measurements, related to an observation; coherent with GeolPDA';
COMMENT ON COLUMN field_observations_struct_measures.opid IS 'Operation identifier';
COMMENT ON COLUMN field_observations_struct_measures.obs_id IS 'Observation identifier: refers to field_observations table';
COMMENT ON COLUMN field_observations_struct_measures.measure_type IS 'Type of measurement: [P: plane L: line PL: plane line PLM: plane line movement PLMS: plane line movement sure]';
COMMENT ON COLUMN field_observations_struct_measures.structure_type IS 'Measured structure type: [VEIN , FRACTURE , C , SCHISTOSITY , FOLIATION , MYLONITE , CONTACT , VEIN_FAULT , FOLD_PAX_AX , FOLIATION_LINE , FAULT , CATACLASE , MINERALISED_STRUCTURE]';
COMMENT ON COLUMN field_observations_struct_measures.north_ref IS 'North reference for azimuths and directions measurements: [Nm: magnetic North, Ng: geographic North, Nu: UTM north, Nl: local grid Y axis]';
COMMENT ON COLUMN field_observations_struct_measures.direction IS 'Plane direction, 0-180°';
COMMENT ON COLUMN field_observations_struct_measures.dip IS 'Plane dip, 0-90°';
COMMENT ON COLUMN field_observations_struct_measures.dip_quadrant IS 'Plane dip quadrant, NESW';
COMMENT ON COLUMN field_observations_struct_measures.pitch IS 'Pitch of line on plane, 0-90°';
COMMENT ON COLUMN field_observations_struct_measures.pitch_quadrant IS 'Quadrant of pitch, NESW';
COMMENT ON COLUMN field_observations_struct_measures.movement IS 'Relative movement of fault/C: [N: normal, I: inverse = R = reverse, D: dextral, S: sinistral]';
COMMENT ON COLUMN field_observations_struct_measures.valid IS 'Measure is valid or not (impossible cases = not valid)';
COMMENT ON COLUMN field_observations_struct_measures.comments IS 'Comments';
COMMENT ON COLUMN field_observations_struct_measures.numauto IS 'Automatic integer primary key';
COMMENT ON COLUMN field_observations_struct_measures.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN field_observations_struct_measures.username IS 'User (role) which created data record';
COMMENT ON COLUMN field_observations_struct_measures.datasource IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN field_observations_struct_measures.rotation_matrix IS '3x3 rotation matrix, fully describing any orientation: initial state: [X axis points East, Y axis points North, Z axis points up] => measurement state = rotation applied. Corresponds to function public static float[] getOrientation (float[] R, float[] values) from android API as described in http://developer.android.com/reference/android/hardware/SensorManager.html#getOrientation%28float[],%20float[]%29';
COMMENT ON COLUMN field_observations_struct_measures.sortgroup IS 'Sorting group, for discriminated of various phases: a, b, c, ...';
COMMENT ON COLUMN field_observations_struct_measures.device IS 'Measuring device: compass, electronic device';




SET search_path = public, pg_catalog;
--
-- Name: field_photos; Type: TABLE; Schema: public; Owner: data_admin; Tablespace: 
--
CREATE TABLE field_photos (
    pho_id text NOT NULL,
    obs_id text,
    file text,
    description text,
    az numeric,
    dip numeric,
    author text,
    opid integer,
    datasource integer,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"(),
    numauto integer NOT NULL
);
ALTER TABLE field_photos OWNER TO data_admin;
--
-- Name: TABLE field_photos; Type: COMMENT; Schema: public; Owner: data_admin
--
COMMENT ON TABLE field_photos IS 'Photographs taken in field, related to an observation';
--
-- Name: COLUMN field_photos.opid; Type: COMMENT; Schema: public; Owner: data_admin
--
COMMENT ON COLUMN field_photos.opid IS 'Operation identifier';
COMMENT ON COLUMN field_photos.datasource IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN field_photos.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN field_photos.username IS 'User (role) which created data record';
COMMENT ON COLUMN field_photos.numauto IS 'Automatic integer';




SET search_path = public, pg_catalog;
--
-- Name: formations_group_lithos; Type: TABLE; Schema: public; Owner: data_admin; Tablespace: 
--
CREATE TABLE formations_group_lithos (
    opid integer,
    formation_name text,
    code_litho text,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"(),
    numauto integer NOT NULL,
    datasource integer
);
ALTER TABLE formations_group_lithos OWNER TO data_admin;
--
-- Name: TABLE formations_group_lithos; Type: COMMENT; Schema: public; Owner: data_admin
--
COMMENT ON TABLE formations_group_lithos IS 'Groups of lithologies, for simplification, typically for drill holes sections';
COMMENT ON COLUMN formations_group_lithos.opid IS 'Operation identifier';
COMMENT ON COLUMN formations_group_lithos.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN formations_group_lithos.username IS 'User (role) which created data record';
COMMENT ON COLUMN formations_group_lithos.numauto IS 'Automatic integer primary key';






--
-- Name: geoch_ana; Type: TABLE; Schema: public; Owner: data_admin; Tablespace: 
--
CREATE TABLE geoch_ana (
    sampl_index integer,
    ana_type text,
    unit text,
    det_lim numeric(6,4),
    scheme text,
    comment text,
    value numeric(10,3),
    numauto integer NOT NULL,
    opid integer,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"(),
    datasource integer
);
ALTER TABLE geoch_ana OWNER TO data_admin;
--
-- Name: TABLE geoch_ana; Type: COMMENT; Schema: public; Owner: data_admin
--
COMMENT ON TABLE geoch_ana IS 'Assay results from geochemistry samples';
--
-- Name: COLUMN geoch_ana.sampl_index; Type: COMMENT; Schema: public; Owner: data_admin
--
COMMENT ON COLUMN geoch_ana.sampl_index IS 'Sample identification related to the geoch_sampling table';
COMMENT ON COLUMN geoch_ana.ana_type IS 'Analysis type ';
COMMENT ON COLUMN geoch_ana.unit IS 'Unit of the analysis ';
COMMENT ON COLUMN geoch_ana.det_lim IS 'Analysis detection limit';
COMMENT ON COLUMN geoch_ana.scheme IS 'Analysis method';
COMMENT ON COLUMN geoch_ana.comment IS 'Some comments';
COMMENT ON COLUMN geoch_ana.value IS 'Analysis value';
COMMENT ON COLUMN geoch_ana.numauto IS 'Automatic integer primary key';
COMMENT ON COLUMN geoch_ana.opid IS 'Operation identifier';
COMMENT ON COLUMN geoch_ana.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN geoch_ana.username IS 'User (role) which created data record';
COMMENT ON COLUMN geoch_ana.datasource IS 'Datasource identifier, refers to lex_datasource';



SET search_path = public, pg_catalog;
--
-- Name: geoch_sampling; Type: TABLE; Schema: public; Owner: data_admin; Tablespace: 
--
CREATE TABLE geoch_sampling (
    id text,
    lab_id text,
    labo_ref text,
    amc_ref text,
    recep_date date,
    type text,
    sampl_index text NOT NULL,
    x numeric(15,4),
    y numeric(15,4),
    z numeric(10,4),
    soil_color text,
    type_sort text,
    depth_cm numeric(10,2),
    reg_type text,
    geomorphology text,
    rock_type text,
    comment text,
    utm_zone text,
    geologist text,
    float_sampl text,
    host_rock text,
    prospect text,
    spacing text,
    horizon text,
    datasource integer,
    date date,
    survey_type text,
    opid integer,
    grid_line text,
    grid_station text,
    alteration text,
    occ_soil text,
    slope text,
    slope_dir text,
    soil_description text,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"(),
    numauto integer NOT NULL
);
ALTER TABLE geoch_sampling OWNER TO data_admin;
COMMENT ON TABLE geoch_sampling IS 'Geochemistry samples, from soil or stream sediments, location and description';
COMMENT ON COLUMN geoch_sampling.id IS 'Identification';
COMMENT ON COLUMN geoch_sampling.lab_id IS 'Analysis laboratory';
COMMENT ON COLUMN geoch_sampling.labo_ref IS 'Analysis laboratory report reference';
COMMENT ON COLUMN geoch_sampling.amc_ref IS 'AMC analysis report reference';
COMMENT ON COLUMN geoch_sampling.recep_date IS 'Report reception date by AMC';
COMMENT ON COLUMN geoch_sampling.type IS 'Analysis type';
COMMENT ON COLUMN geoch_sampling.sampl_index IS 'Auto increment integer';
COMMENT ON COLUMN geoch_sampling.x IS 'X coordinate, projected in UTM (m)';
COMMENT ON COLUMN geoch_sampling.y IS 'Y coordinate, projected in UTM (m)';
COMMENT ON COLUMN geoch_sampling.z IS 'Z coordinate, projected in UTM (m)';
COMMENT ON COLUMN geoch_sampling.soil_color IS 'Soil color';
COMMENT ON COLUMN geoch_sampling.type_sort IS 'Sort of type';
COMMENT ON COLUMN geoch_sampling.depth_cm IS 'Sample depth';
COMMENT ON COLUMN geoch_sampling.reg_type IS 'Type of region';
COMMENT ON COLUMN geoch_sampling.geomorphology IS 'Some region description';
COMMENT ON COLUMN geoch_sampling.rock_type IS 'Lithology';
COMMENT ON COLUMN geoch_sampling.comment IS 'Some comments';
COMMENT ON COLUMN geoch_sampling.utm_zone IS 'UTM area';
COMMENT ON COLUMN geoch_sampling.geologist IS 'geologist';
COMMENT ON COLUMN geoch_sampling.float_sampl IS 'sample designation (?)';
COMMENT ON COLUMN geoch_sampling.host_rock IS 'host rock';
COMMENT ON COLUMN geoch_sampling.datasource IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN geoch_sampling.date IS 'type of survey (ex : HHGPS)';
COMMENT ON COLUMN geoch_sampling.opid IS 'Operation identifier';
COMMENT ON COLUMN geoch_sampling.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN geoch_sampling.username IS 'User (role) which created data record';
COMMENT ON COLUMN geoch_sampling.numauto IS 'Automatic integer';



SET search_path = public, pg_catalog;
--
-- Name: geoch_sampling_grades; Type: TABLE; Schema: public; Owner: data_admin; Tablespace: 
--
CREATE TABLE geoch_sampling_grades (
    numauto integer,
    au_ppb numeric
)
INHERITS (geoch_sampling);
ALTER TABLE geoch_sampling_grades OWNER TO data_admin;
COMMENT ON TABLE geoch_sampling_grades IS ' Geochemistry samples with grades; table inherits from geoch_sampling';
COMMENT ON COLUMN geoch_sampling_grades.datasource IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN geoch_sampling_grades.opid IS 'Operation identifier';
COMMENT ON COLUMN geoch_sampling_grades.numauto IS 'Automatic integer primary key';



--
-- Name: gps_wpt; Type: TABLE; Schema: pierre; Owner: pierre; Tablespace: 
--
CREATE TABLE gps_wpt (
    gid integer,
    numberofpo integer,
    nameofpoin text,
    altitude text,
    comment text,
    symbol text,
    display1 text,
    geolog text,
    descriptio text,
    code text,
    the_geom public.geometry,
    x numeric,
    y numeric,
    date text,
    "time" text,
    device text
);
ALTER TABLE gps_wpt OWNER TO pierre;




SET search_path = public, pg_catalog;
--
-- Name: gpy_mag_ground; Type: TABLE; Schema: public; Owner: data_admin; Tablespace: 
--

CREATE TABLE gpy_mag_ground (
    opid integer,
    srid integer,
    x numeric(10,2),
    y numeric(10,2),
    z numeric(10,2),
    x_local numeric(10,2),
    y_local numeric(10,2),
    mag_nanotesla double precision,
    val_corr_mag_nanotesla double precision,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"(),
    numauto integer NOT NULL,
    datasource integer
);

ALTER TABLE gpy_mag_ground OWNER TO data_admin;
COMMENT ON TABLE gpy_mag_ground IS ' Geophysics: ground mag';
COMMENT ON COLUMN gpy_mag_ground.opid IS 'Operation identifier';
COMMENT ON COLUMN gpy_mag_ground.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN gpy_mag_ground.username IS 'User (role) which created data record';
COMMENT ON COLUMN gpy_mag_ground.numauto IS 'Automatic integer primary key';
COMMENT ON COLUMN gpy_mag_ground.datasource IS 'Datasource identifier, refers to lex_datasource';




SET search_path = public, pg_catalog;
--
-- Name: grade_ctrl; Type: TABLE; Schema: public; Owner: data_admin; Tablespace: 
--
CREATE TABLE grade_ctrl (
    id text,
    num text,
    x numeric(10,2),
    y numeric(10,2),
    z numeric(10,2),
    prof numeric(10,2),
    aucy numeric(10,2),
    autot numeric(10,2),
    litho text,
    old_id text,
    numauto integer NOT NULL,
    aucy2 numeric(10,2),
    datasource integer,
    opid integer,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"()
);
ALTER TABLE grade_ctrl OWNER TO data_admin;
--
-- Name: TABLE grade_ctrl; Type: COMMENT; Schema: public; Owner: data_admin
--
COMMENT ON TABLE grade_ctrl IS 'Grade-control samples during mining exploitation';
--
-- Name: COLUMN grade_ctrl.id; Type: COMMENT; Schema: public; Owner: data_admin
--
COMMENT ON COLUMN grade_ctrl.id IS 'Quarry and block identification in 4 characters';
--
-- Name: COLUMN grade_ctrl.num; Type: COMMENT; Schema: public; Owner: data_admin
--
COMMENT ON COLUMN grade_ctrl.num IS 'sample number';
--
-- Name: COLUMN grade_ctrl.x; Type: COMMENT; Schema: public; Owner: data_admin
--
COMMENT ON COLUMN grade_ctrl.x IS 'X drill hole collar coordinate, projected in UTM (m)';
--
-- Name: COLUMN grade_ctrl.y; Type: COMMENT; Schema: public; Owner: data_admin
--
COMMENT ON COLUMN grade_ctrl.y IS 'Y drill hole collar coordinate, projected in UTM (m)';
--
-- Name: COLUMN grade_ctrl.z; Type: COMMENT; Schema: public; Owner: data_admin
--
COMMENT ON COLUMN grade_ctrl.z IS 'Z drill hole collar coordinate, projected in UTM (m)';
--
-- Name: COLUMN grade_ctrl.prof; Type: COMMENT; Schema: public; Owner: data_admin
--
COMMENT ON COLUMN grade_ctrl.prof IS 'End of sample depth';
--
-- Name: COLUMN grade_ctrl.aucy; Type: COMMENT; Schema: public; Owner: data_admin
--
COMMENT ON COLUMN grade_ctrl.aucy IS 'Sample cyanidable gold grade (g/t)';
--
-- Name: COLUMN grade_ctrl.autot; Type: COMMENT; Schema: public; Owner: data_admin
--
COMMENT ON COLUMN grade_ctrl.autot IS 'Total gold grade (g/t)';
--
-- Name: COLUMN grade_ctrl.litho; Type: COMMENT; Schema: public; Owner: data_admin
--
COMMENT ON COLUMN grade_ctrl.litho IS 'Sample lithology in GDM or Sermine code';
--
-- Name: COLUMN grade_ctrl.old_id; Type: COMMENT; Schema: public; Owner: data_admin
--
COMMENT ON COLUMN grade_ctrl.old_id IS 'Quarry and block old identification ';
--
-- Name: COLUMN grade_ctrl.numauto; Type: COMMENT; Schema: public; Owner: data_admin
--
COMMENT ON COLUMN grade_ctrl.numauto IS 'Automatic integer primary key';
--
-- Name: COLUMN grade_ctrl.datasource; Type: COMMENT; Schema: public; Owner: data_admin
--
COMMENT ON COLUMN grade_ctrl.datasource IS 'Datasource identifier, refers to lex_datasource';
--
-- Name: COLUMN grade_ctrl.opid; Type: COMMENT; Schema: public; Owner: data_admin
--
COMMENT ON COLUMN grade_ctrl.opid IS 'Operation identifier';
--
-- Name: COLUMN grade_ctrl.creation_ts; Type: COMMENT; Schema: public; Owner: data_admin
--
COMMENT ON COLUMN grade_ctrl.creation_ts IS 'Current date and time stamp when data is loaded in table';
--
-- Name: COLUMN grade_ctrl.username; Type: COMMENT; Schema: public; Owner: data_admin
--
COMMENT ON COLUMN grade_ctrl.username IS 'User (role) which created data record';








--
-- Name: grid; Type: TABLE; Schema: pierre; Owner: pierre; Tablespace: 
--
CREATE TABLE grid (
    line text,
    station text,
    x numeric,
    y numeric,
    srid integer,
    numauto integer NOT NULL,
    opid integer
);
ALTER TABLE grid OWNER TO pierre;







--
-- Name: rock_ana; Type: TABLE; Schema: pierre; Owner: pierre; Tablespace: 
--
CREATE TABLE rock_ana (
    hammer_index integer,
    value numeric(10,2),
    numauto integer NOT NULL,
    shipment date,
    reception date,
    amc_batch text,
    labo_batch text,
    comments text,
    ticket_id text,
    ana_type integer,
    opid integer
);
ALTER TABLE rock_ana OWNER TO pierre;
COMMENT ON COLUMN rock_ana.hammer_index IS 'Sample identification related to the hammer_sampling table';
COMMENT ON COLUMN rock_ana.value IS 'Analysis value';
COMMENT ON COLUMN rock_ana.numauto IS 'auto increment integer';




SET search_path = public, pg_catalog;
--
-- Name: index_geo_documentation; Type: TABLE; Schema: public; Owner: data_admin; Tablespace: 
--
CREATE TABLE index_geo_documentation (
    id integer NOT NULL,
    title text,
    lat_min numeric(20,8),
    lat_max numeric(20,8),
    lon_min numeric(20,8),
    lon_max numeric(20,8),
    opid integer,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"(),
    numauto integer NOT NULL,
    datasource integer,
    filename text
);
ALTER TABLE index_geo_documentation OWNER TO data_admin;
--
-- Name: TABLE index_geo_documentation; Type: COMMENT; Schema: public; Owner: data_admin
--
COMMENT ON TABLE index_geo_documentation IS 'Index for any documentation, with lat-lon rectangles, so that any documentation may be accessed geographically';
--
-- Name: COLUMN index_geo_documentation.opid; Type: COMMENT; Schema: public; Owner: data_admin
--
COMMENT ON COLUMN index_geo_documentation.opid IS 'Operation identifier';
--
-- Name: COLUMN index_geo_documentation.creation_ts; Type: COMMENT; Schema: public; Owner: data_admin
--
COMMENT ON COLUMN index_geo_documentation.creation_ts IS 'Current date and time stamp when data is loaded in table';
--
-- Name: COLUMN index_geo_documentation.username; Type: COMMENT; Schema: public; Owner: data_admin
--
COMMENT ON COLUMN index_geo_documentation.username IS 'User (role) which created data record';
--
-- Name: COLUMN index_geo_documentation.numauto; Type: COMMENT; Schema: public; Owner: data_admin
--
COMMENT ON COLUMN index_geo_documentation.numauto IS 'Automatic integer primary key';
--
-- Name: COLUMN index_geo_documentation.datasource; Type: COMMENT; Schema: public; Owner: data_admin
--
COMMENT ON COLUMN index_geo_documentation.datasource IS 'Datasource identifier, refers to lex_datasource';




SET search_path = public, pg_catalog;
--
-- Name: lab_ana_batches_expedition; Type: TABLE; Schema: public; Owner: data_admin; Tablespace: 
--
CREATE TABLE lab_ana_batches_expedition (
    opid integer,
    batch_id integer,
    labname text,
    expedition_id text,
    order_id text,
    description text,
    preparation text,
    process_labo text,
    scheme text,
    shipment_date date,
    sent_to_lab boolean,
    reception_date date,
    results_received boolean,
    lab_batches text,
    comments text,
    samples_amount integer,
    sample_id_first text,
    sample_id_last text,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"(),
    numauto integer NOT NULL,
    datasource integer
);
ALTER TABLE lab_ana_batches_expedition OWNER TO data_admin;
COMMENT ON TABLE lab_ana_batches_expedition IS 'Batches of samples sent for analysis';
COMMENT ON COLUMN lab_ana_batches_expedition.opid IS 'Operation identifier';
COMMENT ON COLUMN lab_ana_batches_expedition.batch_id IS 'Batch identifier; recommended is 7-digit number, year and sequential number on 3 digits';
COMMENT ON COLUMN lab_ana_batches_expedition.labname IS 'Destination assay laboratory name';
COMMENT ON COLUMN lab_ana_batches_expedition.expedition_id IS 'Identifier of expedition (this is usually useless, if batches correspond to expeditions)';
COMMENT ON COLUMN lab_ana_batches_expedition.order_id IS 'Order identifier (DA number)';
COMMENT ON COLUMN lab_ana_batches_expedition.description IS 'Quick description of samples: rocks, soils, core, chips, rocktypes if relevant, etc.';
COMMENT ON COLUMN lab_ana_batches_expedition.preparation IS 'Preparation of samples prior to expedition to lab (crushing, grinding, splitting, etc.)';
COMMENT ON COLUMN lab_ana_batches_expedition.process_labo IS 'Required preparation of samples in laboratory';
COMMENT ON COLUMN lab_ana_batches_expedition.scheme IS 'Required assay scheme';
COMMENT ON COLUMN lab_ana_batches_expedition.shipment_date IS 'Date of batch expedition to laboratory';
COMMENT ON COLUMN lab_ana_batches_expedition.sent_to_lab IS 'Boolean: batch sent to laboratory or not';
COMMENT ON COLUMN lab_ana_batches_expedition.reception_date IS 'Date of batch received';
COMMENT ON COLUMN lab_ana_batches_expedition.results_received IS 'Boolean: results received for this batch (useful if laboratory returns results according to expedition batches (recommended); irrelevant otherwise)';
COMMENT ON COLUMN lab_ana_batches_expedition.lab_batches IS 'List of laboratory batches, if any; useless if laboratory batches correspond to expedition batches';
COMMENT ON COLUMN lab_ana_batches_expedition.comments IS 'Specific comments, reason for assay (control re-assay, re-sampling, routine, etc.)';
COMMENT ON COLUMN lab_ana_batches_expedition.samples_amount IS 'Number of samples';
COMMENT ON COLUMN lab_ana_batches_expedition.sample_id_first IS 'First sample identifier; only relevant if samples in sequence';
COMMENT ON COLUMN lab_ana_batches_expedition.sample_id_last IS 'Last sample identifier; only relevant if samples in sequence';
COMMENT ON COLUMN lab_ana_batches_expedition.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN lab_ana_batches_expedition.username IS 'User (role) which created data record';
COMMENT ON COLUMN lab_ana_batches_expedition.numauto IS 'Automatic integer primary key';
COMMENT ON COLUMN lab_ana_batches_expedition.datasource IS 'Datasource identifier, refers to lex_datasource';



SET search_path = public, pg_catalog;
--
-- Name: lab_ana_batches_reception; Type: TABLE; Schema: public; Owner: data_admin; Tablespace: 
--
CREATE TABLE lab_ana_batches_reception (
    opid integer,
    jobno text,
    generic_txt text,
    numauto integer NOT NULL,
    datasource integer,
    labname text,
    client text,
    validated date,
    number_of_samples integer,
    project text,
    shipment_id text,
    p_o_number text,
    received date,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"(),
    certificate_comments text,
    info_suppl_json text
);
ALTER TABLE lab_ana_batches_reception OWNER TO data_admin;
COMMENT ON TABLE lab_ana_batches_reception IS 'Batches of samples results received from laboratory';
COMMENT ON COLUMN lab_ana_batches_reception.opid IS 'Operation identifier';
COMMENT ON COLUMN lab_ana_batches_reception.jobno IS 'As in files received from laboratory: job number';
COMMENT ON COLUMN lab_ana_batches_reception.generic_txt IS 'Generic text, containing information from original results file as is, unformatted';
COMMENT ON COLUMN lab_ana_batches_reception.numauto IS 'Automatic integer primary key';
COMMENT ON COLUMN lab_ana_batches_reception.datasource IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN lab_ana_batches_reception.labname IS 'As in files received from laboratory: full laboratory name';
COMMENT ON COLUMN lab_ana_batches_reception.client IS 'As in files received from laboratory: client name';
COMMENT ON COLUMN lab_ana_batches_reception.validated IS 'As in files received from laboratory: validation date';
COMMENT ON COLUMN lab_ana_batches_reception.number_of_samples IS 'As in files received from laboratory: number of samples';
COMMENT ON COLUMN lab_ana_batches_reception.project IS 'As in files received from laboratory: project name';
COMMENT ON COLUMN lab_ana_batches_reception.shipment_id IS 'As in files received from laboratory: shipment id';
COMMENT ON COLUMN lab_ana_batches_reception.p_o_number IS 'As in files received from laboratory: P.O. number';
COMMENT ON COLUMN lab_ana_batches_reception.received IS 'As in files received from laboratory: reception date';
COMMENT ON COLUMN lab_ana_batches_reception.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN lab_ana_batches_reception.username IS 'User (role) which created data record';
COMMENT ON COLUMN lab_ana_batches_reception.certificate_comments IS 'As in files received from laboratory: certificate comments';
COMMENT ON COLUMN lab_ana_batches_reception.info_suppl_json IS 'Supplementary information, serialised as a JSON (validated by json_xs)';



--
-- Name: lab_ana_batches_reception_18_corr; Type: TABLE; Schema: pierre; Owner: pierre; Tablespace: 
--
CREATE TABLE lab_ana_batches_reception_18_corr (
    opid integer,
    jobno text,
    generic_txt text,
    numauto integer,
    datasource integer,
    labname text,
    client text,
    validated date,
    number_of_samples integer,
    project text,
    shipment_id text,
    p_o_number text,
    received date,
    creation_ts timestamp without time zone,
    username text,
    certificate_comments text,
    info_suppl_json text
);
ALTER TABLE lab_ana_batches_reception_18_corr OWNER TO pierre;




SET search_path = public, pg_catalog;
--
-- Name: lab_ana_columns_definition; Type: TABLE; Schema: public; Owner: data_admin; Tablespace: 
--
CREATE TABLE lab_ana_columns_definition (
    analyte text,
    unit text,
    scheme text,
    colid text,
    opid integer,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"(),
    numauto integer NOT NULL
);
ALTER TABLE lab_ana_columns_definition OWNER TO data_admin;
--
-- Name: TABLE lab_ana_columns_definition; Type: COMMENT; Schema: public; Owner: data_admin
--
COMMENT ON TABLE lab_ana_columns_definition IS 'Definition of columns; obsolete';
COMMENT ON COLUMN lab_ana_columns_definition.analyte IS 'Analyte';
COMMENT ON COLUMN lab_ana_columns_definition.unit IS 'Unit (PPM, PPB, etc.)';
COMMENT ON COLUMN lab_ana_columns_definition.colid IS 'Column identifier, used for groupings in cross-tab queries';
COMMENT ON COLUMN lab_ana_columns_definition.opid IS 'Operation identifier';
COMMENT ON COLUMN lab_ana_columns_definition.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN lab_ana_columns_definition.username IS 'User (role) which created data record';
COMMENT ON COLUMN lab_ana_columns_definition.numauto IS 'Automatic integer primary key';



SET search_path = public, pg_catalog;
--
-- Name: lab_ana_qaqc_results; Type: TABLE; Schema: public; Owner: data_admin; Tablespace: 
--
CREATE TABLE lab_ana_qaqc_results (
    opid integer,
    jobno text,
    generic_txt_col1 text,
    generic_txt_col2 text,
    generic_txt_col3 text,
    generic_txt_col4 text,
    generic_txt_col5 text,
    datasource integer,
    numauto integer NOT NULL,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"()
);
ALTER TABLE lab_ana_qaqc_results OWNER TO data_admin;
COMMENT ON TABLE lab_ana_qaqc_results IS 'Quality control assay results, internal to analytical laboratory';
COMMENT ON COLUMN lab_ana_qaqc_results.opid IS 'Operation identifier';
COMMENT ON COLUMN lab_ana_qaqc_results.jobno IS 'Job number';
COMMENT ON COLUMN lab_ana_qaqc_results.generic_txt_col1 IS 'Generic text field, receiving any text from original file, as is';
COMMENT ON COLUMN lab_ana_qaqc_results.generic_txt_col2 IS 'Generic text field, receiving any text from original file, as is';
COMMENT ON COLUMN lab_ana_qaqc_results.generic_txt_col3 IS 'Generic text field, receiving any text from original file, as is';
COMMENT ON COLUMN lab_ana_qaqc_results.generic_txt_col4 IS 'Generic text field, receiving any text from original file, as is';
COMMENT ON COLUMN lab_ana_qaqc_results.generic_txt_col5 IS 'Generic text field, receiving any text from original file, as is';
COMMENT ON COLUMN lab_ana_qaqc_results.datasource IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN lab_ana_qaqc_results.numauto IS 'Automatic integer primary key';
COMMENT ON COLUMN lab_ana_qaqc_results.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN lab_ana_qaqc_results.username IS 'User (role) which created data record';




--
-- Name: lab_analysis_icp; Type: TABLE; Schema: pierre; Owner: pierre; Tablespace: 
--
CREATE TABLE lab_analysis_icp (
    num integer,
    sample_id text,
    elem_code text,
    unit text,
    value numeric(20,2),
    batch_id text,
    opid integer
);
ALTER TABLE lab_analysis_icp OWNER TO pierre;



--
-- Name: layer_styles; Type: TABLE; Schema: pierre; Owner: pierre; Tablespace: 
--
CREATE TABLE layer_styles (
    id integer NOT NULL,
    f_table_catalog text,
    f_table_schema text,
    f_table_name text,
    f_geometry_column text,
    stylename text,
    styleqml xml,
    stylesld xml,
    useasdefault boolean,
    description text,
    owner text,
    ui xml,
    update_time timestamp without time zone DEFAULT now()
);
ALTER TABLE layer_styles OWNER TO pierre;



SET search_path = public, pg_catalog;
--
-- Name: lex_codes; Type: TABLE; Schema: public; Owner: data_admin; Tablespace: 
--
CREATE TABLE lex_codes (
    opid integer,
    tablename text,
    field text,
    code text,
    description text,
    datasource integer,
    numauto integer NOT NULL,
    comments text,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"()
);
ALTER TABLE lex_codes OWNER TO data_admin;
--
-- Name: TABLE lex_codes; Type: COMMENT; Schema: public; Owner: data_admin
--
COMMENT ON TABLE lex_codes IS 'General look-up table with codes for various tables and coded fields';
COMMENT ON COLUMN lex_codes.opid IS 'Operation identifier';
COMMENT ON COLUMN lex_codes.datasource IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN lex_codes.numauto IS 'Automatic integer primary key';
COMMENT ON COLUMN lex_codes.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN lex_codes.username IS 'User (role) which created data record';



SET search_path = public, pg_catalog;
--
-- Name: lex_datasource; Type: TABLE; Schema: public; Owner: data_admin; Tablespace: 
--
CREATE TABLE lex_datasource (
    opid integer,
    filename text,
    comments text,
    datasource_id integer NOT NULL,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"(),
    numauto integer NOT NULL
);
ALTER TABLE lex_datasource OWNER TO data_admin;
COMMENT ON TABLE lex_datasource IS 'Lexicon of data sources, keeping track of imported file, for reference';
COMMENT ON COLUMN lex_datasource.opid IS 'Operation identifier';
COMMENT ON COLUMN lex_datasource.filename IS 'Data imported: file name with full path, to be kept for permanent reference';
COMMENT ON COLUMN lex_datasource.comments IS 'Various comments';
COMMENT ON COLUMN lex_datasource.datasource_id IS 'datasource field in various tables refer to this datasource_id field';
COMMENT ON COLUMN lex_datasource.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN lex_datasource.username IS 'User (role) which created data record';
COMMENT ON COLUMN lex_datasource.numauto IS 'Automatic integer primary key';



SET search_path = public, pg_catalog;
--
-- Name: lex_standard; Type: TABLE; Schema: public; Owner: data_admin; Tablespace: 
--
CREATE TABLE lex_standard (
    std_id text NOT NULL,
    unit text NOT NULL,
    element text NOT NULL,
    value numeric NOT NULL,
    std_dev numeric,
    interval_conf numeric,
    std_origin text,
    type_analyse text NOT NULL,
    numauto integer NOT NULL,
    opid integer,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"(),
    datasource integer
);
ALTER TABLE lex_standard OWNER TO data_admin;
COMMENT ON TABLE lex_standard IS 'table contenant les valeurs des standards or et multi elements';
COMMENT ON COLUMN lex_standard.numauto IS 'Automatic integer primary key';
COMMENT ON COLUMN lex_standard.opid IS 'Operation identifier';
COMMENT ON COLUMN lex_standard.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN lex_standard.username IS 'User (role) which created data record';
COMMENT ON COLUMN lex_standard.datasource IS 'Datasource identifier, refers to lex_datasource';



SET search_path = public, pg_catalog;
--
-- Name: licences; Type: TABLE; Schema: public; Owner: data_admin; Tablespace: 
--
CREATE TABLE licences (
    opid integer,
    licence_name text,
    operator text,
    year integer,
    lat_min numeric(10,5) NOT NULL,
    lon_min numeric(10,5) NOT NULL,
    lat_max numeric(10,5) NOT NULL,
    lon_max numeric(10,5) NOT NULL,
    comments text,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"(),
    numauto integer NOT NULL,
    datasource integer,
    geometry_literal_description_plain_txt text,
    geometry_wkt text
);
ALTER TABLE licences OWNER TO data_admin;
COMMENT ON TABLE licences IS 'Licences, tenements';
COMMENT ON COLUMN licences.opid IS 'Operation identifier';
COMMENT ON COLUMN licences.licence_name IS 'Licence official name, as reported on legal documents';
COMMENT ON COLUMN licences.operator IS 'Operator, owner of licence';
COMMENT ON COLUMN licences.year IS 'Year when information is valid';
COMMENT ON COLUMN licences.lat_min IS 'Minimum latitude';
COMMENT ON COLUMN licences.lon_min IS 'Minimum longitude';
COMMENT ON COLUMN licences.lat_max IS 'Maximum latitude';
COMMENT ON COLUMN licences.lon_max IS 'Maximum longitude';
COMMENT ON COLUMN licences.comments IS 'Comments';
COMMENT ON COLUMN licences.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN licences.username IS 'User (role) which created data record';
COMMENT ON COLUMN licences.numauto IS 'Automatic integer';
COMMENT ON COLUMN licences.datasource IS 'Datasource identifier, refers to lex_datasource';



--
-- Name: mag_declination; Type: TABLE; Schema: public; Owner: data_admin; Tablespace: 
--
CREATE TABLE mag_declination (
    opid integer,
    mag_decl numeric,
    numauto integer NOT NULL,
    date date,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"(),
    datasource integer
);
ALTER TABLE mag_declination OWNER TO data_admin;
COMMENT ON TABLE mag_declination IS 'Magnetic declination';
COMMENT ON COLUMN mag_declination.opid IS 'Operation identifier';
COMMENT ON COLUMN mag_declination.numauto IS 'Automatic integer primary key';
COMMENT ON COLUMN mag_declination.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN mag_declination.username IS 'User (role) which created data record';
COMMENT ON COLUMN mag_declination.datasource IS 'Datasource identifier, refers to lex_datasource';



SET search_path = public, pg_catalog;
--
-- Name: occurrences; Type: TABLE; Schema: public; Owner: data_admin; Tablespace: 
--
CREATE TABLE occurrences (
    numauto integer,
    name text,
    status text,
    description text,
    w_done text,
    w_todo text,
    geom geometry,
    code text,
    opid integer,
    zone text,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"(),
    datasource integer,
    comments text,
    --numauto_auto integer NOT NULL,
    CONSTRAINT chk_status CHECK (((status)::text = ANY (ARRAY[('OCCUR'::text)::text, ('OREB'::text)::text, ('MINE'::text)::text, ('MINED'::text)::text, ('MCO'::text)::text, ('DISTRICT'::text)::text]))),
    CONSTRAINT enforce_geotype_geom CHECK (((geometrytype(geom) = 'POINT'::text) OR (geom IS NULL)))
);
ALTER TABLE occurrences OWNER TO data_admin;
COMMENT ON TABLE occurrences IS 'Occurences table: targets, mines, showings, deposits, mines. Compiled from various tables, and updated.';
COMMENT ON COLUMN occurrences.numauto IS 'Automatic integer primary key';
COMMENT ON COLUMN occurrences.name IS 'Occurence name';
COMMENT ON COLUMN occurrences.status IS 'Status: OCCUR = occurence ; OREB = orebody ; MINE = active mine ; MINED = exploited, depleted mine';
COMMENT ON COLUMN occurrences.description IS 'Occurence description: geological context, significant figures at current stage of exploration or exploitation';
COMMENT ON COLUMN occurrences.w_done IS 'Exploration work done, codified field: PROSPection (rock sampling on surface), SOIL geochemistry, MAPping, DECAPage, TRenches, Drill Holes';
COMMENT ON COLUMN occurrences.w_todo IS 'Exploration work to be done, codified field: PROSPection (rock sampling on surface), SOIL geochemistry, MAPping, DECAPage, TRenches, Drill Holes';
COMMENT ON COLUMN occurrences.opid IS 'Operation identifier';
COMMENT ON COLUMN occurrences.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN occurrences.username IS 'User (role) which created data record';
COMMENT ON COLUMN occurrences.datasource IS 'Datasource identifier, refers to lex_datasource';



SET search_path = public, pg_catalog;
--
-- Name: operations; Type: TABLE; Schema: public; Owner: data_admin; Tablespace: 
--
CREATE TABLE operations (
    opid integer NOT NULL,
    operation text,
    full_name text,
    operator text,
    year integer,
    confidentiality boolean DEFAULT true,
    lat_min numeric(10,5) NOT NULL,
    lon_min numeric(10,5) NOT NULL,
    lat_max numeric(10,5),
    lon_max numeric(10,5),
    comments text,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"(),
    numauto integer NOT NULL
);
ALTER TABLE operations OWNER TO data_admin;
COMMENT ON TABLE operations IS 'Operations, projects, operator or client name';
COMMENT ON COLUMN operations.opid IS 'Operation identifier';
COMMENT ON COLUMN operations.operation IS 'Operation code';
COMMENT ON COLUMN operations.full_name IS 'Complete operation name';
COMMENT ON COLUMN operations.operator IS 'Operator: mining operator, exploration company, client name';
COMMENT ON COLUMN operations.year IS 'Year of operation activity';
COMMENT ON COLUMN operations.confidentiality IS 'Confidentiality flag, true or false; default is true';
COMMENT ON COLUMN operations.lat_min IS 'South latitude, decimal degrees, WGS84';
COMMENT ON COLUMN operations.lon_min IS 'West longitude, decimal degrees, WGS84';
COMMENT ON COLUMN operations.lat_max IS 'North latitude, decimal degrees, WGS84';
COMMENT ON COLUMN operations.lon_max IS 'East latitude, decimal degrees, WGS84';
COMMENT ON COLUMN operations.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN operations.username IS 'User (role) which created data record';
COMMENT ON COLUMN operations.numauto IS 'Automatic integer';




--
-- Name: program; Type: TABLE; Schema: pierre; Owner: pierre; Tablespace: 
--
CREATE TABLE program (
    gid integer NOT NULL,
    myid integer,
    geometry public.geometry,
    id text,
    completed boolean,
    opid integer,
    CONSTRAINT enforce_geotype_geometry CHECK (((public.geometrytype(geometry) = 'POINT'::text) OR (geometry IS NULL)))
);
ALTER TABLE program OWNER TO pierre;





--
-- Name: qc_sampling; Type: TABLE; Schema: public; Owner: data_admin; Tablespace: 
--
CREATE TABLE qc_sampling (
    sample_id text,
    qc_type text,
    comments text,
    opid integer,
    batch_id integer,
    refers_to text,
    datasource integer,
    weight_kg numeric(6,2),
    numauto integer NOT NULL,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"()
);
ALTER TABLE qc_sampling OWNER TO data_admin;
COMMENT ON TABLE qc_sampling IS 'Quality control samples: duplicates, blanks, standards';
COMMENT ON COLUMN qc_sampling.opid IS 'Operation identifier';
COMMENT ON COLUMN qc_sampling.datasource IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN qc_sampling.numauto IS 'Automatic integer primary key';
COMMENT ON COLUMN qc_sampling.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN qc_sampling.username IS 'User (role) which created data record';





--
-- Name: qc_standards; Type: TABLE; Schema: public; Owner: data_admin; Tablespace: 
--
CREATE TABLE qc_standards (
    qc_id text NOT NULL,
    labo text,
    matrix text,
    presentation text,
    au_ppm numeric(10,3),
    cu_ppm numeric(10,3),
    zn_ppm numeric(10,3),
    pb_ppm numeric(10,3),
    ag_ppm numeric(10,3),
    ni_ppm numeric(10,3),
    au_ppm_95pc_conf_interval numeric,
    cu_ppm_95pc_conf_interval numeric,
    zn_ppm_95pc_conf_interval numeric,
    pb_ppm_95pc_conf_interval numeric,
    ag_ppm_95pc_conf_interval numeric,
    ni_ppm_95pc_conf_interval numeric,
    opid integer,
    datasource integer,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"(),
    numauto integer NOT NULL
);
ALTER TABLE qc_standards OWNER TO data_admin;
COMMENT ON TABLE qc_standards IS 'Quality Control standard samples, most of them are CRM (Certified Reference Materials)';
COMMENT ON COLUMN qc_standards.qc_id IS 'sample identification';
COMMENT ON COLUMN qc_standards.labo IS 'sample laboratory';
COMMENT ON COLUMN qc_standards.matrix IS 'sample composition';
COMMENT ON COLUMN qc_standards.presentation IS 'sample presentation';
COMMENT ON COLUMN qc_standards.au_ppm IS 'sample analysis value';
COMMENT ON COLUMN qc_standards.cu_ppm IS 'sample analysis value';
COMMENT ON COLUMN qc_standards.zn_ppm IS 'sample analysis value';
COMMENT ON COLUMN qc_standards.pb_ppm IS 'sample analysis value';
COMMENT ON COLUMN qc_standards.ag_ppm IS 'sample analysis value';
COMMENT ON COLUMN qc_standards.ni_ppm IS 'sample analysis value';
COMMENT ON COLUMN qc_standards.opid IS 'Operation identifier';
COMMENT ON COLUMN qc_standards.datasource IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN qc_standards.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN qc_standards.username IS 'User (role) which created data record';
COMMENT ON COLUMN qc_standards.numauto IS 'Automatic integer primary key';




--
-- Name: rock_sampling; Type: TABLE; Schema: pierre; Owner: pierre; Tablespace: 
--
CREATE TABLE rock_sampling (
    geologist text,
    num text,
    x numeric(10,2),
    y numeric(10,2),
    z numeric(10,2),
    hammer_index integer NOT NULL,
    datasource integer,
    description text,
    location text,
    opid integer
);
ALTER TABLE rock_sampling OWNER TO pierre;
COMMENT ON TABLE rock_sampling IS 'outcrop sampling  (taken with geological hammer)';
COMMENT ON COLUMN rock_sampling.geologist IS 'geologist name';
COMMENT ON COLUMN rock_sampling.num IS 'sample name or number';
COMMENT ON COLUMN rock_sampling.x IS 'X coordinate';
COMMENT ON COLUMN rock_sampling.y IS 'Y coordinate';
COMMENT ON COLUMN rock_sampling.z IS 'Z coordinate';
COMMENT ON COLUMN rock_sampling.hammer_index IS 'integer related to the hammer_ana table';


CREATE TABLE sections_definition (
    opid integer,
    id integer NOT NULL,
    location text,
    srid integer,
    ll_corner_x numeric(10,2),
    ll_corner_y numeric(10,2),
    ll_corner_z numeric(10,2),
    azim_ng numeric(10,2),
    "interval" numeric(10,0),
    num_start integer DEFAULT 1,
    count numeric(3,0),
    length numeric(5,0),
    title text
);
ALTER TABLE sections_definition OWNER TO pierre;
COMMENT ON COLUMN sections_definition.opid IS 'Operation identifier';
COMMENT ON COLUMN sections_definition.location IS 'Drilling area';
COMMENT ON COLUMN sections_definition.ll_corner_x IS 'X coordinate of lower left corner of gridded area';
COMMENT ON COLUMN sections_definition.ll_corner_y IS 'y coordinate of lower left corner of gridded area';
COMMENT ON COLUMN sections_definition.ll_corner_z IS 'z coordinate of lower left corner of gridded area';
COMMENT ON COLUMN sections_definition.azim_ng IS 'Base line azimuth relative to true North';
COMMENT ON COLUMN sections_definition."interval" IS 'distance between two adjacent sections, i.e. 25m';
COMMENT ON COLUMN sections_definition.num_start IS 'first section number (default 1)';
COMMENT ON COLUMN sections_definition.count IS 'number of sections';
COMMENT ON COLUMN sections_definition.length IS 'sections length';
COMMENT ON COLUMN sections_definition.title IS 'section title, to be displayed before section number';


SET search_path = public, pg_catalog;
--
-- Name: surface_samples_grades; Type: TABLE; Schema: public; Owner: data_admin; Tablespace: 
--

CREATE TABLE surface_samples_grades (
    opid integer,
    sample_id text,
    x double precision,
    y double precision,
    z double precision,
    srid integer,
    description text,
    sample_type text,
    outcrop_id text,
    trend text,
    dip text,
    length_m text,
    width_m text,
    au1_ppm double precision,
    au2_ppm double precision,
    ag1_ double precision,
    ag2_ double precision,
    cu1_ double precision,
    cu2_ double precision,
    as_ double precision,
    pb_ double precision,
    zn_ double precision,
    k2o_ double precision,
    ba_ double precision,
    sio2_ double precision,
    al2x_ double precision,
    fe2x_ double precision,
    mno_ double precision,
    tio2_ double precision,
    p2o5_ double precision,
    cao_ double precision,
    mgo_ double precision,
    mo_ double precision,
    sn_ double precision,
    sb_ double precision,
    w_ double precision,
    bi_ double precision,
    zr_ double precision,
    li_ double precision,
    b_ double precision,
    v_ double precision,
    cr_ double precision,
    ni_ double precision,
    co_ double precision,
    sr_ double precision,
    y_ double precision,
    la_ double precision,
    ce_ double precision,
    nb_ double precision,
    be_ double precision,
    cd_ double precision,
    spp2 double precision,
    numauto integer NOT NULL,
    creation_ts timestamp without time zone DEFAULT now(),
    username text DEFAULT "current_user"(),
    datasource integer,
    campaign text
);
ALTER TABLE surface_samples_grades OWNER TO data_admin;
COMMENT ON TABLE surface_samples_grades IS 'Ponctual samples taken from surface: stream sediments, alluvial sediments, till, soils, termite mounds, rock outcrops, floats, etc. with grades';
COMMENT ON COLUMN surface_samples_grades.opid IS 'Operation identifier';
COMMENT ON COLUMN surface_samples_grades.numauto IS 'Automatic integer primary key';
COMMENT ON COLUMN surface_samples_grades.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN surface_samples_grades.username IS 'User (role) which created data record';
COMMENT ON COLUMN surface_samples_grades.datasource IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN surface_samples_grades.campaign IS 'Campaign: year, type, etc. i.e. till exploration 1967';



CREATE TABLE doc_bdexplo_tables_descriptions (
    tablename text NOT NULL,
    category text,
    comment_fr text,
    numauto integer NOT NULL
);
ALTER TABLE doc_bdexplo_tables_descriptions OWNER TO pierre;




CREATE TABLE survey_lines (
    opid numeric,
    id text,
    x_start numeric,
    y_start numeric,
    x_end numeric,
    y_end numeric,
    length numeric,
    numauto integer NOT NULL,
    srid numeric
);
ALTER TABLE survey_lines OWNER TO pierre;
COMMENT ON TABLE survey_lines IS 'Survey lines, for geophysics or other types of linear surveys; defined with start and end points.';



CREATE TABLE units (
    unit_name text,
    unit_factor real
);
ALTER TABLE units OWNER TO pierre;
COMMENT ON TABLE units IS 'Units, with multiplicator factor';
COMMENT ON COLUMN units.unit_name IS 'Unit abbreviated name, uppercase';
COMMENT ON COLUMN units.unit_factor IS 'Multiplication factor';



CREATE TABLE conversions_oxydes_elements (
    oxide text,
    molecular_weight numeric,
    factor numeric
);
ALTER TABLE conversions_oxydes_elements OWNER TO pierre;
--
-- Name: TABLE conversions_oxydes_elements; Type: COMMENT; Schema: public; Owner: pierre
--
COMMENT ON TABLE conversions_oxydes_elements IS 'Molecular weights of some oxides and factors to convert them to elements by weight.';

}}}
*/

x reste à voir:{{{

--
-- Name: dh_collars_points_marrec; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW dh_collars_points_marrec AS
 SELECT dh_collars.id,
    dh_collars.shid,
    dh_collars.location,
    dh_collars.profile,
    dh_collars.srid,
    dh_collars.x,
    dh_collars.y,
    dh_collars.z,
    dh_collars.azim_ng,
    dh_collars.azim_nm,
    dh_collars.dip_hz,
    dh_collars.dh_type,
    dh_collars.date_start,
    dh_collars.contractor,
    dh_collars.geologist,
    dh_collars.length,
    dh_collars.nb_samples,
    dh_collars.comments,
    dh_collars.completed,
    dh_collars.numauto,
    dh_collars.date_completed,
    dh_collars.opid,
    dh_collars.purpose,
    dh_collars.x_local,
    dh_collars.y_local,
    dh_collars.z_local,
    dh_collars.accusum,
    dh_collars.id_pject,
    dh_collars.x_pject,
    dh_collars.y_pject,
    dh_collars.z_pject,
    dh_collars.topo_survey_type,
    dh_collars.creation_ts,
    dh_collars.username,
    dh_collars.datasource,
    public.geomfromewkt((((('POINT('::text || dh_collars.x_local) || ' '::text) || dh_collars.y_local) || ' )'::text)) AS geomfromewkt
   FROM dh_collars
  WHERE ((dh_collars.x_local IS NOT NULL) AND (dh_collars.y_local IS NOT NULL));
ALTER TABLE dh_collars_points_marrec OWNER TO pierre;


--
-- Name: dh_mineralised_intervals0_traces_3d; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW dh_mineralised_intervals0_traces_3d AS
 SELECT tmp.opid,
    tmp.id,
    tmp.srid,
    tmp.x,
    tmp.y,
    tmp.z,
    tmp.azim_ng,
    tmp.dip_hz,
    tmp.depfrom,
    tmp.depto,
    tmp.mine,
    tmp.avau,
    tmp.stva,
    tmp.accu,
    tmp.mineralisation_stretch_value_label,
    tmp.numauto,
    tmp.x1,
    tmp.y1,
    tmp.z1,
    tmp.x2,
    tmp.y2,
    tmp.z2,
    public.geomfromewkt((((((((((((((('SRID='::text || tmp.srid) || ';LINESTRING ('::text) || tmp.x1) || ' '::text) || tmp.y1) || ' '::text) || tmp.z1) || ', '::text) || tmp.x2) || ' '::text) || tmp.y2) || ' '::text) || tmp.z2) || ')'::text)) AS geomfromewkt
   FROM ( SELECT dh_mineralised_intervals.opid,
            dh_mineralised_intervals.id,
            dh_collars.srid,
            dh_collars.x,
            dh_collars.y,
            dh_collars.z,
            dh_collars.azim_ng,
            dh_collars.dip_hz,
            dh_mineralised_intervals.depfrom,
            dh_mineralised_intervals.depto,
            dh_mineralised_intervals.mine,
            dh_mineralised_intervals.avau,
            dh_mineralised_intervals.stva,
            dh_mineralised_intervals.accu,
            (((((((dh_collars.id)::text || ': '::text) || replace(to_char(dh_mineralised_intervals.depfrom, 'FM99990.99'::text), '.'::text, ''::text)) || '-'::text) || replace(to_char(dh_mineralised_intervals.depto, 'FM99990.99'::text), '.'::text, ''::text)) || 'm => '::text) || (dh_mineralised_intervals.stva)::text) AS mineralisation_stretch_value_label,
            dh_mineralised_intervals.numauto,
            ((dh_collars.x)::double precision + (((dh_mineralised_intervals.depfrom)::double precision * cos((((dh_collars.dip_hz / (180)::numeric))::double precision * pi()))) * sin((((dh_collars.azim_ng / (180)::numeric))::double precision * pi())))) AS x1,
            ((dh_collars.y)::double precision + (((dh_mineralised_intervals.depfrom)::double precision * cos((((dh_collars.dip_hz / (180)::numeric))::double precision * pi()))) * cos((((dh_collars.azim_ng / (180)::numeric))::double precision * pi())))) AS y1,
            ((dh_collars.z)::double precision - ((dh_mineralised_intervals.depfrom)::double precision * sin((((dh_collars.dip_hz / (180)::numeric))::double precision * pi())))) AS z1,
            ((dh_collars.x)::double precision + (((dh_mineralised_intervals.depto)::double precision * cos((((dh_collars.dip_hz / (180)::numeric))::double precision * pi()))) * sin((((dh_collars.azim_ng / (180)::numeric))::double precision * pi())))) AS x2,
            ((dh_collars.y)::double precision + (((dh_mineralised_intervals.depto)::double precision * cos((((dh_collars.dip_hz / (180)::numeric))::double precision * pi()))) * cos((((dh_collars.azim_ng / (180)::numeric))::double precision * pi())))) AS y2,
            ((dh_collars.z)::double precision - ((dh_mineralised_intervals.depto)::double precision * sin((((dh_collars.dip_hz / (180)::numeric))::double precision * pi())))) AS z2
           FROM (dh_mineralised_intervals
             JOIN dh_collars ON (((dh_mineralised_intervals.opid = dh_collars.opid) AND ((dh_mineralised_intervals.id)::text = (dh_collars.id)::text))))
          WHERE (dh_mineralised_intervals.mine = 0)) tmp
  ORDER BY tmp.id, tmp.depfrom, tmp.depto, tmp.mine;
ALTER TABLE dh_mineralised_intervals0_traces_3d OWNER TO pierre;


SET search_path = pierre, pg_catalog;
--
-- Name: dh_quicklog; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW dh_quicklog AS
 SELECT dh_quicklog.opid,
    dh_quicklog.id,
    dh_quicklog.depfrom,
    dh_quicklog.depto,
    dh_quicklog.description,
    dh_quicklog.oxid,
    dh_quicklog.alt,
    dh_quicklog.def,
    dh_quicklog.numauto,
    dh_quicklog.creation_ts,
    dh_quicklog.username,
    dh_quicklog.datasource
   FROM (public.dh_quicklog
     JOIN public.operation_active ON ((dh_quicklog.opid = operation_active.opid)));
ALTER TABLE dh_quicklog OWNER TO pierre;


--
-- Name: dh_sampling_avg_grades_3dpoints; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW dh_sampling_avg_grades_3dpoints AS
 SELECT tmp.srid,
    tmp.id,
    tmp.depfrom,
    tmp.depto,
    tmp.core_loss_cm,
    tmp.weight_kg,
    tmp.sample_type,
    tmp.sample_id,
    tmp.comments,
    tmp.opid,
    tmp.batch_id,
    tmp.datasource,
    tmp.au1_ppm,
    tmp.au2_ppm,
    tmp.au3_ppm,
    tmp.au4_ppm,
    tmp.au5_ppm,
    tmp.au6_ppm,
    tmp.ph,
    tmp.moisture,
    tmp.numauto,
    tmp.au_specks,
    tmp.quartering,
    tmp.creation_ts,
    tmp.username,
    tmp.x1,
    tmp.y1,
    tmp.z1,
    tmp.x2,
    tmp.y2,
    tmp.z2,
    public.geomfromewkt((((((((('SRID='::text || tmp.srid) || ';POINT ('::text) || tmp.x2) || ' '::text) || tmp.y2) || ' '::text) || tmp.z2) || ')'::text)) AS geometry
   FROM ( SELECT c.srid,
            s.id,
            s.depfrom,
            s.depto,
            s.core_loss_cm,
            s.weight_kg,
            s.sample_type,
            s.sample_id,
            s.comments,
            s.opid,
            s.batch_id,
            s.datasource,
            s.au1_ppm,
            s.au2_ppm,
            s.au3_ppm,
            s.au4_ppm,
            s.au5_ppm,
            s.au6_ppm,
            s.ph,
            s.moisture,
            s.numauto,
            s.au_specks,
            s.quartering,
            s.creation_ts,
            s.username,
            ((c.x)::double precision + (((s.depfrom)::double precision * cos((((c.dip_hz / (180)::numeric))::double precision * pi()))) * sin((((c.azim_ng / (180)::numeric))::double precision * pi())))) AS x1,
            ((c.y)::double precision + (((s.depfrom)::double precision * cos((((c.dip_hz / (180)::numeric))::double precision * pi()))) * cos((((c.azim_ng / (180)::numeric))::double precision * pi())))) AS y1,
            ((c.z)::double precision - ((s.depfrom)::double precision * sin((((c.dip_hz / (180)::numeric))::double precision * pi())))) AS z1,
            ((c.x)::double precision + (((s.depto)::double precision * cos((((c.dip_hz / (180)::numeric))::double precision * pi()))) * sin((((c.azim_ng / (180)::numeric))::double precision * pi())))) AS x2,
            ((c.y)::double precision + (((s.depto)::double precision * cos((((c.dip_hz / (180)::numeric))::double precision * pi()))) * cos((((c.azim_ng / (180)::numeric))::double precision * pi())))) AS y2,
            ((c.z)::double precision - ((s.depto)::double precision * sin((((c.dip_hz / (180)::numeric))::double precision * pi())))) AS z2
           FROM (( SELECT dh_collars.id,
                    dh_collars.srid,
                    dh_collars.x,
                    dh_collars.y,
                    dh_collars.z,
                    dh_collars.azim_ng,
                    dh_collars.dip_hz
                   FROM dh_collars) c
             JOIN dh_sampling_grades s ON (((c.id)::text = (s.id)::text)))) tmp;
ALTER TABLE dh_sampling_avg_grades_3dpoints OWNER TO pierre;



SET search_path = pierre, pg_catalog;
--
-- Name: dh_sampling_bottle_roll; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW dh_sampling_bottle_roll AS
 SELECT dh_sampling_bottle_roll.opid,
    dh_sampling_bottle_roll.id,
    dh_sampling_bottle_roll.depfrom,
    dh_sampling_bottle_roll.depto,
    dh_sampling_bottle_roll.sample_id,
    dh_sampling_bottle_roll.au_total,
    dh_sampling_bottle_roll.au_24h,
    dh_sampling_bottle_roll.au_48h,
    dh_sampling_bottle_roll.au_72h,
    dh_sampling_bottle_roll.au_residu,
    dh_sampling_bottle_roll.rec_24h_pc,
    dh_sampling_bottle_roll.rec_48h_pc,
    dh_sampling_bottle_roll.rec_72h_pc,
    dh_sampling_bottle_roll.datasource,
    dh_sampling_bottle_roll.numauto,
    dh_sampling_bottle_roll.creation_ts,
    dh_sampling_bottle_roll.username
   FROM (public.dh_sampling_bottle_roll
     JOIN public.operation_active ON ((dh_sampling_bottle_roll.opid = operation_active.opid)));
ALTER TABLE dh_sampling_bottle_roll OWNER TO pierre;

--
-- Name: dh_sampling_grades_graph_au_6; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW dh_sampling_grades_graph_au_6 AS
 SELECT dh_sampling_grades.opid,
    dh_sampling_grades.id,
    dh_sampling_grades.depfrom,
    dh_sampling_grades.depto,
    dh_sampling_grades.sample_id,
    dh_sampling_grades.au1_ppm,
    dh_sampling_grades.au2_ppm,
    dh_sampling_grades.au6_ppm,
    dh_sampling_grades.weight_kg,
    dh_sampling_grades.core_loss_cm,
    repeat('#'::text, ((dh_sampling_grades.au6_ppm * (5)::numeric))::integer) AS graph_au_6
   FROM dh_sampling_grades
  ORDER BY dh_sampling_grades.opid, dh_sampling_grades.id, dh_sampling_grades.depto;
ALTER TABLE dh_sampling_grades_graph_au_6 OWNER TO pierre;

--
-- Name: dh_sampling_grades_open_ended_au_tail; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW dh_sampling_grades_open_ended_au_tail AS
 SELECT tmp.id,
    max(tmp.length) AS length,
    max(tmp.depto) AS depto
   FROM ( SELECT dh_sampling_grades.id,
            dh_sampling_grades.depfrom,
            dh_sampling_grades.depto,
            dh_sampling_grades.core_loss_cm,
            dh_sampling_grades.weight_kg,
            dh_sampling_grades.sample_type,
            dh_sampling_grades.sample_id,
            dh_sampling_grades.comments,
            dh_sampling_grades.opid,
            dh_sampling_grades.batch_id,
            dh_sampling_grades.datasource,
            dh_sampling_grades.au1_ppm,
            dh_sampling_grades.au2_ppm,
            dh_sampling_grades.au3_ppm,
            dh_sampling_grades.au4_ppm,
            dh_sampling_grades.au5_ppm,
            dh_sampling_grades.au6_ppm,
            dh_sampling_grades.ph,
            dh_sampling_grades.moisture,
            dh_sampling_grades.numauto,
            dh_sampling_grades.au_specks,
            dh_sampling_grades.quartering,
            dh_sampling_grades.creation_ts,
            dh_sampling_grades.username,
            dh_collars.length
           FROM (dh_sampling_grades
             JOIN dh_collars ON (((dh_sampling_grades.opid = dh_collars.opid) AND ((dh_sampling_grades.id)::text = (dh_collars.id)::text)))),
            ( SELECT 0.5 AS teneur_coupure) tmp_tc,
            ( SELECT 5 AS sortir_d_au_moins) tmp_sortir
          WHERE ((((dh_collars.dh_type)::text <> ALL (ARRAY[('PIT'::text)::text, ('TR'::text)::text, ('CS'::text)::text])) AND (GREATEST(dh_sampling_grades.au1_ppm, dh_sampling_grades.au2_ppm, dh_sampling_grades.au3_ppm, dh_sampling_grades.au4_ppm, dh_sampling_grades.au5_ppm, dh_sampling_grades.au6_ppm) >= tmp_tc.teneur_coupure)) AND ((dh_collars.length > (tmp_sortir.sortir_d_au_moins)::numeric) AND ((dh_collars.length - dh_sampling_grades.depto) < (tmp_sortir.sortir_d_au_moins)::numeric)))) tmp
  GROUP BY tmp.id
  ORDER BY tmp.id, max(tmp.depto);
ALTER TABLE dh_sampling_grades_open_ended_au_tail OWNER TO pierre;

--
-- Name: dh_sampling_grades_open_ended_au_top; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW dh_sampling_grades_open_ended_au_top AS
 SELECT tmp.id,
    tmp.length,
    min(tmp.depto) AS depto
   FROM ( SELECT dh_sampling_grades.id,
            dh_sampling_grades.depfrom,
            dh_sampling_grades.depto,
            dh_sampling_grades.core_loss_cm,
            dh_sampling_grades.weight_kg,
            dh_sampling_grades.sample_type,
            dh_sampling_grades.sample_id,
            dh_sampling_grades.comments,
            dh_sampling_grades.opid,
            dh_sampling_grades.batch_id,
            dh_sampling_grades.datasource,
            dh_sampling_grades.au1_ppm,
            dh_sampling_grades.au2_ppm,
            dh_sampling_grades.au3_ppm,
            dh_sampling_grades.au4_ppm,
            dh_sampling_grades.au5_ppm,
            dh_sampling_grades.au6_ppm,
            dh_sampling_grades.ph,
            dh_sampling_grades.moisture,
            dh_sampling_grades.numauto,
            dh_sampling_grades.au_specks,
            dh_sampling_grades.quartering,
            dh_sampling_grades.creation_ts,
            dh_sampling_grades.username,
            dh_collars.length
           FROM (dh_sampling_grades
             JOIN dh_collars ON (((dh_sampling_grades.opid = dh_collars.opid) AND ((dh_sampling_grades.id)::text = (dh_collars.id)::text)))),
            ( SELECT 0.5 AS teneur_coupure) tmp_tc,
            ( SELECT 5 AS sortir_d_au_moins) tmp_sortir
          WHERE ((((dh_collars.dh_type)::text <> ALL (ARRAY[('PIT'::text)::text, ('TR'::text)::text, ('CS'::text)::text])) AND (GREATEST(dh_sampling_grades.au1_ppm, dh_sampling_grades.au2_ppm, dh_sampling_grades.au3_ppm, dh_sampling_grades.au4_ppm, dh_sampling_grades.au5_ppm, dh_sampling_grades.au6_ppm) >= tmp_tc.teneur_coupure)) AND ((dh_collars.length > (tmp_sortir.sortir_d_au_moins)::numeric) AND (dh_sampling_grades.depfrom < (tmp_sortir.sortir_d_au_moins)::numeric)))) tmp
  GROUP BY tmp.id, tmp.length, tmp.depto
  ORDER BY tmp.id, min(tmp.depto);
ALTER TABLE dh_sampling_grades_open_ended_au_top OWNER TO pierre;

--
-- Name: dh_sampling_mineralised_intervals_graph_au6; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW dh_sampling_mineralised_intervals_graph_au6 AS
 SELECT tmp.opid,
    tmp.id,
    tmp.depfrom,
    tmp.depto,
    tmp.mineralised_interval,
    tmp.sample_id,
    tmp.weight_kg,
    tmp.core_loss_cm,
    tmp.au6_ppm AS aumaxi_ppm,
    tmp.graph_au_6 AS graph_aumaxi
   FROM (( SELECT dh_sampling_grades_graph_au_6.opid,
            dh_sampling_grades_graph_au_6.id,
            dh_sampling_grades_graph_au_6.depfrom,
            dh_sampling_grades_graph_au_6.depto,
            dh_sampling_grades_graph_au_6.sample_id,
            dh_sampling_grades_graph_au_6.au1_ppm,
            dh_sampling_grades_graph_au_6.au2_ppm,
            dh_sampling_grades_graph_au_6.au6_ppm,
            dh_sampling_grades_graph_au_6.weight_kg,
            dh_sampling_grades_graph_au_6.core_loss_cm,
            dh_sampling_grades_graph_au_6.graph_au_6,
                CASE
                    WHEN (dh_mineralised_intervals.depfrom = dh_sampling_grades_graph_au_6.depfrom) THEN rpad((((('>=== '::text || (dh_mineralised_intervals.stva)::text) || ' (accu: '::text) || ((dh_mineralised_intervals.accu)::text)::text) || ') '::text), 50, '='::text)
                    WHEN (dh_mineralised_intervals.depto = dh_sampling_grades_graph_au_6.depto) THEN '>================================================='::text
                    WHEN (dh_mineralised_intervals.mine IS NOT NULL) THEN ' |'::text
                    ELSE ''::text
                END AS mineralised_interval,
            dh_sampling_grades_graph_au_6.depto AS pied_passe_min
           FROM (dh_sampling_grades_graph_au_6
             LEFT JOIN ( SELECT dh_mineralised_intervals_1.id,
                    dh_mineralised_intervals_1.depfrom,
                    dh_mineralised_intervals_1.depto,
                    dh_mineralised_intervals_1.mine,
                    dh_mineralised_intervals_1.avau,
                    dh_mineralised_intervals_1.stva,
                    dh_mineralised_intervals_1.accu,
                    dh_mineralised_intervals_1.recu,
                    dh_mineralised_intervals_1.dens,
                    dh_mineralised_intervals_1.numauto,
                    dh_mineralised_intervals_1.comments,
                    dh_mineralised_intervals_1.opid,
                    dh_mineralised_intervals_1.creation_ts,
                    dh_mineralised_intervals_1.username,
                    dh_mineralised_intervals_1.datasource
                   FROM dh_mineralised_intervals dh_mineralised_intervals_1
                  WHERE (dh_mineralised_intervals_1.mine = 0)) dh_mineralised_intervals ON ((((((dh_sampling_grades_graph_au_6.opid = dh_mineralised_intervals.opid) AND ((dh_sampling_grades_graph_au_6.id)::text = (dh_mineralised_intervals.id)::text)) AND (dh_sampling_grades_graph_au_6.depto <= dh_mineralised_intervals.depto)) AND (dh_sampling_grades_graph_au_6.depfrom >= dh_mineralised_intervals.depfrom)) AND (dh_mineralised_intervals.mine = 0))))) tmp
     LEFT JOIN ( SELECT dh_mineralised_intervals.opid,
            dh_mineralised_intervals.id,
            dh_mineralised_intervals.depfrom,
            dh_mineralised_intervals.depto,
            dh_mineralised_intervals.avau,
            dh_mineralised_intervals.stva,
            dh_mineralised_intervals.accu
           FROM ( SELECT dh_mineralised_intervals_1.id,
                    dh_mineralised_intervals_1.depfrom,
                    dh_mineralised_intervals_1.depto,
                    dh_mineralised_intervals_1.mine,
                    dh_mineralised_intervals_1.avau,
                    dh_mineralised_intervals_1.stva,
                    dh_mineralised_intervals_1.accu,
                    dh_mineralised_intervals_1.recu,
                    dh_mineralised_intervals_1.dens,
                    dh_mineralised_intervals_1.numauto,
                    dh_mineralised_intervals_1.comments,
                    dh_mineralised_intervals_1.opid,
                    dh_mineralised_intervals_1.creation_ts,
                    dh_mineralised_intervals_1.username,
                    dh_mineralised_intervals_1.datasource
                   FROM dh_mineralised_intervals dh_mineralised_intervals_1
                  WHERE (dh_mineralised_intervals_1.mine = 0)) dh_mineralised_intervals) tmpmine ON ((((tmp.opid = tmpmine.opid) AND ((tmp.id)::text = (tmpmine.id)::text)) AND (tmp.pied_passe_min = tmpmine.depto))))
  ORDER BY tmp.opid, tmp.id, tmp.depto;
ALTER TABLE dh_sampling_mineralised_intervals_graph_au6 OWNER TO pierre;



SET search_path = pierre, pg_catalog;
--
-- Name: dh_struct_measures; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW dh_struct_measures AS
 SELECT dh_struct_measures.opid,
    dh_struct_measures.id,
    dh_struct_measures.depto,
    dh_struct_measures.measure_type,
    dh_struct_measures.structure_type,
    dh_struct_measures.alpha_tca,
    dh_struct_measures.beta,
    dh_struct_measures.gamma,
    dh_struct_measures.north_ref,
    dh_struct_measures.direction,
    dh_struct_measures.dip,
    dh_struct_measures.dip_quadrant,
    dh_struct_measures.pitch,
    dh_struct_measures.pitch_quadrant,
    dh_struct_measures.movement,
    dh_struct_measures.valid,
    dh_struct_measures.struct_description,
    dh_struct_measures.sortgroup,
    dh_struct_measures.datasource,
    dh_struct_measures.numauto,
    dh_struct_measures.creation_ts,
    dh_struct_measures.username
   FROM (public.dh_struct_measures
     JOIN public.operation_active ON ((dh_struct_measures.opid = operation_active.opid)));
ALTER TABLE dh_struct_measures OWNER TO pierre;



SET search_path = pierre, pg_catalog;
--
-- Name: dh_tech; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW dh_tech AS
 SELECT dh_tech.id,
    dh_tech.depfrom,
    dh_tech.depto,
    dh_tech.drilled_len,
    dh_tech.reco_len,
    dh_tech.rqd_len,
    dh_tech.diam,
    dh_tech.numauto,
    dh_tech.datasource,
    dh_tech.opid,
    dh_tech.comments,
    dh_tech.drillers_depto,
    dh_tech.core_loss_cm,
    dh_tech.joints_description,
    dh_tech.nb_joints,
    dh_tech.creation_ts,
    dh_tech.username
   FROM (public.dh_tech
     JOIN public.operation_active ON ((dh_tech.opid = operation_active.opid)));
ALTER TABLE dh_tech OWNER TO pierre;




SET search_path = pierre, pg_catalog;
--
-- Name: dh_thinsections; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW dh_thinsections AS
 SELECT dh_thinsections.opid,
    dh_thinsections.id,
    dh_thinsections.depto,
    dh_thinsections.core_quarter,
    dh_thinsections.questions,
    dh_thinsections.name,
    dh_thinsections.texture,
    dh_thinsections.mineralogy,
    dh_thinsections.metamorphism_deformations,
    dh_thinsections.mineralisations,
    dh_thinsections.origin,
    dh_thinsections.numauto,
    dh_thinsections.creation_ts,
    dh_thinsections.username,
    dh_thinsections.datasource
   FROM (public.dh_thinsections
     JOIN public.operation_active ON ((dh_thinsections.opid = operation_active.opid)));
ALTER TABLE dh_thinsections OWNER TO pierre;

--
-- Name: dh_traces_3d; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW dh_traces_3d AS
 SELECT tmp.id,
    tmp.shid,
    tmp.location,
    tmp.profile,
    tmp.srid,
    tmp.x,
    tmp.y,
    tmp.z,
    tmp.azim_ng,
    tmp.azim_nm,
    tmp.dip_hz,
    tmp.dh_type,
    tmp.date_start,
    tmp.contractor,
    tmp.geologist,
    tmp.length,
    tmp.nb_samples,
    tmp.comments,
    tmp.completed,
    tmp.numauto,
    tmp.date_completed,
    tmp.opid,
    tmp.purpose,
    tmp.x_local,
    tmp.y_local,
    tmp.z_local,
    tmp.accusum,
    tmp.id_pject,
    tmp.x_pject,
    tmp.y_pject,
    tmp.z_pject,
    tmp.topo_survey_type,
    tmp.creation_ts,
    tmp.username,
    tmp.datasource,
    tmp.x1,
    tmp.y1,
    tmp.z1,
    public.geomfromewkt((((((((((((((('SRID='::text || tmp.srid) || ';LINESTRING ('::text) || tmp.x) || ' '::text) || tmp.y) || ' '::text) || tmp.z) || ', '::text) || tmp.x1) || ' '::text) || tmp.y1) || ' '::text) || tmp.z1) || ')'::text)) AS geomfromewkt
   FROM ( SELECT dh_collars.id,
            dh_collars.shid,
            dh_collars.location,
            dh_collars.profile,
            dh_collars.srid,
            dh_collars.x,
            dh_collars.y,
            dh_collars.z,
            dh_collars.azim_ng,
            dh_collars.azim_nm,
            dh_collars.dip_hz,
            dh_collars.dh_type,
            dh_collars.date_start,
            dh_collars.contractor,
            dh_collars.geologist,
            dh_collars.length,
            dh_collars.nb_samples,
            dh_collars.comments,
            dh_collars.completed,
            dh_collars.numauto,
            dh_collars.date_completed,
            dh_collars.opid,
            dh_collars.purpose,
            dh_collars.x_local,
            dh_collars.y_local,
            dh_collars.z_local,
            dh_collars.accusum,
            dh_collars.id_pject,
            dh_collars.x_pject,
            dh_collars.y_pject,
            dh_collars.z_pject,
            dh_collars.topo_survey_type,
            dh_collars.creation_ts,
            dh_collars.username,
            dh_collars.datasource,
            ((dh_collars.x)::double precision + (((dh_collars.length)::double precision * cos((((dh_collars.dip_hz / (180)::numeric))::double precision * pi()))) * sin((((dh_collars.azim_ng / (180)::numeric))::double precision * pi())))) AS x1,
            ((dh_collars.y)::double precision + (((dh_collars.length)::double precision * cos((((dh_collars.dip_hz / (180)::numeric))::double precision * pi()))) * cos((((dh_collars.azim_ng / (180)::numeric))::double precision * pi())))) AS y1,
            ((dh_collars.z)::double precision - ((dh_collars.length)::double precision * sin((((dh_collars.dip_hz / (180)::numeric))::double precision * pi())))) AS z1
           FROM dh_collars) tmp
  ORDER BY tmp.id;
ALTER TABLE dh_traces_3d OWNER TO pierre;



SET search_path = pierre, pg_catalog;
--
-- Name: field_observations; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW field_observations AS
 SELECT field_observations.opid,
    field_observations.year,
    field_observations.obs_id,
    field_observations.date,
    field_observations.waypoint_name,
    field_observations.x,
    field_observations.y,
    field_observations.z,
    field_observations.description,
    field_observations.code_litho,
    field_observations.code_unit,
    field_observations.srid,
    field_observations.geologist,
    field_observations.icon_descr,
    field_observations.comments,
    field_observations.sample_id,
    field_observations.datasource,
    field_observations.numauto,
    field_observations.photos,
    field_observations.audio,
    field_observations.timestamp_epoch_ms,
    field_observations.creation_ts,
    field_observations.username,
    field_observations.device,
    field_observations."time"
   FROM (public.field_observations
     JOIN public.operation_active ON ((field_observations.opid = operation_active.opid)));
ALTER TABLE field_observations OWNER TO pierre;

--
-- Name: field_observations_points; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW field_observations_points AS
 SELECT field_observations.opid,
    field_observations.year,
    field_observations.obs_id,
    field_observations.date,
    field_observations.waypoint_name,
    field_observations.x,
    field_observations.y,
    field_observations.z,
    field_observations.description,
    field_observations.code_litho,
    field_observations.code_unit,
    field_observations.srid,
    field_observations.geologist,
    field_observations.icon_descr,
    field_observations.comments,
    field_observations.sample_id,
    field_observations.datasource,
    field_observations.numauto,
    field_observations.photos,
    field_observations.audio,
    field_observations.timestamp_epoch_ms,
    field_observations.creation_ts,
    field_observations.username,
    field_observations.device,
    field_observations."time",
    public.geomfromewkt((((((((('SRID='::text || field_observations.srid) || ';POINT ('::text) || field_observations.x) || ' '::text) || field_observations.y) || ' '::text) || field_observations.z) || ')'::text)) AS geomfromewkt
   FROM field_observations;
ALTER TABLE field_observations_points OWNER TO pierre;



SET search_path = pierre, pg_catalog;
--
-- Name: field_observations_struct_measures; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW field_observations_struct_measures AS
 SELECT field_observations_struct_measures.opid,
    field_observations_struct_measures.obs_id,
    field_observations_struct_measures.measure_type,
    field_observations_struct_measures.structure_type,
    field_observations_struct_measures.north_ref,
    field_observations_struct_measures.direction,
    field_observations_struct_measures.dip,
    field_observations_struct_measures.dip_quadrant,
    field_observations_struct_measures.pitch,
    field_observations_struct_measures.pitch_quadrant,
    field_observations_struct_measures.movement,
    field_observations_struct_measures.valid,
    field_observations_struct_measures.comments,
    field_observations_struct_measures.numauto,
    field_observations_struct_measures.creation_ts,
    field_observations_struct_measures.username,
    field_observations_struct_measures.datasource,
    field_observations_struct_measures.rotation_matrix,
    field_observations_struct_measures.geolpda_id,
    field_observations_struct_measures.geolpda_poi_id,
    field_observations_struct_measures.sortgroup
   FROM (public.field_observations_struct_measures
     JOIN public.operation_active ON ((field_observations_struct_measures.opid = operation_active.opid)));
ALTER TABLE field_observations_struct_measures OWNER TO pierre;



SET search_path = pierre, pg_catalog;
--
-- Name: field_photos; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW field_photos AS
 SELECT field_photos.pho_id,
    field_photos.obs_id,
    field_photos.file,
    field_photos.description,
    field_photos.az,
    field_photos.dip,
    field_photos.author,
    field_photos.opid,
    field_photos.datasource,
    field_photos.creation_ts,
    field_photos.username,
    field_photos.numauto
   FROM (public.field_photos
     JOIN public.operation_active ON ((field_photos.opid = operation_active.opid)));
ALTER TABLE field_photos OWNER TO pierre;



SET search_path = pierre, pg_catalog;
--
-- Name: formations_group_lithos; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW formations_group_lithos AS
 SELECT formations_group_lithos.opid,
    formations_group_lithos.formation_name,
    formations_group_lithos.code_litho,
    formations_group_lithos.creation_ts,
    formations_group_lithos.username,
    formations_group_lithos.numauto,
    formations_group_lithos.datasource
   FROM (public.formations_group_lithos
     JOIN public.operation_active ON ((formations_group_lithos.opid = operation_active.opid)));
ALTER TABLE formations_group_lithos OWNER TO pierre;


--
-- Name: geoch_ana; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW geoch_ana AS
 SELECT geoch_ana.sampl_index,
    geoch_ana.ana_type,
    geoch_ana.unit,
    geoch_ana.det_lim,
    geoch_ana.scheme,
    geoch_ana.comment,
    geoch_ana.value,
    geoch_ana.numauto,
    geoch_ana.opid,
    geoch_ana.creation_ts,
    geoch_ana.username,
    geoch_ana.datasource
   FROM (public.geoch_ana
     JOIN public.operation_active ON ((geoch_ana.opid = operation_active.opid)));
ALTER TABLE geoch_ana OWNER TO pierre;



SET search_path = pierre, pg_catalog;
--
-- Name: geoch_sampling; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW geoch_sampling AS
 SELECT geoch_sampling.id,
    geoch_sampling.lab_id,
    geoch_sampling.labo_ref,
    geoch_sampling.amc_ref,
    geoch_sampling.recep_date,
    geoch_sampling.type,
    geoch_sampling.sampl_index,
    geoch_sampling.x,
    geoch_sampling.y,
    geoch_sampling.z,
    geoch_sampling.soil_color,
    geoch_sampling.type_sort,
    geoch_sampling.depth_cm,
    geoch_sampling.reg_type,
    geoch_sampling.geomorphology,
    geoch_sampling.rock_type,
    geoch_sampling.comment,
    geoch_sampling.utm_zone,
    geoch_sampling.geologist,
    geoch_sampling.float_sampl,
    geoch_sampling.host_rock,
    geoch_sampling.prospect,
    geoch_sampling.spacing,
    geoch_sampling.horizon,
    geoch_sampling.datasource,
    geoch_sampling.date,
    geoch_sampling.survey_type,
    geoch_sampling.opid,
    geoch_sampling.grid_line,
    geoch_sampling.grid_station,
    geoch_sampling.alteration,
    geoch_sampling.occ_soil,
    geoch_sampling.slope,
    geoch_sampling.slope_dir,
    geoch_sampling.soil_description,
    geoch_sampling.creation_ts,
    geoch_sampling.username,
    geoch_sampling.numauto
   FROM (public.geoch_sampling
     JOIN public.operation_active ON ((geoch_sampling.opid = operation_active.opid)));
ALTER TABLE geoch_sampling OWNER TO pierre;



SET search_path = pierre, pg_catalog;
--
-- Name: geoch_sampling_grades; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW geoch_sampling_grades AS
 SELECT geoch_sampling_grades.id,
    geoch_sampling_grades.lab_id,
    geoch_sampling_grades.labo_ref,
    geoch_sampling_grades.amc_ref,
    geoch_sampling_grades.recep_date,
    geoch_sampling_grades.type,
    geoch_sampling_grades.sampl_index,
    geoch_sampling_grades.x,
    geoch_sampling_grades.y,
    geoch_sampling_grades.z,
    geoch_sampling_grades.soil_color,
    geoch_sampling_grades.type_sort,
    geoch_sampling_grades.depth_cm,
    geoch_sampling_grades.reg_type,
    geoch_sampling_grades.geomorphology,
    geoch_sampling_grades.rock_type,
    geoch_sampling_grades.comment,
    geoch_sampling_grades.utm_zone,
    geoch_sampling_grades.geologist,
    geoch_sampling_grades.float_sampl,
    geoch_sampling_grades.host_rock,
    geoch_sampling_grades.prospect,
    geoch_sampling_grades.spacing,
    geoch_sampling_grades.horizon,
    geoch_sampling_grades.datasource,
    geoch_sampling_grades.date,
    geoch_sampling_grades.survey_type,
    geoch_sampling_grades.opid,
    geoch_sampling_grades.grid_line,
    geoch_sampling_grades.grid_station,
    geoch_sampling_grades.alteration,
    geoch_sampling_grades.occ_soil,
    geoch_sampling_grades.slope,
    geoch_sampling_grades.slope_dir,
    geoch_sampling_grades.soil_description,
    geoch_sampling_grades.creation_ts,
    geoch_sampling_grades.username,
    geoch_sampling_grades.numauto,
    geoch_sampling_grades.au_ppb
   FROM (public.geoch_sampling_grades
     JOIN public.operation_active ON ((geoch_sampling_grades.opid = operation_active.opid)));
ALTER TABLE geoch_sampling_grades OWNER TO pierre;

--
-- Name: geoch_sampling_grades_points; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW geoch_sampling_grades_points AS
 SELECT geoch_sampling_grades.id,
    geoch_sampling_grades.lab_id,
    geoch_sampling_grades.labo_ref,
    geoch_sampling_grades.amc_ref,
    geoch_sampling_grades.recep_date,
    geoch_sampling_grades.type,
    geoch_sampling_grades.sampl_index,
    geoch_sampling_grades.x,
    geoch_sampling_grades.y,
    geoch_sampling_grades.z,
    geoch_sampling_grades.soil_color,
    geoch_sampling_grades.type_sort,
    geoch_sampling_grades.depth_cm,
    geoch_sampling_grades.reg_type,
    geoch_sampling_grades.geomorphology,
    geoch_sampling_grades.rock_type,
    geoch_sampling_grades.comment,
    geoch_sampling_grades.utm_zone,
    geoch_sampling_grades.geologist,
    geoch_sampling_grades.float_sampl,
    geoch_sampling_grades.host_rock,
    geoch_sampling_grades.prospect,
    geoch_sampling_grades.spacing,
    geoch_sampling_grades.horizon,
    geoch_sampling_grades.datasource,
    geoch_sampling_grades.date,
    geoch_sampling_grades.survey_type,
    geoch_sampling_grades.opid,
    geoch_sampling_grades.grid_line,
    geoch_sampling_grades.grid_station,
    geoch_sampling_grades.alteration,
    geoch_sampling_grades.occ_soil,
    geoch_sampling_grades.slope,
    geoch_sampling_grades.slope_dir,
    geoch_sampling_grades.soil_description,
    geoch_sampling_grades.creation_ts,
    geoch_sampling_grades.username,
    geoch_sampling_grades.numauto,
    geoch_sampling_grades.au_ppb,
    public.geomfromewkt((((((('SRID= 20136; POINT ('::text || geoch_sampling_grades.x) || ' '::text) || geoch_sampling_grades.y) || ' '::text) || geoch_sampling_grades.z) || ')'::text)) AS geomfromewkt
   FROM geoch_sampling_grades;
ALTER TABLE geoch_sampling_grades_points OWNER TO pierre;




SET search_path = pierre, pg_catalog;
--
-- Name: gpy_mag_ground; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW gpy_mag_ground AS
 SELECT gpy_mag_ground.opid,
    gpy_mag_ground.srid,
    gpy_mag_ground.x,
    gpy_mag_ground.y,
    gpy_mag_ground.z,
    gpy_mag_ground.x_local,
    gpy_mag_ground.y_local,
    gpy_mag_ground.mag_nanotesla,
    gpy_mag_ground.val_corr_mag_nanotesla,
    gpy_mag_ground.creation_ts,
    gpy_mag_ground.username,
    gpy_mag_ground.numauto,
    gpy_mag_ground.datasource
   FROM (public.gpy_mag_ground
     JOIN public.operation_active ON ((gpy_mag_ground.opid = operation_active.opid)));
ALTER TABLE gpy_mag_ground OWNER TO pierre;



SET search_path = pierre, pg_catalog;
-- Name: grade_ctrl; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW grade_ctrl AS
 SELECT grade_ctrl.id,
    grade_ctrl.num,
    grade_ctrl.x,
    grade_ctrl.y,
    grade_ctrl.z,
    grade_ctrl.prof,
    grade_ctrl.aucy,
    grade_ctrl.autot,
    grade_ctrl.litho,
    grade_ctrl.old_id,
    grade_ctrl.numauto,
    grade_ctrl.aucy2,
    grade_ctrl.datasource,
    grade_ctrl.opid,
    grade_ctrl.creation_ts,
    grade_ctrl.username
   FROM (public.grade_ctrl
     JOIN public.operation_active ON ((grade_ctrl.opid = operation_active.opid)));
ALTER TABLE grade_ctrl OWNER TO pierre;



SET search_path = pierre, pg_catalog;
--
-- Name: index_geo_documentation; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW index_geo_documentation AS
 SELECT index_geo_documentation.id,
    index_geo_documentation.title,
    index_geo_documentation.lat_min,
    index_geo_documentation.lat_max,
    index_geo_documentation.lon_min,
    index_geo_documentation.lon_max,
    index_geo_documentation.opid,
    index_geo_documentation.creation_ts,
    index_geo_documentation.username,
    index_geo_documentation.numauto,
    index_geo_documentation.datasource,
    index_geo_documentation.filename
   FROM (public.index_geo_documentation
     JOIN public.operation_active ON ((index_geo_documentation.opid = operation_active.opid)));
ALTER TABLE index_geo_documentation OWNER TO pierre;



SET search_path = pierre, pg_catalog;
--
-- Name: lab_ana_batches_expedition; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW lab_ana_batches_expedition AS
 SELECT lab_ana_batches_expedition.opid,
    lab_ana_batches_expedition.batch_id,
    lab_ana_batches_expedition.labname,
    lab_ana_batches_expedition.expedition_id,
    lab_ana_batches_expedition.order_id,
    lab_ana_batches_expedition.description,
    lab_ana_batches_expedition.preparation,
    lab_ana_batches_expedition.process_labo,
    lab_ana_batches_expedition.scheme,
    lab_ana_batches_expedition.shipment_date,
    lab_ana_batches_expedition.sent_to_lab,
    lab_ana_batches_expedition.reception_date,
    lab_ana_batches_expedition.results_received,
    lab_ana_batches_expedition.lab_batches,
    lab_ana_batches_expedition.comments,
    lab_ana_batches_expedition.samples_amount,
    lab_ana_batches_expedition.sample_id_first,
    lab_ana_batches_expedition.sample_id_last,
    lab_ana_batches_expedition.creation_ts,
    lab_ana_batches_expedition.username,
    lab_ana_batches_expedition.numauto,
    lab_ana_batches_expedition.datasource
   FROM (public.lab_ana_batches_expedition
     JOIN public.operation_active ON ((lab_ana_batches_expedition.opid = operation_active.opid)));
ALTER TABLE lab_ana_batches_expedition OWNER TO pierre;





SET search_path = pierre, pg_catalog;
--
-- Name: lab_ana_batches_reception; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW lab_ana_batches_reception AS
 SELECT lab_ana_batches_reception.opid,
    lab_ana_batches_reception.jobno,
    lab_ana_batches_reception.generic_txt,
    lab_ana_batches_reception.numauto,
    lab_ana_batches_reception.datasource,
    lab_ana_batches_reception.labname,
    lab_ana_batches_reception.client,
    lab_ana_batches_reception.validated,
    lab_ana_batches_reception.number_of_samples,
    lab_ana_batches_reception.project,
    lab_ana_batches_reception.shipment_id,
    lab_ana_batches_reception.p_o_number,
    lab_ana_batches_reception.received,
    lab_ana_batches_reception.creation_ts,
    lab_ana_batches_reception.username,
    lab_ana_batches_reception.certificate_comments,
    lab_ana_batches_reception.info_suppl_json
   FROM (public.lab_ana_batches_reception
     JOIN public.operation_active ON ((lab_ana_batches_reception.opid = operation_active.opid)));
ALTER TABLE lab_ana_batches_reception OWNER TO pierre;




SET search_path = pierre, pg_catalog;
--
-- Name: lab_ana_columns_definition; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW lab_ana_columns_definition AS
 SELECT lab_ana_columns_definition.analyte,
    lab_ana_columns_definition.unit,
    lab_ana_columns_definition.scheme,
    lab_ana_columns_definition.colid,
    lab_ana_columns_definition.opid,
    lab_ana_columns_definition.creation_ts,
    lab_ana_columns_definition.username,
    lab_ana_columns_definition.numauto
   FROM (public.lab_ana_columns_definition
     JOIN public.operation_active ON ((lab_ana_columns_definition.opid = operation_active.opid)));
ALTER TABLE lab_ana_columns_definition OWNER TO pierre;



SET search_path = pierre, pg_catalog;
--
-- Name: lab_ana_qaqc_results; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW lab_ana_qaqc_results AS
 SELECT lab_ana_qaqc_results.opid,
    lab_ana_qaqc_results.jobno,
    lab_ana_qaqc_results.generic_txt_col1,
    lab_ana_qaqc_results.generic_txt_col2,
    lab_ana_qaqc_results.generic_txt_col3,
    lab_ana_qaqc_results.generic_txt_col4,
    lab_ana_qaqc_results.generic_txt_col5,
    lab_ana_qaqc_results.datasource,
    lab_ana_qaqc_results.numauto,
    lab_ana_qaqc_results.creation_ts,
    lab_ana_qaqc_results.username
   FROM (public.lab_ana_qaqc_results
     JOIN public.operation_active ON ((lab_ana_qaqc_results.opid = operation_active.opid)));
ALTER TABLE lab_ana_qaqc_results OWNER TO pierre;




SET search_path = pierre, pg_catalog;
--
-- Name: lex_codes; Type: VIEW; Schema: pierre; Owner: pierre
CREATE VIEW lex_codes AS
 SELECT lex_codes.opid,
    lex_codes.tablename,
    lex_codes.field,
    lex_codes.code,
    lex_codes.description,
    lex_codes.datasource,
    lex_codes.numauto,
    lex_codes.comments,
    lex_codes.creation_ts,
    lex_codes.username
   FROM (public.lex_codes
     JOIN public.operation_active ON ((lex_codes.opid = operation_active.opid)));
ALTER TABLE lex_codes OWNER TO pierre;



SET search_path = pierre, pg_catalog;
--
-- Name: lex_datasource; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW lex_datasource AS
 SELECT lex_datasource.opid,
    lex_datasource.filename,
    lex_datasource.comments,
    lex_datasource.datasource_id,
    lex_datasource.creation_ts,
    lex_datasource.username,
    lex_datasource.numauto
   FROM (public.lex_datasource
     JOIN public.operation_active ON ((lex_datasource.opid = operation_active.opid)));
ALTER TABLE lex_datasource OWNER TO pierre;



SET search_path = pierre, pg_catalog;
--
-- Name: lex_standard; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW lex_standard AS
 SELECT lex_standard.std_id,
    lex_standard.unit,
    lex_standard.element,
    lex_standard.value,
    lex_standard.std_dev,
    lex_standard.interval_conf,
    lex_standard.std_origin,
    lex_standard.type_analyse,
    lex_standard.numauto,
    lex_standard.opid,
    lex_standard.creation_ts,
    lex_standard.username,
    lex_standard.datasource
   FROM (public.lex_standard
     JOIN public.operation_active ON ((lex_standard.opid = operation_active.opid)));
ALTER TABLE lex_standard OWNER TO pierre;



SET search_path = pierre, pg_catalog;
--
-- Name: licences; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW licences AS
 SELECT licences.opid,
    licences.licence_name,
    licences.operator,
    licences.year,
    licences.lat_min,
    licences.lon_min,
    licences.lat_max,
    licences.lon_max,
    licences.comments,
    licences.creation_ts,
    licences.username,
    licences.numauto,
    licences.datasource
   FROM (public.licences
     JOIN public.operation_active ON ((licences.opid = operation_active.opid)));
ALTER TABLE licences OWNER TO pierre;

--
-- Name: licences_quadrangles; Type: VIEW; Schema: pierre; Owner: pierre
--

CREATE VIEW licences_quadrangles AS
 SELECT licences.opid,
    licences.licence_name,
    licences.operator,
    licences.year,
    licences.lat_min,
    licences.lon_min,
    licences.lat_max,
    licences.lon_max,
    licences.comments,
    licences.creation_ts,
    licences.username,
    licences.numauto,
    licences.datasource,
    public.geomfromewkt((((((((((((((((((((('SRID=4326;POLYGON('::text || licences.lon_min) || ' '::text) || licences.lat_max) || ','::text) || licences.lon_max) || ' '::text) || licences.lat_max) || ','::text) || licences.lon_max) || ' '::text) || licences.lat_min) || ','::text) || licences.lon_min) || ' '::text) || licences.lat_min) || ','::text) || licences.lon_min) || ' '::text) || licences.lat_max) || ')'::text)) AS geomfromewkt
   FROM licences
  ORDER BY licences.licence_name;


ALTER TABLE licences_quadrangles OWNER TO pierre;

SET search_path = public, pg_catalog;



SET search_path = pierre, pg_catalog;
--
-- Name: mag_declination; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW mag_declination AS
 SELECT mag_declination.opid,
    mag_declination.mag_decl,
    mag_declination.numauto,
    mag_declination.date,
    mag_declination.creation_ts,
    mag_declination.username,
    mag_declination.datasource
   FROM (public.mag_declination
     JOIN public.operation_active ON ((mag_declination.opid = operation_active.opid)));
ALTER TABLE mag_declination OWNER TO pierre;



SET search_path = pierre, pg_catalog;
--
-- Name: occurrences; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW occurrences AS
 SELECT occurrences.numauto,
    occurrences.name,
    occurrences.status,
    occurrences.description,
    occurrences.w_done,
    occurrences.w_todo,
    occurrences.geom,
    occurrences.code,
    occurrences.opid,
    occurrences.zone,
    occurrences.creation_ts,
    occurrences.username,
    occurrences.datasource,
    occurrences.comments
   FROM (public.occurrences
     JOIN public.operation_active ON ((occurrences.opid = operation_active.opid)));
ALTER TABLE occurrences OWNER TO pierre;
CREATE VIEW occurrences_ AS
 SELECT occurrences.numauto,
    occurrences.name,
    occurrences.status,
    public.st_x(occurrences.geom) AS x,
    public.st_y(occurrences.geom) AS y,
    occurrences.description,
    occurrences.w_done,
    occurrences.w_todo,
    ''::text AS geol_poten,
    ''::text AS grade,
    ''::text AS type,
    ''::text AS code_typ,
    0 AS size,
    ''::text AS au,
    ''::text AS trenches,
    ''::text AS coredrill,
    ''::text AS pdrill,
    ''::text AS max_grade,
    ''::text AS length,
    ''::text AS thickness,
    ''::text AS code_indic,
    occurrences.geom,
    0 AS num_code,
    occurrences.code,
    occurrences.opid,
    public.st_srid(occurrences.geom) AS srid,
    occurrences.zone,
    public.st_z(occurrences.geom) AS z
   FROM (public.occurrences
     JOIN public.operation_active ON ((occurrences.opid = operation_active.opid)));
ALTER TABLE occurrences_ OWNER TO pierre;

--
-- Name: occurrences_bal_200km; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW occurrences_bal_200km AS
 SELECT occurrences.numauto,
    occurrences.name,
    occurrences.status,
    occurrences.description,
    occurrences.w_done,
    occurrences.w_todo,
    occurrences.geom,
    occurrences.code,
    occurrences.opid,
    occurrences.zone,
    occurrences.creation_ts,
    occurrences.username,
    occurrences.datasource,
    occurrences.comments,
    occurrences.numauto_auto
   FROM public.occurrences
  WHERE ((occurrences.opid = 30) AND (occurrences.numauto_auto = ANY (ARRAY[53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 388, 389, 390, 391, 392, 393, 394, 395, 398, 399, 400, 401, 402, 403, 404, 405, 406, 407, 408, 409, 410, 411, 597, 598, 605, 606, 607, 608, 609, 610, 613, 614, 615, 616, 617, 618, 619, 620, 621, 622, 623, 624, 625, 626, 627, 628, 629, 630, 631, 632, 633, 634, 635, 636, 637, 638, 639, 640, 641, 642, 643, 644, 645, 646, 647, 648, 649, 650, 651, 652, 653, 654, 655, 656, 657, 658, 659, 676, 677, 679, 680, 681, 682, 684, 685, 686, 692, 693, 694, 695, 696, 697, 698, 786, 805, 841, 842, 843, 844, 845, 846, 847, 848, 849, 850, 851, 852, 853, 854, 856, 857, 861, 862, 863, 864, 865, 866, 867, 868, 869, 870, 871, 872, 873, 874, 875, 876, 877, 878, 879, 880, 884, 885, 886, 887, 888, 889, 890, 891, 892, 898, 900, 902, 904, 905, 906, 907, 908, 909, 910, 911, 912, 919, 920, 921, 855, 858, 923, 924, 925, 926, 927, 928, 929, 930, 931, 932, 933, 936, 937, 974, 976, 977, 983, 984, 985])));
ALTER TABLE occurrences_bal_200km OWNER TO pierre;



SET search_path = pierre, pg_catalog;
--
-- Name: operations_quadrangles; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW operations_quadrangles AS
 SELECT operations.opid,
    operations.operation,
    operations.full_name,
    operations.operator,
    operations.year,
    operations.confidentiality,
    operations.lat_min,
    operations.lon_min,
    operations.lat_max,
    operations.lon_max,
    operations.comments,
    operations.creation_ts,
    operations.username,
    operations.numauto,
    public.geomfromewkt((((((((((((((((((((('SRID=4326;POLYGON(('::text || operations.lon_min) || ' '::text) || operations.lat_max) || ','::text) || operations.lon_max) || ' '::text) || operations.lat_max) || ','::text) || operations.lon_max) || ' '::text) || operations.lat_min) || ','::text) || operations.lon_min) || ' '::text) || operations.lat_min) || ','::text) || operations.lon_min) || ' '::text) || operations.lat_max) || '))'::text)) AS geomfromewkt
   FROM public.operations
  ORDER BY operations.operation;
ALTER TABLE operations_quadrangles OWNER TO pierre;

--
-- Name: petro_mineralo_study_dh_collars; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW petro_mineralo_study_dh_collars AS
 SELECT dh_collars_points.id,
    dh_collars_points.shid,
    dh_collars_points.location,
    dh_collars_points.profile,
    dh_collars_points.srid,
    dh_collars_points.x,
    dh_collars_points.y,
    dh_collars_points.z,
    dh_collars_points.azim_ng,
    dh_collars_points.azim_nm,
    dh_collars_points.dip_hz,
    dh_collars_points.dh_type,
    dh_collars_points.date_start,
    dh_collars_points.contractor,
    dh_collars_points.geologist,
    dh_collars_points.length,
    dh_collars_points.nb_samples,
    dh_collars_points.comments,
    dh_collars_points.completed,
    dh_collars_points.numauto,
    dh_collars_points.date_completed,
    dh_collars_points.opid,
    dh_collars_points.purpose,
    dh_collars_points.x_local,
    dh_collars_points.y_local,
    dh_collars_points.z_local,
    dh_collars_points.accusum,
    dh_collars_points.id_pject,
    dh_collars_points.x_pject,
    dh_collars_points.y_pject,
    dh_collars_points.z_pject,
    dh_collars_points.topo_survey_type,
    dh_collars_points.creation_ts,
    dh_collars_points.username,
    dh_collars_points.datasource,
    dh_collars_points.geomfromewkt
   FROM dh_collars_points
  WHERE ((dh_collars_points.id)::text = ANY (ARRAY[('S430'::text)::text, ('W08-573'::text)::text, ('W08-597'::text)::text, ('W08-593'::text)::text, ('W08-598'::text)::text, ('W08-598'::text)::text, ('W08-601'::text)::text, ('GB09-889'::text)::text, ('GB09-889'::text)::text, ('GB09-893'::text)::text]))
  ORDER BY dh_collars_points.id;
ALTER TABLE petro_mineralo_study_dh_collars OWNER TO pierre;
CREATE VIEW petro_mineralo_study_field_observations_points AS
 SELECT field_observations_points.opid,
    field_observations_points.year,
    field_observations_points.obs_id,
    field_observations_points.date,
    field_observations_points.waypoint_name,
    field_observations_points.x,
    field_observations_points.y,
    field_observations_points.z,
    field_observations_points.description,
    field_observations_points.code_litho,
    field_observations_points.code_unit,
    field_observations_points.srid,
    field_observations_points.geologist,
    field_observations_points.icon_descr,
    field_observations_points.comments,
    field_observations_points.sample_id,
    field_observations_points.datasource,
    field_observations_points.numauto,
    field_observations_points.photos,
    field_observations_points.audio,
    field_observations_points.timestamp_epoch_ms,
    field_observations_points.creation_ts,
    field_observations_points.username,
    field_observations_points.device,
    field_observations_points."time",
    field_observations_points.geomfromewkt
   FROM field_observations_points
  WHERE ((field_observations_points.sample_id)::text = ANY (ARRAY[('PCh854'::text)::text, ('PCh856'::text)::text, ('PCh865'::text)::text, ('PCh873'::text)::text, ('PCh875A, PCh875B'::text)::text]))
  ORDER BY field_observations_points.obs_id;
ALTER TABLE petro_mineralo_study_field_observations_points OWNER TO pierre;


SET search_path = public, pg_catalog;



SET search_path = pierre, pg_catalog;
--
-- Name: qc_sampling; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW qc_sampling AS
 SELECT qc_sampling.sample_id,
    qc_sampling.qc_type,
    qc_sampling.comments,
    qc_sampling.opid,
    qc_sampling.batch_id,
    qc_sampling.refers_to,
    qc_sampling.datasource,
    qc_sampling.weight_kg,
    qc_sampling.numauto,
    qc_sampling.creation_ts,
    qc_sampling.username
   FROM (public.qc_sampling
     JOIN public.operation_active ON ((qc_sampling.opid = operation_active.opid)));


ALTER TABLE qc_sampling OWNER TO pierre;

SET search_path = public, pg_catalog;



SET search_path = pierre, pg_catalog;
--
-- Name: qc_standards; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW qc_standards AS
 SELECT qc_standards.qc_id,
    qc_standards.labo,
    qc_standards.matrix,
    qc_standards.presentation,
    qc_standards.au_ppm,
    qc_standards.cu_ppm,
    qc_standards.zn_ppm,
    qc_standards.pb_ppm,
    qc_standards.ag_ppm,
    qc_standards.ni_ppm,
    qc_standards.au_ppm_95pc_conf_interval,
    qc_standards.cu_ppm_95pc_conf_interval,
    qc_standards.zn_ppm_95pc_conf_interval,
    qc_standards.pb_ppm_95pc_conf_interval,
    qc_standards.ag_ppm_95pc_conf_interval,
    qc_standards.ni_ppm_95pc_conf_interval,
    qc_standards.opid,
    qc_standards.datasource,
    qc_standards.creation_ts,
    qc_standards.username,
    qc_standards.numauto
   FROM (public.qc_standards
     JOIN public.operation_active ON ((qc_standards.opid = operation_active.opid)));
ALTER TABLE qc_standards OWNER TO pierre;



ALTER TABLE sections_array_num_seq OWNER TO pierre;


SET search_path = pierre, pg_catalog;
--
-- Name: surface_samples_grades; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW surface_samples_grades AS
 SELECT surface_samples_grades.opid,
    surface_samples_grades.sample_id,
    surface_samples_grades.x,
    surface_samples_grades.y,
    surface_samples_grades.z,
    surface_samples_grades.srid,
    surface_samples_grades.description,
    surface_samples_grades.sample_type,
    surface_samples_grades.outcrop_id,
    surface_samples_grades.trend,
    surface_samples_grades.dip,
    surface_samples_grades.length_m,
    surface_samples_grades.width_m,
    surface_samples_grades.au1_ppm,
    surface_samples_grades.au2_ppm,
    surface_samples_grades.ag1_,
    surface_samples_grades.ag2_,
    surface_samples_grades.cu1_,
    surface_samples_grades.cu2_,
    surface_samples_grades.as_,
    surface_samples_grades.pb_,
    surface_samples_grades.zn_,
    surface_samples_grades.k2o_,
    surface_samples_grades.ba_,
    surface_samples_grades.sio2_,
    surface_samples_grades.al2x_,
    surface_samples_grades.fe2x_,
    surface_samples_grades.mno_,
    surface_samples_grades.tio2_,
    surface_samples_grades.p2o5_,
    surface_samples_grades.cao_,
    surface_samples_grades.mgo_,
    surface_samples_grades.mo_,
    surface_samples_grades.sn_,
    surface_samples_grades.sb_,
    surface_samples_grades.w_,
    surface_samples_grades.bi_,
    surface_samples_grades.zr_,
    surface_samples_grades.li_,
    surface_samples_grades.b_,
    surface_samples_grades.v_,
    surface_samples_grades.cr_,
    surface_samples_grades.ni_,
    surface_samples_grades.co_,
    surface_samples_grades.sr_,
    surface_samples_grades.y_,
    surface_samples_grades.la_,
    surface_samples_grades.ce_,
    surface_samples_grades.nb_,
    surface_samples_grades.be_,
    surface_samples_grades.cd_,
    surface_samples_grades.spp2,
    surface_samples_grades.numauto,
    surface_samples_grades.creation_ts,
    surface_samples_grades.username,
    surface_samples_grades.datasource
   FROM (public.surface_samples_grades
     JOIN public.operation_active ON ((surface_samples_grades.opid = operation_active.opid)));
ALTER TABLE surface_samples_grades OWNER TO pierre;

--
-- Name: surface_samples_grades_points; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW surface_samples_grades_points AS
 SELECT surface_samples_grades.opid,
    surface_samples_grades.sample_id,
    surface_samples_grades.x,
    surface_samples_grades.y,
    surface_samples_grades.z,
    surface_samples_grades.srid,
    surface_samples_grades.description,
    surface_samples_grades.sample_type,
    surface_samples_grades.outcrop_id,
    surface_samples_grades.trend,
    surface_samples_grades.dip,
    surface_samples_grades.length_m,
    surface_samples_grades.width_m,
    surface_samples_grades.au1_ppm,
    surface_samples_grades.au2_ppm,
    surface_samples_grades.ag1_,
    surface_samples_grades.ag2_,
    surface_samples_grades.cu1_,
    surface_samples_grades.cu2_,
    surface_samples_grades.as_,
    surface_samples_grades.pb_,
    surface_samples_grades.zn_,
    surface_samples_grades.k2o_,
    surface_samples_grades.ba_,
    surface_samples_grades.sio2_,
    surface_samples_grades.al2x_,
    surface_samples_grades.fe2x_,
    surface_samples_grades.mno_,
    surface_samples_grades.tio2_,
    surface_samples_grades.p2o5_,
    surface_samples_grades.cao_,
    surface_samples_grades.mgo_,
    surface_samples_grades.mo_,
    surface_samples_grades.sn_,
    surface_samples_grades.sb_,
    surface_samples_grades.w_,
    surface_samples_grades.bi_,
    surface_samples_grades.zr_,
    surface_samples_grades.li_,
    surface_samples_grades.b_,
    surface_samples_grades.v_,
    surface_samples_grades.cr_,
    surface_samples_grades.ni_,
    surface_samples_grades.co_,
    surface_samples_grades.sr_,
    surface_samples_grades.y_,
    surface_samples_grades.la_,
    surface_samples_grades.ce_,
    surface_samples_grades.nb_,
    surface_samples_grades.be_,
    surface_samples_grades.cd_,
    surface_samples_grades.spp2,
    surface_samples_grades.numauto,
    surface_samples_grades.creation_ts,
    surface_samples_grades.username,
    surface_samples_grades.datasource,
    public.geomfromewkt((((((((('SRID='::text || surface_samples_grades.srid) || '; POINT ('::text) || surface_samples_grades.x) || ' '::text) || surface_samples_grades.y) || ' '::text) || 0) || ')'::text)) AS geomfromewkt
   FROM surface_samples_grades;
ALTER TABLE surface_samples_grades_points OWNER TO pierre;

--
-- Name: t2; Type: TABLE; Schema: pierre; Owner: pierre; Tablespace: 
--

CREATE TABLE t2 (
    id integer
);


ALTER TABLE t2 OWNER TO pierre;

--
-- Name: tanguysurp_project; Type: VIEW; Schema: pierre; Owner: postgres
--


ALTER TABLE tmp_xy OWNER TO pierre;

CREATE VIEW tmp_xy_points AS
 SELECT tmp_xy.shid,
    tmp_xy.id,
    tmp_xy.srid,
    tmp_xy.x,
    tmp_xy.y,
    tmp_xy.z,
    tmp_xy.val,
    tmp_xy.comment,
    public.geomfromewkt((((((((('SRID='::text || tmp_xy.srid) || ';POINT('::text) || tmp_xy.x) || ' '::text) || tmp_xy.y) || ' '::text) || tmp_xy.z) || ')'::text)) AS geomfromewkt
   FROM tmp_xy;


ALTER TABLE tmp_xy_points OWNER TO pierre;


--
-- Name: topo_points_points; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW topo_points_points AS
 SELECT topo_points.location,
    topo_points.num,
    topo_points.x,
    topo_points.y,
    topo_points.z,
    topo_points.numauto,
    topo_points.id,
    topo_points.datasource,
    topo_points.opid,
    topo_points.survey_date,
    topo_points.topo_survey_type,
    topo_points.coordsys,
    topo_points.surveyor,
    topo_points.creation_ts,
    topo_points.username,
    public.geomfromewkt((((((('POINT('::text || topo_points.x) || ' '::text) || topo_points.y) || ' '::text) || topo_points.z) || ')'::text)) AS geometry
   FROM topo_points;
ALTER TABLE topo_points_points OWNER TO pierre;

--
-- Name: tt_obs_abusives; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW tt_obs_abusives AS
 SELECT field_observations.opid,
    field_observations.year,
    field_observations.obs_id,
    field_observations.date,
    field_observations.waypoint_name,
    field_observations.x,
    field_observations.y,
    field_observations.z,
    field_observations.description,
    field_observations.code_litho,
    field_observations.code_unit,
    field_observations.srid,
    field_observations.geologist,
    field_observations.icon_descr,
    field_observations.comments,
    field_observations.sample_id,
    field_observations.datasource,
    field_observations.numauto,
    field_observations.photos,
    field_observations.audio,
    field_observations.timestamp_epoch_ms,
    field_observations.creation_ts,
    field_observations.username,
    field_observations.device,
    field_observations."time"
   FROM public.field_observations
  WHERE ((field_observations.obs_id)::text = ANY ((ARRAY['AFX03131'::text, 'AFX03132'::text, 'AFX03133'::text, 'AFX03148'::text, 'AFX03149'::text, 'AFX03150'::text, 'AFX03151'::text, 'AFX03162'::text, 'AFX03163'::text, 'AFX03164'::text, 'AFX03165'::text, 'AFX03166'::text, 'AFX03167'::text, 'AFX03168'::text, 'AFX03169'::text, 'AFX03170'::text, 'AFX03171'::text, 'AFX03172'::text, 'AFX03173'::text, 'AFX03174'::text, 'AFX03175'::text, 'AFX03176'::text, 'AFX03177'::text, 'AFX03178'::text, 'AFX03179'::text, 'AFX03180'::text])::text[]));
ALTER TABLE tt_obs_abusives OWNER TO pierre;

CREATE VIEW dh_collars_points_latlon AS
 SELECT dh_collars.id,
    dh_collars.shid,
    dh_collars.location,
    dh_collars.profile,
    dh_collars.srid,
    dh_collars.x,
    dh_collars.y,
    dh_collars.z,
    dh_collars.azim_ng,
    dh_collars.azim_nm,
    dh_collars.dip_hz,
    dh_collars.dh_type,
    dh_collars.date_start,
    dh_collars.contractor,
    dh_collars.geologist,
    dh_collars.length,
    dh_collars.nb_samples,
    dh_collars.comments,
    dh_collars.completed,
    dh_collars.numauto,
    dh_collars.date_completed,
    dh_collars.opid,
    dh_collars.purpose,
    dh_collars.x_local,
    dh_collars.y_local,
    dh_collars.z_local,
    dh_collars.accusum,
    dh_collars.id_pject,
    dh_collars.x_pject,
    dh_collars.y_pject,
    dh_collars.z_pject,
    dh_collars.topo_survey_type,
    dh_collars.creation_ts,
    dh_collars.username,
    dh_collars.datasource,
    st_transform(geomfromewkt((((((('SRID='::text || dh_collars.srid) || '; POINT ('::text) || dh_collars.x) || ' '::text) || dh_collars.y) || ')'::text)), 4326) AS geometry
   FROM dh_collars
  WHERE ((((dh_collars.x IS NOT NULL) AND (dh_collars.y IS NOT NULL)) AND (dh_collars.srid IS NOT NULL)) AND (dh_collars.srid <> 999));


ALTER TABLE dh_collars_points_latlon OWNER TO pierre;

CREATE VIEW field_observations_points AS
 SELECT field_observations.opid,
    field_observations.year,
    field_observations.obs_id,
    field_observations.date,
    field_observations.waypoint_name,
    field_observations.x,
    field_observations.y,
    field_observations.z,
    field_observations.description,
    field_observations.code_litho,
    field_observations.code_unit,
    field_observations.srid,
    field_observations.geologist,
    field_observations.icon_descr,
    field_observations.comments,
    field_observations.sample_id,
    field_observations.datasource,
    field_observations.numauto,
    field_observations.photos,
    field_observations.audio,
    field_observations.timestamp_epoch_ms,
    field_observations.creation_ts,
    field_observations.username,
    field_observations.device,
    field_observations."time",
    geomfromewkt((((((((('SRID='::text || field_observations.srid) || ';POINT ('::text) || field_observations.x) || ' '::text) || field_observations.y) || ' '::text) || field_observations.z) || ')'::text)) AS geomfromewkt
   FROM field_observations;


ALTER TABLE field_observations_points OWNER TO pierre;



SET default_with_oids = true;

--
-- Name: geometry_columns_old; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE geometry_columns_old (
    f_table_catalog character varying(256) NOT NULL,
    f_table_schema character varying(256) NOT NULL,
    f_table_name character varying(256) NOT NULL,
    f_geometry_column character varying(256) NOT NULL,
    coord_dimension integer NOT NULL,
    srid integer NOT NULL,
    type character varying(30) NOT NULL
);


ALTER TABLE geometry_columns_old OWNER TO postgres;

CREATE VIEW licences_polygons AS
 SELECT licences.opid,
    licences.licence_name,
    licences.operator,
    licences.year,
    licences.lat_min,
    licences.lon_min,
    licences.lat_max,
    licences.lon_max,
    licences.comments,
    licences.creation_ts,
    licences.username,
    licences.numauto,
    licences.datasource,
    licences.geometry_literal_description_plain_txt,
    licences.geometry_wkt,
    geomfromewkt((licences.geometry_wkt)::text) AS geomfromewkt
   FROM licences
  ORDER BY licences.opid, licences.licence_name;


ALTER TABLE licences_polygons OWNER TO pierre;

--
-- Name: licences_quadrangles; Type: VIEW; Schema: public; Owner: pierre
--

CREATE VIEW licences_quadrangles AS
 SELECT licences.opid,
    licences.licence_name,
    licences.operator,
    licences.year,
    licences.lat_min,
    licences.lon_min,
    licences.lat_max,
    licences.lon_max,
    licences.comments,
    licences.creation_ts,
    licences.username,
    licences.numauto,
    licences.datasource,
    licences.geometry_literal_description_plain_txt,
    licences.geometry_wkt,
    geomfromewkt((((((((((((((((((((('SRID=4326;POLYGON(('::text || licences.lon_min) || ' '::text) || licences.lat_max) || ','::text) || licences.lon_max) || ' '::text) || licences.lat_max) || ', '::text) || licences.lon_max) || ' '::text) || licences.lat_min) || ', '::text) || licences.lon_min) || ' '::text) || licences.lat_min) || ', '::text) || licences.lon_min) || ' '::text) || licences.lat_max) || '))'::text)) AS geomfromewkt
   FROM licences
  ORDER BY licences.opid, licences.licence_name;


ALTER TABLE licences_quadrangles OWNER TO pierre;

CREATE VIEW survey_lines_plines AS
 SELECT survey_lines.opid,
    survey_lines.id,
    survey_lines.x_start,
    survey_lines.y_start,
    survey_lines.x_end,
    survey_lines.y_end,
    survey_lines.length,
    survey_lines.numauto,
    survey_lines.srid,
    geomfromewkt((((((((((('SRID='::text || survey_lines.srid) || '; LINESTRING ('::text) || survey_lines.x_start) || ' '::text) || survey_lines.y_start) || ', '::text) || survey_lines.x_end) || ' '::text) || survey_lines.y_end) || ')'::text)) AS geomfromewkt
   FROM survey_lines;


ALTER TABLE survey_lines_plines OWNER TO pierre;

CREATE VIEW avancements_sondages_stats_annuelles AS
 SELECT tmp.year,
    sum(tmp.drilled_length_during_shift) AS drilled_length_during_year
   FROM ( SELECT date_part('year'::text, shift_reports.date) AS year,
            shift_reports.drilled_length_during_shift
           FROM pierre.shift_reports) tmp
  GROUP BY tmp.year
  ORDER BY tmp.year;


ALTER TABLE avancements_sondages_stats_annuelles OWNER TO pierre;

--
-- Name: avancements_sondages_stats_annuelles_par_objectif; Type: VIEW; Schema: stats_reports; Owner: pierre
--

CREATE VIEW avancements_sondages_stats_annuelles_par_objectif AS
 SELECT tmp.year,
    tmp.target,
    sum(tmp.drilled_length_during_shift) AS drilled_length_during_month
   FROM ( SELECT date_part('year'::text, shift_reports.date) AS year,
            date_part('month'::text, shift_reports.date) AS month,
            shift_reports.drilled_length_during_shift,
            "substring"((shift_reports.id)::text, 1, 4) AS target
           FROM pierre.shift_reports) tmp
  GROUP BY tmp.year, tmp.target
  ORDER BY tmp.year;


ALTER TABLE avancements_sondages_stats_annuelles_par_objectif OWNER TO pierre;

--
-- Name: avancements_sondages_stats_mensuelles; Type: VIEW; Schema: stats_reports; Owner: pierre
--

CREATE VIEW avancements_sondages_stats_mensuelles AS
 SELECT tmp.year,
    tmp.month,
    sum(tmp.drilled_length_during_shift) AS drilled_length_during_month
   FROM ( SELECT date_part('year'::text, shift_reports.date) AS year,
            date_part('month'::text, shift_reports.date) AS month,
            shift_reports.drilled_length_during_shift
           FROM pierre.shift_reports) tmp
  GROUP BY tmp.year, tmp.month
  ORDER BY tmp.year, tmp.month;


ALTER TABLE avancements_sondages_stats_mensuelles OWNER TO pierre;

--
-- Name: avancements_sondages_stats_mensuelles_par_objectif; Type: VIEW; Schema: stats_reports; Owner: pierre
--

CREATE VIEW avancements_sondages_stats_mensuelles_par_objectif AS
 SELECT tmp.year,
    tmp.month,
    tmp.target,
    sum(tmp.drilled_length_during_shift) AS drilled_length_during_month
   FROM ( SELECT date_part('year'::text, shift_reports.date) AS year,
            date_part('month'::text, shift_reports.date) AS month,
            shift_reports.drilled_length_during_shift,
            split_part((shift_reports.id)::text, '_'::text, 1) AS target
           FROM pierre.shift_reports) tmp
  GROUP BY tmp.year, tmp.month, tmp.target
  ORDER BY tmp.year, tmp.month;


ALTER TABLE avancements_sondages_stats_mensuelles_par_objectif OWNER TO pierre;

--
-- Name: avancements_sondages_stats_quotidiennes; Type: VIEW; Schema: stats_reports; Owner: pierre
--

CREATE VIEW avancements_sondages_stats_quotidiennes AS
 SELECT shift_reports.rig,
    shift_reports.date,
    sum(shift_reports.drilled_length_during_shift) AS drilled_length_per_day,
    repeat('|'::text, ((sum(shift_reports.drilled_length_during_shift) / (10)::numeric))::integer) AS graph_drilled_length_per_day,
    count(DISTINCT shift_reports.id) AS nb_drill_holes,
    min((shift_reports.id)::text) AS first_dh,
    max((shift_reports.id)::text) AS last_dh
   FROM pierre.shift_reports
  GROUP BY shift_reports.rig, shift_reports.date
  ORDER BY shift_reports.rig, shift_reports.date;


ALTER TABLE avancements_sondages_stats_quotidiennes OWNER TO pierre;

--
-- Name: longueur_exploree_par_location; Type: VIEW; Schema: stats_reports; Owner: pierre
--

CREATE VIEW longueur_exploree_par_location AS
 SELECT dh_collars.completed,
    dh_collars.location,
    dh_collars.dh_type,
    sum(dh_collars.length) AS sum_length
   FROM pierre.dh_collars
  GROUP BY dh_collars.completed, dh_collars.location, dh_collars.dh_type
  ORDER BY dh_collars.completed, dh_collars.location, dh_collars.dh_type;


ALTER TABLE longueur_exploree_par_location OWNER TO pierre;

--
-- Name: longueur_exploree_par_location_et_type; Type: VIEW; Schema: stats_reports; Owner: pierre
--

CREATE VIEW longueur_exploree_par_location_et_type AS
 SELECT dh_collars.location,
    dh_collars.dh_type,
    sum(dh_collars.length) AS sum
   FROM pierre.dh_collars
  WHERE dh_collars.completed
  GROUP BY dh_collars.location, dh_collars.dh_type
  ORDER BY dh_collars.location, dh_collars.dh_type DESC;


ALTER TABLE longueur_exploree_par_location_et_type OWNER TO pierre;

--
-- Name: longueur_exploree_par_type_km; Type: VIEW; Schema: stats_reports; Owner: pierre
--

CREATE VIEW longueur_exploree_par_type_km AS
 SELECT dh_collars.dh_type,
    (sum(dh_collars.length) / (1000)::numeric) AS km_explored_length
   FROM pierre.dh_collars
  GROUP BY dh_collars.dh_type
  ORDER BY dh_collars.dh_type DESC;


ALTER TABLE longueur_exploree_par_type_km OWNER TO pierre;

--
-- Name: recap_file_results_drill_holes; Type: VIEW; Schema: stats_reports; Owner: pierre
--

CREATE VIEW recap_file_results_drill_holes AS
 SELECT lex_datasource.filename,
    tmp3.datasource,
    tmp3.id,
    tmp3.nb_assay_values
   FROM (( SELECT DISTINCT tmp1.datasource,
            tmp2.id,
            count(*) AS nb_assay_values
           FROM (( SELECT lab_ana_results.opid,
                    lab_ana_results.sample_id,
                    lab_ana_results.datasource
                   FROM pierre.lab_ana_results) tmp1
             JOIN ( SELECT dh_sampling_grades.opid,
                    dh_sampling_grades.id,
                    dh_sampling_grades.sample_id
                   FROM pierre.dh_sampling_grades) tmp2 ON (((tmp1.opid = tmp2.opid) AND ((tmp1.sample_id)::text = (tmp2.sample_id)::text))))
          GROUP BY tmp1.datasource, tmp2.id) tmp3
     JOIN pierre.lex_datasource ON ((tmp3.datasource = lex_datasource.datasource_id)))
  ORDER BY tmp3.datasource, tmp3.id;


ALTER TABLE recap_file_results_drill_holes OWNER TO pierre;

--
-- Name: verif_attachements_journaliers_sondeur; Type: VIEW; Schema: stats_reports; Owner: pierre
--

CREATE VIEW verif_attachements_journaliers_sondeur AS
 SELECT shift_reports.date,
    sum(shift_reports.drilled_length_during_shift) AS drilled_length_per_day,
    repeat('|'::text, ((sum(shift_reports.drilled_length_during_shift) / (10)::numeric))::integer) AS graph_drilled_length_per_day,
    count(DISTINCT shift_reports.id) AS nb_drill_holes,
    min((shift_reports.id)::text) AS first_dh,
    max((shift_reports.id)::text) AS last_dh
   FROM pierre.shift_reports
  GROUP BY shift_reports.date
  ORDER BY shift_reports.date;


ALTER TABLE verif_attachements_journaliers_sondeur OWNER TO pierre;




CREATE VIEW cme_sampling_grades_last AS
 SELECT tmp_cme_sampling_grades_150102_utf8.hole_id,
    tmp_cme_sampling_grades_150102_utf8.sample_id,
    tmp_cme_sampling_grades_150102_utf8.sample_type,
    tmp_cme_sampling_grades_150102_utf8.depth_from,
    tmp_cme_sampling_grades_150102_utf8.depth_to,
    tmp_cme_sampling_grades_150102_utf8.au_ppm,
    tmp_cme_sampling_grades_150102_utf8.core_loss_m,
    tmp_cme_sampling_grades_150102_utf8.weight_kg,
    tmp_cme_sampling_grades_150102_utf8.comments,
    tmp_cme_sampling_grades_150102_utf8.opid
   FROM tmp_cme_sampling_grades_150102_utf8;


ALTER TABLE cme_sampling_grades_last OWNER TO pierre;



ALTER TABLE orientation OWNER TO pierre;




Des règles et contraintes:{{{

--
-- Name: dh_collars_points_latlon_rule_del; Type: RULE; Schema: public; Owner: pierre
--

CREATE RULE dh_collars_points_latlon_rule_del AS
    ON DELETE TO dh_collars_points_latlon DO INSTEAD  DELETE FROM dh_collars
  WHERE (dh_collars.numauto = old.numauto);
CREATE RULE dh_collars_points_latlon_rule_ins AS
    ON INSERT TO dh_collars_points_latlon DO INSTEAD  INSERT INTO dh_collars (id, shid, location, profile, srid, x, y, z, azim_ng, azim_nm, dip_hz, dh_type, date_start, contractor, geologist, length, nb_samples, comments, completed, date_completed, opid, purpose, x_local, y_local, z_local, accusum, id_pject, x_pject, y_pject, z_pject, topo_survey_type, datasource)
  VALUES (new.id, new.shid, new.location, new.profile, new.srid, new.x, new.y, new.z, new.azim_ng, new.azim_nm, new.dip_hz, new.dh_type, new.date_start, new.contractor, new.geologist, new.length, new.nb_samples, new.comments, new.completed, new.date_completed, new.opid, new.purpose, new.x_local, new.y_local, new.z_local, new.accusum, new.id_pject, new.x_pject, new.y_pject, new.z_pject, new.topo_survey_type, new.datasource);
CREATE RULE dh_collars_points_latlon_rule_upd AS
    ON UPDATE TO dh_collars_points_latlon DO INSTEAD  UPDATE dh_collars SET id = new.id, shid = new.shid, location = new.location, profile = new.profile, srid = new.srid, x = new.x, y = new.y, z = new.z, azim_ng = new.azim_ng, azim_nm = new.azim_nm, dip_hz = new.dip_hz, dh_type = new.dh_type, date_start = new.date_start, contractor = new.contractor, geologist = new.geologist, length = new.length, nb_samples = new.nb_samples, comments = new.comments, completed = new.completed, numauto = new.numauto, date_completed = new.date_completed, opid = new.opid, purpose = new.purpose, x_local = new.x_local, y_local = new.y_local, z_local = new.z_local, accusum = new.accusum, id_pject = new.id_pject, x_pject = new.x_pject, y_pject = new.y_pject, z_pject = new.z_pject, topo_survey_type = new.topo_survey_type, datasource = new.datasource
  WHERE (dh_collars.numauto = old.numauto);
CREATE RULE field_observations_points_del AS
    ON DELETE TO field_observations_points DO INSTEAD  DELETE FROM field_observations
  WHERE (field_observations.numauto = old.numauto);
CREATE RULE field_observations_points_ins_geom AS
    ON INSERT TO field_observations_points
   WHERE (((new.x IS NULL) AND (new.y IS NULL)) AND (new.geomfromewkt IS NOT NULL)) DO INSTEAD  INSERT INTO field_observations (opid, year, obs_id, date, waypoint_name, x, y, z, description, code_litho, code_unit, srid, geologist, icon_descr, comments, sample_id, datasource, photos, audio, timestamp_epoch_ms)
  VALUES (new.opid, new.year, new.obs_id, new.date, new.waypoint_name, st_x(new.geomfromewkt), st_y(new.geomfromewkt), st_z(new.geomfromewkt), new.description, new.code_litho, new.code_unit, new.srid, new.geologist, new.icon_descr, new.comments, new.sample_id, new.datasource, new.photos, new.audio, new.timestamp_epoch_ms);
CREATE RULE field_observations_points_ins_xy AS
    ON INSERT TO field_observations_points
   WHERE (((new.x IS NOT NULL) AND (new.y IS NOT NULL)) AND (new.geomfromewkt IS NULL)) DO INSTEAD  INSERT INTO field_observations (opid, year, obs_id, date, waypoint_name, x, y, z, description, code_litho, code_unit, srid, geologist, icon_descr, comments, sample_id, datasource, photos, audio, timestamp_epoch_ms)
  VALUES (new.opid, new.year, new.obs_id, new.date, new.waypoint_name, new.x, new.y, new.z, new.description, new.code_litho, new.code_unit, new.srid, new.geologist, new.icon_descr, new.comments, new.sample_id, new.datasource, new.photos, new.audio, new.timestamp_epoch_ms);
CREATE RULE field_observations_points_upd AS
    ON UPDATE TO field_observations_points DO INSTEAD  UPDATE field_observations SET opid = new.opid, year = new.year, obs_id = new.obs_id, date = new.date, waypoint_name = new.waypoint_name, x = new.x, y = new.y, z = new.z, description = new.description, code_litho = new.code_litho, code_unit = new.code_unit, srid = new.srid, geologist = new.geologist, icon_descr = new.icon_descr, comments = new.comments, sample_id = new.sample_id, datasource = new.datasource, photos = new.photos, audio = new.audio, timestamp_epoch_ms = new.timestamp_epoch_ms
  WHERE (field_observations.numauto = old.numauto);
CREATE RULE field_observations_rule_update_no_geom AS
    ON UPDATE TO field_observations_points
   WHERE (old.numauto = new.numauto) DO INSTEAD  UPDATE field_observations SET opid = new.opid, year = new.year, obs_id = new.obs_id, date = new.date, waypoint_name = new.waypoint_name, x = new.x, y = new.y, z = new.z, description = new.description, code_litho = new.code_litho, code_unit = new.code_unit, srid = new.srid, geologist = new.geologist, icon_descr = new.icon_descr, comments = new.comments, sample_id = new.sample_id, datasource = new.datasource, photos = new.photos, audio = new.audio, timestamp_epoch_ms = new.timestamp_epoch_ms
  WHERE (new.numauto = old.numauto);


SET search_path = pierre, pg_catalog;

--
-- Name: sections_definition_change; Type: TRIGGER; Schema: pierre; Owner: pierre
--

CREATE TRIGGER sections_definition_change AFTER INSERT OR UPDATE ON sections_definition FOR EACH ROW EXECUTE PROCEDURE public.generate_cross_sections_array();


SET search_path = public, pg_catalog;

--
-- Name: lab_ana_results_insert; Type: TRIGGER; Schema: public; Owner: data_admin
--

CREATE TRIGGER lab_ana_results_insert AFTER INSERT ON lab_ana_results FOR EACH STATEMENT EXECUTE PROCEDURE lab_ana_results_sample_id_default_value_num();
ALTER TABLE ONLY dh_collars
    ADD CONSTRAINT dh_collars_opid_fkey FOREIGN KEY (opid) REFERENCES operations(opid) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE ONLY dh_core_boxes
    ADD CONSTRAINT dh_core_boxes_opid_fkey FOREIGN KEY (opid, id) REFERENCES dh_collars(opid, id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE ONLY dh_density
    ADD CONSTRAINT dh_density_opid_fkey FOREIGN KEY (opid, id) REFERENCES dh_collars(opid, id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE ONLY dh_devia
    ADD CONSTRAINT dh_devia_opid_fkey FOREIGN KEY (opid, id) REFERENCES dh_collars(opid, id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE ONLY dh_followup
    ADD CONSTRAINT dh_followup_opid_fkey FOREIGN KEY (opid, id) REFERENCES dh_collars(opid, id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE ONLY dh_litho
    ADD CONSTRAINT dh_litho_opid_fkey FOREIGN KEY (opid, id) REFERENCES dh_collars(opid, id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE ONLY dh_mineralised_intervals
    ADD CONSTRAINT dh_mineralised_intervals_opid_fkey FOREIGN KEY (opid, id) REFERENCES dh_collars(opid, id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE ONLY dh_quicklog
    ADD CONSTRAINT dh_quicklog_opid_fkey FOREIGN KEY (opid, id) REFERENCES dh_collars(opid, id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE ONLY dh_sampling_bottle_roll
    ADD CONSTRAINT dh_sampling_bottle_roll_opid_fkey FOREIGN KEY (opid, id) REFERENCES dh_collars(opid, id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE ONLY dh_sampling_grades
    ADD CONSTRAINT dh_sampling_grades_opid_fkey FOREIGN KEY (opid, id) REFERENCES dh_collars(opid, id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE ONLY dh_struct_measures
    ADD CONSTRAINT dh_struct_measures_opid_fkey FOREIGN KEY (opid, id) REFERENCES dh_collars(opid, id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE ONLY dh_tech
    ADD CONSTRAINT dh_tech_opid_fkey FOREIGN KEY (opid, id) REFERENCES dh_collars(opid, id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE ONLY dh_thinsections
    ADD CONSTRAINT dh_thinsections_opid_fkey FOREIGN KEY (opid, id) REFERENCES dh_collars(opid, id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE ONLY field_observations
    ADD CONSTRAINT field_observations_opid_fkey FOREIGN KEY (opid) REFERENCES operations(opid) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE ONLY field_observations_struct_measures
    ADD CONSTRAINT field_observations_struct_measures_opid_fkey FOREIGN KEY (opid, obs_id) REFERENCES field_observations(opid, obs_id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE ONLY mag_declination
    ADD CONSTRAINT mag_declination_opid_fkey FOREIGN KEY (opid) REFERENCES operations(opid) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE ONLY occurrences
    ADD CONSTRAINT occurrences_opid_fkey FOREIGN KEY (opid) REFERENCES operations(opid) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE ONLY occurrences_recup_depuis_dump
    ADD CONSTRAINT occurrences_recup_depuis_dump_opid_fkey FOREIGN KEY (opid) REFERENCES operations(opid) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE ONLY shift_reports
    ADD CONSTRAINT shift_reports_opid_fkey FOREIGN KEY (opid, id) REFERENCES dh_collars(opid, id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;

}}}

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;
GRANT ALL ON SCHEMA public TO data_admin WITH GRANT OPTION;
REVOKE ALL ON FUNCTION addgeometrycolumn(character varying, character varying, integer, character varying, integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION addgeometrycolumn(character varying, character varying, integer, character varying, integer) FROM postgres;
GRANT ALL ON FUNCTION addgeometrycolumn(character varying, character varying, integer, character varying, integer) TO postgres;
GRANT ALL ON FUNCTION addgeometrycolumn(character varying, character varying, integer, character varying, integer) TO PUBLIC;
GRANT ALL ON FUNCTION addgeometrycolumn(character varying, character varying, integer, character varying, integer) TO data_admin WITH GRANT OPTION;
REVOKE ALL ON FUNCTION addgeometrycolumn(character varying, character varying, character varying, integer, character varying, integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION addgeometrycolumn(character varying, character varying, character varying, integer, character varying, integer) FROM postgres;
GRANT ALL ON FUNCTION addgeometrycolumn(character varying, character varying, character varying, integer, character varying, integer) TO postgres;
GRANT ALL ON FUNCTION addgeometrycolumn(character varying, character varying, character varying, integer, character varying, integer) TO PUBLIC;
GRANT ALL ON FUNCTION addgeometrycolumn(character varying, character varying, character varying, integer, character varying, integer) TO data_admin WITH GRANT OPTION;
REVOKE ALL ON FUNCTION addgeometrycolumn(character varying, character varying, character varying, character varying, integer, character varying, integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION addgeometrycolumn(character varying, character varying, character varying, character varying, integer, character varying, integer) FROM postgres;
GRANT ALL ON FUNCTION addgeometrycolumn(character varying, character varying, character varying, character varying, integer, character varying, integer) TO postgres;
GRANT ALL ON FUNCTION addgeometrycolumn(character varying, character varying, character varying, character varying, integer, character varying, integer) TO PUBLIC;
GRANT ALL ON FUNCTION addgeometrycolumn(character varying, character varying, character varying, character varying, integer, character varying, integer) TO data_admin WITH GRANT OPTION;
REVOKE ALL ON FUNCTION fix_geometry_columns() FROM PUBLIC;
REVOKE ALL ON FUNCTION fix_geometry_columns() FROM postgres;
GRANT ALL ON FUNCTION fix_geometry_columns() TO postgres;
GRANT ALL ON FUNCTION fix_geometry_columns() TO PUBLIC;
GRANT ALL ON FUNCTION fix_geometry_columns() TO data_admin WITH GRANT OPTION;
REVOKE ALL ON FUNCTION lab_ana_results_sample_id_default_value_num() FROM PUBLIC;
REVOKE ALL ON FUNCTION lab_ana_results_sample_id_default_value_num() FROM pierre;
GRANT ALL ON FUNCTION lab_ana_results_sample_id_default_value_num() TO pierre;
GRANT ALL ON FUNCTION lab_ana_results_sample_id_default_value_num() TO data_admin WITH GRANT OPTION;
GRANT ALL ON FUNCTION lab_ana_results_sample_id_default_value_num() TO PUBLIC;
REVOKE ALL ON FUNCTION populate_geometry_columns() FROM PUBLIC;
REVOKE ALL ON FUNCTION populate_geometry_columns() FROM postgres;
GRANT ALL ON FUNCTION populate_geometry_columns() TO postgres;
GRANT ALL ON FUNCTION populate_geometry_columns() TO PUBLIC;
GRANT ALL ON FUNCTION populate_geometry_columns() TO data_admin WITH GRANT OPTION;
REVOKE ALL ON FUNCTION populate_geometry_columns(tbl_oid oid) FROM PUBLIC;
REVOKE ALL ON FUNCTION populate_geometry_columns(tbl_oid oid) FROM postgres;
GRANT ALL ON FUNCTION populate_geometry_columns(tbl_oid oid) TO postgres;
GRANT ALL ON FUNCTION populate_geometry_columns(tbl_oid oid) TO PUBLIC;
GRANT ALL ON FUNCTION populate_geometry_columns(tbl_oid oid) TO data_admin WITH GRANT OPTION;
REVOKE ALL ON FUNCTION probe_geometry_columns() FROM PUBLIC;
REVOKE ALL ON FUNCTION probe_geometry_columns() FROM postgres;
GRANT ALL ON FUNCTION probe_geometry_columns() TO postgres;
GRANT ALL ON FUNCTION probe_geometry_columns() TO PUBLIC;
GRANT ALL ON FUNCTION probe_geometry_columns() TO data_admin WITH GRANT OPTION;
REVOKE ALL ON FUNCTION rename_geometry_table_constraints() FROM PUBLIC;
REVOKE ALL ON FUNCTION rename_geometry_table_constraints() FROM postgres;
GRANT ALL ON FUNCTION rename_geometry_table_constraints() TO postgres;
GRANT ALL ON FUNCTION rename_geometry_table_constraints() TO PUBLIC;
GRANT ALL ON FUNCTION rename_geometry_table_constraints() TO data_admin WITH GRANT OPTION;
REVOKE ALL ON FUNCTION st_asbinary(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION st_asbinary(text) FROM postgres;
GRANT ALL ON FUNCTION st_asbinary(text) TO postgres;
GRANT ALL ON FUNCTION st_asbinary(text) TO PUBLIC;
GRANT ALL ON FUNCTION st_asbinary(text) TO data_admin WITH GRANT OPTION;
REVOKE ALL ON TABLE dh_collars FROM PUBLIC;
REVOKE ALL ON TABLE dh_collars FROM data_admin;
GRANT ALL ON TABLE dh_collars TO data_admin;
REVOKE ALL ON TABLE operation_active FROM PUBLIC;
REVOKE ALL ON TABLE operation_active FROM data_admin;
GRANT ALL ON TABLE operation_active TO data_admin;
REVOKE ALL ON TABLE dh_litho FROM PUBLIC;
REVOKE ALL ON TABLE dh_litho FROM data_admin;
GRANT ALL ON TABLE dh_litho TO data_admin;
REVOKE ALL ON TABLE dh_sampling_grades FROM PUBLIC;
REVOKE ALL ON TABLE dh_sampling_grades FROM data_admin;
GRANT ALL ON TABLE dh_sampling_grades TO data_admin;
REVOKE ALL ON TABLE topo_points FROM PUBLIC;
REVOKE ALL ON TABLE topo_points FROM data_admin;
GRANT ALL ON TABLE topo_points TO data_admin;
GRANT ALL ON TABLE topo_points TO postgres;
REVOKE ALL ON TABLE shift_reports FROM PUBLIC;
REVOKE ALL ON TABLE shift_reports FROM data_admin;
GRANT ALL ON TABLE shift_reports TO data_admin;
REVOKE ALL ON TABLE dh_devia FROM PUBLIC;
REVOKE ALL ON TABLE dh_devia FROM data_admin;
GRANT ALL ON TABLE dh_devia TO data_admin;
GRANT ALL ON TABLE dh_devia TO postgres;
REVOKE ALL ON TABLE ancient_workings FROM PUBLIC;
REVOKE ALL ON TABLE ancient_workings FROM data_admin;
GRANT ALL ON TABLE ancient_workings TO data_admin;
REVOKE ALL ON TABLE baselines FROM PUBLIC;
REVOKE ALL ON TABLE baselines FROM data_admin;
GRANT ALL ON TABLE baselines TO data_admin;
REVOKE ALL ON TABLE lab_ana_results FROM PUBLIC;
REVOKE ALL ON TABLE lab_ana_results FROM data_admin;
GRANT ALL ON TABLE lab_ana_results TO data_admin;
REVOKE ALL ON TABLE dh_core_boxes FROM PUBLIC;
REVOKE ALL ON TABLE dh_core_boxes FROM data_admin;
GRANT ALL ON TABLE dh_core_boxes TO data_admin;
REVOKE ALL ON TABLE dh_density FROM PUBLIC;
REVOKE ALL ON TABLE dh_density FROM data_admin;
GRANT ALL ON TABLE dh_density TO data_admin;
REVOKE ALL ON TABLE dh_followup FROM PUBLIC;
REVOKE ALL ON TABLE dh_followup FROM data_admin;
GRANT ALL ON TABLE dh_followup TO data_admin;
REVOKE ALL ON TABLE dh_mineralised_intervals FROM PUBLIC;
REVOKE ALL ON TABLE dh_mineralised_intervals FROM data_admin;
GRANT ALL ON TABLE dh_mineralised_intervals TO data_admin;
GRANT ALL ON TABLE dh_mineralised_intervals TO postgres;
REVOKE ALL ON TABLE dh_quicklog FROM PUBLIC;
REVOKE ALL ON TABLE dh_quicklog FROM data_admin;
GRANT ALL ON TABLE dh_quicklog TO data_admin;
REVOKE ALL ON TABLE dh_sampling_bottle_roll FROM PUBLIC;
REVOKE ALL ON TABLE dh_sampling_bottle_roll FROM data_admin;
GRANT ALL ON TABLE dh_sampling_bottle_roll TO data_admin;
REVOKE ALL ON TABLE dh_struct_measures FROM PUBLIC;
REVOKE ALL ON TABLE dh_struct_measures FROM data_admin;
GRANT ALL ON TABLE dh_struct_measures TO data_admin;
REVOKE ALL ON TABLE dh_tech FROM PUBLIC;
REVOKE ALL ON TABLE dh_tech FROM data_admin;
GRANT ALL ON TABLE dh_tech TO data_admin;
GRANT ALL ON TABLE dh_tech TO postgres;
REVOKE ALL ON TABLE dh_thinsections FROM PUBLIC;
REVOKE ALL ON TABLE dh_thinsections FROM data_admin;
GRANT ALL ON TABLE dh_thinsections TO data_admin;
REVOKE ALL ON TABLE field_observations FROM PUBLIC;
REVOKE ALL ON TABLE field_observations FROM data_admin;
GRANT ALL ON TABLE field_observations TO data_admin;
REVOKE ALL ON TABLE field_observations_struct_measures FROM PUBLIC;
REVOKE ALL ON TABLE field_observations_struct_measures FROM data_admin;
GRANT ALL ON TABLE field_observations_struct_measures TO data_admin;
REVOKE ALL ON TABLE field_photos FROM PUBLIC;
REVOKE ALL ON TABLE field_photos FROM data_admin;
GRANT ALL ON TABLE field_photos TO data_admin;
REVOKE ALL ON TABLE formations_group_lithos FROM PUBLIC;
REVOKE ALL ON TABLE formations_group_lithos FROM data_admin;
GRANT ALL ON TABLE formations_group_lithos TO data_admin;
REVOKE ALL ON TABLE geoch_ana FROM PUBLIC;
REVOKE ALL ON TABLE geoch_ana FROM data_admin;
GRANT ALL ON TABLE geoch_ana TO data_admin;
GRANT ALL ON TABLE geoch_ana TO postgres;
REVOKE ALL ON TABLE geoch_sampling FROM PUBLIC;
REVOKE ALL ON TABLE geoch_sampling FROM data_admin;
GRANT ALL ON TABLE geoch_sampling TO data_admin;
GRANT ALL ON TABLE geoch_sampling TO postgres;
REVOKE ALL ON TABLE geoch_sampling_grades FROM PUBLIC;
REVOKE ALL ON TABLE geoch_sampling_grades FROM data_admin;
GRANT ALL ON TABLE geoch_sampling_grades TO data_admin;
REVOKE ALL ON TABLE gpy_mag_ground FROM PUBLIC;
REVOKE ALL ON TABLE gpy_mag_ground FROM data_admin;
GRANT ALL ON TABLE gpy_mag_ground TO data_admin;
REVOKE ALL ON TABLE grade_ctrl FROM PUBLIC;
REVOKE ALL ON TABLE grade_ctrl FROM data_admin;
GRANT ALL ON TABLE grade_ctrl TO data_admin;
GRANT ALL ON TABLE grade_ctrl TO postgres;


SET search_path = pierre, pg_catalog;

--
-- Name: rock_ana; Type: ACL; Schema: pierre; Owner: pierre
--

REVOKE ALL ON TABLE rock_ana FROM PUBLIC;
REVOKE ALL ON TABLE rock_ana FROM pierre;
GRANT ALL ON TABLE rock_ana TO pierre;
GRANT ALL ON TABLE rock_ana TO postgres;

SET search_path = public, pg_catalog;

--
-- Name: index_geo_documentation; Type: ACL; Schema: public; Owner: data_admin
--

REVOKE ALL ON TABLE index_geo_documentation FROM PUBLIC;
REVOKE ALL ON TABLE index_geo_documentation FROM data_admin;
GRANT ALL ON TABLE index_geo_documentation TO data_admin;
REVOKE ALL ON TABLE lab_ana_batches_expedition FROM PUBLIC;
REVOKE ALL ON TABLE lab_ana_batches_expedition FROM data_admin;
GRANT ALL ON TABLE lab_ana_batches_expedition TO data_admin;
REVOKE ALL ON TABLE lab_ana_batches_reception FROM PUBLIC;
REVOKE ALL ON TABLE lab_ana_batches_reception FROM data_admin;
GRANT ALL ON TABLE lab_ana_batches_reception TO data_admin;
REVOKE ALL ON TABLE lab_ana_columns_definition FROM PUBLIC;
REVOKE ALL ON TABLE lab_ana_columns_definition FROM data_admin;
GRANT ALL ON TABLE lab_ana_columns_definition TO data_admin;
REVOKE ALL ON TABLE lab_ana_qaqc_results FROM PUBLIC;
REVOKE ALL ON TABLE lab_ana_qaqc_results FROM data_admin;
GRANT ALL ON TABLE lab_ana_qaqc_results TO data_admin;
REVOKE ALL ON TABLE lex_codes FROM PUBLIC;
REVOKE ALL ON TABLE lex_codes FROM data_admin;
GRANT ALL ON TABLE lex_codes TO data_admin;
REVOKE ALL ON TABLE lex_datasource FROM PUBLIC;
REVOKE ALL ON TABLE lex_datasource FROM data_admin;
GRANT ALL ON TABLE lex_datasource TO data_admin;
REVOKE ALL ON TABLE lex_standard FROM PUBLIC;
REVOKE ALL ON TABLE lex_standard FROM data_admin;
GRANT ALL ON TABLE lex_standard TO data_admin;
REVOKE ALL ON TABLE licences FROM PUBLIC;
REVOKE ALL ON TABLE licences FROM data_admin;
GRANT ALL ON TABLE licences TO data_admin;
REVOKE ALL ON TABLE mag_declination FROM PUBLIC;
REVOKE ALL ON TABLE mag_declination FROM data_admin;
GRANT ALL ON TABLE mag_declination TO data_admin;
REVOKE ALL ON TABLE occurrences FROM PUBLIC;
REVOKE ALL ON TABLE occurrences FROM data_admin;
GRANT ALL ON TABLE occurrences TO data_admin;
REVOKE ALL ON TABLE operations FROM PUBLIC;
REVOKE ALL ON TABLE operations FROM data_admin;
GRANT ALL ON TABLE operations TO data_admin;
REVOKE ALL ON TABLE qc_sampling FROM PUBLIC;
REVOKE ALL ON TABLE qc_sampling FROM data_admin;
GRANT ALL ON TABLE qc_sampling TO data_admin;
REVOKE ALL ON TABLE qc_standards FROM PUBLIC;
REVOKE ALL ON TABLE qc_standards FROM data_admin;
GRANT ALL ON TABLE qc_standards TO data_admin;


SET search_path = pierre, pg_catalog;

--
-- Name: rock_sampling; Type: ACL; Schema: pierre; Owner: pierre
--

REVOKE ALL ON TABLE rock_sampling FROM PUBLIC;
REVOKE ALL ON TABLE rock_sampling FROM pierre;
GRANT ALL ON TABLE rock_sampling TO pierre;
GRANT ALL ON TABLE rock_sampling TO postgres;


SET search_path = public, pg_catalog;

--
-- Name: surface_samples_grades; Type: ACL; Schema: public; Owner: data_admin
--

REVOKE ALL ON TABLE surface_samples_grades FROM PUBLIC;
REVOKE ALL ON TABLE surface_samples_grades FROM data_admin;
GRANT ALL ON TABLE surface_samples_grades TO data_admin;
REVOKE ALL ON TABLE geometry_columns_old FROM PUBLIC;
REVOKE ALL ON TABLE geometry_columns_old FROM postgres;
GRANT ALL ON TABLE geometry_columns_old TO postgres;
GRANT ALL ON TABLE geometry_columns_old TO pierre;
GRANT ALL ON TABLE geometry_columns_old TO data_admin WITH GRANT OPTION;
REVOKE ALL ON TABLE occurrences_recup_depuis_dump FROM PUBLIC;
REVOKE ALL ON TABLE occurrences_recup_depuis_dump FROM data_admin;
GRANT ALL ON TABLE occurrences_recup_depuis_dump TO data_admin;
REVOKE ALL ON TABLE spatial_ref_sys_old FROM PUBLIC;
REVOKE ALL ON TABLE spatial_ref_sys_old FROM postgres;
GRANT ALL ON TABLE spatial_ref_sys_old TO postgres;
GRANT SELECT ON TABLE spatial_ref_sys_old TO pierre;
GRANT ALL ON TABLE spatial_ref_sys_old TO data_admin WITH GRANT OPTION;

}}}

_______________ENCOURS_______________GEOLLLIBRE ^


-- @#TODO 2 backups et une table, à voir plus tard:{{{
--
-- Name: field_observations_2016_03_09_14h08; Type: TABLE; Schema: backups; Owner: pierre; Tablespace: 
--

CREATE TABLE field_observations_2016_03_09_14h08 (
    opid integer,
    year integer,
    obs_id text,
    date date,
    waypoint_name text,
    x numeric(20,10),
    y numeric(20,10),
    z numeric(20,2),
    description text,
    code_litho text,
    code_unit text,
    srid integer,
    geologist text,
    icon_descr text,
    comments text,
    sample_id text,
    datasource integer,
    numauto integer,
    photos text,
    audio text,
    timestamp_epoch_ms bigint,
    creation_ts timestamp without time zone,
    username text,
    device text,
    "time" text
);


ALTER TABLE field_observations_2016_03_09_14h08 OWNER TO pierre;

--
-- Name: field_observations_struct_measures_2016_03_09_14h10; Type: TABLE; Schema: backups; Owner: pierre; Tablespace: 
--

CREATE TABLE field_observations_struct_measures_2016_03_09_14h10 (
    opid integer,
    obs_id text,
    measure_type text,
    structure_type text,
    north_ref text,
    direction integer,
    dip integer,
    dip_quadrant text,
    pitch integer,
    pitch_quadrant text,
    movement text,
    valid boolean,
    comments text,
    numauto integer,
    creation_ts timestamp without time zone,
    username text,
    datasource integer,
    rotation_matrix text,
    geolpda_id integer,
    geolpda_poi_id integer,
    sortgroup text,
    device text
);


ALTER TABLE field_observations_struct_measures_2016_03_09_14h10 OWNER TO pierre;



CREATE TABLE bondoukou_alain_lambert_icp (
    sio2 double precision,
    al2o3 double precision,
    fe2o3 double precision,
    cao double precision,
    mgo double precision,
    k2o double precision,
    mno double precision,
    tio2 double precision,
    p2o5 double precision,
    li double precision,
    be double precision,
    b double precision,
    v double precision,
    cr double precision,
    co double precision,
    ni double precision,
    cu double precision,
    zn double precision,
    "As" double precision,
    sr double precision,
    y double precision,
    nb double precision,
    mo double precision,
    ag double precision,
    cd double precision,
    sn double precision,
    sb double precision,
    ba double precision,
    la double precision,
    ce double precision,
    w double precision,
    pb double precision,
    bi double precision,
    zr double precision,
    indr integer
);
ALTER TABLE bondoukou_alain_lambert_icp OWNER TO pierre;

}}}

/*-- xTODO à mettre ailleurs que dans postgeol:{{{


--
-- Name: european_federation_geologists_members; Type: TABLE; Schema: pierre; Owner: pierre; Tablespace: 
--
CREATE TABLE european_federation_geologists_members (
    year integer,
    no integer,
    award_date date,
    surname text,
    first_name text,
    licensed_body text,
    country text,
    known integer,
    update_date date
);
ALTER TABLE european_federation_geologists_members OWNER TO pierre;

--
-- Name: european_federation_geologists_members_latest; Type: VIEW; Schema: pierre; Owner: pierre
--
CREATE VIEW european_federation_geologists_members_latest AS
 SELECT european_federation_geologists_members.no,
    european_federation_geologists_members.surname,
    european_federation_geologists_members.first_name,
    european_federation_geologists_members.licensed_body,
    european_federation_geologists_members.country,
    european_federation_geologists_members.known,
    european_federation_geologists_members.update_date
   FROM european_federation_geologists_members
  WHERE (european_federation_geologists_members.update_date = ( SELECT max(european_federation_geologists_members_1.update_date) AS max
           FROM european_federation_geologists_members european_federation_geologists_members_1));
ALTER TABLE european_federation_geologists_members_latest OWNER TO pierre;



--
-- Name: pchgeol_rapports; Type: TABLE; Schema: pierre; Owner: pierre; Tablespace: 
--
CREATE TABLE pchgeol_rapports (
    numrap integer NOT NULL,
    date date DEFAULT ('now'::text)::date,
    titre text,
    fini boolean,
    filename text,
    opid integer,
    client text,
    print boolean,
    comments text,
    language text
);
ALTER TABLE pchgeol_rapports OWNER TO pierre;

CREATE VIEW pchgeol_rapports_liste_biblio_cv AS
 SELECT (((((('Chevalier P. ('::text || to_char((pchgeol_rapports.date)::timestamp with time zone, 'YYYY'::text)) || ') - '::text) || (pchgeol_rapports.titre)::text) || '. Rapport PChGeol '::text) || replace((((((pchgeol_rapports.numrap)::numeric(10,2) / (100)::numeric))::numeric(10,2))::text)::text, '.'::text, '-'::text)) || COALESCE((' pour '::text || (pchgeol_rapports.client)::text), ''::text)) AS ref_biblio_pour_cv
   FROM pchgeol_rapports
  ORDER BY pchgeol_rapports.numrap DESC;
ALTER TABLE pchgeol_rapports_liste_biblio_cv OWNER TO pierre;





CREATE TABLE songs (
    artist text,
    title text,
    whosuggests text,
    url text,
    mp3_as_from_youtube text,
    mp3 text,
    numauto integer NOT NULL,
    au_point integer
);
ALTER TABLE songs OWNER TO pierre;





--
-- Name: pieces_mouvts; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--
CREATE TABLE pieces_mouvts (
    date_doc_internes text,
    jour_doc_internes text,
    reference_article text,
    designation text,
    no_piece text,
    reference text,
    quantite numeric,
    cmup numeric,
    montant numeric,
    code_affaire text,
    intitule_document text,
    depot text
);
ALTER TABLE pieces_mouvts OWNER TO pierre;

--
-- Name: pieces_stock_fin_2011; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE pieces_stock_fin_2011 (
    reference_article text,
    reference_designation_article text,
    emplacement_principal text,
    qte_stock_reel numeric,
    qte_disponible numeric,
    cmup_unitaire numeric,
    montant_stock__cmup_ numeric,
    controle_prix numeric,
    ecart numeric
);


ALTER TABLE pieces_stock_fin_2011 OWNER TO pierre;




--
-- Name: tmp_africa_powermining_projects_database; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_africa_powermining_projects_database (
    property_name text,
    country text,
    commodity text,
    type_of_work text,
    status text,
    extent_of_processing text,
    best_reserve_available text,
    reserves_tonnes_000_units text,
    reserve_grade text,
    reserve_grade_unit text,
    current_production text,
    current_production_unit text,
    expected_yearly_production_at_full_capacity text,
    _expected_production_at_full_capacity_unit text,
    life_of_mine_years text,
    project_inception_year text,
    project_completion_year text,
    company_name text,
    "_expected_investment_mm$" text,
    probability_to_move_to_investment_by_2020 text,
    power_sourcing_arrangement_or_relationship_between_mine_n_grid text,
    source_of_power text,
    energy_consumption_kwh_per_t_product text,
    annual_energy_consumption_mwh text,
    energy_needs_mw text,
    shareholding_code text,
    mine_location text,
    location_notes text,
    region text,
    tariff_public_utility text,
    cost_relativity text,
    grid_energy_source text,
    grid_reliability text,
    source text,
    notes text,
    reference text,
    projects_pre_2000 text,
    projects_2001_2012 text,
    projects_2020 text
);


ALTER TABLE tmp_africa_powermining_projects_database OWNER TO pierre;




--
-- Name: tmp_european_federation_geologists_members; Type: TABLE; Schema: tmp_imports; Owner: pierre; Tablespace: 
--

CREATE TABLE tmp_european_federation_geologists_members (
    year text,
    no_ text,
    award_date_ text,
    surname text,
    first_name_ text,
    licensed_body_ text,
    country text
);


ALTER TABLE tmp_european_federation_geologists_members OWNER TO pierre;


}}}
=> passé dans la bd pierre */

/*non: {{{

--
-- Name: dh_nb_samples; Type: TABLE; Schema: pierre; Owner: pierre; Tablespace: 
--
CREATE TABLE dh_nb_samples (
    opid integer,
    id text,
    nb_samples integer
);
ALTER TABLE dh_nb_samples OWNER TO pierre;
COMMENT ON COLUMN dh_nb_samples.nb_samples IS 'Number of samples';



}}}*/

/*séquences (qui seront automatiques):{{{
CREATE SEQUENCE dh_collars_lengths_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE dh_collars_lengths_numauto_seq OWNER TO pierre;
ALTER SEQUENCE dh_collars_lengths_numauto_seq OWNED BY dh_collars_lengths.numauto;


--
-- Name: tmp_ity_gpspolo_travaux_97et2004_numauto_seq; Type: SEQUENCE; Schema: tmp_imports; Owner: pierre
--

CREATE SEQUENCE tmp_ity_gpspolo_travaux_97et2004_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tmp_ity_gpspolo_travaux_97et2004_numauto_seq OWNER TO pierre;

--
-- Name: tmp_ity_gpspolo_travaux_97et2004_numauto_seq; Type: SEQUENCE OWNED BY; Schema: tmp_imports; Owner: pierre
--

ALTER SEQUENCE tmp_ity_gpspolo_travaux_97et2004_numauto_seq OWNED BY tmp_ity_gpspolo_travaux_97et2004.numauto;


--
-- Name: tmp_tt_pierre_nettoye_uploader_wpt_numauto_seq; Type: SEQUENCE; Schema: tmp_imports; Owner: pierre
--

CREATE SEQUENCE tmp_tt_pierre_nettoye_uploader_wpt_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tmp_tt_pierre_nettoye_uploader_wpt_numauto_seq OWNER TO pierre;

--
-- Name: tmp_tt_pierre_nettoye_uploader_wpt_numauto_seq; Type: SEQUENCE OWNED BY; Schema: tmp_imports; Owner: pierre
--

ALTER SEQUENCE tmp_tt_pierre_nettoye_uploader_wpt_numauto_seq OWNED BY tmp_tt_pierre_nettoye_uploader_wpt.numauto;
CREATE VIEW tmp_tt_pierre_nettoye_uploader_wpt_points AS
 SELECT tmp_tt_pierre_nettoye_uploader_wpt.h,
    tmp_tt_pierre_nettoye_uploader_wpt.idnt,
    tmp_tt_pierre_nettoye_uploader_wpt.latitude,
    tmp_tt_pierre_nettoye_uploader_wpt.longitude,
    tmp_tt_pierre_nettoye_uploader_wpt.date,
    tmp_tt_pierre_nettoye_uploader_wpt."time",
    tmp_tt_pierre_nettoye_uploader_wpt.alt,
    tmp_tt_pierre_nettoye_uploader_wpt.description,
    tmp_tt_pierre_nettoye_uploader_wpt.proximity,
    tmp_tt_pierre_nettoye_uploader_wpt.symbol,
    tmp_tt_pierre_nettoye_uploader_wpt.lat_dd,
    tmp_tt_pierre_nettoye_uploader_wpt.lon_dd,
    tmp_tt_pierre_nettoye_uploader_wpt.numauto,
    public.geomfromewkt((((('SRID=4326; POINT('::text || tmp_tt_pierre_nettoye_uploader_wpt.lon_dd) || ' '::text) || tmp_tt_pierre_nettoye_uploader_wpt.lat_dd) || ')'::text)) AS geomfromewkt
   FROM tmp_tt_pierre_nettoye_uploader_wpt;


--
-- Name: tmp_tt_pts_gps_mdb_copie_numauto_seq; Type: SEQUENCE; Schema: tmp_imports; Owner: pierre
--

CREATE SEQUENCE tmp_tt_pts_gps_mdb_copie_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tmp_tt_pts_gps_mdb_copie_numauto_seq OWNER TO pierre;

--
-- Name: tmp_tt_pts_gps_mdb_copie_numauto_seq; Type: SEQUENCE OWNED BY; Schema: tmp_imports; Owner: pierre
--

ALTER SEQUENCE tmp_tt_pts_gps_mdb_copie_numauto_seq OWNED BY tmp_tt_pts_gps_mdb_copie.numauto;
CREATE VIEW tmp_tt_pts_gps_mdb_copie_points AS
 SELECT tmp_tt_pts_gps_mdb_copie.no,
    tmp_tt_pts_gps_mdb_copie.idnt,
    tmp_tt_pts_gps_mdb_copie.latitude,
    tmp_tt_pts_gps_mdb_copie.longitude,
    tmp_tt_pts_gps_mdb_copie.date,
    tmp_tt_pts_gps_mdb_copie."time",
    tmp_tt_pts_gps_mdb_copie.alt,
    tmp_tt_pts_gps_mdb_copie.descriptio,
    tmp_tt_pts_gps_mdb_copie.proximity,
    tmp_tt_pts_gps_mdb_copie.symbol__,
    tmp_tt_pts_gps_mdb_copie.mapinfo_id,
    tmp_tt_pts_gps_mdb_copie.lat_dd,
    tmp_tt_pts_gps_mdb_copie.lon_dd,
    tmp_tt_pts_gps_mdb_copie.numauto,
    public.geomfromewkt((((('SRID=4326; POINT('::text || tmp_tt_pts_gps_mdb_copie.lon_dd) || ' '::text) || tmp_tt_pts_gps_mdb_copie.lat_dd) || ')'::text)) AS geomfromewkt
   FROM tmp_tt_pts_gps_mdb_copie;


--
-- Name: tmp_tt_pts_gps_mdb_points_latlong_numauto_seq; Type: SEQUENCE; Schema: tmp_imports; Owner: pierre
--

CREATE SEQUENCE tmp_tt_pts_gps_mdb_points_latlong_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tmp_tt_pts_gps_mdb_points_latlong_numauto_seq OWNER TO pierre;

--
-- Name: tmp_tt_pts_gps_mdb_points_latlong_numauto_seq; Type: SEQUENCE OWNED BY; Schema: tmp_imports; Owner: pierre
--

ALTER SEQUENCE tmp_tt_pts_gps_mdb_points_latlong_numauto_seq OWNED BY tmp_tt_pts_gps_mdb_points_latlong.numauto;
CREATE VIEW tmp_tt_pts_gps_mdb_points_latlong_points AS
 SELECT tmp_tt_pts_gps_mdb_points_latlong.idnt,
    tmp_tt_pts_gps_mdb_points_latlong."time",
    tmp_tt_pts_gps_mdb_points_latlong.alt,
    tmp_tt_pts_gps_mdb_points_latlong.descriptio,
    tmp_tt_pts_gps_mdb_points_latlong.symbol__,
    tmp_tt_pts_gps_mdb_points_latlong.no,
    tmp_tt_pts_gps_mdb_points_latlong.date,
    tmp_tt_pts_gps_mdb_points_latlong.lat_ns,
    tmp_tt_pts_gps_mdb_points_latlong.lon_eo,
    tmp_tt_pts_gps_mdb_points_latlong.latitude,
    tmp_tt_pts_gps_mdb_points_latlong.longitude,
    tmp_tt_pts_gps_mdb_points_latlong.lat_dd,
    tmp_tt_pts_gps_mdb_points_latlong.lon_dd,
    tmp_tt_pts_gps_mdb_points_latlong.numauto,
    public.geomfromewkt((((('SRID=4326 ;POINT ('::text || tmp_tt_pts_gps_mdb_points_latlong.lon_dd) || ' '::text) || tmp_tt_pts_gps_mdb_points_latlong.lat_dd) || ')'::text)) AS geomfromewkt
   FROM tmp_tt_pts_gps_mdb_points_latlong;


--
-- Name: tmp_tt_pts_gps_mdb_sdqrfgadzrg_numauto_seq; Type: SEQUENCE; Schema: tmp_imports; Owner: pierre
--

CREATE SEQUENCE tmp_tt_pts_gps_mdb_sdqrfgadzrg_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tmp_tt_pts_gps_mdb_sdqrfgadzrg_numauto_seq OWNER TO pierre;

--
-- Name: tmp_tt_pts_gps_mdb_sdqrfgadzrg_numauto_seq; Type: SEQUENCE OWNED BY; Schema: tmp_imports; Owner: pierre
--

ALTER SEQUENCE tmp_tt_pts_gps_mdb_sdqrfgadzrg_numauto_seq OWNED BY tmp_tt_pts_gps_mdb_sdqrfgadzrg.numauto;
CREATE VIEW tmp_tt_pts_gps_mdb_sdqrfgadzrg_points AS
 SELECT tmp_tt_pts_gps_mdb_sdqrfgadzrg.no,
    tmp_tt_pts_gps_mdb_sdqrfgadzrg.idnt,
    tmp_tt_pts_gps_mdb_sdqrfgadzrg.latitude,
    tmp_tt_pts_gps_mdb_sdqrfgadzrg.longitude,
    tmp_tt_pts_gps_mdb_sdqrfgadzrg.date,
    tmp_tt_pts_gps_mdb_sdqrfgadzrg."time",
    tmp_tt_pts_gps_mdb_sdqrfgadzrg.alt,
    tmp_tt_pts_gps_mdb_sdqrfgadzrg.descriptio,
    tmp_tt_pts_gps_mdb_sdqrfgadzrg.proximity,
    tmp_tt_pts_gps_mdb_sdqrfgadzrg.symbol__,
    tmp_tt_pts_gps_mdb_sdqrfgadzrg.mapinfo_id,
    tmp_tt_pts_gps_mdb_sdqrfgadzrg.lat_dd,
    tmp_tt_pts_gps_mdb_sdqrfgadzrg.lon_dd,
    tmp_tt_pts_gps_mdb_sdqrfgadzrg.numauto,
    public.geomfromewkt((((('SRID=4326; POINT('::text || tmp_tt_pts_gps_mdb_sdqrfgadzrg.lon_dd) || ' '::text) || tmp_tt_pts_gps_mdb_sdqrfgadzrg.lat_dd) || ')'::text)) AS geomfromewkt
   FROM tmp_tt_pts_gps_mdb_sdqrfgadzrg;



--
-- Name: tmp_tt_pts_gps_mdb_vireendb_numauto_seq; Type: SEQUENCE; Schema: tmp_imports; Owner: pierre
--

CREATE SEQUENCE tmp_tt_pts_gps_mdb_vireendb_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tmp_tt_pts_gps_mdb_vireendb_numauto_seq OWNER TO pierre;

--
-- Name: tmp_tt_pts_gps_mdb_vireendb_numauto_seq; Type: SEQUENCE OWNED BY; Schema: tmp_imports; Owner: pierre
--

ALTER SEQUENCE tmp_tt_pts_gps_mdb_vireendb_numauto_seq OWNED BY tmp_tt_pts_gps_mdb_vireendb.numauto;
CREATE VIEW tmp_tt_pts_gps_mdb_vireendb_points AS
 SELECT tmp_tt_pts_gps_mdb_vireendb.no,
    tmp_tt_pts_gps_mdb_vireendb.idnt,
    tmp_tt_pts_gps_mdb_vireendb.lat_ns,
    tmp_tt_pts_gps_mdb_vireendb.latitude,
    tmp_tt_pts_gps_mdb_vireendb.lon_eo,
    tmp_tt_pts_gps_mdb_vireendb.longitude,
    tmp_tt_pts_gps_mdb_vireendb.date,
    tmp_tt_pts_gps_mdb_vireendb."time",
    tmp_tt_pts_gps_mdb_vireendb.alt,
    tmp_tt_pts_gps_mdb_vireendb.descriptio,
    tmp_tt_pts_gps_mdb_vireendb.proximity,
    tmp_tt_pts_gps_mdb_vireendb.symbol__,
    tmp_tt_pts_gps_mdb_vireendb.mapinfo_id,
    tmp_tt_pts_gps_mdb_vireendb.lat_dd,
    tmp_tt_pts_gps_mdb_vireendb.lon_dd,
    tmp_tt_pts_gps_mdb_vireendb.numauto,
    public.geomfromewkt((((('SRID=4326 ;POINT ('::text || tmp_tt_pts_gps_mdb_vireendb.lon_dd) || ' '::text) || tmp_tt_pts_gps_mdb_vireendb.lat_dd) || ')'::text)) AS geomfromewkt
   FROM tmp_tt_pts_gps_mdb_vireendb;



--
-- Name: bound_e_gid_seq; Type: SEQUENCE; Schema: tmp_ntoto; Owner: pierre
--

CREATE SEQUENCE bound_e_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bound_e_gid_seq OWNER TO pierre;

--
-- Name: bound_e_gid_seq; Type: SEQUENCE OWNED BY; Schema: tmp_ntoto; Owner: pierre
--

ALTER SEQUENCE bound_e_gid_seq OWNED BY bound_e.gid;


--
-- Name: brgm_au_gid_seq; Type: SEQUENCE; Schema: tmp_ntoto; Owner: pierre
--

CREATE SEQUENCE brgm_au_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE brgm_au_gid_seq OWNER TO pierre;

--
-- Name: brgm_au_gid_seq; Type: SEQUENCE OWNED BY; Schema: tmp_ntoto; Owner: pierre
--

ALTER SEQUENCE brgm_au_gid_seq OWNED BY brgm_au.gid;

--
-- Name: codes_gid_seq; Type: SEQUENCE; Schema: tmp_ntoto; Owner: pierre
--

CREATE SEQUENCE codes_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE codes_gid_seq OWNER TO pierre;

--
-- Name: codes_gid_seq; Type: SEQUENCE OWNED BY; Schema: tmp_ntoto; Owner: pierre
--

ALTER SEQUENCE codes_gid_seq OWNED BY codes.gid;

--
-- Name: contact_gid_seq; Type: SEQUENCE; Schema: tmp_ntoto; Owner: pierre
--

CREATE SEQUENCE contact_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE contact_gid_seq OWNER TO pierre;

--
-- Name: contact_gid_seq; Type: SEQUENCE OWNED BY; Schema: tmp_ntoto; Owner: pierre
--

ALTER SEQUENCE contact_gid_seq OWNED BY contact.gid;

--
-- Name: density_gid_seq; Type: SEQUENCE; Schema: tmp_ntoto; Owner: pierre
--

CREATE SEQUENCE density_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE density_gid_seq OWNER TO pierre;

--
-- Name: density_gid_seq; Type: SEQUENCE OWNED BY; Schema: tmp_ntoto; Owner: pierre
--

ALTER SEQUENCE density_gid_seq OWNED BY density.gid;

--
-- Name: devia_gid_seq; Type: SEQUENCE; Schema: tmp_ntoto; Owner: pierre
--

CREATE SEQUENCE devia_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE devia_gid_seq OWNER TO pierre;

--
-- Name: devia_gid_seq; Type: SEQUENCE OWNED BY; Schema: tmp_ntoto; Owner: pierre
--

ALTER SEQUENCE devia_gid_seq OWNED BY devia.gid;

--
-- Name: formatio_gid_seq; Type: SEQUENCE; Schema: tmp_ntoto; Owner: pierre
--

CREATE SEQUENCE formatio_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE formatio_gid_seq OWNER TO pierre;

--
-- Name: formatio_gid_seq; Type: SEQUENCE OWNED BY; Schema: tmp_ntoto; Owner: pierre
--

ALTER SEQUENCE formatio_gid_seq OWNED BY formatio.gid;

--
-- Name: geotec_gid_seq; Type: SEQUENCE; Schema: tmp_ntoto; Owner: pierre
--

CREATE SEQUENCE geotec_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE geotec_gid_seq OWNER TO pierre;

--
-- Name: geotec_gid_seq; Type: SEQUENCE OWNED BY; Schema: tmp_ntoto; Owner: pierre
--

ALTER SEQUENCE geotec_gid_seq OWNED BY geotec.gid;


--
-- Name: headers_gid_seq; Type: SEQUENCE; Schema: tmp_ntoto; Owner: pierre
--

CREATE SEQUENCE headers_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE headers_gid_seq OWNER TO pierre;

--
-- Name: headers_gid_seq; Type: SEQUENCE OWNED BY; Schema: tmp_ntoto; Owner: pierre
--

ALTER SEQUENCE headers_gid_seq OWNED BY headers.gid;

--
-- Name: kendril2_gid_seq; Type: SEQUENCE; Schema: tmp_ntoto; Owner: pierre
--

CREATE SEQUENCE kendril2_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE kendril2_gid_seq OWNER TO pierre;

--
-- Name: kendril2_gid_seq; Type: SEQUENCE OWNED BY; Schema: tmp_ntoto; Owner: pierre
--

ALTER SEQUENCE kendril2_gid_seq OWNED BY kendril2.gid;


--
-- Name: lithaufu_gid_seq; Type: SEQUENCE; Schema: tmp_ntoto; Owner: pierre
--

CREATE SEQUENCE lithaufu_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE lithaufu_gid_seq OWNER TO pierre;

--
-- Name: lithaufu_gid_seq; Type: SEQUENCE OWNED BY; Schema: tmp_ntoto; Owner: pierre
--

ALTER SEQUENCE lithaufu_gid_seq OWNED BY lithaufu.gid;


--
-- Name: litho_gid_seq; Type: SEQUENCE; Schema: tmp_ntoto; Owner: pierre
--

CREATE SEQUENCE litho_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE litho_gid_seq OWNER TO pierre;

--
-- Name: litho_gid_seq; Type: SEQUENCE OWNED BY; Schema: tmp_ntoto; Owner: pierre
--

ALTER SEQUENCE litho_gid_seq OWNED BY litho.gid;

--
-- Name: mag_gid_seq; Type: SEQUENCE; Schema: tmp_ntoto; Owner: pierre
--

CREATE SEQUENCE mag_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mag_gid_seq OWNER TO pierre;

--
-- Name: mag_gid_seq; Type: SEQUENCE OWNED BY; Schema: tmp_ntoto; Owner: pierre
--

ALTER SEQUENCE mag_gid_seq OWNED BY mag.gid;


--
-- Name: mask_gid_seq; Type: SEQUENCE; Schema: tmp_ntoto; Owner: pierre
--

CREATE SEQUENCE mask_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mask_gid_seq OWNER TO pierre;

--
-- Name: mask_gid_seq; Type: SEQUENCE OWNED BY; Schema: tmp_ntoto; Owner: pierre
--

ALTER SEQUENCE mask_gid_seq OWNED BY mask.gid;


--
-- Name: mine_gid_seq; Type: SEQUENCE; Schema: tmp_ntoto; Owner: pierre
--

CREATE SEQUENCE mine_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mine_gid_seq OWNER TO pierre;

--
-- Name: mine_gid_seq; Type: SEQUENCE OWNED BY; Schema: tmp_ntoto; Owner: pierre
--

ALTER SEQUENCE mine_gid_seq OWNED BY mine.gid;


--
-- Name: outline_gid_seq; Type: SEQUENCE; Schema: tmp_ntoto; Owner: pierre
--



CREATE SEQUENCE outline_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE outline_gid_seq OWNER TO pierre;

--
-- Name: outline_gid_seq; Type: SEQUENCE OWNED BY; Schema: tmp_ntoto; Owner: pierre
--

ALTER SEQUENCE outline_gid_seq OWNED BY outline.gid;


--
-- Name: quicklog_gid_seq; Type: SEQUENCE; Schema: tmp_ntoto; Owner: pierre
--

CREATE SEQUENCE quicklog_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE quicklog_gid_seq OWNER TO pierre;

--
-- Name: quicklog_gid_seq; Type: SEQUENCE OWNED BY; Schema: tmp_ntoto; Owner: pierre
--

ALTER SEQUENCE quicklog_gid_seq OWNED BY quicklog.gid;

--
-- Name: rank_gid_seq; Type: SEQUENCE; Schema: tmp_ntoto; Owner: pierre
--

CREATE SEQUENCE rank_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE rank_gid_seq OWNER TO pierre;

--
-- Name: rank_gid_seq; Type: SEQUENCE OWNED BY; Schema: tmp_ntoto; Owner: pierre
--

ALTER SEQUENCE rank_gid_seq OWNED BY rank.gid;

--
-- Name: sampling_gid_seq; Type: SEQUENCE; Schema: tmp_ntoto; Owner: pierre
--

CREATE SEQUENCE sampling_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sampling_gid_seq OWNER TO pierre;

--
-- Name: sampling_gid_seq; Type: SEQUENCE OWNED BY; Schema: tmp_ntoto; Owner: pierre
--

ALTER SEQUENCE sampling_gid_seq OWNED BY sampling.gid;


--
-- Name: sgs_au_gid_seq; Type: SEQUENCE; Schema: tmp_ntoto; Owner: pierre
--

CREATE SEQUENCE sgs_au_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sgs_au_gid_seq OWNER TO pierre;

--
-- Name: sgs_au_gid_seq; Type: SEQUENCE OWNED BY; Schema: tmp_ntoto; Owner: pierre
--

ALTER SEQUENCE sgs_au_gid_seq OWNED BY sgs_au.gid;


--
-- Name: sgsrecod_gid_seq; Type: SEQUENCE; Schema: tmp_ntoto; Owner: pierre
--

CREATE SEQUENCE sgsrecod_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sgsrecod_gid_seq OWNER TO pierre;

--
-- Name: sgsrecod_gid_seq; Type: SEQUENCE OWNED BY; Schema: tmp_ntoto; Owner: pierre
--

ALTER SEQUENCE sgsrecod_gid_seq OWNED BY sgsrecod.gid;


--
-- Name: soil_gid_seq; Type: SEQUENCE; Schema: tmp_ntoto; Owner: pierre
--

CREATE SEQUENCE soil_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE soil_gid_seq OWNER TO pierre;

--
-- Name: soil_gid_seq; Type: SEQUENCE OWNED BY; Schema: tmp_ntoto; Owner: pierre
--

ALTER SEQUENCE soil_gid_seq OWNED BY soil.gid;


--
-- Name: statrenc_gid_seq; Type: SEQUENCE; Schema: tmp_ntoto; Owner: pierre
--

CREATE SEQUENCE statrenc_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE statrenc_gid_seq OWNER TO pierre;

--
-- Name: statrenc_gid_seq; Type: SEQUENCE OWNED BY; Schema: tmp_ntoto; Owner: pierre
--

ALTER SEQUENCE statrenc_gid_seq OWNED BY statrenc.gid;


--
-- Name: struc_gid_seq; Type: SEQUENCE; Schema: tmp_ntoto; Owner: pierre
--

CREATE SEQUENCE struc_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE struc_gid_seq OWNER TO pierre;

--
-- Name: struc_gid_seq; Type: SEQUENCE OWNED BY; Schema: tmp_ntoto; Owner: pierre
--

ALTER SEQUENCE struc_gid_seq OWNED BY struc.gid;


--
-- Name: submit_gid_seq; Type: SEQUENCE; Schema: tmp_ntoto; Owner: pierre
--

CREATE SEQUENCE submit_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE submit_gid_seq OWNER TO pierre;

--
-- Name: submit_gid_seq; Type: SEQUENCE OWNED BY; Schema: tmp_ntoto; Owner: pierre
--

ALTER SEQUENCE submit_gid_seq OWNED BY submit.gid;


--
-- Name: thisecti_gid_seq; Type: SEQUENCE; Schema: tmp_ntoto; Owner: pierre
--

CREATE SEQUENCE thisecti_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE thisecti_gid_seq OWNER TO pierre;

--
-- Name: thisecti_gid_seq; Type: SEQUENCE OWNED BY; Schema: tmp_ntoto; Owner: pierre
--

ALTER SEQUENCE thisecti_gid_seq OWNED BY thisecti.gid;


--
-- Name: tr_au_gid_seq; Type: SEQUENCE; Schema: tmp_ntoto; Owner: pierre
--

CREATE SEQUENCE tr_au_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tr_au_gid_seq OWNER TO pierre;

--
-- Name: tr_au_gid_seq; Type: SEQUENCE OWNED BY; Schema: tmp_ntoto; Owner: pierre
--

ALTER SEQUENCE tr_au_gid_seq OWNED BY tr_au.gid;


--
-- Name: tr_litho_gid_seq; Type: SEQUENCE; Schema: tmp_ntoto; Owner: pierre
--

CREATE SEQUENCE tr_litho_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tr_litho_gid_seq OWNER TO pierre;

--
-- Name: tr_litho_gid_seq; Type: SEQUENCE OWNED BY; Schema: tmp_ntoto; Owner: pierre
--

ALTER SEQUENCE tr_litho_gid_seq OWNED BY tr_litho.gid;


--
-- Name: vchannau_gid_seq; Type: SEQUENCE; Schema: tmp_ntoto; Owner: pierre
--

CREATE SEQUENCE vchannau_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE vchannau_gid_seq OWNER TO pierre;

--
-- Name: vchannau_gid_seq; Type: SEQUENCE OWNED BY; Schema: tmp_ntoto; Owner: pierre
--

ALTER SEQUENCE vchannau_gid_seq OWNED BY vchannau.gid;


--
-- Name: vchannel_gid_seq; Type: SEQUENCE; Schema: tmp_ntoto; Owner: pierre
--

CREATE SEQUENCE vchannel_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE vchannel_gid_seq OWNER TO pierre;

--
-- Name: vchannel_gid_seq; Type: SEQUENCE OWNED BY; Schema: tmp_ntoto; Owner: pierre
--

ALTER SEQUENCE vchannel_gid_seq OWNED BY vchannel.gid;




--
-- Name: id; Type: DEFAULT; Schema: pierre; Owner: pierre
--

ALTER TABLE ONLY coords ALTER COLUMN id SET DEFAULT nextval('coords_id_seq'::regclass);
ALTER TABLE ONLY dh_collars_lengths ALTER COLUMN numauto SET DEFAULT nextval('dh_collars_lengths_numauto_seq'::regclass);
ALTER TABLE ONLY grid ALTER COLUMN numauto SET DEFAULT nextval('grid_numauto_seq'::regclass);
ALTER TABLE ONLY layer_styles ALTER COLUMN id SET DEFAULT nextval('layer_styles_id_seq'::regclass);
ALTER TABLE ONLY rock_ana ALTER COLUMN numauto SET DEFAULT nextval('hammer_ana_numauto_seq'::regclass);
ALTER TABLE ONLY sections_array ALTER COLUMN num SET DEFAULT nextval('sections_array_num_seq'::regclass);
ALTER TABLE ONLY sections_definition ALTER COLUMN id SET DEFAULT nextval('sections_definition_id_seq'::regclass);
ALTER TABLE ONLY songs ALTER COLUMN numauto SET DEFAULT nextval('songs_numauto_seq'::regclass);
ALTER TABLE ONLY tmp_xy ALTER COLUMN id SET DEFAULT nextval('tmp_xy_id_seq'::regclass);



--
-- Name: gid; Type: DEFAULT; Schema: public; Owner: data_admin
--

ALTER TABLE ONLY ancient_workings ALTER COLUMN gid SET DEFAULT nextval('ancient_workings_gid_seq'::regclass);
ALTER TABLE ONLY ancient_workings ALTER COLUMN numauto SET DEFAULT nextval('ancient_workings_numauto_seq'::regclass);
ALTER TABLE ONLY baselines ALTER COLUMN numauto SET DEFAULT nextval('baselines_numauto_seq'::regclass);
ALTER TABLE ONLY dh_collars ALTER COLUMN numauto SET DEFAULT nextval('dh_collars_numauto_seq'::regclass);
ALTER TABLE ONLY dh_core_boxes ALTER COLUMN numauto SET DEFAULT nextval('dh_core_boxes_numauto_seq'::regclass);
ALTER TABLE ONLY dh_density ALTER COLUMN numauto SET DEFAULT nextval('dh_density_numauto_seq'::regclass);
ALTER TABLE ONLY dh_devia ALTER COLUMN numauto SET DEFAULT nextval('dh_devia_numauto_seq'::regclass);
ALTER TABLE ONLY dh_followup ALTER COLUMN numauto SET DEFAULT nextval('dh_followup_numauto_seq'::regclass);
ALTER TABLE ONLY dh_litho ALTER COLUMN numauto SET DEFAULT nextval('dh_litho_numauto_seq'::regclass);
ALTER TABLE ONLY dh_mineralised_intervals ALTER COLUMN numauto SET DEFAULT nextval('dh_mine_numauto_seq'::regclass);
ALTER TABLE ONLY dh_quicklog ALTER COLUMN numauto SET DEFAULT nextval('dh_quicklog_numauto_seq'::regclass);
ALTER TABLE ONLY dh_sampling_bottle_roll ALTER COLUMN numauto SET DEFAULT nextval('dh_sampling_bottle_roll_numauto_seq'::regclass);
ALTER TABLE ONLY dh_sampling_grades ALTER COLUMN numauto SET DEFAULT nextval('dh_sampling_grades_numauto_seq'::regclass);
ALTER TABLE ONLY dh_struct_measures ALTER COLUMN numauto SET DEFAULT nextval('dh_struct_measures_numauto_seq'::regclass);
ALTER TABLE ONLY dh_tech ALTER COLUMN numauto SET DEFAULT nextval('dh_tech_numauto_seq'::regclass);
ALTER TABLE ONLY dh_thinsections ALTER COLUMN numauto SET DEFAULT nextval('dh_thinsections_numauto_seq'::regclass);
ALTER TABLE ONLY doc_bdexplo_table_categories ALTER COLUMN numauto SET DEFAULT nextval('doc_bdexplo_table_categories_numauto_seq'::regclass);
ALTER TABLE ONLY doc_bdexplo_tables_descriptions ALTER COLUMN numauto SET DEFAULT nextval('doc_bdexplo_tables_descriptions_numauto_seq'::regclass);
ALTER TABLE ONLY field_observations ALTER COLUMN numauto SET DEFAULT nextval('field_observations_numauto_seq2'::regclass);
ALTER TABLE ONLY field_observations_struct_measures ALTER COLUMN numauto SET DEFAULT nextval('field_observations_struct_measures_numauto_seq'::regclass);
ALTER TABLE ONLY field_photos ALTER COLUMN numauto SET DEFAULT nextval('field_photos_numauto_seq'::regclass);
ALTER TABLE ONLY formations_group_lithos ALTER COLUMN numauto SET DEFAULT nextval('formations_group_lithos_numauto_seq'::regclass);
ALTER TABLE ONLY geoch_ana ALTER COLUMN numauto SET DEFAULT nextval('geoch_ana_numauto_seq'::regclass);
ALTER TABLE ONLY geoch_sampling ALTER COLUMN sampl_index SET DEFAULT nextval('geoch_sampling_sampl_index_seq'::regclass);
ALTER TABLE ONLY geoch_sampling ALTER COLUMN numauto SET DEFAULT nextval('geoch_sampling_numauto_seq'::regclass);
ALTER TABLE ONLY geoch_sampling_grades ALTER COLUMN sampl_index SET DEFAULT nextval('geoch_sampling_sampl_index_seq'::regclass);
ALTER TABLE ONLY geoch_sampling_grades ALTER COLUMN creation_ts SET DEFAULT now();
ALTER TABLE ONLY geoch_sampling_grades ALTER COLUMN username SET DEFAULT "current_user"();
ALTER TABLE ONLY geoch_sampling_grades ALTER COLUMN numauto SET DEFAULT nextval('geoch_sampling_grades_numauto_seq'::regclass);
ALTER TABLE ONLY gpy_mag_ground ALTER COLUMN numauto SET DEFAULT nextval('gpy_mag_ground_numauto_seq'::regclass);
ALTER TABLE ONLY grade_ctrl ALTER COLUMN numauto SET DEFAULT nextval('preex_sampling_numauto_seq'::regclass);
ALTER TABLE ONLY index_geo_documentation ALTER COLUMN id SET DEFAULT nextval('index_geo_documentation_id_seq'::regclass);
ALTER TABLE ONLY index_geo_documentation ALTER COLUMN numauto SET DEFAULT nextval('index_geo_documentation_numauto_seq'::regclass);
ALTER TABLE ONLY lab_ana_batches_expedition ALTER COLUMN numauto SET DEFAULT nextval('lab_ana_batches_expedition_numauto_seq'::regclass);
ALTER TABLE ONLY lab_ana_batches_reception ALTER COLUMN numauto SET DEFAULT nextval('lab_ana_batches_reception_numauto_seq'::regclass);
ALTER TABLE ONLY lab_ana_columns_definition ALTER COLUMN numauto SET DEFAULT nextval('lab_ana_columns_definition_numauto_seq'::regclass);
ALTER TABLE ONLY lab_ana_qaqc_results ALTER COLUMN numauto SET DEFAULT nextval('lab_ana_qaqc_results_numauto_seq'::regclass);
ALTER TABLE ONLY lab_ana_results ALTER COLUMN numauto SET DEFAULT nextval('lab_ana_results_numauto_seq'::regclass);
ALTER TABLE ONLY lex_codes ALTER COLUMN numauto SET DEFAULT nextval('lex_codes_numauto_seq'::regclass);
ALTER TABLE ONLY lex_datasource ALTER COLUMN datasource_id SET DEFAULT nextval('lex_datasource_datasource_id_seq'::regclass);
ALTER TABLE ONLY lex_datasource ALTER COLUMN numauto SET DEFAULT nextval('lex_datasource_numauto_seq'::regclass);
ALTER TABLE ONLY lex_standard ALTER COLUMN numauto SET DEFAULT nextval('lex_standard_numauto_seq'::regclass);
ALTER TABLE ONLY licences ALTER COLUMN numauto SET DEFAULT nextval('licences_numauto_seq'::regclass);
ALTER TABLE ONLY mag_declination ALTER COLUMN numauto SET DEFAULT nextval('mag_declination_numauto_seq'::regclass);
ALTER TABLE ONLY occurrences ALTER COLUMN numauto_auto SET DEFAULT nextval('occurrences_numauto_auto_seq'::regclass);
ALTER TABLE ONLY operation_active ALTER COLUMN numauto SET DEFAULT nextval('operation_active_numauto_seq'::regclass);
ALTER TABLE ONLY operations ALTER COLUMN opid SET DEFAULT nextval('operations_opid_seq'::regclass);
ALTER TABLE ONLY operations ALTER COLUMN numauto SET DEFAULT nextval('operations_numauto_seq'::regclass);
ALTER TABLE ONLY qc_sampling ALTER COLUMN numauto SET DEFAULT nextval('qc_sampling_numauto_seq'::regclass);
ALTER TABLE ONLY qc_standards ALTER COLUMN numauto SET DEFAULT nextval('qc_standards_numauto_seq'::regclass);
ALTER TABLE ONLY shift_reports ALTER COLUMN numauto SET DEFAULT nextval('shift_reports_numauto_seq'::regclass);
ALTER TABLE ONLY surface_samples_grades ALTER COLUMN numauto SET DEFAULT nextval('surface_samples_grades_numauto_seq'::regclass);
ALTER TABLE ONLY survey_lines ALTER COLUMN numauto SET DEFAULT nextval('survey_lines_numauto_seq'::regclass);
ALTER TABLE ONLY topo_points ALTER COLUMN numauto SET DEFAULT nextval('topo_points_numauto_seq'::regclass);


SET search_path = tmp_a_traiter, pg_catalog;

--
-- Name: numauto; Type: DEFAULT; Schema: tmp_a_traiter; Owner: pierre
--

ALTER TABLE ONLY bondoukou_alain_lambert_coor ALTER COLUMN numauto SET DEFAULT nextval('bondoukou_alain_lambert_coor_numauto_seq'::regclass);
ALTER TABLE ONLY bondoukou_alain_lambert_vx_tvx ALTER COLUMN numauto SET DEFAULT nextval('bondoukou_alain_lambert_vx_tvx_numauto_seq'::regclass);
ALTER TABLE ONLY soil_geoch_bondoukou ALTER COLUMN numauto SET DEFAULT nextval('soil_geoch_bondoukou_numauto_seq'::regclass);


SET search_path = tmp_imports, pg_catalog;

--
-- Name: numauto; Type: DEFAULT; Schema: tmp_imports; Owner: pierre
--

ALTER TABLE ONLY tmp_ity_gpspolo_travaux_97et2004 ALTER COLUMN numauto SET DEFAULT nextval('tmp_ity_gpspolo_travaux_97et2004_numauto_seq'::regclass);
ALTER TABLE ONLY tmp_tt_pierre_nettoye_uploader_wpt ALTER COLUMN numauto SET DEFAULT nextval('tmp_tt_pierre_nettoye_uploader_wpt_numauto_seq'::regclass);
ALTER TABLE ONLY tmp_tt_pts_gps_mdb_copie ALTER COLUMN numauto SET DEFAULT nextval('tmp_tt_pts_gps_mdb_copie_numauto_seq'::regclass);
ALTER TABLE ONLY tmp_tt_pts_gps_mdb_points_latlong ALTER COLUMN numauto SET DEFAULT nextval('tmp_tt_pts_gps_mdb_points_latlong_numauto_seq'::regclass);
ALTER TABLE ONLY tmp_tt_pts_gps_mdb_sdqrfgadzrg ALTER COLUMN numauto SET DEFAULT nextval('tmp_tt_pts_gps_mdb_sdqrfgadzrg_numauto_seq'::regclass);
ALTER TABLE ONLY tmp_tt_pts_gps_mdb_vireendb ALTER COLUMN numauto SET DEFAULT nextval('tmp_tt_pts_gps_mdb_vireendb_numauto_seq'::regclass);


SET search_path = tmp_ntoto, pg_catalog;

--
-- Name: gid; Type: DEFAULT; Schema: tmp_ntoto; Owner: pierre
--

ALTER TABLE ONLY bound_e ALTER COLUMN gid SET DEFAULT nextval('bound_e_gid_seq'::regclass);
ALTER TABLE ONLY brgm_au ALTER COLUMN gid SET DEFAULT nextval('brgm_au_gid_seq'::regclass);
ALTER TABLE ONLY codes ALTER COLUMN gid SET DEFAULT nextval('codes_gid_seq'::regclass);
ALTER TABLE ONLY contact ALTER COLUMN gid SET DEFAULT nextval('contact_gid_seq'::regclass);
ALTER TABLE ONLY density ALTER COLUMN gid SET DEFAULT nextval('density_gid_seq'::regclass);
ALTER TABLE ONLY devia ALTER COLUMN gid SET DEFAULT nextval('devia_gid_seq'::regclass);
ALTER TABLE ONLY formatio ALTER COLUMN gid SET DEFAULT nextval('formatio_gid_seq'::regclass);
ALTER TABLE ONLY geotec ALTER COLUMN gid SET DEFAULT nextval('geotec_gid_seq'::regclass);
ALTER TABLE ONLY headers ALTER COLUMN gid SET DEFAULT nextval('headers_gid_seq'::regclass);
ALTER TABLE ONLY kendril2 ALTER COLUMN gid SET DEFAULT nextval('kendril2_gid_seq'::regclass);
ALTER TABLE ONLY lithaufu ALTER COLUMN gid SET DEFAULT nextval('lithaufu_gid_seq'::regclass);
ALTER TABLE ONLY litho ALTER COLUMN gid SET DEFAULT nextval('litho_gid_seq'::regclass);
ALTER TABLE ONLY mag ALTER COLUMN gid SET DEFAULT nextval('mag_gid_seq'::regclass);
ALTER TABLE ONLY mask ALTER COLUMN gid SET DEFAULT nextval('mask_gid_seq'::regclass);
ALTER TABLE ONLY mine ALTER COLUMN gid SET DEFAULT nextval('mine_gid_seq'::regclass);
ALTER TABLE ONLY outline ALTER COLUMN gid SET DEFAULT nextval('outline_gid_seq'::regclass);
ALTER TABLE ONLY quicklog ALTER COLUMN gid SET DEFAULT nextval('quicklog_gid_seq'::regclass);
ALTER TABLE ONLY rank ALTER COLUMN gid SET DEFAULT nextval('rank_gid_seq'::regclass);
ALTER TABLE ONLY sampling ALTER COLUMN gid SET DEFAULT nextval('sampling_gid_seq'::regclass);
ALTER TABLE ONLY sgs_au ALTER COLUMN gid SET DEFAULT nextval('sgs_au_gid_seq'::regclass);
ALTER TABLE ONLY sgsrecod ALTER COLUMN gid SET DEFAULT nextval('sgsrecod_gid_seq'::regclass);
ALTER TABLE ONLY soil ALTER COLUMN gid SET DEFAULT nextval('soil_gid_seq'::regclass);
ALTER TABLE ONLY statrenc ALTER COLUMN gid SET DEFAULT nextval('statrenc_gid_seq'::regclass);
ALTER TABLE ONLY struc ALTER COLUMN gid SET DEFAULT nextval('struc_gid_seq'::regclass);
ALTER TABLE ONLY submit ALTER COLUMN gid SET DEFAULT nextval('submit_gid_seq'::regclass);
ALTER TABLE ONLY thisecti ALTER COLUMN gid SET DEFAULT nextval('thisecti_gid_seq'::regclass);
ALTER TABLE ONLY tr_au ALTER COLUMN gid SET DEFAULT nextval('tr_au_gid_seq'::regclass);
ALTER TABLE ONLY tr_litho ALTER COLUMN gid SET DEFAULT nextval('tr_litho_gid_seq'::regclass);
ALTER TABLE ONLY vchannau ALTER COLUMN gid SET DEFAULT nextval('vchannau_gid_seq'::regclass);
ALTER TABLE ONLY vchannel ALTER COLUMN gid SET DEFAULT nextval('vchannel_gid_seq'::regclass);





REVOKE ALL ON SEQUENCE surface_samples_grades_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE surface_samples_grades_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE surface_samples_grades_numauto_seq TO data_admin;
REVOKE ALL ON SEQUENCE topo_points_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE topo_points_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE topo_points_numauto_seq TO data_admin;
GRANT ALL ON SEQUENCE topo_points_numauto_seq TO postgres;


CREATE SEQUENCE sections_array_num_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;




CREATE SEQUENCE sections_definition_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE doc_bdexplo_table_categories_numauto_seq OWNED BY doc_bdexplo_table_categories.numauto;
ALTER SEQUENCE surface_samples_grades_numauto_seq OWNED BY surface_samples_grades.numauto;


--
-- Name: grid_numauto_seq; Type: SEQUENCE; Schema: pierre; Owner: pierre
--
CREATE SEQUENCE grid_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE grid_numauto_seq OWNER TO pierre;
--
-- Name: grid_numauto_seq; Type: SEQUENCE OWNED BY; Schema: pierre; Owner: pierre
--
ALTER SEQUENCE grid_numauto_seq OWNED BY grid.numauto;



--
-- Name: hammer_ana_numauto_seq; Type: SEQUENCE; Schema: pierre; Owner: pierre
--
CREATE SEQUENCE hammer_ana_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE hammer_ana_numauto_seq OWNER TO pierre;

--
-- Name: hammer_ana_numauto_seq; Type: SEQUENCE OWNED BY; Schema: pierre; Owner: pierre
--
ALTER SEQUENCE hammer_ana_numauto_seq OWNED BY rock_ana.numauto;



--
-- Name: layer_styles_id_seq; Type: SEQUENCE; Schema: pierre; Owner: pierre
--
CREATE SEQUENCE layer_styles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE layer_styles_id_seq OWNER TO pierre;

--
-- Name: layer_styles_id_seq; Type: SEQUENCE OWNED BY; Schema: pierre; Owner: pierre
--
ALTER SEQUENCE layer_styles_id_seq OWNED BY layer_styles.id;



--
-- Name: sections_array_num_seq; Type: SEQUENCE OWNED BY; Schema: pierre; Owner: pierre
--
ALTER SEQUENCE sections_array_num_seq OWNED BY sections_array.num;



ALTER TABLE sections_definition_id_seq OWNER TO pierre;

--
-- Name: sections_definition_id_seq; Type: SEQUENCE OWNED BY; Schema: pierre; Owner: pierre
--
ALTER SEQUENCE sections_definition_id_seq OWNED BY sections_definition.id;


--
-- Name: songs_numauto_seq; Type: SEQUENCE; Schema: pierre; Owner: pierre
--

CREATE SEQUENCE songs_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE songs_numauto_seq OWNER TO pierre;

--
-- Name: songs_numauto_seq; Type: SEQUENCE OWNED BY; Schema: pierre; Owner: pierre
--

ALTER SEQUENCE songs_numauto_seq OWNED BY songs.numauto;



--
-- Name: tmp_xy_id_seq; Type: SEQUENCE; Schema: pierre; Owner: pierre
--

CREATE SEQUENCE tmp_xy_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tmp_xy_id_seq OWNER TO pierre;

--
-- Name: tmp_xy_id_seq; Type: SEQUENCE OWNED BY; Schema: pierre; Owner: pierre
--

ALTER SEQUENCE tmp_xy_id_seq OWNED BY tmp_xy.id;


SET search_path = public, pg_catalog;
--
-- Name: ancient_workings_gid_seq; Type: SEQUENCE; Schema: public; Owner: data_admin
--
CREATE SEQUENCE ancient_workings_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ancient_workings_gid_seq OWNER TO data_admin;

--
-- Name: ancient_workings_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE ancient_workings_gid_seq OWNED BY ancient_workings.gid;
CREATE SEQUENCE ancient_workings_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ancient_workings_numauto_seq OWNER TO data_admin;

--
-- Name: ancient_workings_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE ancient_workings_numauto_seq OWNED BY ancient_workings.numauto;
CREATE SEQUENCE baselines_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE baselines_numauto_seq OWNER TO data_admin;

--
-- Name: baselines_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE baselines_numauto_seq OWNED BY baselines.numauto;




CREATE SEQUENCE dh_collars_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dh_collars_numauto_seq OWNER TO data_admin;

--
-- Name: dh_collars_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE dh_collars_numauto_seq OWNED BY dh_collars.numauto;



--
-- Name: dh_core_boxes_numauto_seq; Type: SEQUENCE; Schema: public; Owner: data_admin
--

CREATE SEQUENCE dh_core_boxes_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dh_core_boxes_numauto_seq OWNER TO data_admin;

--
-- Name: dh_core_boxes_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE dh_core_boxes_numauto_seq OWNED BY dh_core_boxes.numauto;
CREATE SEQUENCE dh_density_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dh_density_numauto_seq OWNER TO data_admin;

--
-- Name: dh_density_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE dh_density_numauto_seq OWNED BY dh_density.numauto;
CREATE SEQUENCE dh_devia_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dh_devia_numauto_seq OWNER TO data_admin;

--
-- Name: dh_devia_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE dh_devia_numauto_seq OWNED BY dh_devia.numauto;
CREATE SEQUENCE dh_followup_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dh_followup_numauto_seq OWNER TO data_admin;

--
-- Name: dh_followup_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE dh_followup_numauto_seq OWNED BY dh_followup.numauto;
CREATE SEQUENCE dh_litho_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dh_litho_numauto_seq OWNER TO data_admin;

--
-- Name: dh_litho_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE dh_litho_numauto_seq OWNED BY dh_litho.numauto;
CREATE SEQUENCE dh_mine_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dh_mine_numauto_seq OWNER TO data_admin;

--
-- Name: dh_mine_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE dh_mine_numauto_seq OWNED BY dh_mineralised_intervals.numauto;
CREATE SEQUENCE dh_quicklog_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dh_quicklog_numauto_seq OWNER TO data_admin;

--
-- Name: dh_quicklog_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE dh_quicklog_numauto_seq OWNED BY dh_quicklog.numauto;
CREATE SEQUENCE dh_sampling_bottle_roll_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dh_sampling_bottle_roll_numauto_seq OWNER TO data_admin;

--
-- Name: dh_sampling_bottle_roll_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE dh_sampling_bottle_roll_numauto_seq OWNED BY dh_sampling_bottle_roll.numauto;
CREATE SEQUENCE dh_sampling_grades_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dh_sampling_grades_numauto_seq OWNER TO data_admin;

--
-- Name: dh_sampling_grades_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE dh_sampling_grades_numauto_seq OWNED BY dh_sampling_grades.numauto;
CREATE SEQUENCE dh_struct_measures_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dh_struct_measures_numauto_seq OWNER TO data_admin;

--
-- Name: dh_struct_measures_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE dh_struct_measures_numauto_seq OWNED BY dh_struct_measures.numauto;
CREATE SEQUENCE dh_tech_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dh_tech_numauto_seq OWNER TO data_admin;

--
-- Name: dh_tech_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE dh_tech_numauto_seq OWNED BY dh_tech.numauto;
CREATE SEQUENCE dh_thinsections_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dh_thinsections_numauto_seq OWNER TO data_admin;

--
-- Name: dh_thinsections_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE dh_thinsections_numauto_seq OWNED BY dh_thinsections.numauto;

--
-- Name: doc_bdexplo_table_categories_numauto_seq; Type: SEQUENCE; Schema: public; Owner: pierre
--

CREATE SEQUENCE doc_bdexplo_table_categories_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE doc_bdexplo_table_categories_numauto_seq OWNER TO pierre;

--
-- Name: doc_bdexplo_table_categories_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pierre
--

--
-- Name: doc_bdexplo_tables_descriptions_numauto_seq; Type: SEQUENCE; Schema: public; Owner: pierre
--

CREATE SEQUENCE doc_bdexplo_tables_descriptions_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE doc_bdexplo_tables_descriptions_numauto_seq OWNER TO pierre;

--
-- Name: doc_bdexplo_tables_descriptions_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pierre
--

ALTER SEQUENCE doc_bdexplo_tables_descriptions_numauto_seq OWNED BY doc_bdexplo_tables_descriptions.numauto;
CREATE SEQUENCE field_observations_numauto_seq2
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE field_observations_numauto_seq2 OWNER TO data_admin;

--
-- Name: field_observations_numauto_seq2; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE field_observations_numauto_seq2 OWNED BY field_observations.numauto;



--
-- Name: field_observations_struct_measures_numauto_seq; Type: SEQUENCE; Schema: public; Owner: data_admin
--

CREATE SEQUENCE field_observations_struct_measures_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE field_observations_struct_measures_numauto_seq OWNER TO data_admin;

--
-- Name: field_observations_struct_measures_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE field_observations_struct_measures_numauto_seq OWNED BY field_observations_struct_measures.numauto;
CREATE VIEW field_observations_struct_measures_points AS
 SELECT o.geomfromewkt,
    m.opid,
    m.obs_id,
    m.measure_type,
    m.structure_type,
    m.north_ref,
    m.direction,
    m.dip,
    m.dip_quadrant,
    m.pitch,
    m.pitch_quadrant,
    m.movement,
    m.valid,
    m.comments,
    m.numauto,
    m.creation_ts,
    m.username,
    m.datasource,
    m.rotation_matrix,
    m.geolpda_id,
    m.geolpda_poi_id,
    m.sortgroup,
    m.device
   FROM (field_observations_points o
     JOIN field_observations_struct_measures m ON (((o.opid = m.opid) AND ((o.obs_id)::text = (m.obs_id)::text))))
  ORDER BY m.opid, m.obs_id, m.numauto;


ALTER TABLE field_observations_struct_measures_points OWNER TO pierre;

--
-- Name: field_photos_numauto_seq; Type: SEQUENCE; Schema: public; Owner: data_admin
--

CREATE SEQUENCE field_photos_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE field_photos_numauto_seq OWNER TO data_admin;

--
-- Name: field_photos_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE field_photos_numauto_seq OWNED BY field_photos.numauto;
CREATE SEQUENCE formations_group_lithos_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE formations_group_lithos_numauto_seq OWNER TO data_admin;

--
-- Name: formations_group_lithos_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE formations_group_lithos_numauto_seq OWNED BY formations_group_lithos.numauto;
CREATE SEQUENCE geoch_ana_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE geoch_ana_numauto_seq OWNER TO data_admin;

--
-- Name: geoch_ana_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE geoch_ana_numauto_seq OWNED BY geoch_ana.numauto;
CREATE SEQUENCE geoch_sampling_grades_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE geoch_sampling_grades_numauto_seq OWNER TO data_admin;

--
-- Name: geoch_sampling_grades_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE geoch_sampling_grades_numauto_seq OWNED BY geoch_sampling_grades.numauto;
CREATE SEQUENCE geoch_sampling_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE geoch_sampling_numauto_seq OWNER TO data_admin;

--
-- Name: geoch_sampling_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE geoch_sampling_numauto_seq OWNED BY geoch_sampling.numauto;
CREATE SEQUENCE geoch_sampling_sampl_index_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE geoch_sampling_sampl_index_seq OWNER TO data_admin;

--
-- Name: geoch_sampling_sampl_index_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE geoch_sampling_sampl_index_seq OWNED BY geoch_sampling.sampl_index;





--
-- Name: gpy_mag_ground_numauto_seq; Type: SEQUENCE; Schema: public; Owner: data_admin
--

CREATE SEQUENCE gpy_mag_ground_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gpy_mag_ground_numauto_seq OWNER TO data_admin;

--
-- Name: gpy_mag_ground_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE gpy_mag_ground_numauto_seq OWNED BY gpy_mag_ground.numauto;
CREATE SEQUENCE index_geo_documentation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE index_geo_documentation_id_seq OWNER TO data_admin;

--
-- Name: index_geo_documentation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE index_geo_documentation_id_seq OWNED BY index_geo_documentation.id;
CREATE SEQUENCE index_geo_documentation_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE index_geo_documentation_numauto_seq OWNER TO data_admin;

--
-- Name: index_geo_documentation_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE index_geo_documentation_numauto_seq OWNED BY index_geo_documentation.numauto;
CREATE SEQUENCE lab_ana_batches_expedition_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE lab_ana_batches_expedition_numauto_seq OWNER TO data_admin;

--
-- Name: lab_ana_batches_expedition_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE lab_ana_batches_expedition_numauto_seq OWNED BY lab_ana_batches_expedition.numauto;
CREATE SEQUENCE lab_ana_batches_reception_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE lab_ana_batches_reception_numauto_seq OWNER TO data_admin;

--
-- Name: lab_ana_batches_reception_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE lab_ana_batches_reception_numauto_seq OWNED BY lab_ana_batches_reception.numauto;
CREATE SEQUENCE lab_ana_columns_definition_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE lab_ana_columns_definition_numauto_seq OWNER TO data_admin;

--
-- Name: lab_ana_columns_definition_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE lab_ana_columns_definition_numauto_seq OWNED BY lab_ana_columns_definition.numauto;
CREATE SEQUENCE lab_ana_qaqc_results_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE lab_ana_qaqc_results_numauto_seq OWNER TO data_admin;

--
-- Name: lab_ana_qaqc_results_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE lab_ana_qaqc_results_numauto_seq OWNED BY lab_ana_qaqc_results.numauto;
CREATE SEQUENCE lab_ana_results_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE lab_ana_results_numauto_seq OWNER TO data_admin;

--
-- Name: lab_ana_results_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE lab_ana_results_numauto_seq OWNED BY lab_ana_results.numauto;
CREATE SEQUENCE lex_codes_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE lex_codes_numauto_seq OWNER TO data_admin;

--
-- Name: lex_codes_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE lex_codes_numauto_seq OWNED BY lex_codes.numauto;
CREATE SEQUENCE lex_datasource_datasource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE lex_datasource_datasource_id_seq OWNER TO data_admin;

--
-- Name: lex_datasource_datasource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE lex_datasource_datasource_id_seq OWNED BY lex_datasource.datasource_id;
CREATE SEQUENCE lex_datasource_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE lex_datasource_numauto_seq OWNER TO data_admin;

--
-- Name: lex_datasource_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE lex_datasource_numauto_seq OWNED BY lex_datasource.numauto;
CREATE SEQUENCE lex_standard_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE lex_standard_numauto_seq OWNER TO data_admin;

--
-- Name: lex_standard_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE lex_standard_numauto_seq OWNED BY lex_standard.numauto;
CREATE SEQUENCE licences_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE licences_numauto_seq OWNER TO data_admin;

--
-- Name: licences_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE licences_numauto_seq OWNED BY licences.numauto;




--
-- Name: mag_declination_numauto_seq; Type: SEQUENCE; Schema: public; Owner: data_admin
--

CREATE SEQUENCE mag_declination_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mag_declination_numauto_seq OWNER TO data_admin;

--
-- Name: mag_declination_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE mag_declination_numauto_seq OWNED BY mag_declination.numauto;
CREATE SEQUENCE occurrences_numauto_auto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE occurrences_numauto_auto_seq OWNER TO data_admin;

--
-- Name: occurrences_numauto_auto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE occurrences_numauto_auto_seq OWNED BY occurrences.numauto_auto;


SET default_with_oids = false;


CREATE SEQUENCE operation_active_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE operation_active_numauto_seq OWNER TO data_admin;

--
-- Name: operation_active_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE operation_active_numauto_seq OWNED BY operation_active.numauto;
CREATE SEQUENCE operations_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE operations_numauto_seq OWNER TO data_admin;

--
-- Name: operations_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE operations_numauto_seq OWNED BY operations.numauto;
CREATE SEQUENCE operations_opid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE operations_opid_seq OWNER TO data_admin;

--
-- Name: operations_opid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE operations_opid_seq OWNED BY operations.opid;
CREATE SEQUENCE preex_sampling_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE preex_sampling_numauto_seq OWNER TO data_admin;

--
-- Name: preex_sampling_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE preex_sampling_numauto_seq OWNED BY grade_ctrl.numauto;
CREATE SEQUENCE qc_sampling_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE qc_sampling_numauto_seq OWNER TO data_admin;

--
-- Name: qc_sampling_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE qc_sampling_numauto_seq OWNED BY qc_sampling.numauto;
CREATE SEQUENCE qc_standards_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE qc_standards_numauto_seq OWNER TO data_admin;

--
-- Name: qc_standards_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE qc_standards_numauto_seq OWNED BY qc_standards.numauto;
CREATE SEQUENCE shift_reports_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE shift_reports_numauto_seq OWNER TO data_admin;

--
-- Name: shift_reports_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE shift_reports_numauto_seq OWNED BY shift_reports.numauto;

--
-- Name: surface_samples_grades_numauto_seq; Type: SEQUENCE; Schema: public; Owner: data_admin
--

CREATE SEQUENCE surface_samples_grades_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE surface_samples_grades_numauto_seq OWNER TO data_admin;

--
-- Name: surface_samples_grades_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--


CREATE SEQUENCE survey_lines_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE survey_lines_numauto_seq OWNER TO pierre;

--
-- Name: survey_lines_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pierre
--

ALTER SEQUENCE survey_lines_numauto_seq OWNED BY survey_lines.numauto;


--
-- Name: topo_points_numauto_seq; Type: SEQUENCE; Schema: public; Owner: data_admin
--

CREATE SEQUENCE topo_points_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE topo_points_numauto_seq OWNER TO data_admin;

--
-- Name: topo_points_numauto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: data_admin
--

ALTER SEQUENCE topo_points_numauto_seq OWNED BY topo_points.numauto;




SET search_path = stats_reports, pg_catalog;

--
-- Name: avancements_sondages_stats_annuelles; Type: VIEW; Schema: stats_reports; Owner: pierre
--


--
-- Name: bondoukou_alain_lambert_coor_numauto_seq; Type: SEQUENCE; Schema: tmp_a_traiter; Owner: pierre
--

CREATE SEQUENCE bondoukou_alain_lambert_coor_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bondoukou_alain_lambert_coor_numauto_seq OWNER TO pierre;

--
-- Name: bondoukou_alain_lambert_coor_numauto_seq; Type: SEQUENCE OWNED BY; Schema: tmp_a_traiter; Owner: pierre
--

ALTER SEQUENCE bondoukou_alain_lambert_coor_numauto_seq OWNED BY bondoukou_alain_lambert_coor.numauto;





--
-- Name: bondoukou_alain_lambert_vx_tvx_numauto_seq; Type: SEQUENCE; Schema: tmp_a_traiter; Owner: pierre
--

CREATE SEQUENCE bondoukou_alain_lambert_vx_tvx_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bondoukou_alain_lambert_vx_tvx_numauto_seq OWNER TO pierre;

--
-- Name: bondoukou_alain_lambert_vx_tvx_numauto_seq; Type: SEQUENCE OWNED BY; Schema: tmp_a_traiter; Owner: pierre
--

ALTER SEQUENCE bondoukou_alain_lambert_vx_tvx_numauto_seq OWNED BY bondoukou_alain_lambert_vx_tvx.numauto;


--
-- Name: soil_geoch_bondoukou_numauto_seq; Type: SEQUENCE; Schema: tmp_a_traiter; Owner: pierre
--

CREATE SEQUENCE soil_geoch_bondoukou_numauto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE soil_geoch_bondoukou_numauto_seq OWNER TO pierre;

--
-- Name: soil_geoch_bondoukou_numauto_seq; Type: SEQUENCE OWNED BY; Schema: tmp_a_traiter; Owner: pierre
--

ALTER SEQUENCE soil_geoch_bondoukou_numauto_seq OWNED BY soil_geoch_bondoukou.numauto;


--
-- Name: cme_sampling_grades_last; Type: VIEW; Schema: tmp_imports; Owner: pierre
--


REVOKE ALL ON SEQUENCE hammer_ana_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE hammer_ana_numauto_seq FROM pierre;
GRANT ALL ON SEQUENCE hammer_ana_numauto_seq TO pierre;
GRANT ALL ON SEQUENCE hammer_ana_numauto_seq TO postgres;

REVOKE ALL ON SEQUENCE ancient_workings_gid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE ancient_workings_gid_seq FROM data_admin;
GRANT ALL ON SEQUENCE ancient_workings_gid_seq TO data_admin;
REVOKE ALL ON SEQUENCE ancient_workings_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE ancient_workings_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE ancient_workings_numauto_seq TO data_admin;
REVOKE ALL ON SEQUENCE baselines_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE baselines_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE baselines_numauto_seq TO data_admin;
REVOKE ALL ON SEQUENCE dh_collars_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE dh_collars_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE dh_collars_numauto_seq TO data_admin;
REVOKE ALL ON SEQUENCE dh_core_boxes_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE dh_core_boxes_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE dh_core_boxes_numauto_seq TO data_admin;
REVOKE ALL ON SEQUENCE dh_density_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE dh_density_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE dh_density_numauto_seq TO data_admin;
REVOKE ALL ON SEQUENCE dh_devia_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE dh_devia_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE dh_devia_numauto_seq TO data_admin;
REVOKE ALL ON SEQUENCE dh_followup_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE dh_followup_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE dh_followup_numauto_seq TO data_admin;
REVOKE ALL ON SEQUENCE dh_litho_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE dh_litho_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE dh_litho_numauto_seq TO data_admin;
REVOKE ALL ON SEQUENCE dh_mine_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE dh_mine_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE dh_mine_numauto_seq TO data_admin;
GRANT ALL ON SEQUENCE dh_mine_numauto_seq TO postgres;
REVOKE ALL ON SEQUENCE dh_quicklog_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE dh_quicklog_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE dh_quicklog_numauto_seq TO data_admin;
REVOKE ALL ON SEQUENCE dh_sampling_bottle_roll_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE dh_sampling_bottle_roll_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE dh_sampling_bottle_roll_numauto_seq TO data_admin;
REVOKE ALL ON SEQUENCE dh_sampling_grades_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE dh_sampling_grades_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE dh_sampling_grades_numauto_seq TO data_admin;
REVOKE ALL ON SEQUENCE dh_struct_measures_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE dh_struct_measures_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE dh_struct_measures_numauto_seq TO data_admin;
REVOKE ALL ON SEQUENCE dh_tech_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE dh_tech_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE dh_tech_numauto_seq TO data_admin;
GRANT ALL ON SEQUENCE dh_tech_numauto_seq TO postgres;
REVOKE ALL ON SEQUENCE dh_thinsections_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE dh_thinsections_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE dh_thinsections_numauto_seq TO data_admin;
REVOKE ALL ON SEQUENCE field_observations_numauto_seq2 FROM PUBLIC;
REVOKE ALL ON SEQUENCE field_observations_numauto_seq2 FROM data_admin;
GRANT ALL ON SEQUENCE field_observations_numauto_seq2 TO data_admin;
REVOKE ALL ON SEQUENCE field_observations_struct_measures_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE field_observations_struct_measures_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE field_observations_struct_measures_numauto_seq TO data_admin;
REVOKE ALL ON SEQUENCE field_photos_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE field_photos_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE field_photos_numauto_seq TO data_admin;
REVOKE ALL ON SEQUENCE formations_group_lithos_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE formations_group_lithos_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE formations_group_lithos_numauto_seq TO data_admin;
REVOKE ALL ON SEQUENCE geoch_ana_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE geoch_ana_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE geoch_ana_numauto_seq TO data_admin;
GRANT ALL ON SEQUENCE geoch_ana_numauto_seq TO postgres;
REVOKE ALL ON SEQUENCE geoch_sampling_grades_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE geoch_sampling_grades_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE geoch_sampling_grades_numauto_seq TO data_admin;
REVOKE ALL ON SEQUENCE geoch_sampling_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE geoch_sampling_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE geoch_sampling_numauto_seq TO data_admin;
REVOKE ALL ON SEQUENCE geoch_sampling_sampl_index_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE geoch_sampling_sampl_index_seq FROM data_admin;
GRANT ALL ON SEQUENCE geoch_sampling_sampl_index_seq TO data_admin;
GRANT ALL ON SEQUENCE geoch_sampling_sampl_index_seq TO postgres;


REVOKE ALL ON SEQUENCE gpy_mag_ground_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE gpy_mag_ground_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE gpy_mag_ground_numauto_seq TO data_admin;
REVOKE ALL ON SEQUENCE index_geo_documentation_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE index_geo_documentation_id_seq FROM data_admin;
GRANT ALL ON SEQUENCE index_geo_documentation_id_seq TO data_admin;
REVOKE ALL ON SEQUENCE index_geo_documentation_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE index_geo_documentation_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE index_geo_documentation_numauto_seq TO data_admin;
REVOKE ALL ON SEQUENCE lab_ana_batches_expedition_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE lab_ana_batches_expedition_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE lab_ana_batches_expedition_numauto_seq TO data_admin;
REVOKE ALL ON SEQUENCE lab_ana_batches_reception_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE lab_ana_batches_reception_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE lab_ana_batches_reception_numauto_seq TO data_admin;
REVOKE ALL ON SEQUENCE lab_ana_columns_definition_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE lab_ana_columns_definition_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE lab_ana_columns_definition_numauto_seq TO data_admin;
REVOKE ALL ON SEQUENCE lab_ana_qaqc_results_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE lab_ana_qaqc_results_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE lab_ana_qaqc_results_numauto_seq TO data_admin;
REVOKE ALL ON SEQUENCE lab_ana_results_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE lab_ana_results_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE lab_ana_results_numauto_seq TO data_admin;
REVOKE ALL ON SEQUENCE lex_codes_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE lex_codes_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE lex_codes_numauto_seq TO data_admin;
REVOKE ALL ON SEQUENCE lex_datasource_datasource_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE lex_datasource_datasource_id_seq FROM data_admin;
GRANT ALL ON SEQUENCE lex_datasource_datasource_id_seq TO data_admin;
REVOKE ALL ON SEQUENCE lex_datasource_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE lex_datasource_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE lex_datasource_numauto_seq TO data_admin;
REVOKE ALL ON SEQUENCE lex_standard_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE lex_standard_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE lex_standard_numauto_seq TO data_admin;
REVOKE ALL ON SEQUENCE licences_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE licences_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE licences_numauto_seq TO data_admin;
REVOKE ALL ON SEQUENCE mag_declination_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE mag_declination_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE mag_declination_numauto_seq TO data_admin;

REVOKE ALL ON SEQUENCE operation_active_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE operation_active_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE operation_active_numauto_seq TO data_admin;
REVOKE ALL ON SEQUENCE operations_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE operations_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE operations_numauto_seq TO data_admin;
REVOKE ALL ON SEQUENCE operations_opid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE operations_opid_seq FROM data_admin;
GRANT ALL ON SEQUENCE operations_opid_seq TO data_admin;
REVOKE ALL ON SEQUENCE preex_sampling_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE preex_sampling_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE preex_sampling_numauto_seq TO data_admin;
GRANT ALL ON SEQUENCE preex_sampling_numauto_seq TO postgres;
REVOKE ALL ON SEQUENCE qc_sampling_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE qc_sampling_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE qc_sampling_numauto_seq TO data_admin;
REVOKE ALL ON SEQUENCE qc_standards_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE qc_standards_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE qc_standards_numauto_seq TO data_admin;
REVOKE ALL ON SEQUENCE shift_reports_numauto_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE shift_reports_numauto_seq FROM data_admin;
GRANT ALL ON SEQUENCE shift_reports_numauto_seq TO data_admin;
















}}}*/

NB!!!
Avant d'importer les données de bdexplo dans la structure de postgeol recréée:
:%s/creation_ts *timestamp without time zone DEFAULT now()/creation_ts    timestamp with time zone DEFAULT now() NOT NULL,/gc

