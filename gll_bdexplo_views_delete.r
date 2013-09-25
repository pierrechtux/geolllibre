#!/usr/bin/rebol -qs
rebol	[
	Title:   "Démolition des vues de bdexplo"
	Name:    gll_bdexplo_views_create.r
	Version: 1.0.0
	Date:    "5-Aug-2013/17:53:46"
	Author:  "Pierre Chevalier"
	License: {
		This file is part of GeolLLibre software suite: FLOSS dedicated to Earth Sciences.
		###########################################################################
		##          ____  ___/_ ____  __   __   __   _()____   ____  _____       ##
		##         / ___\/ ___// _  |/ /  / /  / /  /  _/ _ \ / __ \/ ___/       ##
		##        / /___/ /_  / / | / /  / /  / /   / // /_/_/ /_/ / /_          ##
		##       / /_/ / /___|  \/ / /__/ /__/ /___/ // /_/ / _, _/ /___         ##
		##       \____/_____/ \___/_____/___/_____/__/_____/_/ |_/_____/         ##
		##                                                                       ##
		###########################################################################
		  Copyright (C) 2013 Pierre Chevalier <pierrechevaliergeol@free.fr>
		 
		    GeolLLibre is free software: you can redistribute it and/or modify
		    it under the terms of the GNU General Public License as published by
		    the Free Software Foundation, either version 3 of the License, or
		    (at your option) any later version.
		
		    This program is distributed in the hope that it will be useful,
		    but WITHOUT ANY WARRANTY; without even the implied warranty of
		    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		    GNU General Public License for more details.
		
		    You should have received a copy of the GNU General Public License
		    along with this program.  If not, see <http://www.gnu.org/licenses/>
		    or write to the Free Software Foundation, Inc., 51 Franklin Street, 
		    Fifth Floor, Boston, MA 02110-1301, USA.
		    See LICENSE file.
		}
]


;	 _________
;	< bdexplo >
;	 ---------
;	        \   ^__^
;	         \  (xx)\_______
;	            (__)\       )\/\
;	             U  ||----w |
;	                ||     ||
;	



do load to-file system/options/home/bin/gll_routines.r	; Récupération des routines et préférences
connection_db						; connection à la base
insert db "BEGIN TRANSACTION;"
;# on fabrique un gros texte en sql, qu'on fera tourner à la fin {{ {

?? dbhost
?? dbname


