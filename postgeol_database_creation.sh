#!/bin/bash
#	Title:   "Creation of postgeol database: postgresql database for geological data"
#	Name:    postgeol_database_creation.sh
#            (used to be: bdexplo_creation.r  => when it was a mining exploration database)
#	Version: 0.0.2
#	Date:    22-Aug-2018/22:29:08+2:00
#	Author:  "Pierre Chevalier"
#	License: {
echo "    Now running script $0"
echo "{{{"
echo "		This file is part of GeolLLibre software suite: FLOSS dedicated to Earth Sciences."
echo "		###########################################################################"
echo "		##          ____  ___/_ ____  __   __   __   _()____   ____  _____       ##"
echo "		##         / ___\/ ___// _  |/ /  / /  / /  /  _/ _ \ / __ \/ ___/       ##"
echo "		##        / /___/ /_  / / | / /  / /  / /   / // /_/_/ /_/ / /_          ##"
echo "		##       / /_/ / /___|  \/ / /__/ /__/ /___/ // /_/ / _, _/ /___         ##"
echo "		##       \____/_____/ \___/_____/___/_____/__/_____/_/ |_/_____/         ##"
echo "		##                                                                       ##"
echo "		###########################################################################"
echo "		  Copyright (C) 2018 Pierre Chevalier <pierrechevaliergeol@free.fr>"
echo ""
echo "		    GeolLLibre is free software: you can redistribute it and/or modify"
echo "		    it under the terms of the GNU General Public License as published by"
echo "		    the Free Software Foundation, either version 3 of the License, or"
echo "		    (at your option) any later version."
echo "		"
echo "		    This program is distributed in the hope that it will be useful,"
echo "		    but WITHOUT ANY WARRANTY; without even the implied warranty of"
echo "		    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the"
echo "		    GNU General Public License for more details."
echo "		"
echo "		    You should have received a copy of the GNU General Public License"
echo "		    along with this program.  If not, see <http://www.gnu.org/licenses/>"
echo "		    or write to the Free Software Foundation, Inc., 51 Franklin Street,"
echo "		    Fifth Floor, Boston, MA 02110-1301, USA."
echo "		    See LICENSE file."
#		}
#]

echo
echo "	 _________                      "
echo "	< BDexplo >               <= the ancester of postgeol, ca. 1992 to 2018"
echo "	 ---------                      "
echo "	        \   ^__^                "
echo "	         \  (xx)\_______        "
echo "	            (__)\       )\/\    "
echo "	             U  ||----w |       "
echo "	                ||     ||       "
echo
echo "	 __________                     "
echo "	< PostGeol >                  <= the descendant of bdexplo, since 2016"
echo "	 ----------"
echo "	        \    __                 "
echo "	         \ /(  )\_---------_    "
echo "	          { (°°) }          )\  "
echo "	          { /()\ }          | \ "
echo "	           / () \  |____\   |   "
echo "	          /  !! |\ |     |  |\  "
echo "	             J  [__|     [__||  "  #	TODO: hack cowsay source, and add a pachydermic option"
echo
echo "           ____________________________________"
echo "         oO                                    Oo"
echo "         °                                        °"
echo "        {     PostGeol: PostgreSQL for Geology     }"
echo "         °                                        °"
echo "          °o____________________________________o°"

# General variables:
# TODO => les mettre dans ce script, plutôt que dans les .sql ; demander, au besoin, les valeurs interactivement.
# nom de la base à créer, hôte, port
# les rôles, sont-ils existants ou à créer, qui fait quoi (cf. autre script plus avant, de gestion des rôles).

#clear ################### <= ENLEVER APRES MISE AU POINT SCRIPT ######## TODO
echo
echo
echo
echo "Generation of a new empty database with PostGIS extension, with the PostgreSQL structure."
echo
#echo "Make a new empty database."
#echo "Also, create a schema with the current user's name, who becomes the creator and owner of the database."
echo
echo "}}}" #

