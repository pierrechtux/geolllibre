--[ ;{{{ } } }
--	Title:   "Structure of postgeol database: postgresql database for geological data"
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

--TODO faire le rôle data_admin
--echo "CREATE DATABASE postgeol WITH TEMPLATE=template_postgis ENCODING='UTF8'OWNER=pierre;" | psql
-- => no, refer to postgeol_database_creation.sh


--IFNDEF $POSTGEOL PAS DÉFINI, ON LE DÉFINIT: @#TODO
POSTGEOL = 'postgeol'
-- _____________JEANSUILA_________________________


CREATE DATABASE $POSTGEOL ENCODING='UTF8';
\c $POSTGEOL
CREATE EXTENSION postgis;
CREATE EXTENSION postgis_topology;

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';
CREATE OR REPLACE PROCEDURAL LANGUAGE plpythonu;
ALTER PROCEDURAL LANGUAGE plpythonu OWNER TO postgres;

-- schemas:{{{
CREATE SCHEMA checks;
COMMENT ON SCHEMA checks IS 'Views selecting unconsistent, incoherent, unprobable data';

CREATE SCHEMA gdm;
COMMENT ON SCHEMA gdm IS 'Views for connection with GDM software through ODBC';

CREATE SCHEMA input;
COMMENT ON SCHEMA input IS 'Tables with same structure as tables in main data schema: for data input before validation and dump into final tables (apparently unused on production site 2013_08_03__11_40_18).';

CREATE SCHEMA stats_reports;
COMMENT ON SCHEMA stats_reports IS 'Views with statistics and reports, for daily/weekly/monthly statistics.';

CREATE SCHEMA tmp_imports;
COMMENT ON SCHEMA tmp_imports IS 'Temporary place from imported files.  Tables imported from .csv files by using the csv2sql utility are going in this schema.';

--}}}

--Tables{{{
--SET SCHEMA_DATA = 'public'; -- for the time being.  Eventually, data tables will be moved into another work schema.
--SET search_path = SCHEMA_DATA, pg_catalog;
--SET search_path = '$user', 'public';
SET search_path = public, pg_catalog;
-- operations: master table, to be queried all the time, especially for confidentiality purposes: {{{
DROP TABLE IF EXISTS operations CASCADE;
CREATE TABLE operations (
    opid            serial NOT NULL,
    operation       varchar,
    full_name       varchar,
    operator        varchar,
    year            integer,
    confidentiality boolean DEFAULT TRUE,
    lat_min         numeric(10,5) NOT NULL,
    lon_min         numeric(10,5) NOT NULL,
    lat_max         numeric(10,5),
    lon_max         numeric(10,5),
    comments        varchar,
    numauto         serial UNIQUE NOT NULL,
    db_update_timestamp timestamp without time zone DEFAULT now(),
    username        varchar DEFAULT "current_user"(),
    CONSTRAINT opid PRIMARY KEY (opid)
);

COMMENT ON TABLE operations                         IS 'Operations, projects, operator or client name';
COMMENT ON COLUMN operations.opid                   IS 'Operation identifier, automatic sequence';
COMMENT ON COLUMN operations.operation              IS 'Operation code';
COMMENT ON COLUMN operations.full_name              IS 'Complete operation name';
COMMENT ON COLUMN operations.operator               IS 'Operator: mining operator, exploration company, client name';
COMMENT ON COLUMN operations.year                   IS 'Year of operation activity';
COMMENT ON COLUMN operations.confidentiality        IS 'Confidentiality flag, true or false; default is true';
COMMENT ON COLUMN operations.lat_min                IS 'South latitude, decimal degrees, WGS84';
COMMENT ON COLUMN operations.lon_min                IS 'West longitude, decimal degrees, WGS84';
COMMENT ON COLUMN operations.lat_max                IS 'North latitude, decimal degrees, WGS84';
COMMENT ON COLUMN operations.lon_max                IS 'East latitude, decimal degrees, WGS84';
COMMENT ON COLUMN operations.db_update_timestamp    IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN operations.username               IS 'User (role) which created data record';
COMMENT ON COLUMN operations.numauto                IS 'Automatic integer';

--}}}
-- operation_active: table containing active opid, in order to separate different operations:{{{

--SET search_path = current_user $USER, pg_catalog; => in fact, this table should rather be in the user's schema => TODO later

CREATE TABLE operation_active (
    opid integer,
    db_update_timestamp timestamp without time zone DEFAULT now(),
    username character varying DEFAULT "current_user"(),
    numauto integer NOT NULL
);

ALTER TABLE operation_active OWNER TO data_admin;
COMMENT ON COLUMN operation_active.opid IS 'Operation identifier';
COMMENT ON COLUMN operation_active.db_update_timestamp IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN operation_active.username IS 'User (role) which created data record';
COMMENT ON COLUMN operation_active.numauto IS 'Automatic integer';
--}}}
-- drill holes: table names prefixed with dh_ {{{
-- VU dh_collars {{{

CREATE TABLE public.dh_collars (
    opid                integer NOT NULL,
    id                  varchar NOT NULL,
    location            varchar,
    campaign            varchar,
    purpose             varchar DEFAULT 'EXPLO'::character varying,
    profile             varchar,
    srid                integer,
    x                   numeric(12,3),
    y                   numeric(12,3),
    z                   numeric(12,3),
    azim_ng             numeric(10,2),
    azim_nm             numeric(10,2),
    dip_hz              numeric(10,2),
    length              numeric(10,2),
    dh_type             varchar,
    date_start          date,
    date_completed      date,
    completed           boolean DEFAULT false,
    contractor          varchar,
    geologist           varchar,
    nb_samples          integer,
    topo_survey_type    varchar,
    comments            varchar,
    x_local             numeric(12,3),
    y_local             numeric(12,3),
    z_local             numeric(12,3),
    accusum             numeric(10,2),
    id_pject            varchar,
    x_pject             numeric(10,3),
    y_pject             numeric(10,3),
    z_pject             numeric(10,3),
    datasource          integer,
    shid                varchar,
    numauto             serial UNIQUE NOT NULL,
    db_update_timestamp timestamp without time zone DEFAULT now(),
    username            varchar DEFAULT "current_user"()
);

-- Fields dropped:
    --len_destr numeric(10,2),
    --len_pq numeric(10,2),
    --len_hq numeric(10,2),
    --len_nq numeric(10,2),
    --len_bq numeric(10,2),

ALTER TABLE dh_collars OWNER TO data_admin;

COMMENT ON TABLE dh_collars                         IS 'Drill holes collars or trenches starting points';
COMMENT ON COLUMN dh_collars.opid                   IS 'Operation identifier, refers to operations table';
COMMENT ON COLUMN dh_collars.id                     IS 'Full identifier for borehole or trench, may include zone code, type and sequential number.  opid and id make the unique key of dh_collars table.';
COMMENT ON COLUMN dh_collars.location               IS 'Investigated area code, refers to occurrences table';
COMMENT ON COLUMN dh_collars.campaign               IS 'Campaign: year, type, etc. i.e. DDH exploration 1967';
COMMENT ON COLUMN dh_collars.purpose                IS 'Purpose of hole: exploration, delineation, estimation, grade control, etc.';
COMMENT ON COLUMN dh_collars.profile                IS 'Profile number';
COMMENT ON COLUMN dh_collars.srid                   IS 'Spatial Reference Identifier, or coordinate reference system: see spatial_ref_sys from postgis extension';
COMMENT ON COLUMN dh_collars.x                      IS 'X coordinate (Easting),  in coordinate system srid';
COMMENT ON COLUMN dh_collars.y                      IS 'Y coordinate (Northing), in coordinate system srid';
COMMENT ON COLUMN dh_collars.z                      IS 'Z coordinate';
COMMENT ON COLUMN dh_collars.azim_ng                IS 'Hole or trench azimuth (°) relative to geographic North';
COMMENT ON COLUMN dh_collars.azim_nm                IS 'Hole or trench azimuth (°) relative to Magnetic North';
COMMENT ON COLUMN dh_collars.dip_hz                 IS 'Drill hole or trench dip relative to horizontal (°)';
COMMENT ON COLUMN dh_collars.length                 IS 'Total length (m)';
COMMENT ON COLUMN dh_collars.dh_type                IS 'Type: D for Diamond drill hole, R for RC drill hole, T for Trench, A for Auger drill hole';
COMMENT ON COLUMN dh_collars.date_start             IS 'Work start date';
COMMENT ON COLUMN dh_collars.date_completed         IS 'Work finish date';
COMMENT ON COLUMN dh_collars.completed              IS 'True: completed; False: planned';
COMMENT ON COLUMN dh_collars.contractor             IS 'Drilling contractor';
COMMENT ON COLUMN dh_collars.geologist              IS 'Geologist name';
COMMENT ON COLUMN dh_collars.nb_samples             IS 'Number of samples';
COMMENT ON COLUMN dh_collars.topo_survey_type       IS 'Topographic collar survey type: GPS, GPSD, geometry, theodolite, relative, computed from local coordinate system, etc.';
COMMENT ON COLUMN dh_collars.comments               IS 'Comments, e.g. quick history of the hole, why it stopped, remarkable facts, etc.';
COMMENT ON COLUMN dh_collars.x_local                IS 'Local x coordinate';
COMMENT ON COLUMN dh_collars.y_local                IS 'Local y coordinate';
COMMENT ON COLUMN dh_collars.z_local                IS 'Local z coordinate';
COMMENT ON COLUMN dh_collars.accusum                IS 'Accumulation sum over various mineralised intervals intersected by drill hole or trench (purpose: quick visualisation on maps (at wide scale ONLY), quick ranking of interesting holes)';
COMMENT ON COLUMN dh_collars.id_pject               IS 'PJ for ProJect identifier: provisional identifier; aka peg number';
COMMENT ON COLUMN dh_collars.x_pject                IS 'Planned x coordinate';
COMMENT ON COLUMN dh_collars.y_pject                IS 'Planned y coordinate';
COMMENT ON COLUMN dh_collars.z_pject                IS 'Planned z coordinate';
COMMENT ON COLUMN dh_collars.datasource             IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN dh_collars.shid                   IS 'Short identifier: e.g. _ sequential number (rarely used)';
COMMENT ON COLUMN dh_collars.numauto                IS 'Automatic integer primary key';
COMMENT ON COLUMN dh_collars.db_update_timestamp    IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_collars.username               IS 'User (role) which created data record';

--COMMENT ON COLUMN dh_collars.old_flid               IS 'Old identifier, as in original data files';              -- field dropped
--COMMENT ON COLUMN collars.problems                  IS 'If there is a problem or not, in terms of data integrity/consistency'; -- field dropped
--COMMENT ON COLUMN dh_collars.export                 IS 'Data to be exported or not';                             -- field dropped
--COMMENT ON COLUMN dh_collars.len_destr              IS 'Destructive (percussion or rotary drilling) length (m)'; -- field dropped
--COMMENT ON COLUMN dh_collars.len_pq                 IS 'Core PQ length (m)';                                     -- field dropped
--COMMENT ON COLUMN dh_collars.len_hq                 IS 'Core HQ length (m)';                                     -- field dropped
--COMMENT ON COLUMN dh_collars.len_nq                 IS 'Core NQ length (m)';                                     -- field drop ped
--COMMENT ON COLUMN dh_collars.len_bq                 IS 'Core BQ length (m)';                                     -- field dropped

--}}}
-- dh_followup {{{
CREATE TABLE dh_followup (
    opid                integer,
    id                  varchar,
    devia               character varying(3),
    quick_log           character varying(3),
    log_tech            character varying(3),
    log_lith            character varying(3),
    sampling            character varying(3),
    results             character varying(3),
    relogging           character varying(3),
    beacon              character varying(3),
    in_gdm              character varying(1),
    numauto             serial UNIQUE NOT NULL,
    db_update_timestamp timestamp without time zone DEFAULT now(),
    username            character varying DEFAULT "current_user"()
);

COMMENT ON TABLE dh_followup                        IS 'Simple table for daily drill holes followup';
COMMENT ON COLUMN dh_followup.opid                  IS 'Operation identifier';
COMMENT ON COLUMN dh_followup.id                    IS 'Identifier, refers to dh_collars';
COMMENT ON COLUMN dh_followup.devia                 IS 'Deviation survey (x: done; xx: done, data entered; xxx: data verified)';
COMMENT ON COLUMN dh_followup.quick_log             IS 'Quick geological log, typically done on hole finish, for an A4 log plot (x: done; xx: done, data entered; xxx: data verified)';
COMMENT ON COLUMN dh_followup.log_tech              IS 'Core fitting, core measurement, meters marking, RQD, fracture counts, etc. (x: done; xx: done, data entered; xxx: data verified)';
COMMENT ON COLUMN dh_followup.log_lith              IS 'Full geological log (x: done; xx: done, data entered; xxx: data verified)';
COMMENT ON COLUMN dh_followup.sampling              IS 'Hole sampling (x: done; xx: done, data entered; xxx: data verified)';
COMMENT ON COLUMN dh_followup.results               IS 'Assay results back from laboratory (x: received; xx: entered; xxx: verified)';
COMMENT ON COLUMN dh_followup.relogging             IS 'Geological log done afterwards on mineralised intervals (x: done; xx: done, data entered; xxx: data verified)';
COMMENT ON COLUMN dh_followup.beacon                IS 'Beacon or any other permanent hole marker on field (PVC pipe, concrete beacon, cement, etc.) (x: done)';
COMMENT ON COLUMN dh_followup.in_gdm                IS 'Data exported to GDM; implicitely: data clean, checked by GDM procedures (x: done)';
COMMENT ON COLUMN dh_followup.db_update_timestamp   IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_followup.username              IS 'User (role) which created data record';
COMMENT ON COLUMN dh_followup.numauto               IS 'Automatic integer primary key';

--}}}
-- dh_devia {{{
CREATE TABLE dh_devia (
    id                  character varying(20),
    depto               numeric(10,2),
    azim_nm             numeric(10,2),
    dip_hz              numeric(10,2),
    temperature         numeric(10,2),
    magnetic            numeric(10,2),
    date                date,
    roll                numeric(10,2),
    "time"              integer,
    comments            character varying,
    opid                integer,
    valid               boolean DEFAULT true,
    azim_ng             numeric(10,2),
    datasource          integer,
    numauto             serial UNIQUE NOT NULL,
    device              character varying,
    db_update_timestamp timestamp without time zone DEFAULT now(),
    username            character varying DEFAULT "current_user"()
);

COMMENT ON TABLE dh_devia                           IS 'Drill holes or trenches deviations measurements';
COMMENT ON COLUMN dh_devia.id                       IS 'Drill hole identification related to the collars table';
COMMENT ON COLUMN dh_devia.depto                    IS 'Depth of deviation measurement';
COMMENT ON COLUMN dh_devia.azim_nm                  IS 'Hole azimuth (°) relative to magnetic North (?)';
COMMENT ON COLUMN dh_devia.dip_hz                   IS 'Drill hole dip relative to horizontal (°), positive down';
COMMENT ON COLUMN dh_devia.temperature              IS 'temperature';
COMMENT ON COLUMN dh_devia.magnetic                 IS 'Magnetic field intensity measurement';
COMMENT ON COLUMN dh_devia.date                     IS 'Date of deviation measurement';
COMMENT ON COLUMN dh_devia.roll                     IS 'Roll angle';
COMMENT ON COLUMN dh_devia."time"                   IS 'Time of deviation measurement';
COMMENT ON COLUMN dh_devia.comments                 IS 'Various comments; concerning measurements done with Reflex Gyro, all parameters are concatened as a json-like structure';
COMMENT ON COLUMN dh_devia.opid                     IS 'Operation identifier';
COMMENT ON COLUMN dh_devia.numauto                  IS 'Automatic integer primary key';
COMMENT ON COLUMN dh_devia.valid                    IS 'True when a deviation measurement is usable; queries should take into account only valid records';
COMMENT ON COLUMN dh_devia.azim_ng                  IS 'Hole azimuth (°) relative to geographic North';
COMMENT ON COLUMN dh_devia.datasource               IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN dh_devia.device                   IS 'Device used for deviation measurement';
COMMENT ON COLUMN dh_devia.db_update_timestamp      IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_devia.username                 IS 'User (role) which created data record';

-- TODO convert the json-like data into a real json field.

--}}}
-- dh_quicklog {{{
CREATE TABLE dh_quicklog (
    opid integer,
    id text,
    depfrom numeric(10,2),
    depto numeric(10,2),
    description character varying,
    oxid character varying(4),
    alt smallint,
    def smallint,
    numauto serial UNIQUE NOT NULL,
    db_update_timestamp timestamp without time zone DEFAULT now(),
    username character varying DEFAULT "current_user"(),
    datasource integer
);

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
COMMENT ON COLUMN dh_quicklog.db_update_timestamp IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_quicklog.username IS 'User (role) which created data record';
COMMENT ON COLUMN dh_quicklog.datasource IS 'Datasource identifier, refers to lex_datasource';

--}}}
-- dh_core_boxes {{{

CREATE TABLE dh_core_boxes (
    id character varying(20),
    depfrom numeric(10,2),
    depto numeric(10,2),
    box_number integer,
    datasource integer,
    opid integer,
    numauto serial UNIQUE NOT NULL,
    db_update_timestamp timestamp without time zone DEFAULT now(),
    username character varying DEFAULT "current_user"()
);

COMMENT ON TABLE dh_core_boxes                      IS 'Core drill holes boxes';
COMMENT ON COLUMN dh_core_boxes.id                  IS 'Identifier, refers to dh_collars';
COMMENT ON COLUMN dh_core_boxes.depfrom             IS 'Core box contents beginning depth';
COMMENT ON COLUMN dh_core_boxes.depto               IS 'Core box contents ending depth';
COMMENT ON COLUMN dh_core_boxes.box_number          IS 'Core box number';
COMMENT ON COLUMN dh_core_boxes.datasource          IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN dh_core_boxes.opid                IS 'Operation identifier';
COMMENT ON COLUMN dh_core_boxes.numauto             IS 'Automatic integer primary key';
COMMENT ON COLUMN dh_core_boxes.db_update_timestamp IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_core_boxes.username            IS 'User (role) which created data record';

--}}}
-- dh_tech {{{

CREATE TABLE dh_tech (
    id character varying(20),
    depfrom numeric(10,2),
    depto numeric(10,2),
    drilled_len numeric(10,2),
    reco_len numeric(10,2),
    rqd_len numeric(10,2),
    diam character varying(10),
    datasource integer,
    opid integer,
    comments character varying,
    drillers_depto numeric(10,2),
    core_loss_cm integer,
    joints_description character varying,
    nb_joints integer,
    numauto serial UNIQUE NOT NULL,
    db_update_timestamp timestamp without time zone DEFAULT now(),
    username character varying DEFAULT "current_user"()
);

COMMENT ON TABLE dh_tech                            IS 'Technical drilling data, and geotechnical parameters';
COMMENT ON COLUMN dh_tech.id                        IS 'Drill hole identification';
COMMENT ON COLUMN dh_tech.depfrom                   IS 'Interval begining depth';
COMMENT ON COLUMN dh_tech.depto                     IS 'Interval ending depth';
COMMENT ON COLUMN dh_tech.drilled_len               IS 'Interval length';
COMMENT ON COLUMN dh_tech.reco_len                  IS 'Recovery length';
COMMENT ON COLUMN dh_tech.rqd_len                   IS 'Rock Quality Designation "length"';
COMMENT ON COLUMN dh_tech.diam                      IS 'core diameter';
COMMENT ON COLUMN dh_tech.numauto                   IS 'Automatic integer primary key';
COMMENT ON COLUMN dh_tech.datasource                IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN dh_tech.opid                      IS 'Operation identifier';
COMMENT ON COLUMN dh_tech.drillers_depto            IS 'Driller end-of-run depth, as mentioned on core block';
COMMENT ON COLUMN dh_tech.core_loss_cm              IS 'Core loss along drilled run';
COMMENT ON COLUMN dh_tech.joints_description        IS 'Joints description: rugosity, fillings, etc.';
COMMENT ON COLUMN dh_tech.nb_joints                 IS 'Count of natural joints along drilled run';
COMMENT ON COLUMN dh_tech.db_update_timestamp       IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_tech.username                  IS 'User (role) which created data record';

--}}}                
-- dh_struct_measures {{{

CREATE TABLE dh_struct_measures (
    opid integer,
    id character varying(20),
    depto numeric(10,2),
    measure_type character varying,
    structure_type character varying,
    alpha_tca numeric,
    beta numeric,
    gamma numeric,
    north_ref character varying,
    direction integer,
    dip integer,
    dip_quadrant character varying,
    pitch integer,
    pitch_quadrant character varying,
    movement character varying,
    valid boolean,
    struct_description character varying,
    sortgroup character(1),
    datasource integer,
    numauto serial UNIQUE NOT NULL,
    db_update_timestamp timestamp without time zone DEFAULT now(),
    username character varying DEFAULT "current_user"()
);


COMMENT ON TABLE dh_struct_measures                 IS 'Structural measurements done on core, or in trenches';
COMMENT ON COLUMN dh_struct_measures.opid           IS 'Operation identifier';
COMMENT ON COLUMN dh_struct_measures.id             IS 'Full identifier for borehole or trench';
COMMENT ON COLUMN dh_struct_measures.depto          IS 'Measurement depth';
COMMENT ON COLUMN dh_struct_measures.measure_type   IS 'Type of measurement: [P: plane L: line PL: plane line PLM: plane line movement PLMS: plane line movement sure]';
COMMENT ON COLUMN dh_struct_measures.structure_type IS 'Measured structure type: [VEIN , FRACTURE , C , SCHISTOSITY , FOLIATION , MYLONITE , CONTACT , VEIN_FAULT , FOLD_PAX_AX , FOLIATION_LINE , FAULT , CATACLASE , MINERALISED_STRUCTURE]';
COMMENT ON COLUMN dh_struct_measures.alpha_tca      IS 'Alpha angle = To Core Axis (TCA) angle, measured on core';
COMMENT ON COLUMN dh_struct_measures.beta           IS 'Beta angle';
COMMENT ON COLUMN dh_struct_measures.gamma          IS 'Gamma angle';
COMMENT ON COLUMN dh_struct_measures.north_ref      IS 'North reference for azimuths and directions measurements: [Nm: magnetic North, Ng: geographic North, Nu: UTM north, Nl: local grid Y axis]';
COMMENT ON COLUMN dh_struct_measures.direction      IS 'Plane direction, 0-180°';
COMMENT ON COLUMN dh_struct_measures.dip            IS 'Plane dip, 0-90°';
COMMENT ON COLUMN dh_struct_measures.dip_quadrant   IS 'Plane dip quadrant, NESW';
COMMENT ON COLUMN dh_struct_measures.pitch          IS 'Pitch of line on plane, 0-90°';
COMMENT ON COLUMN dh_struct_measures.pitch_quadrant IS 'Quadrant of pitch, NESW';
COMMENT ON COLUMN dh_struct_measures.movement       IS 'Relative movement of fault/C: [N: normal, I: inverse = R = reverse, D: dextral, S: sinistral]';
COMMENT ON COLUMN dh_struct_measures.valid          IS 'Measure is valid or not (impossible cases = not valid)';
COMMENT ON COLUMN dh_struct_measures.struct_description IS 'Naturalist description of measured structure';
COMMENT ON COLUMN dh_struct_measures.sortgroup      IS 'Sorting group, for discriminated of various phases: a, b, c, ...';
COMMENT ON COLUMN dh_struct_measures.datasource     IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN dh_struct_measures.numauto        IS 'Automatic integer primary key';
COMMENT ON COLUMN dh_struct_measures.db_update_timestamp IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_struct_measures.username       IS 'User (role) which created data record';

--}}}        
-- dh_litho {{{
-- lithological descriptions
CREATE TABLE dh_litho (
    opid integer,
    id character varying(20),
    depfrom numeric(10,2),
    depto numeric(10,2),
    description character varying,
    description1 character varying,
    description2 character varying,
    code1 character varying(4),
    code2 character varying(4),
    code3 character varying(4),
    code4 character varying(4),
    value1 integer,
    value2 integer,
    value3 integer,
    value4 integer,
    value5 integer,
    value6 integer,
    colour character varying,
    datasource integer,
    numauto serial UNIQUE NOT NULL,
    db_update_timestamp timestamp without time zone DEFAULT now(),
    username character varying DEFAULT "current_user"()
);

ALTER TABLE dh_litho OWNER TO data_admin;

COMMENT ON TABLE dh_litho                           IS 'Drill holes or trenches geological descriptions';
COMMENT ON COLUMN dh_litho.opid                     IS 'Operation identifier';
COMMENT ON COLUMN dh_litho.id                       IS 'Identifier, refers to dh_collars';
COMMENT ON COLUMN dh_litho.depfrom                  IS 'Interval beginning depth';
COMMENT ON COLUMN dh_litho.depto                    IS 'Interval ending depth';
COMMENT ON COLUMN dh_litho.description              IS 'Geological description, naturalist style';
COMMENT ON COLUMN dh_litho.description1             IS 'Complement to main geological description: metallic minerals';
COMMENT ON COLUMN dh_litho.description2             IS 'Complement to main geological description: alterations';
COMMENT ON COLUMN dh_litho.code1                    IS 'Conventional use is lithology code, 4 characters, uppercase. Refer to lex_codes table';
COMMENT ON COLUMN dh_litho.code2                    IS 'Conventional use is supergene oxidation, 1 character, uppercase. Refer to lex_codes table';
COMMENT ON COLUMN dh_litho.code3                    IS 'Conventional use is stratigraphy code, 4 characters, uppercase. Refer to lex_codes table';
COMMENT ON COLUMN dh_litho.code4                    IS '4 characters code. Refer to lex_codes table';
COMMENT ON COLUMN dh_litho.value1                   IS 'Integer value. Refer to lex_codes table';
COMMENT ON COLUMN dh_litho.value2                   IS 'Integer value. Refer to lex_codes table';
COMMENT ON COLUMN dh_litho.value3                   IS 'Integer value. Refer to lex_codes table';
COMMENT ON COLUMN dh_litho.value4                   IS 'Integer value. Refer to lex_codes table';
COMMENT ON COLUMN dh_litho.value5                   IS 'Integer value. Refer to lex_codes table';
COMMENT ON COLUMN dh_litho.value6                   IS 'Integer value. Refer to lex_codes table';
COMMENT ON COLUMN dh_litho.datasource               IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN dh_litho.numauto                  IS 'Automatic integer primary key';
COMMENT ON COLUMN dh_litho.db_update_timestamp      IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_litho.username                 IS 'User (role) which created data record';
--}}}
-- dh_sampling_grades {{{

CREATE TABLE dh_sampling_grades (
    id character varying(20),
    depfrom numeric(10,2),
    depto numeric(10,2),
    core_loss_cm numeric(5,1),
    weight_kg numeric(6,2),
    sample_type character varying(8),
    sample_id character varying(20),
    comments character varying,
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
    au_specks integer,
    quartering integer,
    numauto serial UNIQUE NOT NULL,
    db_update_timestamp timestamp without time zone DEFAULT now(),
    username character varying DEFAULT "current_user"()
);

COMMENT ON TABLE dh_sampling_grades                 IS 'Samples along drill holes and trenches, with grades';
COMMENT ON COLUMN dh_sampling_grades.id             IS 'Identifier, refers to dh_collars';
COMMENT ON COLUMN dh_sampling_grades.depfrom        IS 'Sample beginning depth';
COMMENT ON COLUMN dh_sampling_grades.depto          IS 'Sample ending depth';
COMMENT ON COLUMN dh_sampling_grades.core_loss_cm   IS 'Cumulated core loss over sampled interval, in cm';
COMMENT ON COLUMN dh_sampling_grades.weight_kg      IS 'Sample weight kg';
COMMENT ON COLUMN dh_sampling_grades.sample_type    IS 'Sample type: DD: core sample (diamond drill), RC: percussion drilling Reverse Circulation sample, NS: not sampled, CS: channel sample';
COMMENT ON COLUMN dh_sampling_grades.sample_id      IS 'Sample identifier: refers to assay results and quality check tables';
COMMENT ON COLUMN dh_sampling_grades.comments       IS 'Free comments, if any';
COMMENT ON COLUMN dh_sampling_grades.opid           IS 'Operation identifier';
COMMENT ON COLUMN dh_sampling_grades.batch_id       IS 'Batch identifier: refers to batch submission table: lab_ana_batches_expedition';
COMMENT ON COLUMN dh_sampling_grades.datasource     IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN dh_sampling_grades.au1_ppm        IS 'Au grade 1; cf. usage definition in lex_codes for opid';
COMMENT ON COLUMN dh_sampling_grades.au2_ppm        IS 'Au grade 2; cf. usage definition in lex_codes for opid';
COMMENT ON COLUMN dh_sampling_grades.au3_ppm        IS 'Au grade 3; cf. usage definition in lex_codes for opid';
COMMENT ON COLUMN dh_sampling_grades.au4_ppm        IS 'Au grade 4; cf. usage definition in lex_codes for opid';
COMMENT ON COLUMN dh_sampling_grades.au5_ppm        IS 'Au grade 5; cf. usage definition in lex_codes for opid';
COMMENT ON COLUMN dh_sampling_grades.au6_ppm        IS 'Au grade 6; cf. usage definition in lex_codes for opid';
COMMENT ON COLUMN dh_sampling_grades.ph             IS 'pH measurement (for acidic ores)';
COMMENT ON COLUMN dh_sampling_grades.moisture       IS 'Moisture content (for percussion drilling samples mainly)';
COMMENT ON COLUMN dh_sampling_grades.numauto        IS 'Automatic integer primary key';
COMMENT ON COLUMN dh_sampling_grades.au_specks      IS 'Number of gold specks seen in drill hole or trench; typically, after panning destructive drilling chips, also gold specks seen in core drilling';
COMMENT ON COLUMN dh_sampling_grades.quartering     IS 'Sample quartering, if any (for percussion drilling samples split on site, mainly)';
COMMENT ON COLUMN dh_sampling_grades.db_update_timestamp IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_sampling_grades.username       IS 'User (role) which created data record';

--}}}
-- dh_mineralised_intervals {{{

CREATE TABLE dh_mineralised_intervals (
    opid integer,
    id character varying(20),
    depfrom numeric(10,2),
    depto numeric(10,2),
    mine integer DEFAULT 1,
    avau numeric(10,2),
    stva character varying(150),
    accu numeric(10,2),
    recu numeric(10,2),
    dens numeric(10,2),
    comments character varying(100),
    datasource integer,
    numauto serial UNIQUE NOT NULL,
    db_update_timestamp timestamp without time zone DEFAULT now(),
    username character varying DEFAULT "current_user"()
);

COMMENT ON TABLE dh_mineralised_intervals           IS 'Drill holes mineralised intercepts: stretch values over mineralised intervals, along drill holes or trenches';
COMMENT ON COLUMN dh_mineralised_intervals.id       IS 'Full identifier for borehole or trench';
COMMENT ON COLUMN dh_mineralised_intervals.depfrom  IS 'Mineralised interval starting depth';
COMMENT ON COLUMN dh_mineralised_intervals.depto    IS 'Mineralised interval ending depth';
COMMENT ON COLUMN dh_mineralised_intervals.mine     IS 'Take-out interval class: 1=normal interval, 2=high-grade interval ';
COMMENT ON COLUMN dh_mineralised_intervals.avau     IS 'Average grade (g/t)';
COMMENT ON COLUMN dh_mineralised_intervals.stva     IS 'Stretch value, X m at Y g/t';
COMMENT ON COLUMN dh_mineralised_intervals.accu     IS 'Accumulation in m.g/t over mineralised interval';
COMMENT ON COLUMN dh_mineralised_intervals.recu     IS 'recovery';
COMMENT ON COLUMN dh_mineralised_intervals.dens     IS 'density';
COMMENT ON COLUMN dh_mineralised_intervals.numauto  IS 'Automatic integer primary key';
COMMENT ON COLUMN dh_mineralised_intervals.opid     IS 'Operation identifier';
COMMENT ON COLUMN dh_mineralised_intervals.db_update_timestamp IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_mineralised_intervals.username IS 'User (role) which created data record';
COMMENT ON COLUMN dh_mineralised_intervals.datasource IS 'Datasource identifier, refers to lex_datasource';

--}}}
-- dh_density {{{

CREATE TABLE dh_density (
    id character varying(20),
    depfrom numeric(10,2),
    depto numeric(10,2),
    density numeric(10,2),
    opid integer,
    density_humid numeric,
    moisture numeric,
    method character varying,
    numauto serial UNIQUE NOT NULL,
    db_update_timestamp timestamp without time zone DEFAULT now(),
    username character varying DEFAULT "current_user"(),
    datasource integer
);

COMMENT ON TABLE dh_density                         IS 'Density measurements along drill holes or trenches';
COMMENT ON COLUMN dh_density.id                     IS 'Identifier, refers to dh_collars';
COMMENT ON COLUMN dh_density.depfrom                IS 'Interval beginning depth: if not empty, density measured along an interval; otherwise, density measured on a point';
COMMENT ON COLUMN dh_density.depto                  IS 'Interval ending depth: if depfrom is empty, depth of ponctual density measurement';
COMMENT ON COLUMN dh_density.density                IS 'Density, unitless, or considered as kg/l, or t/m3';
COMMENT ON COLUMN dh_density.opid                   IS 'Operation identifier';
COMMENT ON COLUMN dh_density.density_humid          IS 'Density, unitless, or considered as kg/l, or t/m3, determined on humid sample';
COMMENT ON COLUMN dh_density.moisture               IS 'Moisture contents';
COMMENT ON COLUMN dh_density.method                 IS 'Procedure used to determine specific gravity';
COMMENT ON COLUMN dh_density.numauto                IS 'Automatic integer primary key';
COMMENT ON COLUMN dh_density.db_update_timestamp    IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_density.username               IS 'User (role) which created data record';
COMMENT ON COLUMN dh_density.datasource             IS 'Datasource identifier, refers to lex_datasource';

--}}}
-- dh_thinsections {{{

CREATE TABLE dh_thinsections (
    opid integer,
    id character varying,
    depto numeric(10,2),
    core_quarter character varying,
    questions character varying,
    name character varying,
    texture character varying,
    mineralogy character varying,
    metamorphism_deformations character varying,
    mineralisations character varying,
    origin character varying,
    numauto serial UNIQUE NOT NULL,
    db_update_timestamp timestamp without time zone DEFAULT now(),
    username character varying DEFAULT "current_user"(),
    datasource integer
);

COMMENT ON TABLE dh_thinsections                    IS 'Thin sections for petrological studies';
COMMENT ON COLUMN dh_thinsections.opid              IS 'Operation identifier';
COMMENT ON COLUMN dh_thinsections.id                IS 'Identifier, refers to dh_collars';
COMMENT ON COLUMN dh_thinsections.depto             IS 'Sample taken for thin section: bottom depth';
COMMENT ON COLUMN dh_thinsections.core_quarter      IS 'Optional code to identify which core quarter was taken to make thin section; useful for oriented core';
COMMENT ON COLUMN dh_thinsections.questions         IS 'Interrogations concerning sample; desired diagnose';
COMMENT ON COLUMN dh_thinsections.name              IS 'Result of diagnose: rock name';
COMMENT ON COLUMN dh_thinsections.texture           IS 'Result of diagnose: texture';
COMMENT ON COLUMN dh_thinsections.mineralogy        IS 'Result of diagnose: mineralogy';
COMMENT ON COLUMN dh_thinsections.metamorphism_deformations IS 'Result of diagnose: metamorphism and/or deformations';
COMMENT ON COLUMN dh_thinsections.mineralisations   IS 'Result of diagnose: mineralisations';
COMMENT ON COLUMN dh_thinsections.origin            IS 'Result of diagnose: origin: in case of highly transformed rock, protore';
COMMENT ON COLUMN dh_thinsections.numauto           IS 'Automatic integer primary key';
COMMENT ON COLUMN dh_thinsections.db_update_timestamp IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_thinsections.username          IS 'User (role) which created data record';
COMMENT ON COLUMN dh_thinsections.datasource        IS 'Datasource identifier, refers to lex_datasource';

--}}}
-- dh_sampling_bottle_roll {{{

CREATE TABLE dh_sampling_bottle_roll (
    opid integer,
    id text,
    depfrom numeric(10,2),
    depto numeric(10,2),
    sample_id character varying,
    au_total numeric(10,2),
    au_24h numeric(10,2),
    au_48h numeric(10,2),
    au_72h numeric(10,2),
    au_residu numeric(10,2),
    rec_24h_pc numeric(10,2),
    rec_48h_pc numeric(10,2),
    rec_72h_pc numeric(10,2),
    datasource integer,
    numauto serial UNIQUE NOT NULL,
    db_update_timestamp timestamp without time zone DEFAULT now(),
    username character varying DEFAULT "current_user"()
);

COMMENT ON TABLE dh_sampling_bottle_roll                      IS 'Mineralurgical samples, bottle-roll tests results';
COMMENT ON COLUMN dh_sampling_bottle_roll.opid                IS 'Operation identifier';
COMMENT ON COLUMN dh_sampling_bottle_roll.id                  IS 'Identifier, refers to dh_collars';
COMMENT ON COLUMN dh_sampling_bottle_roll.depfrom             IS 'Sample beginning depth';
COMMENT ON COLUMN dh_sampling_bottle_roll.depto               IS 'Sample ending depth';
COMMENT ON COLUMN dh_sampling_bottle_roll.sample_id           IS 'Sample identifier: refers to assay results and quality check tables';
COMMENT ON COLUMN dh_sampling_bottle_roll.au_total            IS 'Total gold recovered';
COMMENT ON COLUMN dh_sampling_bottle_roll.au_24h              IS 'Gold recovered after 24 hours';
COMMENT ON COLUMN dh_sampling_bottle_roll.au_48h              IS 'Gold recovered after 48 hours';
COMMENT ON COLUMN dh_sampling_bottle_roll.au_72h              IS 'Gold recovered after 72 hours';
COMMENT ON COLUMN dh_sampling_bottle_roll.au_residu           IS 'Residual gold';
COMMENT ON COLUMN dh_sampling_bottle_roll.rec_24h_pc          IS 'Recovery after 24 hours, percent';
COMMENT ON COLUMN dh_sampling_bottle_roll.rec_48h_pc          IS 'Recovery after 48 hours, percent';
COMMENT ON COLUMN dh_sampling_bottle_roll.rec_72h_pc          IS 'Recovery after 72 hours, percent';
COMMENT ON COLUMN dh_sampling_bottle_roll.datasource          IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN dh_sampling_bottle_roll.numauto             IS 'Automatic integer primary key';
COMMENT ON COLUMN dh_sampling_bottle_roll.db_update_timestamp IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_sampling_bottle_roll.username            IS 'User (role) which created data record';

--}}}
   
-- _____________JEANSUILA_________________________





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
DROP TABLE IF EXISTS lab_ana_results ;
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
COMMENT ON TABLE lab_ana_results                    IS 'Laboratory results table, after laboratory instructions, related to LIMS system';
COMMENT ON COLUMN lab_ana_results.labname           IS 'Analytical laboratory';
COMMENT ON COLUMN lab_ana_results.lab_pjcsa_pro_job IS 'jcsa.pro_job,           --> Intertek JobNo (VarChar(20))';
COMMENT ON COLUMN lab_ana_results.lab_pj_cli_code   IS 'pj.cli_code,             --> Client Name (VarChar(40))';
COMMENT ON COLUMN lab_ana_results.lab_pj_orderno    IS 'pj.orderno,              --> Client Order No (VarChar(40))';
COMMENT ON COLUMN lab_ana_results.lab_pjc_sampleident      IS 'pjc.sampleident,         --> Client SampleID (VarChar(40))';
COMMENT ON COLUMN lab_ana_results.lab_pjcsa_sch_code       IS 'pjcsa.sch_code,          --> Scheme Code (Intertek Internal Code - which probably reported to Client as well) (VarChar(20))';
COMMENT ON COLUMN lab_ana_results.lab_pjcsa_analytecode    IS 'pjcsa.analytecode,       --> Analyte Code (Intertek Internal Code - which probably reported to Client as well) (VarChar(20))';
COMMENT ON COLUMN lab_ana_results.lab_pjcsa_formattedvalue IS 'pjcsa.formattedvalue     --> Reported Value (VarChar(20))';
COMMENT ON COLUMN lab_ana_results.batch_id          IS 'Batch number';
COMMENT ON COLUMN lab_ana_results.db_update_timestamp      IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN lab_ana_results.value_num         IS 'Reported value, converted to numeric. IS becomes -999, LNR -9999, < -, > nothing';

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
-- lab analyses: {{{
-- lab_ana_results {{{


CREATE TABLE lab_ana_results (
    labname character varying(10),
    jobno character varying(20),
    orderno character varying(40),
    sample_id character varying(40),
    scheme character varying(20),
    analyte character varying(20),
    value character varying(20),
    db_update_timestamp timestamp without time zone DEFAULT now(),
    value_num numeric,
    opid integer,
    batch_id integer,
    sampletype character varying,
    unit character varying,
    datasource integer,
    numauto integer NOT NULL,
    sample_id_lab character varying,
    valid boolean DEFAULT true,
    detlim numeric,
    uplim numeric,
    username character varying DEFAULT "current_user"()
);

COMMENT ON TABLE lab_ana_results IS 'Laboratory results table, after laboratory instructions, related to LIMS system';
COMMENT ON COLUMN lab_ana_results.labname IS 'Analytical laboratory';
COMMENT ON COLUMN lab_ana_results.jobno IS 'jcsa.pro_job,           --> Intertek JobNo (VarChar(20))';
COMMENT ON COLUMN lab_ana_results.orderno IS 'pj.orderno,              --> Client Order No (VarChar(40))';
COMMENT ON COLUMN lab_ana_results.sample_id IS 'Sample Identifier';
COMMENT ON COLUMN lab_ana_results.scheme IS 'pjcsa.sch_code,          --> Scheme Code (Intertek Internal Code - which probably reported to Client as well) (VarChar(20))';
COMMENT ON COLUMN lab_ana_results.analyte IS 'pjcsa.analytecode,       --> Analyte Code (Intertek Internal Code - which probably reported to Client as well) (VarChar(20))';
COMMENT ON COLUMN lab_ana_results.value IS 'pjcsa.formattedvalue     --> Reported Value (VarChar(20))';
COMMENT ON COLUMN lab_ana_results.db_update_timestamp IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN lab_ana_results.value_num IS 'Reported value, converted to numeric. IS becomes -999, LNR -9999, < -, > nothing';
COMMENT ON COLUMN lab_ana_results.opid IS 'Operation identifier';
COMMENT ON COLUMN lab_ana_results.batch_id IS 'Batch identifier';
COMMENT ON COLUMN lab_ana_results.sampletype IS 'Sample type: DUP: duplicate, STD: standard, REP: repeat, etc.';
COMMENT ON COLUMN lab_ana_results.unit IS 'Unit: PPM, PPB, KG, G, %, etc.';
COMMENT ON COLUMN lab_ana_results.datasource IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN lab_ana_results.numauto IS 'Automatic integer primary key';
COMMENT ON COLUMN lab_ana_results.sample_id_lab IS 'pjc.sampleident,         --> Client SampleID (VarChar(40)) => sometimes different from REAL sample_id';
COMMENT ON COLUMN lab_ana_results.valid IS 'Analysis is considered as valid or ignored (if QAQC failed, for instance)';
COMMENT ON COLUMN lab_ana_results.detlim IS 'Lower detection limit';
COMMENT ON COLUMN lab_ana_results.uplim IS 'Upper limit';
COMMENT ON COLUMN lab_ana_results.username IS 'User (role) which created data record';

-- }}}

-- Name: lab_ana_results_sample_id_default_value_num(); Type: FUNCTION; {{{

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
-- }}}

--}}}

-- licences, tenements: {{{
-- @#redo with polygons instead of quadrangles; make a field containing EWKT
DROP TABLE IF EXISTS licences CASCADE;
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
COMMENT ON TABLE licences                           IS 'Licences, tenements';
COMMENT ON COLUMN licences.opid                     IS 'Operation identifier, see table operations';
COMMENT ON COLUMN licences.id                       IS 'Licence identifier, automatic sequence';
COMMENT ON COLUMN licences.licence_name             IS 'Name of licence';
COMMENT ON COLUMN licences.operator                 IS 'Owner of licence';
COMMENT ON COLUMN licences.year                     IS 'Year when licence was valid';
COMMENT ON COLUMN licences.lat_min                  IS 'South latitude, decimal degrees, WGS84';
COMMENT ON COLUMN licences.lon_min                  IS 'West longitude, decimal degrees, WGS84';
COMMENT ON COLUMN licences.lat_max                  IS 'North latitude, decimal degrees, WGS84';
COMMENT ON COLUMN licences.lon_max                  IS 'East latitude, decimal degrees, WGS84';

DROP VIEW IF EXISTS licences_quadrangles;
CREATE VIEW licences_quadrangles AS 
SELECT *, GeomFromewkt('SRID=4326;POLYGON(('||lon_min||' '||lat_max||','||lon_max||' '||lat_max||','||lon_max||' '||lat_min||','||lon_min||' '||lat_min||','||lon_min||' '||lat_max||'))')
FROM licences ORDER BY licence_name;
--}}}
}}}

-- functions:{{{
--generate_cross_sections_array:{{{
CREATE FUNCTION public.generate_cross_sections_array() RETURNS trigger
    LANGUAGE plpythonu
    AS $$
#{{{
#{{{
# This function is called from a TRIGGER of 
# sections_definition table, without any argument; 
# it returns a trigger.
# TRIGGER definition:
#    CREATE TRIGGER sections_definition_change 
#    AFTER INSERT OR UPDATE ON sections_definition 
#    FOR EACH ROW 
#    EXECUTE PROCEDURE generate_cross_sections_array();
#
# TODO @#faire le pendant, qui détruise les enregistrements de sections_array quand on supprime un enregistrement de sections_definition
# TODO @#do the symetric, to DELETE records from sections_array when a sections_definition record is DELETEd.
#}}}
from math import sin, cos, pi
import string

sep       = "," #"\t"      # Separator definition: comma
sepchar   = "\'"           # Character string separator definition: ', in SQL

# Get parameters defining cross-sections, from the sections_definition table:
res = plpy.execute("SELECT opid, id, location, srid, ll_corner_x, ll_corner_y, ll_corner_z, azim_ng, interval, num_start, count, length, title FROM sections_definition /*WHERE opid IN (SELECT opid FROM operation_active)*/;")

sql_insert = ""               #We build a sql_insert string which will contain everything necessary, mostly INSERTs.

# First, DELETE existing cross-sections from sections_array table:{{{
sql_insert += "DELETE FROM sections_array WHERE sections_array.opid IN (SELECT opid FROM operation_active) AND sections_array.id IS NOT NULL; "
# No: rather, just remove existing cross-sections having the same id as the one which has just been affected:
#sql_insert +="DELETE FROM sections_array WHERE substr(sections_array.title, 1, " + str(NEW["title"].len) + ") = " + sepchar + NEW["title"] + sepchar + ";"
# => marche pas:
#  ERREUR:  PL/python : NameError: global name 'NEW' is not defined
#  CONTEXTE : fonction PL/ generate_cross_sections_array Python 
# =>@# TODO reprendre
#}}}

i = 0
for line in res:
    # Result is given as dictionaries tuples:
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
    #num   = 1                                 # no need, there is an autoincrement in the table 
    section_nr = num_start                     # cross-section number
    sql_insert += "INSERT INTO sections_array (opid, location, id, title, srid, length, x1, y1, z1, x2, y2, z2) VALUES \n"
    for j in range(count):
        #out =  str(opid) + sep + sepchar + location + sepchar + sep + sepchar + location+'_'+str(section_nr).zfill(3) + sepchar + sep + sepchar + title + " - section # "+str(section_nr)                       + sepchar + sep + str(srid) + sep
        out  =  str(opid) + sep + sepchar + location + sepchar + sep + sepchar + location+'_'+str(section_nr).zfill(3) + sepchar + sep + sepchar + title + " - section " + location+'_'+str(section_nr).zfill(3) + sepchar + sep + str(srid) + sep
        x2 = ll_corner_x+interval_*(j) * cos((90.0-azim_ng)/180*pi)
        y2 = ll_corner_y+interval_*(j) * sin((90.0-azim_ng)/180*pi)
        x1 = x2 - length * sin((90.0-azim_ng)/180*pi)
        y1 = y2 + length * cos((90.0-azim_ng)/180*pi)
        z  = ll_corner_z
        out += str(length) + sep + str(x1) + sep + str(y1) + sep + str(z) + sep + str(x2) + sep + str(y2) + sep + str(z)
        sql_insert += "("+out+"),\n"
        section_nr += 1
    sql_insert = sql_insert[0:len(sql_insert)-2]  #pour enlever le dernier ",\n"
    sql_insert += ";\n"
    i += 1

# Instead of returning the string (like in the standalone python script), let's execute directly the SQL:
res = plpy.execute(sql_insert)
return 'OK'
#}}}
$$;

ALTER FUNCTION public.generate_cross_sections_array() OWNER TO postgres;
--}}}
--lab_ana_results_sample_id_default_value_num:{{{
CREATE FUNCTION public.lab_ana_results_sample_id_default_value_num() RETURNS trigger
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

ALTER FUNCTION public.lab_ana_results_sample_id_default_value_num() OWNER TO pierre; --TODO why pierre?
--}}}
--string_to_int:{{{
DROP FUNCTION IF EXISTS string_to_int(text);
CREATE OR REPLACE FUNCTION string_to_int(t text) RETURNS bigint AS
$$
/*
Fournit un entier à partir d'une chaîne; intérêt pour éviter d'avoir des champs serial, pour les tables à carter avec postgis.
Returns an integer from a string; avoids the requirement for serial fields, for tables to be mapped using postgis.
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
--}}}

--views:
--operations_quadrangles:{{{
DROP VIEW IF EXISTS operations_quadrangles;
CREATE VIEW operations_quadrangles AS 
SELECT *, 
       GeomFromewkt('SRID=4326;POLYGON(('||lon_min||' '||lat_max||','
                                         ||lon_max||' '||lat_max||','
                                         ||lon_max||' '||lat_min||','
                                         ||lon_min||' '||lat_min||','
                                         ||lon_min||' '||lat_max||'))'
                   )
FROM operations ORDER BY operation;

COMMENT ON VIEW operations_quadrangles IS 'Rectangles geographically traced around all operations';

--}}}



--_____________JEANSUILA_________________________



--les traces des sondages, pareil, pour un srid
CREATE OR REPLACE VIEW dh_traces_3d AS
SELECT *,
       GeomFromEWKT(
                    'SRID=' || srid ||
                    ';LINESTRING (' ||
                                   x    || ' ' ||
                                   y    || ' ' ||
                                   z    || 
                                          ', ' ||
                                   x1   || ' ' ||
                                   y1   || ' ' ||
                                   z1   ||
                                ')'
                   )
 FROM (
       SELECT *,
              x + length * cos((dip_hz / 180) * pi()) * sin((azim_ng / 180) * pi()) AS x1,
              y + length * cos((dip_hz / 180) * pi()) * cos((azim_ng / 180) * pi()) AS y1,
              z - length * sin((dip_hz / 180) * pi())                               AS z1
       FROM dh_collars
       --WHERE srid = 20136
     ) tmp
ORDER BY tmp.id;

--trash:{{{
--CREATE OR REPLACE VIEW dh_traces_3d_20137 AS 
--SELECT *, GeomFromEWKT('SRID=' || srid || ';LINESTRING (' || x || ' ' || y || ' ' || z || ', ' || x1 || ' ' || y1 || ' ' || z1 || ')') FROM (SELECT *, x + length * cos((dip_hz / 180) * pi()) * sin((azim_ng / 180) * pi()) AS x1, y + length * cos((dip_hz / 180) * pi()) * cos((azim_ng / 180) * pi()) AS y1, z - length * sin((dip_hz / 180) * pi()) AS z1
--FROM dh_collars
--WHERE srid = 20137) tmp
--ORDER BY tmp.id;
--}}}



--les vues refaisant comme les tables séparées pour trous futurs et prévus:
--views acting like separate tables for planned and realised holes:
CREATE VIEW collars AS SELECT * FROM dh_collars WHERE completed;
CREATE VIEW collars_program AS SELECT * FROM dh_collars WHERE NOT(completed);






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
COMMENT ON TABLE locations                          IS 'Zones, prospects code, rectangle';
COMMENT ON COLUMN locations.operation               IS 'Operation id';
COMMENT ON COLUMN locations.location                IS 'Location code name, see collars.location';
COMMENT ON COLUMN locations.full_name               IS 'Location full name';
COMMENT ON COLUMN locations.lat_min                 IS 'South latitude, decimal degrees, WGS84';
COMMENT ON COLUMN locations.lon_min                 IS 'West longitude, decimal degrees, WGS84';
COMMENT ON COLUMN locations.lat_max                 IS 'North latitude, decimal degrees, WGS84';
COMMENT ON COLUMN locations.lon_max                 IS 'East latitude, decimal degrees, WGS84';

--CREATE VIEW locations_rectangles AS SELECT *, GeomFromewkt('SRID=@#latlonwgs84;LINESTRING @#ou_plutôt_rectangle (' 
--|| lon_min || ' ' || lat_max || ', ' 
--|| lon_max || ' ' || lat_max || ', '
--|| lon_max || ' ' || lat_min || ', '
--|| lon_min || ' ' || lat_min || ', '
--|| lon_min || ' ' || lat_max || )) 
--FROM locations ORDER BY location;
-}}}




--}}}

--geochemistry

--anomalies

--targets

--mines

--various, utilities:
--quick plot of xy {{{
DROP TABLE IF EXISTS tmp_xy CASCADE;
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

DROP VIEW IF EXISTS tmp_xy_points;
CREATE VIEW tmp_xy_points AS
SELECT *, GeomFromewkt('SRID='|| srid ||';POINT(' || x || ' ' || y || ' ' || z || ')')
FROM tmp_xy;
--}}}

