#!/usr/bin/rebol -qs
rebol []/*{{{*/ } } }
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

	cmd: rejoin [{echo "\dt+ public.} t {" | psql -X -d bdexplo -H} ]
	print cmd
	tt: copy ""
	err: copy ""
	call/wait/output/error cmd tt err
	append output tt
	append output newline

	append output "<p>Structure:</p>"
	cmd: rejoin [{echo "\d+ public.} t {" | psql -X -d bdexplo -H} ]
	print cmd
	tt: copy ""
	err: copy ""
	call/wait/output/error cmd tt err
	append output rejoin [newline tt "</p>" newline]

	append output "<p>Extrait:</p>"
	cmd: rejoin [{echo "SELECT * FROM public.} t { WHERE opid IN(11, 18) ORDER BY 1, 2, 3 LIMIT 10;" | psql -X -d bdexplo -H} ]
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
;/*}}}*/


