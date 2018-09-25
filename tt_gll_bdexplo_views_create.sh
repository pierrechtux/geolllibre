echo "
BEGIN TRANSACTION;
CREATE VIEW field_photos AS SELECT field_photos.* FROM field_photos JOIN operation_active ON field_photos.opid = operation_active.opid;
CREATE VIEW dh_litho AS SELECT dh_litho.* FROM dh_litho JOIN operation_active ON dh_litho.opid = operation_active.opid;
CREATE VIEW dh_sampling_grades AS SELECT dh_sampling_grades.* FROM dh_sampling_grades JOIN operation_active ON dh_sampling_grades.opid = operation_active.opid;
CREATE VIEW shift_reports AS SELECT shift_reports.* FROM shift_reports JOIN operation_active ON shift_reports.opid = operation_active.opid;
CREATE VIEW baselines AS SELECT baselines.* FROM baselines JOIN operation_active ON baselines.opid = operation_active.opid;
CREATE VIEW lab_ana_results AS SELECT lab_ana_results.* FROM lab_ana_results JOIN operation_active ON lab_ana_results.opid = operation_active.opid;
CREATE VIEW dh_density AS SELECT dh_density.* FROM dh_density JOIN operation_active ON dh_density.opid = operation_active.opid;
CREATE VIEW dh_sampling_bottle_roll AS SELECT dh_sampling_bottle_roll.* FROM dh_sampling_bottle_roll JOIN operation_active ON dh_sampling_bottle_roll.opid = operation_active.opid;
CREATE VIEW dh_quicklog AS SELECT dh_quicklog.* FROM dh_quicklog JOIN operation_active ON dh_quicklog.opid = operation_active.opid;
CREATE VIEW dh_followup AS SELECT dh_followup.* FROM dh_followup JOIN operation_active ON dh_followup.opid = operation_active.opid;
CREATE VIEW dh_thinsections AS SELECT dh_thinsections.* FROM dh_thinsections JOIN operation_active ON dh_thinsections.opid = operation_active.opid;
CREATE VIEW field_observations AS SELECT field_observations.* FROM field_observations JOIN operation_active ON field_observations.opid = operation_active.opid;
CREATE VIEW dh_tech AS SELECT dh_tech.* FROM dh_tech JOIN operation_active ON dh_tech.opid = operation_active.opid;
CREATE VIEW formations_group_lithos AS SELECT formations_group_lithos.* FROM formations_group_lithos JOIN operation_active ON formations_group_lithos.opid = operation_active.opid;
CREATE VIEW lab_ana_batches_expedition AS SELECT lab_ana_batches_expedition.* FROM lab_ana_batches_expedition JOIN operation_active ON lab_ana_batches_expedition.opid = operation_active.opid;
CREATE VIEW grade_ctrl AS SELECT grade_ctrl.* FROM grade_ctrl JOIN operation_active ON grade_ctrl.opid = operation_active.opid;
CREATE VIEW geoch_sampling AS SELECT geoch_sampling.* FROM geoch_sampling JOIN operation_active ON geoch_sampling.opid = operation_active.opid;
CREATE VIEW gpy_mag_ground AS SELECT gpy_mag_ground.* FROM gpy_mag_ground JOIN operation_active ON gpy_mag_ground.opid = operation_active.opid;
CREATE VIEW index_geo_documentation AS SELECT index_geo_documentation.* FROM index_geo_documentation JOIN operation_active ON index_geo_documentation.opid = operation_active.opid;
CREATE VIEW lab_ana_batches_reception AS SELECT lab_ana_batches_reception.* FROM lab_ana_batches_reception JOIN operation_active ON lab_ana_batches_reception.opid = operation_active.opid;
CREATE VIEW lab_ana_columns_definition AS SELECT lab_ana_columns_definition.* FROM lab_ana_columns_definition JOIN operation_active ON lab_ana_columns_definition.opid = operation_active.opid;
CREATE VIEW geoch_sampling_grades AS SELECT geoch_sampling_grades.* FROM geoch_sampling_grades JOIN operation_active ON geoch_sampling_grades.opid = operation_active.opid;
CREATE VIEW lex_codes AS SELECT lex_codes.* FROM lex_codes JOIN operation_active ON lex_codes.opid = operation_active.opid;
CREATE VIEW lex_datasource AS SELECT lex_datasource.* FROM lex_datasource JOIN operation_active ON lex_datasource.opid = operation_active.opid;
CREATE VIEW licences AS SELECT licences.* FROM licences JOIN operation_active ON licences.opid = operation_active.opid;
CREATE VIEW lab_ana_qaqc_results AS SELECT lab_ana_qaqc_results.* FROM lab_ana_qaqc_results JOIN operation_active ON lab_ana_qaqc_results.opid = operation_active.opid;
CREATE VIEW surface_samples_grades AS SELECT surface_samples_grades.* FROM surface_samples_grades JOIN operation_active ON surface_samples_grades.opid = operation_active.opid;
CREATE VIEW occurrences_recup_depuis_dump AS SELECT occurrences_recup_depuis_dump.* FROM occurrences_recup_depuis_dump JOIN operation_active ON occurrences_recup_depuis_dump.opid = operation_active.opid;
CREATE VIEW qc_sampling AS SELECT qc_sampling.* FROM qc_sampling JOIN operation_active ON qc_sampling.opid = operation_active.opid;
CREATE VIEW field_sampling AS SELECT field_sampling.* FROM field_sampling JOIN operation_active ON field_sampling.opid = operation_active.opid;
CREATE VIEW geometry_columns_old AS SELECT geometry_columns_old.* FROM geometry_columns_old JOIN operation_active ON geometry_columns_old.opid = operation_active.opid;
CREATE VIEW spatial_ref_sys_old AS SELECT spatial_ref_sys_old.* FROM spatial_ref_sys_old JOIN operation_active ON spatial_ref_sys_old.opid = operation_active.opid;
CREATE VIEW survey_lines AS SELECT survey_lines.* FROM survey_lines JOIN operation_active ON survey_lines.opid = operation_active.opid;
CREATE VIEW dh_struct_measures AS SELECT dh_struct_measures.* FROM dh_struct_measures JOIN operation_active ON dh_struct_measures.opid = operation_active.opid;
CREATE VIEW field_observations_struct_measures AS SELECT field_observations_struct_measures.* FROM field_observations_struct_measures JOIN operation_active ON field_observations_struct_measures.opid = operation_active.opid;
CREATE VIEW mag_declination AS SELECT mag_declination.* FROM mag_declination JOIN operation_active ON mag_declination.opid = operation_active.opid;
CREATE VIEW qc_standards AS SELECT qc_standards.* FROM qc_standards JOIN operation_active ON qc_standards.opid = operation_active.opid;
CREATE VIEW doc_postgeol_table_categories AS SELECT doc_postgeol_table_categories.* FROM doc_postgeol_table_categories JOIN operation_active ON doc_postgeol_table_categories.opid = operation_active.opid;
CREATE VIEW occurrences AS SELECT occurrences.* FROM occurrences JOIN operation_active ON occurrences.opid = operation_active.opid;
CREATE VIEW ancient_workings AS SELECT ancient_workings.* FROM ancient_workings JOIN operation_active ON ancient_workings.opid = operation_active.opid;
CREATE VIEW topo_points AS SELECT topo_points.* FROM topo_points JOIN operation_active ON topo_points.opid = operation_active.opid;
CREATE VIEW geoch_ana AS SELECT geoch_ana.* FROM geoch_ana JOIN operation_active ON geoch_ana.opid = operation_active.opid;
CREATE VIEW lex_standard AS SELECT lex_standard.* FROM lex_standard JOIN operation_active ON lex_standard.opid = operation_active.opid;
CREATE VIEW dh_core_boxes AS SELECT dh_core_boxes.* FROM dh_core_boxes JOIN operation_active ON dh_core_boxes.opid = operation_active.opid;
CREATE VIEW dh_radiometry AS SELECT dh_radiometry.* FROM dh_radiometry JOIN operation_active ON dh_radiometry.opid = operation_active.opid;
CREATE VIEW dh_devia AS SELECT dh_devia.* FROM dh_devia JOIN operation_active ON dh_devia.opid = operation_active.opid;
CREATE VIEW dh_mineralised_intervals AS SELECT dh_mineralised_intervals.* FROM dh_mineralised_intervals JOIN operation_active ON dh_mineralised_intervals.opid = operation_active.opid;
CREATE VIEW dh_collars AS SELECT dh_collars.* FROM dh_collars JOIN operation_active ON dh_collars.opid = operation_active.opid;
CREATE VIEW dh_resistivity AS SELECT dh_resistivity.* FROM dh_resistivity JOIN operation_active ON dh_resistivity.opid = operation_active.opid;
CREATE VIEW dh_devia_runs_xyz AS SELECT dh_devia_runs_xyz.* FROM dh_devia_runs_xyz JOIN operation_active ON dh_devia_runs_xyz.opid = operation_active.opid;
CREATE VIEW dh_core_boxes_runs_xyz AS SELECT dh_core_boxes_runs_xyz.* FROM dh_core_boxes_runs_xyz JOIN operation_active ON dh_core_boxes_runs_xyz.opid = operation_active.opid;
CREATE VIEW dh_density_runs_xyz AS SELECT dh_density_runs_xyz.* FROM dh_density_runs_xyz JOIN operation_active ON dh_density_runs_xyz.opid = operation_active.opid;
CREATE VIEW dh_litho_runs_xyz AS SELECT dh_litho_runs_xyz.* FROM dh_litho_runs_xyz JOIN operation_active ON dh_litho_runs_xyz.opid = operation_active.opid;
CREATE VIEW dh_mineralised_intervals_runs_xyz AS SELECT dh_mineralised_intervals_runs_xyz.* FROM dh_mineralised_intervals_runs_xyz JOIN operation_active ON dh_mineralised_intervals_runs_xyz.opid = operation_active.opid;
CREATE VIEW dh_quicklog_runs_xyz AS SELECT dh_quicklog_runs_xyz.* FROM dh_quicklog_runs_xyz JOIN operation_active ON dh_quicklog_runs_xyz.opid = operation_active.opid;
CREATE VIEW dh_radiometry_runs_xyz AS SELECT dh_radiometry_runs_xyz.* FROM dh_radiometry_runs_xyz JOIN operation_active ON dh_radiometry_runs_xyz.opid = operation_active.opid;
CREATE VIEW dh_resistivity_runs_xyz AS SELECT dh_resistivity_runs_xyz.* FROM dh_resistivity_runs_xyz JOIN operation_active ON dh_resistivity_runs_xyz.opid = operation_active.opid;
CREATE VIEW dh_sampling_bottle_roll_runs_xyz AS SELECT dh_sampling_bottle_roll_runs_xyz.* FROM dh_sampling_bottle_roll_runs_xyz JOIN operation_active ON dh_sampling_bottle_roll_runs_xyz.opid = operation_active.opid;
CREATE VIEW dh_sampling_grades_runs_xyz AS SELECT dh_sampling_grades_runs_xyz.* FROM dh_sampling_grades_runs_xyz JOIN operation_active ON dh_sampling_grades_runs_xyz.opid = operation_active.opid;
CREATE VIEW dh_struct_measures_runs_xyz AS SELECT dh_struct_measures_runs_xyz.* FROM dh_struct_measures_runs_xyz JOIN operation_active ON dh_struct_measures_runs_xyz.opid = operation_active.opid;
CREATE VIEW dh_tech_runs_xyz AS SELECT dh_tech_runs_xyz.* FROM dh_tech_runs_xyz JOIN operation_active ON dh_tech_runs_xyz.opid = operation_active.opid;
CREATE VIEW dh_thinsections_runs_xyz AS SELECT dh_thinsections_runs_xyz.* FROM dh_thinsections_runs_xyz JOIN operation_active ON dh_thinsections_runs_xyz.opid = operation_active.opid;
CREATE VIEW field_sampling_ana AS SELECT field_sampling_ana.* FROM field_sampling_ana JOIN operation_active ON field_sampling_ana.opid = operation_active.opid;
CREATE VIEW mine_plant_daily_production AS SELECT mine_plant_daily_production.* FROM mine_plant_daily_production JOIN operation_active ON mine_plant_daily_production.opid = operation_active.opid;

