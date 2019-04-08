#!/usr/bin/rebol -qs
REBOL [;{{{ } } }
	Title:   "Gets information from GeolPDA android device, and uploads it to a PostGeol database"
	;Date:    == 12-Feb-2014/12:18:12+1:00
	;Date:    == 27-Aug-2016/15:59:30+2:00
	Version: 0.1.0
	Purpose: {
	}
	History: [
		22-Oct-2013/17:23:33+2:00 {Version operational}
		12-Feb-2014/12:18:12+1:00 {Clean-up}
		27-Aug-2016/15:59:30+2:00 {Re-write to access Android device through MTP protocol}
	]
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
  Copyright (C) 2016 Pierre Chevalier <pierrechevaliergeol@free.fr>
 
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
];}}}

DEBUG: false
if DEBUG [; check:  ============================ save 2 tables observations and measurements as csv (no, it is not csv, but just a text dump; it does not matter much) BEFORE: {{{ } } }
run_query "SELECT * FROM public.field_observations"
;write %~/field_observations_avant.csv sql_result_csv
foreach r sql_result [
	write/append %~/field_observations_avant.csv rejoin [mold r newline]
]
run_query "SELECT * FROM public.field_observations_struct_measures"
;write/lines %~/field_observations_struct_measures_avant.csv sql_result_csv
;write %~/field_observations_struct_measures_avant.csv newline
foreach r sql_result [
	write/append %~/field_observations_struct_measures_avant.csv rejoin [mold r newline]
]
] ;}}}

; initialisation: ;{{{ } } }
if error? try [													; Get routines (and preferences) and database connection
if error? try [
do load to-file system/options/home/bin/gll_routines.r			; either from ~/bin,
] [
do load to-file %gll_routines.r				 					; or where the current script is located,
]
] [
do load to-file system/options/home/geolllibre/gll_routines.r	; or from ~/geolllibre
]
flag_ERROR: false
;}}}

; Execution
print "========================================================================="
print " Get database and associated files from GeolPDA device to local computer"
print "========================================================================="
;get_bdexplo_max__id ; no, it does not work if a new geolpda database is used: this is the case when a sqlite geolpda database becomes too big, making GeolPDA too slow for field work.
; So, instead, get the max_timestamp_epoch_ms:
max_timestamp_epoch_ms: get_postgeol_max_timestamp_epoch_ms

if flag_ERROR [ print "Error, quitting." quit ]
print "Connect geolpda android device, copy to local directory:" ;{{{ } } }
COMMENT: [
; NO => Old way, using USB mass storage; deprecated on modern Android devices (sigh...) => commented out: {{{
;; DOUBLE commented out, for readability:
;; default directories are stored in .gll_preferences
;
;; Get the user to properly mount the android device:
;print "Mount android device: connect android device containing geolpda; then press Enter when device properly connected"
;; Get the location where it is mounted:
;alert {locate where android device is mounted, pick up "geolpda" subdirectory}
;unless DEBUG [ dir_mount_geolpda_android: request-dir/title/dir {locate geolpda where android device is located, choose "geolpda" subdirectory} dir_mount_geolpda_android ]
;
;; Get the location of the local image of geolpda data:
;alert {now locate the local directory where geolpda data is (or will be) replicated}
;unless DEBUG [ dir_geolpda_local:         request-dir/title/dir {locate local directory for replication of geolpda data}                        dir_geolpda_local         ]
;
;print rejoin ["Mount directory of GeolPDA android device: " tab tab dir_mount_geolpda_android newline "Local directory for GeolPDA data replication: " tab dir_geolpda_local]
;}}}
; NO => Other way, using MTP protocol, which seems the only way to access modern (as of 2016_08_27__16_16_47) Android devices (sigh again...): {{{ } } }
; 
;; default directories are stored in .gll_preferences
;
;; If there is already an MTP mount, skip the mount step:
;tt: call_wait_output_error "mount | grep jmtp"
;either (tt = "") [
;	; Get the user to properly mount the android device:
;	ask "Connect Android device for MTP access by a USB cable and make sure android screen is unlocked." newline "Press Enter when ready."
;	;alert "Mount android device: connect android device containing geolpda; then press Enter when device properly connected"
;	dir: copy to-string dir_mount_geolpda_android
;	replace dir "/Phone/geolpda/" ""
;	call_wait_output_error rejoin ["jmtpfs " dir]
;	; wait a couple seconds:
;	wait 2
;	; check that the device is correctly mounted:
;	call_wait_output_error "mount | grep jmtp"
;	; double-check (...) by listing mounted directory:
;	print "Listing mounted directory:"
;	if error? try [print read to-file dir] [print rejoin [ "=> error, " dir " contents cannot be read."]]
;	print newline
;] [
;	print ["Android device already mounted." newline]
;]
;;}}}
] 
; And yet another way, using adb, which proves to be much faster and more reliable than MTP to mount an android machine:{{{ } } }
 
