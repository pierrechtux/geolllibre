#!/usr/bin/rebol_core -qs
REBOL [
	Title:   "GeolPDA report generator"
	Date:    09-Mar-2013
	Version: 0.8.0 
	File:    %gll_geolpda_report_generator.r
	Purpose: {
		Génération d'un rapport sous forme d'un fichier .html 
		à partir d'une base sqlite "geolpda" du geolpda
		en allant chercher la table des observations avec les données:
		_id,poiname,poitime,elevation,poilat,poilon,photourl,audiourl,note
		"94","PCh2012_0372","1351959798292","544.3","43.4495","0.733307","1351959861748.jpg","1351959897130.3gpp","Le Bouche à oreille, café, logiciels libres, tango studio"
		"93","PCh2012_0371","1351700656858","91.1","5.37645","-3.96311","","","chez PNG"
		Le fichier sqlite doit se situer là (répertoire courant):
		geolpda
		Et les photos doivent être là (en aval du répertoire courant):
			photos/
	}
	History: [
		0.1.0 15-Nov-2012            	"PCh: J'écris vite fait un script qui fabrique un .html de mes données collectées avec le geolpda"
		0.2.0 17-Nov-2012           	"PCh: Youpi, mon programme Rebol a généré un rapport à peu près potable:"
		0.2.1 10-Dec-2012          		"PCh: Je fais un exemple de rapport de geolpda: quelques modifications"
		0.2.2 8-Mar-2013            	"PCh: Tri des observations en fonction du timestamp, et non de l'id (problème de tri asciibétique)"
		0.2.3 2-Apr-2013/11:59:57+2:00	"Ajout license et copyright"
		0.2.4 15-Apr-2013/14:08:11		"Prise en compte du cas ou le .csv a une ligne vide à la fin"
		0.2.5 11-Sep-2013/20:01:21+2:00	"Débogage, corrections; prise en compte de dates de début et fin pour générer le rapport"
		;(check git)
		0.8.0 8-Nov-2013/13:24:46+1:00	"Take data from sqlite base, instead of .csv files"
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
]

; Get routines, preferences, and connect to database:
do load to-file system/options/home/bin/gll_routines.r
; Library to access sqlite geolpda database:
do %~/rebol/library/scripts/btn-sqlite.r

; non: {{{ } } }
;; ouvrir le fichier .csv des observations du geolpda:
;change-dir system/options/path
;lines: read/lines %geolpda_picks.csv
;}}}
; =============================================================================
; TODO: ouvrir le fichier avec un chemin à choisir
; TODO: à terme, attaquer direct la base sqlite geolpda => auquai
; 		=> 23-Oct-2013/9:55:53+2:00: see gll_geolpda_fetch_data.r
;		=> 6-Feb-2014/23:58:48-3:00: essayons
; =============================================================================

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
run_query "SELECT * FROM poi ORDER BY poitime"	; ORDER BY évitera de trier par la suite
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

;}}}
;}}}