-- 4. vues pour postgis:{{{

-- 2014_02_01__17_55_45
CREATE VIEW        dh_collars_points                              AS SELECT *, GeomFromewkt('SRID='|| srid || ';POINT('|| x || ' ' || y || ' ' || z || ')') FROM        dh_collars;
CREATE VIEW        dh_traces_3d                                   AS SELECT *, GeomFromEWKT('SRID=' || srid || ';LINESTRING (' || x || ' ' || y || ' ' || z || ', ' || x1 || ' ' || y1 || ' ' || z1 || ')') FROM (SELECT *, x + length * cos((dip_hz / 180) * pi()) * sin((azim_ng / 180) * pi()) AS x1, y + length * cos((dip_hz / 180) * pi()) * cos((azim_ng / 180) * pi()) AS y1, z - length * sin((dip_hz / 180) * pi()) AS z1 FROM        dh_collars) tmp ORDER BY tmp.id;
CREATE VIEW        field_observations_points                      AS SELECT *, GeomFromewkt('SRID=' || srid || ';POINT ('|| x || ' ' || y || ' ' || z || ')') FROM        field_observations;
CREATE VIEW        geoch_sampling_grades_points                   AS SELECT *, GeomFromewkt('SRID= 20136; POINT ('|| x || ' ' || y || ' ' || z || ')') FROM        geoch_sampling_grades;
CREATE VIEW        index_geo_documentation_rectangles             AS SELECT id, title, lat_min, lat_max, lon_min, lon_max, geomfromtext('RECTANGLE (' || lon_min || ' ' || lat_min || ' ' || lon_max || ' ' || lat_max || '), 20136') AS geomfromtext FROM        index_geo_documentation;
CREATE VIEW        licences_quadrangles                           AS SELECT *, geomfromewkt('SRID=4326;POLYGON(' || lon_min || ' ' || lat_max || ',' || lon_max || ' ' || lat_max || ',' || lon_max || ' ' || lat_min || ',' || lon_min || ' ' || lat_min || ',' || lon_min || ' ' || lat_max || ')') AS geomfromewkt FROM        licences ORDER BY licences.licence_name;
CREATE VIEW        operations_quadrangles                         AS SELECT *, GeomFromewkt('SRID=4326;POLYGON(('||lon_min||' '||lat_max||','||lon_max||' '||lat_max||','||lon_max||' '||lat_min||','||lon_min||' '||lat_min||','||lon_min||' '||lat_max||'))') FROM        operations ORDER BY operation;
CREATE VIEW        surface_samples_grades_points                  AS SELECT *, GeomFromewkt('SRID=' || srid || '; POINT ('|| x || ' ' || y || ' ' || 0 || ')') FROM        surface_samples_grades;
CREATE VIEW        dh_collars_points_marrec                       AS SELECT *, GeomFromewkt('POINT('|| x_local  || ' ' || y_local || ' )') FROM        dh_collars WHERE x_local IS NOT NULL AND y_local IS NOT NULL;
CREATE VIEW        petro_mineralo_study_field_observations_points AS SELECT * FROM        field_observations_points WHERE sample_id IN ('PCh854', 'PCh856', 'PCh865', 'PCh873', 'PCh875A, PCh875B') ORDER BY obs_id;
CREATE VIEW        petro_mineralo_study_dh_collars                AS SELECT * FROM        dh_collars_points WHERE id IN ('S430', 'W08-573', 'W08-597', 'W08-593', 'W08-598', 'W08-598', 'W08-601', 'GB09-889', 'GB09-889', 'GB09-893') ORDER BY id;

CREATE VIEW public.dh_collars_points_latlon                       AS SELECT *, ST_Transform( geomfromewkt( 'SRID=' || srid || '; POINT (' || x || ' ' || y || ')') , 4326) AS geometry FROM public.dh_collars WHERE x IS NOT NULL AND y IS NOT NULL AND srid IS NOT NULL AND srid <> 999;
-- les règles associées: {{{
CREATE RULE dh_collars_points_latlon_rule_upd AS ON UPDATE TO public.dh_collars_points_latlon
 DO INSTEAD
  UPDATE public.dh_collars
   SET 
    id = new.id,shid = new.shid,location = new.location,profile = new.profile,srid = new.srid,x = new.x ,y = new.y ,z = new.z ,azim_ng = new.azim_ng,azim_nm = new.azim_nm,dip_hz = new.dip_hz,dh_type = new.dh_type,date_start = new.date_start,contractor = new.contractor,geologist = new.geologist,length = new.length,nb_samples = new.nb_samples,comments = new.comments,completed = new.completed,numauto = new.numauto,date_completed = new.date_completed,opid = new.opid,purpose = new.purpose,x_local = new.x_local,y_local = new.y_local,z_local = new.z_local,accusum = new.accusum,id_pject = new.id_pject,x_pject = new.x_pject,y_pject = new.y_pject,z_pject = new.z_pject,topo_survey_type = new.topo_survey_type,datasource = new.datasource
   WHERE numauto = old.numauto;

CREATE RULE dh_collars_points_latlon_rule_del AS ON DELETE TO public.dh_collars_points_latlon
 DO INSTEAD
  DELETE FROM public.dh_collars
   WHERE numauto = old.numauto;

CREATE RULE dh_collars_points_latlon_rule_ins AS ON INSERT TO public.dh_collars_points_latlon
 DO INSTEAD 
  INSERT INTO public.dh_collars (id,shid,location,profile,srid,x,y,z,azim_ng,azim_nm,dip_hz,dh_type,date_start,contractor,geologist,length,nb_samples,comments,completed,date_completed,opid,purpose,x_local,y_local,z_local,accusum,id_pject,x_pject,y_pject,z_pject,topo_survey_type,datasource)
  VALUES (new.id,new.shid,new.location,new.profile,new.srid,new.x,new.y,new.z,new.azim_ng,new.azim_nm,new.dip_hz,new.dh_type,new.date_start,new.contractor,new.geologist,new.length,new.nb_samples,new.comments,new.completed,new.date_completed,new.opid,new.purpose,new.x_local,new.y_local,new.z_local,new.accusum,new.id_pject,new.x_pject,new.y_pject,new.z_pject,new.topo_survey_type,new.datasource );
--}}}

CREATE VIEW public.field_observations_points AS SELECT *, GeomFromewkt('SRID=' || srid || ';POINT ('|| x || ' ' || y || ' ' || z || ')') FROM public.field_observations;
-- les règles associées: {{{

CREATE RULE field_observations_rule_update_no_geom as on UPDATE TO public.field_observations_points
--WHERE geomfromewkt = NEW.geomfromewkt 
WHERE OLD.numauto = NEW.numauto 
DO INSTEAD UPDATE public.field_observations 
SET opid = NEW.opid,
year = NEW.year,
obs_id = NEW.obs_id,
date = NEW.date,
waypoint_name = NEW.waypoint_name,
x = NEW.x,
y = NEW.y,
z = NEW.z,
description = NEW.description,
code_litho = NEW.code_litho,
code_unit = NEW.code_unit,
srid = NEW.srid,
geologist = NEW.geologist,
icon_descr = NEW.icon_descr,
comments = NEW.comments,
sample_id = NEW.sample_id,
datasource = NEW.datasource,
photos = NEW.photos,
audio = NEW.audio,
timestamp_epoch_ms = NEW.timestamp_epoch_ms
WHERE NEW.numauto = OLD.numauto;

CREATE RULE field_observations_points_upd AS ON UPDATE TO public.field_observations_points 
 DO INSTEAD 
  UPDATE public.field_observations 
   SET 
    opid = new.opid, 
    year = new.year, 
    obs_id = new.obs_id, 
    date = new.date, 
    waypoint_name = new.waypoint_name, 
    x = new.x, 
    y = new.y, 
    z = new.z, 
    description = new.description, 
    code_litho = new.code_litho, 
    code_unit = new.code_unit, 
    srid = new.srid, 
    geologist = new.geologist, 
    icon_descr = new.icon_descr, 
    comments = new.comments, 
    sample_id = new.sample_id, 
    datasource = new.datasource, 
    photos = new.photos, 
    audio = new.audio, 
    timestamp_epoch_ms = new.timestamp_epoch_ms
  WHERE numauto = old.numauto;

CREATE RULE field_observations_points_del AS ON DELETE TO public.field_observations_points 
 DO INSTEAD 
  DELETE FROM public.field_observations 
   WHERE numauto = OLD.numauto;

CREATE RULE field_observations_points_ins_xy AS 
 ON INSERT TO public.field_observations_points 
 WHERE x IS NOT NULL AND y IS NOT NULL AND geomfromewkt IS NULL 
  DO INSTEAD 
   INSERT INTO public.field_observations (opid,year,obs_id,date,waypoint_name,x,y,z,description,code_litho,code_unit,srid,geologist,icon_descr,comments,sample_id,datasource,photos,audio,timestamp_epoch_ms)
    VALUES (new.opid,new.year,new.obs_id,new.date,new.waypoint_name,new.x,new.y,new.z,new.description,new.code_litho,new.code_unit,new.srid,new.geologist,new.icon_descr,new.comments,new.sample_id,new.datasource,new.photos,new.audio,new.timestamp_epoch_ms);

CREATE RULE field_observations_points_ins_geom AS 
 ON INSERT TO public.field_observations_points 
 WHERE x IS NULL AND y IS NULL AND geomfromewkt IS NOT NULL 
  DO INSTEAD 
   INSERT INTO public.field_observations (opid,year,obs_id,date,waypoint_name,x,y,z,description,code_litho,code_unit,srid,geologist,icon_descr,comments,sample_id,datasource,photos,audio,timestamp_epoch_ms)
    VALUES (new.opid,new.year,new.obs_id,new.date,new.waypoint_name,ST_X(new.geomfromewkt),ST_Y(new.geomfromewkt),ST_Z(new.geomfromewkt),new.description,new.code_litho,new.code_unit,new.srid,new.geologist,new.icon_descr,new.comments,new.sample_id,new.datasource,new.photos,new.audio,new.timestamp_epoch_ms);
--}}}

--DROP cascade sur vue dh_mineralised_intervals0_traces_3d/*{{{*/
CREATE OR REPLACE VIEW        dh_mineralised_intervals2_traces_3d AS 
SELECT *, 
GeomFromEWKT('SRID=' || srid || ';LINESTRING (' || 
x1 || ' ' || 
y1 || ' ' || 
z1 || ', ' || 
x2 || ' ' || 
y2 || ' ' || 
z2 || ')') 
FROM 
(
SELECT 
dh_mineralised_intervals.opid, dh_mineralised_intervals.id, srid, x, y, z, azim_ng, dip_hz, depfrom, depto, dh_mineralised_intervals.mine, avau, stva, accu, 
dh_collars.id || ': ' || 
replace(to_char(depfrom, 'FM99990.99'),'.','')
|| '-' || 
replace(to_char(depto, 'FM99990.99'),'.','')
|| 'm => ' || stva AS mineralisation_stretch_value_label, 
dh_mineralised_intervals.numauto, 
x + depfrom * cos((dip_hz / 180) * pi()) * sin((azim_ng / 180) * pi())   AS x1, 
y + depfrom * cos((dip_hz / 180) * pi()) * cos((azim_ng / 180) * pi())   AS y1, 
z - depfrom * sin((dip_hz / 180) * pi())                                 AS z1, 
x + depto * cos((dip_hz / 180) * pi()) * sin((azim_ng / 180) * pi()) AS x2, 
y + depto * cos((dip_hz / 180) * pi()) * cos((azim_ng / 180) * pi())     AS y2, 
z - depto * sin((dip_hz / 180) * pi())                                   AS z2 
FROM dh_mineralised_intervals 
JOIN 
dh_collars 
ON dh_mineralised_intervals.opid = dh_collars.opid AND dh_mineralised_intervals.id = dh_collars.id
WHERE mine = 0 
--AND dh_collars.opid = 18 
) tmp
ORDER BY id, depfrom, depto, mine;

/*}}}*/

CREATE VIEW        topo_points_points AS
SELECT *, geomfromewkt('POINT(' || topo_points.x || ' ' || topo_points.y || ' ' || topo_points.z || ')') AS geometry FROM topo_points;

-- pour voir les points de sondages prévus par rapport à là où ils ont réellement été réalisés:
CREATE VIEW dh_collars_diff_project_actual_line                   AS SELECT *, GeomFromEWKT('SRID=' || srid || ';LINESTRING (' || x_pject || ' ' || y_pject || ' ' || z_pject || ', ' || x || ' ' || y || ' ' || z || ')') FROM dh_collars WHERE x_pject IS NOT NULL AND y_pject IS NOT NULL AND z_pject IS NOT NULL;


--}}}
-- 3. des vues genre alias pratique: {{{
--CREATE VIEW dh_litho_custom AS SELECT id, depfrom, depto, code1 AS codelitho, code2 AS codestrati, description, code3 AS oxidation, value1 AS deformation, value2 AS alteration, code4 AS water FROM dh_litho;

--les échantillons avec teneurs (au6 = au maxi), et graphique des teneurs en ascii-art:
CREATE VIEW dh_sampling_grades_graph_au_6 AS 
SELECT opid, id, depfrom, depto, sample_id, au1_ppm, au2_ppm, au6_ppm, weight_kg, core_loss_cm, 
repeat('#', (au6_ppm*5)::integer) AS graph_au_6
FROM dh_sampling_grades 
--WHERE id IN (SELECT id FROM dh_dernieres_analyses)
ORDER BY opid, id, depto;



--les teneurs et les passes minéralisées (de classe 0) raboutées:/*{{{*/
CREATE VIEW dh_sampling_mineralised_intervals_graph_au6 AS

SELECT 
tmp.opid, 
tmp.id, 
tmp.depfrom,
tmp.depto, 
mineralised_interval,
sample_id,
weight_kg,
core_loss_cm,
au6_ppm AS aumaxi_ppm, 
graph_au_6 AS graph_aumaxi
--start_interval, end_interval
FROM 
 (SELECT 
  dh_sampling_grades_graph_au_6.*, 
  CASE 
   WHEN (dh_mineralised_intervals.depfrom = dh_sampling_grades_graph_au_6.depfrom) THEN rpad('>=== ' || stva || ' (accu: ' || accu::varchar || ') ', 50, '=')
   WHEN (dh_mineralised_intervals.depto   = dh_sampling_grades_graph_au_6.depto  ) THEN '>=================================================' 
   WHEN (dh_mineralised_intervals.mine IS NOT NULL)                                THEN ' |'
   ELSE ''
  END AS mineralised_interval,
  dh_sampling_grades_graph_au_6.depto AS pied_passe_min 
 FROM 
  dh_sampling_grades_graph_au_6 
 LEFT JOIN 
  (SELECT * FROM dh_mineralised_intervals WHERE mine = 0) AS dh_mineralised_intervals 
 ON 
  (
  dh_sampling_grades_graph_au_6.opid = dh_mineralised_intervals.opid AND 
  dh_sampling_grades_graph_au_6.id = dh_mineralised_intervals.id AND 
  dh_sampling_grades_graph_au_6.depto <= dh_mineralised_intervals.depto AND 
  dh_sampling_grades_graph_au_6.depfrom >= dh_mineralised_intervals.depfrom AND 
  dh_mineralised_intervals.mine = 0)
 ) tmp
LEFT JOIN 
 (
 SELECT 
  opid, id, depfrom, depto, avau, stva, accu 
 FROM 
 (SELECT * FROM dh_mineralised_intervals WHERE mine = 0) AS dh_mineralised_intervals 
 ) tmpmine 
ON 
 (tmp.opid = tmpmine.opid AND
  tmp.id = tmpmine.id AND
  tmp.pied_passe_min = tmpmine.depto
 )
ORDER BY tmp.opid, tmp.id, tmp.depto;



--/*}}}*/


--}}}
-- 5. vues des analyses en colonnes:{{{

-- la fonction qui va bien: {{{
/*
CREATE OR REPLACE FUNCTION create_crosstab_view (eavsql_inarg varchar, resview varchar, rowid varchar, colid varchar, val varchar, agr varchar) RETURNS pg_catalog.void AS
\$body\$
DECLARE
    casesql varchar;
    dynsql varchar;    
    r record;
BEGIN   
dynsql='';
for r in
      select * from pg_views where lower(viewname) = lower(resview)
  loop
      execute 'DROP VIEW ' || resview;
  end loop;   
casesql='SELECT DISTINCT ' || colid || ' AS v from (' || eavsql_inarg || ') eav ORDER BY ' || colid;
FOR r IN EXECUTE casesql
  Loop
    dynsql = dynsql || ', ' || agr || '(CASE WHEN ' || colid || E'=\'' || r.v::varchar || E'\' THEN ' || val || ' ELSE NULL END) AS ' || agr || '_' || r.v;
  END LOOP;
dynsql = 'CREATE VIEW ' || resview || ' AS SELECT ' || rowid || dynsql || ' from (' || eavsql_inarg || ') eav GROUP BY ' || rowid;
EXECUTE dynsql;
END
\$body\$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;
*/
--}}}
--  Ça semble bien ne plus fonctionner, le 2014_11_23__21_23_20 => cancellé

--une vue temporaire pour avoir analyte, unité et scheme dans le libellé pour crosstabber dessus, en allant chercher le libellé des colonnes dans une table annexe, lab_ana_columns_definition:

/*
CREATE OR REPLACE VIEW tmp_lab_ana_results AS 
SELECT lab_ana_results.opid, sample_id, colid, 
(CASE WHEN value_num < 0 THEN 0 ELSE value_num END) AS value_num 
FROM lab_ana_results 
JOIN lab_ana_columns_definition 
ON 
(
lab_ana_results.opid    = lab_ana_columns_definition.opid    AND
lab_ana_results.analyte = lab_ana_columns_definition.analyte AND 
lab_ana_results.scheme  = lab_ana_columns_definition.scheme  AND 
lab_ana_results.unit    = lab_ana_columns_definition.unit
);
*/

/*
--on crosstabbe sur cette vue:
SELECT create_crosstab_view ('SELECT * FROM tmp_lab_ana_results', 'lab_ana_results_columns_avg',   'sample_id', 'colid', 'value_num', 'avg'  );
SELECT create_crosstab_view ('SELECT * FROM tmp_lab_ana_results', 'lab_ana_results_columns_min',   'sample_id', 'colid', 'value_num', 'min'  );
SELECT create_crosstab_view ('SELECT * FROM tmp_lab_ana_results', 'lab_ana_results_columns_max',   'sample_id', 'colid', 'value_num', 'max'  );
SELECT create_crosstab_view ('SELECT * FROM tmp_lab_ana_results', 'lab_ana_results_columns_count', 'sample_id', 'colid', 'value_num', 'count');
*/

--@#attention aux échantillons qui ont leur sample_id commun à 2 opid!!

--CREATE VIEW lab_ana_results_sel AS SELECT * FROM lab_ana_results WHERE orderno = 'VMS_001';
--}}}
-- 6. vues des échantillons et analyses en colonnes: {{{
--CREATE VIEW dh_sampling_ana AS SELECT opid, id, depfrom, depto, lab_ana_results_columns_avg.* FROM dh_sampling_grades JOIN lab_ana_results_columns_avg ON (dh_sampling_grades.sample_id = lab_ana_results_columns_avg.sample_id);
--cancellé, le 2014_11_23__21_23_20
--}}}
-- 8. les sondages ouverts:/*{{{*/