############ DEFINE SERVER:
echo "- 1. SERVER DEFINITION:                                                      {{{"
echo "- 1.1 HOST:                                                               {{{"
echo -e "Default postgresql database server is named after environment variable \$GLL_BD_HOST, which is now:\n  $GLL_BD_HOST"
echo "Press <Enter> to confirm, or type a valid postgresql server hostname and then <Enter>:"
read tmp
[[ ! -z "$tmp" ]] && GLL_BD_HOST=$tmp
echo "  Hostname: $GLL_BD_HOST"
echo
echo "                                                                          }}}"
echo "- 1.2 PORT:                                                               {{{"
echo -e "Default port (traditionnally 5432) of the postgresql database is named after environment variable \$GLL_BD_PORT, which is now:\n  $GLL_BD_PORT"
echo "Press <Enter> to confirm, or type a valid port number used by postgresql on $GLL_BD_HOST server:"
read tmp
[[ ! -z "$tmp" ]] && GLL_BD_PORT=$tmp
echo "  Port: $GLL_BD_PORT"
echo
echo "                                                                          }}}"
echo "- 1.3 DATABASE NAME:                                                      {{{"
echo -e "The default database to be created is named after environment variable \$POSTGEOL, which is now:\n  $POSTGEOL"
#echo "Enter to validate this database name for the new database to be created; otherwise, enter a valid database name (no dashes, preferrably lowercase, underscores, etc.) to be created with postgeol structure:"
echo "Press <Enter> to confirm, or type a valid database name (no dashes, preferrably lowercase, underscores, etc.) to be created with postgeol structure on postgresql $GLL_BD_HOST server:"
read tmp
[[ ! -z "$tmp" ]] && POSTGEOL=$tmp
echo "  Database: $POSTGEOL"
echo
echo "                                                                          }}}"
echo "- 1.4 SUPERUSER NAME:                                                     {{{"
echo -e "The default database user name (\"role\", in PostgreSQL terminology) is named after environment variable \$GLL_BD_USER (which is usually by default the other environment variable \$USER), which is now:\n  $GLL_BD_USER"
#echo "Enter to validate this database name for the new database to be created; otherwise, enter a valid database name (no dashes, preferrably lowercase, underscores, etc.) to be created with postgeol structure:"
echo "Press <Enter> to confirm, or type a valid database role name (it should already exist in the database; TODO will implement later role creation; no hurry) to be used as the owner of the $POSTGEOL database to be created:"
read tmp
[[ ! -z "$tmp" ]] && GLL_BD_USER=$tmp
echo "  Username: $GLL_BD_USER"
echo
echo "                                                                          }}}"

######## On rappelle la connexion:
echo "- 1. SUMMARY:"
CONNINFO="-h $GLL_BD_HOST -p $GLL_BD_PORT -U $GLL_BD_USER $POSTGEOL"
echo -e "Summary: on postgresql server *$GLL_BD_HOST* listening on port *$GLL_BD_PORT*, the database *$POSTGEOL* is about to be created, with owner role *$GLL_BD_USER*.\nThis can be summarised as the options below:\  $CONNINFO\nPress enter to confirm, Ctrl-C to cancel."
read tmp
echo "                                                                             }}}"
echo "- 2. DATABASE CREATION:                                                      {{{"
echo "- 2.1 DESTRUCTION (...):                                                  {{{"
echo "Before creating $POSTGEOL database, drop database $POSTGEOL, if it already exists (TODO to be implemented):"
echo "Enter to continue, Ctrl-C to cancel:"
read
#dropdb -h $GLL_BD_HOST -p $GLL_BD_PORT -U $GLL_BD_USER $POSTGEOL
dropdb $CONNINFO
echo "                                                                          }}}"
echo "- 2.2 CREATION:                                                           {{{"
echo "Database creation:"
#createdb $POSTGEOL --o $GLL_BD_USER -h $GLL_BD_HOST -p $GLL_BD_PORT
#createdb -h $GLL_BD_HOST -p $GLL_BD_PORT -U $GLL_BD_USER -O $GLL_BD_USER $POSTGEOL
createdb $CONNINFO -O $GLL_BD_USER
echo "                                                                          }}}"
echo "                                                                             }}}"
echo "- 3. IMPLEMENT EXTENSIONS AND LANGUAGES:                                     {{{"
echo "- 3.1 DESTRUCTION (...):                                                  {{{"
dropdb -h $GLL_BD_HOST -p $GLL_BD_PORT -U $GLL_BD_USER $POSTGEOL
echo "                                                                          }}}"
echo "- 2.2 CREATION:                                                           {{{"
echo "Database creation:"
createdb $POSTGEOL --o $GLL_BD_USER -h $GLL_BD_HOST -p $GLL_BD_PORT
createdb -h $GLL_BD_HOST -p $GLL_BD_PORT -U $GLL_BD_USER -O $GLL_BD_USER $POSTGEOL
echo "                                                                          }}}"