sql_text: {
--destruction des vues de la bdexplo
--tout est listé dans l'ordre inverse du script de création

BEGIN TRANSACTION;  -- {{{

DROP VIEW IF EXISTS tanguy.qry_blank;
DROP VIEW IF EXISTS tanguy.qry_deviation;
DROP VIEW IF EXISTS tanguy.qry_duplicate;
DROP VIEW IF EXISTS tanguy.qry_interval_mine;
DROP VIEW IF EXISTS tanguy.qry_recup;
DROP VIEW IF EXISTS tanguy.qry_std; 
DROP VIEW IF EXISTS tanguy.qry_suivi_ech;
DROP VIEW IF EXISTS tanguy.chk_tmp;
DROP VIEW IF EXISTS tanguy.geoch_data;
DROP VIEW IF EXISTS tanguy.geoch_multi_ana;
DROP VIEW IF EXISTS tanguy.geoch_multi_ana_subq;
DROP VIEW IF EXISTS tanguy.surp_collar;



DROP VIEW IF EXISTS public.dh_collars_for_gpx;

--#################################################################

--#################################################################

--9. points echantillons 3D:/*{{{*/
DROP VIEW IF EXISTS public.dh_sampling_avg_grades_3dpoints;
--
/*}}}*/
-- 8. requetes SMI: apu/*{{{*/
--DROP VIEW IF EXISTS smi.dh_sampling_avg_grades;
--DROP VIEW IF EXISTS smi.tmp_topo_xyz_points;
--DROP VIEW IF EXISTS smi.tmp_dh_marec;
--DROP VIEW IF EXISTS smi.tmp_collargbeitouo_points;
--DROP VIEW IF EXISTS smi.tmp_charlot_dh_collars_point;
--DROP VIEW IF EXISTS smi.tmp;
--DROP VIEW IF EXISTS smi.lab_ana_results;
--DROP VIEW IF EXISTS smi.dh_traces_3d;
--DROP VIEW IF EXISTS smi.dh_sampling_grades;
--DROP VIEW IF EXISTS smi.dh_sampling;
--DROP VIEW IF EXISTS smi.dh_litho;
--DROP VIEW IF EXISTS smi.dh_devia;
--DROP VIEW IF EXISTS smi.dh_collars_points;
--DROP VIEW IF EXISTS smi.dh_collars;
--

--DROP VIEW IF EXISTS  smi.dh_collars                   ;
/*}}}*/

--DROP VIEW IF EXISTS dh_dernieres_analyses;

DROP VIEW IF EXISTS public.dh_collars_points_last_ana_results;

DROP VIEW IF EXISTS public.sections_array_plines;

--le marecage de la SMI: /*{{{*/
--DROP VIEW IF EXISTS marec2utm;
/*}}}*/

-- pour surpac:/*{{{*/
DROP VIEW IF EXISTS public.surpac_survey;
--
/*}}}*/

-- des stats:
DROP VIEW IF EXISTS stats_reports.recap_file_results_drill_holes;
DROP VIEW IF EXISTS stats_reports.avancements_sondages_stats_quotidiennes;
DROP VIEW IF EXISTS stats_reports.avancements_sondages_stats_mensuelles;
DROP VIEW IF EXISTS stats_reports.avancements_sondages_stats_mensuelles_par_objectif;
DROP VIEW IF EXISTS stats_reports.avancements_sondages_stats_annuelles;
DROP VIEW IF EXISTS stats_reports.avancements_sondages_stats_annuelles_par_objectif;
DROP VIEW IF EXISTS stats_reports.longueur_exploree_par_location;
DROP VIEW IF EXISTS stats_reports.longueur_exploree_par_location_et_type;
DROP VIEW IF EXISTS stats_reports.longueur_exploree_par_type_km;



DROP VIEW IF EXISTS checks.collars_lengths_vs_dh_sampling_depths;
DROP VIEW IF EXISTS checks.collars_lengths_vs_dh_litho_depths;
DROP VIEW IF EXISTS checks.doublons_collars_id;
DROP VIEW IF EXISTS checks.doublons_dh_sampling_id_depto;
DROP VIEW IF EXISTS checks.doublons_dh_litho_id_depto;
DROP VIEW IF EXISTS checks.tetes_passes_ouvrages_dans_tetes_pas_dans_passes_dh_sampling;
DROP VIEW IF EXISTS checks.tetes_passes_ouvrages_dans_passes_pas_dans_tetes_dh_sampling;
DROP VIEW IF EXISTS checks.tetes_passes_ouvrages_dans_tetes_pas_dans_passes_dh_litho;
DROP VIEW IF EXISTS checks.tetes_passes_ouvrages_dans_passes_pas_dans_tetes_dh_litho;
DROP VIEW IF EXISTS checks.collars_vs_temp_topo_id_topo_sans_collars;
DROP VIEW IF EXISTS checks.collars_vs_topo_xyz_en_face_et_differences_importantes;
DROP VIEW IF EXISTS checks.fichettes_infos_redondantes_incoherentes;
DROP VIEW IF EXISTS checks.fichettes_infos_redondantes_incoherentes_quels_ouvrages;
DROP VIEW IF EXISTS checks.fichettes_infos_incoherentes_heures;
DROP VIEW IF EXISTS checks.fichettes_vs_collars_ouvrages_dans_fichettes_pas_collars;
DROP VIEW IF EXISTS checks.fichettes_longueurs_incoherentes;
DROP VIEW IF EXISTS checks.fichettes_vs_collars_longueurs_incoherentes;
DROP VIEW IF EXISTS checks.fichettes_ouvrages_non_completed;

DROP VIEW IF EXISTS checks.dh_collars_to_topo_points_lines;


DROP VIEW IF EXISTS checks.fichettes_vs_collars_completed_incoherents;
DROP VIEW IF EXISTS checks.fichettes_vs_collars_azimuts_incoherents;
DROP VIEW IF EXISTS checks.fichettes_vs_collars_dips_incoherents;
DROP VIEW IF EXISTS checks.fichettes_infos_incoherentes_drilled_lengths;
DROP VIEW IF EXISTS checks.fichettes_infos_incoherentes_nb_samples;
DROP VIEW IF EXISTS stats_reports.verif_attachements_journaliers_sondeur;
DROP VIEW IF EXISTS checks.doublons_collars_xyz;
DROP VIEW IF EXISTS checks.doublons_collars_xyz_ouvrages_concernes;


-- 7. pour GDM: les vues sont basées sur la table gdm_selection: 
DROP VIEW IF EXISTS gdm.gdm_dh_planned;
DROP VIEW IF EXISTS gdm.gdm_sections_array;
DROP VIEW IF EXISTS gdm.gdm_baselines;
DROP VIEW IF EXISTS gdm.gdm_dh_mine_0;
DROP VIEW IF EXISTS gdm.gdm_dh_mine_1;
DROP VIEW IF EXISTS gdm.gdm_dh_sampling_grades_open_ended_au_tail;
DROP VIEW IF EXISTS gdm.gdm_dh_sampling_grades_open_ended_au_top;
DROP VIEW IF EXISTS gdm.gdm_dh_sampling_grades;
DROP VIEW IF EXISTS gdm.gdm_dh_litho;
DROP VIEW IF EXISTS gdm.gdm_dh_devia;
DROP VIEW IF EXISTS gdm.gdm_selection;




--un intrus: une dépendance à résoudre: TODO
DROP VIEW IF EXISTS public.dh_sampling;


-- 8. les sondages ouverts:

--sondages ouverts en pied en Au:
DROP VIEW IF EXISTS dh_sampling_grades_open_ended_au_tail;
--
--sondages ouverts en tête en Au:
DROP VIEW IF EXISTS dh_sampling_grades_open_ended_au_top;
--


--
-- 6. vues des échantillons et analyses en colonnes: 
DROP VIEW IF EXISTS dh_sampling_ana;
--

-- 5. vues des analyses en colonnes:
--DROP VIEW IF EXISTS lab_ana_results_sel;
DROP VIEW IF EXISTS lab_ana_results_columns_count;
DROP VIEW IF EXISTS lab_ana_results_columns_max;
DROP VIEW IF EXISTS lab_ana_results_columns_min;
DROP VIEW IF EXISTS lab_ana_results_columns_avg;
DROP VIEW IF EXISTS tmp_lab_ana_results;
DROP FUNCTION public.create_crosstab_view (eavsql_inarg varchar, resview varchar, rowid varchar, colid varchar, val varchar, agr varchar);
--

-- 3. des vues genre alias pratique: 
DROP VIEW IF EXISTS dh_sampling_mineralised_intervals_graph_au6;
DROP VIEW IF EXISTS dh_sampling_grades_graph_au_6;
--DROP VIEW IF EXISTS dh_litho_custom;
DROP VIEW IF EXISTS public.collars_selection;
--DROP VIEW IF EXISTS public.dh_collars_points_20137;
--DROP VIEW IF EXISTS public.dh_collars_points_20136;
--DROP VIEW IF EXISTS public.collars_program;
--DROP VIEW IF EXISTS public.collars;
--



-- 4. vues pour postgis:
--DROP VIEW IF EXISTS public.tmp_xy_points;
--DROP VIEW IF EXISTS public.tmp_coupes_seriees_plines;
--DROP VIEW IF EXISTS soil_geoch_bondoukou_points;

DROP VIEW IF EXISTS public.dh_collars_points_marrec ;

DROP VIEW IF EXISTS surface_samples_grade_points;
DROP VIEW IF EXISTS operations_quadrangles;
DROP VIEW IF EXISTS public.licences_quadrangles;
DROP VIEW IF EXISTS dh_mineralised_intervals0_traces_3d;
DROP VIEW IF EXISTS public.index_geo_documentation_rectangles;
DROP VIEW IF EXISTS public.grid_points;


DROP VIEW IF EXISTS public.geoch_sampling_grades_points;



--#################################################################
DROP VIEW IF EXISTS public.topo_points_points;
DROP VIEW IF EXISTS petro_mineralo_study_field_observations_points;
DROP VIEW IF EXISTS petro_mineralo_study_dh_collars;
--#################################################################


DROP VIEW IF EXISTS field_observations_points;
DROP VIEW IF EXISTS dh_traces_3d              ;
DROP VIEW IF EXISTS dh_collars_points         ;
--DROP VIEW IF EXISTS public.dh_traces_3d_20137;
--DROP VIEW IF EXISTS public.dh_traces_3d_20136;
--

COMMIT; --}}}
}

