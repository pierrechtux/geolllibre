BEGIN TRANSACTION;
-- Roles definition
/*
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
ALTER FUNCTION public.lab_ana_results_sample_id_default_value_num() OWNER TO pierre; -- TODO why pierre?
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

-- TODO Les droits: trucs du genre: ALTER TABLE field_photos OWNER TO data_admin;

*/

