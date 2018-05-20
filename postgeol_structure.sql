-- _______________ENCOURS_______________GEOLLLIBRE 1
-- LIGNES:     0 en-tête, licence, rien et TODOs
--            90 des trucs en en-tête du dump
--           100 liste objets de bdexplo, ordonnée
--          1100 création base, schémas
-- ==>      1200 création tables  <==
--         10000 le reste...

--TODO liste:{{{
-- o faire le rôle data_admin, et les autres rôles "génériques" (groupes)
-- o d'autres rôles du genre db_admin, etc.
-- e mettre des types comme conseillé dans (? cf. twitter), par exemple des TEXT au lieu de VARCHAR => bigserial au lieu de serial: fait; ...
-- o check all owners to data_admin
-- o ajouter des CONSTRAINT PRIMARY KEY où nécessaire, ou plutôt des trucs comme: ("CREATE TABLE test (id bigserial PRIMARY KEY, num integer, data text);")
-- o mettre des NOT NULL un peu partout

-- o Il faudrait lancer ce script comme un administrateur,
--     avec des arguments:
--       - le rôle "utilisateur lambda" à utiliser;
--       - le ou les rôles "utilisateur admin"
--       - le nom de la base à créer, si différent de postgeol
-- Quelque chose dans le genre:
--    psql -v normal_user="pierre" -v postgeol_newdb_name="test_postgeol" -f postgeol_structure.sql
--    :normal_user

-- fait:{{{

-- x mettre les numauto en:     numauto             bigserial UNIQUE NOT NULL,
-- x mettre tous les numauto en bigserial PRIMARY KEY
-- x mettre tous les: REFERENCES operations (opid)


--}}}
-- }}}

-- DEBUG: ATTENTION AUX /* */  =>  /\/\*\|\*\/
-- :set foldmarker=/*,*/

--{{{ En-tête, copyright
--	Title:   "Structure of POSTGEOL database: PostgreSQL database for GEOLogical data"
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
--		  Copyright (C) 2017 Pierre Chevalier <pierrechevaliergeol@free.fr>
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
--}}}

