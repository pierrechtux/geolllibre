#!/usr/bin/rebol_core -qs
REBOL [;{{{ } } }
	Title:   "Gets information from GeolPDA android device, and uploads it to a database"
	Date:    == 22-Oct-2013/17:23:33+2:00
	Version: 0.0.0 
	Purpose: {
	}
	History: [
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
];}}}

DEBUG: false
; initialisation: ;{{{ } } }
if error? try [						; Récupération des routines (et des préférences) et connexion à la base
if error? try [						; Récupération des routines (et des préférences) et connexion à la base
do load to-file system/options/home/bin/gll_routines.r	; soit depuis ~/bin
] [
do load to-file %gll_routines.r				; ou sinon là où se trouve le script présent
]
] [
do load to-file system/options/home/geolllibre/gll_routines.r		; ou sinon dans ~/geolllibre
]

;}}}
; functions, libraries: {{{ } } }
synchronize_geolpda: does [
	; TODO: make this platform-independent:
	; as is, it will /only work on a platform where rsync is installed 
	; and in the $PATH
	print "Synchronization process..."
	cmd: rejoin [{rsync --inplace -auv --del --exclude="tmp/" } dir_mount_geolpda_android { } dir_geolpda_local ]
	;rsync --inplace -auv --del --exclude="tmp/" /mnt/galaxy1/geolpda/ geolpda/android_cp/geolpda/
	print rejoin["Running " cmd]
	tt:  copy ""
	err: copy ""
	call/wait/output/error cmd tt err
	print tt
]

; Library to access sqlite geolpda database:
do %~/rebol/library/scripts/btn-sqlite.r
;}}}

; First, connect geolpda android device, copy to local directory:{{{ } } }
; default directories are stored in .gll_preferences

; Get the user to properly mount the android device:
alert "Mount android device: connect android device containing geolpda; then press Enter when device properly connected"
; Get the location where it is mounted (unless DEBUG is on):
alert {locate where android device is mounted, pick up "geolpda" subdirectory}
unless DEBUG [ dir_mount_geolpda_android: request-dir/title/dir {locate geolpda where android device is located, choose "geolpda" subdirectory} dir_mount_geolpda_android ]

; Get the location of the local image of geolpda data (unless DEBUG is on):
alert {now locate the local directory where geolpda data is (or will be) replicated}
unless DEBUG [ dir_geolpda_local:         request-dir/title/dir {locate local directory for replication of geolpda data}                        dir_geolpda_local         ]

print rejoin ["Mount directory of GeolPDA android device: " tab tab dir_mount_geolpda_android newline "Local directory for GeolPDA data replication: " tab dir_geolpda_local]

;}}}
; Synchronize android device to local filesystem, if agreed (and not DEBUG):{{{ } } }
unless DEBUG [ if ( confirm "synchronize geolpda data?" ) [ synchronize_geolpda ] ]
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
run_query "SELECT * FROM poi"
	; DEBUG TODO remove ça
	; write %qq1 sql_result_csv

; Comparison of field list: to be sure that the table structure matches the 
; one used at the time of coding (23-Oct-2013/9:24:01+2:00)
unless sql_result_fields = ["_id" "poiname" "poitime" "elevation" "poilat" "poilon" "photourl" "audiourl" "note"] [
	print "ATTENTION! field names differ from geolpda reference implementation"
	print "Error, halting"
	halt
]
geolpda_observations:        copy sql_result
geolpda_observations_fields: copy sql_result_fields
print rejoin [tab length? geolpda_observations " records in observations table"]

; To check if a record was previously inserted in the database, make a copy of identifiers:
run_query "SELECT poiname, _id, poitime FROM poi"
	; DEBUG TODO remove ça
	; write %qq2 sql_result_csv

