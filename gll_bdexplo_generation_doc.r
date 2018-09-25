#!/usr/bin/rebol -qs
rebol	[
	Title:   "Generation of a HTML documentation from bdexplo database"
	Name:    gll_bdexplo_generation_doc.r
	Version: 0.0.1
	Date:    "26-Sep-2013/15:08:19+2:00"
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
	Description: {
	}
	History: [
	]
]

do load to-file system/options/home/bin/gll_routines.r	; Récupération des routines (et des préférences)
connection_db						; connection à la base
tables: run_query "SELECT tablename FROM pg_tables WHERE schemaname = 'public' AND tableowner <> 'postgres';"
sort tables

;tables: [["ancient_workings"] ["baselines"] ["dh_collars"] ["dh_core_boxes"]] ;DEBUG
;en-tête html:{{{ } } }
output: copy {<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
 <head>
  <style type="text/css">
   div {
    overflow:auto; max-height:200px;
    border: 1px solid; margin: 1px; padding: 10px; width:90%;}
   img {
    border: 1px solid}
   body { counter-reset: chapter; }
   h1:before { 
          content: counter(chapter) ". ";
       counter-increment: chapter;
   }
   h1 {    counter-reset: section; }
   h2:before { 
       content: counter(chapter) "." counter(section) ". ";
       counter-increment: section;
   }
   h2 {    counter-reset: sssection; }
   h3:before { 
       content: counter(chapter) "." counter(section) "." counter(sssection) ". ";
       counter-increment: sssection;
   }
  </style>
  <title>
   BDEXPLO
  </title>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <!--iso-8859-1-->
 </head>
<body>
}
;}}}
append output "<h1>Bdexplo: documentation automatique</h1>"
foreach t tables [ ;{{{ } } }
	append output rejoin [newline "<h2>" t "</h2>" newline]

	cmd: rejoin [{echo "\dt+ public.} t {" | psql -X -h } dbhost { -p } dbport { -U } user { -d } dbname { -H} ]
	print cmd
	tt: copy ""
	err: copy ""
	call/wait/output/error cmd tt err
	append output tt
	append output newline

	append output "<p>Structure:</p>"
	cmd: rejoin [{echo "\d+ public.} t {" | psql -X -h } dbhost { -p } dbport { -U } user { -d } dbname { -H} ]
	print cmd
	tt: copy ""
	err: copy ""
	call/wait/output/error cmd tt err
	append output rejoin [newline tt "</p>" newline]

	append output "<p>Extrait:</p>"
	cmd: rejoin [{echo "SELECT * FROM public.} t { WHERE opid IN(11, 18) ORDER BY 1, 2, 3 LIMIT 10;" | psql -X -h } dbhost { -p } dbport { -U } user { -d } dbname { -H} ]
	print cmd
	tt: copy ""
	err: copy ""
	call/wait/output/error cmd tt err
	append output rejoin [newline tt "</p>" newline]
	];}}}
append output rejoin [newline "</body></html>"]
;print output
write %tt.html output
;browse %tt.html


