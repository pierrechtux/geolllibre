#!/usr/bin/rebol_core -qs
REBOL [;{{{ } } }
	Title:   "Computation of GeolPDA orientation matrix"
	Date:    5-Oct-2013/15:34:37+2:00
	Version: 0.0.0 
	Purpose: {
		Conversion from structural measurements done by GeolPDA,
		expressed as a 3x3 rotation matrix of the telephone
		orientation, to "traditional" structural geological
		measurements.
		Drawing of a "Té" symbol.
	}
	History: [
		0.0.0 5-Oct-2013/15:34:37+2:00	"PCh: first implementation, with a GUI to test datasets"
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

; #DEBUG tout ça marche (pas pour le moment): {{{ } } }
; initialisation: {{{ } } }
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



rotation_matrix: make object! [
	rotation_matrix_measure: copy []
	__init__: func [args [block!]] [
		; at object construction time, initialise with a block! with an
		; orientation measurement, as given by geolpda application:
		; list of 9 rot(n) variables, in a block, like:
			;[0.375471 -0.866153 -0.32985 0.669867 0.499563 -0.549286 0.640547 -0.0147148 0.767778]
				; Une mesure réelle du géolpda:
			; Exemple réel de plan:
			;_id	poiname	poitime	elevation	poilat	poilon	photourl	audiourl	note
			;358	PCh2013_0639	1377339260698	89.9	43.3359	-1.39078	1377339392897.jpg;1377339414464.jpg		Bel affleurement de gneiss, foliation Nm140/40/W
			;
			;_id	poi_id	orientationtype	rot1	rot2	rot3	rot4	rot5	rot6	rot7	rot8	rot9	v1	v2	v3
			;851	358	P	0.375471	-0.866153	-0.32985	0.669867	0.499563	-0.549286	0.640547	-0.0147148	0.767778	0	0	0
			;
			;rotation_matrix_measure: [0.375471 -0.866153 -0.32985 0.669867 0.499563 -0.549286 0.640547 -0.0147148 0.767778]

		rotation_matrix_measure: copy args

		; Convert rotation_matrix_measure to a block of blocks:
		rotation_matrix: make block! []
		foreach [a b c] rotation_matrix_measure [append/only rotation_matrix to-block reduce [a b c]]

		; Juste pour un souci d'ergonomie du codeur:
		; la notation de la matrice de rotation
		; est bien plus pratique à manier sous
		; forme de abcdefghi, dans les formules:
		; No: too ringard:/*{{{*/
		;a: rotation_matrix/1/1
		;b: rotation_matrix/1/2
		;c: rotation_matrix/1/3
		;d: rotation_matrix/2/1
		;e: rotation_matrix/2/2
		;f: rotation_matrix/2/3
		;g: rotation_matrix/3/1
		;h: rotation_matrix/3/2
		;i: rotation_matrix/3/3
		;/*}}}*/
		; Better, more rebolish:
		variables_short: "abcdefghi"
		count: 1
		for i 1 3 1[
			for j 1 3 1 [
				do rejoin [variables_short/(count) ": rotation_matrix/" i "/" j]
				count: count + 1	]	]

	]

	trace_te: func [
	] 

]

; instanciation (si j'ose dire) d'une orientation:
orientation1: new rotation_matrix [0.375471 -0.866153 -0.32985 0.669867 0.499563 -0.549286 0.640547 -0.0147148 0.767778]



;Je tente de passer en rebol le code python que je fis pour tracer le té de pendage dans le géolpda: {{{ } } }
;# Pour pouvoir faire des maths:
;# from math import *	; => inutile en rebol

; ## Les données initiales: {{{ } } }
;# J'ai pris une mesure de ma planchette dans ma position de
;# travail chez moi, avec le téléphone pitchant vers la
;# gauche.
;# Ça revient à une mesure de faille Nm30/60/E/55/S/N.
;# en tous cas, sans intérêt pour nous.
;# À l'écran du GéolPDA, ça se présentait à peu près
;# ainsi:
;#
;#       |  -0.7 |   0   |   0.7 |   0   |
;#       |   0.6 |   0.6 |  -0.5 |   0   |
;#       |   0.4 |   0.8 |   0.4 |   0   |
;#       |   0   |   0   |   0   |   1   |
;#
;# J'ai recopié ça depuis l'écran du GéolPDA, en
;# omettant la dernière colonne et la dernière
;# ligne, qui sont insignifiantes (une réminiscence
;# de la matrice identité; peut-être l'accélération?)
;# (J'ai aussi un peu arrondi les valeurs; pas
;# facile de les lire quand ça bouge dans tous les
;# sens lors de la mesure): peu importe.
;#
;# J'ai mis la matrice de rotation 3x3 sous
;# la forme linéaire suivante:
;
;"'}
;rotation_matrix:	 [[ -0.7   0     0.7]
;					  [  0.6   0.6  -0.5]
;					  [  0.4   0.8   0.4]]
;(une autre mesure:)
;rotation_matrix:	 [[ 0.95   0.3    -0.1]
;					  [ -0.3   0.9    -0.3]
;					  [  0.0   0.3     0.95]]

; L'exemple de matrice pour une pseudomesure de faille Nm30/60/E/55/S/N:
;rotation_matrix:	 [ [-0.7   0     0.7]
;					   [ 0.6   0.6  -0.5]
;					   [ 0.4   0.8   0.4]]

; }}}
; Des choses génériques, dont on se resservira => (mis dans gll_routines.r): {{{
; matrix_product_line
; On définit une classe pour les vecteurs:
; vector
; }}}
; }}}