;# -- 1. les vues homonymes des tables, dans le premier schéma dans l'ordre de recherche, en restreignant à l'opération active: 
views_user: run_query rejoin ["SELECT viewname FROM pg_views WHERE schemaname = '" user  "';"]
tables_public: run_query "SELECT tablename FROM pg_tables WHERE schemaname = 'public';"
sort tables_public
views_from_join_operationid: intersect views_user tables_public

comment [ ;{{{ } } }
views_from_join_operationid: [
"ancient_workings"        
"dh_collars"              
"dh_collars_program"      
"dh_density"              
"dh_devia"                
"dh_litho"                
"dh_mineralised_intervals"
"dh_sampling_grades"      
"dh_struct"               
"dh_tech"                 
"field_observations"      
"field_photos"            
"geoch_ana"               
"geoch_sampling"          
"geoch_sampling_grades"   
"grade_ctrl"              
"lab_ana_batches"         
"lab_ana_results"         
"lab_analysis_icp"        
"occurrences"             
"qc_sampling"             
"qc_standards"            
"rock_ana"                
"rock_sampling"           
"shift_reports"           
"topo_points"
]
]; }}}

append sql_text rejoin ["BEGIN TRANSACTION;  --{{{" newline]
foreach tablename views_from_join_operationid [
	append sql_text rejoin ["DROP VIEW IF EXISTS " user "." tablename ";" newline]
	]