tt_observations_in_geolpda: copy sql_result
;}}}
; orientations:{{{ } } }
run_query "SELECT * FROM orientation"
; Comparison of field list: to be sure that the table structure matches the 
; one used at the time of coding (23-Oct-2013/9:24:01+2:00)
unless sql_result_fields = ["_id" "poi_id" "orientationtype" "rot1" "rot2" "rot3" "rot4" "rot5" "rot6" "rot7" "rot8" "rot9" "v1" "v2" "v3"] [
	print "ATTENTION! field names differ from geolpda reference implementation"
	print "Error, halting"
	halt
]
; If we reached here, we are ok; now, it is necessary to also fetch the full id from observations by JOINing:
run_query "SELECT poiname, orientation._id, poi_id, orientationtype, rot1, rot2, rot3, rot4, rot5, rot6, rot7, rot8, rot9, v1, v2, v3 FROM orientation LEFT JOIN poi ON poi._id = orientation.poi_id"
geolpda_orientations: 			copy sql_result
geolpda_orientations_fields: 	copy sql_result_fields
print rejoin [tab length? geolpda_orientations " records in orientations measurements table"]
	; DEBUG TODO remove ça
	; write %qq3 sql_result_csv

; To check if a record was previously inserted in the database, make a copy of identifiers:
;run_query "SELECT poi_id FROM orientation"
; =>    ah, no: in final database, the whole id is mentioned, not the index;
;       so we must JOIN the two tables:
run_query "SELECT poiname, count(*) FROM orientation LEFT JOIN poi ON poi._id = orientation.poi_id GROUP BY poiname"
tt_orientations_in_geolpda: copy sql_result

	; DEBUG TODO remove ça
	; write %qq4 sql_result_csv

; The sqlite driver apparently returns strings instead of numerics:
; conversion to decimal! (same as value returned by postgresql driver), 
; to allow comparisons, later on:
tt: copy []
foreach v tt_orientations_in_geolpda [
	append/only tt compose [(v/1) (to-decimal v/2)]
]
tt_orientations_in_geolpda: copy tt
;}}}
;}}}

; Open destination database:{{{ } } }
connection_db
print rejoin [newline "Open database " dbname " on host " dbhost]

; => careful: now DB points to the default database, not to the geolpda any more.
insert db "BEGIN TRANSACTION;"
run_query "SELECT obs_id, waypoint_name, timestamp_epoch_ms FROM field_observations"
	; DEBUG TODO remove ça
	; write %qq5 sql_result_csv

tt_observations_already_in_db: copy sql_result
print rejoin [tab length? tt_observations_already_in_db " records in field_observations table"]

run_query "SELECT obs_id, count(*) FROM field_observations_struct_measures GROUP BY obs_id"
tt_orientations_already_in_db: copy sql_result
	; DEBUG TODO remove ça
	; write %qq6 sql_result_csv


;}}}
; Remove records from dataset from geolpda which are already in database: {{{ } } }
; observations: {{{ } } }
print rejoin [newline "Remove records from dataset from geolpda which are already in database:" newline
tab "- observations:"
tab length? tt_observations_in_geolpda " records in GeolPDA dataset,"
tab length? tt_observations_already_in_db " records in field_observations table:"]

; Strange: a trailing ".0" appeared at the end of the epoch timestamp, from the
; postgresql database side, even though the field type is a bigint:
;   =>  figured out: rebol saw this bigint as a decimal! ; but in
;       the geolpda database, the epoch timestamp is returned as 
;       a string!
; workaround: suppress these ".0":
tt: copy []
foreach i tt_observations_already_in_db [
	either (none? i/3) [
		x: none								][
		x: replace to-string i/3 ".0" ""	]
	;print rejoin [x i/3 type? i/3 none? i/3]
	append/only tt to-block reduce [i/1 i/2 x]
]
tt_observations_already_in_db: copy tt
to_del: intersect tt_observations_in_geolpda tt_observations_already_in_db
print rejoin [tab tab length? to_del " common records (sharing same values for (obs_id, waypoint_name, timestamp_epoch_ms) fields): " newline tab tab "=> remove from geolpda dataset: ..."]
unless ((length? to_del) = 0) [
	observations_new: exclude tt_observations_in_geolpda tt_observations_already_in_db
	tt: copy []
	foreach o geolpda_observations [
		foreach n observations_new [
			if (all [(n/1 = o/2) (n/2 = o/1) (n/3 = o/3)]) [ ; record to be kept
				append/only tt o
				break
	]	]	]
	geolpda_observations: copy tt
]
print rejoin [tab tab length? geolpda_observations " records remaining to be INSERTed into database " dbname " on " dbhost "."]
;}}}