exit 0 ######## DEBUG #### _______________ENCOURS_______________GEOLLLIBRE

#echo "IMPLEMENT EXTENSIONS AND LANGUAGES:"
#psql -d $POSTGEOL -X --single-transaction -U postgres -c "
# CREATE EXTENSION postgis;
# CREATE EXTENSION postgis_topology;
# GRANT ALL ON geometry_columns to $LOGNAME;
# GRANT SELECT ON spatial_ref_sys to $LOGNAME;
# CREATE LANGUAGE plpythonu;
# CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
# CREATE SCHEMA $LOGNAME;
# GRANT ALL ON SCHEMA $LOGNAME TO $LOGNAME;"

echo "IMPLEMENT EXTENSIONS AND LANGUAGES:"
psql $CONNINFO -U postgres -c "
 CREATE EXTENSION postgis;
 CREATE EXTENSION postgis_topology;
 GRANT ALL ON geometry_columns to $LOGNAME;
 GRANT SELECT ON spatial_ref_sys to $LOGNAME;
 CREATE LANGUAGE plpythonu;
 CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
 CREATE SCHEMA $LOGNAME;
 GRANT ALL ON SCHEMA $LOGNAME TO $LOGNAME;"
echo "                                                                             }}}"

echo "Creation of postgeol structure in database named: " $newdb
echo " 1) schemas and tables:"
psql -d $newdb -X --single-transaction             -f ~/geolllibre/postgeol_structure_01_tables.sql    |& grep -v "^SET$\|^COMMENT$" |& grep -v "^CREATE TABLE$" |& grep -v "CREATE SCHEMA" |& grep -v "^psql:.* ERROR:  current transaction is aborted, commands ignored until end of transaction block$" # Note: all psql calls used to be the --single-transaction option, but it proved to make it very difficult to debug; so, instead, all .sql files have BEGIN TRANSACTION; and COMMIT; statements. => no... it proved to be easier to just grep -v ...

echo " 2) functions (this part has to be run as postgresql superuser: postgres):"
psql -d $newdb -X --single-transaction -U postgres -f ~/geolllibre/postgeol_structure_02_functions.sql |& grep -v "^SET$\|^COMMENT$" |& grep -v "^CREATE FUNCTION$"

echo " 3) views:"
# create the queries set:
psql -d $newdb -X --single-transaction             -f ~/geolllibre/postgeol_structure_03_views.sql     |& grep -v "^SET$\|^COMMENT$" |& grep -v "^CREATE VIEW$" |& grep -v "^CREATE RULE$"

#~/geolllibre/gll_bdexplo_views_create.r 
~/geolllibre/postgeol_structure_03_1_views_opid_create # TODO paramétrer le nom de la base => auquai.

# à la fin, pour transférer les données de bdexplo vers postgeol:
postgeol_transfer_data_from_bdexplo

