#!/usr/bin/rebol -qs
rebol	[
	Title:   "Generation of a HTML report from bdexplo database, with various check queries"
	Name:    gll_bdexplo_generation_checks_vapas.r
	Version: 1.0.0
	Date:    "5-Aug-2013/17:53:46"
	Author:  "Pierre Chevalier"
	Licence: {
		  Copyright 2013 Pierre Chevalier <pierrechevaliergeol@free.fr>
		  
		  This program is free software; you can redistribute it and/or modify
		  it under the terms of the GNU General Public License as published by
		  the Free Software Foundation; either version 2 of the License, or
		  (at your option) any later version.
		  
		  This program is distributed in the hope that it will be useful,
		  but WITHOUT ANY WARRANTY; without even the implied warranty of
		  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		  GNU General Public License for more details.
		  
		  You should have received a copy of the GNU General Public License
		  along with this program; if not, write to the Free Software
		  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
		  MA 02110-1301, USA.
		}
	Desctiption: {
	Ce script va chercher un fichier contenant une série de requêtes SQL:
	    bdexplo_verifs.sql
	puis génère une sortie en .html reprenant les sorties des requêtes.
	Le fichier des requêtes est structuré comme suit, à base de lignes commençant par --#:
	    --#BEGIN{{{                                               <= tout ce qui est avant cette ligne est ignoré
	    --#+Check drill holes and trenches data
	    --#+Titre de niveau 1
	    --commentaire quelconque                                  <= commentaire n'apparaissant pas
	                                                              <= ligne vide avant chaque élément
	    --#+Titre de niveau 1
	
	    --#++Titre de niveau 2
	    --#Texte qui sera affiché sur la sortie
	    SELECT split_part(id, '_', 1) AS id_left_part,            <= requête SQL, peut s'étager sur 
	    location, count(*) AS nb_records FROM collars;               plusieurs lignes
	    
	    --#END}}}                                                 <= tout ce qui est après la ligne précédente est ignoré.
	}
	History: [
	1.0.0 [	{Première version en python}]
	1.1.0 [ 4-Dec-2009 {
		Passé en rebol generation_rapport_checks_bdexplo_vapas_from_bdexplo_verifs.r Pierre Chevalier, 4 décembre 2009, Ste-Barbe}
		]
	1.1.1 [10-Sep-2013/23:38:42+2:00 {
		version opérationnelle, tests en cours}]
	1.1.2 [15-Sep-2013               {
		version opérationnelle, tests au quai}]
	]
]

;TOUT ÇA ROULE: {{{ } } }
; initialisation: {{{ } } }
do load to-file system/options/home/bin/gll_routines.r	; Récupération des routines (et des préférences)
change-dir system/options/path				; on se met dans le répertoire courant (...)
connection_db						; connection à la base
if error? try [ type? journal_sql ] [journal_sql: [] ]	; si pas de journal des instructions SQL, on en crée un vide

; début de transaction:
insert db "BEGIN TRANSACTION;"
;}}}

runQueryToReport: func ["Prend du SQL en entrée, sort une boîte en .html avec le résultat de la requête passée à psql" sql_text] [ ;{{{ } } }
	sortie: rejoin ["<div><i><small>" sql_text "</small></i><p><pre>" newline]
	append sortie do_psql sql_text
	append sortie "</pre></div><p>"
	;append output sortie
	return sortie
	] ;}}}
;test: {{{ } } }

;comment [
;a: runQueryToReport "SELECT * FROM public.dh_collars LIMIT 2;"
;write %tt a
;print a
;<div><i><small>SELECT * FROM public.dh_collars LIMIT 2;</small></i><p><pre>
;  id   | shid |  location   |  profile  | srid  |     x      |     y      |    z    | azim_ng | azim_nm | dip_hz | dh_type | date_start | contractor | geologist | length | nb_samples |          comments           | completed | datasource | numauto | date_completed | opid |   purpose   |  x_local  | y_local  | z_local | accusum | id_pject | x_pject | y_pject | z_pject | topo_survey_type |    db_update_timestamp     | username 
;-------+------+-------------+-----------+-------+------------+------------+---------+---------+---------+--------+---------+------------+------------+-----------+--------+------------+-----------------------------+-----------+------------+---------+----------------+------+-------------+-----------+----------+---------+---------+----------+---------+---------+---------+------------------+----------------------------+----------
; PJ623 |      | MONT_ITY    | mtity--01 | 32629 | 597951.900 | 759348.100 | 280.000 |  135.00 |         |  60.00 | DD      |            |            |           | 260.00 |            |                             | f         | 1050       |   95500 |                |   18 | delineation |           |          |         |         | PJ623    |         |         |         |                  | 2013-08-17 21:38:01.337625 | pierre
; 240_4 |      | FLOTOUO_ZIA |           | 32629 | 598299.627 | 759930.256 | 243.215 |    0.00 |         |   0.00 | TR      |            |            |           | 118.00 |            | Date on csv file; preex=240 | t         | 700        |   17638 | 2002-10-28     |   11 | GC          | 20418.750 | 9557.000 | 234.440 |  370.46 |          |         |         |         |                  | 2013-08-17 21:38:01.337625 | pierre
;(2 lignes)
;
;</pre></div><p>
;];}}}

