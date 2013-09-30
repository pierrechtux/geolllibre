rebol [ ;{{{ } } }
	Title:   "User Interface, rights management of bdexplo database"
	Name:    gll_bdexplo_ui_rights_managt.r
	Version: 0.0.1
	Date:    
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
	History: [
]	]
;}}}

do load to-file system/options/home/bin/gll_routines.r	; Récupération des routines (et des préférences) et connexion à la base


schemas: run_query "SELECT DISTINCT schemaname FROM pg_tables WHERE tableowner <> 'postgres';"  ; ORDER BY schemaname;
roles:   run_query "SELECT rolname FROM pg_roles;"
tables:	 run_query "SELECT DISTINCT tablename FROM pg_tables WHERE tablename <> 'postgres';"


ui_rights_management: [ ; {{{ } } }
	h1 "GeolLLibre - exploration database bdexplo"
	h1 rejoin 	["Gestion des droits pour les tables de la base " 
			dbname " sur le serveur " dbhost]
	guide
	h2 "Schemas:"
	schema_list: text-list blue 100x100 data (schemas) [
		print value
		tables:	 run_query rejoin ["SELECT DISTINCT tablename FROM pg_tables WHERE tablename <> 'postgres' AND schemaname = '" value "' ;"]
		tables_list/data: tables
		show tables_list
	]
	return
	h2 "Tables"
	tables_list: text-list black 100x100 data (tables) [
		
	]

	return
	h2 "Roles:"
	roles_list: text-list blue 100x100 data (roles) [
		print value
	]
	;choice ["1" "2" "3"]

	btn #"Q" "Quit"  [unview halt]		; halt is softer than quit: it allows 
					; the rebol console to remain open, 
					; in case there is something useful.
]

view layout ui_rights_management
;}}}

; Pour déboguer le VID:
; do %~/autan/rebol/telech/VID-Livecoding/RealTime-VID-demo.r