exit 0 ###### si jamais...
--DES TABLES QUE, FINALEMENT, TOUT BIEN PESÉ, ON NE MET PAS DANS POSTGEOL:{{{
-- Il convient de les traiter comme il convient, dans bdexplo, où elles restent. En versant leurs données dans la *bonne* structure, celle de postgeol.
-- _______________ENCOURS_______________GEOLLLIBRE 5
-- ?? lab_ana_batches_reception_18_corr:{{{ TODO isn't this daube??

CREATE TABLE public.lab_ana_batches_reception_18_corr (
    opid integer REFERENCES operations (opid),
    jobno text,
    generic_txt text,
    labname text,
    client text,
    validated date,
    number_of_samples integer,
    project text,
    shipment_id text,
    p_o_number text,
    received date,
    certificate_comments text,
    info_suppl_json text
    datasource integer,
    numauto bigserial PRIMARY KEY,
    creation_ts timestamp without time zone,
    username text
);

--}}}
-- x field_sampling (used to be rock_sampling):{{{

-- TODO table très vide: contenu à verser, plutôt, dans surface_sampling (SI CE N'EST DÉJÀ FAIT!)
CREATE TABLE public.field_sampling (  -- Nota bene: field_sampling used to be called rock_sampling; actually, it may encompass much more than just rocks.  Actually, surface_sampling and field_sampling are competing names and notions...  Why not then, name all "field_*" tables "surface_*", or, abbreviated, "surf_*", or "srf_*", or even "sf*"?... TODO discuss these issues quickly, these choices are not so innocent.
    opid           integer
      REFERENCES public.operations(opid)
      ON UPDATE CASCADE
      ON DELETE CASCADE
       DEFERRABLE INITIALLY DEFERRED
    location       text,
    num            text,      -- renommer sample_id
    hammer_index   integer NOT NULL, -- HM! Garder pour le moment, pour la jointure avec rock_ana, puis virer.
    geologist      text,
    description    text,
    x              numeric(10,2),
    y              numeric(10,2),
    z              numeric(10,2),
    datasource     integer
--     FOREIGN KEY (opid) REFERENCES operations
);
-- {{{
/* Kept for history only
COMMENT ON TABLE  public.rock_sampling                IS 'outcrop sampling  (taken with geological hammer)'; -- TODO rectifier ça
COMMENT ON COLUMN public.rock_sampling.geologist      IS 'geologist name';
COMMENT ON COLUMN public.rock_sampling.num            IS 'sample name or number';
COMMENT ON COLUMN public.rock_sampling.x              IS 'X coordinate';
COMMENT ON COLUMN public.rock_sampling.y              IS 'Y coordinate';
COMMENT ON COLUMN public.rock_sampling.z              IS 'Z coordinate';
COMMENT ON COLUMN public.rock_sampling.hammer_index   IS 'integer related to the hammer_ana table';          -- TODO rectifier ça aussi
*/
COMMENT ON TABLE  public.field_sampling               IS 'Rock samples taken in the field, on surface: outcrops, floats, etc.'; -- TODO rectifier ça
COMMENT ON COLUMN public.field_sampling.geologist     IS 'Geologist name';
COMMENT ON COLUMN public.field_sampling.sample_id     IS 'Sample identifier: refers to assay results and quality check tables';
COMMENT ON COLUMN public.field_sampling.x             IS 'X coordinate'; -- TODO add an srid
COMMENT ON COLUMN public.field_sampling.y             IS 'Y coordinate';
COMMENT ON COLUMN public.field_sampling.z             IS 'Z coordinate';
COMMENT ON COLUMN public.field_sampling.hammer_index  IS 'integer related to the hammer_ana table';          -- TODO rectifier ça aussi
-- }}}
--}}}
-- x rock_ana:{{{ TODO rename table => no, rather DROP it; lab_ana_results contains results.  If necessary, make a field_sampling_grades table.
-- TODO table assez vide, tout comme field_sampling: contenu à verser, plutôt, dans lab_ana_results (SI CE N'EST DÉJÀ FAIT!)
-- _______________ENCOURS_______________GEOLLLIBRE 6
CREATE TABLE public.field_sampling_ana (  -- Nota bene: field_sampling_ana used to be called rock_ana; actually, it may encompass much more than just rocks.  See remarks above concerning field_sampling table.
    opid                integer REFERENCES operations (opid)
      REFERENCES operations (opid)
      ON UPDATE CASCADE
      ON DELETE CASCADE
      DEFERRABLE INITIALLY DEFERRED,
    --  hammer_index integer,  -- TODO rectifier ça... =>
    sample_id           text,
    shipment            date,
    ticket_id           text,
    reception           date,
    ana_type            integer,
    amc_batch           text,
    labo_batch          text,
    value               numeric(10,2),
    comments            text,
    numauto             bigserial PRIMARY KEY
);
-- COMMENT ON COLUMN public.rock_ana.hammer_index       IS 'Sample identification related to the hammer_sampling table';
COMMENT ON COLUMN public.rock_ana.value               IS 'Analysis value';
COMMENT ON COLUMN public.rock_ana.numauto             IS 'auto increment integer';

--}}}
-- x gps_wpt: TODO is this daube?{{{ TODO comparer avec field_observations (on dirait que les données y sont; mais vérifier en plottant sur SIG), et faire un bon ménage là-dedans. En profiter pour aller rechercher la bd que j'avais au SGR/REU, et reprendre mes waypoints de l'époque, qui doivent manquer à l'appel (il y en avait d'autres, des persos qui n'étaient pas dans cette BD?). Ainsi que les tracés (tracklogs), té, tank à fer. Tracés qu'il faudrait stocker en BD, aussi, bien sûr. En se calquant sur la structure d'oruxmaps par exemple; ou alors en stockant des gros jsonb ou des gros xml: à voir.

CREATE TABLE public.gps_wpt (
    opid integer REFERENCES operations (opid), -- TODO ATTENTION, CHAMP RAJOUTÉ
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

--}}}
-- x dh_collars_lengths{{{
-- Old data, historical, kept out of main tables set: -- TODO dump this as tagged contents (json-like, or equivalent) into comments field, rather; later on.

CREATE TABLE public.dh_collars_lengths (
    opid integer REFERENCES operations (opid),
    id text,
    len_destr numeric(10,2),
    len_pq numeric(10,2),
    len_hq numeric(10,2),
    len_nq numeric(10,2),
    len_bq numeric(10,2),
    numauto bigserial PRIMARY KEY
);
COMMENT ON TABLE dh_collars_lengths                   IS 'Old data, fields removed from dh_collars table, values stored here';
COMMENT ON COLUMN dh_collars_lengths.len_destr        IS 'Destructive (percussion or rotary drilling) length (m)';
COMMENT ON COLUMN dh_collars_lengths.len_pq           IS 'Core PQ length (m)';
COMMENT ON COLUMN dh_collars_lengths.len_hq           IS 'Core HQ length (m)';
COMMENT ON COLUMN dh_collars_lengths.len_nq           IS 'Core NQ length (m)';
COMMENT ON COLUMN dh_collars_lengths.len_bq           IS 'Core BQ length (m)';

--}}}
-- x program:{{{ TODO useful?? junk???
-- Name: program; Type: TABLE; Schema: pierre; Owner: pierre; Tablespace:

CREATE TABLE public.program (
    opid           integer
        REFERENCES public.operations (opid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED,
    gid            integer NOT NULL,
    myid           integer,
    geometry       public.geometry,
    id             text,
    completed      boolean,
    CONSTRAINT enforce_geotype_geometry CHECK (((public.geometrytype(geometry) = 'POINT'::text) OR (geometry IS NULL)))
);

-- Des sondages à faire vers Dakoua; regrouper toutes ces données de programmes (il y a aussi des tables mapinfectes et des shapefiles) dans dh_collars (sans grand enthousiasme).
--}}}
-- x layer_styles:{{{
-- => table vide => exclue de la migration de bdexplo vers postgeol

--CREATE TABLE layer_styles (
--    id integer NOT NULL,
--    f_table_catalog text,
--    f_table_schema text,
--    f_table_name text,
--    f_geometry_column text,
--    stylename text,
--    styleqml xml,
--    stylesld xml,
--    useasdefault boolean,
--    description text,
--    owner text,
--    ui xml,
--    update_time timestamp without time zone DEFAULT now()
--);

--}}}
-- }}}

############## TODO MÉNAGE