printTxt: func ["Renvoie un texte tout bêtement entre deux balises <p>" text] [ ;{{{ } } }
	return rejoin ["<p>" text "</p>"]
	] ;}}}

entete: func ["Écrit l'en-tête du fichier .html, avec les styles, le titre, etc."] [ ;{{{ } } }
	out: copy {
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
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
}
	append out run_query "SELECT DISTINCT operation || ' ' || full_name || ' ' || operator FROM operations JOIN operation_active ON operations.opid = operation_active.opid;"
	append out { -- exploration database consistency checks</title>
  <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">
  <!--iso-8859-1-->
 </head>
<body>}
	;#<!--
	;#<p><pre>
	;#+--------------------------------------------------------------------------------+
	;#|                                                                                |
	;#|      Exploration database                                                      |
	;#|  Set of queries for checks and reporting                                       |
	;#|                                                                                |
	;#+--------------------------------------------------------------------------------+
	;#</pre></p>
	;#-->
	append out rejoin [newline "<div><em><center>"]
	append out run_query "SELECT DISTINCT operation FROM operations JOIN operation_active ON operations.opid = operation_active.opid;"
	append out { exploration database<br>Results of set of queries, checks and reporting<br>}
	opids: run_query "SELECT opid FROM operation_active ORDER BY opid;"
	append out "(opid: "
	foreach opid opids [
		append out rejoin [opid " "]
		]
	out: trim_last_char out
	append out ")"
	append out {
<pre>
###########################################################################
##          ____  ___/_ ____  __   __   __   _()____   ____  _____       ##
##         / ___\/ ___// _  |/ /  / /  / /  /  _/ _ \ / __ \/ ___/       ##
##        / /___/ /_  / / | / /  / /  / /   / // /_/_/ /_/ / /_          ##
##       / /_/ / /___|  \/ / /__/ /__/ /___/ // /_/ / _, _/ /___         ##
##       \____/_____/ \___/_____/___/_____/__/_____/_/ |_/_____/         ##
##                                                                       ##
###########################################################################
</pre>
</center></em></div>}
	append out "<p><p><small>Report generated on "
	append out now
	append out "</small></p>"
	return out
	] ;#}}}

printImg: func [image] [ ;{{{ } } }
	;Met l'image passée en argument dans le .html.
	print rejoin {<center><img alt="} image {" src="} image {"/></center>}
	] ;}}}

printGraph: func [var table] [ ;{{{ } } }
	;Prend une requête en entrée qui doit renvoyer une variable,
	;appelle gnuplot en passant par un .csv, et renvoie une image.
	sql_text: rejoin ["SELECT " var " FROM " table]
	;datafile = sql_text.replace(" ", "_") + ".dat"
	datafile: rejoin [(replace sql_text " " "_") ".dat"]
	;img_filename = "plots" + os.sep + "tmp_graph_select_" + var + "_from_" + table + ".png"
	img_filename: rejoin ["plots/tmp_graph_select_" var "_from_" table ".png"]
	ligne_cmd1: rejoin [{'echo "}  sql_text {;" | psql -X -d} dbname { -h } dbhost {  | sed -e 's/,/ /g' | tail -n +3 | head -n -2 > } datafile]
	ligne_cmd2: {echo "
plot '} datafile {' w p
set ylabel '} var {'
set term png
set output '} img_filename {'
replot
" | gnuplot}
	;sys.stdout.flush()
	call  ligne_cmd1
	;sys.stdout.flush()
	call ligne_cmd2
	printTxt rejoin ["Plot of ["  sql_text + "]:"]
	printImg img_filename
	] ;}}}