--sondages ouverts en pied en Au:{{{
CREATE VIEW dh_sampling_grades_open_ended_au_tail
 AS
SELECT id, max(length) AS length, max(depto) AS depto FROM (
SELECT dh_sampling_grades.*, dh_collars.length FROM 
dh_sampling_grades JOIN dh_collars ON 
(dh_sampling_grades.opid = dh_collars.opid AND dh_sampling_grades.id = dh_collars.id), 
(SELECT 0.5 AS teneur_coupure) AS tmp_tc, 
(SELECT 5 AS sortir_d_au_moins) AS tmp_sortir
WHERE 
dh_type NOT IN ('PIT', 'TR', 'CS') AND
GREATEST(au1_ppm, au2_ppm, au3_ppm, au4_ppm, au5_ppm, au6_ppm) >= teneur_coupure
AND 
(
length > sortir_d_au_moins --quand même, ne pas prendre les sondages plus courts que la longueur minimale de sortie...
AND
length - depto < sortir_d_au_moins
)
) AS tmp GROUP BY id


ORDER BY id, depto;
--}}}
--sondages ouverts en tête en Au:{{{



--DROP VIEW dh_sampling_grades_open_ended_au_top CASCADE;
CREATE VIEW dh_sampling_grades_open_ended_au_top
 AS
SELECT id, length, min(depto) AS depto FROM (
SELECT dh_sampling_grades.*, dh_collars.length FROM 
dh_sampling_grades JOIN dh_collars ON 
(dh_sampling_grades.opid = dh_collars.opid AND dh_sampling_grades.id = dh_collars.id), 
(SELECT 0.5 AS teneur_coupure) AS tmp_tc, 
(SELECT 5 AS sortir_d_au_moins) AS tmp_sortir
WHERE 
dh_type NOT IN ('PIT', 'TR', 'CS') AND
GREATEST(au1_ppm, au2_ppm, au3_ppm, au4_ppm, au5_ppm, au6_ppm) >= teneur_coupure
AND 
(
length > sortir_d_au_moins --quand même, ne pas prendre les sondages plus courts que la longueur minimale de sortie...
AND
depfrom        < sortir_d_au_moins
)
) AS tmp GROUP BY id, length, depto
ORDER BY id, depto;
--}}}