; orientations: {{{ } } }
print rejoin [	tab "- orientations:" newline 
				tab length? tt_orientations_in_geolpda " records in GeolPDA dataset,"
				tab length? tt_orientations_already_in_db " records in field_observations_struct_measures table:"]

tt_orientations_in_geolpda: 	unique tt_orientations_in_geolpda
tt_orientations_already_in_db: 	unique tt_orientations_already_in_db	; (normally, this is useless, the query was already GROUPed BY => kept just in case query would change, some day...)
to_del: intersect tt_orientations_in_geolpda tt_orientations_already_in_db
;write %~/qa newline
;write %~/qb newline
;foreach i tt_orientations_in_geolpda 	[	write/append %~/qa rejoin [i/1 " " i/2 newline] ]
;foreach i tt_orientations_already_in_db [	write/append %~/qb rejoin [i/1 " " i/2 newline] ]
;vimdiff qa qb

print rejoin [	tab tab length? to_del " common records (sharing same values for (obs_id, waypoint_name, timestamp_epoch_ms) fields): " 
				newline tab tab "=> remove from dataset..."]

unless ((length? to_del) = 0) [
	orientations_new: exclude tt_orientations_in_geolpda tt_orientations_already_in_db
	tt: copy []
	foreach o geolpda_orientations [
		foreach n orientations_new [
			if (all [(n/1 = o/2) (n/2 = o/1) (n/3 = o/3)]) [
				; record to be kept
				append/only tt o
				break
	]	]	]
	geolpda_orientations: copy tt
]
print rejoin [tab tab length? geolpda_orientations " records to be INSERTed into database " dbname " on " dbhost "."]
;}}}
;}}}
; Generate a new datasource: TODO: {{{ } } }
datasource: 9999    ; bidon; TODO generate a new datasource record in lex_datasource
;}}}

;####################################################################{ {{
; ###### data from geolpda is now in tables:
;   geolpda_observations
;   geolpda_orientations
; check recordsets:
;   tt_observations_in_geolpda       <------------------+ok
;   tt_orientations_in_geolpda            <-------+ok   |
; ###### check recordsets from database:          |     |
;   tt_observations_already_in_db     <-----------)-----+
;   tt_orientations_already_in_db           <-----+

;   /tt_observations_in_geolpda\|tt_observations_already_in_db
;   /tt_orientations_in_geolpda\|tt_orientations_already_in_db

;####################################################################
;/*} }}*/

; Put data:{{{ } } }
; observations:{{{ } } }
; build a SQL INSERT statement:
sql_string: copy ""
; if there is anything to add:
if (length? geolpda_observations) > 0 [
	; continue the SQL INSERT statement:
	_: {, } ; just to save a few keystrokes to the coder... and to make REJOIN code a bit more readable; variable was called SEP for SEParator; renamed to _ for clarity/brevity
	sql_string:  {INSERT INTO public.field_observations (opid,year,obs_id,date,waypoint_name,x,y,z,description,code_litho,code_unit,srid,geologist,icon_descr,comments,sample_id,datasource,photos,audio,timestamp_epoch_ms) VALUES }
	foreach o geolpda_observations [
		; assign temporary variables with field names: (bof, no){{{ } } }
		;i: 0
		;foreach f geolpda_observations_fields [
		;	++ i
		;	print rejoin [f ": "]
		;	print o/:i
		;] ; }}}
		; check if record already in database or not: by default, we do not update
		; data in the database, assuming that data inside the database could have
		; changed, corrected, updated, etc. since it was imported from GeolPDA.
		; DEBUG o: geolpda_observations/4
		tmp: to-date epoch-to-date (to-integer ((to-decimal o/3) / 1000))
		append sql_string rejoin [newline {(} opid _ tmp/year _ {'} o/2 {'} _ {'} tmp/year "-" pad tmp/month 2 "-" pad tmp/day 2 {'} _ {'} o/1 {'} _ o/6 _ o/5 _ o/4 _ {'} o/9 {'} _ {NULL, NULL, 4326} _ {'} geologist {'} _ {NULL, NULL, NULL, NULL, } {'} o/7 {'} _ {'} o/8 {'} _ o/3 {),}]
	]
	sql_string: rejoin [copy/part sql_string ((length? sql_string) - 1) ";"]
]
;DEBUG editor sql_string

