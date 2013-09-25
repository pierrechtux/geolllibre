--[ ;{{{ } } }
--	Title:   "Structure of bdexplo database: postgresql database for exploration data"
--	Author:  "Pierre Chevalier"
--	License: {
--		This file is part of GeolLLibre software suite: FLOSS dedicated to Earth Sciences.
--		###########################################################################
--		##          ____  ___/_ ____  __   __   __   _()____   ____  _____       ##
--		##         / ___\/ ___// _  |/ /  / /  / /  /  _/ _ \ / __ \/ ___/       ##
--		##        / /___/ /_  / / | / /  / /  / /   / // /_/_/ /_/ / /_          ##
--		##       / /_/ / /___|  \/ / /__/ /__/ /___/ // /_/ / _, _/ /___         ##
--		##       \____/_____/ \___/_____/___/_____/__/_____/_/ |_/_____/         ##
--		##                                                                       ##
--		###########################################################################
--		  Copyright (C) 2013 Pierre Chevalier <pierrechevaliergeol@free.fr>
--		 
--		    GeolLLibre is free software: you can redistribute it and/or modify
--		    it under the terms of the GNU General Public License as published by
--		    the Free Software Foundation, either version 3 of the License, or
--		    (at your option) any later version.
--		
--		    This program is distributed in the hope that it will be useful,
--		    but WITHOUT ANY WARRANTY; without even the implied warranty of
--		    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--		    GNU General Public License for more details.
--		
--		    You should have received a copy of the GNU General Public License
--		    along with this program.  If not, see <http://www.gnu.org/licenses/>
--		    or write to the Free Software Foundation, Inc., 51 Franklin Street, 
--		    Fifth Floor, Boston, MA 02110-1301, USA.
--		    See LICENSE file.
--		}
--] ;}}}

--echo "CREATE DATABASE bdexplo WITH TEMPLATE=template_postgis ENCODING='UTF8'OWNER=pierre;" | psql

--fonctions: {{{
DROP FUNCTION string_to_int(text);
CREATE OR REPLACE FUNCTION string_to_int(t text) RETURNS bigint AS
$$
/*
Fournit un entier à partir d'une chaîne; intérêt pour éviter d'avoir des champs serial, pour les tables à carter avec postgis.
*/
DECLARE
 int_out bigint = 0;
 ch char(1);
 tt text;
 ttt text = '';
 i integer = 0;
BEGIN
 WHILE i<length(t) LOOP
  ch:=substring(t from i+1 for 1);
  tt:=ascii(ch)::text;
  ttt:=ttt || tt;
  i:=i+1;
 END LOOP;
 int_out:=ttt::bigint;
 return int_out;
END;
$$
LANGUAGE 'plpgsql' VOLATILE RETURNS NULL ON NULL INPUT SECURITY INVOKER;
--}}}

--table operations {{{
--master table, to be queried all the time, especially for confidentiality purposes.
DROP TABLE operations CASCADE;
CREATE TABLE operations (
    opid serial NOT NULL,
    operation character varying(4),
    full_name character varying(50),
    operator character varying(50),
    year integer,
    confidentiality boolean DEFAULT TRUE,
    lat_min numeric(10,5) NOT NULL,
    lon_min numeric(10,5) NOT NULL,
    lat_max numeric(10,5),
    lon_max numeric(10,5),
    comments character varying(500),
    CONSTRAINT opid PRIMARY KEY (opid)
);
COMMENT ON TABLE operations IS 'Operations, projects, operator or client name';
COMMENT ON COLUMN operations.opid IS             'Operation identifier, automatic sequence';
COMMENT ON COLUMN operations.operation IS        'Operation code';
COMMENT ON COLUMN operations.full_name IS        'Complete operation name';
COMMENT ON COLUMN operations.operator IS         'Operator: mining operator, exploration company, client name';
COMMENT ON COLUMN operations.year IS             'Year of operation activity';
COMMENT ON COLUMN operations.confidentiality IS  'Confidentiality flag, true or false; default is true';
COMMENT ON COLUMN operations.lat_min IS          'South latitude, decimal degrees, WGS84';
COMMENT ON COLUMN operations.lon_min IS          'West longitude, decimal degrees, WGS84';
COMMENT ON COLUMN operations.lat_max IS          'North latitude, decimal degrees, WGS84';
COMMENT ON COLUMN operations.lon_max IS          'East latitude, decimal degrees, WGS84';

DROP VIEW operations_quadrangles;
CREATE VIEW operations_quadrangles AS 
SELECT *, GeomFromewkt('SRID=4326;POLYGON(('||lon_min||' '||lat_max||','||lon_max||' '||lat_max||','||lon_max||' '||lat_min||','||lon_min||' '||lat_min||','||lon_min||' '||lat_max||'))')
FROM operations ORDER BY operation;
--}}}