; Inutile si on n'utilise pas le .csv: {{{ } } }
;; l'en-tête du csv => (TODO: les noms de champs sont à réviser!):
;;lines/1 == {_id,poiname,poitime,elevation,poilat,poilon,photourl,audiourl,note}
;
;observations: copy []    ; un tableau contenant les observations
;foreach line lines [     ; on remplit ce tableau
;	if line == "" [ break ]
;	t: parse/all line ","
;	append observations reduce [to-list skip t 1]
;]
;;?? observations
;
;; On enlève la première ligne d'en-tête:
;remove observations
;
;; On trie la table: {{{ } } }
;;sort observations
;; non, ça déconnait, pour Fred Rossi, qui, les [ 27-Feb-2013 28-Feb-2013 1-Mar-2013 ], avait des identifiants sans zéros préfixant, donc des tris asciibétiques aberrants: [ ;{{{ } } }
;;TotBol1
;;TotBol10
;;TotBol11
;;TotBol12
;;TotBol13
;;TotBol14
;;TotBol15
;;TotBol16
;;TotBol17
;;TotBol18
;;TotBol19
;;TotBol2
;;TotBol20
;;TotBol21
;;TotBol22
;;TotBol3
;;TotBol4
;;TotBol5
;;TotBol6
;;TotBol7
;;TotBol8
;;TotBol9
;;] ;}}}
;; Donc on trie la table par timestamp, plutôt:
;field: 2    ; le champ sur lequel trier: timestamp = 2, en l'occurrence
;sort/compare observations func [a b] [(at a field) < (at b field)]
;; }}}
;}}}
; On affiche combien on a de lignes (d'observations)
print rejoin ["Nombre d'observations: " length? geolpda_observations]

; Il s'agit maintenant de déterminer les jours où il y a eu des observations: [{{{
; on construit une liste vide:
dates: copy []
; qui contiendra
; toutes les dates:
foreach o geolpda_observations [
    append dates o/3             ;c'est le champ poitime
]

; Il faut trouver les jours.
; Les dates sont au format epoch en millisecondes;
; on utilise la fonction pour convertir les epoch en date 
; dans gll_routines.r

; Faisons une liste contenant les jours:
jours: copy []

;compteur: 0
; et on y met tous les jours (au format date):
foreach i dates [
;compteur: compteur + 1
;print compteur
    ;tmp: to-date epoch-to-date (to-integer ((to-decimal i) / 1000))
    ; => marche plus pour une date:
	;** Script Error: Invalid argument: 7-Dec-2012/23:57:591:00
	;** Where: to-date
	;** Near: to date! :value
    ; => contournement de l'obstacle:
    tmp1: epoch-to-date (to-integer ((to-decimal i) / 1000))
    tmp: to-date (first parse tmp1 "/")
    append jours tmp/date
]

; On ne garde que les jours uniques, en les plaçant dans la liste jours:
jours: unique jours
; que l'on trie:
sort jours
;}}}]
prin "Jours: "
foreach j jours [print j]   ; <= la liste des jours, triée

; 2013_09_11__15_51_45: j'essaye de faire une liste des séquences contigües de dates, 
; pour donner le choix des séquences à traiter à l'utilisateur.
; ### MARCHE PAS ###
comment [ ; {{{ } } }
jour_zero: to-date replace/all "05_01_2012" "_" "/" ; le jour de la première version de GeolPDA: il ne peut, par définition, avoir d'observations faite avant.

;/*{{{*/
sequences_jours_contigus:  copy []
sequence:                  copy []
num:                       0

; premier jour:
append sequence jours/1
jour_precedent: jours/1
sequence_encours:          true
nb_sequences:              1
jours: next jours

foreach j jours [								; à partir du second jour, donc, on itère:
	either (j - jour_precedent > 1) [ 				; on est dans une séquence non contigüe:
		either sequence_encours [						; si on est dans une séquences, 
			append sequence jour_precedent				; on l'arrête.
			jour_precedent: j
			append sequence j							; et on en démarre une autre
			append sequences_jours_contigus 
		] [	sequence_encours: true					; on n'est pas dans une séquence contigüe: on démarre une séquence
			append sequences_jours_contigus j
			jour_precedent: j
		]
	] [											; séquence contigüe
		either sequence_encours [
		] [
			jour_precedent: j
			sequence_encours: true
			append sequences_jours j
		]
	]
]





sequence: copy []
j: jours/1
append sequence j
jour_precedent: j
foreach j jours [
	unless (j - jour_precedent = 1) [
		
	]
]



append sequence jours/1
for i 2 ((length? jours) - 1) 1 [
	unless all [((jours/:i - jours/(i - 1)) = 1) ((jours/(i + 1) - jours/:i) = 1)] [
		append sequence jours/(:i - 1) 
		append sequence jours/:i
	]
]





;/*}}}*/


jours: [		;;DEBUG!!!
21-Jul-2013
4-Aug-2013
7-Aug-2013
22-Aug-2013
23-Aug-2013
24-Aug-2013
25-Aug-2013
26-Aug-2013
27-Aug-2013
28-Aug-2013
30-Aug-2013
2-Oct-2013
]
nbjours: length? jours
sequences_jours_contigus: copy []
append sequences_jours_contigus jours/1
jours: next jours
while [ (nbjours - (index? jours)) > 2 ] [
	print first jours
	either (((first jours) - (jours/(-1))) = 1) [	; jour contigu au précédent?
													; si c'est le cas, on ne fait rien
	] [												; sinon,
		either ((jours/2 - jours/1) = 1) [		; jour contigu au suivant?
															; si c'est le cas, on ne fait toujours rien
		] [													; sinon
			append sequences_jours_contigus (jours/(-1))	; on ajoute le jour précédent pour finir la séquence en cours,
			append sequences_jours_contigus (first jours)			; ainsi que le jour courant   pour commencer la nouvelle séquence.
		]
	]
	jours: next jours
]
foreach [a b] sequences_jours_contigus [
	prin a
	prin tab
	print b
]









trucmuche [
	print i
	print rejoin [jours/(i - 1) " - " jours/:i " -" jours/(i + 1)]
	print rejoin ["    " (jours/:i - jours/(i - 1)) "         " (jours/(i + 1) - jours/:i)]
]




jour_precedent: jour_zero
sequences_jours: copy []
foreach j jours [
	append sequences_jours (j - jour_precedent)
	append sequences_jours j
	jour_precedent: j
]

jour_precedent: jour_zero
tt: copy []

until  [
	print first sequences_jours
	if ((first sequences_jours) > 1) [
		append tt next sequences_jours
		jour_precedent: copy next sequences_jours
	]
	sequences_jours: next next sequences_jours	
	(tail? sequences_jours)
]



] ;}}}
; ### MARCHE PAS ###

