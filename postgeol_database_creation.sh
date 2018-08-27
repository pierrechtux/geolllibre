#!/bin/bash
#	Title:   "Creation of postgeol database: postgresql database for geological data"
#	Name:    postgeol_database_creation.sh
#            (used to be: bdexplo_creation.r  => when it was a mining exploration database)
#	Version: 0.0.1
#	Date:    22-Aug-2018/22:29:08+2:00
#	Author:  "Pierre Chevalier"
#	License: {
#		This file is part of GeolLLibre software suite: FLOSS dedicated to Earth Sciences.
#		###########################################################################
#		##          ____  ___/_ ____  __   __   __   _()____   ____  _____       ##
#		##         / ___\/ ___// _  |/ /  / /  / /  /  _/ _ \ / __ \/ ___/       ##
#		##        / /___/ /_  / / | / /  / /  / /   / // /_/_/ /_/ / /_          ##
#		##       / /_/ / /___|  \/ / /__/ /__/ /___/ // /_/ / _, _/ /___         ##
#		##       \____/_____/ \___/_____/___/_____/__/_____/_/ |_/_____/         ##
#		##                                                                       ##
#		###########################################################################
#		  Copyright (C) 2018 Pierre Chevalier <pierrechevaliergeol@free.fr>
#		 
#		    GeolLLibre is free software: you can redistribute it and/or modify
#		    it under the terms of the GNU General Public License as published by
#		    the Free Software Foundation, either version 3 of the License, or
#		    (at your option) any later version.
#		
#		    This program is distributed in the hope that it will be useful,
#		    but WITHOUT ANY WARRANTY; without even the implied warranty of
#		    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#		    GNU General Public License for more details.
#		
#		    You should have received a copy of the GNU General Public License
#		    along with this program.  If not, see <http://www.gnu.org/licenses/>
#		    or write to the Free Software Foundation, Inc., 51 Franklin Street, 
#		    Fifth Floor, Boston, MA 02110-1301, USA.
#		    See LICENSE file.
#		}
#]

#-- General variables:
#-- TODO => les mettre dans ce script, plutôt que dans les .sql ; demander, au besoin, les valeurs interactivement.

echo "Make a new empty database, with postgis extension."
echo "Also, create a schema with the current user's name."

echo "The database to be created comes from environment variable \$POSTGEOL, which is now '$POSTGEOL'."
newdb=$POSTGEOL
# TODO treat case when environment variable is not defined; maybe offer a choice to the user, for another database name.

echo "Drop database $POSTGEOL, if it already exists:"
# TODO prompt for a confirmation
dropdb $newdb

echo "Database creation:"
createdb $newdb --o $LOGNAME

echo "Implement extensions and languages:"
psql -X -U postgres -d $newdb --single-transaction -c "
 CREATE EXTENSION postgis;
 CREATE EXTENSION postgis_topology;
 GRANT ALL ON geometry_columns to $LOGNAME;
 GRANT SELECT ON spatial_ref_sys to $LOGNAME;
 CREATE LANGUAGE plpythonu;
 CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
 CREATE SCHEMA $LOGNAME; 
 GRANT ALL ON SCHEMA $LOGNAME TO $LOGNAME;"

echo "Creation of postgeol structure in database named: " $newdb
echo " 1) schemas and tables:"
psql -d $newdb -f ~/geolllibre/postgeol_structure_01_tables.sql | grep -v "^SET$\|^COMMENT$" | grep -v "^CREATE TABLE$" | grep -v "CREATE SCHEMA"

echo " 2) functions (this part has to be run as postgresql superuser: postgres):"
psql -d $newdb -U postgres -f ~/geolllibre/postgeol_structure_02_functions.sql

echo " 3) views:"
# create the queries set:
newdb=$POSTGEOL #########ENLEVER APRES MISE AU POINT SCRIPT########
psql -d $newdb -U postgres -f ~/geolllibre/postgeol_structure_03_views.sql

exit 0 #################################### DEBUG #### _______________ENCOURS_______________GEOLLLIBRE

~/geolllibre/gll_bdexplo_views_create.r # TODO paramétrer le nom de la base


# à la fin, pour transférer les données de bdexplo vers postgeol:
# postgeol_transfer_data_from_bdexplo.sh

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