;{{{ } } }
;#echo "
;#plot 'au_dupl.dat' w p
;#ideal(x) = x
;#replot ideal(x) w l; set xlabel 'Au not duplicate'
;#set ylabel 'Au duplicate'
;#set xrange [0:100]
;#set yrange [0:100]
;#set xtics 10; set ytics 10
;#set grid xtics
;#set grid ytics
;#set term png
;#set output 'cross_plot_au_dup_100.png'
;#replot
;#" | gnuplot
;#printTxt "Cross-plot up to 100 g/t:"
;#printImg "cross_plot_au_dup_100.png"
;#}}}

printGraph_et_voit: func [var table] [ ;{{{ } } }
	;Juste une fonction pour vite fait, grapher une variable et voir de suite le résultat
	printGraph var table
	img_filename: rejoin ["plots" os.sep "tmp_graph_select_" var "_from_" table ".png"]
	ligne_cmd: rejoin ["geeqie " img_filename]
	;sys.stdout.flush()
	call ligne_cmd
	] ;}}}

fin: does [ ;{{{ } } }
	;#la date
	out: copy "<p><small>Report generation finished at:"
	append out now
	append out "</small></p>"
	append out "</body></html>"
	] ;}}}

ensb_requete: make object! [ ;class ensb_requete: ;#{{{ } } }
	;"ensemble requete, avec un numero, un niveau hierarchique, un titre, un texte de requete"
	niveau: 0
	titre: ""
	commentaire: ""
	sql: ""
	] ;}}}


;# +-------------------------------------------+
;# |       fin de la définition des            |
;# |        fonctions, exécution               |
;# +-------------------------------------------+

;le gros texte en sortie (plutôt que de faire des print): variable sortie_generale
sortie_generale: copy ""
append sortie_generale entete

;#printGraph("length", "dh_collars")	#un exemple pour envoyer un plot d'une variable

;#d'abord, si le schéma pierre_a_part est là, le renommer:
;call {echo "ALTER SCHEMA pierre_a_part RENAME TO pierre; | psql -X bdexplo}
;do_psql "ALTER SCHEMA pierre_a_part RENAME TO pierre;"

;#ouverture du fichier sql commenté avec les balises comme il faut
fichier_requetes: rejoin [working_directory "bdexplo_verifs.sql"]
if error? try [chk_file_exists fichier_requetes] [
	print rejoin ["Error, check query file " fichier_requetes " not found. Cannot continue."]
	quit]
print rejoin ["Query file open: " fichier_requetes]
ensemble_requetes: read/lines fichier_requetes
print rejoin [" => " length? ensemble_requetes "lines..."]
;-----------------------}}}
;############TESTS############# /* DEBUG
;ensemble_requetes: read/lines rejoin [working_directory "bdexplo_verifs_tests.sql"]
;length? ensemble_requetes
;== 35
;############TESTS############# */ DEBUG
;fabrication d'un block! avec les requêtes:{{{ } } }
; on met dans tt ce qui est entre le début et la fin:
tt: {}
parse ensemble_requetes [ any [thru  "--#BEGIN{{{"	; commençons par parser en ne gardant que ce qui est entre les balises
	copy tt
	to "--#END}}}"] to end]
; non: {{{
; on refait une chaîne ensemble_requetes avec des sauts de ligne, comme l'ensemble_requetes original:
;ensemble_requetes: copy {}
;foreach i tt [append ensemble_requetes rejoin [i newline]]
; on a maintenant ensemble_requetes qui ne comprend que ce qui est entre les balises de début et fin.
; }}}
; plutôt:
; on refait un block! ensemble_requetes qui ne comprend que ce qui est entre les balises de début et fin.
ensemble_requetes: copy []
foreach i tt [append ensemble_requetes i]
length? ensemble_requetes
;== 20

;ligne: copy "" ;pour rien
;ensemble_requetes: head ensemble_requetes; pareil: zapper, une fois que touroule
;--}}}


