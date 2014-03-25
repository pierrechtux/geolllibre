#!/usr/bin/rebol -qs
rebol [
	Title:   "Define a new datasource, and fill the database lex_datasource"
	Name:    gll_bdexplo_new_datasource.r
	Version: 1.0.0
	Date:    "26-Jul-2013/22:23:16+2:00"
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

; initialisation:
if error? try [						; Récupération des routines (et des préférences) et connexion à la base
do load to-file system/options/home/bin/gll_routines.r	; soit depuis ~/bin
] [
do load to-file %gll_routines.r				; ou sinon là où se trouve le script présent
]

if error? try [ type? journal_sql ] [journal_sql: [] ]	; si pas de journal des instructions SQL, on en crée un vide

; test pour voir si les transactions peuvent avoir lieu:
insert db "BEGIN TRANSACTION;"
; oui, ça marche!

; des fonctions:
	msg_err: does [
		print "Erreur: usage = "
		print "gll_bdexplo_new_datasource.r chemin/fichier            => crée un nouveau datasource_id automatiquement (max + 1)"
		print "ou:"
		print "    gll_bdexplo_new_datasource.r chemin/fichier 12345      => crée un nouveau datasource_id "
		print "Les préférences (hôte de la base bdexplo, port, username, opid, etc. sont dans le fichier .bdexplo_prefs dans le répertoire $HOME"
		]



; Récupération du dernier datasource, fabrication d'un nouveau numéro de datasource (+1):
get_new_datasource_id


; choix du déroulement en fonction du nombre d'arguments en ligne de commande:
either system/options/args = none [
	; s'il n'y a rien en arguments sur la ligne de commande, mode interactif graphique:
	layout_new_datasource: [				; Un layout pour choisir un fichier (si ce n'est déjà fait) à importer, et déterminer un nouveau datasource
		backdrop white
		across
		; --- Partie concernant le choix du fichier, avec une prévisualisation
			;title "Data file import"
			h1 "Fichier pour import:"
			if error? try [ empty? file_in ] [ file_in: "" ]
			f: info to-string file_in
			; bouton pour choisir un fichier:
			btn #"c" "Choix fichier pour import" [				;"Choose file to import" 
			 file_in: request-file/title/filter "fichier de données à traiter" "Ouvrir" [*.csv *.CSV]
			 f/text: to-string file_in
			 show f
			 ; On vérifie que ce soit un fichier et qu'on l'ouvre:
			 either (chk_file_exists file_in) [
			  ; Prévisualisation du fichier:
			  preview/text: read to-file file_in
		  	  show preview ][
			  alert rejoin [ "Non, cela ne le fait pas, erreur en essayant d'ouvrir " to-string file_in ]
			  ]
			 ]
			return
			; Zone de prévisualisation du contenu du fichier choisi:
			preview: info 500x40 white
			return
			below
		; --- Partie concernant le datasource ---
			h1 "Traçabilité des données: définition d'identifiant de datasource"	;"Data traceability: datasource identifier definition"
			; attendons un vid sous rebol3 avant de pouvoir mettre des caractères accentués proprement...
			text rejoin ["Dernier (maximum) identifiant datasource dans lex_datasource pour l'opid " opid ":" ]	;["Last (maximum) datasource identifier in lex_datasource for opid " opid ":" ]
			info to-string max_datasource_id
			text rejoin [ "Nouvel identifiant datasource proposé: max + 1:" ]
			across
			field_new_datasource_id: field to-string ( new_datasource_id ) [
			 new_datasource_id: to-integer field_new_datasource_id/text]
			btn #"t" "Test datasource_id; génération sql si auquai" [
			 new_datasource_id: to-integer field_new_datasource_id/text
			 either (test_datasource_available new_datasource_id) [
			  t/text: rejoin ["ok, proposed datasource_id " new_datasource_id " free in database" ]
			  generate_sql_string_update new_datasource_id file_in
			  field_sql/text: sql_string_update
			  show field_sql
			  ] [
			  t/text: rejoin ["problem, proposed datasource_id " new_datasource_id " already referenced in database: ^/" res ]
			  ]
			 show t ]
			return
			t: info 500x40 white
			return
		; --- Partie concernant la mise à jour de la table ---
		field_sql: field 500x40 [ sql_string_update: face/text ]
		across
		; Boutons
		btn #"o" "OK, continuer" [
		 if true = request rejoin ["Générer l'enregistrement dans public.lex_datasource?^/" sql_string_update ] [
		 run_sql_string_update
		 unview ]
		]
		btn #"c" "Abandon" [ new_datasource_id: none
		 unview ]
		]
	if view? [	; /only if this rebol is a view
		view/title layout layout_new_datasource "Fichier pour import et nouveau datasource_id"
		if confirm "Commit changes to database (*not* undoable)?" [
			insert db "COMMIT;"
		]
	]
	quit
][
	; s'il y a quelque chose en arguments sur la ligne de commande, on fait en mode texte:
	; on utilise sous la forme:
	;                           gll_bdexplo_new_datasource.r "~/smi/transferts/from/duc/fich.csv" 		=> numéro datasource_id automatique
	;                           gll_bdexplo_new_datasource.r "~/smi/transferts/from/duc/fich.csv" 1232	=> force un datasource_id

	switch/default length? system/options/args [
	1 [				;=> numéro datasource_id automatique
	 ; RAS, on garde le new_datasource_id tel que déjà défini
	 ]
	2 [				;=> force un datasource_id
	 if error? try [new_datasource_id: to-integer system/options/args/2 ] [ msg_err ]
	 ]
	][				;=> autre cas: erreur
	msg_err
	]

	; tout va bien, on continue
	file_in: to-file pick system/options/args 1
	if not(test_datasource_available new_datasource_id) [
		print rejoin ["problem, proposed datasource_id " new_datasource_id " already referenced in database: ^/" res ]
		quit
	]
	; tout va bien, ça continue
	print rejoin ["ok, proposed datasource_id " new_datasource_id " free in database" ]
	if not (chk_file_exists file_in) [
		print rejoin [ "Non, cela ne le fait pas, erreur en essayant d'ouvrir " to-string file_in ]
		quit
	]
	; tout va bien, ça continue encore
	print rejoin ["ok, file " file_in " open"]

	generate_sql_string_update new_datasource_id file_in
	print "-- SQL instruction to be run:"
	print sql_string_update
	reponse: (ask rejoin ["Générer l'enregistrement dans public.lex_datasource:^/" sql_string_update "^/(Y/n) ?"])
	if any [(reponse = "y") (reponse = "")] [
		run_sql_string_update ]
	reponse: (ask "Commit changes to database (undoable)?")
	if any [(reponse = "y") (reponse = "")] [
		insert db "COMMIT;"
		prin "New datasource generated: "
		print new_datasource_id
	]
	quit
]
; fin