;print sql_text #DEBUG
;comment [ ;{{{ } } } 
;Anciennement: /*
;DROP VIEW IF EXISTS shift_reports;
;DROP VIEW IF EXISTS rock_sampling;
;DROP VIEW IF EXISTS rock_ana;
;DROP VIEW IF EXISTS qc_standards;
;DROP VIEW IF EXISTS qc_sampling;
;DROP VIEW IF EXISTS occurrences;
;DROP VIEW IF EXISTS lab_analysis_icp;
;DROP VIEW IF EXISTS lab_ana_results;
;DROP VIEW IF EXISTS lab_ana_batches;
;DROP VIEW IF EXISTS grade_ctrl;
;DROP VIEW IF EXISTS geoch_sampling_grades;
;DROP VIEW IF EXISTS geoch_sampling;
;DROP VIEW IF EXISTS geoch_ana;
;DROP VIEW IF EXISTS field_photos;
;DROP VIEW IF EXISTS field_observations;
;DROP VIEW IF EXISTS dh_tech;
;DROP VIEW IF EXISTS dh_struct;
;DROP VIEW IF EXISTS dh_sampling_grades;
;DROP VIEW IF EXISTS dh_sampling;
;DROP VIEW IF EXISTS dh_mineralised_intervals;
;DROP VIEW IF EXISTS dh_litho;
;DROP VIEW IF EXISTS dh_devia;
;DROP VIEW IF EXISTS dh_density;
;DROP VIEW IF EXISTS dh_collars_program;
;DROP VIEW IF EXISTS dh_collars;
;DROP VIEW IF EXISTS ancient_workings;
;*/
;] ; }}}

append sql_text "COMMIT; --}}}"
append sql_text newline

;# Voilà, le sql est fabriqué.
;# que l'on runne ensuite
; insert db to-string sql_text
;insert db sql_text

;comment [
;
;>> insert db to-string sql_text ;=> 
;** Script Error: Invalid argument: VIEW
;** Where: forever
;** Near: to integer! trim pos
;>> 
;=> marche pas: voir avec Doc
;] 

; => en attendant que ça marche (voir doc ou Doc), on passe bêtement par une bonne vieille ligne de commande:
ligne_cmd: rejoin [{echo "} sql_text {" | psql -X -d } dbname { -h } dbhost { -U } user ]
;call/wait ligne_cmd

; Prudemment, on ne runne pas, on affiche juste:
; print ligne_cmd
; Mieux, on génère un script à runner:
script: %tt_gll_bdexplo_views_delete.sh 
write script ligne_cmd

print rejoin [newline "Bdexplo views deletion script generated: " to-string script newline "to run it:" newline "sh " to-string script newline]
close  db