print "SQL statement to be run:"
print copy/part sql_string 300
print "..."


; DEBUG vérif:
; run_query "SELECT * FROM public.field_observations"

;write %azeq  newline
;ww: copy sql_result
;foreach r ww [
;	write/append %azeq rejoin [r newline]
;]
;}}}
; orientations: {{{ } } }
; if anything to add:
if (length? geolpda_orientations) > 0 [
	; continue the SQL INSERT statement:
		;\pset format unaligned
		;\pset fieldsep ','
		;SELECT * FROM public.field_observations_struct_measures LIMIT 0;
		;opid,obs_id,measure_type,structure_type,north_ref,direction,dip,dip_quadrant,pitch,pitch_quadrant,movement,valid,comments,numauto,db_update_timestamp,username,datasource,rotation_matrix,geolpda_id,geolpda_poi_id

	; DEBUG 
	; o: geolpda_orientations/1
	; geolpda_orientations_fields
	; == ["poiname" "_id" "poi_id" "orientationtype" "rot1" "rot2" "rot3" "rot4" "rot5" "rot6" "rot7" "rot8" "rot9" "v1" "v2" "v3"]
	;   m/       1     2        3                 4      5      6      7      8      9     10     11     12     13   14   15   16
	;for i 5 13 1 [prin rejoin [" m/" to-string i { " "}]]
	; m/5 " " m/6 " " m/7 " " m/8 " " m/9 " " m/10 " " m/11 " " m/12 " " m/13 " ">> 
	append sql_string rejoin [newline newline {INSERT INTO public.field_observations_struct_measures (opid,    obs_id     , measure_type , north_ref ,  datasource ,        rotation_matrix                                                                ,   geolpda_id , geolpda_poi_id   ) VALUES } ]
	foreach m geolpda_orientations [
		append sql_string rejoin [newline {(}                                               		  opid _ {'} m/1 {'}  _  {'} m/4 {'} _    {'Nm'} _  datasource _   {'[}  m/5 " " m/6 " " m/7 " " m/8 " " m/9 " " m/10 " " m/11 " " m/12 " " m/13  {]'} _       m/2    _      m/3        {),}        ]
	]
	sql_string: rejoin [copy/part sql_string ((length? sql_string) - 1) ";"]
			; DEBUG 
			;editor sql_string
			;sql_string: copy ""

			;write %azeq sql_string
			; DEBUG
]

print "SQL statement to be run:"
print copy/part sql_string 300
print "..."

insert db sql_string
print "Done..."
insert db "COMMIT;"

; DEBUG vérif:
run_query "SELECT * FROM public.field_observations"
write %azeq  newline
ww: copy sql_result
foreach r ww [
	write/append %azeq rejoin [mold r newline]
]

run_query "SELECT * FROM public.field_observations_struct_measures"
write/lines %aqez sql_result_csv
sql_result
 %azeq  newline
ww: copy sql_result
foreach r ww [
	write/append %azeq rejoin [mold r newline]
]


;}}}
;}}}

; Play INSERT queries on database and COMMIT: {{{ } } }
insert db sql_string
print "Done..."
insert db "COMMIT;"

print "commited => end."

;}}}
; Finished.