--/*}}}*/
-- 7. pour GDM: les vues sont basées sur la vue gdm_selection: {{{
-- définissons-la:{{{
CREATE OR REPLACE VIEW gdm.gdm_selection AS 
SELECT dh_collars.opid, id FROM public.dh_collars JOIN operation_active ON (dh_collars.opid = operation_active.opid) 
--WHERE
--(NOT (x < 1000 OR y < 10000) 
-- -- AND location IN (
-- -- 'GBEITOUO' 
-- -- ,'WALTER'    
-- -- ,'GBEITOUO1' 
-- -- ,'GBEITOUO2' 
-- -- ,'BAKATOUO'  
-- -- ,'DAAPLEU'   
-- -- ,'DAAPLEUSW' 
-- -- ,'DAHA'      
-- -- ,'DIABYDOUGOU'
-- -- ,'FLOLEU'    
-- -- ,'FLOTOUO_ZIA'
-- -- ,'ITY_FLAT'  
-- -- ,'ITY_VILLAGE'
-- -- ,'MEANDRE'   
-- -- ,'MLAMBO'    
-- -- ,'MORGAN'    
-- -- ,'MORGAN-EXT'
-- -- ,'MT_ITY'    
-- -- ,'PLAQ'      
-- -- ,'TIAPLEU'   
-- -- ,'TONTOUO'   
-- -- ,'YACETOUO'  
-- -- ,'ZIA'       
-- -- ,'ZYA EXT'   
-- -- ,''
-- -- )
-- )
;

--}}}
--deviations:{{{
CREATE OR REPLACE VIEW gdm.gdm_dh_devia AS 
/*
SELECT 
dh_collars.id, dh_collars.x, dh_collars.y, dh_collars.z, length, dh_collars.azim_ng AS azim_ng_collar, dh_collars.dip_hz AS dip_collar, 
0 AS depto, dh_collars.azim_ng, dh_collars.dip_hz 
FROM gdm.gdm_selection JOIN dh_collars ON (gdm_selection.opid = dh_collars.opid AND gdm_selection.location = dh_collars.location) 
UNION
*/
(
SELECT 
 dh_collars.id, x, y, z, length, azim_ng AS azim_ng_collar, dip_hz AS dip_collar, 
 length AS depto, azim_ng, dip_hz 
FROM 
 dh_collars 
 JOIN 
 gdm.gdm_selection 
 ON 
  (gdm_selection.opid = dh_collars.opid AND gdm_selection.id = dh_collars.id) 
WHERE dh_collars.id NOT IN 
(
SELECT DISTINCT id/*, depto, azim_ng, dip_hz, comments*/ FROM dh_devia WHERE (depto > 0 AND valid)
) /*AS devia_downhole*/
--LEFT OUTER JOIN dh_devia ON (dh_collars.opid = dh_devia.opid AND dh_collars.id = dh_devia.id) WHERE dh_devia.id IS NULL
)
UNION 
(
SELECT 
 dh_devia.id, x, y, z, length, dh_collars.azim_ng AS azim_ng_collar, dh_collars.dip_hz AS dip_collar, 
 depto, dh_devia.azim_ng, dh_devia.dip_hz
FROM
 (
  dh_collars 
  JOIN 
  gdm.gdm_selection 
  ON 
   (gdm_selection.opid = dh_collars.opid AND gdm_selection.id = dh_collars.id) 
  JOIN 
  dh_devia 
  ON 
   (dh_collars.opid = dh_devia.opid AND dh_collars.id = dh_devia.id)
 ) 
WHERE 
 dh_devia.azim_ng IS NOT NULL 
 AND 
 dh_devia.dip_hz IS NOT NULL
 AND
 dh_devia.depto > 0
 AND
 (
  (valid OR valid IS NULL)
  --OR survey_name ILIKE 'Survey_%-out'
 )
)
ORDER BY id, depto;

--}}}
--lithologies:{{{
CREATE VIEW gdm.gdm_dh_litho AS 
SELECT 
dh_collars.id, dh_collars.location, dh_collars.x, dh_collars.y, dh_collars.z, dh_collars.azim_ng, dh_collars.dip_hz, dh_collars.length, 
dh_litho.depfrom, dh_litho.depto, dh_litho.code1, dh_litho.code2, dh_litho.code3, dh_litho.code4, dh_litho.value1, dh_litho.value2, dh_litho.value3, dh_litho.value4, dh_litho.description 
FROM (
gdm.gdm_selection 
JOIN 
dh_collars 
ON (gdm_selection.opid = dh_collars.opid AND gdm_selection.id = dh_collars.id) 
JOIN 
dh_litho 
ON (dh_collars.opid = dh_litho.opid AND dh_collars.id = dh_litho.id)) 
ORDER BY dh_collars.id, dh_litho.depto;
--}}}
--échantillons et teneurs => annulée:{{{
--}}}

--échantillons et teneurs, via dh_sampling_grades: {{{

CREATE VIEW gdm.gdm_dh_sampling_grades AS 
 SELECT dh_collars.id, dh_collars.x, dh_collars.y, dh_collars.z, dh_collars.length, 
        dh_sampling_grades_nodup.depfrom, dh_sampling_grades_nodup.depto, 
        /*grade_au_cn_smi, 
        grade_au_tot_smi, 
        -- marche pas: grade_au_cn_smi_repeat, 
        grade_au_cn_smi_dup, grade_au_sgs1, 
        -- marche pas: grade_au_sgs2, 
        grade_au_fa_als, grade_au_resource */
        au1_ppm, au2_ppm, au3_ppm, au4_ppm, au5_ppm, au6_ppm
 FROM 
  gdm.gdm_selection 
 JOIN 
  dh_collars 
 ON 
  (gdm_selection.opid = dh_collars.opid AND gdm_selection.id = dh_collars.id) 
 JOIN 
  (SELECT * FROM dh_sampling_grades WHERE sample_type IS NULL OR sample_type <> 'DUP') 
  AS dh_sampling_grades_nodup 
 ON 
  (dh_collars.id = dh_sampling_grades_nodup.id) 
 ORDER BY dh_sampling_grades_nodup.id, dh_sampling_grades_nodup.depto;

--}}}

--radiométrie: {{{

CREATE VIEW gdm_dh_radiometry AS 
 SELECT dh_collars.id, dh_collars.x, dh_collars.y, dh_collars.z, dh_collars.length, 
        dh_radiometry.depfrom, dh_radiometry.depto, dh_radiometry.probe, dh_radiometry.radiometry AS radiom
 FROM 
  gdm.gdm_selection 
 JOIN 
  dh_collars 
 ON 
  (gdm_selection.opid = dh_collars.opid AND gdm_selection.id = dh_collars.id) 
 JOIN 
  dh_radiometry
 ON 
  (dh_collars.id = dh_radiometry.id) 
 ORDER BY dh_radiometry.id, dh_radiometry.depto;


--}}}

--sondages ouverts:/*{{{*/
--Les sondages ouverts en tête en Au: {{{
CREATE OR REPLACE VIEW gdm.gdm_dh_sampling_grades_open_ended_au_top AS 
SELECT gdm_dh_sampling_grades.* 
FROM 
gdm.gdm_dh_sampling_grades 
JOIN 
dh_sampling_grades_open_ended_au_top 
ON 
--gdm_dh_sampling_grades.opid = dh_sampling_grades_open_ended_au_top.opid 
--AND 
gdm_dh_sampling_grades.id = dh_sampling_grades_open_ended_au_top.id 
AND gdm_dh_sampling_grades.depto = dh_sampling_grades_open_ended_au_top.depto;
---}}}
--Les sondages ouverts en pied en Au: {{{
CREATE OR REPLACE VIEW gdm.gdm_dh_sampling_grades_open_ended_au_tail AS 
SELECT gdm_dh_sampling_grades.* 
FROM 
gdm.gdm_dh_sampling_grades 
JOIN 
dh_sampling_grades_open_ended_au_tail 
ON 
--gdm_dh_sampling_grades.opid = dh_sampling_grades_open_ended_au_tail.opid 
--AND 
gdm_dh_sampling_grades.id = dh_sampling_grades_open_ended_au_tail.id 
AND gdm_dh_sampling_grades.depto = dh_sampling_grades_open_ended_au_tail.depto;
---}}}
--/*}}}*/

--passes minéralisées: {{{
CREATE OR REPLACE VIEW gdm.gdm_dh_mine_1 AS 
 SELECT dh_collars.id, dh_collars.x, dh_collars.y, dh_collars.z, dh_collars.azim_ng, dh_collars.dip_hz, dh_collars.length, dh_mineralised_intervals.depfrom, dh_mineralised_intervals.depto, dh_mineralised_intervals.avau, dh_mineralised_intervals.stva, dh_mineralised_intervals.accu, dh_mineralised_intervals.dens, dh_mineralised_intervals.recu, dh_mineralised_intervals.comments
   FROM 
    gdm.gdm_selection JOIN dh_collars 
    ON (gdm_selection.opid = dh_collars.opid AND gdm_selection.id = dh_collars.id) 
    JOIN dh_mineralised_intervals 
    ON (dh_collars.opid = dh_mineralised_intervals.opid AND dh_collars.id = dh_mineralised_intervals.id)
   WHERE dh_mineralised_intervals.mine = 1
;

CREATE OR REPLACE VIEW gdm.gdm_dh_mine_0 AS 
 SELECT dh_collars.id, dh_collars.x, dh_collars.y, dh_collars.z, dh_collars.azim_ng, dh_collars.dip_hz, dh_collars.length, dh_mineralised_intervals.depfrom, dh_mineralised_intervals.depto, dh_mineralised_intervals.avau, dh_mineralised_intervals.stva, dh_mineralised_intervals.accu, dh_mineralised_intervals.dens, dh_mineralised_intervals.recu, dh_mineralised_intervals.comments
   FROM 
    gdm.gdm_selection JOIN dh_collars 
    ON (gdm_selection.opid = dh_collars.opid AND gdm_selection.id = dh_collars.id) 
    JOIN dh_mineralised_intervals 
    ON (dh_collars.opid = dh_mineralised_intervals.opid AND dh_collars.id = dh_mineralised_intervals.id)
   WHERE dh_mineralised_intervals.mine = 0
;
--}}}


--lignes de base: {{{
CREATE VIEW gdm.gdm_baselines AS SELECT *, 1 AS order FROM baselines ORDER BY id;
--}}}
--coupes sériées: {{{
CREATE OR REPLACE VIEW gdm.gdm_sections_array AS 
SELECT sections_array.* FROM 
sections_array WHERE opid IN (SELECT DISTINCT opid FROM gdm.gdm_selection) ORDER BY id;
--}}}

--sondages prévus (et ceux non prévus mais sans analyses = juste réalisés):/*{{{*/
CREATE OR REPLACE VIEW gdm.gdm_dh_planned AS
SELECT dh_collars.id, location, x, y, z, azim_ng, dip_hz, length, completed, comments, length AS depto
FROM gdm.gdm_selection JOIN dh_collars ON (gdm_selection.opid = dh_collars.opid AND gdm_selection.id = dh_collars.id) 
WHERE 
(completed = FALSE OR completed IS NULL)
/*OR 
(completed AND dh_collars.id NOT IN (SELECT DISTINCT id FROM dh_sampling_grades))
*/
ORDER BY dh_collars.id, depto
;
--/*}}}*/
--}}}
-- des statistiques:{{{

--Tableau récapitulant les résultats par source de données:
CREATE VIEW stats_reports.recap_file_results_drill_holes AS 
SELECT filename, datasource, id, nb_assay_values FROM 
(
SELECT DISTINCT datasource, id, count(*) AS nb_assay_values FROM 
(SELECT opid, sample_id, datasource FROM lab_ana_results) AS tmp1
JOIN 
(SELECT opid, id, sample_id FROM dh_sampling_grades) AS tmp2 
ON tmp1.opid = tmp2.opid AND tmp1.sample_id = tmp2.sample_id
GROUP BY datasource, id
) AS tmp3 
JOIN lex_datasource 
ON tmp3.datasource = lex_datasource.datasource_id
ORDER BY datasource, id
;

CREATE OR REPLACE VIEW stats_reports.avancements_sondages_stats_quotidiennes AS             /*stats_reports.stats_quotidiennes_avancements_sondages*/
SELECT rig, date, sum(drilled_length_during_shift) as drilled_length_per_day, repeat('|'::text, (sum(drilled_length_during_shift)/10)::integer) AS graph_drilled_length_per_day, count(DISTINCT /*drill_hole_id*/ id) AS nb_drill_holes, min(/*drill_hole_id*/ id) AS first_dh, max(/*drill_hole_id*/ id) AS last_dh from /*drilling_daily_reports*/ shift_reports group by rig, date order by rig, date;


CREATE OR REPLACE VIEW stats_reports.avancements_sondages_stats_mensuelles AS 
SELECT year, month, sum(drilled_length_during_shift) as drilled_length_during_month FROM (SELECT extract(year from date) as year, extract (month from date) as month, drilled_length_during_shift FROM /*drilling_daily_reports*/ shift_reports) AS tmp GROUP BY year,month ORDER BY year, month;

--idem, avec location:
CREATE OR REPLACE VIEW stats_reports.avancements_sondages_stats_mensuelles_par_objectif AS 
SELECT year, month, target, sum(drilled_length_during_shift) as drilled_length_during_month FROM (SELECT extract(year from date) as year, extract (month from date) as month, drilled_length_during_shift, split_part (/*drill_hole_id*/ id, '_', 1) as target FROM /*drilling_daily_reports*/ shift_reports) AS tmp GROUP BY year,month, target ORDER BY year, month;


--stats annuelles
CREATE OR REPLACE VIEW stats_reports.avancements_sondages_stats_annuelles AS 
SELECT year, sum(drilled_length_during_shift) as drilled_length_during_year FROM (SELECT extract(year from date) as year, drilled_length_during_shift FROM /*drilling_daily_reports*/ shift_reports) AS tmp GROUP BY year ORDER BY year;

--idem, avec location:
CREATE OR REPLACE VIEW stats_reports.avancements_sondages_stats_annuelles_par_objectif AS 
SELECT year, target, sum(drilled_length_during_shift) as drilled_length_during_month FROM (SELECT extract(year from date) as year, extract (month from date) as month, drilled_length_during_shift, substring(/*drill_hole_id*/ id,1,4) as target FROM /*drilling_daily_reports*/ shift_reports) AS tmp GROUP BY year, target ORDER BY year;


CREATE OR REPLACE VIEW stats_reports.longueur_exploree_par_location AS --@#À AMÉLIORER!!!!
SELECT completed, location, dh_type, sum(length) AS sum_length 
FROM dh_collars 
GROUP BY 
completed, location, dh_type
ORDER BY 
completed, location, dh_type
;


--longueur explorée par location et type
CREATE OR REPLACE VIEW stats_reports.longueur_exploree_par_location_et_type AS 
SELECT location,dh_type,sum(length) FROM dh_collars WHERE completed GROUP BY location,dh_type ORDER BY location,dh_type DESC;


--longueur explorée par type (en kilomètres):
CREATE OR REPLACE VIEW stats_reports.longueur_exploree_par_type_km AS 
SELECT dh_type,sum(length)/1000 as km_explored_length FROM dh_collars GROUP BY dh_type ORDER BY dh_type DESC;






CREATE OR REPLACE VIEW checks.fichettes_vs_collars_longueurs_incoherentes AS 
SELECT /*drill_hole_id*/ tmp.id, max_drilled_length, length 
FROM 
(SELECT /*drill_hole_id*/ id, max(drilled_length) AS max_drilled_length, sum(drilled_length_during_shift) AS sum_drilled_length_during_shift FROM /*drilling_daily_reports*/ shift_reports GROUP BY /*drill_hole_id*/ shift_reports.id ORDER BY /*drill_hole_id*/ shift_reports.id) tmp 
JOIN 
dh_collars 
ON 
(tmp./*drill_hole_id*/id = dh_collars.id) 
WHERE 
max_drilled_length <> length ;


CREATE OR REPLACE VIEW checks.fichettes_vs_collars_ouvrages_dans_fichettes_pas_collars AS 
SELECT /*drill_hole_id*/ shift_reports.id AS shift_reports_id, dh_collars.id AS dh_collars_id FROM /*drilling_daily_reports*/ shift_reports LEFT JOIN dh_collars ON (/*drilling_daily_reports*/ shift_reports./*drill_hole_id*/ id = dh_collars.id) WHERE dh_collars.id IS NULL ORDER BY /*drill_hole_id*/ shift_reports.id, dh_collars.id;







CREATE OR REPLACE VIEW checks.fichettes_vs_collars_completed_incoherents AS 
SELECT /*drill_hole_id*/ tmp.id, dh_collars.completed, max_completed_fichettes 
FROM 
(SELECT /*drill_hole_id*/ id, max(completed::integer) AS max_completed_fichettes 
FROM /*drilling_daily_reports*/ shift_reports 
GROUP BY /*drill_hole_id*/ id) tmp 
JOIN 
dh_collars 
ON 
(tmp./*drill_hole_id*/ id = dh_collars.id) 
WHERE dh_collars.completed::integer <> max_completed_fichettes;


--CREATE OR REPLACE VIEW checks.fichettes_vs_collars_azimuts_incoherents AS 
--SELECT /*drill_hole_id*/ shift_reports.id, /*drilling_daily_reports*/ /*shift_reports.azim_nm, dh_collars.azim_ng */
--FROM /*drilling_daily_reports*/ shift_reports 
--JOIN 
--dh_collars 
--ON /*drilling_daily_reports*/ shift_reports./*drill_hole_id*/ id = dh_collars.id 
--WHERE /*drilling_daily_reports*/ shift_reports.azim_nm <> dh_collars.azim_ng;


--CREATE OR REPLACE VIEW checks.fichettes_vs_collars_dips_incoherents AS 
--SELECT /*drill_hole_id*/ shift_reports.id, /*drilling_daily_reports*/ shift_reports.dip, dh_collars.dip_hz FROM /*drilling_daily_reports*/ shift_reports JOIN dh_collars ON /*drilling_daily_reports*/ shift_reports./*drill_hole_id*/ id = dh_collars.id WHERE /*drilling_daily_reports*/ shift_reports.dip <> dh_collars.dip_hz;

CREATE OR REPLACE VIEW checks.fichettes_infos_incoherentes_drilled_lengths AS 
SELECT min(no_fichette) AS first_fichette, max(no_fichette) AS last_fichette, /*drill_hole_id*/ id, SUM(drilled_length_during_shift) AS sum_drilled_length_during_shift, MAX(drilled_length) AS max_drilled_length FROM /*drilling_daily_reports*/ shift_reports GROUP BY /*drill_hole_id*/ id HAVING SUM(drilled_length_during_shift) <> MAX(drilled_length) ORDER BY /*drill_hole_id*/ id;

--CREATE OR REPLACE VIEW checks.fichettes_infos_incoherentes_nb_samples AS 
--SELECT no_fichette, /*drill_hole_id*/ id, samples_from, samples_to, (samples_to - samples_from +1) AS diff_samples_from_to, nb_samples FROM /*drilling_daily_reports*/ shift_reports WHERE (samples_to - samples_from +1) <> nb_samples;

CREATE OR REPLACE VIEW stats_reports.verif_attachements_journaliers_sondeur AS 
SELECT date, sum(drilled_length_during_shift) as drilled_length_per_day, repeat('|'::text, (sum(drilled_length_during_shift)/10)::integer) AS graph_drilled_length_per_day, count(DISTINCT /*drill_hole_id*/ id) AS nb_drill_holes, min(/*drill_hole_id*/ id) AS first_dh, max(/*drill_hole_id*/ id) AS last_dh from /*drilling_daily_reports*/ shift_reports group by date order by date;

--CREATE OR REPLACE VIEW checks.codes_litho_codegdm AS 
--SELECT codegdm, count_codegdm FROM (SELECT codegdm, count(*) AS count_codegdm FROM dh_litho GROUP BY codegdm) tmp ORDER BY count_codegdm;




CREATE OR REPLACE VIEW checks.doublons_collars_xyz AS SELECT count(*),x,y,z, min(id), max(id) from dh_collars group by x,y,z HAVING count(*) >1;

CREATE OR REPLACE VIEW checks.doublons_collars_xyz_ouvrages_concernes AS SELECT id, dh_collars.x, dh_collars.y, dh_collars.z, azim_ng, dip_hz FROM dh_collars JOIN (SELECT count(*),x,y from dh_collars group by x,y HAVING count(*) >1) tmp ON (dh_collars.x=tmp.x AND dh_collars.y=tmp.y);



---}}}



-- pour surpac:/*{{{*/
CREATE VIEW surpac_survey AS
    SELECT dh_collars.id AS hole_id, 0 AS depth, (- dh_collars.dip_hz) AS dip, dh_collars.azim_ng AS azimuth FROM dh_collars WHERE (NOT (dh_collars.id IN (SELECT DISTINCT dh_devia.id FROM dh_devia WHERE ((dh_devia.depto = 0) AND (dh_devia.valid IS TRUE))))) UNION SELECT dh_devia.id AS hole_id, dh_devia.depto AS depth, (- dh_devia.dip_hz) AS dip, dh_devia.azim_ng AS azimuth FROM dh_devia WHERE (dh_devia.valid IS TRUE) ORDER BY 1, 2;