; default directories are stored in .gll_preferences
; If there is already an ADB mount, skip the mount step:
tt: call_wait_output_error "mount | grep adbfs"
either (tt = "") [
	; Get the user to properly mount the android device:
	ask "Connect Android device for ADB access by a USB cable and make sure android screen is unlocked." newline "Press Enter when ready."
	;alert "Mount android device: connect android device containing geolpda; then press Enter when device properly connected"
	dir: copy to-string dir_mount_geolpda_android
	replace dir "/Phone/geolpda/" ""  ; c'est pas bon pour le adbfs, apparemment
	replace dir "/sdcard/geolpda/" ""
	call_wait_output_error rejoin ["adbfs " dir]
	; wait a couple seconds:
	wait 2
	; check that the device is correctly mounted:
	call_wait_output_error "mount | grep adbfs"
	; double-check (...) by listing mounted directory:
	print "Listing mounted directory:"
	if error? try [print read to-file dir] [print rejoin [ "=> error, " dir " contents cannot be read."]]
	print newline
] [
	print ["Android device already mounted." newline]
]

;}}}

; Get the geolpda location on the mounted filesystem:
	;dir_mount_geolpda_android: request-dir/title/dir {pick up "geolpda" subdirectory} dir_mount_geolpda_android
	; => without rebol/view, everything on the console:
	print {Choose "geolpda" subdirectory:}
	while [not (exists? to-file dir_mount_geolpda_android)] [
		print rejoin ["Default directory: " dir_mount_geolpda_android " cannot be read."]
		print {Locate where android device is mounted, pick up "geolpda" subdirectory}
		print dir_mount_geolpda_android
		x: input
		either (x = "") [x: dir_mount_geolpda_android] [dir_mount_geolpda_android: to-file x]
	]

print "Android geolpda directory contents:"
print read dir_mount_geolpda_android

; Get the location of the local image of geolpda data:
;dir_geolpda_local:         request-dir/title/dir {locate local directory for replication of geolpda data}                        dir_geolpda_local
; => without rebol/view:
	while [not (exists? to-file dir_geolpda_local)] [
		print rejoin ["Default directory: " dir_geolpda_local " cannot be read."]
		print {Locate the local directory where geolpda data is (or will be) replicated:}
		print dir_geolpda_local
	]

print rejoin ["Mount directory of GeolPDA android device: " tab tab dir_mount_geolpda_android newline "Local directory for GeolPDA data replication: " tab dir_geolpda_local]
;

; Get the DCIM pictures location on the mounted filesystem:
	print {Choose Digital Camera IMages (DCIM) directory to be imported:}
	while [not (exists? to-file dir_mount_dcim_android)] [
		print rejoin ["Default directory: " dir_mount_dcim_android " cannot be read."]
		print {Locate where android device is mounted, pick up "DCIM" (or equivalent) subdirectory}
		print dir_mount_dcim_android
		x: input
		either (x = "") [x: dir_mount_dcim_android] [dir_mount_dcim_android: to-file x]
	]

;}}}
; Synchronize android device to local filesystem, if agreed:{{{ } } }
answer: copy ""
while [((answer != "y") and (answer != "n") and (answer != ""))] [
	answer: ask "Get geolpda database from android device? (Y/n)"
]
if ((answer = "y") or (answer = "")) [
	if error? try [
		copy-file to-file rejoin [dir_geolpda_local "geolpda"] to-file rejoin [dir_geolpda_local "geolpda.bak." timestamp_]
	] [
		print "Error while backuping previous geolpda."
	]
	copy-file to-file rejoin [dir_mount_geolpda_android "geolpda"] to-file rejoin [dir_geolpda_local "geolpda"]
	print "Database copied from android device."
]
answer: copy ""
while [((answer != "y") and (answer != "n") and (answer != ""))] [
	answer: ask "Synchronize geolpda files (pictures, audio files)? (Y/n)"
]
if ((answer = "y") or (answer = "")) [ synchronize_geolpda_files ]

