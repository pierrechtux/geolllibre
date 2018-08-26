BEGIN TRANSACTION;
-- o views:
-- une vue retrouvée dans les tables:{{{
-- TODO Is this view still valid?  If not, erase.
--DROP VIEW IF EXISTS licences_quadrangles;
--CREATE VIEW licences_quadrangles AS
--SELECT *, GeomFromewkt('SRID=4326;POLYGON(('||lon_min||' '||lat_max||','||lon_max||' '||lat_max||','||lon_max||' '||lat_min||','||lon_min||' '||lat_min||','||lon_min||' '||lat_max||'))')
--FROM licences ORDER BY licence_name;
--}}}

-- o general views:
-- @#TODO vue inutile?? (dh_sampling = ??) => non, semble utile, appelée par d'autres vues checks.*:{{{
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
ALTER TABLE dh_sampling OWNER TO pierre; --TODO enlever tous ces "pierre" pour mettre des rôles 


-- }}}
-- o operations_quadrangles:{{{
-- DROP VIEW IF EXISTS operations_quadrangles;
CREATE VIEW operations_quadrangles AS
SELECT *,
       GeomFromewkt('SRID=4326;POLYGON('||lon_min||' '||lat_max||','
                                        ||lon_max||' '||lat_max||','
                                        ||lon_max||' '||lat_min||','
                                        ||lon_min||' '||lat_min||','
                                        ||lon_min||' '||lat_max||')' )
FROM operations ORDER BY opid;

COMMENT ON VIEW operations_quadrangles                IS 'Rectangles geographically traced around all operations';

--}}}
-- o stats_reports views:{{{

CREATE OR REPLACE VIEW
--stats_reports.stats_quotidiennes_avancements_sondages
--avancements_sondages_stats_quotidiennes 
stats_reports.drilling_daily_progress_stats AS
SELECT rig, date, sum(drilled_length_during_shift) as drilled_length_per_day, repeat('|'::text, (sum(drilled_length_during_shift)/10)::integer) AS graph_drilled_length_per_day, count(DISTINCT id) AS nb_drill_holes, min(id) AS first_dh, max(id) AS last_dh
FROM dh_shift_reports GROUP BY rig, date ORDER BY rig, date;

CREATE OR REPLACE VIEW 
--stats_reports.avancements_sondages_stats_mensuelles 
stats_reports.drilling_monthly_progress_stats AS
SELECT year, month, sum(drilled_length_during_shift) as drilled_length_during_month FROM (SELECT extract(year from date) as year, extract (month from date) as month, drilled_length_during_shift FROM
--drilling_daily_reports
 dh_shift_reports) AS tmp GROUP BY year,month ORDER BY year, month;

--idem, avec location:
CREATE OR REPLACE VIEW 
--stats_reports.avancements_sondages_stats_mensuelles_par_objectif 
stats_reports.drilling_daily_reports_per_target AS
SELECT year, month, target, sum(drilled_length_during_shift) as drilled_length_during_month FROM (SELECT extract(year from date) as year, extract (month from date) as month, drilled_length_during_shift, split_part (
--drill_hole_id
id, '_', 1) as target FROM
--drilling_daily_reports
 dh_shift_reports) AS tmp GROUP BY year,month, target ORDER BY year, month;


--stats annuelles
CREATE OR REPLACE VIEW 
--stats_reports.avancements_sondages_stats_annuelles 
stats_reports.drilling_yearly_progress_stats AS
SELECT year, sum(drilled_length_during_shift) as drilled_length_during_year FROM (SELECT extract(year from date) as year, drilled_length_during_shift FROM
--drilling_daily_reports
 dh_shift_reports) AS tmp GROUP BY year ORDER BY year;

--idem, avec location:
CREATE OR REPLACE VIEW 
--stats_reports.avancements_sondages_stats_annuelles_par_objectif
stats_reports.drilling_yearly_progress_stats_per_target AS
SELECT year, target, sum(drilled_length_during_shift) as drilled_length_during_month FROM (SELECT extract(year from date) as year, extract (month from date) as month, drilled_length_during_shift, substring(
--drill_hole_id
 id,1,4) as target FROM
--drilling_daily_reports
 dh_shift_reports) AS tmp GROUP BY year, target ORDER BY year;


CREATE OR REPLACE VIEW 
--stats_reports.longueur_exploree_par_location 
stats_reports.drilled_length_per_location AS --@#À AMÉLIORER!!!!
SELECT completed, location, dh_type, sum(length) AS sum_length
FROM dh_collars
GROUP BY
completed, location, dh_type
ORDER BY
completed, location, dh_type;


--longueur explorée par location et type
CREATE OR REPLACE VIEW 
--stats_reports.longueur_exploree_par_location_et_type
stats_reports.length_drilled_per_location_and_type AS
SELECT location,dh_type,sum(length) FROM dh_collars WHERE completed GROUP BY location,dh_type ORDER BY location,dh_type DESC;


--longueur explorée par type (en kilomètres):
CREATE OR REPLACE VIEW 
-- stats_reports.longueur_exploree_par_type_km AS
stats_reports.length_drilled_per_type_km AS
SELECT dh_type,sum(length)/1000 as km_explored_length FROM dh_collars GROUP BY dh_type ORDER BY dh_type DESC;


--}}}
-- o check views:{{{

--CREATE OR REPLACE VIEW checks.collars_location_vs_sector AS
--SELECT location, sector FROM dh_collars GROUP BY location,sector ORDER BY sector;

--Comparons un coup les profondeurs des tables de passes et des têtes:
--table échantillons:

CREATE OR REPLACE VIEW checks.collars_lengths_vs_dh_sampling_depths AS
SELECT dh_collars.id, length, max_depto_sampl, length - max_depto_sampl AS diff_SHOULD_BE_ZERO FROM dh_collars INNER JOIN (SELECT id, max(depto) AS max_depto_sampl FROM dh_sampling GROUP BY id) AS max_depto ON dh_collars.id=max_depto.id WHERE length - max_depto_sampl<>0 ORDER BY id;

CREATE OR REPLACE VIEW checks.collars_lengths_vs_dh_litho_depths AS
SELECT dh_collars.id, length, max_depto_litho, length - max_depto_litho AS diff_SHOULD_BE_ZERO FROM dh_collars INNER JOIN (SELECT id,max(depto) AS max_depto_litho FROM dh_litho GROUP BY id) AS max_depto ON dh_collars.id=max_depto.id WHERE length - max_depto_litho<>0 ORDER BY id;

CREATE OR REPLACE VIEW checks.doublons_collars_id AS
SELECT id AS collars_id_non_uniq, COUNT(id) FROM dh_collars GROUP BY id HAVING COUNT(id)>1;

CREATE OR REPLACE VIEW checks.doublons_dh_sampling_id_depto AS
SELECT id, depto, COUNT(*) FROM dh_sampling GROUP BY id, depto HAVING COUNT(*) > 1;

CREATE OR REPLACE VIEW checks.doublons_dh_litho_id_depto AS
SELECT id, depto, COUNT(*) FROM dh_litho GROUP BY id, depto HAVING COUNT(*) > 1;


CREATE OR REPLACE VIEW checks.tetes_passes_ouvrages_dans_tetes_pas_dans_passes_dh_sampling AS
SELECT dh_collars.id AS collars_id_without_samples, dh_sampling.id AS samples_id_nulls FROM dh_collars LEFT OUTER JOIN dh_sampling ON dh_collars.id=dh_sampling.id WHERE dh_sampling.id IS NULL ORDER BY dh_collars.id;

CREATE OR REPLACE VIEW checks.tetes_passes_ouvrages_dans_passes_pas_dans_tetes_dh_sampling AS
SELECT distinct dh_sampling_id FROM (SELECT dh_collars.id, dh_sampling.id AS dh_sampling_id FROM dh_collars RIGHT OUTER JOIN dh_sampling ON dh_collars.id=dh_sampling.id WHERE dh_collars.id IS NULL ORDER BY dh_sampling.id) tmp;

CREATE OR REPLACE VIEW checks.tetes_passes_ouvrages_dans_tetes_pas_dans_passes_dh_litho AS
SELECT dh_collars.id AS collars_id_without_litho, dh_litho.id AS litho_id_nulls FROM dh_collars LEFT OUTER JOIN dh_litho ON dh_collars.id=dh_litho.id WHERE dh_litho.id IS NULL ORDER BY dh_collars.id;

CREATE OR REPLACE VIEW checks.tetes_passes_ouvrages_dans_passes_pas_dans_tetes_dh_litho AS
SELECT dh_collars.id, dh_litho.id AS litho_id FROM dh_collars RIGHT OUTER JOIN dh_litho ON dh_collars.id=dh_litho.id WHERE dh_collars.id IS NULL ORDER BY dh_litho.id;


CREATE OR REPLACE VIEW checks.collars_vs_temp_topo_id_topo_sans_collars AS
SELECT
--tmp_dh_topo_coordinates
 topo_points.id AS id_topo, dh_collars.id AS id_collars FROM
--tmp_dh_topo_coordinates
 topo_points LEFT OUTER JOIN dh_collars ON
--tmp_dh_topo_coordinates
 topo_points.id = dh_collars.id WHERE dh_collars.id IS NULL;

CREATE OR REPLACE VIEW checks.collars_vs_topo_xyz_en_face_et_differences_importantes AS
SELECT id_topo, id_collars, topo_x, collars_x, diffx, topo_y, collars_y, diffy, topo_z, collars_z, diffz FROM (SELECT
--tmp_dh_topo_coordinates
topo_points.id AS id_topo, dh_collars.id AS id_collars,
--tmp_dh_topo_coordinates
 topo_points.x AS topo_x, dh_collars.x AS collars_x,
--tmp_dh_topo_coordinates
topo_points.y as topo_y, dh_collars.y AS collars_y,
--tmp_dh_topo_coordinates
topo_points.z AS topo_z, dh_collars.z AS collars_z,
--tmp_dh_topo_coordinates
topo_points.x-dh_collars.x AS diffx,
--tmp_dh_topo_coordinates
topo_points.y-dh_collars.y AS diffy,
--tmp_dh_topo_coordinates
topo_points.z-dh_collars.z AS diffz FROM
--tmp_dh_topo_coordinates
--topo_points
topo_points JOIN dh_collars ON
--tmp_dh_topo_coordinates
topo_points.id = dh_collars.id) tmp WHERE ABS(diffx) >= 0.05 OR ABS(diffy) >= 0.05 OR ABS(diffz) >= 0.05;


CREATE OR REPLACE VIEW checks.fichettes_infos_redondantes_incoherentes AS
SELECT nb_sondages_et_attributs, nb_sondages, nb_sondages_et_attributs-nb_sondages AS diff_SHOULD_BE_ZERO  FROM (SELECT count(*) AS nb_sondages_et_attributs FROM (SELECT
--drill_hole_id
id, planned_length/*, azim_nm, dip*/ FROM
--drilling_daily_reports
dh_shift_reports GROUP BY
--drill_hole_id
id, planned_length/*, azim_nm, dip*/) tmp) tmp1, (SELECT count(DISTINCT
--drill_hole_id
id) AS nb_sondages FROM
--drilling_daily_reports
dh_shift_reports) tmp2 WHERE nb_sondages_et_attributs-nb_sondages <> 0;

CREATE OR REPLACE VIEW checks.fichettes_infos_redondantes_incoherentes_quels_ouvrages AS
SELECT
--drill_hole_id
id, min(planned_length) AS min_planned_length, max(planned_length) AS max_planned_length /*, min(azim_nm) AS min_azim_nm, max(azim_nm) AS max_azim_nm, min(dip) AS min_dip, max(dip) AS max_dip*/ FROM
--drilling_daily_reports
dh_shift_reports GROUP BY
--drill_hole_id
id HAVING (count(DISTINCT planned_length)>1 /*OR count(DISTINCT azim_nm)>1 OR count(DISTINCT dip)>1*/);

CREATE OR REPLACE VIEW checks.fichettes_infos_incoherentes_heures AS
SELECT date,
--drill_hole_id
id, time_start, time_end FROM
--drilling_daily_reports
dh_shift_reports WHERE time_start>time_end;


CREATE OR REPLACE VIEW checks.fichettes_vs_collars_ouvrages_dans_fichettes_pas_collars AS
SELECT
--drill_hole_id
dh_shift_reports.id AS dh_shift_reports_id, dh_collars.id AS dh_collars_id FROM
--drilling_daily_reports
dh_shift_reports LEFT JOIN dh_collars ON (
--drilling_daily_reports
--drill_hole_id
dh_shift_reports.id = dh_collars.id) WHERE dh_collars.id IS NULL ORDER BY
--drill_hole_id
dh_shift_reports.id, dh_collars.id;

CREATE OR REPLACE VIEW checks.fichettes_longueurs_incoherentes AS
SELECT
--drill_hole_id
id, max_drilled_length, sum_drilled_length_during_shift FROM (SELECT
--drill_hole_id
id, max(drilled_length) AS max_drilled_length, sum(drilled_length_during_shift) AS sum_drilled_length_during_shift FROM
--drilling_daily_reports
dh_shift_reports GROUP BY
--drill_hole_id
id ORDER BY
--drill_hole_id
id) tmp WHERE max_drilled_length <> sum_drilled_length_during_shift ;

CREATE OR REPLACE VIEW checks.fichettes_vs_collars_longueurs_incoherentes AS
SELECT
--drill_hole_id
tmp.id, max_drilled_length, length
FROM
(SELECT
--drill_hole_id
id, max(drilled_length) AS max_drilled_length, sum(drilled_length_during_shift) AS sum_drilled_length_during_shift FROM
--drilling_daily_reports
dh_shift_reports GROUP BY
--drill_hole_id
dh_shift_reports.id ORDER BY
--drill_hole_id
dh_shift_reports.id) tmp
JOIN
dh_collars
ON
--(tmp.drill_hole_id = dh_collars.id)
(tmp.id = dh_collars.id)
WHERE
max_drilled_length <> length ;


CREATE OR REPLACE VIEW checks.fichettes_ouvrages_non_completed AS
SELECT
--drill_hole_id
id, max(completed::integer) FROM
--drilling_daily_reports
dh_shift_reports GROUP BY
--drill_hole_id
id HAVING max(completed::integer) <> 1;


--}}}


--les traces des sondages, pareil, pour un srid:{{{
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
--}}}

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

-- field observations
--geochemistry
--anomalies
--targets
--mines
/*  DEBUG  *** DEBUT DE TOUT CE QUI EST INVALIDÉ/PAS ENCORE FAIT ***
--POUBELLE {{{
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
--}}}

*/ --DEBUG FIN DE TOUT CE QUI EST INVALIDÉ