; ON est la normale du plan vers le haut (utile pour 
; les pendages inverses, par exemple):
ON: make vector [x: c y: f z: i]
;>> probe ON
;make object! [
;    x: 0.7
;    y: -0.5
;    z: 0.4
;]
;>>
; => semble correct 

;; mieux (plus "propre", "lisible"):
;ON: product_matrix_line rotation_matrix [0 0 1]
;;>> probe ON
;;[0.7 -0.5 0.4]
;; => semble correct ; mais je préfère le vecteur, finaloumen.


; OA est le vecteur de l'Axe du téléphone, vers le haut
; quand on tient le téléphone normalement.
; Si l'on mesure une faille, il s'agit du vecteur mouvement du bloc 
; en place (opposé de celui de la mesure), de sorte qu'une faille
; _normale_ se mesure avec le téléphone en position _normale_.

OA: product_matrix_line rotation_matrix [0 1 0]
OA: to-vector OA
probe OA
OA/azim
OA/dip
OA/is_unit
OA/norm


; OD est le vecteur aval-pendage; D pour Down-Dip:
OD: make vector [
	x: i / (square-root 3) 
	y: i * f / ((square-root 2) * c) 
	z: square-root ( 1 - (( ( i ** 2 ) / 2 ) - ( ( ( i ** 2 ) * ( f ** 2 ) ) / ( 2 * ( c ** 2 ) ) ) ) )
]
;>> probe OD
;make object! [
;    x: 0.443276834977873
;    y: 0.904071351522265
;    z: 1.23393819942544
;    norm: func [][return (x ** 2) + (y ** 2) + (z ** 2)]
;    is_unit: func [][return ((norm) - 1) ** 2 < 0.0001]
;    azim: func [][
;        tt: arcsine (x / ((x ** 2) + (y ** 2) + (z ** 2))) 
;        return tt
;    ]
;    dip: func [][return arccosine (z / ((x ** 2) + (y ** 2) + (z ** 2)))]
;]
; => le z semble bizarre...

probe OD
OD/azim
OD/dip
OD/is_unit
OD/norm
;>> OD/azim
;== 10.0648773634543
;>> OD/dip
;== 60.8902711774529
;>> OD/is_unit
;== false
;>> OD/norm
;== 2.53644284107259
;
; => pas bon TODO revoir

; Azimut de OD = , en fait, azimut de ON:
; nota bene: calculs directement en degrés chez rebol
azim_downdip: 90 - arctangent (ON/y / ON/x)

; Pendage du plan = plongement de OD:
dip: arccosine ( ON/z )
;== 39.8452276492299
; => correct




;=======================================================

;# N (normal_vect), vecteur unitaire normal
;# au plan du GéolPDA, se définit par xn,
;# yn, zn: les calculs matriciels sont simplistes,
;# il suffit de prendre la dernière colonne de la
;# matrice rotation_matrix; ça se démontre en un tournemain;
;# je mets normal_vect sous forme linéaire:
; ATTENTION! les index changent, entre python et rebol, début 0 ou 1:
normal_vect: reduce [	rotation_matrix/1/3
						rotation_matrix/2/3
						rotation_matrix/3/3 ]

;# et A (axis_vect), vecteur unitaire dans
;# l'allongement du GéolPDA, se définit par
;# xa, ya, za: pareil, calculs simplistes,
;# c'est la seconde colonne de la matrice
;# rotation_matrix:

axis_vect: reduce [	rotation_matrix/1/2
	                rotation_matrix/2/2
        	        rotation_matrix/3/2 ]