;}}}

; Open sqlite geolpda, get data:{{{ } } }
print "Open GeolPDA database..."
change-dir dir_geolpda_local
copy-file %geolpda %geolpda_copy.db
	; => not terrible; this file copy is /only due to the 
	;    fact that the btn (better than nothing) driver does
	;    not support sqlite file without extension...
db: open to-url rejoin [{btn://localhost/} dir_geolpda_local {geolpda_copy.db}]

; Get data: as db is the same name as defined for default
; database connexion in gll_routines.r, we can use the functions:
; observations: {{{ } } }
run_query (rejoin ["SELECT * FROM poi WHERE poitime > " max_timestamp_epoch_ms])

; Comparison of field list: to be sure that the table structure matches the 
; one used at the time of coding (23-Oct-2013/9:24:01+2:00)
unless sql_result_fields = ["_id" "poiname" "poitime" "elevation" "poilat" "poilon" "photourl" "audiourl" "note"] [
	print "ATTENTION! field names differ from geolpda reference implementation"
	print "Error, halting"
	halt
]
geolpda_observations:        copy sql_result
;geolpda_observations_fields: copy sql_result_fields
print rejoin [tab length? geolpda_observations " records in observations table from GeolPDA with poitime superior to maximum timestamp_epoch_ms in field_observations (" max_timestamp_epoch_ms")"]
;}}}
; orientations:{{{ } } }
run_query (rejoin ["SELECT orientation.* FROM orientation LEFT JOIN poi ON poi._id = orientation.poi_id WHERE poitime > " max_timestamp_epoch_ms])

; Unless there is no record:
unless (length? sql_result) = 0 [
; Comparison of field list: to be sure that the table structure matches the 
; one used at the time of coding (23-Oct-2013/9:24:01+2:00)
unless sql_result_fields = ["_id" "poi_id" "orientationtype" "rot1" "rot2" "rot3" "rot4" "rot5" "rot6" "rot7" "rot8" "rot9" "v1" "v2" "v3"] [
	print "ATTENTION! field names differ from geolpda reference implementation"
	print "Error, halting"
	halt
] ]
; If we reached here, we are ok; now, it is necessary to also fetch the full id from observations by JOINing:
run_query rejoin ["SELECT poiname, orientation._id, poi_id, orientationtype, rot1, rot2, rot3, rot4, rot5, rot6, rot7, rot8, rot9, v1, v2, v3 FROM orientation LEFT JOIN poi ON poi._id = orientation.poi_id WHERE poitime > " max_timestamp_epoch_ms ]
geolpda_orientations: 			copy sql_result
;geolpda_orientations_fields: 	copy sql_result_fields
print rejoin [tab length? geolpda_orientations " records in orientations measurements table from GeolPDA with poitime superior to maximum timestamp_epoch_ms in field_observations (" max_timestamp_epoch_ms ")"]
;}}}
;}}}

;####################################################################{ {{
; ###### data from geolpda is now in tables:
;   geolpda_observations
;   geolpda_orientations
;####################################################################
;/*} }}*/

connection_db		; => careful: now DB points to the default database, not to the geolpda any more.
; default opid from .gll_preferences can be irrelevant, for field_observations: it rather leads to unconsistencies. So it is better to ask the user which opid he wishes. {{{ } } }
print-list run_query "SELECT opid, ': ', confidentiality, CASE WHEN confidentiality THEN substring(name_full, 0, 5) || '-----' ELSE name_full END FROM public.operations ORDER BY opid;"