; je boucle sur le block!:
lit_prochaine_ligne: does [ ;{{{ } } }
	if alafin [return false]
	ligne: to-string copy/part ensemble_requetes 1
	ensemble_requetes: next ensemble_requetes
	num_ligne: num_ligne + 1
	;?? num_ligne	; DEBUG
	;?? ligne	; DEBUG
	;if num_ligne = 18 [print "dans lit_prochaine_ligne" halt]	; DEBUG
	;print "touche pour continuer" ; DEBUG
	;input
	return true
];}}}
alafin: does [ ; {{{ } } }
	if/else (tail? ensemble_requetes) [; #est-on à la fin?
		append requetes requete		; on est à la fin
		return true
	] [
		return false			; c'est pas fini
	]
]
;return tail? ensemble_requetes
;] ;((substring ligne 1 9) = "--#END}}}")   ;(il y avait aussi: and (ligne <> "") => ? jarreté)
requetes: copy []
requete:  copy [] ; juste pour éviter une erreur lors du premier appel de alafin
num_ligne: 0
continue: does [throw 'continue] ;suivant conseil Nenad, pour mimer le comportement d'un continue dans une boucle
while [not (alafin)] [ catch [ ;{{{ } } }
	;#on initie un objet ensemble-requête:
	requete: make ensb_requete []
	lit_prochaine_ligne
	; on cherche un début marqué par "--#":
	while [(substring ligne 1 3) <> "--#"] [
		lit_prochaine_ligne
		if alafin [break]
	]
	;#on lit d'abord le titre
	requete/titre: (copy at ligne 4)
	;#de quel niveau?
	niveau: 0
	;#(commentaire){{{ } } } 
	;# au lieu de faire le niveau avec des +, ++, on va prendre la 
	;# convention de vim, fort pratique:
	;# --3 accolades  pour bloc de niveau n
	;#avant:
	;#while requete.titre[0] == "+":
	;#	niveau = niveau + 1
	;#	requete.titre = requete.titre[1:len(requete.titre)]
	;#}}}
	if (parse requete/titre [3 "{" to end]) [ 	;} pour fermer...
		requete/titre: at requete/titre 4
		niveau: to-integer to-string first requete/titre  ;#on ne prend que des niveaux < 10, quand même!! donc niveau codé sur un caractère entier
		requete/titre: at requete/titre 2
	]
	requete/niveau: niveau
	;#lisons la ligne suivante
	lit_prochaine_ligne
	if ligne = "" [
		;#ligne vide, ce n'était qu'un simple titre, sans requête, on passe à la suite
        	append requetes requete
	        continue
	]
	if ((substring ligne 1 3) = "--#") [
		;#une ligne servant de texte à afficher
	        requete/commentaire: at ligne 4
		lit_prochaine_ligne
	]
	if ((substring ligne 0 2) = "--") [
        	;#une ligne servant de commentaire n'ayant pas à être affiché
		lit_prochaine_ligne
	]
	if ligne = "" [
		;#ligne vide, ce n'était qu'un simple titre avec un commentaire, sans requête, on passe à la suite
		append requetes requete
		continue
	]
	;#le texte de la requête, on guette le ; final
	requete/sql: ligne
	while [not (find ligne ";")] [
		lit_prochaine_ligne
		append requete/sql rejoin [newline ligne]
	]
	append requetes requete
	if num_ligne = 18 [halt]	;DEBUG
	if alafin [break]
]] ;}}}



;#voilà, on a toutes nos requêtes dans une liste de requete, fermons le fichier
;fichier_requetes.close()

;#puis égrenons tout cela, en faisant sortir en html
;#d'abord, on fait un petit sommaire, après un préambule:
append sortie_generale rejoin [newline printTxt "Most queries listed here are designed to outline problems in the dataset. They should return zero records, meaning that the dataset is right." newline]
;#puis on défile les requêtes:
count: 0
total: length? requetes
foreach rq requetes [
	print rejoin ["Process #" count " of " total ":"]
	print rq/sql
	print "..."
	append sortie_generale rejoin [newline "<h"rq/niveau">" rq/titre "</h" rq/niveau ">" newline]
	if ((length? rq/commentaire) > 0) [append sortie_generale printTxt rq/commentaire]
	if ((length? rq/sql) > 0) [
		count: count + 1
		;#pour faire le .html complet, lourdingue:
		append sortie_generale runQueryToReport rq/sql
		
		;#pour faire un .html plus léger:
		;#runQueryToReport(rq.sql.replace(";", " LIMIT 100;"))
		
		append sortie_generale rejoin ["<p align=RIGHT><small><i>( query #" to-string count ") </i></small></p>"]
		]
	]

append sortie_generale fin

;#on remet le schéma pierre_a_part (c'est juste pour knoda):
;#os.system('echo "ALTER SCHEMA pierre RENAME TO pierre_a_part;" | psql bdexplo')
;#non...
;#si.......