;# Il s'agit maintenant de tracer le Té de
;# pendage:
;# Les coordonnées sont centrées autour de
;# O(0,0) autour du croisement des lignes du Té;
;# le Té s'inscrit dans un cercle de rayon 1:
;#
;#          O(0,0)
;#    ------+-------  Exemple d'un Té
;#          |         de pendage pour
;#          |         un plan Nm90/45/S
;#         45
;#
;#
;#   B(-1,0)        A(1,0)
;#    ------+-------  Même Té, points du
;#          |         symbole, avec coordonnées
;#          |
;#         C(0,-0.3)
;#
;#
;# La "queue" du Té a ici une longueur de 0.3;
;# question de goût et d'esthétique; on met ça
;# dans la variable len_queue_t:

len_queue_t: 0.3


;# Il faudra tracer la ligne symbolisant
;# la linéation, mesurée par l'axe A du
;# GéolPDA:
;#
;#   B              A
;#    ------+-------  Même Té, avec une
;#         /|         linéation en plus;
;#        / |         exemple d'une linéation
;#       /  C         d'azimut environ Nm45
;#      /
;#     L
;#


;# Calcul des coordonnées des points A,B,C,L:
;# Un point tmp, colinéaire au projeté de normal_vect
;# sur le plan horizontal, à 1 de l'origine:
tmp: reduce [
	normal_vect/1 / (square-root (((normal_vect/1 ** 2) + (normal_vect/2 ** 2)))) 
	normal_vect/2 / (square-root (((normal_vect/1 ** 2) + (normal_vect/2 ** 2)))) 
]


;##   FIXME: pour un plan strictement horizontal,
;##   on aura une division par zéro: faut gérer ça!
;##     Pour le moment, lors de la démo, il faudra
;##     simplement éviter de poser le GéolPDA à plat...

;# Le point origine O, par convénience...
O: [0 0]

;# on définit les points A et B comme les bouts
;# de la barre du Té:
;# A: on part de tmp et on tourne à gauche de 90°:
A: reduce [   - tmp/2
                tmp/1]
;# B: on repart de tmp et on tourne à droite de 90°:
B: reduce  [    tmp/2
            0 - tmp/1]
; => TRÈS piégeux en Rebol; si on met:{{{ } } }
;B: reduce  [  tmp/2
;            - tmp/1]
;>> B: reduce  [  tmp/2
;[                - tmp/1]
;== [-1.39497166492583]  <= erreur!
;}}}

;# On définit le point C comme le bout
;# de la queue du Té:
C: reduce [ 	tmp/1 * len_queue_t
	      		tmp/2 * len_queue_t]

;# On définit L comme le bout du symbole de
;# la linéation; il s'agit de -axis_vect
;# (compte tenu de la convention de mouvement),
;# projeté sur l'horizontale, donc le vecteur
;# axis_vect[0:2]
L: reduce [	  - axis_vect/1
			0 - axis_vect/2]
;}}}

;# Maintenant, il n'y a plus qu'à tracer
;# le symbole: en pseudo-code:
;#    trace_ligne (A, B)
;#    trace_ligne (O, C)
;#    trace_ligne (O, L)