--/*}}}*/
--le marecage de la SMI: {{{
--SMI: Tiens: la formule pour avoir les xyz en utm à partir du marec, transcrite en SQL à partir du .xls: {{{

--
--deltax  = x - 19840
--deltay  = y -  9715
--gise    = {{{
--=SI(ET(deltax>=0,F14>0),ATAN((E14/F14))*200/PI(),SI(ET(E14<=0,F14>0),ATAN((E14/F14))*200/PI()+400,SI(ET(E14>=0,F14<0),ATAN((E14/F14))*200/PI()+200,SI(ET(E14<=0,F14<0),ATAN((E14/F14))*200/PI()+200,SI(ET(E14>0,F14=0),100,SI(ET(E14<0,F14=0),300,SI(ET(E14=0,F14=0),"IDEM")))))))
--
--Traduisons ça en pseudocode:
--
--=SI(
-- ET(deltax>=0,deltay>0),
--  ATAN((deltax/deltay))*200/PI(),
-- SI(
--  ET(deltax<=0,deltay>0),
--  ATAN((deltax/deltay))*200/PI()+400,
--  SI(
--   ET(deltax>=0,deltay<0),
--   ATAN((deltax/deltay))*200/PI()+200,
--   SI(
--    ET(deltax<=0,deltay<0),
--    ATAN((deltax/deltay))*200/PI()+200,
--    SI(
--     ET(deltax>0,deltay=0),
--     100,
--     SI(
--      ET(deltax<0,deltay=0),
--      300,
--      SI(
--       ET(deltax=0,deltay=0),
--       "IDEM"
--      )
--     )
--    )
--   )
--  )
-- )
--)
--
--Ah, il y a de toute évidence des grades, et non des degrés!
--
--CASE WHEN --(
-- (deltax>=0 AND deltay>0)
--  THEN ATAN((deltax/deltay))*200/PI()
-- ELSE WHEN --(
--  (deltax<=0 AND deltay>0)
--  THEN ATAN((deltax/deltay))*200/PI()+400
--  ELSE WHEN --(
--   (deltax>=0 AND deltay<0),
--   THEN ATAN((deltax/deltay))*200/PI()+200
--   ELSE WHEN --(
--    (deltax<=0 AND deltay<0)
--    THEN ATAN((deltax/deltay))*200/PI()+200
--    ELSE WHEN --(
--     (deltax>0 AND deltay=0)
--     THEN 100
--     ELSE WHEN --(
--      (deltax<0 AND deltay=0)
--      THEN 300
--      ELSE WHEN --(
--       (deltax=0 AND deltay=0)
--       THEN
--       "IDEM"
--      --)
--     --)
--    --)
--   --)
--  --)
-- --)
----)
--
--Moui. Ça doit pouvoir se simplifier.
--Déjà, les fonctions trigo, ce sont les bonnes abréviations?{{{
--SELECT TAN(PI()/4), ATAN(1)/pi();
-- tan | ?column? 
-------+----------
--   1 |     0.25
--(1 ligne)
--}}}
--Auquai, c'est les bonnes fonctions.
--
--Oui, on peut simplifier facilement:
--SELECT (
--CASE WHEN
-- (deltax>0 AND deltay=0)
-- THEN 100
--WHEN
-- (deltax<0 AND deltay=0)
-- THEN 300
--WHEN
-- (deltax=0 AND deltay=0)
-- THEN
--  NULL --'IDEM'
--ELSE
-- ATAN((deltax/deltay))*200/PI()
-- +(deltax<=0 AND deltay>0)::integer * 400
-- +(deltax>=0 AND deltay<0)::integer * 200
-- +(deltax<=0 AND deltay<0)::integer * 200
--END) AS gise
--
--Essayons voir:{{{
--SELECT (
--CASE WHEN
-- (deltax>0 AND deltay=0)
-- THEN 100
--WHEN
-- (deltax<0 AND deltay=0)
-- THEN 300
--WHEN
-- (deltax=0 AND deltay=0)
-- THEN
--  NULL --'IDEM'
--ELSE
-- ATAN((deltax/deltay))*200/PI()
-- +(deltax<=0 AND deltay>0)::integer * 400
-- +(deltax>=0 AND deltay<0)::integer * 200
-- +(deltax<=0 AND deltay<0)::integer * 200
--END) AS gise
--FROM 
--(SELECT 
--1369.120 AS deltax, 1174.057 AS deltay
--) AS tmp;
--}}}
----Auquai, après qq modifs, ça correspond avec le résultat du .xls.
----Continuons:
--}}}
--dist    = {{{
--=RACINE((E11*E11)+(F11*F11))
--=sqrt((deltax2)+(deltay2))
--
--}}}
--crctn_g = {{{
--=gise-0.3979902727
--}}}
--xc     = {{{
--=597720+dist*SIN(crctn_g*PI()/200)
--}}}
--yc     = {{{
--=Q$4+H31*COS(I31*PI()/200)
--=760085+dist*COS(crctn_g*PI()/200)
--}}}
--zc     = {{{
--=D33+J$2
--=z+8.775
--}}}
--*/
--/*{{{*/
--/*
--CREATE OR REPLACE VIEW marec2utm AS 
--SELECT *,
--597720+dist*SIN(crctn_g*PI()/200) AS xc,
--760085+dist*COS(crctn_g*PI()/200) AS yc,
--z_local+8.775 AS zc
--FROM
--(
--SELECT *,
--gise-0.3979902727 AS crctn_g
--FROM
--(
--SELECT *,
--(
--CASE WHEN
-- (deltax>0 AND deltay=0)
-- THEN 100
--WHEN
-- (deltax<0 AND deltay=0)
-- THEN 300
--WHEN
-- (deltax=0 AND deltay=0)
-- THEN
--  NULL --'IDEM'
--ELSE
-- ATAN((deltax/deltay))*200/PI()
-- +(deltax<=0 AND deltay>0)::integer * 400
-- +(deltax>=0 AND deltay<0)::integer * 200
-- +(deltax<=0 AND deltay<0)::integer * 200
--END) AS gise,
--sqrt((deltax2)+(deltay2)) AS dist
--FROM
--(SELECT 
--id, x_local, y_local, z_local,
--x_local - 19840 AS deltax,
--y_local -  9715 AS deltay 
--FROM dh_collars
--WHERE x_local IS NOT NULL AND y_local IS NOT NULL AND z_local IS NOT NULL
--) AS xyz_local
--) AS interm1
--) AS interm2
--;
--*/
--/*
--Moui, pas mal. Mais ça donne des résultats légèrement différents de ceux du .xls, à qq dm près:
--SELECT 
--m.id,
--m.x_local, m.y_local, m.z_local,
--m.xc,m.yc,m.zc,
--t.x_local,t.y_local,t.z_local,
--t.x,t.y,t.z,
--m.xc - t.x AS diffx,
--m.yc - t.y AS diffy,
--m.zc - t.z AS diffz
-- FROM marec2utm AS m JOIN tmp_imports.tmp_xfer_sondages_utm_est_et_ouest_cavally_2007_2009 AS t ON m.id = t.id ORDER BY m.id;
--
--
--TABLE tmp_imports.tmp_xfer_sondages_utm_est_et_ouest_cavally_2007_2009 ;
--JOIN dh_collars ON tmp_xfer_sondages_utm_est_et_ouest_cavally_2007_2009.id = dh_collars.id ORDER BY dh_collars.id;
--s
--
--Hm, des différences de l'ordre de 36cm en y et qq cm en x. Curieux.
--Ça sentirait le souci de calcul. Peut-être la précision de pi(), et les conversions trigonométriques dans plusieurs sens?
--pi() selon oocalc:
--3.1415926536        10 décimales
--et selon postgresql:
--3.14159265358979    14 décimales
--
--kspread et gnumeric donnent les mêmes résultats qu'oOo. kspread s'est complètement gourré en lisant les formules, notons en passant, il a mis des B$14 au lieu des B$4 => @#faire un rapport de bogue.
--
--Bon, pour le moment, je préfère m'en tenir aux coordonnées calculées par le .xls, par prudence. Je garde la vue sous le coude.
--
--Il y a aussi un souci fondamental, c'est qu'on fait de la géométrie cartésienne sur un espace qui est en fait courbe. À grande échelle, c'est acceptable, mais il faut s'attendre à ce que ça dérive, et assez rapidement.
--*/
--/*}}}*/
--
----la bonne requête:/*{{{*/
--
--CREATE OR REPLACE VIEW marec2utm AS 
--SELECT *,
--597719.9009+dist*SIN(crctn_g*PI()/200) AS xc,
--760084.6351+dist*COS(crctn_g*PI()/200) AS yc,
--z_local+8.775 AS zc
--FROM
--(
--SELECT *,
--gise-0.3979902727 AS crctn_g
--FROM
--(
--SELECT *,
--(
--CASE WHEN
-- (deltax>0 AND deltay=0)
-- THEN 100
--WHEN
-- (deltax<0 AND deltay=0)
-- THEN 300
--WHEN
-- (deltax=0 AND deltay=0)
-- THEN
--  NULL /*'IDEM'*/
--ELSE
-- ATAN((deltax/deltay))*200/PI()
-- +(deltax<=0 AND deltay>0)::integer * 400
-- +(deltax>=0 AND deltay<0)::integer * 200
-- +(deltax<=0 AND deltay<0)::integer * 200
--END) AS gise,
--sqrt((deltax2)+(deltay2)) AS dist
--FROM
--(SELECT 
--id, x_local, y_local, z_local,
--x_local - 19840 AS deltax,
--y_local -  9715 AS deltay 
--FROM tmp_xyz_marec
--WHERE x_local IS NOT NULL AND y_local IS NOT NULL AND z_local IS NOT NULL
--) AS xyz_local
--) AS interm1
--) AS interm2
--;
--/*}}}*/
----}}}
----}}}
--des coupes sériées @#à replacer où il faut:{{{

--ALTER TABLE sections_array ADD CONSTRAINT sections_array_num PRIMARY KEY (num);

--CREATE OR REPLACE VIEW sections_array_plines AS SELECT *,     GeomFromEWKT('SRID=' || srid || ';LINESTRING (' || x1 || ' ' || y1 || ' ' || z1 || ', ' || x2 || ' ' || y2 || ' ' || z2 || ')') FROM sections_array ORDER BY num;


--}}}
--9. points echantillons 3D:{{{
CREATE VIEW dh_sampling_avg_grades_3dpoints AS
SELECT *,
GeomFromEWKT('SRID=' || srid || ';POINT (' ||/* x1 || ' ' || y1 || ' ' || z1 || ', ' ||*/ x2 || ' ' || y2 || ' ' || z2 || ')') AS geometry 
FROM
(
SELECT srid, s.*,
x + depfrom * cos((dip_hz / 180) * pi()) * sin((azim_ng / 180) * pi()) AS x1,
y + depfrom * cos((dip_hz / 180) * pi()) * cos((azim_ng / 180) * pi()) AS y1,
z - depfrom * sin((dip_hz / 180) * pi())                               AS z1,
x +  depto  * cos((dip_hz / 180) * pi()) * sin((azim_ng / 180) * pi()) AS x2,
y +  depto  * cos((dip_hz / 180) * pi()) * cos((azim_ng / 180) * pi()) AS y2,
z -  depto  * sin((dip_hz / 180) * pi())                               AS z2 
FROM 
(
SELECT id, srid, x, y, z, azim_ng, dip_hz FROM 
dh_collars 
) c 
JOIN dh_sampling_grades s 
ON c.id = s.id
) tmp
--ORDER BY id, depto
;
--}}}
-- des sélections, des vues qui ont vocation à être souvent modifiées, au gré de différentes sélections:{{{

CREATE VIEW collars_selection AS SELECT * FROM dh_collars_points WHERE id IN('DA08-650', 'DA08-656');
--}}}
-- un dh_sampling, par souci de compatibilité avec les requêtes ayant précédé dh_sampling_grades::{{{
CREATE VIEW dh_sampling AS SELECT id,depfrom,depto,core_loss_cm,weight_kg,sample_type,sample_id,comments,opid,batch_id,datasource FROM dh_sampling_grades;

--}}}
-- une vue qui montre les sondages avec les dernières analyses:/*{{{*/
CREATE VIEW dh_collars_points_last_ana_results AS 
SELECT * FROM dh_collars_points WHERE id 
IN (
SELECT DISTINCT id FROM dh_sampling_grades WHERE sample_id IN (
SELECT sample_id FROM lab_ana_results WHERE datasource = (
SELECT max(datasource) AS last_datasource FROM lab_ana_results)))
ORDER BY id;
/*}}}*/