; écrivons la sortie dans un fichier .html:
;write %ttt sortie_generale
fichier_sortie: "bdexplo_verifs"
operations: run_query "SELECT DISTINCT operation FROM operations JOIN operation_active ON operations.opid = operation_active.opid;"
foreach o operations [append fichier_sortie rejoin ["_" to-string o]]
append fichier_sortie "_"
;timestamp: replace/all replace/all replace/all to-string now "-" "_" "/" "_" ":" "_"
timestamp: replace/all rejoin [now/year "_" pad now/month 2 "_" pad now/day 2 "_" now/time] ":" "_"
append fichier_sortie timestamp
append fichier_sortie ".html"
fichier_sortie: to-file lowercase fichier_sortie
write fichier_sortie sortie_generale



; poubelle: {{{ } } }
;des tests divers de parse, pas réussis: {{{ } } }
; il faut en extraire les chapitres, 
;rule_chaptern: [thru "--#{{{" digit
;	copy p
;	to   "--#}}}" (append/only qq p)]
;
;
;qq: make block! []
;rule_paragraphe: [thru "--#{{{"
;	copy p
;	to   "--#}}}" (append/only qq p)]
;parse ttt [some rule_paragraphe]
;
;q: copy []
;t:{
;deb
;entre les deux
;fin
;deb autre chose fin
;}
;
;debfin: [thru "deb" copy tt to "fin" (append q tt)]
;rule: [any debfin]
;parse t rule


;paragraphe: copy ""
;parse to-string tt [
;	thru "--#^{^{^{"
;	copy paragraphe
;	to   "--#^}^}^}"]
;print paragraphe
;
;
;digit: charset [#"0" - #"9"]
;alpha: charset [#"A" - #"Z" #"a" - #"z"]
;alphanum: union alpha digit

;ttt: to-string tt
;ensemble_requetes: copy ""
;
;length? tt
;a: ""
;foreach t tt [append a t
;append a newline]
;length? a

;ensemble_requetes: copy tt
;
;
;ligne: copy ""
;num_ligne: 0
;requetes: copy []
; essai de parse, mais les règles semblent avoir changé entre ma doc de référence et la version actuelle: tampis, je fais du parse plus basique {{{
;digit: charset [#"0" - #"9"]	;digit: charset "0123456789"
;regles: {
;-- --#{{{nLes têtes d'ouvrages                          Titre de la requête, sur une seule ligne.
;--                                                      l'indentation /*en nombre de + au début*/
;--                                                      en n (après les -- et les accolades)
;--                                                      fait la hiérarchie
;--
;-- --#Liste des têtes de sondages et tranchées          Si second commentaire juste après la ligne de titre, 
;--                                                      texte à afficher.
;--                                                      Si ligne vide après la ligne de titre, le titre fait celui 
;--                                                      d'une rubrique, pas d'une requête.
;--
;-- --faudra peaufiner cette roquette                    si commentaire non diésé, commentaire off, ignoré
;--
;-- SELECT * FROM dh_collar;                             le SQL de la requête
;--                                                      etc.
;-- --#}}}                                               fin d'un paragraphe
;}
;tt: ""
;
;find ensemble_requetes "--#/{/{/{"
;parse ensemble_requetes [thru "--#/{/{/{" copy tt to "--#/}/}/}"]
;print tt
;
;
;}}}
;}}}
; sera probablement obsolète, avec le recours à parse: {{{ } } }
;comment [
;#on cherche le début:
; recherche de la première ligne débutant les requêtes: {{{ } } }
;while  [ligne <> "--#BEGIN{{{"] [	; (}}} juste pour pouvoir lire ce code sous vim)
;	lit_prochaine_ligne
;	] ;}}}
;];}}}
;;TODO remplacer tout ça par un parse astucieux: {{{ } } }
;continue: does [print "DEBUG: CONTINUE" throw 'continue] ;suivant conseil Nenad, pour mimer le comportement d'un continue dans une boucle
;; => non, le continue était là en python pour pallier l'absence de case, qui existe en rebol
;; => si, pas seulement...
;while [not alafin] [     ;#jusqu'à la fin:  	;#on initie un ensemble-requête
;print "DEBUG: DÉBUT BOUCLE WHILE"
;catch  [	; catch seulement pour le continue
;	print "DEBUG: DÉBUT CATCH"
;
;	;#on initie un objet ensemble-requête:
;	requete: make ensb_requete []
;	;#on lit une ligne:
;	lit_prochaine_ligne
;	;#cherchons le prochain tag --#:
;	while [(substring ligne 1 3) <> "--#"] [ lit_prochaine_ligne ]
;	print "DEBUG: trouvé un --#"
;	print ligne
;	print "DEBUG"
;	if alafin [break] ;#est-on à la fin? si oui, cassos
;	;#on lit d'abord le titre
;	requete/titre: (copy at ligne 4)
;	;#de quel niveau?
;	niveau: 0
;	;#{{{ } } }
;	;# au lieu de faire le niveau avec des +, ++, on va prendre la 
;	;# convention de vim, fort pratique:
;	;# --3 accolades  pour bloc de niveau n
;	;#avant:
;	;#while requete.titre[0] == "+":
;	;#	niveau = niveau + 1
;	;#	requete.titre = requete.titre[1:len(requete.titre)]
;	;#}}}
;	while [(substring requete/titre 0 3) = "{{{"] [ 					; (#}}}juste pour matcher les accolades, dans vim)
;		requete/titre: at requete/titre 4
;		niveau: to-integer to-string first requete/titre  ;#on ne prend que des niveaux < 10, quand même!! donc niveau codé sur un caractère entier
;		requete/titre: at requete/titre 2
;		]
;	requete/niveau: niveau
;	;#lisons la ligne suivante
;	lit_prochaine_ligne
;	if alafin [break]
;	;if (ligne == "\n"):
;	;			requetes.append(requete)
;	;	continue
;
;	;DEBUG
;	print ligne
;	print "stop? (o/n)"
;	a: input
;	if [a = "o"] [halt]
;	;DEBUG
;	;case [
;		((trim ligne) = "") [	;#ligne vide, ce n'était qu'un simple titre, sans requête, on passe à la suite
;			append requetes requete
;			print "DEBUG LIGNE VIDE"
;			;TODO équivalent de continue en rebol?
;			continue	;=> oui, en rebol3 => ach, pilote postgresql pas en rebol3... => continue marche comme une exception
;			;		;=> inutile avec case
;			]
;		((copy/part ligne 3) = "--#") [
;			;#une ligne servant de texte à afficher
;			print "DEBUG LIGNE TEXTE"
;			requete/commentaire: at ligne 3
;			lit_prochaine_ligne ]
;		((copy/part ligne 2) = "--") [
;			;#une ligne servant de commentaire n'ayant pas à être affiché
;			print "DEBUG LIGNE COMMENTAIRE PAS AFFICHÉ"
;			lit_prochaine_ligne ]
;		((trim ligne) = "") [
;			;#ligne vide, ce n'était qu'un simple titre avec un commentaire, sans requête, on passe à la suite
;			print "DEBUG LIGNE VIDE SIMPLE TITRE"
;			append requetes requete
;			;continue
;			]
;		]
;	;#le texte de la requête, on guette le ; final
;	requete/sql: ligne
;	;_____________JEANSUILA_______________
;	while [find ligne ";"] [	
;		lit_prochaine_ligne
;		append requete/sql ligne ]
;	append requetes requete
;	if alafin [break]
;	]
;}}}
;}}}