opids: run_query "SELECT opid FROM public.operations;"
until [
	tt: ask rejoin ["OPeration IDentifier (default: " opid ")?" newline ]
	; check that the temporary variable holds an integer, or nothing:
	either (tt = "") [
		true 			; if tt = "", nothing to do, since opid is already defined
		] [
		; tt is not ""
		either (error? try [tt: to-integer tt]) [
			print rejoin [ "Error: " tt " cannot be converted to an integer => try again:"]
			tt: copy ""
			false
			] [
			; tt has been converted to an integer
			; check that the chosen opid actually exists in operations table:
			either (find opids reduce [to-block tt]) [
				opid: tt
				] [
				print rejoin [ "Error: " tt " cannot be found in the opid list from operations table in " dbname " database hosted by " dbhost " => try again:"]
				tt: copy ""
				false
	] ] ] ]
?? opid
; TODO also check that the user does not answer to a previous question by yor n, typing while the program is (too silently) syncing...

;}}}
; Put data:{{{ } } }
; build a SQL INSERT statement:
sql_string: copy ""
; Generate a new datasource: {{{ } } }
;datasource: 9999    ; bidon; TODO generate a new datasource record in lex_datasource
file_in: rejoin [ to-string dir_mount_geolpda_android "geolpda"]
; générer un datasource_id: {{{
print "New datasource_id generation..."
get_new_datasource_id
either (test_datasource_available new_datasource_id) [
	print rejoin ["Ok, proposed datasource_id " new_datasource_id " free in database" ]
	generate_sql_string_update new_datasource_id file_in
	; NB: sql_string_update contient maintenant le SQL à jouer à la fin
	] [
	print rejoin ["Problem, proposed datasource_id " new_datasource_id " already referenced in database: ^/" res ]
	;quit ; trop dur
	halt  ; plus doux
	]
sql_string: rejoin ["" newline sql_string_update]
datasource: new_datasource_id
;}}}
;}}}
; TODO BUG: no records are added to public.lex_datasource
; => 2018_10_15__19_38_10 ?? No bug (?): records have correctly been added to public.lex_datasource
; => recheck, later on.
append sql_string newline

; observations:{{{ } } }
; if there is anything to add:
if (length? geolpda_observations) > 0 [
	; continue the SQL INSERT statement:
	_: {, } ; just to save a few keystrokes to the coder... and to make REJOIN code a bit more readable; variable was called SEP for SEParator; renamed to _ for clarity/brevity
	append sql_string {INSERT INTO public.field_observations (device,opid,year,obs_id,date,waypoint_name,x,y,z,description,code_litho,code_unit,srid,geologist,icon_descr,comments,sample_id,datasource,photos,audio,timestamp_epoch_ms) VALUES }
	foreach o geolpda_observations [
		tmp: to-date epoch-to-date (to-integer ((to-decimal o/3) / 1000))
		append sql_string rejoin [newline {('} geolpda_device {'} _ opid _ tmp/year _ {'} o/2 {'} _ {'} tmp/year "-" pad tmp/month 2 "-" pad tmp/day 2 {'} _ {'} o/1 {'} _ o/6 _ o/5 _ o/4 _ {'} o/9 {'} _ {NULL, NULL, 4326} _ {'} geologist {'} _ {NULL, NULL, NULL, NULL, } {'} o/7 {'} _ {'} o/8 {'} _ o/3 {),}]
	]
	sql_string: rejoin [copy/part sql_string ((length? sql_string) - 1) ";"]
]
; Corrections of single quotes in strings: i.e. jusqu&#39;ici
append sql_string rejoin [newline {UPDATE public.field_observations SET description = replace(description, '&#39;', e'\'') WHERE description ILIKE '%&#39;%';}]

print "SQL statement to be run:"
prin copy/part sql_string 300
print "..."

;}}}
; orientations: {{{ } } }
; if anything to add:
if (length? geolpda_orientations) > 0 [
	append sql_string rejoin [newline newline {INSERT INTO public.field_observations_struct_measures (device,                  opid,    obs_id     , measure_type , north_ref ,  datasource ,        rotation_matrix                                                                ,   geolpda_id , geolpda_poi_id, valid  ) VALUES } ]
	foreach m geolpda_orientations [
		append sql_string rejoin [newline {(}                                                         {'} geolpda_device {'} _ opid _ {'} m/1 {'}  _  {'} m/4 {'} _    {'Nm'} _  datasource _   {'[}  m/5 " " m/6 " " m/7 " " m/8 " " m/9 " " m/10 " " m/11 " " m/12 " " m/13  {]'} _       m/2    _      m/3      _ {TRUE  ),}        ]
	]
	sql_string: rejoin [copy/part sql_string ((length? sql_string) - 1) ";"]
]