--des vues de vérifs:{{{

--Comparons un coup les profondeurs des tables de passes et des têtes:
--table échantillons:

CREATE OR REPLACE VIEW checks.collars_lengths_vs_dh_sampling_depths AS 
SELECT dh_collars.id, length, max_depto_sampl, length - max_depto_sampl as diff_SHOULD_BE_ZERO FROM dh_collars INNER JOIN (SELECT id, max(depto) as max_depto_sampl FROM dh_sampling GROUP BY id) AS max_depto ON dh_collars.id=max_depto.id WHERE length - max_depto_sampl<>0 ORDER BY id;

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
SELECT /*tmp_dh_topo_coordinates*/ topo_points.id AS id_topo, dh_collars.id AS id_collars FROM /*tmp_dh_topo_coordinates*/ topo_points LEFT OUTER JOIN dh_collars ON /*tmp_dh_topo_coordinates*/ topo_points.id = dh_collars.id WHERE dh_collars.id IS NULL;

CREATE OR REPLACE VIEW checks.collars_vs_topo_xyz_en_face_et_differences_importantes AS 
SELECT id_topo, id_collars, topo_x, collars_x, diffx, topo_y, collars_y, diffy, topo_z, collars_z, diffz FROM (SELECT /*tmp_dh_topo_coordinates*/ topo_points.id AS id_topo, dh_collars.id AS id_collars, /*tmp_dh_topo_coordinates*/ topo_points.x AS topo_x, dh_collars.x AS collars_x, /*tmp_dh_topo_coordinates*/ topo_points.y as topo_y, dh_collars.y AS collars_y, /*tmp_dh_topo_coordinates*/ topo_points.z AS topo_z, dh_collars.z AS collars_z, /*tmp_dh_topo_coordinates*/ topo_points.x-dh_collars.x AS diffx, /*tmp_dh_topo_coordinates*/ topo_points.y-dh_collars.y AS diffy, /*tmp_dh_topo_coordinates*/ topo_points.z-dh_collars.z AS diffz FROM /*/*tmp_dh_topo_coordinates*/ topo_points*/ topo_points JOIN dh_collars ON /*tmp_dh_topo_coordinates*/ topo_points.id = dh_collars.id) tmp WHERE ABS(diffx) >= 0.05 OR ABS(diffy) >= 0.05 OR ABS(diffz) >= 0.05;


CREATE OR REPLACE VIEW checks.fichettes_infos_redondantes_incoherentes AS 
SELECT nb_sondages_et_attributs, nb_sondages, nb_sondages_et_attributs-nb_sondages AS diff_SHOULD_BE_ZERO  FROM (SELECT count(*) AS nb_sondages_et_attributs FROM (SELECT /*drill_hole_id*/ id, planned_length/*, azim_nm,*/ /*dip*/ FROM /*drilling_daily_reports*/ shift_reports GROUP BY /*drill_hole_id*/ id, planned_length/*, azim_nm, dip*/) tmp) tmp1, (SELECT count(DISTINCT /*drill_hole_id*/ id) AS nb_sondages FROM /*drilling_daily_reports*/ shift_reports) tmp2 WHERE nb_sondages_et_attributs-nb_sondages <> 0;

CREATE OR REPLACE VIEW checks.fichettes_infos_redondantes_incoherentes_quels_ouvrages AS 
SELECT /*drill_hole_id*/ id, min(planned_length) AS min_planned_length, max(planned_length) AS max_planned_length/*, min(azim_nm) AS min_azim_nm, max(azim_nm) AS max_azim_nm, min(dip) AS min_dip, max(dip) AS max_dip*/ FROM /*drilling_daily_reports*/ shift_reports GROUP BY /*drill_hole_id*/ id HAVING (count(DISTINCT planned_length)>1/* OR count(DISTINCT azim_nm)>1 OR count(DISTINCT dip)>1*/);

CREATE OR REPLACE VIEW checks.fichettes_infos_incoherentes_heures AS 
SELECT date, /*drill_hole_id*/ id, time_start, time_end FROM /*drilling_daily_reports*/ shift_reports WHERE time_start>time_end;


CREATE OR REPLACE VIEW checks.fichettes_vs_collars_ouvrages_dans_fichettes_pas_collars AS 
SELECT /*drill_hole_id*/ shift_reports.id AS shift_reports_id, dh_collars.id AS dh_collars_id FROM /*drilling_daily_reports*/ shift_reports LEFT JOIN dh_collars ON (/*drilling_daily_reports*/ shift_reports./*drill_hole_id*/ id = dh_collars.id) WHERE dh_collars.id IS NULL ORDER BY /*drill_hole_id*/ shift_reports.id, dh_collars.id;

CREATE OR REPLACE VIEW checks.fichettes_longueurs_incoherentes AS 
SELECT /*drill_hole_id*/ id, max_drilled_length, sum_drilled_length_during_shift FROM (SELECT /*drill_hole_id*/ id, max(drilled_length) AS max_drilled_length, sum(drilled_length_during_shift) AS sum_drilled_length_during_shift FROM /*drilling_daily_reports*/ shift_reports GROUP BY /*drill_hole_id*/ id ORDER BY /*drill_hole_id*/ id) tmp WHERE max_drilled_length <> sum_drilled_length_during_shift ;

CREATE OR REPLACE VIEW checks.fichettes_vs_collars_longueurs_incoherentes AS 
SELECT /*drill_hole_id*/ tmp.id, max_drilled_length, length 
FROM 
(SELECT /*drill_hole_id*/ id, max(drilled_length) AS max_drilled_length, sum(drilled_length_during_shift) AS sum_drilled_length_during_shift FROM /*drilling_daily_reports*/ shift_reports GROUP BY /*drill_hole_id*/ shift_reports.id ORDER BY /*drill_hole_id*/ shift_reports.id) tmp 
JOIN 
dh_collars 
ON 
(tmp./*drill_hole_id*/id = dh_collars.id) 
WHERE 
max_drilled_length <> length ;


CREATE OR REPLACE VIEW checks.fichettes_ouvrages_non_completed AS 
SELECT /*drill_hole_id*/ id, max(completed::integer) FROM /*drilling_daily_reports*/ shift_reports GROUP BY /*drill_hole_id*/ id HAVING max(completed::integer) <> 1;



--}}}