;###############apu######################################/*{{{*/
;comment [
;def rien():
;	# -- requêtes de vérification --
;	print "<a name=\"check_queries\"><h2>Check queries on database, with PROBLEMS: everything should be SOLVED, eventually.</h2>"
;
;	# -- les sondages --
;	print "<a name=\"check_queries_dh\"<h3>Drill holes data</h3>"
;
;	# -- les tetes de sondages et tranchées -- 
;	print "<a name=\"check_queries_dh_collars\"><h4>Drill holes collars and trenches starting points: dh_collars table</h4>"
;	check_queries_dh_collars()
;
;	# -- les échantillons et analyses de sondages et tranchées -- 
;	#print "<a name=\"check_queries_dh_sampling\"><h3>Sampling and assay data in drill holes and trenches</h3>"
;	check_queries_dh_sampling()
;
;	# -- les descriptions de sondages --
;	#print "<a name=\"check_queries_dh_litho\"><h3>Lithologies, geological descriptions</h3>"
;
;	# -- les logs techniques --
;	#print "<a name=\"check_queries_dh_tech\"><h3>Technical data</h3>"
;
;
;	# -- les déviations --
;	#print "<a name=\"check_queries_dh_devia\"><h3>Deviation measurements</h3>"
;
;	# -- les affleurements -- 
;	# -- la géochimie -- 
;	# -- le grade-control --
;	# -- boîte à coQuilles --
;	# -- apu! --
;	fin()
;
;
;
;#def compare_bd_js_csa(): #{{{
;#	#comparaison des bd:
;#	printTxt("List of tables in amc_2009_05_06_de_jsm database:")
;#	print "<div><pre>"
;#	os.system('echo "\\dt+" | psql -d amc_2009_05_06_de_jsm')
;#	print "</pre></div>"
;#	
;#	printTxt("List of tables in amc_csa database:")
;#	print "<div><pre>"
;#	os.system('\\dt+" | psql -d amc_csa')
;#	print "</pre></div>"
;#	
;#	#printTxt "Automatic comparison of all tables from both databases: only differences are shown by diff utility."
;#	
;#	ligne_cmd = """for i in $(echo "\dt" | psql -d amc_2009_05_06_de_jsm | grep table | colrm 1 10 | colrm 21); 
;#	do 
;#	echo "<div><pre>"
;#	echo "___________ $i ____________"; 
;#	compare_tables_deux_bd amc_2009_05_06_de_jsm amc_csa $i;
;#	echo "</pre></div>"
;#	done
;#	"""
;#	os.system(ligne_cmd)
;#
;#}}}
;
;
;#def init_connexion_bd(): #{{{
;#	db = QtSql.QSqlDatabase("QPSQL")
;#	db.setPort(5432)
;#	db.setDatabaseName("bdexplo")
;#	if not db.open():
;#		raise db.lastError().text().toUtf8()
;##}}}
;
;
;def check_queries_dh_collars(): #{{{
;	print "<h2>Drill holes and trenches collars: dh_collars table</h2>"
;	runQueryToReport("SELECT * FROM dh_collars WHERE operation = 'HASS' OR operation IS NULL ORDER BY completed DESC, id;")
;	#il y avait cellet liste de champs à la place de l'étoile:
;	#id,shid,location,profile,srid,x,y,z,azim_ng,azim_nm,dip_hz,dh_type,date_start,driller,geologist,length,len_destr,len_pq,len_hq,len_nq,len_bq,nb_samples,comments,completed,data_source,numauto 
;	print "<h3>Unconsistent data: fields id, location, location vs. identifier prefix</h3>"
;	runQueryToReport("SELECT split_part(id, '_', 1) AS id_left_part, location, count(*) AS nb_records FROM collars /*WHERE completed IS TRUE*/ GROUP BY split_part(id, '_', 1), location HAVING split_part(id, '_', 1) <> location ORDER BY split_part(id, '_', 1);")
;	printTxt("The dh_collars.location field corresponds to the occurrences.code field.")
;	printTxt("occurrences table:")
;	runQueryToReport("SELECT code, name,status,x,y,description,w_done,w_todo,geol_poten,grade,type,code_typ,size,au,trenches,coredrill,pdrill,max_grade,length,thickness,code_indic,num_code FROM occurrences ORDER BY code, name;")
;	printTxt("Corresponding records:")
;	runQueryToReport("SELECT location AS collars_location, code AS occurrences_code, COUNT(*) FROM collars FULL OUTER JOIN occurrences ON collars.location = occurrences.code GROUP BY location, code;")
;	printTxt("Codes have to be informed in occurrences table. Note that this is not critical.")
;	printTxt("Records without location or sector:")
;	runQueryToReport("SELECT id, location FROM collars WHERE location IS NULL;")
;	printTxt("Fields id, shid (IDentifier, SHort IDentifier): unconsistent records:")
;	#runQueryToReport "SELECT split_part(id, '_', 2) AS id_right_part, shid FROM collars WHERE split_part(id, '_', 2) <> shid;"
;	runQueryToReport("SELECT split_part(id, '_', 2) AS id_right_part, shid, replace(split_part(id, '_', 2), '0', '') AS id_right_part_no0, replace(shid, '0', '') AS shid_no0 FROM collars WHERE replace(split_part(id, '_', 2), '0', '') <> replace(shid, '0', '');")
;	printTxt("Unconsistent geometries: azimuth and dip:")
;	runQueryToReport("SELECT id, azim_ng, dip_hz FROM collars WHERE azim_ng >360 OR dip_hz < 0 OR dip_hz > 90;")
;	printTxt("Azimuth value was misplaced in dip field.")
;	printTxt("Azimuth relative to North Geographic (azim_ng) and azimuth relative to North Magnetic (azim_nm): very few values informed of azim_nm, even though this is the true measurement done in the field. When both values are present, difference is always 1 degree. One of the two fields should be dropped, the missing value being calculated in a view, rather.")
;	runQueryToReport("SELECT id, azim_ng, azim_nm, azim_ng - azim_nm AS diff_azim_nm_ng FROM collars WHERE azim_nm IS NOT NULL AND azim_ng IS NOT NULL ORDER BY id;")
;	printTxt("Drill holes locations:<br>Mapping drill holes collars does not show, at first glance, any obvious errors.")
;	printImg("map_qgis_collars_locations.png")
;	printTxt("map_qgis_collars_locations.png AMAJ")
;	printTxt("Missing coordinates:")
;	runQueryToReport("SELECT id, x, y, z FROM collars WHERE x IS NULL OR x <300 OR y IS NULL OR y <300 OR z IS NULL OR z <300 ORDER BY id;")
;	printTxt("Undefined elevations, appearing at sea level:")
;	printImg("plot_xyz_collars3d.png")
;	printTxt("plot_xyz_collars3d.png A_MAJ")
;	printTxt("Drill holes coordinates, suspect values: type cast errors?")
;	runQueryToReport("SELECT id, x,y,z from collars where x=cast(x/10 as int)*10 or y=cast(y/10 as int)*10 order by id;")	
;	#CONTINUER les vérifs dans collars
;	#}}}
;
;def check_queries_dh_sampling(): #{{{
;	printTxt("dh_collars table contains collars data, dh_sampling table contains samples from drill holes and trenches.")
;	printTxt("Start from dh_sampling table:")
;	runQueryToReport("SELECT * FROM dh_sampling ORDER BY id, depto LIMIT 10;")
;	printTxt("The sample identifier and the key from table dh_sampling is dh_sampling.sample_id; it is supposed to be unique => list of sample_id not uniques:") 
;	runQueryToReport("SELECT sample_id, COUNT(*) FROM dh_sampling GROUP BY sample_id HAVING COUNT(*) >1;")
;	printTxt("Drill holes which have several duplicate sample_id's:")
;	runQueryToReport("SELECT id, SUM(cnt) AS count FROM (SELECT id, sample_id, COUNT(*) AS cnt FROM dh_sampling GROUP BY id, sample_id HAVING COUNT(*) >1) AS tmp GROUP BY id;")
;
;	printTxt("Check consistency between dh_collars.id and dh_sampling.id: the following query lists orphan records, they are all missing id, from one side or the other. The field dh_collars.nb_samples is supposed to contain the number of samples taken in each hole/trench: when it is set to zero, it means that the hole/trench was not sampled:")
;	runQueryToReport("""
;SELECT dh_collarsc.id AS dh_collars_id, dh_collarsc.nb_samples AS nb_samples_supposed, tmp.id AS dh_sampling_id, tmp.samples AS number_samples 
;FROM 
;(SELECT * FROM dh_collars WHERE completed) dh_collarsc
;FULL OUTER JOIN 
;(SELECT id, COUNT(*)AS samples FROM dh_sampling GROUP BY dh_sampling.id) tmp 
;ON dh_collarsc.id = tmp.id 
;WHERE 
;(dh_collarsc.id IS NULL OR tmp.id IS NULL) 
;ORDER BY dh_collarsc.id || tmp.id;
;""")
;
;	print "<p>When dh_collars_id do not correspond to any dh_sampling_id, it means (hopefully) that the hole/trench has not been sampled. Strange, but explainable. When it is the other way, it is a mistake: a sample without its collar defined is not acceptable. A total of"
;	os.system("""echo "SELECT SUM(number_samples) FROM (SELECT dh_collars.id AS dh_collars_id, tmp.id AS dh_sampling_id, tmp.samples AS number_samples FROM dh_collars FULL OUTER JOIN (SELECT id, COUNT(*)AS samples FROM dh_sampling GROUP BY dh_sampling.id) tmp ON dh_collars.id = tmp.id WHERE dh_collars.id IS NULL OR tmp.id IS NULL) tmp;" | psql -X -d bdexplo | grep -v [a-zA-Z-]""")
;	print "records from dh_sampling are concerned.</p>"
;	#}}}
;
;def grade_control(): #{{{
;	#printTxt("Note that this is also the case in grade_ctrl table: => LATER")
;	#runQueryToReport("SELECT id, x,y,z from grade_ctrl where x=cast(x/10 as int)*10 or y=cast(y/10 as int)*10 order by id;")
;	printTxt("An example of such type cast errors on pre-exploitation sampling on Ganaet mine:")
;	printImg("map_qgis_preex_type_cast_errors.png")
;	printTxt("map_qgis_preex_type_cast_errors.png A_MAJ")
;	#}}}
;]
;#/*}}}*/