;}}}

; {{{ non: } } }
; =============================================================================
; TODO: paramétrer les dates de début et fin de la génération du rapport
; =============================================================================
prin rejoin ["Date de début de génération du rapport (défaut: " (to-string first jours) ": "]
date_deb: input
either date_deb = "" [date_deb: first jours] [date_deb: to-date date_deb]
?? date_deb
prin rejoin ["Date de fin de génération du rapport (défaut: " (to-string last jours) ": "]
date_fin: input
either date_fin = "" [date_fin: last jours] [date_fin: to-date date_fin]
?? date_fin
; }}}

comment [ ; DEBUG ######################
date_deb: 22-Aug-2013
date_fin: 28-Aug-2013
]         ; DEBUG ######################

; {{{ } } }

;==============================================================================
; Créons un fichier .html en sortie, en y ouvrant un port:
; Le fichier est nommé en fonction du dernier jour;
; next form 100 est un truc pour avoir des leading zeroes.
outputfile: to-file rejoin ["geolpda_report_pch_from_"
date_deb/year "_" 
next form 100 + date_deb/month "_" 
next form 100 + date_deb/day
"to"
date_fin/year "_" 
next form 100 + date_fin/month "_" 
next form 100 + date_fin/day ".html"]
;******************************************************************************
; TODO:
;     o le outputfile est curieusement créé dans le répertoire du script, 
;       soit ~/bin, sur ma machine autan:
;       il faudrait qu'il le crée dans le répertoire d'où on lance le script.
;       comme pis-aller, je fais un symlink à chaque fois...
;
;    o mettre des symbole structuraux, sous forme de Tés ou stéréos ou rosaces
;
;    o générer des cartelettes par jour ou parcours ou regroupement géographique
;       de points d'observations
;
;    o faire une interface utilisateur VID avec choix des dates à reporter, 
;      élimination manuelle de certains points à ne pas mettre dans le rapport 
;      (genre "bon resto", "pêche mémorable", etc.)
;
;    o prévoir un champ "reporting" booléen dans la table des observations,
;      valide par défaut, qu'on puisse décocher au moment de la prise de note,
;      de manière à ne point reporter tous les endroits où l'on défèque ou les 
;      meilleures gargottes ou autres lieux de perdition dans le rapport 
;      d'intervention destiné au client.
;
;******************************************************************************

; On y écrit un en-tête général: [{{{
write/lines outputfile to-string [
{<!DOCTYPE HTML PUBLIC ^"-//W3C//DTD HTML 4.01 Transitional//EN^">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
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
  }]

write/lines/append outputfile rejoin ["Rapport d'observations de terrain collectées par GeolPDA du " (to-string date_deb) " au " (to-string date_fin)]
write/lines/append outputfile [{
  </title>
 </head>
<body>
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
</center></em></div>
<p>
}]

write/lines/append outputfile to-string now/date
write/lines/append outputfile rejoin ["<p><small>Report generated on "
 to-string now " by gll_geolpda_report_generator.r</small></p>"]
;}}}]
;}}}