;}}}
print "SQL statement to be run:"
prin copy/part sql_string 300 print "..."
;}}}

; Play INSERT queries on database and COMMIT: {{{ } } } ;TODO BUG: Il n'y a pas de TRANSACTION de commencée?? Remédier à cela...
insert db sql_string
print "Done..."
insert db "COMMIT;"
print "commited => end."
;}}}

; Compute structural orientations from geolpda orientation measurements and populate appropriate fields in field_observations_struct_measures_avant.csv:{{{
;print "TO BE TESTED! ARRÊTÉ!"
;input
; Restrict the computation to the data that has just been imported.
;update_field_observations_struct_measures_from_rotation_matrix /criteria rejoin ["datasource = " datasource]
; TODO attention! datasource ne semble pas être renseigné tout le temps! Il faudra remettre la ligne précédente, une fois ceci résolu.
update_field_observations_struct_measures_from_rotation_matrix /criteria rejoin ["creation_ts::date = " to-iso-date now/date]


;_______________________________________________________________________________________________________________________________


;}}}

if DEBUG [ ; {{{ } } }
vérif:  ============================ sauve 2 tables obs et mesures en csv APRÈS: {{{ } } }
run_query "SELECT * FROM public.field_observations"
;write %~/field_observations_apres.csv newline
;ww: copy sql_result
;foreach r ww [
;	write/append %~/field_observations_apres.csv rejoin [mold r newline]
;]
write %~/field_observations_apres.csv sql_result_csv

run_query "SELECT * FROM public.field_observations_struct_measures"
;write %~/field_observations_struct_measures_apres.csv newline
;ww: copy sql_result
;foreach r ww [
;	write/append %~/field_observations_struct_measures_apres.csv rejoin [mold r newline]
;]
write/lines %~/field_observations_struct_measures_apres.csv sql_result_csv
;}}}

; Comparaison des csv avant-après: {{{ } } }
print {To see diffs, run:}
print {diff ~/field_observations_avant.csv ~/field_observations_apres.csv}
print {diff ~/field_observations_struct_measures_avant.csv ~/field_observations_struct_measures_apres.csv}
;}}}
] ;}}}

; Synchronize oruxmaps tracklogs, optionally: ;/*{{{*/ } } }
; TODO get rid of VIEW functions calls
if confirm {Synchronize oruxmaps tracklogs?} [
	print "Synchronizing oruxmaps tracklogs"
	alert {locate where android device is mounted, pickup "oruxmaps" subdirectory}
	unless DEBUG [ dir_mount_oruxmaps_android: request-dir/title/dir {locate oruxmaps where android device is located, choose "oruxmaps" subdirectory} dir_mount_oruxmaps_android ]
	alert {locate the local directory where oruxmaps tracks data is (or will be) replicated}
	unless DEBUG [ dir_oruxmaps_local:         request-dir/title/dir {locate local directory for replication of geolpda data}                        dir_oruxmaps_local         ]
	print rejoin ["Mount directory of OruxMaps android device: " tab tab dir_mount_oruxmaps_android newline "Local directory for oruxmaps data replication: " tab dir_oruxmaps_local]
	unless DEBUG [ if ( confirm "synchronize oruxmaps tracklogs?" ) [ synchronize_oruxmaps_tracklogs ] ]
]

;/*}}}*/
; Finished.

; Generate a report using gll_geolpda_report_generator.r ?
if confirm {Generate report using gll_geolpda_report_generator.r using data just imported?} [
	times: copy []
	foreach o geolpda_observations [
		append times o/3
	]
	sort times
	date_start: epoch_ms_to_date (first times)
	date_end:   epoch_ms_to_date (last  times)
	flag_create_tec_files: true
	do load to-file system/options/home/geolllibre/gll_geolpda_report_generator.r 
]

; Finished.

; à la fin, faire: 
;call rejoin ["jmtpfs " dir]
;fusermount -u /mnt/galaxy1