--une vue spécifique pour envoyer à un .gpx, qui permettra de mettre name, notamment:/*{{{*/
CREATE VIEW dh_collars_for_gpx AS SELECT id AS name FROM dh_collars_points WHERE not(completed);
/*}}}*/
-- une vue pour carter les points topo vers points de dh_collars:/*{{{*/
CREATE OR REPLACE VIEW checks.dh_collars_to_topo_points_lines AS SELECT dh_collars.id, topo_points.numauto, dh_collars.x dh_collars_x, topo_points.x AS topo_points_x, dh_collars.y AS dh_collars_y, topo_points.y AS topo_points_y, dh_collars.z AS dh_collars_z, topo_points.z AS topo_points_z, geomfromewkt('LINESTRING (' || dh_collars.x::text || ' ' || dh_collars.y::text || ' ' || dh_collars.z::text || ', ' || topo_points.x || ' ' || topo_points.y::text || ' ' || topo_points.z || ')') AS geometry FROM topo_points JOIN dh_collars ON topo_points.opid = dh_collars.opid AND topo_points.id = dh_collars.id;
/*}}}*/
-- les vues du schéma tanguy: {{{
/*
CREATE VIEW tanguy.qry_blank AS
    SELECT lab_ana_batches_reception.generic_txt_col2, qc_sampling.batch_id, lab_ana_results.sample_id, lab_ana_results.value_num, to_date((lab_ana_batches_reception.generic_txt_col2)::text, 'DDMMYY'::text) AS analy_date, date_part('month'::text, to_date((lab_ana_batches_reception.generic_txt_col2)::text, 'DDMMYY'::text)) AS mois_analyse, date_part('year'::text, to_date((lab_ana_batches_reception.generic_txt_col2)::text, 'DDMMYY'::text)) AS year_analyse, date_part('week'::text, to_date((lab_ana_batches_reception.generic_txt_col2)::text, 'DDMMYY'::text)) AS week_analyse, lab_ana_results.unit FROM public.lab_ana_results, public.qc_sampling, public.lab_ana_batches_reception WHERE (((((((lab_ana_results.jobno)::text = (lab_ana_batches_reception.jobno)::text) AND (lab_ana_results.opid = lab_ana_batches_reception.opid)) AND (qc_sampling.opid = lab_ana_results.opid)) AND ((qc_sampling.sample_id)::text = (lab_ana_results.sample_id)::text)) AND ((lab_ana_batches_reception.generic_txt_col1)::text = 'DATE COMPLETED'::text)) AND ((qc_sampling.qc_type)::text = 'BLANK'::text)) ORDER BY lab_ana_results.batch_id;
CREATE VIEW tanguy.qry_deviation AS
    SELECT dh_collars.id, dh_devia.depto, dh_devia.dip_hz, dh_devia.magnetic, dh_devia.azim_ng, dh_collars.azim_ng AS "PLANNED_AZIM_NG", dh_collars.dip_hz AS "PLANNED_DIP_HZ" FROM public.dh_collars, public.dh_devia WHERE (((dh_collars.id)::text = (dh_devia.id)::text) AND (dh_collars.opid = dh_devia.opid)) ORDER BY dh_collars.id, dh_devia.depto;
CREATE VIEW tanguy.qry_duplicate AS
    SELECT qc_sampling.batch_id, qc_sampling.qc_type, "ANA1".sample_id AS "DUPLICA", "ANA1".value_num AS "VALUE_DUPLICA", "ANA2".sample_id AS "ORIGIN", "ANA2".value_num AS "VALUE_ORIGIN", to_date((lab_ana_batches_reception.generic_txt_col2)::text, 'DDMMYY'::text) AS analy_date, date_part('month'::text, to_date((lab_ana_batches_reception.generic_txt_col2)::text, 'DDMMYY'::text)) AS mois_analyse, date_part('year'::text, to_date((lab_ana_batches_reception.generic_txt_col2)::text, 'DDMMYY'::text)) AS year_analyse, date_part('week'::text, to_date((lab_ana_batches_reception.generic_txt_col2)::text, 'DDMMYY'::text)) AS week_analyse, abs((("ANA2".value_num - "ANA1".value_num) / "ANA2".value_num)) AS mape, "ANA1".unit, "ANA2".unit AS unit2 FROM public.lab_ana_results "ANA1", public.lab_ana_batches_reception, public.lab_ana_results "ANA2", public.qc_sampling WHERE ((((((((("ANA1".jobno)::text = (lab_ana_batches_reception.jobno)::text) AND ("ANA1".opid = lab_ana_batches_reception.opid)) AND (("ANA1".sample_id)::text = (qc_sampling.sample_id)::text)) AND ("ANA1".opid = qc_sampling.opid)) AND ((qc_sampling.refers_to)::text = ("ANA2".sample_id)::text)) AND (qc_sampling.opid = "ANA2".opid)) AND ((lab_ana_batches_reception.generic_txt_col1)::text ~~ 'DATE COMPLETED'::text)) AND (("ANA1".unit)::text ~~ 'PPM'::text)) ORDER BY lab_ana_batches_reception.generic_txt_col2, "ANA1".batch_id;
CREATE VIEW tanguy.qry_interval_mine AS
    SELECT dh_collars_points.id, dh_collars_points.location, dh_collars_points.profile, dh_collars_points.x, dh_collars_points.y, dh_collars_points.z, dh_collars_points.azim_ng, dh_collars_points.dip_hz, dh_collars_points.dh_type, date_part('week'::text, dh_collars_points.date_start) AS week_start, date_part('year'::text, dh_collars_points.date_start) AS year_start, date_part('month'::text, dh_collars_points.date_start) AS month_start, dh_collars_points.contractor, dh_collars_points.geologist, dh_collars_points.length, dh_mineralised_intervals.depfrom, dh_mineralised_intervals.depto, dh_mineralised_intervals.mine, dh_mineralised_intervals.accu, dh_litho.depfrom AS litho_from, dh_litho.depto AS litho_to, dh_litho.code1, dh_litho.code2 FROM ((public.dh_collars_points LEFT JOIN public.dh_mineralised_intervals ON ((((dh_collars_points.id)::text = (dh_mineralised_intervals.id)::text) AND (dh_collars_points.opid = dh_mineralised_intervals.opid)))) LEFT JOIN public.dh_litho ON ((((dh_mineralised_intervals.id)::text = (dh_litho.id)::text) AND (((dh_mineralised_intervals.depfrom >= dh_litho.depfrom) AND (dh_mineralised_intervals.depto <= dh_litho.depto)) OR ((dh_mineralised_intervals.depfrom <= dh_litho.depfrom) AND (dh_mineralised_intervals.depto >= dh_litho.depto)))))) ORDER BY dh_collars_points.date_start, dh_collars_points.id, dh_mineralised_intervals.depfrom, dh_litho.depfrom;
CREATE VIEW tanguy.qry_recup AS
    SELECT dh_collars.id, dh_collars.contractor, dh_collars.geologist, dh_tech.drilled_len, dh_tech.reco_len, CASE dh_tech.reco_len WHEN 0 THEN (0)::numeric ELSE (dh_tech.drilled_len / dh_tech.reco_len) END AS pourc_recup, dh_collars.date_start, dh_collars.dh_type, dh_collars.location, dh_collars.date_completed, date_part('year'::text, dh_collars.date_start) AS year_start, date_part('month'::text, dh_collars.date_start) AS month_start, date_part('week'::text, dh_collars.date_start) AS week_start FROM (public.dh_collars LEFT JOIN public.dh_tech ON (((dh_collars.id)::text = (dh_tech.id)::text))) ORDER BY dh_collars.date_start, dh_collars.date_completed, dh_collars.id;
CREATE VIEW tanguy.qry_std AS 
    SELECT lab_ana_batches_reception.opid, qc_sampling.batch_id, lab_ana_batches_reception.jobno, lab_ana_results.scheme, lab_ana_results.labname, qc_sampling.qc_type, lab_ana_results.sample_id, lab_ana_batches_reception.generic_txt_col1, date_part('month'::text, to_date((lab_ana_batches_reception.generic_txt_col2)::text, 'DDMMYY'::text)) AS mois_analyse, date_part('year'::text, to_date((lab_ana_batches_reception.generic_txt_col2)::text, 'DDMMYY'::text)) AS year_analyse, date_part('week'::text, to_date((lab_ana_batches_reception.generic_txt_col2)::text, 'DDMMYY'::text)) AS week_analyse, lab_ana_batches_reception.generic_txt_col2, lab_ana_results.value_num, lab_ana_results.value, qc_sampling.refers_to, libs.unit, libs.std_id, libs.element, libs.std_value, libs.std_devia, libs.type_analyse FROM (((public.qc_sampling LEFT JOIN public.lab_ana_results ON ((((qc_sampling.sample_id)::text = (lab_ana_results.sample_id)::text) AND (qc_sampling.opid = lab_ana_results.opid)))) LEFT JOIN (SELECT lex_standard.unit, lex_standard.std_id, lex_standard.element, max(lex_standard.value) AS std_value, max(lex_standard.std_dev) AS std_devia, lex_standard.type_analyse FROM (public.lex_standard LEFT JOIN public.lab_ana_batches_reception ON ((upper(btrim((lex_standard.element)::text)) = upper(btrim(((lab_ana_batches_reception.generic_txt_col2)::bpchar)::text))))) WHERE ((lab_ana_batches_reception.generic_txt_col1)::text = 'IDENT'::text) GROUP BY lex_standard.std_id, lex_standard.type_analyse, lex_standard.unit, lex_standard.element) libs ON (((upper(btrim((qc_sampling.refers_to)::text)) = upper(btrim((libs.std_id)::text))) AND (upper(btrim(((lab_ana_results.scheme)::bpchar)::text)) = upper(btrim((libs.type_analyse)::text)))))) LEFT JOIN public.lab_ana_batches_reception ON ((((lab_ana_results.jobno)::text = (lab_ana_batches_reception.jobno)::text) AND (lab_ana_results.opid = lab_ana_batches_reception.opid)))) WHERE (((qc_sampling.qc_type)::text = 'STD'::text) AND ((lab_ana_batches_reception.generic_txt_col1)::text = 'DATE COMPLETED'::text));
CREATE VIEW tanguy.qry_suivi_ech AS
    SELECT dh_collars.id AS hole_id, max(dh_collars.date_start) AS date_start, max(dh_collars.length) AS max_length, max(dh_collars.date_completed) AS max_date, dh_collars.id_pject, dh_sampling_grades.sample_type, count(dh_sampling_grades.numauto) AS nb_samples_in_samplesgrades, lab_ana_results.labname, count(dh_sampling_grades.batch_id) AS count_batch_id, count(lab_ana_results.jobno) AS nb_job, max(lab_ana_results.db_update_timestamp) AS date_import, max((lab_ana_batches_reception.generic_txt_col2)::text) AS date_analy, max(to_date((lab_ana_batches_reception.generic_txt_col2)::text, 'DDMMYY'::text)) AS analy_date, max(date_part('month'::text, to_date((lab_ana_batches_reception.generic_txt_col2)::text, 'DDMMYY'::text))) AS mois_analyse, max(date_part('year'::text, to_date((lab_ana_batches_reception.generic_txt_col2)::text, 'DDMMYY'::text))) AS year_analyse, max(date_part('week'::text, to_date((lab_ana_batches_reception.generic_txt_col2)::text, 'DDMMYY'::text))) AS week_analyse, max(dh_sampling_grades.batch_id) AS num_batch, max(date_part('month'::text, dh_collars.date_start)) AS month_start, max(date_part('year'::text, dh_collars.date_start)) AS year_start, max(date_part('week'::text, dh_collars.date_start)) AS week_start, dh_collars.dh_type, dh_collars.location FROM (((public.dh_collars LEFT JOIN public.dh_sampling_grades ON (((dh_collars.opid = dh_sampling_grades.opid) AND ((dh_collars.id)::text = (dh_sampling_grades.id)::text)))) LEFT JOIN public.lab_ana_results ON (((dh_sampling_grades.opid = lab_ana_results.opid) AND ((dh_sampling_grades.sample_id)::text = (lab_ana_results.sample_id)::text)))) LEFT JOIN public.lab_ana_batches_reception ON (((lab_ana_results.opid = lab_ana_batches_reception.opid) AND ((lab_ana_results.jobno)::text = (lab_ana_batches_reception.jobno)::text)))) WHERE (((lab_ana_batches_reception.generic_txt_col1)::text = 'DATE COMPLETED'::text) OR (lab_ana_batches_reception.generic_txt_col1 IS NULL)) GROUP BY dh_collars.id, dh_collars.id_pject, dh_sampling_grades.sample_type, lab_ana_results.labname, dh_collars.dh_type, dh_collars.location ORDER BY max(date_part('year'::text, to_date((lab_ana_batches_reception.generic_txt_col2)::text, 'DDMMYY'::text))), max(date_part('month'::text, to_date((lab_ana_batches_reception.generic_txt_col2)::text, 'DDMMYY'::text))), max(dh_sampling_grades.batch_id);
CREATE VIEW tanguy.chk_tmp AS
    SELECT dh_collars.id, dh_collars.length, sum((tmp_120708_smi_explo_suivi_sondages.drilled_shift)::numeric) AS sum FROM (pierre.dh_collars JOIN tmp_imports.tmp_120708_smi_explo_suivi_sondages ON (((dh_collars.id)::text = (tmp_120708_smi_explo_suivi_sondages.id)::text))) GROUP BY dh_collars.id, dh_collars.length, tmp_120708_smi_explo_suivi_sondages.id HAVING (sum((tmp_120708_smi_explo_suivi_sondages.drilled_shift)::numeric) <> dh_collars.length) ORDER BY dh_collars.id;
CREATE VIEW tanguy.geoch_data AS
    SELECT geoch_sampling.id, geoch_sampling.lab_id, geoch_sampling.batch_id, geoch_sampling.gps_w_point, geoch_sampling.recep_date, geoch_sampling.type, geoch_sampling.x, geoch_sampling.y, geoch_sampling.z, geoch_sampling.soil_color, geoch_sampling.type_sort, geoch_sampling.depth_m, geoch_sampling.paysage_vege, geoch_sampling.topographie, geoch_sampling.lithologie, geoch_sampling.comment, geoch_sampling.utm_zone, geoch_sampling.geologist, geoch_sampling.quartz, geoch_sampling.host_rock, geoch_sampling.prospect, geoch_sampling.spacing, geoch_sampling.horizon, geoch_sampling.datasource, geoch_sampling.date_sampled, geoch_sampling.survey_type, geoch_sampling.opid, geoch_sampling.grid_line, geoch_sampling.grid_station, geoch_sampling.alteration, geoch_sampling.condition, geoch_sampling.slope, geoch_sampling.slope_dir, geoch_sampling.soil_description, "ANA_AU".unit AS unit_au, "ANA_AU".det_lim AS detec_limite_au, "ANA_AU".scheme AS scheme_au, "ANA_AU".value AS teneur_au, "ANA_AU".qaqc_type, "ANA_AU".jobno, "ANA_POIDS".unit AS unit_poids, "ANA_POIDS".value AS poids, CASE geoch_sampling.batch_id WHEN NULL::text THEN 'SAMPLED'::text ELSE 'DISPATCH'::text END AS status_sample FROM ((public.geoch_sampling LEFT JOIN public.geoch_ana "ANA_AU" ON ((((geoch_sampling.id)::text = ("ANA_AU".id)::text) AND (geoch_sampling.opid = "ANA_AU".opid)))) LEFT JOIN public.geoch_ana "ANA_POIDS" ON ((((geoch_sampling.id)::text = ("ANA_POIDS".id)::text) AND (geoch_sampling.opid = "ANA_POIDS".opid)))) WHERE ((("ANA_AU".ana_type)::text = 'AU1'::text) AND (("ANA_POIDS".ana_type)::text = 'POIDS'::text));
CREATE VIEW tanguy.geoch_multi_ana AS
    SELECT geoch_sampling.id, "AG".no_ech, "MO".unit AS "UNIT_MO", "MO".value AS "MO_VALUE", "CU".unit AS "UNIT_CU", "CU".value AS "CU_VALUE", "PB".unit AS "UNIT_PB", "PB".value AS "PB_VALUE", "ZN".unit AS "UNIT_ZN", "ZN".value AS "ZN_VALUE", "AG".unit AS "UNIT_AG", "AG".value AS "AG_VALUE", "NI".unit AS "UNIT_NI", "NI".value AS "NI_VALUE", "CO".unit AS "UNIT_CO", "CO".value AS "CO_VALUE", "MN".unit AS "UNIT_MN", "MN".value AS "MN_VALUE", "FE".unit AS "UNIT_FE", "FE".value AS "FE_VALUE", "AS".unit AS "UNIT_AS", "AS".value AS "AS_VALUE", "TH".unit AS "UNIT_TH", "TH".value AS "TH_VALUE", "CD".unit AS "UNIT_CD", "CD".value AS "CD_VALUE", "SB".unit AS "UNIT_SB", "SB".value AS "SB_VALUE", "BI".unit AS "UNIT_BI", "BI".value AS "BI_VALUE", "V".unit AS "UNIT_V", "V".value AS "V_VALUE", "CA".unit AS "UNIT_CA", "CA".value AS "CA_VALUE", "P".unit AS "UNIT_P", "P".value AS "P_VALUE", "LA".unit AS "UNIT_LA", "LA".value AS "LA_VALUE", "CR".unit AS "UNIT_CR", "CR".value AS "CR_VALUE", "HG".unit AS "UNIT_HG", "HG".value AS "HG_VALUE", "TL".unit AS "UNIT_TL", "TL".value AS "TL_VALUE", "GA".unit AS "UNIT_GA", "GA".value AS "GA_VALUE", "SC".unit AS "UNIT_SC", "SC".value AS "SC_VALUE" FROM public.geoch_sampling, public.geoch_ana "MO", public.geoch_ana "CU", public.geoch_ana "PB", public.geoch_ana "ZN", public.geoch_ana "AG", public.geoch_ana "NI", public.geoch_ana "CO", public.geoch_ana "MN", public.geoch_ana "FE", public.geoch_ana "AS", public.geoch_ana "TH", public.geoch_ana "SR", public.geoch_ana "CD", public.geoch_ana "SB", public.geoch_ana "BI", public.geoch_ana "V", public.geoch_ana "CA", public.geoch_ana "P", public.geoch_ana "LA", public.geoch_ana "CR", public.geoch_ana "HG", public.geoch_ana "TL", public.geoch_ana "GA", public.geoch_ana "SC" WHERE ((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((geoch_sampling.id)::text = ("MO".id)::text) AND (geoch_sampling.opid = "MO".opid)) AND ((geoch_sampling.id)::text = ("CU".id)::text)) AND (geoch_sampling.opid = "CU".opid)) AND ((geoch_sampling.id)::text = ("PB".id)::text)) AND (geoch_sampling.opid = "PB".opid)) AND ((geoch_sampling.id)::text = ("ZN".id)::text)) AND (geoch_sampling.opid = "ZN".opid)) AND ((geoch_sampling.id)::text = ("AG".id)::text)) AND ((geoch_sampling.id)::text = ("NI".id)::text)) AND (geoch_sampling.opid = "NI".opid)) AND ((geoch_sampling.id)::text = ("CO".id)::text)) AND (geoch_sampling.opid = "CO".opid)) AND ((geoch_sampling.id)::text = ("MN".id)::text)) AND (geoch_sampling.opid = "MN".opid)) AND ((geoch_sampling.id)::text = ("FE".id)::text)) AND (geoch_sampling.opid = "FE".opid)) AND ((geoch_sampling.id)::text = ("AS".id)::text)) AND (geoch_sampling.opid = "AS".opid)) AND ((geoch_sampling.id)::text = ("TH".id)::text)) AND (geoch_sampling.opid = "TH".opid)) AND ((geoch_sampling.id)::text = ("SR".id)::text)) AND (geoch_sampling.opid = "SR".opid)) AND ((geoch_sampling.id)::text = ("CD".id)::text)) AND (geoch_sampling.opid = "CD".opid)) AND ((geoch_sampling.id)::text = ("SB".id)::text)) AND (geoch_sampling.opid = "SB".opid)) AND ((geoch_sampling.id)::text = ("BI".id)::text)) AND (geoch_sampling.opid = "BI".opid)) AND ((geoch_sampling.id)::text = ("V".id)::text)) AND (geoch_sampling.opid = "V".opid)) AND ((geoch_sampling.id)::text = ("CA".id)::text)) AND (geoch_sampling.opid = "CA".opid)) AND ((geoch_sampling.id)::text = ("P".id)::text)) AND (geoch_sampling.opid = "P".opid)) AND ((geoch_sampling.id)::text = ("LA".id)::text)) AND (geoch_sampling.opid = "LA".opid)) AND ((geoch_sampling.id)::text = ("CR".id)::text)) AND (geoch_sampling.opid = "CR".opid)) AND ((geoch_sampling.id)::text = ("HG".id)::text)) AND (geoch_sampling.opid = "HG".opid)) AND ((geoch_sampling.id)::text = ("TL".id)::text)) AND (geoch_sampling.opid = "TL".opid)) AND ((geoch_sampling.id)::text = ("GA".id)::text)) AND (geoch_sampling.opid = "GA".opid)) AND ((geoch_sampling.id)::text = ("SC".id)::text)) AND (geoch_sampling.opid = "SC".opid)) AND (("MO".ana_type)::text = 'MO'::text)) AND (("CU".ana_type)::text = 'CU'::text)) AND (("PB".ana_type)::text = 'PB'::text)) AND (("ZN".ana_type)::text = 'ZN'::text)) AND (("AG".ana_type)::text = 'AG'::text)) AND (("NI".ana_type)::text = 'NI'::text)) AND (("CO".ana_type)::text = 'CO'::text)) AND (("MN".ana_type)::text = 'MN'::text)) AND (("FE".ana_type)::text = 'FE'::text)) AND (("AS".ana_type)::text = 'AS'::text)) AND (("TH".ana_type)::text = 'TH'::text)) AND (("SR".ana_type)::text = 'SR'::text)) AND (("CD".ana_type)::text = 'CD'::text)) AND (("SB".ana_type)::text = 'SB'::text)) AND (("BI".ana_type)::text = 'BI'::text)) AND (("V".ana_type)::text = 'V'::text)) AND (("CA".ana_type)::text = 'CA'::text)) AND (("P".ana_type)::text = 'P'::text)) AND (("LA".ana_type)::text = 'LA'::text)) AND (("CR".ana_type)::text = 'CR'::text)) AND (("HG".ana_type)::text = 'HG'::text)) AND (("TL".ana_type)::text = 'TL'::text)) AND (("GA".ana_type)::text = 'GA'::text)) AND (("SC".ana_type)::text = 'SC'::text));

CREATE VIEW tanguy.geoch_multi_ana_subq AS
    SELECT geoch_sampling.id, geoch_sampling.sampl_index, "MO".no_ech, "MO".unit AS "UNIT_MO", "MO".value AS "MO_VALUE", "CU".unit AS "UNIT_CU", "CU".value AS "CU_VALUE", "PB".unit AS "UNIT_PB", "PB".value AS "PB_VALUE", "ZN".unit AS "UNIT_ZN", "ZN".value AS "ZN_VALUE", "AG".unit AS "UNIT_AG", "AG".value AS "AG_VALUE", "NI".unit AS "UNIT_NI", "NI".value AS "NI_VALUE", "CO".unit AS "UNIT_CO", "CO".value AS "CO_VALUE", "MN".unit AS "UNIT_MN", "MN".value AS "MN_VALUE", "FE".unit AS "UNIT_FE", "FE".value AS "FE_VALUE", "AS".unit AS "UNIT_AS", "AS".value AS "AS_VALUE", "TH".unit AS "UNIT_TH", "TH".value AS "TH_VALUE", "CD".unit AS "UNIT_CD", "CD".value AS "CD_VALUE", "SB".unit AS "UNIT_SB", "SB".value AS "SB_VALUE", "BI".unit AS "UNIT_BI", "BI".value AS "BI_VALUE", "V".unit AS "UNIT_V", "V".value AS "V_VALUE", "CA".unit AS "UNIT_CA", "CA".value AS "CA_VALUE", "P".unit AS "UNIT_P", "P".value AS "P_VALUE", "LA".unit AS "UNIT_LA", "LA".value AS "LA_VALUE", "CR".unit AS "UNIT_CR", "CR".value AS "CR_VALUE", "HG".unit AS "UNIT_HG", "HG".value AS "HG_VALUE", "TL".unit AS "UNIT_TL", "TL".value AS "TL_VALUE", "GA".unit AS "UNIT_GA", "GA".value AS "GA_VALUE", "SC".unit AS "UNIT_SC", "SC".value AS "SC_VALUE" FROM (((((((((((((((((((((((public.geoch_sampling LEFT JOIN (SELECT geoch_ana.no_ech, geoch_ana.id, geoch_ana.unit, geoch_ana.value FROM public.geoch_ana WHERE ((geoch_ana.qaqc_type IS NULL) AND ((geoch_ana.ana_type)::text = 'MO'::text))) "MO" ON (((geoch_sampling.id)::text = ("MO".id)::text))) LEFT JOIN (SELECT geoch_ana.id, geoch_ana.unit, geoch_ana.value FROM public.geoch_ana WHERE ((geoch_ana.qaqc_type IS NULL) AND ((geoch_ana.ana_type)::text = 'CU'::text))) "CU" ON (((geoch_sampling.id)::text = ("CU".id)::text))) LEFT JOIN (SELECT geoch_ana.id, geoch_ana.unit, geoch_ana.value FROM public.geoch_ana WHERE ((geoch_ana.qaqc_type IS NULL) AND ((geoch_ana.ana_type)::text = 'PB'::text))) "PB" ON (((geoch_sampling.id)::text = ("PB".id)::text))) LEFT JOIN (SELECT geoch_ana.id, geoch_ana.unit, geoch_ana.value FROM public.geoch_ana WHERE ((geoch_ana.qaqc_type IS NULL) AND ((geoch_ana.ana_type)::text = 'ZN'::text))) "ZN" ON (((geoch_sampling.id)::text = ("ZN".id)::text))) LEFT JOIN (SELECT geoch_ana.id, geoch_ana.unit, geoch_ana.value FROM public.geoch_ana WHERE ((geoch_ana.qaqc_type IS NULL) AND ((geoch_ana.ana_type)::text = 'AG'::text))) "AG" ON (((geoch_sampling.id)::text = ("AG".id)::text))) LEFT JOIN (SELECT geoch_ana.id, geoch_ana.unit, geoch_ana.value FROM public.geoch_ana WHERE ((geoch_ana.qaqc_type IS NULL) AND ((geoch_ana.ana_type)::text = 'NI'::text))) "NI" ON (((geoch_sampling.id)::text = ("NI".id)::text))) LEFT JOIN (SELECT geoch_ana.id, geoch_ana.unit, geoch_ana.value FROM public.geoch_ana WHERE ((geoch_ana.qaqc_type IS NULL) AND ((geoch_ana.ana_type)::text = 'CO'::text))) "CO" ON (((geoch_sampling.id)::text = ("CO".id)::text))) LEFT JOIN (SELECT geoch_ana.id, geoch_ana.unit, geoch_ana.value FROM public.geoch_ana WHERE ((geoch_ana.qaqc_type IS NULL) AND ((geoch_ana.ana_type)::text = 'MN'::text))) "MN" ON (((geoch_sampling.id)::text = ("MN".id)::text))) LEFT JOIN (SELECT geoch_ana.id, geoch_ana.unit, geoch_ana.value FROM public.geoch_ana WHERE ((geoch_ana.qaqc_type IS NULL) AND ((geoch_ana.ana_type)::text = 'FE'::text))) "FE" ON (((geoch_sampling.id)::text = ("FE".id)::text))) LEFT JOIN (SELECT geoch_ana.id, geoch_ana.unit, geoch_ana.value FROM public.geoch_ana WHERE ((geoch_ana.qaqc_type IS NULL) AND ((geoch_ana.ana_type)::text = 'AS'::text))) "AS" ON (((geoch_sampling.id)::text = ("AS".id)::text))) LEFT JOIN (SELECT geoch_ana.id, geoch_ana.unit, geoch_ana.value FROM public.geoch_ana WHERE ((geoch_ana.qaqc_type IS NULL) AND ((geoch_ana.ana_type)::text = 'TH'::text))) "TH" ON (((geoch_sampling.id)::text = ("TH".id)::text))) LEFT JOIN (SELECT geoch_ana.id, geoch_ana.unit, geoch_ana.value FROM public.geoch_ana WHERE ((geoch_ana.qaqc_type IS NULL) AND ((geoch_ana.ana_type)::text = 'CD'::text))) "CD" ON (((geoch_sampling.id)::text = ("CD".id)::text))) LEFT JOIN (SELECT geoch_ana.id, geoch_ana.unit, geoch_ana.value FROM public.geoch_ana WHERE ((geoch_ana.qaqc_type IS NULL) AND ((geoch_ana.ana_type)::text = 'SB'::text))) "SB" ON (((geoch_sampling.id)::text = ("SB".id)::text))) LEFT JOIN (SELECT geoch_ana.id, geoch_ana.unit, geoch_ana.value FROM public.geoch_ana WHERE ((geoch_ana.qaqc_type IS NULL) AND ((geoch_ana.ana_type)::text = 'BI'::text))) "BI" ON (((geoch_sampling.id)::text = ("BI".id)::text))) LEFT JOIN (SELECT geoch_ana.id, geoch_ana.unit, geoch_ana.value FROM public.geoch_ana WHERE ((geoch_ana.qaqc_type IS NULL) AND ((geoch_ana.ana_type)::text = 'V'::text))) "V" ON (((geoch_sampling.id)::text = ("V".id)::text))) LEFT JOIN (SELECT geoch_ana.id, geoch_ana.unit, geoch_ana.value FROM public.geoch_ana WHERE ((geoch_ana.qaqc_type IS NULL) AND ((geoch_ana.ana_type)::text = 'CA'::text))) "CA" ON (((geoch_sampling.id)::text = ("CA".id)::text))) LEFT JOIN (SELECT geoch_ana.id, geoch_ana.unit, geoch_ana.value FROM public.geoch_ana WHERE ((geoch_ana.qaqc_type IS NULL) AND ((geoch_ana.ana_type)::text = 'P'::text))) "P" ON (((geoch_sampling.id)::text = ("P".id)::text))) LEFT JOIN (SELECT geoch_ana.id, geoch_ana.unit, geoch_ana.value FROM public.geoch_ana WHERE ((geoch_ana.qaqc_type IS NULL) AND ((geoch_ana.ana_type)::text = 'LA'::text))) "LA" ON (((geoch_sampling.id)::text = ("LA".id)::text))) LEFT JOIN (SELECT geoch_ana.id, geoch_ana.unit, geoch_ana.value FROM public.geoch_ana WHERE ((geoch_ana.qaqc_type IS NULL) AND ((geoch_ana.ana_type)::text = 'CR'::text))) "CR" ON (((geoch_sampling.id)::text = ("CR".id)::text))) LEFT JOIN (SELECT geoch_ana.id, geoch_ana.unit, geoch_ana.value FROM public.geoch_ana WHERE ((geoch_ana.qaqc_type IS NULL) AND ((geoch_ana.ana_type)::text = 'HG'::text))) "HG" ON (((geoch_sampling.id)::text = ("HG".id)::text))) LEFT JOIN (SELECT geoch_ana.id, geoch_ana.unit, geoch_ana.value FROM public.geoch_ana WHERE ((geoch_ana.qaqc_type IS NULL) AND ((geoch_ana.ana_type)::text = 'TL'::text))) "TL" ON (((geoch_sampling.id)::text = ("TL".id)::text))) LEFT JOIN (SELECT geoch_ana.id, geoch_ana.unit, geoch_ana.value FROM public.geoch_ana WHERE ((geoch_ana.qaqc_type IS NULL) AND ((geoch_ana.ana_type)::text = 'GA'::text))) "GA" ON (((geoch_sampling.id)::text = ("GA".id)::text))) LEFT JOIN (SELECT geoch_ana.id, geoch_ana.unit, geoch_ana.value FROM public.geoch_ana WHERE ((geoch_ana.qaqc_type IS NULL) AND ((geoch_ana.ana_type)::text = 'SC'::text))) "SC" ON (((geoch_sampling.id)::text = ("SC".id)::text))) WHERE (geoch_sampling.id IS NOT NULL);

--CREATE VIEW tanguy.surp_collar AS
--   SELECT dh_collars.id AS hole_id, COALESCE(dh_collars.location, 'undefined'::character varying) AS project_id, dh_collars.x, dh_collars.y, dh_collars.z, dh_collars.length AS max_depth, dh_collars.profile, dh_collars.azim_ng AS azimuth, 'CURVED' AS hole_path, (- dh_collars.dip_hz) AS dip, dh_collars.dh_type, dh_collars.date_start, dh_collars.contractor, dh_collars.geologist, dh_collars.len_destr, dh_collars.len_pq, dh_collars.len_hq, dh_collars.len_nq, dh_collars.len_bq, dh_collars.nb_samples, dh_collars.comments, dh_collars.completed, dh_collars.datasource, dh_collars.date_completed, dh_collars.id_pject, dh_collars.x_pject, dh_collars.y_pject, dh_collars.z_pject FROM public.dh_collars;
--COMMENT ON VIEW tanguy.surp_collar IS 'Vue formatée collar pour Surpac';
--CREATE VIEW tanguy.surp_litho AS
--    SELECT dh_litho.id AS hole_id, dh_litho.depfrom AS depth_from, dh_litho.depto AS depth_to, dh_litho.description, dh_litho.code1, dh_litho.code2, dh_litho.code3, dh_litho.code4, dh_litho.value1, dh_litho.value2, dh_litho.value3, dh_litho.value4, dh_litho.litho_simple, dh_litho.colour, dh_litho.datasource, dh_litho.description1, dh_litho.description2, dh_litho.value5, dh_litho.value6 FROM public.dh_litho;
--COMMENT ON VIEW tanguysurp_litho IS 'Vue formatée litho pour Surpac';
--CREATE VIEW tanguysurp_project AS
--    SELECT DISTINCT COALESCE(dh_collars.location, 'undefined'::character varying) AS project_id FROM public.dh_collars;
--COMMENT ON VIEW tanguysurp_project IS 'Vue formatée project pour Surpac';
--CREATE VIEW tanguysurp_sampling AS
--    SELECT dh_sampling_grades.id AS hole_id, dh_sampling_grades.depfrom AS depth_from, dh_sampling_grades.depto AS depth_to, dh_sampling_grades.core_loss_cm, dh_sampling_grades.weight_kg, dh_sampling_grades.sample_type, dh_sampling_grades.sample_id, dh_sampling_grades.comments, dh_sampling_grades.batch_id, dh_sampling_grades.moisture, dh_sampling_grades.au1_ppm, dh_sampling_grades.au2_ppm, dh_sampling_grades.au3_ppm, dh_sampling_grades.au4_ppm, dh_sampling_grades.au5_ppm, dh_sampling_grades.au6_ppm, dh_sampling_grades.ag_ppm, dh_sampling_grades.cu_perc, dh_sampling_grades.pb_perc, dh_sampling_grades.zn_perc, dh_sampling_grades.s_perc, dh_sampling_grades.fe_perc, dh_sampling_grades.al_perc, dh_sampling_grades.k_perc, dh_sampling_grades.mg_perc, dh_sampling_grades.ca_perc, dh_sampling_grades.mn_ppm, dh_sampling_grades.as_ppm, dh_sampling_grades.ph FROM public.dh_sampling_grades;
--CREATE VIEW tanguysurp_survey AS
--    SELECT dh_devia.id AS hole_id, dh_devia.depto AS depth, dh_devia.azim_ng AS azimuth, (- dh_devia.dip_hz) AS dip, dh_devia.temperature, dh_devia.magnetic, dh_devia.date, dh_devia.roll, dh_devia."time", dh_devia.comments, dh_devia.valid, dh_devia.azim_nm, dh_devia.datasource, dh_devia.device FROM public.dh_devia WHERE dh_devia.valid;
--COMMENT ON VIEW tanguysurp_survey IS 'Vue formatée survey pour Surpac';
--
*/

--}}}
COMMIT;
" | psql -X -h $GLL_BD_HOST -p $GLL_BD_PORT -U $GLL_BD_USER -d $GLL_BD_NAME