--licences, tenements {{{
--@#refaire avec des polygônes au lieu des quadrangles; faire un champ avec du EWKT dedans
DROP TABLE licences CASCADE;
CREATE TABLE licences (
    opid integer,
    id serial NOT NULL,
    licence_name character varying(50),
    operator character varying(20),
    year integer,
    lat_min numeric(10,5) NOT NULL,
    lon_min numeric(10,5) NOT NULL,
    lat_max numeric(10,5) NOT NULL,
    lon_max numeric(10,5) NOT NULL,
    comments character varying(500),
    CONSTRAINT licence_id PRIMARY KEY (id)
);
COMMENT ON TABLE licences IS 'Licences, tenements';
COMMENT ON COLUMN opid IS                        'Operation identifier, see table operations';
COMMENT ON COLUMN operations.id IS               'Licence identifier, automatic sequence';
COMMENT ON COLUMN licence_name IS                'Name of licence';
COMMENT ON COLUMN operator IS                    'Owner of licence';
COMMENT ON COLUMN year IS                        'Year when licence was valid';
COMMENT ON COLUMN operations.lat_min IS          'South latitude, decimal degrees, WGS84';
COMMENT ON COLUMN operations.lon_min IS          'West longitude, decimal degrees, WGS84';
COMMENT ON COLUMN operations.lat_max IS          'North latitude, decimal degrees, WGS84';
COMMENT ON COLUMN operations.lon_max IS          'East latitude, decimal degrees, WGS84';

DROP VIEW licences_quadrangles;
CREATE VIEW licences_quadrangles AS 
SELECT *, GeomFromewkt('SRID=4326;POLYGON(('||lon_min||' '||lat_max||','||lon_max||' '||lat_max||','||lon_max||' '||lat_min||','||lon_min||' '||lat_min||','||lon_min||' '||lat_max||'))')
FROM licences ORDER BY licence_name;
--}}}

--quick plot of xy {{{
DROP TABLE tmp_xy CASCADE;
CREATE TABLE tmp_xy (
    shid character varying(10) NOT NULL,
    id serial NOT NULL,
    srid integer,
    x numeric(10,2),
    y numeric(10,2),
    z numeric(10,2),
    val numeric(10,2),
    comment character varying(254),
    CONSTRAINT tmp_xy_id PRIMARY KEY (id)
    );

DROP VIEW tmp_xy_points;
CREATE VIEW tmp_xy_points AS
SELECT *, GeomFromewkt('SRID='|| srid ||';POINT(' || x || ' ' || y || ' ' || z || ')')
FROM tmp_xy;
--}}}

--field observations

--locations {{{
CREATE TABLE locations (
    operation character varying(4) NOT NULL,
    location character varying(20) NOT NULL,
    full_name character varying(100),
    lat_min numeric(10,5) NOT NULL,
    lon_min numeric(10,5) NOT NULL,
    lat_max numeric(10,5),
    lon_max numeric(10,5)
);
COMMENT ON TABLE locations IS 'Zones, prospects code, rectangle';
COMMENT ON COLUMN locations.operation IS 'Operation id';
COMMENT ON COLUMN locations.location IS 'Location code name, see collars.location';
COMMENT ON COLUMN locations.full_name IS 'Location full name';
COMMENT ON COLUMN locations.lat_min IS 'South latitude, decimal degrees, WGS84';
COMMENT ON COLUMN locations.lon_min IS 'West longitude, decimal degrees, WGS84';
COMMENT ON COLUMN locations.lat_max IS 'North latitude, decimal degrees, WGS84';
COMMENT ON COLUMN locations.lon_max IS 'East latitude, decimal degrees, WGS84';

--CREATE VIEW locations_rectangles AS SELECT *, GeomFromewkt('SRID=@#latlonwgs84;LINESTRING @#ou_plutôt_rectangle (' 
--|| lon_min || ' ' || lat_max || ', ' 
--|| lon_max || ' ' || lat_max || ', '
--|| lon_max || ' ' || lat_min || ', '
--|| lon_min || ' ' || lat_min || ', '
--|| lon_min || ' ' || lat_max || )) 
--FROM locations ORDER BY location;
-}}}