;# Voilà; tout le reste de mon salmigondis
;# ne sert qu'à afficher ça dans une fenêtres
;# Tk, pour vérifier graphiquement que ça marche.
; {{{
;from Tkinter import *
;
;drawline: func ["tracé d'une ligne dans le canevas can1"] a  b [; #{{{
;	;x1, y1, x2, y2 = a[0], a[1], b[0], b[1]
;	x1: a/1
;	y1: a/2
;	x2: b/1
;	y2: b/2
;
;	factor: 50       ;# on multiplie toutes les xy par un facteur d'échelle
;	foreach v [ x1 y1 x2 y2 ] [
;		vv: to-string v
;		do rejoin [vv ": " vv " * factor"]
;		;do [v: :v * factor]
;	]
;
;	;    x1 *= factor
;	;    y1 *= factor
;	;    x2 *= factor
;	;    y2 *= factor
;	y1: -y1                 ;# on inverse les y
;	y2: -y2
;	offset: [100, 100]      ;# décalage du point haut-gauche vers le milieu
;	x1: x1 + offset[0]
;	y1: y1 + offset[1]
;	x2: x2 + offset[0]
;	y2: y2 + offset[1]
;	can1.create_line(x1, y1, x2, y2, width = 1, fill = coul)
;    #}}}


;coul = 'black'
;fen1 = Tk()
;can1 = Canvas(fen1, bg = 'dark grey', height = 200, width = 200)
;can1.pack(side = LEFT)
;# le tour du graphique: {{{
;drawline([-1, -1], [-1,  1])
;drawline([-1,  1], [ 1,  1])
;drawline([ 1,  1], [ 1, -1])
;drawline([ 1, -1], [-1, -1])
;# }}}
;
;
;# on trace le Té:
;# sa queue:
;drawline(O, C)
;# sa barre de direction:
;drawline(A, B)
;# puis la linéation:
;drawline(O, L)
;
;
;bou1 = Button(fen1, text = 'Quitter', command = fen1.quit)
;bou1.pack(side = BOTTOM)
;
;
;# une grille de textes, pour saisir la matrice de rotation de GéolPDA:
;# TODO
;
;# un bouton pour tout recalculer avec cette matrice:
;# TODO
;
;# un bouton pour retracer le symbole:
;# TODO
;
;# La boucle évènementielle de Tkinter:
;fen1.mainloop()
;fen1.destroy()
;

;}}}



; => non, en VID, plutôt:
; plot is a DRAW dialect block containing the plot:
plot: copy [pen black]

; to offset and scale the output of the plot:
offset: 110x110
scale:  100

; functions to trace graphics elements in the plot block:
trace_line: func [A [block!] B [block!]] [; {{{ } } }
	append plot [line]
	x: (     A/1  * scale) + offset/1
	y: ((0 - A/2) * scale) + offset/2
	append plot as-pair x y

	x: (     B/1  * scale) + offset/1
	y: ((0 - B/2) * scale) + offset/2
	append plot as-pair x y
];}}}
trace_circle: func [center [block!] diameter [number!]] [; {{{ } } }
	append plot [circle]
	x: (     center/1  * scale) + offset/1
	y: ((0 - center/2) * scale) + offset/2
	append plot as-pair x y
	append plot (diameter * scale)
];}}}


; tracé of elements:
;A: [0 0]
;B: [0.5 0.5]
;C: [-.5 0]

append plot [pen black]
;append plot [pen red]
;trace_circle A 0.1
;trace_circle B 0.1
;trace_line A B
;trace_line B C
trace_line A B
trace_line O C
trace_line O L

; axes:
append plot [pen gray]
trace_line [0 -1.1] [0 1.1]
trace_line [-1.1 0] [1.1 0]
; a rondibet:
trace_circle [0 0] 1

append plot [pen black]

ui: [ ; Interface to debug rotation_matrix depatouillating:
	style field field 40x20
	h2 "Matrice de rotation:"
	guide
		return
	f_a: field :a [rotation_matrix/1/1: f_a/text]
	f_b: field :b [rotation_matrix/1/2: f_b/text]
	f_c: field :c [rotation_matrix/1/3: f_c/text]
		return
	f_d: field :d [rotation_matrix/2/1: f_d/text]
	f_e: field :e [rotation_matrix/2/2: f_e/text]
	f_f: field :f [rotation_matrix/2/3: f_f/text]
		return
	f_g: field :g [rotation_matrix/3/1: f_g/text]
	f_h: field :h [rotation_matrix/3/2: f_h/text]
	f_i: field :i [rotation_matrix/3/3: f_i/text]
		return
	guide
	box ivory 220x220 effect [
		;grid 10x10 
		draw plot
	]
	;a: text to-string plot
	btn #"q" "quitte" 	[;quit 
						halt
						]
	; information des 9 zones de texte avec les variables faisant la matrice:
	foreach v variables_short [
		do rejoin ["f_" v "/text: " to-string v]
	]
]
view layout ui



;diagramme: [box 400x400]
;append diagramme compose [
;	circle 100x100 50
;	text 100x10 "N"
;	line 100x50 100x45
;	line 150x100 155x100
;	line 100x150 100x155
;	line 50x100 45x100
;]





; trace_rond: function [][][
;  append diagramme compose [
;   circle 100x100 50
;   text 100x10 "N"
;   line 100x50 100x45
;   line 150x100 155x100
;   line 100x150 100x155
;   line 50x100 45x100
;  ]
;
;  view layout [
;   box white 200x200 effect reduce ['draw diagramme ]
;  ]
; chg_diam_rondibet: function [][][
;
;
;
;append diagramme compose [
;	circle 100x100 50
;	text 100x10 "N"
;	line 100x50 100x45
;	line 150x100 155x100
;	line 100x150 100x155
;	line 50x100 45x100
;]
;
;# }}}