--NON --{{{
--*****************************************************************
-- ********************** ça vient de OPM
-- This program is open source, licensed under the PostgreSQL License.   <= prendre cette license? @#demander Julien
-- For license terms, see the LICENSE file.
-- Copyright (C) 2012-2015: Open PostgreSQL Monitoring Development Group
-- complain if script is sourced in psql, rather than via CREATE EXTENSION
--*****************************************************************









--}}}
--  0090 Ceci était en tête du dump:{{{

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--}}}
-- 0100 LISTE OBJETS DE BDEXPLO:{{{

/* la liste des objets de bdexplo, en ayant fait le ménage:
tables:{{{
--localhost pierre@bdexplo=>
\dt *.*
                                          Liste des relations
       Schéma       |                            Nom                             | Type  | Propriétaire
--------------------+------------------------------------------------------------+-------+--------------
 public             | doc_bdexplo_table_categories      <= refactoré             | table | pierre
 public             | doc_bdexplo_tables_descriptions   <= refactoré             | table | pierre

 public             | operations                                                 | table | data_admin
 public             | operation_active                                           | table | data_admin

 public             | field_observations                                         | table | data_admin
 public             | field_observations_struct_measures                         | table | data_admin
 public             | field_photos                                               | table | data_admin
 public             | formations_group_lithos                                    | table | data_admin
 pierre             | rock_sampling                                              | table | pierre
 pierre             | rock_ana                                                   | table | pierre
 public             | surface_samples_grades                                     | table | data_admin
 pierre             | gps_wpt                                                    | table | pierre

 public             | geoch_sampling                                             | table | data_admin
 public             | geoch_ana                                                  | table | data_admin
 public             | geoch_sampling_grades                                      | table | data_admin

 public             | gpy_mag_ground                                             | table | data_admin

 public             | dh_collars                                                 | table | data_admin
 public             | shift_reports                                              | table | data_admin   <= RENOMMÉE en dh_, ATTENTION! TODO vérifier que TVB
 public             | dh_followup                                                | table | data_admin
 public             | dh_devia                                                   | table | data_admin
 public             | dh_quicklog                                                | table | data_admin
 public             | dh_litho                                                   | table | data_admin
 public             | dh_core_boxes                                              | table | data_admin
 public             | dh_tech                                                    | table | data_admin
 public             | dh_struct_measures                                         | table | data_admin
 pierre             | dh_photos                                                  | table | pierre
 pierre             | dh_samples_submission                                      | table | pierre
 public             | dh_sampling_grades                                         | table | data_admin
 public             | dh_mineralised_intervals                                   | table | data_admin
 public             | dh_density                                                 | table | data_admin
 public             | dh_thinsections                                            | table | data_admin
 public             | dh_sampling_bottle_roll                                    | table | data_admin

 pierre             | dh_collars_lengths                                         | table | pierre

 public             | lab_ana_batches_expedition                                 | table | data_admin
 public             | lab_ana_batches_reception                                  | table | data_admin
 pierre             | lab_ana_batches_reception_18_corr                          | table | pierre
 public             | lab_ana_columns_definition                                 | table | data_admin
 pierre             | ana_det_limit                                              | table | pierre
 public             | lab_ana_results                                            | table | data_admin
 pierre             | lab_analysis_icp                                           | table | pierre
 public             | lab_ana_qaqc_results                                       | table | data_admin

 public             | qc_sampling                                                | table | data_admin
 public             | qc_standards                                               | table | data_admin

 public             | ancient_workings                                           | table | data_admin
 public             | occurrences                                                | table | data_admin

 public             | licences                                                   | table | data_admin

 public             | grade_ctrl                                                 | table | data_admin

 public             | lex_codes                                                  | table | data_admin
 public             | lex_datasource                                             | table | data_admin
 public             | lex_standard                                               | table | data_admin

 public             | mag_declination                                            | table | data_admin
 public             | topo_points                                                | table | data_admin
 public             | survey_lines                                               | table | pierre
 public             | units                                                      | table | pierre
 public             | baselines                                                  | table | data_admin
 pierre             | sections_definition                                        | table | pierre
 pierre             | sections_array                                             | table | pierre
 public             | conversions_oxydes_elements                                | table | pierre
 public             | index_geo_documentation                                    | table | data_admin
 pierre             | layer_styles                                               | table | pierre
 pierre             | program                                                    | table | pierre

 public             | occurrences_recup_depuis_dump                              | table | data_admin

 pierre             | dh_nb_samples                                              | table | pierre    <= inutile
 pierre             | grid                                                       | table | pierre
 pierre             | tmp_xy                                                     | table | pierre
 pierre             | tmp_xyz_marec                                              | table | pierre
 pierre             | toudoux_dh_sampling_grades_datasource_979                  | table | pierre
 pierre             | tt_bdexplo_lex_datasource_autan                            | table | pierre
 pierre             | tt_bdexplo_lex_labo_analysis_autan                         | table | pierre

 tmp_a_traiter      | bondoukou_alain_lambert_acp                                | table | pierre
 tmp_a_traiter      | bondoukou_alain_lambert_au_ou_icp                          | table | pierre
 tmp_a_traiter      | bondoukou_alain_lambert_cah                                | table | pierre
 tmp_a_traiter      | bondoukou_alain_lambert_cah7                               | table | pierre
 tmp_a_traiter      | bondoukou_alain_lambert_coor                               | table | pierre
 tmp_a_traiter      | bondoukou_alain_lambert_coor_icp                           | table | pierre
 tmp_a_traiter      | bondoukou_alain_lambert_icp                                | table | pierre
 tmp_a_traiter      | bondoukou_alain_lambert_or                                 | table | pierre
 tmp_a_traiter      | bondoukou_alain_lambert_tarkw_cah_3                        | table | pierre
 tmp_a_traiter      | bondoukou_alain_lambert_tout                               | table | pierre
 tmp_a_traiter      | bondoukou_alain_lambert_vx_tvx                             | table | pierre
 tmp_a_traiter      | soil_geoch_bondoukou                                       | table | pierre
 tmp_a_traiter      | tmp_auramines_feb_march_sample_list_xlsx_01_main_list      | table | pierre
 tmp_a_traiter      | tmp_auramines_feb_march_sample_list_xlsx_02_dhl_ireland    | table | pierre
 tmp_a_traiter      | tmp_auramines_feb_march_sample_list_xlsx_03_dhl_france     | table | pierre
 tmp_a_traiter      | tmp_auramines_feb_march_sample_list_xlsx_04_sheet_for_omac | table | pierre
 tmp_a_traiter      | tmp_auramines_field_observations                           | table | pierre
 tmp_a_traiter      | tmp_bondoukou_geoch_sol                                    | table | pierre
 tmp_a_traiter      | tmp_bondoukou_sondages_collars                             | table | pierre
 tmp_a_traiter      | tmp_bondoukou_sondages_sampling_grades                     | table | pierre
 tmp_a_traiter      | tmp_bv130613_gravi_results                                 | table | pierre

 tmp_imports        | orientation                                                | table | pierre
 tmp_imports        | poi                                                        | table | pierre
 tmp_imports        | tmp_assay_results_auramines_ns30n                          | table | pierre
 tmp_imports        | tmp_cme_sampling_grades_150102                             | table | pierre
 tmp_imports        | tmp_cme_sampling_grades_150102_utf8                        | table | pierre
 tmp_imports        | tmp_collars_141027_utf8                                    | table | pierre
 tmp_imports        | tmp_collars_141223                                         | table | pierre
 tmp_imports        | tmp_collars_141223_utf8                                    | table | pierre
 tmp_imports        | tmp_entree_donnees_dh_tech                                 | table | pierre
 tmp_imports        | tmp_erreur_z                                               | table | pierre
 tmp_imports        | tmp_esp_pgm_cr_140908_                                     | table | pierre
 tmp_imports        | tmp_export_geolpda_waypoints_descriptions                  | table | pierre
 tmp_imports        | tmp_ext1                                                   | table | pierre
 tmp_imports        | tmp_ext2                                                   | table | pierre
 tmp_imports        | tmp_ext3                                                   | table | pierre
 tmp_imports        | tmp_ext4                                                   | table | pierre
 tmp_imports        | tmp_ext5                                                   | table | pierre
 tmp_imports        | tmp_ext6                                                   | table | pierre
 tmp_imports        | tmp_ext7                                                   | table | pierre
 tmp_imports        | tmp_field_observations_struct_measures                     | table | pierre
 tmp_imports        | tmp_geolpda_orientations                                   | table | pierre
 tmp_imports        | tmp_geolpda_picks                                          | table | pierre
 tmp_imports        | tmp_ity_gpspolo_travaux_97et2004                           | table | pierre
 tmp_imports        | tmp_log_tech                                               | table | pierre
 tmp_imports        | tmp_lr15201855                                             | table | pierre
 tmp_imports        | tmp_observations_pch_guyane_2011_2014                      | table | pierre
 tmp_imports        | tmp_s001                                                   | table | pierre
 tmp_imports        | tmp_s001_corr                                              | table | pierre
 tmp_imports        | tmp_s003_corr                                              | table | pierre
 tmp_imports        | tmp_s005_corr                                              | table | pierre
 tmp_imports        | tmp_sample_description_and_coords_november_2015_paul       | table | pierre
 tmp_imports        | tmp_sondages_est_cavally_resume_fiche_tech                 | table | pierre
 tmp_imports        | tmp_sondages_est_cavally_resume_mineralisation             | table | pierre
 tmp_imports        | tmp_surface_samples_grades                                 | table | pierre
 tmp_imports        | tmp_surface_sampling_141027                                | table | pierre
 tmp_imports        | tmp_surface_sampling_141027_utf8                           | table | pierre
 tmp_imports        | tmp_survey_141027                                          | table | pierre
 tmp_imports        | tmp_survey_141223                                          | table | pierre
 tmp_imports        | tmp_tmp_dactylo_litho                                      | table | pierre
 tmp_imports        | tmp_tmp_field_observations_struct_measures                 | table | pierre
 tmp_imports        | tmp_tmp_structures                                         | table | pierre
 tmp_imports        | tmp_tt                                                     | table | pierre
 tmp_imports        | tmp_tt_omac_sample_list_update                             | table | pierre
 tmp_imports        | tmp_tt_pierre_nettoye_uploader_wpt                         | table | pierre
 tmp_imports        | tmp_tt_programme_esperance                                 | table | pierre
 tmp_imports        | tmp_tt_pts_gps_mdb_copie                                   | table | pierre
 tmp_imports        | tmp_tt_pts_gps_mdb_fichiers                                | table | pierre
 tmp_imports        | tmp_tt_pts_gps_mdb_fsdrg                                   | table | pierre
 tmp_imports        | tmp_tt_pts_gps_mdb_points_latlong                          | table | pierre
 tmp_imports        | tmp_tt_pts_gps_mdb_sdqrfgadzrg                             | table | pierre
 tmp_imports        | tmp_tt_pts_gps_mdb_vireendb                                | table | pierre
 tmp_imports        | tmp_tt_surface_samples                                     | table | pierre
 tmp_imports        | tmp_tt_translation_fr2en                                   | table | pierre
 tmp_imports        | tmp_waypoints_blaz_sudan_2015_02                           | table | pierre
 tmp_imports        | tmp_waypoints_descriptions                                 | table | pierre
 tmp_imports        | tmp_waypoints_descriptions_bricolage                       | table | pierre
 tmp_imports        | tmp_xtr_dh_collars                                         | table | pierre
 tmp_imports        | tmp_xtr_field_observations                                 | table | pierre

 tmp_ntoto          | bound_e                                                    | table | pierre
 tmp_ntoto          | brgm_au                                                    | table | pierre
 tmp_ntoto          | codes                                                      | table | pierre
 tmp_ntoto          | contact                                                    | table | pierre
 tmp_ntoto          | density                                                    | table | pierre
 tmp_ntoto          | devia                                                      | table | pierre
 tmp_ntoto          | formatio                                                   | table | pierre
 tmp_ntoto          | geotec                                                     | table | pierre
 tmp_ntoto          | headers                                                    | table | pierre
 tmp_ntoto          | kendril2                                                   | table | pierre
 tmp_ntoto          | lithaufu                                                   | table | pierre
 tmp_ntoto          | litho                                                      | table | pierre
 tmp_ntoto          | mag                                                        | table | pierre
 tmp_ntoto          | mask                                                       | table | pierre
 tmp_ntoto          | mine                                                       | table | pierre
 tmp_ntoto          | outline                                                    | table | pierre
 tmp_ntoto          | quicklog                                                   | table | pierre
 tmp_ntoto          | rank                                                       | table | pierre
 tmp_ntoto          | sampling                                                   | table | pierre
 tmp_ntoto          | sgs_au                                                     | table | pierre
 tmp_ntoto          | sgsrecod                                                   | table | pierre
 tmp_ntoto          | soil                                                       | table | pierre
 tmp_ntoto          | statrenc                                                   | table | pierre
 tmp_ntoto          | struc                                                      | table | pierre
 tmp_ntoto          | submit                                                     | table | pierre
 tmp_ntoto          | thisecti                                                   | table | pierre
 tmp_ntoto          | tr_au                                                      | table | pierre
 tmp_ntoto          | tr_litho                                                   | table | pierre
 tmp_ntoto          | vchannau                                                   | table | pierre
 tmp_ntoto          | vchannel                                                   | table | pierre

 backups            | field_observations_2016_03_09_14h08                        | table | pierre
 backups            | field_observations_struct_measures_2016_03_09_14h10        | table | pierre

poubelle, ignorer:
 pierre             | t2                                                         | table | pierre

(252 lignes)

-- }}}
vues:{{{
--localhost pierre@bdexplo=>
\dv *.*
                                           Liste des relations
       Schéma       |                             Nom                              | Type | Propriétaire
--------------------+--------------------------------------------------------------+------+--------------
 checks             | collars_lengths_vs_dh_litho_depths                           | vue  | pierre
 checks             | collars_lengths_vs_dh_sampling_depths                        | vue  | pierre
 checks             | collars_vs_temp_topo_id_topo_sans_collars                    | vue  | pierre
 checks             | collars_vs_topo_xyz_en_face_et_differences_importantes       | vue  | pierre
 checks             | dh_collars_to_topo_points_lines                              | vue  | pierre
 checks             | doublons_collars_id                                          | vue  | pierre
 checks             | doublons_collars_xyz                                         | vue  | pierre
 checks             | doublons_collars_xyz_ouvrages_concernes                      | vue  | pierre
 checks             | doublons_dh_litho_id_depto                                   | vue  | pierre
 checks             | doublons_dh_sampling_id_depto                                | vue  | pierre
 checks             | fichettes_infos_incoherentes_drilled_lengths                 | vue  | pierre
 checks             | fichettes_infos_incoherentes_heures                          | vue  | pierre
 checks             | fichettes_infos_redondantes_incoherentes                     | vue  | pierre
 checks             | fichettes_infos_redondantes_incoherentes_quels_ouvrages      | vue  | pierre
 checks             | fichettes_longueurs_incoherentes                             | vue  | pierre
 checks             | fichettes_ouvrages_non_completed                             | vue  | pierre
 checks             | fichettes_vs_collars_completed_incoherents                   | vue  | pierre
 checks             | fichettes_vs_collars_longueurs_incoherentes                  | vue  | pierre
 checks             | fichettes_vs_collars_ouvrages_dans_fichettes_pas_collars     | vue  | pierre
 checks             | tetes_passes_ouvrages_dans_passes_pas_dans_tetes_dh_litho    | vue  | pierre
 checks             | tetes_passes_ouvrages_dans_passes_pas_dans_tetes_dh_sampling | vue  | pierre
 checks             | tetes_passes_ouvrages_dans_tetes_pas_dans_passes_dh_litho    | vue  | pierre
 checks             | tetes_passes_ouvrages_dans_tetes_pas_dans_passes_dh_sampling | vue  | pierre

 gdm                | gdm_dh_devia                                                 | vue  | pierre
 gdm                | gdm_sections_array                                           | vue  | pierre
 gdm                | gdm_selection                                                | vue  | pierre

 pierre             | ancient_workings                                             | vue  | pierre
 pierre             | baselines                                                    | vue  | pierre
 pierre             | collars_selection                                            | vue  | pierre
 pierre             | coords_points                                                | vue  | pierre
 pierre             | dh_collars                                                   | vue  | pierre
 pierre             | dh_collars_                                                  | vue  | pierre
 pierre             | dh_collars_diff_project_actual_line                          | vue  | pierre
 pierre             | dh_collars_for_gpx                                           | vue  | pierre
 pierre             | dh_collars_points                                            | vue  | pierre
 pierre             | dh_collars_points_last_ana_results                           | vue  | pierre
 pierre             | dh_collars_points_marrec                                     | vue  | pierre
 pierre             | dh_core_boxes                                                | vue  | pierre
 pierre             | dh_density                                                   | vue  | pierre
 pierre             | dh_devia                                                     | vue  | pierre
 pierre             | dh_followup                                                  | vue  | pierre
 pierre             | dh_litho                                                     | vue  | pierre
 pierre             | dh_mineralised_intervals                                     | vue  | pierre
 pierre             | dh_mineralised_intervals0_traces_3d                          | vue  | pierre
 pierre             | dh_quicklog                                                  | vue  | pierre
 pierre             | dh_sampling                                                  | vue  | pierre
 pierre             | dh_sampling_avg_grades_3dpoints                              | vue  | pierre
 pierre             | dh_sampling_bottle_roll                                      | vue  | pierre
 pierre             | dh_sampling_grades                                           | vue  | pierre
 pierre             | dh_sampling_grades_graph_au_6                                | vue  | pierre
 pierre             | dh_sampling_grades_open_ended_au_tail                        | vue  | pierre
 pierre             | dh_sampling_grades_open_ended_au_top                         | vue  | pierre
 pierre             | dh_sampling_mineralised_intervals_graph_au6                  | vue  | pierre
 pierre             | dh_struct_measures                                           | vue  | pierre
 pierre             | dh_tech                                                      | vue  | pierre
 pierre             | dh_thinsections                                              | vue  | pierre
 pierre             | dh_traces_3d                                                 | vue  | pierre
 pierre             | field_observations                                           | vue  | pierre
 pierre             | field_observations_points                                    | vue  | pierre
 pierre             | field_observations_struct_measures                           | vue  | pierre
 pierre             | field_photos                                                 | vue  | pierre
 pierre             | formations_group_lithos                                      | vue  | pierre
 pierre             | gdm_baselines                                                | vue  | pierre
 pierre             | gdm_dh_devia                                                 | vue  | pierre
 pierre             | gdm_dh_litho                                                 | vue  | pierre
 pierre             | gdm_dh_mine_0                                                | vue  | pierre
 pierre             | gdm_dh_mine_1                                                | vue  | pierre
 pierre             | gdm_dh_planned                                               | vue  | pierre
 pierre             | gdm_dh_sampling_grades                                       | vue  | pierre
 pierre             | gdm_dh_sampling_grades_open_ended_au_tail                    | vue  | pierre
 pierre             | gdm_dh_sampling_grades_open_ended_au_top                     | vue  | pierre
 pierre             | gdm_sections_array                                           | vue  | pierre
 pierre             | gdm_selection                                                | vue  | pierre
 pierre             | geoch_ana                                                    | vue  | pierre
 pierre             | geoch_sampling                                               | vue  | pierre
 pierre             | geoch_sampling_grades                                        | vue  | pierre
 pierre             | geoch_sampling_grades_points                                 | vue  | pierre
 pierre             | gpy_mag_ground                                               | vue  | pierre
 pierre             | grade_ctrl                                                   | vue  | pierre
 pierre             | index_geo_documentation                                      | vue  | pierre
 pierre             | lab_ana_batches_expedition                                   | vue  | pierre
 pierre             | lab_ana_batches_reception                                    | vue  | pierre
 pierre             | lab_ana_columns_definition                                   | vue  | pierre
 pierre             | lab_ana_qaqc_results                                         | vue  | pierre
 pierre             | lab_ana_results                                              | vue  | pierre
 pierre             | lex_codes                                                    | vue  | pierre
 pierre             | lex_datasource                                               | vue  | pierre
 pierre             | lex_standard                                                 | vue  | pierre
 pierre             | licences                                                     | vue  | pierre
 pierre             | licences_quadrangles                                         | vue  | pierre
 pierre             | mag_declination                                              | vue  | pierre
 pierre             | occurrences                                                  | vue  | pierre
 pierre             | occurrences_                                                 | vue  | pierre
 pierre             | occurrences_bal_200km                                        | vue  | pierre
 pierre             | operations_quadrangles                                       | vue  | pierre
 pierre             | petro_mineralo_study_dh_collars                              | vue  | pierre
 pierre             | petro_mineralo_study_field_observations_points               | vue  | pierre
 pierre             | qc_sampling                                                  | vue  | pierre
 pierre             | qc_standards                                                 | vue  | pierre
 pierre             | shift_reports                                                | vue  | pierre
 pierre             | surface_samples_grades                                       | vue  | pierre
 pierre             | surface_samples_grades_points                                | vue  | pierre
 pierre             | surpac_survey                                                | vue  | pierre
 pierre             | tanguysurp_project                                           | vue  | postgres
 pierre             | tanguysurp_survey                                            | vue  | postgres
 pierre             | tmp_xy_points                                                | vue  | pierre
 pierre             | topo_points                                                  | vue  | pierre
 pierre             | topo_points_points                                           | vue  | pierre
 pierre             | tt_obs_abusives                                              | vue  | pierre

 public             | dh_collars_points_latlon                                     | vue  | pierre
 public             | field_observations_points                                    | vue  | pierre
 public             | field_observations_struct_measures_points                    | vue  | pierre
 public             | licences_polygons                                            | vue  | pierre
 public             | licences_quadrangles                                         | vue  | pierre
 public             | survey_lines_plines                                          | vue  | pierre

 stats_reports      | avancements_sondages_stats_annuelles                         | vue  | pierre
 stats_reports      | avancements_sondages_stats_annuelles_par_objectif            | vue  | pierre
 stats_reports      | avancements_sondages_stats_mensuelles                        | vue  | pierre
 stats_reports      | avancements_sondages_stats_mensuelles_par_objectif           | vue  | pierre
 stats_reports      | avancements_sondages_stats_quotidiennes                      | vue  | pierre
 stats_reports      | longueur_exploree_par_location                               | vue  | pierre
 stats_reports      | longueur_exploree_par_location_et_type                       | vue  | pierre
 stats_reports      | longueur_exploree_par_type_km                                | vue  | pierre
 stats_reports      | recap_file_results_drill_holes                               | vue  | pierre
 stats_reports      | verif_attachements_journaliers_sondeur                       | vue  | pierre

 tmp_imports        | cme_sampling_grades_last                                     | vue  | pierre
 tmp_imports        | tmp_auramines_feb_march_sample_list_xlsx_01_main_list_points | vue  | pierre
 tmp_imports        | tmp_sample_description_and_coords_november_2015_paul_points  | vue  | pierre
 tmp_imports        | tmp_tt_pierre_nettoye_uploader_wpt_points                    | vue  | pierre
 tmp_imports        | tmp_tt_pts_gps_mdb_copie_points                              | vue  | pierre
 tmp_imports        | tmp_tt_pts_gps_mdb_points_latlong_points                     | vue  | pierre
 tmp_imports        | tmp_tt_pts_gps_mdb_sdqrfgadzrg_points                        | vue  | pierre
 tmp_imports        | tmp_tt_pts_gps_mdb_vireendb_points                           | vue  | pierre
(246 lignes)

-- }}}
fonctions:{{{

--localhost pierre@bdexplo=>
\df *.*
                                                                                                                                                                                                                                                                                                                                                                                    Liste des fonctions
       Schéma       |                     Nom                      |        Type de données du résultat         |                                                                                                                                                                                                                                                                                                                 Type de données des paramètres                                                                                                                                                                                                                                                                                                                  |  Type
--------------------+----------------------------------------------+--------------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+---------
 information_schema | ...
 public             | ...
 public             | ...
 public             | generate_cross_sections_array                | trigger                                    |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | trigger
 public             | ...
 public             | lab_ana_results_sample_id_default_value_num  | trigger                                    |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | trigger
 public             | ...
 topology           | ...

(3851 lignes)

-- }}}


Pareil, seulement les noms, pour *er plus facilement, à supprimer après usage:
tables:{{{
--localhost pierre@bdexplo=>
\dt *.*
                    Liste des relations
                           Nom
------------------------------------
doc_postgeol_table_categories    => (relation renommée; dans bdexplo, c'était: doc_bdexplo_table_categories)
doc_postgeol_tables_descriptions => (relation renommée; dans bdexplo, c'était: doc_bdexplo_tables_descriptions)

operations
operation_active

field_observations
field_observations_struct_measures
field_photos
formations_group_lithos
rock_sampling
rock_ana
surface_samples_grades
gps_wpt

geoch_sampling
geoch_ana
geoch_sampling_grades

gpy_mag_ground

dh_collars
shift_reports     <= RENOMMÉE en dh_, ATTENTION! TODO vérifier tout
dh_followup
dh_devia
dh_quicklog
dh_litho
dh_core_boxes
dh_tech
dh_struct_measures
dh_photos
dh_samples_submission
dh_sampling_grades
dh_mineralised_intervals
dh_density
dh_thinsections
dh_sampling_bottle_roll

dh_collars_lengths

lab_ana_batches_expedition
lab_ana_batches_reception
lab_ana_batches_reception_18_corr
lab_ana_columns_definition
ana_det_limit
lab_ana_results
lab_analysis_icp
lab_ana_qaqc_results

qc_sampling
qc_standards

ancient_workings
occurrences

licences

grade_ctrl

lex_codes
lex_datasource
lex_standard

mag_declination
topo_points
survey_lines
units
baselines
sections_definition
sections_array
conversions_oxydes_elements
index_geo_documentation
layer_styles
program


dh_nb_samples
grid
tmp_xy
tmp_xyz_marec
toudoux_dh_sampling_grades_datasource_979
tt_bdexplo_lex_datasource_autan
tt_bdexplo_lex_labo_analysis_autan

bondoukou_alain_lambert_acp
bondoukou_alain_lambert_au_ou_icp
bondoukou_alain_lambert_cah
bondoukou_alain_lambert_cah7
bondoukou_alain_lambert_coor
bondoukou_alain_lambert_coor_icp
bondoukou_alain_lambert_icp
bondoukou_alain_lambert_or
bondoukou_alain_lambert_tarkw_cah_3
bondoukou_alain_lambert_tout
bondoukou_alain_lambert_vx_tvx
soil_geoch_bondoukou
tmp_auramines_feb_march_sample_list_xlsx_01_main_list
tmp_auramines_feb_march_sample_list_xlsx_02_dhl_ireland
tmp_auramines_feb_march_sample_list_xlsx_03_dhl_france
tmp_auramines_feb_march_sample_list_xlsx_04_sheet_for_omac
tmp_auramines_field_observations
tmp_bondoukou_geoch_sol
tmp_bondoukou_sondages_collars
tmp_bondoukou_sondages_sampling_grades
tmp_bv130613_gravi_results

orientation
poi
tmp_assay_results_auramines_ns30n
tmp_cme_sampling_grades_150102
tmp_cme_sampling_grades_150102_utf8
tmp_collars_141027_utf8
tmp_collars_141223
tmp_collars_141223_utf8
tmp_entree_donnees_dh_tech
tmp_erreur_z
tmp_esp_pgm_cr_140908_
tmp_export_geolpda_waypoints_descriptions
tmp_ext1
tmp_ext2
tmp_ext3
tmp_ext4
tmp_ext5
tmp_ext6
tmp_ext7
tmp_field_observations_struct_measures
tmp_geolpda_orientations
tmp_geolpda_picks
tmp_ity_gpspolo_travaux_97et2004
tmp_log_tech
tmp_lr15201855
tmp_observations_pch_guyane_2011_2014
tmp_s001
tmp_s001_corr
tmp_s003_corr
tmp_s005_corr
tmp_sample_description_and_coords_november_2015_paul
tmp_sondages_est_cavally_resume_fiche_tech
tmp_sondages_est_cavally_resume_mineralisation
tmp_surface_samples_grades
tmp_surface_sampling_141027
tmp_surface_sampling_141027_utf8
tmp_survey_141027
tmp_survey_141223
tmp_tmp_dactylo_litho
tmp_tmp_field_observations_struct_measures
tmp_tmp_structures
tmp_tt
tmp_tt_omac_sample_list_update
tmp_tt_pierre_nettoye_uploader_wpt
tmp_tt_programme_esperance
tmp_tt_pts_gps_mdb_copie
tmp_tt_pts_gps_mdb_fichiers
tmp_tt_pts_gps_mdb_fsdrg
tmp_tt_pts_gps_mdb_points_latlong
tmp_tt_pts_gps_mdb_sdqrfgadzrg
tmp_tt_pts_gps_mdb_vireendb
tmp_tt_surface_samples
tmp_tt_translation_fr2en
tmp_waypoints_blaz_sudan_2015_02
tmp_waypoints_descriptions
tmp_waypoints_descriptions_bricolage
tmp_xtr_dh_collars
tmp_xtr_field_observations

bound_e
brgm_au
codes
contact
density
devia
formatio
geotec
headers
kendril2
lithaufu
litho
mag
mask
mine
outline
quicklog
rank
sampling
sgs_au
sgsrecod
soil
statrenc
struc
submit
thisecti
tr_au
tr_litho
vchannau
vchannel

field_observations_2016_03_09_14h08
field_observations_struct_measures_2016_03_09_14h10


t2

(252 lignes)

-- }}}
vues:{{{
--localhost pierre@bdexplo=>
\dv *.*
                                           Liste des relations
                            Nom
------------------------------------------------------------
collars_lengths_vs_dh_litho_depths
collars_lengths_vs_dh_sampling_depths
collars_vs_temp_topo_id_topo_sans_collars
collars_vs_topo_xyz_en_face_et_differences_importantes
dh_collars_to_topo_points_lines
doublons_collars_id
doublons_collars_xyz
doublons_collars_xyz_ouvrages_concernes
doublons_dh_litho_id_depto
doublons_dh_sampling_id_depto
fichettes_infos_incoherentes_drilled_lengths
fichettes_infos_incoherentes_heures
fichettes_infos_redondantes_incoherentes
fichettes_infos_redondantes_incoherentes_quels_ouvrages
fichettes_longueurs_incoherentes
fichettes_ouvrages_non_completed
fichettes_vs_collars_completed_incoherents
fichettes_vs_collars_longueurs_incoherentes
fichettes_vs_collars_ouvrages_dans_fichettes_pas_collars
tetes_passes_ouvrages_dans_passes_pas_dans_tetes_dh_litho
tetes_passes_ouvrages_dans_passes_pas_dans_tetes_dh_sampling
tetes_passes_ouvrages_dans_tetes_pas_dans_passes_dh_litho
tetes_passes_ouvrages_dans_tetes_pas_dans_passes_dh_sampling

gdm_dh_devia
gdm_sections_array
gdm_selection

ancient_workings
baselines
collars_selection
coords_points
dh_collars
dh_collars_
dh_collars_diff_project_actual_line
dh_collars_for_gpx
dh_collars_points
dh_collars_points_last_ana_results
dh_collars_points_marrec
dh_core_boxes
dh_density
dh_devia
dh_followup
dh_litho
dh_mineralised_intervals
dh_mineralised_intervals0_traces_3d
dh_quicklog
dh_sampling
dh_sampling_avg_grades_3dpoints
dh_sampling_bottle_roll
dh_sampling_grades
dh_sampling_grades_graph_au_6
dh_sampling_grades_open_ended_au_tail
dh_sampling_grades_open_ended_au_top
dh_sampling_mineralised_intervals_graph_au6
dh_struct_measures
dh_tech
dh_thinsections
dh_traces_3d
field_observations
field_observations_points
field_observations_struct_measures
field_photos
formations_group_lithos
gdm_baselines
gdm_dh_devia
gdm_dh_litho
gdm_dh_mine_0
gdm_dh_mine_1
gdm_dh_planned
gdm_dh_sampling_grades
gdm_dh_sampling_grades_open_ended_au_tail
gdm_dh_sampling_grades_open_ended_au_top
gdm_sections_array
gdm_selection
geoch_ana
geoch_sampling
geoch_sampling_grades
geoch_sampling_grades_points
gpy_mag_ground
grade_ctrl
index_geo_documentation
lab_ana_batches_expedition
lab_ana_batches_reception
lab_ana_columns_definition
lab_ana_qaqc_results
lab_ana_results
lex_codes
lex_datasource
lex_standard
licences
licences_quadrangles
mag_declination
occurrences
occurrences_
occurrences_bal_200km
operations_quadrangles
petro_mineralo_study_dh_collars
petro_mineralo_study_field_observations_points
qc_sampling
qc_standards
shift_reports
surface_samples_grades
surface_samples_grades_points
surpac_survey
tanguysurp_project
tanguysurp_survey
tmp_xy_points
topo_points
topo_points_points
tt_obs_abusives

dh_collars_points_latlon
field_observations_points
field_observations_struct_measures_points
licences_polygons
licences_quadrangles
survey_lines_plines

avancements_sondages_stats_annuelles
avancements_sondages_stats_annuelles_par_objectif
avancements_sondages_stats_mensuelles
avancements_sondages_stats_mensuelles_par_objectif
avancements_sondages_stats_quotidiennes
longueur_exploree_par_location
longueur_exploree_par_location_et_type
longueur_exploree_par_type_km
recap_file_results_drill_holes
verif_attachements_journaliers_sondeur

cme_sampling_grades_last
tmp_auramines_feb_march_sample_list_xlsx_01_main_list_points
tmp_sample_description_and_coords_november_2015_paul_points
tmp_tt_pierre_nettoye_uploader_wpt_points
tmp_tt_pts_gps_mdb_copie_points
tmp_tt_pts_gps_mdb_points_latlong_points
tmp_tt_pts_gps_mdb_sdqrfgadzrg_points
tmp_tt_pts_gps_mdb_vireendb_points


-- }}}
fonctions:{{{

--localhost pierre@bdexplo=>
\df *.*
                                                                                                                                                                                                                                                                                                                                                                                    Liste des fonctions
                    Nom
---------------------------------------------
...
...
...
generate_cross_sections_array
...
lab_ana_results_sample_id_default_value_num
...
...

(3851 lignes)

--}}}
  .              .
 /!\ refactoré! /!\
`---'          `---'

Pareil, / des instructions de CREATion de TABLEs:
--{{{

/CREATE TABLE.*doc_bdexplo_table_categories
/CREATE TABLE.*doc_postgeol_table_categories
/CREATE TABLE.*doc_bdexplo_tables_descriptions
/CREATE TABLE.*doc_postgeol_tables_descriptions

/CREATE TABLE.*operations
/CREATE TABLE.*operation_active
/CREATE TABLE.*field_observations
/CREATE TABLE.*field_observations_struct_measures
/CREATE TABLE.*field_photos
/CREATE TABLE.*formations_group_lithos
/CREATE TABLE.*field_sampling\|CREATE TABLE.*rock_sampling
/CREATE TABLE.*rock_ana
/CREATE TABLE.*surface_samples_grades
/CREATE TABLE.*gps_wpt
/CREATE TABLE.*geoch_sampling
/CREATE TABLE.*geoch_ana
/CREATE TABLE.*geoch_sampling_grades
/CREATE TABLE.*gpy_mag_ground
/CREATE TABLE.*dh_collars
/CREATE TABLE.*shift_reports
/CREATE TABLE.*dh_followup
/CREATE TABLE.*dh_devia
/CREATE TABLE.*dh_quicklog
/CREATE TABLE.*dh_litho
/CREATE TABLE.*dh_core_boxes
/CREATE TABLE.*dh_tech
/CREATE TABLE.*dh_struct_measures
/CREATE TABLE.*dh_photos
/CREATE TABLE.*dh_samples_submission
/CREATE TABLE.*dh_sampling_grades
/CREATE TABLE.*dh_mineralised_intervals
/CREATE TABLE.*dh_density
/CREATE TABLE.*dh_thinsections
/CREATE TABLE.*dh_sampling_bottle_roll
/CREATE TABLE.*dh_collars_lengths
/CREATE TABLE.*lab_ana_batches_expedition
/CREATE TABLE.*lab_ana_batches_reception
/CREATE TABLE.*lab_ana_columns_definition
/CREATE TABLE.*ana_det_limit
/CREATE TABLE.*lab_ana_results
/CREATE TABLE.*lab_analysis_icp
/CREATE TABLE.*lab_ana_qaqc_results
/CREATE TABLE.*qc_sampling
/CREATE TABLE.*qc_standards
/CREATE TABLE.*ancient_workings
/CREATE TABLE.*occurrences
/CREATE TABLE.*licences
/CREATE TABLE.*grade_ctrl
/CREATE TABLE.*lex_codes
/CREATE TABLE.*lex_datasource
/CREATE TABLE.*lex_standard
/CREATE TABLE.*mag_declination
/CREATE TABLE.*topo_points
/CREATE TABLE.*survey_lines
/CREATE TABLE.*units
/CREATE TABLE.*baselines
/CREATE TABLE.*sections_definition
/CREATE TABLE.*sections_array
/CREATE TABLE.*conversions_oxydes_elements
/CREATE TABLE.*index_geo_documentation
/CREATE TABLE.*layer_styles
/CREATE TABLE.*program
/CREATE TABLE.*dh_nb_samples________________ENCOURS_______________GEOLLLIBRE 2
/CREATE TABLE.*grid
/CREATE TABLE.*tmp_xy
/CREATE TABLE.*tmp_xyz_marec
/CREATE TABLE.*toudoux_dh_sampling_grades_datasource_979
/CREATE TABLE.*tt_bdexplo_lex_datasource_autan
/CREATE TABLE.*tt_bdexplo_lex_labo_analysis_autan
/CREATE TABLE.*bondoukou_alain_lambert_acp
/CREATE TABLE.*bondoukou_alain_lambert_au_ou_icp
/CREATE TABLE.*bondoukou_alain_lambert_cah
/CREATE TABLE.*bondoukou_alain_lambert_cah7
/CREATE TABLE.*bondoukou_alain_lambert_coor
/CREATE TABLE.*bondoukou_alain_lambert_coor_icp
/CREATE TABLE.*bondoukou_alain_lambert_icp
/CREATE TABLE.*bondoukou_alain_lambert_or
/CREATE TABLE.*bondoukou_alain_lambert_tarkw_cah_3
/CREATE TABLE.*bondoukou_alain_lambert_tout
/CREATE TABLE.*bondoukou_alain_lambert_vx_tvx
/CREATE TABLE.*soil_geoch_bondoukou
/CREATE TABLE.*tmp_auramines_feb_march_sample_list_xlsx_01_main_list
/CREATE TABLE.*tmp_auramines_feb_march_sample_list_xlsx_02_dhl_ireland
/CREATE TABLE.*tmp_auramines_feb_march_sample_list_xlsx_03_dhl_france
/CREATE TABLE.*tmp_auramines_feb_march_sample_list_xlsx_04_sheet_for_omac
/CREATE TABLE.*tmp_auramines_field_observations
/CREATE TABLE.*tmp_bondoukou_geoch_sol
/CREATE TABLE.*tmp_bondoukou_sondages_collars
/CREATE TABLE.*tmp_bondoukou_sondages_sampling_grades
/CREATE TABLE.*tmp_bv130613_gravi_results
/CREATE TABLE.*orientation
/CREATE TABLE.*poi
/CREATE TABLE.*tmp_assay_results_auramines_ns30n
/CREATE TABLE.*tmp_cme_sampling_grades_150102
/CREATE TABLE.*tmp_cme_sampling_grades_150102_utf8
/CREATE TABLE.*tmp_collars_141027_utf8
/CREATE TABLE.*tmp_collars_141223
/CREATE TABLE.*tmp_collars_141223_utf8
/CREATE TABLE.*tmp_entree_donnees_dh_tech
/CREATE TABLE.*tmp_erreur_z
/CREATE TABLE.*tmp_esp_pgm_cr_140908_
/CREATE TABLE.*tmp_export_geolpda_waypoints_descriptions
/CREATE TABLE.*tmp_ext1
/CREATE TABLE.*tmp_ext2
/CREATE TABLE.*tmp_ext3
/CREATE TABLE.*tmp_ext4
/CREATE TABLE.*tmp_ext5
/CREATE TABLE.*tmp_ext6
/CREATE TABLE.*tmp_ext7
/CREATE TABLE.*tmp_field_observations_struct_measures
/CREATE TABLE.*tmp_geolpda_orientations
/CREATE TABLE.*tmp_geolpda_picks
/CREATE TABLE.*tmp_ity_gpspolo_travaux_97et2004
/CREATE TABLE.*tmp_log_tech
/CREATE TABLE.*tmp_lr15201855
/CREATE TABLE.*tmp_observations_pch_guyane_2011_2014
/CREATE TABLE.*tmp_s001
/CREATE TABLE.*tmp_s001_corr
/CREATE TABLE.*tmp_s003_corr
/CREATE TABLE.*tmp_s005_corr
/CREATE TABLE.*tmp_sample_description_and_coords_november_2015_paul
/CREATE TABLE.*tmp_sondages_est_cavally_resume_fiche_tech
/CREATE TABLE.*tmp_sondages_est_cavally_resume_mineralisation
/CREATE TABLE.*tmp_surface_samples_grades
/CREATE TABLE.*tmp_surface_sampling_141027
/CREATE TABLE.*tmp_surface_sampling_141027_utf8
/CREATE TABLE.*tmp_survey_141027
/CREATE TABLE.*tmp_survey_141223
/CREATE TABLE.*tmp_tmp_dactylo_litho
/CREATE TABLE.*tmp_tmp_field_observations_struct_measures
/CREATE TABLE.*tmp_tmp_structures
/CREATE TABLE.*tmp_tt
/CREATE TABLE.*tmp_tt_omac_sample_list_update
/CREATE TABLE.*tmp_tt_pierre_nettoye_uploader_wpt
/CREATE TABLE.*tmp_tt_programme_esperance
/CREATE TABLE.*tmp_tt_pts_gps_mdb_copie
/CREATE TABLE.*tmp_tt_pts_gps_mdb_fichiers
/CREATE TABLE.*tmp_tt_pts_gps_mdb_fsdrg
/CREATE TABLE.*tmp_tt_pts_gps_mdb_points_latlong
/CREATE TABLE.*tmp_tt_pts_gps_mdb_sdqrfgadzrg
/CREATE TABLE.*tmp_tt_pts_gps_mdb_vireendb
/CREATE TABLE.*tmp_tt_surface_samples
/CREATE TABLE.*tmp_tt_translation_fr2en
/CREATE TABLE.*tmp_waypoints_blaz_sudan_2015_02
/CREATE TABLE.*tmp_waypoints_descriptions
/CREATE TABLE.*tmp_waypoints_descriptions_bricolage
/CREATE TABLE.*tmp_xtr_dh_collars
/CREATE TABLE.*tmp_xtr_field_observations
/CREATE TABLE.*bound_e
/CREATE TABLE.*brgm_au
/CREATE TABLE.*codes
/CREATE TABLE.*contact
/CREATE TABLE.*density
/CREATE TABLE.*devia
/CREATE TABLE.*formatio
/CREATE TABLE.*geotec
/CREATE TABLE.*headers
/CREATE TABLE.*kendril2
/CREATE TABLE.*lithaufu
/CREATE TABLE.*litho
/CREATE TABLE.*mag
/CREATE TABLE.*mask
/CREATE TABLE.*mine
/CREATE TABLE.*outline
/CREATE TABLE.*quicklog
/CREATE TABLE.*rank
/CREATE TABLE.*sampling
/CREATE TABLE.*sgs_au
/CREATE TABLE.*sgsrecod
/CREATE TABLE.*soil
/CREATE TABLE.*statrenc
/CREATE TABLE.*struc
/CREATE TABLE.*submit
/CREATE TABLE.*thisecti
/CREATE TABLE.*tr_au
/CREATE TABLE.*tr_litho
/CREATE TABLE.*vchannau
/CREATE TABLE.*vchannel

/CREATE TABLE.*lab_ana_batches_reception_18_corr
--}}}

-- (du vide) {{{












































-- }}}

--}}}
--  1100 DÉBUT: CRÉATION BASE, SCHÉMAS:{{{

--echo "CREATE DATABASE postgeol WITH TEMPLATE=template_postgis ENCODING='UTF8'OWNER=pierre;" | psql
-- => no, refer to postgeol_database_creation.sh

--"IFNDEF" SI $POSTGEOL PAS DÉFINI, ON LE DÉFINIT: @#TODO
-- POSTGEOL := 'postgeol';
-- postgeol := 'postgeol';
-- pour l'instant, $POSTGEOL est défini dans mon .bashrc:
-- export POSTGEOL=postgeol


--TODO make a table 'defaults' in the user's schema (or no?)
--     containing all pre-defined preferences, default field values, (special views definitions?).  Or, alternatively, use .gll_preferences file located in $HOME.


--CREATE DATABASE $POSTGEOL ENCODING='UTF8';
--CREATE DATABASE ${POSTGEOL} ENCODING='UTF8';
--SELECT '${POSTGEOL}';
-- COMMENT APPELER UNE VARIABLE D'ENVIRONNEMENT DEPUIS PSQL??
-- voilà (ça ne fonctionne que sur un unix...):
\set postgeol `echo "$POSTGEOL"`
--\echo :postgeol
-- (c'est un peu tordu...)

DROP DATABASE :postgeol; --TODO À INVALIDER, BIEN SÛR!
CREATE DATABASE :postgeol ENCODING='UTF8';

-- Record the current username, and login to the newly made
-- database as superuser postgres:
\set username :USER
\c :postgeol postgres
-- Incorporate some extensions:
CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';
CREATE OR REPLACE PROCEDURAL LANGUAGE plpythonu;
ALTER PROCEDURAL LANGUAGE plpythonu OWNER TO postgres;
-- postgeol is a spatial database, at least partially: inherit from the famous PostGIS extension:
CREATE EXTENSION postgis;
CREATE EXTENSION postgis_topology;
-- Re-connect as the initial (normal) user again:
\c :postgeol :username

-- Create schemas:{{{
CREATE SCHEMA checks;
COMMENT ON SCHEMA checks                              IS 'Views selecting unconsistent, incoherent, unprobable data';

CREATE SCHEMA gdm;
COMMENT ON SCHEMA gdm                                 IS 'Views for connection with GDM software through ODBC';

CREATE SCHEMA input;
COMMENT ON SCHEMA input                               IS 'Tables with same structure as tables in main data schema: for data input before validation and dump into final tables (apparently unused on production site 2013_08_03__11_40_18).';

CREATE SCHEMA stats_reports;
COMMENT ON SCHEMA stats_reports                       IS 'Views with statistics and reports, for daily/weekly/monthly statistics.';

CREATE SCHEMA tmp_imports;
COMMENT ON SCHEMA tmp_imports                         IS 'Temporary place for imported files.  Tables imported from .csv files by using the csv2sql utility are going in this schema.  Also refer to .gll_preferences file.';

CREATE SCHEMA backups;
COMMENT ON SCHEMA backups                             IS 'Just in case, a convenient place to put backups when potentially dangerous changes are to be made.';


--}}}
































--}}}
*/
/* *** 2017_04_02__23_35_37 c'est fait, on commente:
BEGIN TRANSACTION;
-- 1200 TABLES{{{
--SET SCHEMA_DATA = 'public'; -- for the time being.  Eventually, data tables will be moved into another work schema.
--SET search_path = SCHEMA_DATA, pg_catalog;
--SET search_path = '$user', 'public';
--SET search_path = public, pg_catalog;

-- x doc_postgeol_table_categories: --{{{ TODO reprendre: catégories thématiques dans lesquelles sont rangées les tables de bdexplo => postgeol
----------------------------------------------

-- TODO utile de garder ça??
CREATE TABLE public.doc_postgeol_table_categories ( -- used to be named doc_bdexplo_table_categories
    category       text NOT NULL PRIMARY KEY,
    description_en text,
    description_es text,
    description_fr text,
    numauto        bigserial NOT NULL,
    creation_ts    timestamptz DEFAULT now() NOT NULL,
    username       text DEFAULT current_user
);
--COMMENT ON TABLE public.doc_postgeol_table_categories IS ...
--TODO add comments

-- dump de la table:
-- --localhost pierre@bdexplo=>
-- TABLE doc_postgeol_table_categories
-- ;
--   category  |                                 description_fr                                 | numauto
-- ------------+--------------------------------------------------------------------------------+---------
--  OUVRAGES   | Sondages et tranchées; toutes les tables sont préfixées en dh_ pour Drill Hole |       1
--  ANALYSES   | Résultats analytiques, suivi des échantillons                                  |       2
--  QC         | Contrôle analytique, contrôle qualité                                          |       3
--  DATASOURCE | Traçabilité des données                                                        |       4
--  TERRAIN    | Observations de terrain                                                        |       5
--  PRE-EX     | Pré-exploitation                                                               |       6
--  GPY        | Géophysique au sol                                                             |       7
--  SURF       | Prélèvements de surface: prospection, géochimie ruisseau, sol                  |       8
--  GENERAL    | Permis, prospects, indices, données générales                                  |       9
-- (9 lignes)

-- la commande de création initiale:
--CREATE TABLE public.doc_bdexplo_table_categories (category VARCHAR PRIMARY KEY, description_fr VARCHAR, numauto SERIAL);

--}}}
-- x doc_postgeol_tables_descriptions --{{{
-- TODO même question: utile à garder?

CREATE TABLE public.doc_postgeol_tables_descriptions (  -- used to be named doc_bdexplo_tables_descriptions
    tablename      text PRIMARY KEY,
    category       text
        REFERENCES public.doc_postgeol_table_categories(category)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED,
    comment_en     text,
    comment_fr     text,
    numauto        bigserial NOT NULL,
    creation_ts    timestamptz DEFAULT now() NOT NULL,
    username       text DEFAULT current_user
);
COMMENT ON TABLE public.doc_postgeol_tables_descriptions        IS 'Description of tables';
-- Hm, should be the same as COMMENT on tables... TODO: make sure it is consistent, check what uses this table, update if necessary, and clean up (get rid of)!

-- la commande de création initiale:
--CREATE TABLE public.doc_bdexplo_tables_descriptions (tablename VARCHAR PRIMARY KEY, category VARCHAR, comment_fr VARCHAR, numauto SERIAL);

--}}}

-- x operations:{{{

CREATE TABLE public.operations (
    opid            bigserial PRIMARY KEY NOT NULL,
    operation       text NOT NULL,
    full_name       text NOT NULL,
    operator        text NOT NULL,
    year            integer NOT NULL,
    confidentiality boolean NOT NULL DEFAULT TRUE,
    lat_min         numeric(10,5) NOT NULL,
    lon_min         numeric(10,5) NOT NULL,
    lat_max         numeric(10,5) NOT NULL,
    lon_max         numeric(10,5) NOT NULL,
    comments        text NOT NULL,
    --numauto         bigserial UNIQUE NOT NULL,  -- useless, since opid is already the bigserial PRIMARY KEY
    creation_ts     timestamptz DEFAULT now() NOT NULL,
    username        text DEFAULT current_user NOT NULL
);
COMMENT ON TABLE public.operations                              IS 'Operations, projects: master table, to be queried all the time, especially for confidentiality purposes.';
COMMENT ON COLUMN public.operations.opid                        IS 'Operation identifier, automatic sequence; referred by all tables, since all data contained belongs to an operation'; -- TODO ideally, to avoid any collisions, a centralised operations reference should be put in place, so that, throughout the world and among all postgeol users, an opid would always be fully significant.  An "operation creation" procedure is something quite rare, and it should therefore be done online, whereas all subsequent work can be done off Internet.
COMMENT ON COLUMN public.operations.operation                   IS 'Operation code';
COMMENT ON COLUMN public.operations.full_name                   IS 'Complete operation name';
COMMENT ON COLUMN public.operations.operator                    IS 'Operator: mining operator, exploration company, client name';
COMMENT ON COLUMN public.operations.year                        IS 'Year of operation activity';
COMMENT ON COLUMN public.operations.confidentiality             IS 'Confidentiality flag, true or false; default is true';
COMMENT ON COLUMN public.operations.lat_min                     IS 'South latitude, decimal degrees, WGS84';
COMMENT ON COLUMN public.operations.lon_min                     IS 'West longitude, decimal degrees, WGS84';
COMMENT ON COLUMN public.operations.lat_max                     IS 'North latitude, decimal degrees, WGS84';
COMMENT ON COLUMN public.operations.lon_max                     IS 'East latitude, decimal degrees, WGS84';
COMMENT ON COLUMN public.operations.creation_ts                 IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN public.operations.username                    IS 'User (role) which created data record';
--COMMENT ON COLUMN public.operations.numauto                     IS 'Automatic integer';

--}}}
-- x operation_active:{{{

--SET search_path = current_user $USER, pg_catalog; => in fact, this table should rather be in the user's schema => TODO later
-- => as written here, the table will end up in the current user's schema.
CREATE TABLE operation_active (
    opid                integer
        REFERENCES public.operations (opid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED,
    numauto             bigserial PRIMARY KEY,
    creation_ts         timestamptz DEFAULT now() NOT NULL,
    username            text DEFAULT current_user
);
COMMENT ON TABLE operation_active                               IS 'table containing active opid(s), in order to query only some operations by systematically JOINing on opid; homonymous views (same name as public.tables in user schema are doing this seamlessly, once operation_active is properly filled.'; -- TODO add a constraint per user - authorised opid(s)
COMMENT ON COLUMN operation_active.opid                         IS 'Operation identifier';
COMMENT ON COLUMN operation_active.numauto                      IS 'Automatic integer';
COMMENT ON COLUMN operation_active.creation_ts                  IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN operation_active.username                     IS 'User (role) which created data record';

--}}}
-- x field work, on surface:{{{ -- discussion: prefix these tables with field_ or surf_ or ?...
-- x field_observations:{{{

CREATE TABLE public.field_observations (
    opid                integer NOT NULL
        REFERENCES public.operations (opid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED,
    obs_id              text NOT NULL,
    year                integer NOT NULL,
    date                date NOT NULL,
    waypoint_name       text NOT NULL,
    srid                integer NOT NULL,
    x                   numeric(20,10) NOT NULL,
    y                   numeric(20,10) NOT NULL,
    z                   numeric(20,2) NOT NULL,
    description         text NOT NULL,
    code_litho          text NOT NULL,
    code_unit           text NOT NULL,
    sample_id           text NOT NULL,
    audio               text NOT NULL,
    photos              text NOT NULL,
    geologist           text NOT NULL,
    device              text NOT NULL,
    icon_descr          text NOT NULL,
    comments            text NOT NULL,
    "time"              text NOT NULL, -- TODO voir ce que contient ce champ; le renommer mieux
    timestamp_epoch_ms  bigint NOT NULL,
    datasource          integer NOT NULL,
    numauto             bigserial PRIMARY KEY,
    creation_ts         timestamptz DEFAULT now() NOT NULL,
    username            text NOT NULL DEFAULT current_user,
    UNIQUE (opid, obs_id)
);
COMMENT ON TABLE field_observations                             IS 'Field observations: geological observations, on outcrops, floats, or any other observations; coherent with GeolPDA';
COMMENT ON COLUMN field_observations.opid                       IS 'Operation identifier';
COMMENT ON COLUMN field_observations.obs_id                     IS 'Observation identifier: usually composed of: (acronym of person)_(year)_(incremental integer)';
COMMENT ON COLUMN field_observations.year                       IS 'Year when observation is done (TODO DROP COLUMN redundant with date field)';
COMMENT ON COLUMN field_observations.date                       IS 'Observation date';
COMMENT ON COLUMN field_observations.waypoint_name              IS 'If relevant, waypoint name from GPS device';
COMMENT ON COLUMN field_observations.srid                       IS 'Spatial Reference Identifier, or coordinate reference system: see spatial_ref_sys from postgis extension';
COMMENT ON COLUMN field_observations.x                          IS 'X coordinate (Easting),  in coordinate system srid';
COMMENT ON COLUMN field_observations.y                          IS 'Y coordinate (Northing), in coordinate system srid';
COMMENT ON COLUMN field_observations.z                          IS 'Z coordinate';
COMMENT ON COLUMN field_observations.description                IS 'Naturalist description';
COMMENT ON COLUMN field_observations.code_litho                 IS 'Lithological code';
COMMENT ON COLUMN field_observations.code_unit                  IS 'Unit code: lithostratigraphic, and/or cartographic';
COMMENT ON COLUMN field_observations.sample_id                  IS 'If relevant, sample identifier';
COMMENT ON COLUMN field_observations.audio                      IS 'Audio recording files, if relevant';
COMMENT ON COLUMN field_observations.photos                     IS 'List of photographs pictures files, if relevant';
COMMENT ON COLUMN field_observations.geologist                  IS 'Geologist or prospector name';
COMMENT ON COLUMN field_observations.device                     IS 'Device used to record data: good old fieldbook, PDA, smartphone, tablet, dictaphone, raw human memory (not recommended), etc.';
COMMENT ON COLUMN field_observations.icon_descr                 IS 'If relevant, icon description from some GPS devices/programs';
COMMENT ON COLUMN field_observations.comments                   IS 'Comments';
COMMENT ON COLUMN field_observations."time"                     IS '?';
COMMENT ON COLUMN field_observations.timestamp_epoch_ms         IS 'Timestamp of observation: as defined in GeolPDA devices, as epoch in ms';
COMMENT ON COLUMN field_observations.datasource                 IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN field_observations.numauto                    IS 'Automatic integer primary key';
COMMENT ON COLUMN field_observations.creation_ts                IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN field_observations.username                   IS 'User (role) which created data record';

--}}}
-- x field_observations_struct_measures_points:{{{

CREATE TABLE public.field_observations_struct_measures (
    opid                integer NOT NULL,
    obs_id              text NOT NULL,
    measure_type        text NOT NULL,
    device              text NOT NULL,
    structure_type      text NOT NULL,
    rotation_matrix     text NOT NULL,
    north_ref           text NOT NULL,
    direction           integer NOT NULL,
    dip                 integer NOT NULL,
    dip_quadrant        text NOT NULL,
    pitch               integer NOT NULL,
    pitch_quadrant      text NOT NULL,
    movement            text NOT NULL,
    valid               boolean NOT NULL,
    comments            text NOT NULL,
    geolpda_id          integer NOT NULL,
    geolpda_poi_id      integer NOT NULL,
    sortgroup           text NOT NULL,
    datasource          integer NOT NULL,
    numauto             bigserial PRIMARY KEY,
    creation_ts         timestamptz DEFAULT now() NOT NULL,
    username            text DEFAULT current_user,
    FOREIGN KEY (opid, obs_id)
        REFERENCES public.field_observations(opid, obs_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED
);
COMMENT ON TABLE public.field_observations_struct_measures                          IS 'Structural measurements, related to an observation; coherent with GeolPDA';
COMMENT ON COLUMN public.field_observations_struct_measures.opid                    IS 'Operation identifier';
COMMENT ON COLUMN public.field_observations_struct_measures.obs_id                  IS 'Observation identifier: refers to field_observations table';
COMMENT ON COLUMN public.field_observations_struct_measures.measure_type            IS 'Type of measurement: [P: plane L: line PL: plane line PLM: plane line movement PLMS: plane line movement sure]';
COMMENT ON COLUMN public.field_observations_struct_measures.device                  IS 'Measuring device: compass, electronic device';
COMMENT ON COLUMN public.field_observations_struct_measures.structure_type          IS 'Measured structure type: [VEIN , FRACTURE , C , SCHISTOSITY , FOLIATION , MYLONITE , CONTACT , VEIN_FAULT , FOLD_PAX_AX , FOLIATION_LINE , FAULT , CATACLASE , MINERALISED_STRUCTURE]';
COMMENT ON COLUMN public.field_observations_struct_measures.rotation_matrix         IS '3x3 rotation matrix, fully describing any orientation: initial state: [X axis points East, Y axis points North, Z axis points up] => measurement state = rotation applied. Corresponds to function public static float[] getOrientation (float[] R, float[] values) from android API as described in http://developer.android.com/reference/android/hardware/SensorManager.html#getOrientation%28float[],%20float[]%29';
COMMENT ON COLUMN public.field_observations_struct_measures.north_ref               IS 'North reference for azimuths and directions measurements: [Nm: magnetic North, Ng: geographic North, Nu: UTM north, Nl: local grid Y axis]';
COMMENT ON COLUMN public.field_observations_struct_measures.direction               IS 'Plane direction, 0-180°';
COMMENT ON COLUMN public.field_observations_struct_measures.dip                     IS 'Plane dip, 0-90°';
COMMENT ON COLUMN public.field_observations_struct_measures.dip_quadrant            IS 'Plane dip quadrant, NESW';
COMMENT ON COLUMN public.field_observations_struct_measures.pitch                   IS 'Pitch of line on plane, 0-90°';
COMMENT ON COLUMN public.field_observations_struct_measures.pitch_quadrant          IS 'Quadrant of pitch, NESW';
COMMENT ON COLUMN public.field_observations_struct_measures.movement                IS 'Relative movement of fault/C: [N: normal, I: inverse = R = reverse, D: dextral, S: sinistral]';
COMMENT ON COLUMN public.field_observations_struct_measures.valid                   IS 'Measure is valid or not (impossible cases = not valid)';
COMMENT ON COLUMN public.field_observations_struct_measures.comments                IS 'Comments';
COMMENT ON COLUMN public.field_observations_struct_measures.geolpda_id              IS 'If a GeolPDA was used to measure the orientation, copy of geolpda_id field';
COMMENT ON COLUMN public.field_observations_struct_measures.geolpda_poi_id          IS 'If a GeolPDA was used to measure the orientation, copy of geolpda_poi_id field';
--COMMENT ON COLUMN public.field_observations_struct_measures.sortgroup               IS 'Sorting group, for discriminated of various phases: a, b, c, ...';
COMMENT ON COLUMN public.field_observations_struct_measures.sortgroup               IS 'In case of sorting structural measurements using TecTri or similar, letter referring to sort group (corresponding to various phases): a, b, c, ...';
COMMENT ON COLUMN public.field_observations_struct_measures.datasource              IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN public.field_observations_struct_measures.numauto                 IS 'Automatic integer primary key';
COMMENT ON COLUMN public.field_observations_struct_measures.creation_ts             IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN public.field_observations_struct_measures.username                IS 'User (role) which created data record';

--}}}
-- x field_photos:{{{
-- table vide, pour le moment.

CREATE TABLE public.field_photos (
    opid                integer
        REFERENCES public.operations (opid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED,
    pho_id              text NOT NULL,
    obs_id              text,   -- est-ce bien pertinent de faire cela? Ne serait-ce pas plus opportun de faire une table "photos", qui se fasse pointer par field_observations ou par dh_litho ou par dh_sampling ou par... À voir.
    filename            text,   --xTODO "file" => reserved word? appears pinkish in vim with SQL highlighting: rename to filename, if necessary? => done
    description         text,
    azim_nm             numeric,   --WARNING, field renamed from az to something a bit more meaningful; however, maybe azim_ng should be preferable: TODO later.
    dip_hz              numeric,   --WARNING, field renamed from dip to something a bit more meaningful.
    author              text,   --hm, useful? Geologist from field_observations should do it, no? TODO drop this field, if unnecessary.
    datasource          integer,
    numauto             bigserial PRIMARY KEY,
    creation_ts         timestamptz DEFAULT now() NOT NULL,
    username            text DEFAULT current_user
    --FOREIGN KEY (opid, obs_id) REFERENCES public.field_observations(opid, obs_id)
    -- => Non: Notons au passage qu'une photo ne va pas forcément avec un point d'observation.
    --         Mais à ce moment, il faudrait lui prévoir un moyen de la géolocaliser?
    --         On pourrait faire une table points, tout bêtement, où les tables field_observations et field_photos iraient stocker leurs géolocalisations. Hm. TODO y réfléchir. C'est quand même pratique, les struct du C, à la place de ce genre de choses.
--     FOREIGN KEY (opid) REFERENCES public.operations(opid)
--       ON DELETE CASCADE
--       ON UPDATE CASCADE
--       DEFERRABLE INITIALLY DEFERRED
);
COMMENT ON TABLE  public.field_photos                           IS 'Photographs taken in field, related to an observation';
COMMENT ON COLUMN public.field_photos.opid                      IS 'Operation identifier';
COMMENT ON COLUMN public.field_photos.pho_id                    IS 'Photograph identifier';
COMMENT ON COLUMN public.field_photos.filename                  IS 'Photograph full filename, with relative or full path included; to be made consistent and usable';
COMMENT ON COLUMN public.field_photos.azim_nm                   IS 'Azimuth of camera axis, refers to magnetic North (°)';
COMMENT ON COLUMN public.field_photos.dip_hz                    IS 'Dip of camera axis, relative to horizontal (°)';
COMMENT ON COLUMN public.field_photos.author                    IS 'Photograph author; not very useful, as it generally is the geologist, as defined in field_observations table';
COMMENT ON COLUMN public.field_photos.datasource                IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN public.field_photos.numauto                   IS 'Automatic integer';
COMMENT ON COLUMN public.field_photos.creation_ts               IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN public.field_photos.username                  IS 'User (role) which created data record';

--}}}
-- x formations_group_lithos:{{{

CREATE TABLE public.formations_group_lithos (  --TODO name formations_group_lithos is discutable; formations_lithostrati would be better?
    opid                integer
        REFERENCES public.operations(opid)
        ON DELETE CASCADE
        ON UPDATE CASCADE
        DEFERRABLE INITIALLY DEFERRED,
    formation_name      text,
    code_litho          text,
    datasource          integer,
    numauto             bigserial PRIMARY KEY,
    creation_ts         timestamptz DEFAULT now() NOT NULL,
    username            text DEFAULT current_user
);
COMMENT ON TABLE public.formations_group_lithos                 IS 'Groups of lithologies, for simplification; typically for mapping outcrop points, or plotting drill holes sections';
COMMENT ON COLUMN public.formations_group_lithos.opid           IS 'Operation identifier';
COMMENT ON COLUMN public.formations_group_lithos.datasource     IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN public.formations_group_lithos.numauto        IS 'Automatic integer primary key';
COMMENT ON COLUMN public.formations_group_lithos.creation_ts    IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN public.formations_group_lithos.username       IS 'User (role) which created data record';

--}}}
-- x surface_samples_grades:{{{

CREATE TABLE public.surface_samples_grades (
    opid                integer
        REFERENCES public.operations (opid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED,
    sample_id           text,
    x                   numeric,
    y                   numeric,
    z                   numeric,
    srid                integer,
    description         text,
    sample_type         text,
    outcrop_id          text,
    trend               text,
    dip                 text,
    length_m            text,
    width_m             text,
    au1_ppm             double precision,
    au2_ppm             double precision,
    ag1_                double precision,
    ag2_                double precision,
    cu1_                double precision,
    cu2_                double precision,
    as_                 double precision,
    pb_                 double precision,
    zn_                 double precision,
    k2o_                double precision,
    ba_                 double precision,
    sio2_               double precision,
    al2x_               double precision,
    fe2x_               double precision,
    mno_                double precision,
    tio2_               double precision,
    p2o5_               double precision,
    cao_                double precision,
    mgo_                double precision,
    mo_                 double precision,
    sn_                 double precision,
    sb_                 double precision,
    w_                  double precision,
    bi_                 double precision,
    zr_                 double precision,
    li_                 double precision,
    b_                  double precision,
    v_                  double precision,
    cr_                 double precision,
    ni_                 double precision,
    co_                 double precision,
    sr_                 double precision,
    y_                  double precision,
    la_                 double precision,
    ce_                 double precision,
    nb_                 double precision,
    be_                 double precision,
    cd_                 double precision,
    spp2                double precision,
    campaign            text,
    datasource          integer,
    numauto             bigserial PRIMARY KEY,
    creation_ts         timestamptz DEFAULT now() NOT NULL,
    username            text DEFAULT current_user
);
COMMENT ON TABLE public.surface_samples_grades                  IS 'Ponctual samples taken from surface: stream sediments, alluvial sediments, till, soils, termite mounds, rock outcrops, floats, etc. with grades';
COMMENT ON COLUMN public.surface_samples_grades.opid            IS 'Operation identifier';
--...
COMMENT ON COLUMN public.surface_samples_grades.campaign        IS 'Campaign: year, type, etc. i.e. till exploration 1967';
COMMENT ON COLUMN public.surface_samples_grades.datasource      IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN public.surface_samples_grades.numauto         IS 'Automatic integer primary key';
COMMENT ON COLUMN public.surface_samples_grades.creation_ts     IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN public.surface_samples_grades.username        IS 'User (role) which created data record';
-- TODO remain quite a few fields to comment.  But this structure is certainly not relevant.

--}}}
--}}}
-- x geochemistry:{{{
-- x geoch_sampling:{{{

CREATE TABLE public.geoch_sampling (
    opid                integer
        REFERENCES public.operations (opid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED,
    id                  text,
    lab_id              text,
    labo_ref            text,
    amc_ref             text,
    recep_date          date,
    type                text, -- TODO change field name: appears highlighted in vim: must be a reserved word
    sampl_index         text NOT NULL,
    x                   numeric(15,4),
    y                   numeric(15,4),
    z                   numeric(10,4),
    soil_color          text,
    type_sort           text,
    depth_cm            numeric(10,2),
    reg_type            text,
    geomorphology       text,
    rock_type           text,
    comment             text, -- TODO change field name: appears highlighted in vim: is a reserved word
    utm_zone            text,
    geologist           text,
    float_sampl         text,
    host_rock           text,
    prospect            text,
    spacing             text,
    horizon             text,
    date                date,       -- TODO change field name: appears highlighted in vim: obviously a reserved word
    survey_type         text,
    grid_line           text,
    grid_station        text,
    alteration          text,
    occ_soil            text,
    slope               text,
    slope_dir           text,
    soil_description    text,
    datasource          integer,
    numauto             bigserial PRIMARY KEY,
    creation_ts         timestamptz DEFAULT now() NOT NULL,
    username            text DEFAULT current_user
);
COMMENT ON TABLE public.geoch_sampling                          IS 'Geochemistry samples, from soil or stream sediments: location and description data';
COMMENT ON COLUMN public.geoch_sampling.opid                    IS 'Operation identifier';
COMMENT ON COLUMN public.geoch_sampling.id                      IS 'Identification';
COMMENT ON COLUMN public.geoch_sampling.lab_id                  IS 'Analysis laboratory';
COMMENT ON COLUMN public.geoch_sampling.labo_ref                IS 'Analysis laboratory report reference';
COMMENT ON COLUMN public.geoch_sampling.amc_ref                 IS 'AMC analysis report reference'; --TODO get AMC mentions out
COMMENT ON COLUMN public.geoch_sampling.recep_date              IS 'Report reception date by AMC';  --TODO get AMC mentions out
COMMENT ON COLUMN public.geoch_sampling.type                    IS 'Analysis type';
COMMENT ON COLUMN public.geoch_sampling.sampl_index             IS 'Auto increment integer';
COMMENT ON COLUMN public.geoch_sampling.x                       IS 'X coordinate, projected in UTM (m)';
COMMENT ON COLUMN public.geoch_sampling.y                       IS 'Y coordinate, projected in UTM (m)';
COMMENT ON COLUMN public.geoch_sampling.z                       IS 'Z coordinate, projected in UTM (m)';
COMMENT ON COLUMN public.geoch_sampling.soil_color              IS 'Soil color';
COMMENT ON COLUMN public.geoch_sampling.type_sort               IS 'Sort of type';
COMMENT ON COLUMN public.geoch_sampling.depth_cm                IS 'Sample depth';
COMMENT ON COLUMN public.geoch_sampling.reg_type                IS 'Type of region';
COMMENT ON COLUMN public.geoch_sampling.geomorphology           IS 'Some region description';
COMMENT ON COLUMN public.geoch_sampling.rock_type               IS 'Lithology';
COMMENT ON COLUMN public.geoch_sampling.comment                 IS 'Some comments';
COMMENT ON COLUMN public.geoch_sampling.utm_zone                IS 'UTM area';
COMMENT ON COLUMN public.geoch_sampling.geologist               IS 'geologist';
COMMENT ON COLUMN public.geoch_sampling.float_sampl             IS 'sample designation (?)';
COMMENT ON COLUMN public.geoch_sampling.host_rock               IS 'host rock';
COMMENT ON COLUMN public.geoch_sampling.date                    IS 'type of survey (ex : HHGPS)';
COMMENT ON COLUMN public.geoch_sampling.datasource              IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN public.geoch_sampling.numauto                 IS 'Automatic integer';
COMMENT ON COLUMN public.geoch_sampling.creation_ts             IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN public.geoch_sampling.username                IS 'User (role) which created data record';

--}}}
-- x geoch_ana:{{{

CREATE TABLE public.geoch_ana (
    opid                integer
        REFERENCES public.operations (opid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED,
    sampl_index         integer,
    ana_type            text,
    unit                text,
    det_lim             numeric(6,4),
    scheme              text,
    comment             text,
    value               numeric(10,3),
    datasource          integer,
    numauto             bigserial PRIMARY KEY,
    creation_ts         timestamptz DEFAULT now() NOT NULL,
    username            text DEFAULT current_user
);
COMMENT ON TABLE  public.geoch_ana                              IS 'Assay results from geochemistry samples';
COMMENT ON COLUMN public.geoch_ana.opid                         IS 'Operation identifier';
COMMENT ON COLUMN public.geoch_ana.sampl_index                  IS 'Sample identification related to the geoch_sampling table';
COMMENT ON COLUMN public.geoch_ana.ana_type                     IS 'Analysis type ';
COMMENT ON COLUMN public.geoch_ana.unit                         IS 'Unit of the analysis ';
COMMENT ON COLUMN public.geoch_ana.det_lim                      IS 'Analysis detection limit';
COMMENT ON COLUMN public.geoch_ana.scheme                       IS 'Analysis method';
COMMENT ON COLUMN public.geoch_ana.comment                      IS 'Some comments';
COMMENT ON COLUMN public.geoch_ana.value                        IS 'Analysis value';
COMMENT ON COLUMN public.geoch_ana.datasource                   IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN public.geoch_ana.numauto                      IS 'Automatic integer primary key';
COMMENT ON COLUMN public.geoch_ana.creation_ts                  IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN public.geoch_ana.username                     IS 'User (role) which created data record';

--}}}
-- x geoch_sampling_grades:{{{
-- Vérifier si cette table est utile, et si oui en quoi, comment.

CREATE TABLE geoch_sampling_grades (
    numauto             bigserial PRIMARY KEY,
    au_ppb              numeric
)
INHERITS (geoch_sampling);
COMMENT ON TABLE geoch_sampling_grades                          IS 'Geochemistry samples with grades; table inherits from geoch_sampling';
-- COMMENT ON COLUMN geoch_sampling_grades.opid                   IS 'Operation identifier';
-- COMMENT ON COLUMN geoch_sampling_grades.datasource             IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN geoch_sampling_grades.numauto                 IS 'Automatic integer primary key';
COMMENT ON COLUMN geoch_sampling_grades.au_ppb                  IS 'Au grade ppb';

--}}}
--}}}
-- x geophysics:{{{
-- x gpy_mag_ground:{{{

-- SET search_path = public, pg_catalog;
-- Name: gpy_mag_ground; Type: TABLE; Schema: public; Owner: data_admin; Tablespace:

CREATE TABLE gpy_mag_ground (
    opid                     integer
        REFERENCES public.operations (opid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED,
    srid                     integer,
    x                        numeric,
    y                        numeric,
    z                        numeric,
    x_local                  numeric,
    y_local                  numeric,
    mag_nanotesla            double precision,
    val_corr_mag_nanotesla   double precision,
    datasource               integer,
    numauto                  bigserial PRIMARY KEY,
    creation_ts              timestamptz DEFAULT now() NOT NULL,
    username                 text DEFAULT current_user
);
COMMENT ON TABLE gpy_mag_ground                                 IS 'Geophysics: ground mag';
COMMENT ON COLUMN gpy_mag_ground.opid                           IS 'Operation identifier';
COMMENT ON COLUMN gpy_mag_ground.datasource                     IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN gpy_mag_ground.numauto                        IS 'Automatic integer primary key';
COMMENT ON COLUMN gpy_mag_ground.creation_ts                    IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN gpy_mag_ground.username                       IS 'User (role) which created data record';

--}}}
-- o gpy_radiometry{{{
-- TODO plans compteurs
-- }}}
-- o other methods: TODO panneau électrique, PS, sismique marteau, etc.

--}}}
-- x drill holes: table names prefixed with dh_ {{{
-- x dh_collars {{{

CREATE TABLE public.dh_collars (
    opid                integer
        REFERENCES public.operations (opid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED,
    id                  text NOT NULL,
    location            text,
    campaign            text,
    purpose             text DEFAULT 'EXPLO',  -- defaulting to EXPLOration, but this is just for the time being.  A preferences, or defaults, table, should be implemented; or an external file, for such default values.
    profile             text,
    srid                integer,
    x                   numeric,
    y                   numeric,
    z                   numeric,
    azim_ng             numeric,
    azim_nm             numeric,
    dip_hz              numeric,
    length              numeric,
    dh_type             text,
    date_start          date,
    date_completed      date,
    completed           boolean DEFAULT false,
    contractor          text,
    geologist           text,
    nb_samples          integer,
    topo_survey_type    text,
    comments            text,
    x_local             numeric,
    y_local             numeric,
    z_local             numeric,
    accusum             numeric,
    id_pject            text,
    x_pject             numeric,
    y_pject             numeric,
    z_pject             numeric,
    shid                text,
    datasource          integer,
    numauto             bigserial PRIMARY KEY,
    creation_ts         timestamptz DEFAULT now() NOT NULL,
    username            text DEFAULT current_user,
    UNIQUE (opid, id)
);
-- Fields from previous versions, dropped:
    --len_destr numeric(10,2),
    --len_pq numeric(10,2),
    --len_hq numeric(10,2),
    --len_nq numeric(10,2),
    --len_bq numeric(10,2),
COMMENT ON TABLE dh_collars                                     IS 'Drill holes collars or trenches starting points';
COMMENT ON COLUMN dh_collars.opid                               IS 'Operation identifier, refers to operations table';
COMMENT ON COLUMN dh_collars.id                                 IS 'Full identifier for borehole or trench, may include zone code, type and sequential number.  opid and id make the unique key of dh_collars table.';
COMMENT ON COLUMN dh_collars.location                           IS 'Investigated area code, refers to occurrences table';
COMMENT ON COLUMN dh_collars.campaign                           IS 'Campaign: year, type, etc. i.e. DDH exploration 1967';
COMMENT ON COLUMN dh_collars.purpose                            IS 'Purpose of hole: exploration, delineation, estimation, grade control, etc.';
COMMENT ON COLUMN dh_collars.profile                            IS 'Profile number';
COMMENT ON COLUMN dh_collars.srid                               IS 'Spatial Reference Identifier, or coordinate reference system: see spatial_ref_sys from postgis extension';
COMMENT ON COLUMN dh_collars.x                                  IS 'X coordinate (Easting),  in coordinate system srid';
COMMENT ON COLUMN dh_collars.y                                  IS 'Y coordinate (Northing), in coordinate system srid';
COMMENT ON COLUMN dh_collars.z                                  IS 'Z coordinate';
COMMENT ON COLUMN dh_collars.azim_ng                            IS 'Hole or trench azimuth (°) relative to geographic North';
COMMENT ON COLUMN dh_collars.azim_nm                            IS 'Hole or trench azimuth (°) relative to Magnetic North';
COMMENT ON COLUMN dh_collars.dip_hz                             IS 'Drill hole or trench dip relative to horizontal (°)';
COMMENT ON COLUMN dh_collars.length                             IS 'Total length (m)';
COMMENT ON COLUMN dh_collars.dh_type                            IS 'Type: D for Diamond drill hole, R for RC drill hole, T for Trench, A for Auger drill hole';
COMMENT ON COLUMN dh_collars.date_start                         IS 'Work start date';
COMMENT ON COLUMN dh_collars.date_completed                     IS 'Work finish date';
COMMENT ON COLUMN dh_collars.completed                          IS 'True: completed; False: planned';
COMMENT ON COLUMN dh_collars.contractor                         IS 'Drilling contractor';
COMMENT ON COLUMN dh_collars.geologist                          IS 'Geologist name';
COMMENT ON COLUMN dh_collars.nb_samples                         IS 'Number of samples; mainly for quality check purpose, redundancy with count from dh_sampling child table';
COMMENT ON COLUMN dh_collars.topo_survey_type                   IS 'Topographic collar survey type: GPS, GPSD, geometry, theodolite, relative, computed from local coordinate system, etc.';
COMMENT ON COLUMN dh_collars.comments                           IS 'Comments, e.g. quick history of the hole, why it stopped, remarkable facts, etc.';
COMMENT ON COLUMN dh_collars.x_local                            IS 'Local x coordinate';
COMMENT ON COLUMN dh_collars.y_local                            IS 'Local y coordinate';
COMMENT ON COLUMN dh_collars.z_local                            IS 'Local z coordinate';
COMMENT ON COLUMN dh_collars.accusum                            IS 'Accumulation sum over various mineralised intervals intersected by drill hole or trench (purpose: quick visualisation on maps (at wide scale ONLY), quick ranking of interesting holes)';
COMMENT ON COLUMN dh_collars.id_pject                           IS 'PJ for ProJect identifier: provisional identifier; aka peg number';
COMMENT ON COLUMN dh_collars.x_pject                            IS 'Planned x coordinate';
COMMENT ON COLUMN dh_collars.y_pject                            IS 'Planned y coordinate';
COMMENT ON COLUMN dh_collars.z_pject                            IS 'Planned z coordinate';
COMMENT ON COLUMN dh_collars.shid                               IS 'Short identifier: e.g. _ sequential number (rarely used)';
COMMENT ON COLUMN dh_collars.datasource                         IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN dh_collars.numauto                            IS 'Automatic integer primary key';
COMMENT ON COLUMN dh_collars.creation_ts                        IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_collars.username                           IS 'User (role) which created data record';
--COMMENT ON COLUMN dh_collars.old_flid                           IS 'Old identifier, as in original data files';              -- field dropped
--COMMENT ON COLUMN collars.problems                              IS 'If there is a problem or not, in terms of data integrity/consistency'; -- field dropped
--COMMENT ON COLUMN dh_collars.export                             IS 'Data to be exported or not';                             -- field dropped
--COMMENT ON COLUMN dh_collars.len_destr                          IS 'Destructive (percussion or rotary drilling) length (m)'; -- field dropped
--COMMENT ON COLUMN dh_collars.len_pq                             IS 'Core PQ length (m)';                                     -- field dropped
--COMMENT ON COLUMN dh_collars.len_hq                             IS 'Core HQ length (m)';                                     -- field dropped
--COMMENT ON COLUMN dh_collars.len_nq                             IS 'Core NQ length (m)';                                     -- field drop ped
--COMMENT ON COLUMN dh_collars.len_bq                             IS 'Core BQ length (m)';                                     -- field dropped

--}}}
-- x dh_shift_reports{{{ --ATTENTION! TODO CHANGER TOUTES RÉFÉRENCES À shift_reports EN dh_shift_reports!

CREATE TABLE dh_shift_reports (
    opid                          integer,
    date                          date,
    shift                         text,
    no_fichette                   integer NOT NULL,
    rig                           text,
    geologist                     text,
    time_start                    time with time zone,
    time_end                      time with time zone,
    id                            text,
    peg_number                    text,
    planned_length                numeric(10,2),
    tool                          text,
    drilled_length_during_shift   numeric(10,2),
    drilled_length                numeric(10,2),
    completed                     boolean,
    profile                       text,
    comments                      text,
    invoice_nr                    integer,
    drilled_shift_destr           numeric,
    drilled_shift_pq              numeric,
    drilled_shift_hq              numeric,
    drilled_shift_nq              numeric,
    recovered_length_shift        numeric,
    stdby_time1_h                 numeric,
    stdby_time2_h                 numeric,
    stdby_time3_h                 numeric,
    moving_time_h                 numeric,
    driller_name                  text,
    geologist_supervisor          text,
    datasource                    integer,
    numauto                       bigserial PRIMARY KEY,
    creation_ts                   timestamptz DEFAULT now() NOT NULL,
    username                      text DEFAULT current_user,
    FOREIGN KEY (opid, id)
        REFERENCES public.dh_collars (opid, id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED
);

COMMENT ON TABLE dh_shift_reports                               IS 'Daily reports from rigsites: one report per shift/machine/tool';
COMMENT ON COLUMN dh_shift_reports.opid                         IS 'Operation identifier';
COMMENT ON COLUMN dh_shift_reports.date                         IS 'Date of drilling';
COMMENT ON COLUMN dh_shift_reports.shift                        IS 'Day or night shift';
COMMENT ON COLUMN dh_shift_reports.no_fichette                  IS 'Number of fichette = field form filled on a shift and borehole basis';
COMMENT ON COLUMN dh_shift_reports.rig                          IS 'Name/id of drilling (or digging) machine';
COMMENT ON COLUMN dh_shift_reports.geologist                    IS 'Geologist(s) following the drill hole on the rig site, doing the logging.';
COMMENT ON COLUMN dh_shift_reports.time_start                   IS 'Drilling starting time';
COMMENT ON COLUMN dh_shift_reports.time_end                     IS 'Drilling ending time';
COMMENT ON COLUMN dh_shift_reports.id                           IS 'Drill hole identifier, must match collars.id field, e.g. UMA_R086';
COMMENT ON COLUMN dh_shift_reports.peg_number                   IS 'Peg number: provisional identifier/number; aka PJ for ProJect identifier';
COMMENT ON COLUMN dh_shift_reports.planned_length               IS 'Length of the borehole, as initially planned';
COMMENT ON COLUMN dh_shift_reports.tool                         IS 'Drilling (digging) tool/size, diameter: RC, RAB, percussion, core, SQ, PQ, HQ, NQ, BQ, AQ, mechanical shovel, hand shovel, banka, etc.';
COMMENT ON COLUMN dh_shift_reports.drilled_length_during_shift  IS 'Length of borehole drilled during the shift';
COMMENT ON COLUMN dh_shift_reports.drilled_length               IS 'Total length of the borehole drilled at the end of the shift';
COMMENT ON COLUMN dh_shift_reports.completed                    IS 'Borehole finished or not';
COMMENT ON COLUMN dh_shift_reports.profile                      IS 'Section identifier';
COMMENT ON COLUMN dh_shift_reports.comments                     IS 'Comments on drilling (events, presence of water, difficulties, major facies, etc.)';
COMMENT ON COLUMN dh_shift_reports.invoice_nr                   IS 'Subcontractor invoice number';
COMMENT ON COLUMN dh_shift_reports.drilled_shift_destr          IS 'Drilled length during shift in destructive';
COMMENT ON COLUMN dh_shift_reports.drilled_shift_pq             IS 'Drilled length during shift in PQ core';
COMMENT ON COLUMN dh_shift_reports.drilled_shift_hq             IS 'Drilled length during shift in HQ core';
COMMENT ON COLUMN dh_shift_reports.drilled_shift_nq             IS 'Drilled length during shift in NQ core';
COMMENT ON COLUMN dh_shift_reports.recovered_length_shift       IS 'Recovered length during shift';
COMMENT ON COLUMN dh_shift_reports.stdby_time1_h                IS 'Standby time hours, with machine powered on';
COMMENT ON COLUMN dh_shift_reports.stdby_time2_h                IS 'Standby time hours, with machine powered off';
COMMENT ON COLUMN dh_shift_reports.stdby_time3_h                IS 'Standby time hours, due to weather conditions';
COMMENT ON COLUMN dh_shift_reports.moving_time_h                IS 'Moving time hours';
COMMENT ON COLUMN dh_shift_reports.driller_name                 IS 'Driller supervisor name';
COMMENT ON COLUMN dh_shift_reports.geologist_supervisor         IS 'Geologist supervisor name';
COMMENT ON COLUMN dh_shift_reports.datasource                   IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN dh_shift_reports.numauto                      IS 'Automatic integer';
COMMENT ON COLUMN dh_shift_reports.creation_ts                  IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_shift_reports.username                     IS 'User (role) which created data record';

--}}}
-- x dh_followup {{{

CREATE TABLE dh_followup (
    opid                integer,
    id                  text,
    devia               text,
    quick_log           text,
    log_tech            text,
    log_lith            text,
    sampling            text,
    results             text,
    relogging           text,
    beacon              text,
    in_gdm              text,
    numauto             bigserial PRIMARY KEY,
    creation_ts         timestamptz DEFAULT now() NOT NULL,
    username            text DEFAULT current_user,
    FOREIGN KEY (opid, id)
        REFERENCES public.dh_collars (opid, id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED
);
COMMENT ON TABLE dh_followup                                    IS 'Simple table for daily drill holes followup';
COMMENT ON COLUMN dh_followup.opid                              IS 'Operation identifier';
COMMENT ON COLUMN dh_followup.id                                IS 'Identifier, refers to dh_collars';
COMMENT ON COLUMN dh_followup.devia                             IS 'Deviation survey (x: done; xx: done, data entered; xxx: data verified)';
COMMENT ON COLUMN dh_followup.quick_log                         IS 'Quick geological log, typically done on hole finish, for an A4 log plot (x: done; xx: done, data entered; xxx: data verified)';
COMMENT ON COLUMN dh_followup.log_tech                          IS 'Core fitting, core measurement, meters marking, RQD, fracture counts, etc. (x: done; xx: done, data entered; xxx: data verified)';
COMMENT ON COLUMN dh_followup.log_lith                          IS 'Full geological log (x: done; xx: done, data entered; xxx: data verified)';
COMMENT ON COLUMN dh_followup.sampling                          IS 'Hole sampling (x: done; xx: done, data entered; xxx: data verified)';
COMMENT ON COLUMN dh_followup.results                           IS 'Assay results back from laboratory (x: received; xx: entered; xxx: verified)';
COMMENT ON COLUMN dh_followup.relogging                         IS 'Geological log done afterwards on mineralised intervals (x: done; xx: done, data entered; xxx: data verified)';
COMMENT ON COLUMN dh_followup.beacon                            IS 'Beacon or any other permanent hole marker on field (PVC pipe, concrete beacon, cement, etc.) (x: done)';
COMMENT ON COLUMN dh_followup.in_gdm                            IS 'Data exported to GDM; implicitely: data clean, checked by GDM procedures (x: done)';
COMMENT ON COLUMN dh_followup.numauto                           IS 'Automatic integer primary key';
COMMENT ON COLUMN dh_followup.creation_ts                       IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_followup.username                          IS 'User (role) which created data record';

--}}}
-- x dh_devia {{{

CREATE TABLE dh_devia (
    opid                integer,
    id                  text,
    depto               numeric(10,2),
    device              text,
    azim_nm             numeric(10,2),
    azim_ng             numeric(10,2),
    dip_hz              numeric(10,2),
    x_offset            numeric(10,2),
    y_offset            numeric(10,2),
    z_offset            numeric(10,2),
    temperature         numeric(10,2),
    magnetic            numeric(10,2),
    date                date,
    roll                numeric(10,2),
    "time"              integer,                --TODO change field name
    comments            text,
    valid               boolean DEFAULT true,
    datasource          integer,
    numauto             bigserial PRIMARY KEY,
    creation_ts         timestamptz DEFAULT now() NOT NULL,
    username            text DEFAULT current_user,
    FOREIGN KEY (opid, id)
        REFERENCES public.dh_collars (opid, id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED
);
COMMENT ON TABLE dh_devia                             IS 'Drill holes or trenches deviations measurements';
COMMENT ON COLUMN dh_devia.opid                       IS 'Operation identifier';
COMMENT ON COLUMN dh_devia.id                         IS 'Drill hole identification related to the collars table';
COMMENT ON COLUMN dh_devia.depto                      IS 'Depth of deviation measurement';
COMMENT ON COLUMN dh_devia.device                     IS 'Device used for deviation measurement';
COMMENT ON COLUMN dh_devia.azim_nm                    IS 'Hole azimuth (°) relative to magnetic North (normally, this should be the actual measurement, with a magnetic orientation tool)';
COMMENT ON COLUMN dh_devia.azim_ng                    IS 'Hole azimuth (°) relative to geographic North';
COMMENT ON COLUMN dh_devia.dip_hz                     IS 'Drill hole dip relative to horizontal (°), positive down';
COMMENT ON COLUMN dh_devia.x_offset                   IS 'Offset of hole in x';
COMMENT ON COLUMN dh_devia.y_offset                   IS 'Offset of hole in y';
COMMENT ON COLUMN dh_devia.z_offset                   IS 'True vertical depth';
COMMENT ON COLUMN dh_devia.temperature                IS 'temperature';
COMMENT ON COLUMN dh_devia.magnetic                   IS 'Magnetic field intensity measurement';
COMMENT ON COLUMN dh_devia.date                       IS 'Date of deviation measurement';
COMMENT ON COLUMN dh_devia.roll                       IS 'Roll angle';
COMMENT ON COLUMN dh_devia."time"                     IS 'Time of deviation measurement';
COMMENT ON COLUMN dh_devia.comments                   IS 'Various comments; concerning measurements done with Reflex Gyro, all parameters are concatened as a json-like structure';
COMMENT ON COLUMN dh_devia.valid                      IS 'True when a deviation measurement is usable; queries should take into account only valid records';
COMMENT ON COLUMN dh_devia.datasource                 IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN dh_devia.numauto                    IS 'Automatic integer primary key';
COMMENT ON COLUMN dh_devia.creation_ts                IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_devia.username                   IS 'User (role) which created data record';

-- TODO convert the json-like data into a real json field.

--}}}
-- x dh_quicklog {{{

CREATE TABLE dh_quicklog (
    opid                integer,
    id                  text,
    depfrom             numeric(10,2),
    depto               numeric(10,2),
    code                text,
    description         text,
    oxid                text,
    alt                 smallint,
    def                 smallint,
    datasource          integer,
    numauto             bigserial PRIMARY KEY,
    creation_ts         timestamptz DEFAULT now() NOT NULL,
    username            text DEFAULT current_user,
    FOREIGN KEY (opid, id)
        REFERENCES public.dh_collars (opid, id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED
);
COMMENT ON TABLE public.dh_quicklog                   IS 'Quick geological log, typically done on hole finish, for an A4 log plot';
COMMENT ON COLUMN public.dh_quicklog.opid             IS 'Operation identifier';
COMMENT ON COLUMN public.dh_quicklog.id               IS 'Full identifier for borehole or trench';
COMMENT ON COLUMN public.dh_quicklog.depfrom          IS 'Interval beginning depth';
COMMENT ON COLUMN public.dh_quicklog.depto            IS 'Interval ending depth';
COMMENT ON COLUMN public.dh_quicklog.code             IS 'Codification for main unit; similar to unit code in dh_litho table';
COMMENT ON COLUMN public.dh_quicklog.description      IS 'Quick geological description, logging wide intervals and/or only representative portions';
COMMENT ON COLUMN public.dh_quicklog.oxid             IS 'Oxidation state: O, PO, U';
COMMENT ON COLUMN public.dh_quicklog.alt              IS 'Alteration intensity: 0: none, 1: weak, 2: moderate, 3: strong';
COMMENT ON COLUMN public.dh_quicklog.def              IS 'Deformation intensity: 0: none, 1: weak, 2: moderate, 3: strong';
COMMENT ON COLUMN public.dh_quicklog.datasource       IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN public.dh_quicklog.numauto          IS 'Automatic integer primary key';
COMMENT ON COLUMN public.dh_quicklog.creation_ts      IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN public.dh_quicklog.username         IS 'User (role) which created data record';

--}}}
-- x dh_litho {{{
-- lithological descriptions

CREATE TABLE dh_litho (
    opid                integer,
    id                  text,
    depfrom             numeric(10,2),
    depto               numeric(10,2),
    description         text,
    description1        text,
    description2        text,
    code1               text,
    code2               text,
    code3               text,
    code4               text,
    value1              integer,
    value2              integer,
    value3              integer,
    value4              integer,
    value5              integer,
    value6              integer,
    colour              text,
    datasource          integer,
    numauto             bigserial PRIMARY KEY,
    creation_ts         timestamptz DEFAULT now() NOT NULL,
    username            text DEFAULT current_user,
    FOREIGN KEY (opid, id)
        REFERENCES public.dh_collars (opid, id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED
);
COMMENT ON TABLE dh_litho                             IS 'Drill holes or trenches geological descriptions';
COMMENT ON COLUMN dh_litho.opid                       IS 'Operation identifier';
COMMENT ON COLUMN dh_litho.id                         IS 'Identifier, refers to dh_collars';
COMMENT ON COLUMN dh_litho.depfrom                    IS 'Interval beginning depth';
COMMENT ON COLUMN dh_litho.depto                      IS 'Interval ending depth';
COMMENT ON COLUMN dh_litho.description                IS 'Geological description, naturalist style';
COMMENT ON COLUMN dh_litho.description1               IS 'Complement to main geological description: metallic minerals';
--COMMENT ON COLUMN public.dh_litho.description1        IS 'Complement1 to main geological description: metallic minerals';
COMMENT ON COLUMN dh_litho.description2               IS 'Complement to main geological description: alterations';
--COMMENT ON COLUMN public.dh_litho.description2        IS 'Complement1 to main geological description: alterations';
COMMENT ON COLUMN dh_litho.code1                      IS 'Conventional use is lithology code, 4 characters, uppercase. Refer to lex_codes table';
--COMMENT ON COLUMN public.dh_litho.code1               IS 'Conventional use is lithology code, 4 characters, uppercase. Refer to def_litho_code_value_fields table';
COMMENT ON COLUMN dh_litho.code2                      IS 'Conventional use is supergene oxidation, 1 character, uppercase. Refer to lex_codes table';
--COMMENT ON COLUMN public.dh_litho.code2               IS 'Conventional use is supergene oxidation, 1 character, uppercase. Refer to def_litho_code_value_fields table';
COMMENT ON COLUMN dh_litho.code3                      IS 'Conventional use is stratigraphy code, 4 characters, uppercase. Refer to lex_codes table';
--COMMENT ON COLUMN public.dh_litho.code3 IS           'Conventional use is stratigraphy code, 4 characters, uppercase. Refer to def_litho_code_value_fields table';
COMMENT ON COLUMN dh_litho.code4                      IS '4 characters code. Refer to lex_codes table';
--COMMENT ON COLUMN public.dh_litho.code4 IS           '4 characters code. Refer to def_litho_code_value_fields table';
COMMENT ON COLUMN dh_litho.value1                     IS 'Integer value. Refer to lex_codes table';
--COMMENT ON COLUMN public.dh_litho.value1 IS           'Integer value. Refer to def_litho_code_value_fields table';
COMMENT ON COLUMN dh_litho.value2                     IS 'Integer value. Refer to lex_codes table';
--COMMENT ON COLUMN public.dh_litho.value2 IS           'Integer value. Refer to def_litho_code_value_fields table';
COMMENT ON COLUMN dh_litho.value3                     IS 'Integer value. Refer to lex_codes table';
--COMMENT ON COLUMN public.dh_litho.value3 IS           'Integer value. Refer to def_litho_code_value_fields table';
COMMENT ON COLUMN dh_litho.value4                     IS 'Integer value. Refer to lex_codes table';
--COMMENT ON COLUMN public.dh_litho.value4 IS           'Integer value. Refer to def_litho_code_value_fields table';
COMMENT ON COLUMN dh_litho.value5                     IS 'Integer value. Refer to lex_codes table';
--COMMENT ON COLUMN public.dh_litho.value5 IS          'Integer value. Refer to def_litho_code_value_fields table';
COMMENT ON COLUMN dh_litho.value6                     IS 'Integer value. Refer to lex_codes table';
--COMMENT ON COLUMN public.dh_litho.value6 IS          'Integer value. Refer to def_litho_code_value_fields table';
COMMENT ON COLUMN dh_litho.datasource                 IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN dh_litho.numauto                    IS 'Automatic integer primary key';
COMMENT ON COLUMN dh_litho.creation_ts                IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_litho.username                   IS 'User (role) which created data record';

--}}}
-- x dh_core_boxes {{{

CREATE TABLE dh_core_boxes (
    opid                integer,
    id                  text,
    depfrom             numeric(10,2),
    depto               numeric(10,2),
    box_number          integer,
    datasource          integer,
    numauto             bigserial PRIMARY KEY,
    creation_ts         timestamptz DEFAULT now() NOT NULL,
    username            text DEFAULT current_user,
    FOREIGN KEY (opid, id)
        REFERENCES public.dh_collars (opid, id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED
);
COMMENT ON TABLE dh_core_boxes                        IS 'Core drill holes boxes';
COMMENT ON COLUMN dh_core_boxes.opid                  IS 'Operation identifier';
COMMENT ON COLUMN dh_core_boxes.id                    IS 'Identifier, refers to dh_collars';
COMMENT ON COLUMN dh_core_boxes.depfrom               IS 'Core box contents beginning depth';
COMMENT ON COLUMN dh_core_boxes.depto                 IS 'Core box contents ending depth';
COMMENT ON COLUMN dh_core_boxes.box_number            IS 'Core box number';
COMMENT ON COLUMN dh_core_boxes.datasource            IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN dh_core_boxes.numauto               IS 'Automatic integer primary key';
COMMENT ON COLUMN dh_core_boxes.creation_ts           IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_core_boxes.username              IS 'User (role) which created data record';

--}}}
-- x dh_tech {{{

CREATE TABLE dh_tech (
    opid                integer,
    id                  text,
    depfrom             numeric(10,2),
    depto               numeric(10,2),
    drilled_len         numeric(10,2),
    reco_len            numeric(10,2),
    rqd_len             numeric(10,2),
    diam                text,
    comments            text,
    drillers_depto      numeric(10,2),
    core_loss_cm        integer,
    joints_description  text,
    nb_joints           integer,
    datasource          integer,
    numauto             bigserial PRIMARY KEY,
    creation_ts         timestamptz DEFAULT now() NOT NULL,
    username            text DEFAULT current_user,
    FOREIGN KEY (opid, id)
        REFERENCES public.dh_collars (opid, id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED
);
COMMENT ON TABLE dh_tech                              IS 'Technical drilling data, and geotechnical parameters';
COMMENT ON COLUMN dh_tech.opid                        IS 'Operation identifier';
COMMENT ON COLUMN dh_tech.id                          IS 'Drill hole identification';
COMMENT ON COLUMN dh_tech.depfrom                     IS 'Interval begining depth';
COMMENT ON COLUMN dh_tech.depto                       IS 'Interval ending depth';
COMMENT ON COLUMN dh_tech.drilled_len                 IS 'Interval length';
COMMENT ON COLUMN dh_tech.reco_len                    IS 'Recovery length';
COMMENT ON COLUMN dh_tech.rqd_len                     IS 'Rock Quality Designation "length"';
COMMENT ON COLUMN dh_tech.diam                        IS 'core diameter';
COMMENT ON COLUMN dh_tech.drillers_depto              IS 'Driller end-of-run depth, as mentioned on core block';
COMMENT ON COLUMN dh_tech.core_loss_cm                IS 'Core loss along drilled run';
COMMENT ON COLUMN dh_tech.joints_description          IS 'Joints description: rugosity, fillings, etc.';
COMMENT ON COLUMN dh_tech.nb_joints                   IS 'Count of natural joints along drilled run';
COMMENT ON COLUMN dh_tech.datasource                  IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN dh_tech.numauto                     IS 'Automatic integer primary key';
COMMENT ON COLUMN dh_tech.creation_ts                 IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_tech.username                    IS 'User (role) which created data record';

--}}}
-- x dh_struct_measures {{{

CREATE TABLE dh_struct_measures (
    opid                integer,
    id                  text,
    depto               numeric(10,2),
    measure_type        text,
    structure_type      text,
    alpha_tca           numeric,
    beta                numeric,
    gamma               numeric,
    north_ref           text,
    direction           integer,
    dip                 integer,
    dip_quadrant        text,
    pitch               integer,
    pitch_quadrant      text,
    movement            text,
    valid               boolean,
    struct_description  text,
    sortgroup           text,
    datasource          integer,
    numauto             bigserial PRIMARY KEY,
    creation_ts         timestamptz DEFAULT now() NOT NULL,
    username            text DEFAULT current_user,
    FOREIGN KEY (opid, id)
        REFERENCES public.dh_collars (opid, id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED
);
COMMENT ON TABLE dh_struct_measures                   IS 'Structural measurements done on core, or in trenches';
COMMENT ON COLUMN dh_struct_measures.opid             IS 'Operation identifier';
COMMENT ON COLUMN dh_struct_measures.id               IS 'Full identifier for borehole or trench';
COMMENT ON COLUMN dh_struct_measures.depto            IS 'Measurement depth';
COMMENT ON COLUMN dh_struct_measures.measure_type     IS 'Type of measurement: [P: plane L: line PL: plane line PLM: plane line movement PLMS: plane line movement sure]';
COMMENT ON COLUMN dh_struct_measures.structure_type   IS 'Measured structure type: [VEIN , FRACTURE , C , SCHISTOSITY , FOLIATION , MYLONITE , CONTACT , VEIN_FAULT , FOLD_PAX_AX , FOLIATION_LINE , FAULT , CATACLASE , MINERALISED_STRUCTURE]';
COMMENT ON COLUMN dh_struct_measures.alpha_tca        IS 'Alpha angle = To Core Axis (TCA) angle, measured on core';
COMMENT ON COLUMN dh_struct_measures.beta             IS 'Beta angle';
COMMENT ON COLUMN dh_struct_measures.gamma            IS 'Gamma angle';
COMMENT ON COLUMN dh_struct_measures.north_ref        IS 'North reference for azimuths and directions measurements: [Nm: magnetic North, Ng: geographic North, Nu: UTM north, Nl: local grid Y axis]';
COMMENT ON COLUMN dh_struct_measures.direction        IS 'Plane direction, 0-180°';
COMMENT ON COLUMN dh_struct_measures.dip              IS 'Plane dip, 0-90°';
COMMENT ON COLUMN dh_struct_measures.dip_quadrant     IS 'Plane dip quadrant, NESW';
COMMENT ON COLUMN dh_struct_measures.pitch            IS 'Pitch of line on plane, 0-90°';
COMMENT ON COLUMN dh_struct_measures.pitch_quadrant   IS 'Quadrant of pitch, NESW';
COMMENT ON COLUMN dh_struct_measures.movement         IS 'Relative movement of fault/C: [N: normal, I: inverse = R = reverse, D: dextral, S: sinistral]';
COMMENT ON COLUMN dh_struct_measures.valid            IS 'Measure is valid or not (impossible cases = not valid)';
COMMENT ON COLUMN dh_struct_measures.struct_description IS 'Naturalist description of measured structure';
COMMENT ON COLUMN dh_struct_measures.sortgroup        IS 'Sorting group, for discriminated of various phases: a, b, c, ...';
COMMENT ON COLUMN dh_struct_measures.datasource       IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN dh_struct_measures.numauto          IS 'Automatic integer primary key';
COMMENT ON COLUMN dh_struct_measures.creation_ts      IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_struct_measures.username         IS 'User (role) which created data record';

--}}}
-- x dh_photos:{{{

CREATE TABLE dh_photos (
    opid integer,
    id text,
    pho_id text,
    file text,
    author text,
    datasource integer,
    FOREIGN KEY (opid, id)
        REFERENCES public.dh_collars (opid, id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED
);
--TODO il manque BEAUCOUP de choses: profondeurs... Et, aussi, est-il bien judicieux d'ainsi séparer les photos de trous des photos d'autre chose??

--}}}
-- x dh_samples_submission:{{{

CREATE TABLE dh_samples_submission (
    opid integer,
    id text,
    sampfrom smallint,
    sampto smallint,
    nb smallint,
    mspu_sub date,
    sgs_subm date,
    final_interm text,
    results text,
    FOREIGN KEY (opid, id)
        REFERENCES public.dh_collars (opid, id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED
);

--}}}
-- x dh_sampling_grades: {{{

CREATE TABLE dh_sampling_grades (
    opid integer,
    id text,
    depfrom numeric(10,2),
    depto numeric(10,2),
    core_loss_cm numeric(5,1),
    weight_kg numeric(6,2),
    sample_type text,
    sample_id text,
    comments text,
    batch_id integer,
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
    datasource integer,
    numauto bigserial PRIMARY KEY,
    creation_ts    timestamptz DEFAULT now() NOT NULL,
    username text DEFAULT current_user,
    FOREIGN KEY (opid, id)
        REFERENCES public.dh_collars (opid, id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED
);
COMMENT ON TABLE dh_sampling_grades                   IS 'Samples along drill holes and trenches, with grades';
COMMENT ON COLUMN dh_sampling_grades.opid             IS 'Operation identifier';
COMMENT ON COLUMN dh_sampling_grades.id               IS 'Identifier, refers to dh_collars';
COMMENT ON COLUMN dh_sampling_grades.depfrom          IS 'Sample beginning depth';
COMMENT ON COLUMN dh_sampling_grades.depto            IS 'Sample ending depth';
COMMENT ON COLUMN dh_sampling_grades.core_loss_cm     IS 'Cumulated core loss over sampled interval, in cm';
COMMENT ON COLUMN dh_sampling_grades.weight_kg        IS 'Sample weight kg';
COMMENT ON COLUMN dh_sampling_grades.sample_type      IS 'Sample type: DD: core sample (diamond drill), RC: percussion drilling Reverse Circulation sample, NS: not sampled, CS: channel sample';
COMMENT ON COLUMN dh_sampling_grades.sample_id        IS 'Sample identifier: refers to assay results and quality check tables';
COMMENT ON COLUMN dh_sampling_grades.comments         IS 'Free comments, if any';
COMMENT ON COLUMN dh_sampling_grades.batch_id         IS 'Batch identifier: refers to batch submission table: lab_ana_batches_expedition';
COMMENT ON COLUMN dh_sampling_grades.au1_ppm          IS 'Au grade 1; cf. usage definition in lex_codes for opid';
COMMENT ON COLUMN dh_sampling_grades.au2_ppm          IS 'Au grade 2; cf. usage definition in lex_codes for opid';
COMMENT ON COLUMN dh_sampling_grades.au3_ppm          IS 'Au grade 3; cf. usage definition in lex_codes for opid';
COMMENT ON COLUMN dh_sampling_grades.au4_ppm          IS 'Au grade 4; cf. usage definition in lex_codes for opid';
COMMENT ON COLUMN dh_sampling_grades.au5_ppm          IS 'Au grade 5; cf. usage definition in lex_codes for opid';
COMMENT ON COLUMN dh_sampling_grades.au6_ppm          IS 'Au grade 6; cf. usage definition in lex_codes for opid';
COMMENT ON COLUMN dh_sampling_grades.ph               IS 'pH measurement (for acidic ores)';
COMMENT ON COLUMN dh_sampling_grades.moisture         IS 'Moisture content (for percussion drilling samples mainly)';
COMMENT ON COLUMN dh_sampling_grades.au_specks        IS 'Number of gold specks seen in drill hole or trench; typically, after panning destructive drilling chips, also gold specks seen in core drilling';
COMMENT ON COLUMN dh_sampling_grades.quartering       IS 'Sample quartering, if any (for percussion drilling samples split on site, mainly)';
COMMENT ON COLUMN dh_sampling_grades.datasource       IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN dh_sampling_grades.numauto          IS 'Automatic integer primary key';
COMMENT ON COLUMN dh_sampling_grades.creation_ts      IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_sampling_grades.username         IS 'User (role) which created data record';

--}}}
-- x resistivity:{{{

CREATE TABLE public.dh_resistivity (
    opid            integer,
    id              text,
    depfrom         numeric(10,2),
    depto           numeric(10,2),
    rlld            numeric(10,2),
    rlls            numeric(10,2),
    numauto         bigserial PRIMARY KEY,
    creation_ts     timestamptz DEFAULT now() NOT NULL,
    username        text DEFAULT current_user,
    FOREIGN KEY (opid, id)
        REFERENCES public.dh_collars (opid, id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED
);
COMMENT ON TABLE public.dh_resistivity                IS 'Down-hole probing: resistivity measurements';
COMMENT ON COLUMN public.dh_resistivity.opid          IS 'Operation identifier';
COMMENT ON COLUMN public.dh_resistivity.id            IS 'Full identifier for borehole or trench';
COMMENT ON COLUMN public.dh_resistivity.depfrom       IS 'Interval beginning depth';
COMMENT ON COLUMN public.dh_resistivity.depto         IS 'Interval ending depth';
COMMENT ON COLUMN public.dh_resistivity.rlld           IS ''; --TODO
COMMENT ON COLUMN public.dh_resistivity.rlls           IS ''; --TODO
COMMENT ON COLUMN public.dh_resistivity.numauto       IS 'Automatic integer';
COMMENT ON COLUMN public.dh_resistivity.creation_ts   IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN public.dh_resistivity.username      IS 'User (role) which created data record';

--}}}
-- x dh_radiometry:{{{

CREATE TABLE public.dh_radiometry (
    opid            integer,
    id              text,
    depfrom         numeric(10,2),
    depto           numeric(10,2),
    a               text,
    probe           text,
    radiometry      numeric,
    comments        text,
    numauto         bigserial PRIMARY KEY,
    creation_ts     timestamptz DEFAULT now() NOT NULL,
    username        text DEFAULT current_user,
    FOREIGN KEY (opid, id)
        REFERENCES public.dh_collars (opid, id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED
);
COMMENT ON TABLE public.dh_radiometry                  IS 'Down-hole probing: radiometry measurements';
COMMENT ON COLUMN public.dh_radiometry.opid            IS 'Operation identifier';
COMMENT ON COLUMN public.dh_radiometry.id              IS 'Full identifier for borehole or trench';
COMMENT ON COLUMN public.dh_radiometry.depfrom         IS 'Interval beginning depth';
COMMENT ON COLUMN public.dh_radiometry.depto           IS 'Interval ending depth';
COMMENT ON COLUMN public.dh_radiometry.a               IS 'Mysterious field containing only A value'; --TODO to be clarified
COMMENT ON COLUMN public.dh_radiometry.probe           IS 'Probe type: ST22, ST33, DHT-';
COMMENT ON COLUMN public.dh_radiometry.radiometry      IS 'Radiometry measurement, equivalent AVP units (hits per second)';
COMMENT ON COLUMN operation_active.numauto             IS 'Automatic integer';
COMMENT ON COLUMN operation_active.creation_ts         IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN operation_active.username            IS 'User (role) which created data record';

--}}}
-- x dh_mineralised_intervals {{{

CREATE TABLE dh_mineralised_intervals (
    opid integer,
    id text,
    depfrom numeric(10,2),
    depto numeric(10,2),
    mine integer DEFAULT 1,
    avau numeric(10,2),
    stva text,
    accu numeric(10,2),
    recu numeric(10,2),
    dens numeric(10,2),
    comments text,
    datasource integer,
    numauto bigserial PRIMARY KEY,
    creation_ts    timestamptz DEFAULT now() NOT NULL,
    username text DEFAULT current_user,
    FOREIGN KEY (opid, id)
        REFERENCES public.dh_collars (opid, id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED
);
COMMENT ON TABLE dh_mineralised_intervals              IS 'Drill holes mineralised intercepts: stretch values over mineralised intervals, along drill holes or trenches';
COMMENT ON COLUMN dh_mineralised_intervals.opid        IS 'Operation identifier';
COMMENT ON COLUMN dh_mineralised_intervals.id          IS 'Full identifier for borehole or trench';
COMMENT ON COLUMN dh_mineralised_intervals.depfrom     IS 'Mineralised interval starting depth';
COMMENT ON COLUMN dh_mineralised_intervals.depto       IS 'Mineralised interval ending depth';
COMMENT ON COLUMN dh_mineralised_intervals.mine        IS 'Take-out interval class: 1=normal interval, 2=high-grade interval ';
COMMENT ON COLUMN dh_mineralised_intervals.avau        IS 'Average grade (g/t)';
COMMENT ON COLUMN dh_mineralised_intervals.stva        IS 'Stretch value, X m at Y g/t';
COMMENT ON COLUMN dh_mineralised_intervals.accu        IS 'Accumulation in m.g/t over mineralised interval';
COMMENT ON COLUMN dh_mineralised_intervals.recu        IS 'recovery';
COMMENT ON COLUMN dh_mineralised_intervals.dens        IS 'density';
COMMENT ON COLUMN dh_mineralised_intervals.datasource  IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN dh_mineralised_intervals.numauto     IS 'Automatic integer primary key';
COMMENT ON COLUMN dh_mineralised_intervals.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_mineralised_intervals.username    IS 'User (role) which created data record';

--}}}
--densités
-- x dh_density {{{

CREATE TABLE dh_density (
    opid integer,
    id text,
    depfrom numeric(10,2),
    depto numeric(10,2),
    density numeric(10,2),
    density_humid numeric,
    moisture numeric,
    method text,
    datasource integer,
    numauto bigserial PRIMARY KEY,
    creation_ts    timestamptz DEFAULT now() NOT NULL,
    username text DEFAULT current_user,
    FOREIGN KEY (opid, id)
        REFERENCES public.dh_collars (opid, id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED
);
COMMENT ON TABLE dh_density                           IS 'Density measurements along drill holes or trenches';
COMMENT ON COLUMN dh_density.opid                     IS 'Operation identifier';
COMMENT ON COLUMN dh_density.id                       IS 'Identifier, refers to dh_collars';
COMMENT ON COLUMN dh_density.depfrom                  IS 'Interval beginning depth: if not empty, density measured along an interval; otherwise, density measured on a point';
COMMENT ON COLUMN dh_density.depto                    IS 'Interval ending depth: if depfrom is empty, depth of ponctual density measurement';
COMMENT ON COLUMN dh_density.density                  IS 'Density, unitless, or considered as kg/l, or t/m3';
COMMENT ON COLUMN dh_density.density_humid            IS 'Density, unitless, or considered as kg/l, or t/m3, determined on humid sample';
COMMENT ON COLUMN dh_density.moisture                 IS 'Moisture contents';
COMMENT ON COLUMN dh_density.method                   IS 'Procedure used to determine specific gravity';
COMMENT ON COLUMN dh_density.datasource               IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN dh_density.numauto                  IS 'Automatic integer primary key';
COMMENT ON COLUMN dh_density.creation_ts              IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_density.username                 IS 'User (role) which created data record';

--}}}
-- x dh_thinsections {{{

CREATE TABLE dh_thinsections (
    opid                               integer,
    id                                 text,
    depto                              numeric(10,2),
    core_quarter                       text,
    questions                          text,
    name                               text,
    texture                            text,
    mineralogy                         text,
    metamorphism_deformations          text,
    mineralisations                    text,
    origin                             text,
    datasource                         integer,
    numauto                            bigserial PRIMARY KEY,
    creation_ts                        timestamptz DEFAULT now() NOT NULL,
    username                           text DEFAULT current_user,
    FOREIGN KEY (opid, id)
        REFERENCES public.dh_collars (opid, id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED
);
COMMENT ON TABLE dh_thinsections                                IS 'Thin sections for petrological studies';
COMMENT ON COLUMN dh_thinsections.opid                          IS 'Operation identifier';
COMMENT ON COLUMN dh_thinsections.id                            IS 'Identifier, refers to dh_collars';
COMMENT ON COLUMN dh_thinsections.depto                         IS 'Sample taken for thin section: bottom depth';
COMMENT ON COLUMN dh_thinsections.core_quarter                  IS 'Optional code to identify which core quarter was taken to make thin section; useful for oriented core';
COMMENT ON COLUMN dh_thinsections.questions                     IS 'Interrogations concerning sample; desired diagnose';
COMMENT ON COLUMN dh_thinsections.name                          IS 'Result of diagnose: rock name';
COMMENT ON COLUMN dh_thinsections.texture                       IS 'Result of diagnose: texture';
COMMENT ON COLUMN dh_thinsections.mineralogy                    IS 'Result of diagnose: mineralogy';
COMMENT ON COLUMN dh_thinsections.metamorphism_deformations     IS 'Result of diagnose: metamorphism and/or deformations';
COMMENT ON COLUMN dh_thinsections.mineralisations               IS 'Result of diagnose: mineralisations';
COMMENT ON COLUMN dh_thinsections.origin                        IS 'Result of diagnose: origin: in case of highly transformed rock, protore';
COMMENT ON COLUMN dh_thinsections.datasource                    IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN dh_thinsections.numauto                       IS 'Automatic integer primary key';
COMMENT ON COLUMN dh_thinsections.creation_ts                   IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_thinsections.username                      IS 'User (role) which created data record';

--}}}
-- x dh_sampling_bottle_roll {{{ --TODO rename table to something like mineralurgical tests, something less Au-oriented

CREATE TABLE dh_sampling_bottle_roll (
    opid           integer,
    id             text,
    depfrom        numeric(10,2),
    depto          numeric(10,2),
    sample_id      text,
    au_total       numeric(10,2),
    au_24h         numeric(10,2),
    au_48h         numeric(10,2),
    au_72h         numeric(10,2),
    au_residu      numeric(10,2),
    rec_24h_pc     numeric(10,2),
    rec_48h_pc     numeric(10,2),
    rec_72h_pc     numeric(10,2),
    datasource     integer,
    numauto        bigserial PRIMARY KEY,
    creation_ts    timestamptz DEFAULT now() NOT NULL,
    username       text DEFAULT current_user,
    FOREIGN KEY (opid, id)
        REFERENCES public.dh_collars (opid, id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED
);
COMMENT ON TABLE dh_sampling_bottle_roll                        IS 'Mineralurgical samples, bottle-roll tests results';
COMMENT ON COLUMN dh_sampling_bottle_roll.opid                  IS 'Operation identifier';
COMMENT ON COLUMN dh_sampling_bottle_roll.id                    IS 'Identifier, refers to dh_collars';
COMMENT ON COLUMN dh_sampling_bottle_roll.depfrom               IS 'Sample beginning depth';
COMMENT ON COLUMN dh_sampling_bottle_roll.depto                 IS 'Sample ending depth';
COMMENT ON COLUMN dh_sampling_bottle_roll.sample_id             IS 'Sample identifier: refers to assay results and quality check tables';
COMMENT ON COLUMN dh_sampling_bottle_roll.au_total              IS 'Total gold recovered';
COMMENT ON COLUMN dh_sampling_bottle_roll.au_24h                IS 'Gold recovered after 24 hours';
COMMENT ON COLUMN dh_sampling_bottle_roll.au_48h                IS 'Gold recovered after 48 hours';
COMMENT ON COLUMN dh_sampling_bottle_roll.au_72h                IS 'Gold recovered after 72 hours';
COMMENT ON COLUMN dh_sampling_bottle_roll.au_residu             IS 'Residual gold';
COMMENT ON COLUMN dh_sampling_bottle_roll.rec_24h_pc            IS 'Recovery after 24 hours, percent';
COMMENT ON COLUMN dh_sampling_bottle_roll.rec_48h_pc            IS 'Recovery after 48 hours, percent';
COMMENT ON COLUMN dh_sampling_bottle_roll.rec_72h_pc            IS 'Recovery after 72 hours, percent';
COMMENT ON COLUMN dh_sampling_bottle_roll.datasource            IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN dh_sampling_bottle_roll.numauto               IS 'Automatic integer primary key';
COMMENT ON COLUMN dh_sampling_bottle_roll.creation_ts           IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN dh_sampling_bottle_roll.username              IS 'User (role) which created data record';

--}}}
--}}}
--lots analytiques
-- x analytical data: laboratory analyses: {{{
-- x lab_ana_batches_expedition:{{{

SET search_path = public, pg_catalog;
CREATE TABLE lab_ana_batches_expedition (
    opid                integer
        REFERENCES public.operations (opid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED,
    batch_id            integer,
    labname             text,
    expedition_id       text,
    order_id            text,
    description         text,
    preparation         text,
    process_labo        text,
    scheme              text,
    shipment_date       date,
    sent_to_lab         boolean,
    reception_date      date,
    results_received    boolean,
    lab_batches         text,
    comments            text,
    samples_amount      integer,
    sample_id_first     text,
    sample_id_last      text,
    datasource          integer,
    numauto             bigserial PRIMARY KEY,
    creation_ts         timestamptz DEFAULT now() NOT NULL,
    username            text DEFAULT current_user
--     FOREIGN KEY (opid, xx) --TODO remettre ça avec les bons champs, les bonnes connexions
--         REFERENCES public.xxxxxxxxxx (opid, xx)
--         ON UPDATE CASCADE
--         ON DELETE CASCADE
--         DEFERRABLE INITIALLY DEFERRED
);
COMMENT ON TABLE lab_ana_batches_expedition                     IS 'Batches of samples sent for analysis';
COMMENT ON COLUMN lab_ana_batches_expedition.opid               IS 'Operation identifier';
COMMENT ON COLUMN lab_ana_batches_expedition.batch_id           IS 'Batch identifier; recommended is 7-digit number, year and sequential number on 3 digits';
COMMENT ON COLUMN lab_ana_batches_expedition.labname            IS 'Destination assay laboratory name';
COMMENT ON COLUMN lab_ana_batches_expedition.expedition_id      IS 'Identifier of expedition (this is usually useless, if batches correspond to expeditions)';
COMMENT ON COLUMN lab_ana_batches_expedition.order_id           IS 'Order identifier (DA number)';
COMMENT ON COLUMN lab_ana_batches_expedition.description        IS 'Quick description of samples: rocks, soils, core, chips, rocktypes if relevant, etc.';
COMMENT ON COLUMN lab_ana_batches_expedition.preparation        IS 'Preparation of samples prior to expedition to lab (crushing, grinding, splitting, etc.)';
COMMENT ON COLUMN lab_ana_batches_expedition.process_labo       IS 'Required preparation of samples in laboratory';
COMMENT ON COLUMN lab_ana_batches_expedition.scheme             IS 'Required assay scheme';
COMMENT ON COLUMN lab_ana_batches_expedition.shipment_date      IS 'Date of batch expedition to laboratory';
COMMENT ON COLUMN lab_ana_batches_expedition.sent_to_lab        IS 'Boolean: batch sent to laboratory or not';
COMMENT ON COLUMN lab_ana_batches_expedition.reception_date     IS 'Date of batch received';
COMMENT ON COLUMN lab_ana_batches_expedition.results_received   IS 'Boolean: results received for this batch (useful if laboratory returns results according to expedition batches (recommended); irrelevant otherwise)';
COMMENT ON COLUMN lab_ana_batches_expedition.lab_batches        IS 'List of laboratory batches, if any; useless if laboratory batches correspond to expedition batches';
COMMENT ON COLUMN lab_ana_batches_expedition.comments           IS 'Specific comments, reason for assay (control re-assay, re-sampling, routine, etc.)';
COMMENT ON COLUMN lab_ana_batches_expedition.samples_amount     IS 'Number of samples';
COMMENT ON COLUMN lab_ana_batches_expedition.sample_id_first    IS 'First sample identifier; only relevant if samples in sequence';
COMMENT ON COLUMN lab_ana_batches_expedition.sample_id_last     IS 'Last sample identifier; only relevant if samples in sequence';
COMMENT ON COLUMN lab_ana_batches_expedition.datasource         IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN lab_ana_batches_expedition.numauto            IS 'Automatic integer primary key';
COMMENT ON COLUMN lab_ana_batches_expedition.creation_ts        IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN lab_ana_batches_expedition.username           IS 'User (role) which created data record';

--}}}
-- x lab_ana_batches_reception:{{{

SET search_path = public, pg_catalog;
CREATE TABLE lab_ana_batches_reception (
    opid                     integer
        REFERENCES public.operations (opid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED,
    jobno                    text,
    generic_txt              text,
    labname                  text,
    client                   text,
    validated                date,
    number_of_samples        integer,
    project                  text,
    shipment_id              text,
    p_o_number               text,
    received                 date,
    certificate_comments     text,
    info_suppl_json          text,
    datasource               integer,
    numauto                  bigserial PRIMARY KEY,
    creation_ts              timestamptz DEFAULT now() NOT NULL,
    username                 text DEFAULT current_user
--     FOREIGN KEY (opid, xx) --TODO remettre ça avec les bons champs, les bonnes connexions
--         REFERENCES public.xxxxxxxxxx (opid, xx)
--         ON UPDATE CASCADE
--         ON DELETE CASCADE
--         DEFERRABLE INITIALLY DEFERRED
);
COMMENT ON TABLE lab_ana_batches_reception                           IS 'Batches of samples results received from laboratory';
COMMENT ON COLUMN lab_ana_batches_reception.opid                     IS 'Operation identifier';
COMMENT ON COLUMN lab_ana_batches_reception.jobno                    IS 'As in files received from laboratory: job number';
COMMENT ON COLUMN lab_ana_batches_reception.generic_txt              IS 'Generic text, containing information from original results file as is, unformatted';
COMMENT ON COLUMN lab_ana_batches_reception.labname                  IS 'As in files received from laboratory: full laboratory name';
COMMENT ON COLUMN lab_ana_batches_reception.client                   IS 'As in files received from laboratory: client name';
COMMENT ON COLUMN lab_ana_batches_reception.validated                IS 'As in files received from laboratory: validation date';
COMMENT ON COLUMN lab_ana_batches_reception.number_of_samples        IS 'As in files received from laboratory: number of samples';
COMMENT ON COLUMN lab_ana_batches_reception.project                  IS 'As in files received from laboratory: project name';
COMMENT ON COLUMN lab_ana_batches_reception.shipment_id              IS 'As in files received from laboratory: shipment id';
COMMENT ON COLUMN lab_ana_batches_reception.p_o_number               IS 'As in files received from laboratory: P.O. number';
COMMENT ON COLUMN lab_ana_batches_reception.received                 IS 'As in files received from laboratory: reception date';
COMMENT ON COLUMN lab_ana_batches_reception.certificate_comments     IS 'As in files received from laboratory: certificate comments';
COMMENT ON COLUMN lab_ana_batches_reception.info_suppl_json          IS 'Supplementary information, serialised as a JSON (validated by json_xs)';
COMMENT ON COLUMN lab_ana_batches_reception.datasource               IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN lab_ana_batches_reception.numauto                  IS 'Automatic integer primary key';
COMMENT ON COLUMN lab_ana_batches_reception.creation_ts              IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN lab_ana_batches_reception.username                 IS 'User (role) which created data record';

--}}}
-- x lab_ana_columns_definition{{{

CREATE TABLE lab_ana_columns_definition (
    opid           integer
        REFERENCES public.operations (opid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED,
    analyte        text,
    unit           text,
    scheme         text,
    colid          text,
    numauto        bigserial PRIMARY KEY,
    creation_ts    timestamptz DEFAULT now() NOT NULL,
    username       text DEFAULT current_user
--     FOREIGN KEY (opid, xx) --TODO remettre ça avec les bons champs, les bonnes connexions
--         REFERENCES public.xxxxxxxxxx (opid, xx)
--         ON UPDATE CASCADE
--         ON DELETE CASCADE
--         DEFERRABLE INITIALLY DEFERRED
);
COMMENT ON TABLE lab_ana_columns_definition                     IS 'Definition of columns; obsolete';
COMMENT ON COLUMN lab_ana_columns_definition.opid               IS 'Operation identifier';
COMMENT ON COLUMN lab_ana_columns_definition.analyte            IS 'Analyte';
COMMENT ON COLUMN lab_ana_columns_definition.unit               IS 'Unit (PPM, PPB, etc.)';
COMMENT ON COLUMN lab_ana_columns_definition.colid              IS 'Column identifier, used for groupings in cross-tab queries';
COMMENT ON COLUMN lab_ana_columns_definition.numauto            IS 'Automatic integer primary key';
COMMENT ON COLUMN lab_ana_columns_definition.creation_ts        IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN lab_ana_columns_definition.username           IS 'User (role) which created data record';

--}}}
-- x ana_det_limit{{{

CREATE TABLE ana_det_limit (
    opid           integer
        REFERENCES public.operations (opid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED,
    batch_id       text,
    elem_code      text,
    elem_name      text,
    unit           text,
    detlim_inf     integer,
    detlim_sup     integer
-- TODO add fields numauto, creation_ts, username
--     FOREIGN KEY (opid, xx) --TODO remettre ça avec les bons champs, les bonnes connexions
--         REFERENCES public.xxxxxxxxxx (opid, xx)
--         ON UPDATE CASCADE
--         ON DELETE CASCADE
--         DEFERRABLE INITIALLY DEFERRED
);
COMMENT ON TABLE ana_det_limit                        IS 'Analyses detections limits';
--TODO complete field comments

--}}}
-- x lab_ana_results {{{

-- Anaytical results table structure, based on discussion
-- with Andre_Pranata from Intertek andre.pranata@intertek.com
--DROP TABLE IF EXISTS lab_ana_results ;

CREATE TABLE lab_ana_results (
    opid           integer
        REFERENCES public.operations (opid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED,
    labname        text,
    jobno          text,
    orderno        text,
    batch_id       integer,
    sample_id      text,
    sample_id_lab  text,
    sampletype     text,
    scheme         text,
    analyte        text,
    value          text,
    value_num      numeric,
    unit           text,
    detlim         numeric,
    uplim          numeric,
    valid          boolean DEFAULT true,
    datasource     integer,
    numauto        bigserial PRIMARY KEY,
    creation_ts    timestamptz DEFAULT now() NOT NULL,
    username       text DEFAULT current_user
--     FOREIGN KEY (opid, id) --TODO remettre ça avec les bons champs, les bonnes connexions
--         REFERENCES public.dh_collars (opid, id)
--         ON UPDATE CASCADE
--         ON DELETE CASCADE
--         DEFERRABLE INITIALLY DEFERRED
);
COMMENT ON TABLE lab_ana_results                      IS 'Laboratory results table, after laboratory instructions, related to LIMS system';
COMMENT ON COLUMN lab_ana_results.opid                IS 'Operation identifier';
COMMENT ON COLUMN lab_ana_results.labname             IS 'Analytical laboratory';
COMMENT ON COLUMN lab_ana_results.jobno               IS 'jcsa.pro_job,           --> Intertek JobNo (VarChar(20))';
COMMENT ON COLUMN lab_ana_results.orderno             IS 'pj.orderno,              --> Client Order No (VarChar(40))';
COMMENT ON COLUMN lab_ana_results.sample_id           IS 'Sample Identifier';
COMMENT ON COLUMN lab_ana_results.scheme              IS 'pjcsa.sch_code,          --> Scheme Code (Intertek Internal Code - which probably reported to Client as well) (VarChar(20))';
COMMENT ON COLUMN lab_ana_results.analyte             IS 'pjcsa.analytecode,       --> Analyte Code (Intertek Internal Code - which probably reported to Client as well) (VarChar(20))';
COMMENT ON COLUMN lab_ana_results.value               IS 'pjcsa.formattedvalue     --> Reported Value (VarChar(20))';
COMMENT ON COLUMN lab_ana_results.value_num           IS 'Reported value, converted to numeric. IS becomes -999, LNR -9999, < -, > nothing';
COMMENT ON COLUMN lab_ana_results.batch_id            IS 'Batch identifier';
COMMENT ON COLUMN lab_ana_results.sampletype          IS 'Sample type: DUP: duplicate, STD: standard, REP: repeat, etc.';
COMMENT ON COLUMN lab_ana_results.unit                IS 'Unit: PPM, PPB, KG, G, %, etc.';
COMMENT ON COLUMN lab_ana_results.sample_id_lab       IS 'pjc.sampleident,         --> Client SampleID (VarChar(40)) => sometimes different from REAL sample_id';
COMMENT ON COLUMN lab_ana_results.valid               IS 'Analysis is considered as valid or ignored (if QAQC failed, for instance)';
COMMENT ON COLUMN lab_ana_results.detlim              IS 'Lower detection limit';
COMMENT ON COLUMN lab_ana_results.uplim               IS 'Upper limit';
COMMENT ON COLUMN lab_ana_results.datasource          IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN lab_ana_results.numauto             IS 'Automatic integer primary key';
COMMENT ON COLUMN lab_ana_results.creation_ts         IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN lab_ana_results.username            IS 'User (role) which created data record';
-- function lab_ana_results_sample_id_default_value_num() {{{

    -- Après avoir tourné et retourné le problème: - LD
    -- Et pour les codes du labo:
    --  IS: Insufficient sample  -999
    --  LNR: Listed but Not Recovered: -9999
    --  > LD: @#ah: TODO à implémenter
    -- Par exemple.  Un code numerique qui evite d'obliger de stocker les
    -- commentaires tout en préservant l'information, et permettant un filtrage
    -- efficace.

--#lab_ana_results_sample_id_default_value_num:{{{ -- VERSION À 9 REPLACE

CREATE FUNCTION public.lab_ana_results_sample_id_default_value_num() RETURNS trigger
LANGUAGE 'plpgsql'
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
REPLACE(
REPLACE(value,     'IS',           '-999'),
                  'NSS',           '-999'),
                  'LNR',          '-9999'),
                   'NA',            '-99'),
                    '<',              '-'),
                    '>',               ''),
                 'Not Received',  '-9999'),
                 'Bag Empty',     '-9999'),
                 'N/L',           '-9999')::numeric WHERE value <> 'NULL' AND value IS NOT NULL AND value_num IS NULL;
RETURN NULL;
END;
$$
;

--#}}}

-- ANCIENNE VERSION, À 8 REPLACE:{{{
--CREATE FUNCTION public.lab_ana_results_sample_id_default_value_num() RETURNS trigger
--    LANGUAGE plpgsql
--    AS $$
--BEGIN
--UPDATE public.lab_ana_results SET sample_id = lab_sampleid WHERE (sample_id IS NULL OR sample_id = '') AND (lab_sampleid IS NOT NULL OR lab_sampleid <> '');
--UPDATE public.lab_ana_results SET sample_id_lab = sample_id;
--UPDATE public.lab_ana_results SET sample_id = REPLACE(sample_id, 'STD:', '') WHERE sample_id ILIKE 'STD%';
--
--UPDATE public.lab_ana_results SET value_num =
--REPLACE(
--REPLACE(
--REPLACE(
--REPLACE(
--REPLACE(
--REPLACE(
--REPLACE(
--REPLACE(value,     'IS',           '-999'),
--                  'NSS',           '-999'),
--                  'LNR',          '-9999'),
--                   'NA',            '-99'),
--                    '<',              '-'),
--                    '>',               ''),
--                 'Not Received',  '-9999'),
--                 'Bag Empty',     '-9999')::numeric WHERE value <> 'NULL' AND value IS NOT NULL AND value_num IS NULL;
--RETURN NULL;
--END;
--$$;
--}}}
--}}}

-- ANCIENNE VERSION: {{{
--
---- structure de table de résultats analytiques, basé sur discussion
---- avec Andre_Pranata d'Intertek andre.pranata@intertek.com
--DROP TABLE IF EXISTS lab_ana_results ;
--
--CREATE TABLE lab_ana_results (
-- sample_id text,
-- batch_id text,
-- labname text,
-- lab_pjcsa_pro_job text,
---- lab_pj_cli_code text,
-- lab_pj_orderno text,
-- lab_pjc_sampleident text,
-- lab_pjcsa_sch_code text,
-- lab_pjcsa_analytecode text,
-- lab_pjcsa_formattedvalue text,
-- --batch_no integer,
-- value_num numeric,
-- creation_ts timestamp DEFAULT current_timestamp
--);
--COMMENT ON TABLE lab_ana_results                              IS 'Laboratory results table, after laboratory instructions, related to LIMS system';
--COMMENT ON COLUMN lab_ana_results.labname                     IS 'Analytical laboratory';
--COMMENT ON COLUMN lab_ana_results.lab_pjcsa_pro_job           IS 'jcsa.pro_job,           --> Intertek JobNo (VarChar(20))';
--COMMENT ON COLUMN lab_ana_results.lab_pj_cli_code             IS 'pj.cli_code,             --> Client Name (VarChar(40))';
--COMMENT ON COLUMN lab_ana_results.lab_pj_orderno              IS 'pj.orderno,              --> Client Order No (VarChar(40))';
--COMMENT ON COLUMN lab_ana_results.lab_pjc_sampleident         IS 'pjc.sampleident,         --> Client SampleID (VarChar(40))';
--COMMENT ON COLUMN lab_ana_results.lab_pjcsa_sch_code          IS 'pjcsa.sch_code,          --> Scheme Code (Intertek Internal Code - which probably reported to Client as well) (VarChar(20))';
--COMMENT ON COLUMN lab_ana_results.lab_pjcsa_analytecode       IS 'pjcsa.analytecode,       --> Analyte Code (Intertek Internal Code - which probably reported to Client as well) (VarChar(20))';
--COMMENT ON COLUMN lab_ana_results.lab_pjcsa_formattedvalue    IS 'pjcsa.formattedvalue     --> Reported Value (VarChar(20))';
--COMMENT ON COLUMN lab_ana_results.batch_id                    IS 'Batch number';
--COMMENT ON COLUMN lab_ana_results.value_num                   IS 'Reported value, converted to numeric. IS becomes -999, LNR -9999, < -, > nothing';
--COMMENT ON COLUMN lab_ana_results.creation_ts                 IS 'Current date and time stamp when data is loaded in table';
--
--CREATE OR REPLACE FUNCTION lab_ana_results_sample_id_default()
-- RETURNS trigger AS
--$BODY$
--BEGIN
--UPDATE lab_ana_results SET sample_id = lab_pjc_sampleident;
--RETURN NULL;
--END;
--$BODY$
--LANGUAGE 'plpgsql' VOLATILE
--;
--
--CREATE TRIGGER lab_ana_results_insert AFTER INSERT ON lab_ana_results FOR EACH STATEMENT EXECUTE PROCEDURE lab_ana_results_sample_id_default();
--
--}}}
-- }}}
-- x lab_analysis_icp:{{{ TODO: table name inconsistent with rest of lab results tables: RENAME

--
-- Name: lab_analysis_icp; Type: TABLE; Schema: pierre; Owner: pierre; Tablespace:
--
CREATE TABLE lab_analysis_icp (
    opid           integer
        REFERENCES public.operations (opid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED,
    num            integer,
    sample_id      text,
    elem_code      text,
    unit           text,
    value          numeric(20,2),
    batch_id       text
--     FOREIGN KEY (opid, id) --TODO remettre ça avec les bons champs, les bonnes connexions
--         REFERENCES public.dh_collars (opid, id)
--         ON UPDATE CASCADE
--         ON DELETE CASCADE
--         DEFERRABLE INITIALLY DEFERRED
);

--}}}
-- x lab_ana_qaqc_results:{{{

CREATE TABLE lab_ana_qaqc_results (
    opid                integer
        REFERENCES public.operations (opid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED,
    jobno               text,
    generic_txt_col1    text,
    generic_txt_col2    text,
    generic_txt_col3    text,
    generic_txt_col4    text,
    generic_txt_col5    text,
    datasource          integer,
    numauto             bigserial PRIMARY KEY,
    creation_ts         timestamptz DEFAULT now() NOT NULL,
    username            text DEFAULT current_user
--     FOREIGN KEY (opid, id) --TODO remettre ça avec les bons champs, les bonnes connexions
--         REFERENCES public.dh_collars (opid, id)
--         ON UPDATE CASCADE
--         ON DELETE CASCADE
--         DEFERRABLE INITIALLY DEFERRED
);
COMMENT ON TABLE lab_ana_qaqc_results                           IS 'Quality control assay results, internal to analytical laboratory';
COMMENT ON COLUMN lab_ana_qaqc_results.opid                     IS 'Operation identifier';
COMMENT ON COLUMN lab_ana_qaqc_results.jobno                    IS 'Job number';
COMMENT ON COLUMN lab_ana_qaqc_results.generic_txt_col1         IS 'Generic text field, receiving any text from original file, as is';
COMMENT ON COLUMN lab_ana_qaqc_results.generic_txt_col2         IS 'Generic text field, receiving any text from original file, as is';
COMMENT ON COLUMN lab_ana_qaqc_results.generic_txt_col3         IS 'Generic text field, receiving any text from original file, as is';
COMMENT ON COLUMN lab_ana_qaqc_results.generic_txt_col4         IS 'Generic text field, receiving any text from original file, as is';
COMMENT ON COLUMN lab_ana_qaqc_results.generic_txt_col5         IS 'Generic text field, receiving any text from original file, as is';
COMMENT ON COLUMN lab_ana_qaqc_results.datasource               IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN lab_ana_qaqc_results.numauto                  IS 'Automatic integer primary key';
COMMENT ON COLUMN lab_ana_qaqc_results.creation_ts              IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN lab_ana_qaqc_results.username                 IS 'User (role) which created data record';

--}}}
--}}}
--échantillons de contrôle analytique
-- x assays quality control, quality check:{{{

-- x qc_sampling:{{{
-- Name: qc_sampling; Type: TABLE; Schema: public; Owner: data_admin; Tablespace:
--
CREATE TABLE qc_sampling (
    opid                     integer
        REFERENCES public.operations (opid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED,
    sample_id                text,
    qc_type                  text,
    comments                 text,
    batch_id                 integer,
    refers_to                text,
    weight_kg                numeric(6,2),
    datasource               integer,
    numauto                  bigserial PRIMARY KEY,
    creation_ts              timestamptz DEFAULT now() NOT NULL,
    username                 text DEFAULT current_user
--     FOREIGN KEY (opid, id) --TODO remettre ça avec les bons champs, les bonnes connexions
--         REFERENCES public.dh_collars (opid, id)
--         ON UPDATE CASCADE
--         ON DELETE CASCADE
--         DEFERRABLE INITIALLY DEFERRED
);
COMMENT ON TABLE qc_sampling                          IS 'Quality control samples: duplicates, blanks, standards';
COMMENT ON COLUMN qc_sampling.opid                    IS 'Operation identifier';
COMMENT ON COLUMN qc_sampling.datasource              IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN qc_sampling.numauto                 IS 'Automatic integer primary key';
COMMENT ON COLUMN qc_sampling.creation_ts             IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN qc_sampling.username                IS 'User (role) which created data record';

--}}}
-- x qc_standards{{{

--
-- Name: qc_standards; Type: TABLE; Schema: public; Owner: data_admin; Tablespace:
--
CREATE TABLE qc_standards (
    opid                       integer
        REFERENCES public.operations (opid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED,
    qc_id                      text NOT NULL,
    labo                       text,
    matrix                     text,
    presentation               text,
    au_ppm                     numeric,
    cu_ppm                     numeric,
    zn_ppm                     numeric,
    pb_ppm                     numeric,
    ag_ppm                     numeric,
    ni_ppm                     numeric,
    au_ppm_95pc_conf_interval  numeric,
    cu_ppm_95pc_conf_interval  numeric,
    zn_ppm_95pc_conf_interval  numeric,
    pb_ppm_95pc_conf_interval  numeric,
    ag_ppm_95pc_conf_interval  numeric,
    ni_ppm_95pc_conf_interval  numeric,
    datasource                 integer,
    numauto                    bigserial PRIMARY KEY,
    creation_ts                timestamptz DEFAULT now() NOT NULL,
    username                   text DEFAULT current_user
--     FOREIGN KEY (opid, id) --TODO remettre ça avec les bons champs, les bonnes connexions
--         REFERENCES public.dh_collars (opid, id)
--         ON UPDATE CASCADE
--         ON DELETE CASCADE
--         DEFERRABLE INITIALLY DEFERRED
);
COMMENT ON TABLE qc_standards                         IS 'Quality Control standard samples, most of them are CRM (Certified Reference Materials)';
COMMENT ON COLUMN qc_standards.opid                   IS 'Operation identifier';
COMMENT ON COLUMN qc_standards.qc_id                  IS 'sample identification';
COMMENT ON COLUMN qc_standards.labo                   IS 'sample laboratory';
COMMENT ON COLUMN qc_standards.matrix                 IS 'sample composition';
COMMENT ON COLUMN qc_standards.presentation           IS 'sample presentation';
COMMENT ON COLUMN qc_standards.au_ppm                 IS 'sample analysis value';
COMMENT ON COLUMN qc_standards.cu_ppm                 IS 'sample analysis value';
COMMENT ON COLUMN qc_standards.zn_ppm                 IS 'sample analysis value';
COMMENT ON COLUMN qc_standards.pb_ppm                 IS 'sample analysis value';
COMMENT ON COLUMN qc_standards.ag_ppm                 IS 'sample analysis value';
COMMENT ON COLUMN qc_standards.ni_ppm                 IS 'sample analysis value';
COMMENT ON COLUMN qc_standards.datasource             IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN qc_standards.numauto                IS 'Automatic integer primary key';
COMMENT ON COLUMN qc_standards.creation_ts            IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN qc_standards.username               IS 'User (role) which created data record';

--}}}

--}}}
-- x occurrences, ancient workings, mines:{{{
-- x ancient_workings:{{{

CREATE TABLE ancient_workings (
    opid                integer
        REFERENCES operations (opid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED,
    gid                 integer NOT NULL,
    description         text,
    the_geom            geometry,
    datasource          integer,
    numauto             bigserial PRIMARY KEY,
    CONSTRAINT enforce_geotype_the_geom CHECK ((geometrytype(the_geom) = 'POINT') OR (the_geom IS NULL))
--     FOREIGN KEY (opid, id) --TODO remettre ça avec les bons champs, les bonnes connexions
--         REFERENCES public.dh_collars (opid, id)
--         ON UPDATE CASCADE
--         ON DELETE CASCADE
--         DEFERRABLE INITIALLY DEFERRED
);
COMMENT ON TABLE ancient_workings                     IS 'Ancient workings, either historic or recent';
COMMENT ON COLUMN ancient_workings.gid                IS 'Identifier';
COMMENT ON COLUMN ancient_workings.description        IS 'Full description';
COMMENT ON COLUMN ancient_workings.the_geom           IS 'Geometry, usded in GIS';
COMMENT ON COLUMN ancient_workings.opid               IS 'Operation identifier';
COMMENT ON COLUMN ancient_workings.datasource         IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN ancient_workings.numauto            IS 'Automatic integer';

--}}}
-- x occurrences:{{{

CREATE TABLE occurrences (
    opid                integer
        REFERENCES operations (opid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED,
    name                text,
    description         text,
    code                text,
    zone                text,
    status              text,
    w_done              text,
    w_todo              text,
    comments            text,
    geom                geometry,
    datasource          integer,
    numauto             bigserial PRIMARY KEY,
    creation_ts         timestamptz DEFAULT now() NOT NULL,
    username            text DEFAULT current_user,
    --CONSTRAINT chk_status CHECK (status = ANY (ARRAY[('OCCUR'::varchar)::text, ('OREB'::varchar)::text, ('MINE'::varchar)::text, ('MINED'::varchar)::text, ('MCO'::varchar)::text, ('DISTRICT'::varchar)::text])),
    CONSTRAINT chk_status CHECK (status IN ('OCCUR', 'OREB', 'MINE', 'MINED', 'MCO', 'DISTRICT')),  -- Another solution would be to make entries in lex_codes lookup table.  Probably better, more flexible, i18nable; TODO later.
    CONSTRAINT enforce_geotype_geom CHECK (geometrytype(geom) = 'POINT' OR geom IS NULL)            -- Maybe authorize other geometrytypes, like a polygon for a district, another one for an oil field, etc.
);
COMMENT ON TABLE occurrences                          IS 'Occurrences table: targets, showings, deposits, mines.  Compiled from various tables, and updated.';
COMMENT ON COLUMN occurrences.opid                    IS 'Operation identifier';
COMMENT ON COLUMN occurrences.code                    IS 'Occurrence abbreviated code'; --TODO cleaning: sometimes misused, commodities were put, instead of occurrence code.
COMMENT ON COLUMN occurrences.zone                    IS 'Geographic zone code';   -- quite useless; TODO to be discarded, was used only once
COMMENT ON COLUMN occurrences.name                    IS 'Occurence name';
COMMENT ON COLUMN occurrences.status                  IS 'Status: OCCUR = occurence ; OREB = orebody ; MINE = active mine ; MINED = exploited, depleted mine';
COMMENT ON COLUMN occurrences.description             IS 'Occurence description: geological context, significant figures at current stage of exploration or exploitation';
COMMENT ON COLUMN occurrences.w_done                  IS 'Exploration work done, codified field: PROSPection (rock sampling on surface), SOIL geochemistry, MAPping, DECAPage, TRenches, Drill Holes';
COMMENT ON COLUMN occurrences.w_todo                  IS 'Exploration work to be done, codified field: PROSPection (rock sampling on surface), SOIL geochemistry, MAPping, DECAPage, TRenches, Drill Holes';
COMMENT ON COLUMN occurrences.datasource              IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN occurrences.numauto                 IS 'Automatic integer primary key';
COMMENT ON COLUMN occurrences.creation_ts             IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN occurrences.username                IS 'User (role) which created data record';

--}}}

--}}}
-- x licences, tenements: {{{

-- x licences:{{{ TODO "licence" or "license"?...
-- TODO @#redo with polygons instead of quadrangles; make a field containing EWKT

--An old version of the table definition, certainly: TODO to be cleaned, ultimately.{{{
--DROP TABLE IF EXISTS licences CASCADE;
--CREATE TABLE licences (
--    opid integer,
--    id serial NOT NULL,
--    licence_name text,
--    operator text,
--    year integer,
--    lat_min numeric(10,5) NOT NULL,
--    lon_min numeric(10,5) NOT NULL,
--    lat_max numeric(10,5) NOT NULL,
--    lon_max numeric(10,5) NOT NULL,
--    comments text,
--    CONSTRAINT licence_id PRIMARY KEY (id)
--);
--COMMENT ON TABLE licences                           IS 'Licences, tenements';
--COMMENT ON COLUMN licences.opid                     IS 'Operation identifier, see table operations';
--COMMENT ON COLUMN licences.id                       IS 'Licence identifier, automatic sequence';
--COMMENT ON COLUMN licences.licence_name             IS 'Name of licence';
--COMMENT ON COLUMN licences.operator                 IS 'Owner of licence';
--COMMENT ON COLUMN licences.year                     IS 'Year when licence was valid';
--COMMENT ON COLUMN licences.lat_min                  IS 'South latitude, decimal degrees, WGS84';
--COMMENT ON COLUMN licences.lon_min                  IS 'West longitude, decimal degrees, WGS84';
--COMMENT ON COLUMN licences.lat_max                  IS 'North latitude, decimal degrees, WGS84';
--COMMENT ON COLUMN licences.lon_max                  IS 'East latitude, decimal degrees, WGS84';
--}}}

CREATE TABLE licences (
    opid                integer
        REFERENCES public.operations (opid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED,
    licence_name        text,
    operator            text,
    year                integer,
    lat_min             numeric(10,5) NOT NULL,
    lon_min             numeric(10,5) NOT NULL,
    lat_max             numeric(10,5) NOT NULL,
    lon_max             numeric(10,5) NOT NULL,
    comments            text,
    geometry_literal_description_plain_txt text,
    geometry_wkt        text,
    datasource          integer,
    numauto             bigserial PRIMARY KEY,
    creation_ts    timestamptz DEFAULT now() NOT NULL,
    username            text DEFAULT current_user
);
COMMENT ON TABLE licences                             IS 'Licences, tenements';
COMMENT ON COLUMN licences.opid                       IS 'Operation identifier, see table operations';
COMMENT ON COLUMN licences.licence_name               IS 'Licence official name, as reported on legal documents';
COMMENT ON COLUMN licences.operator                   IS 'Operator, owner of licence';
COMMENT ON COLUMN licences.year                       IS 'Year when information is valid';
--COMMENT ON COLUMN licences.lat_min                  IS 'Minimum latitude';
--COMMENT ON COLUMN licences.lon_min                  IS 'Minimum longitude';
--COMMENT ON COLUMN licences.lat_max                  IS 'Maximum latitude';
--COMMENT ON COLUMN licences.lon_max                  IS 'Maximum longitude';
COMMENT ON COLUMN licences.lat_min                    IS 'South latitude, decimal degrees, WGS84';
COMMENT ON COLUMN licences.lon_min                    IS 'West longitude, decimal degrees, WGS84';
COMMENT ON COLUMN licences.lat_max                    IS 'North latitude, decimal degrees, WGS84';
COMMENT ON COLUMN licences.lon_max                    IS 'East latitude, decimal degrees, WGS84';
COMMENT ON COLUMN licences.comments                   IS 'Comments';
COMMENT ON COLUMN licences.datasource                 IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN licences.numauto                    IS 'Automatic integer';
COMMENT ON COLUMN licences.creation_ts                IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN licences.username                   IS 'User (role) which created data record';

--}}}


--}}}
-- x mining, grade control:{{{

-- x grade_ctrl:{{{

CREATE TABLE grade_ctrl (
    opid           integer
        REFERENCES public.operations (opid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED,
    id             text,
    num            text,
    x              numeric(10,2),
    y              numeric(10,2),
    z              numeric(10,2),
    prof           numeric(10,2),
    aucy           numeric(10,2),
    aucy2          numeric(10,2),
    autot          numeric(10,2),
    litho          text,
    old_id         text,
    datasource     integer,
    numauto        bigserial PRIMARY KEY,
    creation_ts    timestamptz DEFAULT now() NOT NULL,
    username       text DEFAULT current_user
);
COMMENT ON TABLE grade_ctrl                           IS 'Grade-control samples during mining exploitation';
COMMENT ON COLUMN grade_ctrl.opid                     IS 'Operation identifier';
COMMENT ON COLUMN grade_ctrl.id                       IS 'Quarry and block identification in 4 characters';
COMMENT ON COLUMN grade_ctrl.num                      IS 'sample number';
COMMENT ON COLUMN grade_ctrl.x                        IS 'X drill hole collar coordinate, projected in UTM (m)';
COMMENT ON COLUMN grade_ctrl.y                        IS 'Y drill hole collar coordinate, projected in UTM (m)';
COMMENT ON COLUMN grade_ctrl.z                        IS 'Z drill hole collar coordinate, projected in UTM (m)';
COMMENT ON COLUMN grade_ctrl.prof                     IS 'End of sample depth';
COMMENT ON COLUMN grade_ctrl.aucy                     IS 'Sample cyanidable gold grade (g/t)';
COMMENT ON COLUMN grade_ctrl.autot                    IS 'Total gold grade (g/t)';
COMMENT ON COLUMN grade_ctrl.litho                    IS 'Sample lithology in GDM or Sermine code';
COMMENT ON COLUMN grade_ctrl.old_id                   IS 'Quarry and block old identification ';
COMMENT ON COLUMN grade_ctrl.datasource               IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN grade_ctrl.numauto                  IS 'Automatic integer primary key';
COMMENT ON COLUMN grade_ctrl.creation_ts              IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN grade_ctrl.username                 IS 'User (role) which created data record';

--}}}

--}}}
-- x lookup tables, aka lexicons, aka code translation tables:{{{

-- x codes: {{{

CREATE TABLE lex_codes (
    opid           integer
        REFERENCES public.operations (opid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED,
    tablename      text,
    field          text,
    code           text,
    description    text,
    comments       text,
    datasource     integer,
    numauto        bigserial PRIMARY KEY,
    creation_ts    timestamptz DEFAULT now() NOT NULL,
    username       text DEFAULT current_user
);
COMMENT ON TABLE lex_codes                            IS 'General look-up table with codes for various tables and coded fields';
COMMENT ON COLUMN lex_codes.opid                      IS 'Operation identifier';
COMMENT ON COLUMN lex_codes.datasource                IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN lex_codes.numauto                   IS 'Automatic integer primary key';
COMMENT ON COLUMN lex_codes.creation_ts               IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN lex_codes.username                  IS 'User (role) which created data record';

--}}}
-- x data sources:{{{

CREATE TABLE lex_datasource (
    opid           integer
        REFERENCES public.operations (opid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED,
    filename       text,
    comments       text,
    datasource_id  integer NOT NULL,
    numauto        bigserial PRIMARY KEY,
    creation_ts    timestamptz DEFAULT now() NOT NULL,
    username       text DEFAULT current_user
);
COMMENT ON TABLE lex_datasource                       IS 'Lexicon of data sources, keeping track of imported file, for reference';
COMMENT ON COLUMN lex_datasource.opid                 IS 'Operation identifier';
COMMENT ON COLUMN lex_datasource.filename             IS 'Data imported: file name with full path, to be kept for permanent reference';
COMMENT ON COLUMN lex_datasource.comments             IS 'Various comments';
COMMENT ON COLUMN lex_datasource.datasource_id        IS 'datasource field in various tables refer to this datasource_id field';
COMMENT ON COLUMN lex_datasource.numauto              IS 'Automatic integer primary key';
COMMENT ON COLUMN lex_datasource.creation_ts          IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN lex_datasource.username             IS 'User (role) which created data record';

--}}}
-- x standards:{{{

CREATE TABLE lex_standard (
    opid           integer
        REFERENCES public.operations (opid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED,
    std_id         text NOT NULL,
    unit           text NOT NULL,
    element        text NOT NULL,
    value          numeric NOT NULL,
    std_dev        numeric,
    interval_conf  numeric,
    std_origin     text,
    type_analyse   text NOT NULL,
    datasource     integer,
    numauto        bigserial PRIMARY KEY,
    creation_ts    timestamptz DEFAULT now() NOT NULL,
    username       text DEFAULT current_user
);
COMMENT ON TABLE lex_standard                         IS 'table contenant les valeurs des standards or et multi elements';
COMMENT ON COLUMN lex_standard.opid                   IS 'Operation identifier';
COMMENT ON COLUMN lex_standard.datasource             IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN lex_standard.numauto                IS 'Automatic integer primary key';
COMMENT ON COLUMN lex_standard.creation_ts            IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN lex_standard.username               IS 'User (role) which created data record';

--}}}
--}}}







-- e miscellaneous:{{{

-- x mag_declination:{{{ TODO to be replaced by C program translated from Fortran (or by Fortran original program, which computes mag deviation?  Or, more prudently, store data *actually used* on operations, and if undefined, fetch the results of the function => TODO to be implemented.

CREATE TABLE mag_declination (
    opid           integer
        REFERENCES public.operations (opid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED,
    mag_decl       numeric,
    date           date,
    datasource     integer,
    numauto        bigserial PRIMARY KEY,
    creation_ts    timestamptz DEFAULT now() NOT NULL,
    username       text DEFAULT current_user
);
COMMENT ON TABLE mag_declination                      IS 'Magnetic declination';
COMMENT ON COLUMN mag_declination.opid                IS 'Operation identifier';
COMMENT ON COLUMN mag_declination.datasource          IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN mag_declination.numauto             IS 'Automatic integer primary key';
COMMENT ON COLUMN mag_declination.creation_ts         IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN mag_declination.username            IS 'User (role) which created data record';

--}}}
-- x topo_points:{{{

CREATE TABLE topo_points (
    opid                integer
        REFERENCES public.operations (opid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED,
    location            text,
    id                  text,
    num                 numeric(10,0),
    x                   numeric(10,3),
    y                   numeric(10,3),
    z                   numeric(10,3),
    survey_date         date,
    topo_survey_type    text,
    coordsys            text,
    surveyor            text,
    datasource          integer,
    numauto             bigserial PRIMARY KEY,
    creation_ts         timestamptz DEFAULT now() NOT NULL,
    username            text DEFAULT current_user
);
COMMENT ON TABLE topo_points                          IS 'topographical data, points';
COMMENT ON COLUMN topo_points.opid                    IS 'Operation identifier';
COMMENT ON COLUMN topo_points.location                IS 'Topographical zone';
COMMENT ON COLUMN topo_points.num                     IS 'Topographical point number';
COMMENT ON COLUMN topo_points.id                      IS 'Full identifier for borehole or trench, including zone code with type and sequential number';
COMMENT ON COLUMN topo_points.x                       IS 'X coordinate, projected in UTM (m) or other similar CRS';
COMMENT ON COLUMN topo_points.y                       IS 'Y coordinate, projected in UTM (m) or other similar CRS';
COMMENT ON COLUMN topo_points.z                       IS 'Z coordinate, projected in UTM (m) or other similar CRS';
COMMENT ON COLUMN topo_points.datasource              IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN topo_points.numauto                 IS 'Automatic integer primary key';
COMMENT ON COLUMN topo_points.creation_ts             IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN topo_points.username                IS 'User (role) which created data record';

--}}}
-- x survey_lines:{{{

CREATE TABLE survey_lines (
    opid           integer
        REFERENCES public.operations (opid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED,
    id             text,
    x_start        numeric,
    y_start        numeric,
    x_end          numeric,
    y_end          numeric,
    length         numeric,
    srid           numeric,
    numauto        bigserial PRIMARY KEY
);
COMMENT ON TABLE survey_lines                         IS 'Survey lines, for geophysics or other types of linear surveys; defined with start and end points.';

--}}}
-- x units:{{{

CREATE TABLE units (
    unit_name text,
    unit_factor real
);
COMMENT ON TABLE units                                IS 'Units, with multiplicator factor';
COMMENT ON COLUMN units.unit_name                     IS 'Unit abbreviated name, uppercase';
COMMENT ON COLUMN units.unit_factor                   IS 'Multiplication factor';

--}}}
-- x baselines: {{{

CREATE TABLE baselines (
    opid           integer
        REFERENCES public.operations (opid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED,
    id             integer,
    location       text,
    x1             numeric(10,3),
    y1             numeric(10,3),
    z1             numeric(10,3),
    x2             numeric(10,3),
    y2             numeric(10,3),
    z2             numeric(10,3),
    datasource     integer,
    numauto        bigserial PRIMARY KEY,
    creation_ts    timestamptz DEFAULT now() NOT NULL,
    username       text DEFAULT current_user
);
COMMENT ON TABLE baselines                            IS 'Baselines, for each prospect, defined as a theoritical line between two points';
COMMENT ON COLUMN baselines.opid                      IS 'Operation identifier';
COMMENT ON COLUMN baselines.id                        IS 'Baseline identifier';
COMMENT ON COLUMN baselines.x1                        IS 'Baseline starting point x coordinate';
COMMENT ON COLUMN baselines.y1                        IS 'Baseline starting point y coordinate';
COMMENT ON COLUMN baselines.z1                        IS 'Baseline starting point z coordinate';
COMMENT ON COLUMN baselines.x2                        IS 'Baseline ending point x coordinate';
COMMENT ON COLUMN baselines.y2                        IS 'Baseline ending point y coordinate';
COMMENT ON COLUMN baselines.z2                        IS 'Baseline ending point z coordinate';
COMMENT ON COLUMN baselines.datasource                IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN baselines.numauto                   IS 'Automatic integer primary key';
COMMENT ON COLUMN baselines.creation_ts               IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN baselines.username                  IS 'User (role) which created data record';

--}}}
-- x sections_definition:{{{

CREATE TABLE sections_definition (
    opid           integer
        REFERENCES public.operations (opid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED,
    id             integer NOT NULL,
    location       text,
    srid           integer,
    ll_corner_x    numeric(10,2),
    ll_corner_y    numeric(10,2),
    ll_corner_z    numeric(10,2),
    azim_ng        numeric(10,2),
    "interval"     numeric(10,0), --TODO change field name
    num_start      integer DEFAULT 1,
    count          numeric(3,0),
    length         numeric(5,0),
    title          text
);
COMMENT ON COLUMN sections_definition.opid            IS 'Operation identifier';
COMMENT ON COLUMN sections_definition.location        IS 'Drilling area';
COMMENT ON COLUMN sections_definition.ll_corner_x     IS 'X coordinate of lower left corner of gridded area';
COMMENT ON COLUMN sections_definition.ll_corner_y     IS 'y coordinate of lower left corner of gridded area';
COMMENT ON COLUMN sections_definition.ll_corner_z     IS 'z coordinate of lower left corner of gridded area';
COMMENT ON COLUMN sections_definition.azim_ng         IS 'Base line azimuth relative to true North';
COMMENT ON COLUMN sections_definition."interval"      IS 'distance between two adjacent sections, i.e. 25m'; -- TODO why is "interval" in quotes?  Was that to escape from something?  Check.
COMMENT ON COLUMN sections_definition.num_start       IS 'first section number (default 1)';
COMMENT ON COLUMN sections_definition.count           IS 'number of sections';
COMMENT ON COLUMN sections_definition.length          IS 'sections length';
COMMENT ON COLUMN sections_definition.title           IS 'section title, to be displayed before section number';

--CREATE SEQUENCE sections_definition_id_seq
--    START WITH 1
--    INCREMENT BY 1
--    NO MINVALUE
--    NO MAXVALUE
--    CACHE 1;
--}}}
-- x sections_array:{{{

CREATE TABLE sections_array (
    opid           integer
        REFERENCES public.operations (opid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED,
    location       text,
    id             text,
    title          text,
    srid           integer,
    x1             numeric(10,2),
    y1             numeric(10,2),
    z1             numeric(10,2),
    length         numeric,
    x2             numeric(10,2),
    y2             numeric(10,2),
    z2             numeric(10,2),
    num            integer NOT NULL
);
COMMENT ON TABLE sections_array                       IS 'Arrays of cross-sections: table automatically fed by generate_cross_sections_array function';

--}}}
-- x conversions_oxydes_elements:{{{

CREATE TABLE conversions_oxydes_elements (
    oxide text,
    molecular_weight numeric,
    factor numeric
);
COMMENT ON TABLE conversions_oxydes_elements          IS 'Molecular weights of some oxides and factors to convert them to elements by weight.';

--}}}
-- x index_geo_documentation:{{{

CREATE TABLE index_geo_documentation (
    opid           integer
        REFERENCES public.operations (opid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED,
    id             integer NOT NULL,
    title          text,
    lat_min        numeric(20,8),
    lat_max        numeric(20,8),
    lon_min        numeric(20,8),
    lon_max        numeric(20,8),
    filename       text,
    datasource     integer,
    numauto        bigserial PRIMARY KEY,
    creation_ts    timestamptz DEFAULT now() NOT NULL,
    username       text DEFAULT current_user
);
COMMENT ON TABLE index_geo_documentation              IS 'Index for any documentation, with lat-lon rectangles, so that any documentation may be accessed geographically';
COMMENT ON COLUMN index_geo_documentation.opid        IS 'Operation identifier';
COMMENT ON COLUMN index_geo_documentation.datasource  IS 'Datasource identifier, refers to lex_datasource';
COMMENT ON COLUMN index_geo_documentation.numauto     IS 'Automatic integer primary key';
COMMENT ON COLUMN index_geo_documentation.creation_ts IS 'Current date and time stamp when data is loaded in table';
COMMENT ON COLUMN index_geo_documentation.username    IS 'User (role) which created data record';

--}}}
--}}}










































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































--}}}


-- on verra à COMMITer en temps utile... => 2017_03_31__11_18_10 semble un temps utile, voilà:
COMMIT;
*/ -- *** fin de ce qui est fait et commenté 2017_04_02__23_35_37


-- _______________ENCOURS_______________GEOLLLIBRE v 3
--10100 LE RESTE...{{{

-- e functions:{{{
-- _______________ENCOURS_______________GEOLLLIBRE vv 4 
-- x generate_cross_sections_array:{{{
-- TODO doit être fait en tant que postgres; voir à améliorer ça.
--\c postgeol postgres

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
#res = plpy.execute("SELECT opid, id, location, srid, ll_corner_x, ll_corner_y, ll_corner_z, azim_ng, interval, num_start, count, length, title FROM sections_definition / *WHERE opid IN (SELECT opid FROM operation_active)* /;") # this line had a C-style comment in the SQL: inserted whitespace, to avoid nested SQL comments conflicts in postgeol_structure.sql script
res = plpy.execute("SELECT opid, id, location, srid, ll_corner_x, ll_corner_y, ll_corner_z, azim_ng, interval, num_start, count, length, title FROM sections_definition;")

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

--}}}
-- o string_to_int:{{{ TODO tiens, curieux: elle n'est pas dans bdexplo: ???
DROP FUNCTION IF EXISTS string_to_int(text);
CREATE OR REPLACE FUNCTION string_to_int(t text) RETURNS bigint AS
$$
--Fournit un entier à partir d'une chaîne; intérêt pour éviter d'avoir des champs serial, pour les tables à carter avec postgis.
--Returns an integer from a string; avoids the requirement for serial fields, for tables to be mapped using postgis.
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

/*  DEBUG  *** DEBUT DE TOUT CE QUI EST INVALIDÉ/PAS ENCORE FAIT ***

-- o views:

-- une vue retrouvée dans les tables:{{{
--TODO Is this view still valid?  If not, erase.
--DROP VIEW IF EXISTS licences_quadrangles;
--CREATE VIEW licences_quadrangles AS
--SELECT *, GeomFromewkt('SRID=4326;POLYGON(('||lon_min||' '||lat_max||','||lon_max||' '||lat_max||','||lon_max||' '||lat_min||','||lon_min||' '||lat_min||','||lon_min||' '||lat_max||'))')
--FROM licences ORDER BY licence_name;
--}}}

-- o general views:
-- o operations_quadrangles:{{{
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

COMMENT ON VIEW operations_quadrangles                IS 'Rectangles geographically traced around all operations';

--}}}
-- o stats_reports views:{{{
CREATE OR REPLACE VIEW
--stats_reports.stats_quotidiennes_avancements_sondages
stats_reports.avancements_sondages_stats_quotidiennes AS
SELECT rig, date, sum(drilled_length_during_shift) as drilled_length_per_day, repeat('|'::text, (sum(drilled_length_during_shift)/10)::integer) AS graph_drilled_length_per_day, count(DISTINCT
--drill_hole_id
 id) AS nb_drill_holes, min(
--drill_hole_id
 id) AS first_dh, max(
--drill_hole_id
 id) AS last_dh from
--drilling_daily_reports
 dh_shift_reports group by rig, date order by rig, date;


CREATE OR REPLACE VIEW stats_reports.avancements_sondages_stats_mensuelles AS
SELECT year, month, sum(drilled_length_during_shift) as drilled_length_during_month FROM (SELECT extract(year from date) as year, extract (month from date) as month, drilled_length_during_shift FROM
--drilling_daily_reports
 dh_shift_reports) AS tmp GROUP BY year,month ORDER BY year, month;

--idem, avec location:
CREATE OR REPLACE VIEW stats_reports.avancements_sondages_stats_mensuelles_par_objectif AS
SELECT year, month, target, sum(drilled_length_during_shift) as drilled_length_during_month FROM (SELECT extract(year from date) as year, extract (month from date) as month, drilled_length_during_shift, split_part (
--drill_hole_id
id, '_', 1) as target FROM
--drilling_daily_reports
 dh_shift_reports) AS tmp GROUP BY year,month, target ORDER BY year, month;


--stats annuelles
CREATE OR REPLACE VIEW stats_reports.avancements_sondages_stats_annuelles AS
SELECT year, sum(drilled_length_during_shift) as drilled_length_during_year FROM (SELECT extract(year from date) as year, drilled_length_during_shift FROM
--drilling_daily_reports
 dh_shift_reports) AS tmp GROUP BY year ORDER BY year;

--idem, avec location:
CREATE OR REPLACE VIEW stats_reports.avancements_sondages_stats_annuelles_par_objectif AS
SELECT year, target, sum(drilled_length_during_shift) as drilled_length_during_month FROM (SELECT extract(year from date) as year, extract (month from date) as month, drilled_length_during_shift, substring(
--drill_hole_id
 id,1,4) as target FROM
--drilling_daily_reports
 dh_shift_reports) AS tmp GROUP BY year, target ORDER BY year;


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
id, planned_length, azim_nm, dip FROM
--drilling_daily_reports
dh_shift_reports GROUP BY
--drill_hole_id
id, planned_length, azim_nm, dip) tmp) tmp1, (SELECT count(DISTINCT
--drill_hole_id
id) AS nb_sondages FROM
--drilling_daily_reports
dh_shift_reports) tmp2 WHERE nb_sondages_et_attributs-nb_sondages <> 0;

CREATE OR REPLACE VIEW checks.fichettes_infos_redondantes_incoherentes_quels_ouvrages AS
SELECT
--drill_hole_id
id, min(planned_length) AS min_planned_length, max(planned_length) AS max_planned_length, min(azim_nm) AS min_azim_nm, max(azim_nm) AS max_azim_nm, min(dip) AS min_dip, max(dip) AS max_dip FROM
--drilling_daily_reports
dh_shift_reports GROUP BY
--drill_hole_id
id HAVING (count(DISTINCT planned_length)>1 OR count(DISTINCT azim_nm)>1 OR count(DISTINCT dip)>1);

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
ALTER TABLE dh_sampling OWNER TO pierre;


-- }}}
--_______________ENCOURS_______________GEOLLLIBRE 5

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
-- ? locations {{{

CREATE TABLE locations (
    operation text NOT NULL,
    location text NOT NULL,
    full_name text,
    lat_min numeric(10,5) NOT NULL,
    lon_min numeric(10,5) NOT NULL,
    lat_max numeric(10,5),
    lon_max numeric(10,5)
);
COMMENT ON TABLE locations                            IS 'Zones, prospects code, rectangle';
COMMENT ON COLUMN locations.operation                 IS 'Operation id';
COMMENT ON COLUMN locations.location                  IS 'Location code name, see collars.location';
COMMENT ON COLUMN locations.full_name                 IS 'Location full name';
COMMENT ON COLUMN locations.lat_min                   IS 'South latitude, decimal degrees, WGS84';
COMMENT ON COLUMN locations.lon_min                   IS 'West longitude, decimal degrees, WGS84';
COMMENT ON COLUMN locations.lat_max                   IS 'North latitude, decimal degrees, WGS84';
COMMENT ON COLUMN locations.lon_max                   IS 'East latitude, decimal degrees, WGS84';

--CREATE VIEW locations_rectangles AS SELECT *, GeomFromewkt('SRID=@#latlonwgs84;LINESTRING @#ou_plutôt_rectangle ('
--|| lon_min || ' ' || lat_max || ', '
--|| lon_max || ' ' || lat_max || ', '
--|| lon_max || ' ' || lat_min || ', '
--|| lon_min || ' ' || lat_min || ', '
--|| lon_min || ' ' || lat_max || ))
--FROM locations ORDER BY location;

--}}}
--geochemistry
--anomalies
--targets
--mines
--various, utilities:
-- o quick plot of xy {{{
DROP TABLE IF EXISTS tmp_xy CASCADE;
CREATE TABLE tmp_xy (
    shid text NOT NULL,
    id bigserial NOT NULL,
    srid integer,
    x numeric(10,2),
    y numeric(10,2),
    z numeric(10,2),
    val numeric(10,2),
    comment text,
    CONSTRAINT tmp_xy_id PRIMARY KEY (id)
    );

DROP VIEW IF EXISTS tmp_xy_points;
CREATE VIEW tmp_xy_points AS
SELECT *, GeomFromewkt('SRID='|| srid ||';POINT(' || x || ' ' || y || ' ' || z || ')')
FROM tmp_xy;

--}}}
-- grid:{{{
--
-- Name: grid; Type: TABLE; Schema: pierre; Owner: pierre; Tablespace:
--
CREATE TABLE grid (
    opid integer
    line text,
    station text,
    x numeric,
    y numeric,
    srid integer,
    numauto bigserial PRIMARY KEY,
);


CREATE VIEW grid_points AS
  SELECT *, GeomFromewkt( 'SRID='|| srid ||
                      ';POINT(' ||
                              x || ' ' ||
                              y ||
                           ')'
                     )
  FROM grid;

--}}}

--PAUMÉ:
--ALTER TABLE public.index_geo_documentation ADD COLUMN opid integer;

--}}}
-- _______________ENCOURS_______________GEOLLLIBRE ^ 6
--POUBELLE {{{
--NON, DÉFINI PLUS BAS --lab_ana_results_sample_id_default_value_num:{{{
--CREATE FUNCTION public.lab_ana_results_sample_id_default_value_num() RETURNS trigger
--    LANGUAGE plpgsql
--    AS $$
--BEGIN
----UPDATE public.lab_ana_results SET sample_id = lab_sampleid WHERE (sample_id IS NULL OR sample_id = '') AND (lab_sampleid IS NOT NULL OR lab_sampleid <> '');
--UPDATE public.lab_ana_results SET sample_id_lab = sample_id;
--UPDATE public.lab_ana_results SET sample_id = REPLACE(sample_id, 'STD:', '') WHERE sample_id ILIKE 'STD%';
--
--UPDATE public.lab_ana_results SET value_num =
--REPLACE(
--REPLACE(
--REPLACE(
--REPLACE(
--REPLACE(
--REPLACE(
--REPLACE(
--REPLACE(value,     'IS',           '-999'),
--                  'NSS',           '-999'),
--                  'LNR',          '-9999'),
--                   'NA',            '-99'),
--                    '<',              '-'),
--                    '>',               ''),
--                 'Not Received',  '-9999'),
--                 'Bag Empty',     '-9999')::numeric WHERE value <> 'NULL' AND value IS NOT NULL AND value_num IS NULL;
--RETURN NULL;
--END;
--$$;

--}}}
--Des alter owner: {{{
ALTER TABLE grid OWNER TO pierre;
ALTER TABLE operation_active OWNER TO data_admin;
--ALTER TABLE field_observations OWNER TO data_admin;
ALTER TABLE field_observations_struct_measures OWNER TO data_admin;
ALTER TABLE public.field_photos OWNER TO data_admin;
ALTER TABLE public.formations_group_lithos OWNER TO data_admin;
ALTER TABLE rock_sampling OWNER TO pierre;
ALTER TABLE public.rock_ana OWNER TO pierre;
ALTER TABLE public.surface_samples_grades OWNER TO data_admin;
ALTER TABLE public.gps_wpt OWNER TO pierre;
ALTER TABLE public.geoch_sampling OWNER TO data_admin;
ALTER TABLE public.geoch_ana OWNER TO data_admin;
ALTER TABLE geoch_sampling_grades OWNER TO data_admin;
ALTER TABLE gpy_mag_ground OWNER TO data_admin;
ALTER TABLE dh_collars OWNER TO data_admin;
ALTER TABLE lab_ana_batches_reception OWNER TO data_admin;
ALTER TABLE dh_shift_reports OWNER TO data_admin;
ALTER TABLE dh_litho OWNER TO data_admin;
ALTER TABLE dh_sampling_grades OWNER TO data_admin;
ALTER TABLE licences OWNER TO data_admin;
ALTER TABLE lab_ana_batches_expedition OWNER TO data_admin;
ALTER TABLE lab_ana_batches_reception_18_corr OWNER TO pierre;
ALTER TABLE lab_ana_columns_definition OWNER TO data_admin;
ALTER TABLE lab_ana_results OWNER TO data_admin;
ALTER FUNCTION public.lab_ana_results_sample_id_default_value_num() OWNER TO pierre; --TODO why pierre?
ALTER TABLE lab_analysis_icp OWNER TO pierre;
ALTER TABLE lab_ana_qaqc_results OWNER TO data_admin;
ALTER TABLE qc_sampling OWNER TO data_admin;
ALTER TABLE qc_standards OWNER TO data_admin;
ALTER TABLE ancient_workings OWNER TO data_admin;
ALTER TABLE lex_datasource OWNER TO data_admin;
ALTER TABLE lex_standard OWNER TO data_admin;
ALTER TABLE mag_declination OWNER TO data_admin;
ALTER TABLE topo_points OWNER TO data_admin;
ALTER TABLE survey_lines OWNER TO pierre;
ALTER TABLE baselines OWNER TO data_admin;
ALTER TABLE sections_definition OWNER TO pierre;
ALTER TABLE layer_styles OWNER TO pierre;
ALTER TABLE index_geo_documentation OWNER TO data_admin;
ALTER TABLE program OWNER TO pierre;
ALTER TABLE occurrences OWNER TO data_admin;
ALTER TABLE grade_ctrl OWNER TO data_admin;
ALTER TABLE lex_codes OWNER TO data_admin;
ALTER FUNCTION public.generate_cross_sections_array() OWNER TO postgres; -- tiens, et pourquoi donc to postgres??
--}}}
--DES TABLES QUE, FINALEMENT, TOUT BIEN PESÉ, ON NE MET PAS DANS POSTGEOL:{{{
-- Il convient de les traiter comme il convient, dans bdexplo, où elles restent. En versant leurs données dans la *bonne* structure, celle de postgeol.
-- _______________ENCOURS_______________GEOLLLIBRE 7
-- ?? lab_ana_batches_reception_18_corr:{{{ TODO isn't this daube??

CREATE TABLE lab_ana_batches_reception_18_corr (
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
CREATE TABLE field_sampling (  -- Nota bene: field_sampling used to be called rock_sampling; actually, it may encompass much more than just rocks.  Actually, surface_sampling and field_sampling are competing names and notions...  Why not then, name all "field_*" tables "surface_*", or, abbreviated, "surf_*", or "srf_*", or even "sf*"?... TODO discuss these issues quickly, these choices are not so innocent.
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
COMMENT ON TABLE  public.rock_sampling                IS 'outcrop sampling  (taken with geological hammer)'; --TODO rectifier ça
COMMENT ON COLUMN public.rock_sampling.geologist      IS 'geologist name';
COMMENT ON COLUMN public.rock_sampling.num            IS 'sample name or number';
COMMENT ON COLUMN public.rock_sampling.x              IS 'X coordinate';
COMMENT ON COLUMN public.rock_sampling.y              IS 'Y coordinate';
COMMENT ON COLUMN public.rock_sampling.z              IS 'Z coordinate';
COMMENT ON COLUMN public.rock_sampling.hammer_index   IS 'integer related to the hammer_ana table';          --TODO rectifier ça aussi
*/
COMMENT ON TABLE  public.field_sampling               IS 'Rock samples taken in the field, on surface: outcrops, floats, etc.'; --TODO rectifier ça
COMMENT ON COLUMN public.field_sampling.geologist     IS 'Geologist name';
COMMENT ON COLUMN public.field_sampling.sample_id     IS 'Sample identifier: refers to assay results and quality check tables';
COMMENT ON COLUMN public.field_sampling.x             IS 'X coordinate'; -- TODO add an srid
COMMENT ON COLUMN public.field_sampling.y             IS 'Y coordinate';
COMMENT ON COLUMN public.field_sampling.z             IS 'Z coordinate';
COMMENT ON COLUMN public.field_sampling.hammer_index  IS 'integer related to the hammer_ana table';          --TODO rectifier ça aussi
-- }}}
--}}}
-- x rock_ana:{{{ TODO rename table => no, rather DROP it; lab_ana_results contains results.  If necessary, make a field_sampling_grades table.
-- TODO table assez vide, tout comme field_sampling: contenu à verser, plutôt, dans lab_ana_results (SI CE N'EST DÉJÀ FAIT!)
-- _______________ENCOURS_______________GEOLLLIBRE 8
CREATE TABLE public.field_sampling_ana (  -- Nota bene: field_sampling_ana used to be called rock_ana; actually, it may encompass much more than just rocks.  See remarks above concerning field_sampling table.
    opid                integer REFERENCES operations (opid)
      REFERENCES operations (opid)
      ON UPDATE CASCADE
      ON DELETE CASCADE
      DEFERRABLE INITIALLY DEFERRED,
    --  hammer_index integer,  --TODO rectifier ça... =>
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
-- x gps_wpt: TODO is this daube?{{{ TODO comparer avec field_observations (on dirait que les données y sont; mais vérifier en plottant sur SIG), et faire un bon ménage là-dedans. En profiter pour aller rechercher la bd que j'avais au SGR/REU, et reprendre mes waypoints de l'époque, qui doivent manquer à l'appel (il y en avait d'autres, des persos qui n'étaient pas dans cette BD?). Ainsi que les tracés, té, tank à fer. Tracés qu'il faudrait stocker en BD, aussi, bien sûr. En se calquant sur la structure d'oruxmaps par exemple; ou alors en stockant des gros jsonb ou des gros xml: à voir.

CREATE TABLE gps_wpt (
    opid integer REFERENCES operations (opid), --TODO ATTENTION, CHAMP RAJOUTÉ
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
-- Old data, historical, kept out of main tables set: --TODO dump this as tagged contents (json-like, or equivalent) into comments field, rather; later on.

CREATE TABLE dh_collars_lengths (
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

CREATE TABLE program (
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

--TODO Les droits: trucs du genre: ALTER TABLE field_photos OWNER TO data_admin;
--TODO