; puis on écrit le corps:/*{{{*/
; Itérons maintenant sur les jours; j est le jour courant:
;?? date_deb
;?? date_fin
foreach j jours [
	;prin j
	; on restreint aux dates définies plus haut:
	if ((j >= date_deb) and (j <= date_fin)) [
		; Écrivons un en-tête pour ce jour: journée = titre de niveau 1:
		print "=============="
		print j
		print "=============="
		;PRINT "DEBUG_1" ?? j input ;###############################################################DEBUG
		write/append outputfile rejoin ["<p></p>" {<hr size="2" width="100%"><br>} "<h1>" to-string j "</h1>"]
		; On ne considère que les observations faites le jour dit:
		foreach o geolpda_observations [
			;if o/1 = "PCh2012_0383" [ halt  ;###############################################################DEBUG
			;	;il y a là une date aberrante:
			;		;PCh2012_0383 1354924679009 0 0 0   
			;		;** Script Error: Invalid argument: 7-Dec-2012/23:57:592:00
			;		;** Where: to-date
			;		;** Near: to date! :value
			;	print "date aberrante: " o/2
			;	]
			;PRINT "DEBUG_2" ?? o input       ;###############################################################DEBUG
			tmp: epoch-to-date to-integer ((to-decimal o/3) / 1000)
			timestamp: to-date tmp
			;PRINT "DEBUG_3" ?? timestamp print timestamp/date ?? j input ;###############################################################DEBUG
			if (timestamp/date = j) [ ; on est dans le jour courant, on procède:
				;PRINT "DEBUG_4" input ;###############################################################DEBUG
				;print timestamp/date
				;print timestamp/date = j
				;input ;###############################################################DEBUG
				; des variables aux noms explicites:
				;poiname,poitime,elevation,poilat,poilon,photourl,audiourl,note
				id:          to-string  o/2
				alt:         to-decimal o/4
				lat:         to-decimal o/5
				lon:         to-decimal o/6
				photos:      to-string  o/7
				audio:       to-string  o/8
				note:        to-string  o/9

				; discret à droite, l'heure:
				write/lines/append outputfile rejoin [ {<p align="right"><small>} timestamp/time "</small></p>" ]
				; => non, ça affiche, curieusement, que none => TODO remettre ça
				; => auquai; ça doit être mieux

				; Un titre de niveau 2 = le waypoint:
				write/lines/append outputfile rejoin [
				"<h2>" id ": "
				either lat >= 0 ["N"] ["S"]
				absolute (round/to lat 1E-6) "° " 
				either lon >= 0 ["E"] ["W"]
				absolute (round/to lon 1E-6) "°, z = "
				absolute (round/to alt 1E-2) "m"
				"</h2>"]
				; les notes:
				write/lines/append outputfile rejoin ["<p>" note "</p>"]
				if length? photos [
					; Il y a des photos:
					;write/append outputfile photos
					;photos: "1342804479678.jpg;1342804628278.jpg;1342804641423.jpg"
					;print photos
					photos_list: to-list parse/all photos ";"
					foreach pho photos_list [
						print pho
						tt: to-integer ((to-decimal first parse pho ".") / 1000)
						timestamp_photo: to-date epoch-to-date tt
						;print timestamp_photo
						write/lines/append outputfile rejoin [
							{<img src="photos/} 
							pho 
							{" style="width="25%" height="25%";" vspace="5" hspace="10" alt="} 
							pho 
							{" />} 
						]
						; {<img src="file://} system/options/path "photos/" pho {" style="width="25%" height="25%";" vspace="5" hspace="10" alt="} pho {" />}
						; plutôt, voir thumbnail-maker.r
						;  {<img alt="} pho {" src="file:///home/pierre/geolpda/copie_android_media_disk/photos/reduit_700/} pho {" " />}
					]
				]
			]
		]
	]
]
;/*}}}*/
; Une fois tout écrit, on ferme les balises ouvertes:/*{{{*/
write/append outputfile to-string [
{
</body> 
</html>
}]

;/*}}}*/

print rejoin ["Report generated: " to-string outputfile]

comment {
Pour vim:
:set foldmarker=[,]
:set syntax=rebol
}