--drill holes: dh {{{
--collars
DROP TABLE dh_collars CASCADE;
CREATE TABLE dh_collars (
    operation character varying(4),
    id character varying(20) UNIQUE NOT NULL,
    shid character varying(10),
    location character varying(20),
    profile character varying(10),
    srid integer,
    x numeric(10,2),
    y numeric(10,2),
    z numeric(10,2),
    azim_ng numeric(10,2),
    azim_nm numeric(10,2),
    dip_hz numeric(10,2),
    dh_type character varying(10),
    start_date date,
    driller character varying(20),
    geologist character varying(50),
    length numeric(10,2),
    len_destr numeric(10,2),
    len_pq numeric(10,2),
    len_hq numeric(10,2),
    len_nq numeric(10,2),
    len_bq numeric(10,2),
    nb_samples numeric(10,2),
    accusum numeric(10,2),
    comments character varying(500),
    completed boolean,
    data_source integer,
--    numauto serial UNIQUE NOT NULL,
    CONSTRAINT id PRIMARY KEY (id)
);
COMMENT ON TABLE dh_collars              IS 'Drill holes collars or trenches starting points';
COMMENT ON COLUMN dh_collars.id          IS 'Full identifier for borehole or trench, including zone code, type and sequential number';
COMMENT ON COLUMN numauto                IS 'Auto incremental integer used for the base administration';
COMMENT ON COLUMN dh_collars.shid        IS 'Short identifier: type _ sequential number';
COMMENT ON COLUMN dh_collars.location    IS 'Investigated area code, see lex_location look-up table';
COMMENT ON COLUMN dh_collars.profile     IS 'Profile number';
--COMMENT ON COLUMN dh_collars.utm_zone  IS 'UTM zone';
COMMENT ON COLUMN dh_collars.srid        IS 'Spatial Reference Identifier, or coordinate reference system: see spatial_ref_sys from postgis extension';
COMMENT ON COLUMN dh_collars.x           IS 'X coordinate (Easting), in coordinate system srid';
COMMENT ON COLUMN dh_collars.y           IS 'Y coordinate (Northing), in coordinate system srid';
COMMENT ON COLUMN dh_collars.z           IS 'Z coordinate';
COMMENT ON COLUMN dh_collars.azim_ng     IS 'Hole or trench azimuth (°) relative to geographic North';
COMMENT ON COLUMN dh_collars.azim_nm     IS 'Hole or trench azimuth (°) relative to Magnetic North';
COMMENT ON COLUMN dh_collars.dip_hz      IS 'Drill hole or trench dip relative to horizontal (°)';
COMMENT ON COLUMN dh_collars.dh_type     IS 'Type: D for Diamond drill hole, R for RC drill hole, T for Trench, A for Auger drill hole';
COMMENT ON COLUMN dh_collars.start_date  IS 'Work start date';
COMMENT ON COLUMN dh_collars.driller     IS 'Drilling contractor';
COMMENT ON COLUMN dh_collars.geologist   IS 'Geologist name';
COMMENT ON COLUMN dh_collars.completed   IS 'True: completed; false: planned';
COMMENT ON COLUMN dh_collars.length      IS 'Total length (m)';
COMMENT ON COLUMN dh_collars.len_destr   IS 'Destructive (percussion or rotary drilling) length (m)';
COMMENT ON COLUMN dh_collars.len_pq      IS 'Core PQ length (m)';
COMMENT ON COLUMN dh_collars.len_hq      IS 'Core HQ length (m)';
COMMENT ON COLUMN dh_collars.len_nq      IS 'Core NQ length (m)';
COMMENT ON COLUMN dh_collars.len_bq      IS 'Core BQ length (m)';
COMMENT ON COLUMN dh_collars.nb_samples  IS 'Number of samples';
COMMENT ON COLUMN dh_collars.accusum     IS 'Accumulation sum over various mineralised intervals intersected by drill hole or trench';
COMMENT ON COLUMN dh_collars.comments    IS 'Comments';
COMMENT ON COLUMN dh_collars.data_source IS 'Data source: filename, sakanap, etc.';
--COMMENT ON COLUMN dh_collars.old_flid IS 'Old identifier, as in original data files';
--COMMENT ON COLUMN collars.problems IS 'If there is a problem or not, in terms of data integrity/consistency';
--COMMENT ON COLUMN dh_collars.export IS 'Data to be exported or not';
--COMMENT ON COLUMN dh_collars.numauto IS 'Auto incremental integer used for the base administration';


--les vues avec les points cartographiable; une par srid, hélas; faudra voir à faire une conversion vers un srid/*{{{*/
DROP VIEW dh_collars_points_20136;
CREATE OR REPLACE VIEW dh_collars_points_20136 AS SELECT *, GeomFromewkt('SRID='|| srid || ';POINT('|| x || ' ' || y || ' ' || z || ')') FROM dh_collars WHERE srid = 20136;
DROP VIEW dh_collars_points_20137;
CREATE OR REPLACE VIEW dh_collars_points_20137 AS SELECT *, GeomFromewkt('SRID='|| srid || ';POINT('|| x || ' ' || y || ' ' || z || ')') FROM dh_collars WHERE srid = 20137;

--les traces des sondages, pareil, pour un srid
CREATE OR REPLACE VIEW dh_traces_3d_20136 AS 
SELECT *, GeomFromEWKT('SRID=' || srid || ';LINESTRING (' || x || ' ' || y || ' ' || z || ', ' || x1 || ' ' || y1 || ' ' || z1 || ')') FROM (SELECT *, x + length * cos((dip_hz / 180) * pi()) * sin((azim_ng / 180) * pi()) AS x1, y + length * cos((dip_hz / 180) * pi()) * cos((azim_ng / 180) * pi()) AS y1, z - length * sin((dip_hz / 180) * pi()) AS z1
FROM dh_collars
WHERE srid = 20136) tmp
ORDER BY tmp.id;
CREATE OR REPLACE VIEW dh_traces_3d_20137 AS 
SELECT *, GeomFromEWKT('SRID=' || srid || ';LINESTRING (' || x || ' ' || y || ' ' || z || ', ' || x1 || ' ' || y1 || ' ' || z1 || ')') FROM (SELECT *, x + length * cos((dip_hz / 180) * pi()) * sin((azim_ng / 180) * pi()) AS x1, y + length * cos((dip_hz / 180) * pi()) * cos((azim_ng / 180) * pi()) AS y1, z - length * sin((dip_hz / 180) * pi()) AS z1
FROM dh_collars
WHERE srid = 20137) tmp
ORDER BY tmp.id;





--les vues refaisant comme les tables séparées pour trous futurs et prévus:
CREATE VIEW collars AS SELECT * FROM dh_collars WHERE completed;
CREATE VIEW collars_program AS SELECT * FROM dh_collars WHERE NOT(completed);



--sampling data
CREATE TABLE dh_sampling (
    id character varying(20),
    depfrom numeric(10,2),
    depto numeric(10,2),
    sampl_nb character varying(50),
    directory_index integer,
    comments character varying(250),
);




--résultats analytiques
--analytical data
	--Apres avoir tourney et retourne le probleme: - LD
	--Et pour les codes du labo:
	--IS: Insufficient sample  -999
	--LNR: Listed but Not Recovered: -9999
	-- > LD: @#ah: à implémenter
	--Par exemple.  Un code numerique qui evite d'obliger de stocker les
	--commentaire tout en preservant l'information, et permettant un filtrage
	--efficace.

--structure de table de résultats analytiques, basé sur discussion 
--avec Andre_Pranata d'Intertek andre.pranata @intertek.com
DROP TABLE lab_ana_results ;
CREATE TABLE lab_ana_results (
 sample_id varchar(20),
 batch_id varchar,
 labname varchar(10),
 lab_pjcsa_pro_job varchar(20),
-- lab_pj_cli_code varchar(40),
 lab_pj_orderno varchar(40),
 lab_pjc_sampleident varchar(40),
 lab_pjcsa_sch_code varchar(20),
 lab_pjcsa_analytecode varchar(20),
 lab_pjcsa_formattedvalue varchar(20),
 --batch_no integer,
 db_update_timestamp timestamp DEFAULT current_timestamp,
 value_num numeric
);
COMMENT ON TABLE lab_ana_results IS                           'Laboratory results table, after laboratory instructions, related to LIMS system';
COMMENT ON COLUMN lab_ana_results.labname IS                  'Analytical laboratory';
COMMENT ON COLUMN lab_ana_results.lab_pjcsa_pro_job IS        'jcsa.pro_job,           --> Intertek JobNo (VarChar(20))';
COMMENT ON COLUMN lab_ana_results.lab_pj_cli_code IS          'pj.cli_code,             --> Client Name (VarChar(40))';
COMMENT ON COLUMN lab_ana_results.lab_pj_orderno IS           'pj.orderno,              --> Client Order No (VarChar(40))';
COMMENT ON COLUMN lab_ana_results.lab_pjc_sampleident IS      'pjc.sampleident,         --> Client SampleID (VarChar(40))';
COMMENT ON COLUMN lab_ana_results.lab_pjcsa_sch_code IS       'pjcsa.sch_code,          --> Scheme Code (Intertek Internal Code - which probably reported to Client as well) (VarChar(20))';
COMMENT ON COLUMN lab_ana_results.lab_pjcsa_analytecode IS    'pjcsa.analytecode,       --> Analyte Code (Intertek Internal Code - which probably reported to Client as well) (VarChar(20))';
COMMENT ON COLUMN lab_ana_results.lab_pjcsa_formattedvalue IS 'pjcsa.formattedvalue     --> Reported Value (VarChar(20))';
COMMENT ON COLUMN lab_ana_results.batch_id IS                  'Batch number';
COMMENT ON COLUMN lab_ana_results.db_update_timestamp IS      'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN lab_ana_results.value_num IS                'Reported value, converted to numeric. IS becomes -999, LNR -9999, < -, > nothing';

CREATE OR REPLACE FUNCTION lab_ana_results_sample_id_default()
 RETURNS trigger AS
$BODY$
BEGIN
UPDATE lab_ana_results SET sample_id = lab_pjc_sampleident;
RETURN NULL;
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE
;

CREATE TRIGGER lab_ana_results_insert AFTER INSERT ON lab_ana_results FOR EACH STATEMENT EXECUTE PROCEDURE lab_ana_results_sample_id_default();






--échantillons de contrôle analytique

--densités

--lots analytiques
/*}}}*/

--descriptions lithologiques
DROP TABLE dh_litho;
CREATE TABLE dh_litho (
    id character varying(20),
    depfrom numeric(10,2),
    depto numeric(10,2),
    codelitho varchar(4),
    codestrati varchar(4),
    description varchar(1000),
    oxidation varchar(4),
    deformation integer,
    alteration integer,
    water varchar(4)
);
COMMENT ON TABLE dh_litho                IS 'Drill holes or trenches geological descriptions';
COMMENT ON COLUMN dh_litho.id            IS 'Identifier, refers to dh_collars;'
COMMENT ON COLUMN dh_litho.depfrom       IS 'Interval beginning depth';
COMMENT ON COLUMN dh_litho.depto         IS 'Interval ending depth';
COMMENT ON COLUMN dh_litho.codelitho     IS 'Lithology code, 4 characters, uppercase';
COMMENT ON COLUMN dh_litho.codestrati    IS 'Stratigraphy code, 4 characters, uppercase';
COMMENT ON COLUMN dh_litho.descriptions  IS 'Geological description, naturalist style';
COMMENT ON COLUMN dh_litho.oxidation     IS 'Supergene oxidation';
COMMENT ON COLUMN dh_litho.deformation   IS 'Deformation intensity, semi-quantitative, 0 to 4';
COMMENT ON COLUMN dh_litho.alteration    IS 'Alteration intensity, semi-quantitative, 0 to 4';
COMMENT ON COLUMN dh_litho.water         IS 'Water presence in drill hole';




--}}}

--geochemistry

--anomalies

--targets

--mines
