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
; some generic code: => to be put later in gll_routines.r : ;{{{ } } }
	azimuth_vector: func [{Returns the azimuth of a 3D vector (block! containing 3 numerics), with reference to North = y axis} v [block!]] [;{{{ } } }
		x: v/1
		y: v/2
		either (x = 0) [azim: 0] [azim: 90 - arctangent (y / x )] ;(nota bene: calculs directement en degrés chez rebol)
		case [
			(x  = 0) and (y  = 0) 	[
									;print "-  "
									]
			(x  = 0) and (y >  0) 	[
									;prin  "N  "
									]
			(x >  0) and (y >  0) 	[
									;prin  "NE "
									]
			(x >  0) and (y  = 0) 	[
									;prin  "E  "
									]
			(x >  0) and (y <  0) 	[
									;prin  "SE "
									]
			(x  = 0) and (y <  0) 	[
									;prin  "S  " 
									azim: azim + 180]
			(x <  0) and (y <  0) 	[
									;prin  "SO " 
									azim: azim + 180]
			(x <  0) and (y  = 0) 	[
									;prin  "O  " 
									azim: azim + 180]
			(x <  0) and (y >  0) 	[
									;prin  "NO " 
									azim: azim + 180]
		]
		return azim
	] ;}}}
; test: {{{ } } }
	;u: [0.5 0.5 1] ; azim = N45
	;azimuth_vector u
	;== 45.0
	;u: [-0.45 .45 1]
	;>> azimuth_vector u
	;== 315.0
;}}}
; }}}
orientation: make object! [ ;--## An orientation object, which fully characterises a plane and/or a line: ;==={{{ } } }
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
	;rotation_matrix:	 [ -0.7   0     0.7
	;					    0.6   0.6  -0.5
	;					    0.4   0.8   0.4]

	;(une autre mesure:)
	;rotation_matrix:	 [ 0.95   0.3    -0.1
	;					   -0.3   0.9    -0.3
	;					    0.0   0.3     0.95]

	; L'exemple de matrice pour une pseudomesure de faille Nm30/60/E/55/S/N:
	;rotation_matrix:	 [ -0.7   0     0.7
	;					    0.6   0.6  -0.5
	;					    0.4   0.8   0.4]
	; }}}
	;--## attributes:
	matrix:             copy []
	;axis_vector: make block! []				; 3D unit vector = axis of geolpda = oriented line
	;plane_downdip_azimuth: 0					; down-dip azimuth of plane
	north_reference:    "Nm" ; magnetic North; could be Nu for UTM north, or Ng for geographic North
	plane_quadrant_dip: copy ""
	;--## methods:
	new: func ["Constructor, builds an orientation object! based on a measurement, as given by GeolPDA device, a rotation matrix represented by a suite of 9 values" m] [;{{{ } } }
		make self [
			; Convert matrix m to a block of blocks:
			foreach [a b c] m [append/only matrix to-block reduce [a b c]]
			; variables abcdefghi: juste pour un souci d'ergonomie du codeur: {{{ } } }
			; la notation de la matrice de rotation
			; est bien plus pratique à manier sous
			; forme de abcdefghi, dans les formules:
			; No: too ringard: => yes, ringard, but works...
			a: self/matrix/1/1
			b: self/matrix/1/2
			c: self/matrix/1/3
			d: self/matrix/2/1
			e: self/matrix/2/2
			f: self/matrix/2/3
			g: self/matrix/3/1
			h: self/matrix/3/2
			i: self/matrix/3/3
			; Better, more rebolish: (but doesn't work... :-/ {{{ } } }
			;variables_short: [a b c d e f g h i]
			;count: 1
			;code: copy ""
			;for i 1 3 1[
			;	for j 1 3 1 [
			;		append code rejoin [variables_short/(count) ": self/matrix/" i "/" j]
			;		count: count + 1
			;]	]
			;do code
			;}}}
			;}}}
			; Definition of vectors which fully caracterise the geometry:
			; plane normal vector:: {{{ } } }
			;=======================================================
			;# ON ou N (plane_Normal_vector): vecteur unitaire normal
			;# au plan du GéolPDA, se définit par xn,
			;# yn, zn: les calculs matriciels sont simplistes,
			;# il suffit de prendre la dernière colonne de la
			;# matrice de rotation matrix; ça se démontre en un tournemain;
			;# je mets plane_normal_vector sous forme linéaire:
			; ATTENTION! les index changent, entre python et rebol, début 0 ou 1:
			plane_normal_vector: reduce [	matrix/1/3
											matrix/2/3
											matrix/3/3 ]
			;; une autre formulation: {{{
			;; ON est la normale du plan vers le haut (utile pour 
			;; les pendages inverses, par exemple):
			;ON: make vector [x: c y: f z: i]
			;;>> probe ON
			;;make object! [
			;;    x: 0.7
			;;    y: -0.5
			;;    z: 0.4
			;;]
			;;>>
			;; => semble correct 
			;; }}}
			;; encore une autre:{{{
			;;; mieux (plus "propre", "lisible"):
			;;ON: product_matrix_vector rotation_matrix [0 0 1]
			;;;>> probe ON
			;;;[0.7 -0.5 0.4]
			;;; => semble correct ; mais je préfère le vecteur, finaloumen.
			;;}}}
			; }}}
			; axis vector: : {{{ } } }
			;=======================================================
			; OA ou A est le vecteur de l'Axe du téléphone, vers le haut
			; quand on tient le téléphone normalement.
			; Si l'on mesure une faille, il s'agit du vecteur mouvement du bloc 
			; en place (opposé de celui de la mesure), de sorte qu'une faille
			; _normale_ se mesure avec le téléphone en position _normale_.
			;OA: product_matrix_line rotation_matrix [0 1 0]
			;OA: to-vector OA
			;probe OA
			;OA/azim
			;OA/dip
			;OA/is_unit
			;OA/norm
			;# et A (axis_vector), vecteur unitaire dans
			;# l'allongement du GéolPDA, se définit par
			;# xa, ya, za: pareil, calculs simplistes,
			;# c'est la seconde colonne de la matrice
			;# rotation_matrix:
			axis_vector: reduce [	self/matrix/1/2
									self/matrix/2/2
									self/matrix/3/2 ]
			;}}}
	;down_dip_vect: func [] [;{{{ } } } ;=> annulé: en fait, on s'en fout.
	;	; OD est le vecteur aval-pendage; D pour Down-Dip:
	;	down_dip_vect: reduce [
	;		x: i / (square-root 3) 
	;		y: i * f / ((square-root 2) * c) 
	;		z: square-root ( 1 - (( ( i ** 2 ) / 2 ) - ( ( ( i ** 2 ) * ( f ** 2 ) ) / ( 2 * ( c ** 2 ) ) ) ) )
	;	]
	;	;>> probe OD
	;	;make object! [
	;	;    x: 0.443276834977873
	;	;    y: 0.904071351522265
	;	;    z: 1.23393819942544
	;	;    norm: func [][return (x ** 2) + (y ** 2) + (z ** 2)]
	;	;    is_unit: func [][return ((norm) - 1) ** 2 < 0.0001]
	;	;    azim: func [][
	;	;        tt: arcsine (x / ((x ** 2) + (y ** 2) + (z ** 2))) 
	;	;        return tt
	;	;    ]
	;	;    dip: func [][return arccosine (z / ((x ** 2) + (y ** 2) + (z ** 2)))]
	;	;]
	;	; => le z semble bizarre...
	;	
	;	;probe OD
	;	;OD/azim
	;	;OD/dip
	;	;OD/is_unit
	;	;OD/norm
	;	;;>> OD/azim
	;	;;== 10.0648773634543
	;	;;>> OD/dip
	;	;;== 60.8902711774529
	;	;;>> OD/is_unit
	;	;;== false
	;	;;>> OD/norm
	;	;;== 2.53644284107259
	;	;;
	;	;; => pas bon TODO revoir
	;	;return down_dip_vect
	;];}}}
			; Calculation of variables:
			plane_downdip_azimuth: azimuth_vector plane_normal_vector ; pour l'azimut de downdip: Azimut de OD = , en fait, azimut de ON
			; direction of the plane, from 0 to 180°:
			plane_direction: plane_downdip_azimuth - 90
			if (plane_direction < 0) [plane_direction: plane_direction - 180]
			; dip of the plane, from 0 to 90°:
			plane_dip: arccosine ( plane_normal_vector/3 ) ; Pendage du plan = plongement de OD: ;== 39.8452276492299 ; => correct
			; quadrant of plane dip, in N E S W:
			case [
				((plane_downdip_azimuth >   315) or (plane_downdip_azimuth <=  45))	[plane_quadrant_dip: "N"]
				((plane_downdip_azimuth >   45) and (plane_downdip_azimuth <= 135))	[plane_quadrant_dip: "E"]
				((plane_downdip_azimuth >  135) and (plane_downdip_azimuth <= 225))	[plane_quadrant_dip: "S"]
				((plane_downdip_azimuth >  225) and (plane_downdip_azimuth <= 315)) [plane_quadrant_dip: "W"]
			]
			; line azimuth:
			line_azimuth: azimuth_vector axis_vector
			; line plunge:
			line_plunge: 90 - (arccosine ( axis_vector/3 ))
			; TODO reste à implémenter ces variables:
			;plan_line_pitch:
			;plan_line_pitch_quadrant:
			;plan_line_movement:
		]
	];}}}
	print_matrix: does [ ;{{{ } } }
		return rejoin ["Matrix: " tab self/matrix]
		;		"Normal vector: " 		probe plane_normal_vector newline
		;		"Axis vector: " 		probe axis_vector newline
		;		"Down-Dip azimuth: "	plane_downdip_azimuth newline
		;		"Dip: " 				plane_dip newline
		;		"Plane direction: " 	plane_direction newline
	];}}}
	print_plane: does [ ;{{{ } } }
		return rejoin [
			"Plane: " tab
			north_reference to-string to-integer self/plane_direction "/" to-string to-integer self/plane_dip "/" self/plane_quadrant_dip
		]
	];}}}
	print_line:  does [ ;{{{ } } }
		return rejoin [
			"Line: " tab 
			north_reference to-string to-integer self/line_azimuth "/" to-string to-integer self/line_plunge
		]
	];}}}
	print_plane_line: does [ ;{{{ } } }
		return rejoin [print_matrix newline print_plane newline print_line]
	];}}}
	trace_structural_symbol: func [diag [object!]] ["Return a DRAW dialect block containing the structural symbol";{{{ } } }
		;Je tente de passer en rebol le code python que je fis pour tracer le té de pendage dans le géolpda: {{{ } } }
		;# Il s'agit maintenant de tracer le Té de
		;# pendage:
		;# Les coordonnées sont centrées autour de
		;# O(0,0) autour du croisement des lignes du Té;
		;# le Té s'inscrit dans un cercle de rayon 1:
		;#
		;#          O(0,0)
		;#    ------x-------  Exemple d'un Té
		;#          |         de pendage pour
		;#          |         un plan Nm90/45/S
		;#         45
		;#
		;#
		;#   B(-1,0)        A(1,0)
		;#    x-----+------x  Même Té, points du
		;#          |         symbole, avec coordonnées
		;#          x
		;#         C(0,-0.3)
		;#
		;#
		;# La "queue" du Té a ici une longueur de 0.3;
		;# question de goût et d'esthétique; on met ça
		;# dans la variable len_queue_t:	
		len_queue_t: 0.3
		;
		;# Il faudra tracer la ligne symbolisant
		;# la linéation, mesurée par l'axe A du
		;# GéolPDA:
		;#
		;#   B              A
		;#    x-----+------x  Même Té, avec une
		;#         /|         linéation en plus;
		;#        / x         exemple d'une linéation
		;#       /  C         d'azimut environ Nm45
		;#      x
		;#     L
		;#
		;}}}
		;# Calcul des coordonnées des points A,B,C,L: {{{ } } }
		;# Un point tmp, colinéaire au projeté de plane_normal_vector
		;# sur le plan horizontal, à 1 de l'origine:
		tmp: reduce [
			self/plane_normal_vector/1 / (square-root (((self/plane_normal_vector/1 ** 2) + (self/plane_normal_vector/2 ** 2)))) 
			self/plane_normal_vector/2 / (square-root (((self/plane_normal_vector/1 ** 2) + (self/plane_normal_vector/2 ** 2)))) 
		]
		;
		;##   FIXME: pour un plan strictement horizontal,
		;##   on aura une division par zéro: faut gérer ça!
		;##     Pour le moment, lors de la démo, il faudra
		;##     simplement éviter de poser le GéolPDA à plat...
		;
		;# Le point origine O, par convénience...
		O: [0 0]
		;
		;# on définit les points A et B comme les bouts
		;# de la barre du Té:
		;# A: on part de tmp et on tourne à gauche de 90°:
		A: reduce [   - tmp/2
						tmp/1]
		;# B: on repart de tmp et on tourne à droite de 90°:
		B: reduce  [    tmp/2
					0 - tmp/1]
		;; => TRÈS piégeux en Rebol; si on met:{{{ } } }
		;;B: reduce  [  tmp/2             - tmp/1]
		;;>> B: reduce  [  tmp/2                - tmp/1]
		;;== [-1.39497166492583]  <= erreur!
		;;}}}
		;
		;# On définit le point C comme le bout
		;# de la queue du Té:
		C: reduce [ 	tmp/1 * len_queue_t
						tmp/2 * len_queue_t]
		;
		;# On définit L comme le bout du symbole de
		;# la linéation; il s'agit de -axis_vect
		;# (compte tenu de la convention de mouvement),
		;# projeté sur l'horizontale, donc le vecteur
		;# axis_vector[0:2]
		L: reduce [	  - self/axis_vector/1
					0 - self/axis_vector/2]
		;}}}
		;# Maintenant, il n'y a plus qu'à tracer
		;# le symbole: en pseudo-code:
		;#    trace_ligne (A, B)
		;#    trace_ligne (O, C)
		;#    trace_ligne (O, L)
		; en python tk => passé à la poubelle =>
		; => en VID, plutôt:;{{{ } } }
		; tracé of elements:
		;A: [0 0]
		;B: [0.5 0.5]
		;C: [-.5 0]
		append diag/plot [pen black]
		;append plot [pen red]
		;trace_circle A 0.1
		;trace_circle B 0.1
		;trace_line A B
		;trace_line B C
		diag/trace_line A B
		diag/trace_line O C
		diag/trace_line O L
		;}}}
	];}}}
] ;}}}
diagram: make object! [ ;--## A diagram, which will contain a DRAW sting with the T trace from the orientation measurement: ;{{{ } } }
	; attributes:
		; plot is a DRAW dialect block containing the diagram:
			plot: copy [pen black]
		; to offset and scale the output of the plot:
			offset: 110x110
			scale:  100
	; methods:
		; functions to trace graphics elements in the plot block:
		plot_reset: does [	plot: copy [pen black]]
		trace_line: func ["traces a line from A point to B point; both are block!s" A [block!] B [block!]] [; {{{ } } }
			append plot [line]
			x: (     A/1  * scale) + offset/1
			y: ((0 - A/2) * scale) + offset/2
			append plot as-pair x y
			x: (     B/1  * scale) + offset/1
			y: ((0 - B/2) * scale) + offset/2
			append plot as-pair x y
		];}}}
		trace_circle: func [{traces a circle from center (block! containing xy coordinates) with diameter} center [block!] diameter [number!]] [; {{{ } } }
			append plot [circle]
			x: (     center/1  * scale) + offset/1
			y: ((0 - center/2) * scale) + offset/2
			append plot as-pair x y
			append plot (diameter * scale)
		];}}}
	; "constructor": rest of the code:
		; axes:
			append plot [pen gray]
			; un réticule:
			;trace_line [0 -1.1] [0 1.1]
			;trace_line [-1.1 0] [1.1 0]
	; trace a rondibet:
		trace_circle [0 0] 1
		trace_line [  1  0 ] [  1.1  0  ]
		trace_line [ -1  0 ] [ -1.1  0  ]
		trace_line [  0  1 ] [  0    1.1]
		trace_line [  0 -1 ] [  0   -1.1]
] ;}}}

; USAGE:
; on définit une orientation (la foliation du gneiss basque):/*{{{*/
o: orientation/new [0.375471 -0.866153 -0.32985 0.669867 0.499563 -0.549286 0.640547 -0.0147148 0.767778]
print o/print_matrix
print o/print_plane
print o/print_line
print o/print_plane_line
;/*}}}*/
; on trace son Té sur diagram:/*{{{*/
structural_symbol: diagram/plot
o/trace_structural_symbol diagram
;== [pen black pen gray line 110x165 110x54 line 54x110 165x110 pen black line 152x135 67x84 line 110x110 102x122 line 110x110 153x1...
; le Té est contenu dans diagram/plot:
print mold diagram/plot
print mold structural_symbol
;>> print mold structural_symbol/plot
;[pen black pen gray line 110x165 110x54 line 54x110 165x110 pen black line 152x135 67x84 line 110x110 102x122 line 110x110 153x134]
;/*}}}*/

; on dessine ça dans un layout:
l: layout [
	zone_diagram: box ivory 220x220 effect	[
		;grid 10x10 gray
		draw [circle 100 100 10]]
]
append zone_diagram/effect/draw structural_symbol
view l
show zone_diagram

; a graphical user interface, more simple:
a: [ ;{{{ } } }
ui: layout [ ; Interface to debug rotation_matrix depatouillating:
	h3 "Matrice de rotation:"	;guide return
	field_matrix: field 250 "0.375471 -0.866153 -0.32985 0.669867 0.499563 -0.549286 0.640547 -0.0147148 0.767778" [
		update_matrix
	]
	structural_measurement: area 250x100
	return
	zone_diagram: box ivory 220x220 effect	[
		;grid 10x10
		draw structural_symbol				]	; strange: if I put diagram/plot (which is the same as structural_symbol, it does not work,
												; although diagram/plot points to structural_symbol => ?
	across
	btn #"t" "trace"	[ trace_diagram	]
	btn #"c" "calcule"	[ print "calcule"	]
	btn #"d" "DEBUG"	[?? o
						?? structural_symbol
						]
	btn #"q" "quitte"	[	;quit 
							halt			]
]
trace_diagram: does						[
	print "trace"
	o: orientation/new to-block field_matrix/text
	o/trace_structural_symbol diagram
	show zone_diagram					]
update_matrix: does [
	print "TODO changement matrice"
	o: orientation/new to-block field_matrix/text
	structural_measurement/text: reduce [o/print_plane_line]
	;append zone_diagram/effect/draw structural_symbol
	show zone_diagram
	show structural_measurement
]
field_matrix/text: "0.375471 -0.866153 -0.32985 0.669867 0.499563 -0.549286 0.640547 -0.0147148 0.767778"
show field_matrix
;append zone_diagram structural_symbol
view ui
do-events
] ;}}}
do a
do-events




;-------------------------------------------------------------------##
; Des essais:{{{ } } }
;[0.375471 -0.866153 -0.32985 0.669867 0.499563 -0.549286 0.640547 -0.0147148 0.767778]
; Une mesure réelle du géolpda:
; Exemple réel de plan (sans ligne), en Euskadi:/*{{{*/
;_id	poiname	poitime	elevation	poilat	poilon	photourl	audiourl	note
;358	PCh2013_0639	1377339260698	89.9	43.3359	-1.39078	1377339392897.jpg;1377339414464.jpg		Bel affleurement de gneiss, foliation Nm140/40/W
;_id	poi_id	orientationtype	rot1	rot2	rot3	rot4	rot5	rot6	rot7	rot8	rot9	v1	v2	v3
;851	358	P	0.375471	-0.866153	-0.32985	0.669867	0.499563	-0.549286	0.640547	-0.0147148	0.767778	0	0	0
;
;matrix:           [0.375471 -0.866153 -0.32985 0.669867 0.499563 -0.549286 0.640547 -0.0147148 0.767778]
o: orientation/new [0.375471 -0.866153 -0.32985 0.669867 0.499563 -0.549286 0.640547 -0.0147148 0.767778]
print o/print_plane_line
;=>
;>> o: orientation/new [0.375471 -0.866153 -0.32985 0.669867 0.499563 -0.549286 0.640547 -0.0147148 0.767778]
;>> o/print_plane_line
;Matrix:     0.375471 -0.866153 -0.32985 0.669867 0.499563 -0.549286 0.640547 -0.0147148 0.767778
;Plane:  Nm120/39/S
;Line:   Nm299/0

probe o
print mold o/matrix
print o/a
o/plane_normal_vector
o/axis_vector
o/plane_downdip_azimuth
o/plane_direction
o/plane_dip
o/plane_quadrant_dip
o/line_azimuth
o/line_plunge
o/print_plane_line
;/*}}}*/

; L'exemple de matrice pour une pseudomesure de faille Nm30/60/E/55/S/N:
o: orientation/new [-0.7   0     0.7 0.6   0.6  -0.5 0.4   0.8   0.4]
print o/print_plane_line
;=>
;>> o/print_plane_line
;Matrix:     -0.7 0 0.7 0.6 0.6 -0.5 0.4 0.8 0.4
;Plane:  Nm35/66/E
;Line:   Nm0/53

;# mesure de faille Nm30/60/E/55/S/N:
;rotation_matrix:	 [ -0.7   0     0.7
;					    0.6   0.6  -0.5
;					    0.4   0.8   0.4]

f: orientation/new [ -0.7   0     0.7 0.6   0.6  -0.5 0.4   0.8   0.4]
print f/print_plane_line
;>> f/print_plane_line
;Matrix:     -0.7 0 0.7 0.6 0.6 -0.5 0.4 0.8 0.4
;Plane:  Nm35/66/E
;Line:   Nm0/53

;}}}
;-------------------------------------------------------------------##


;###### Other solution, a function which uses orientation object!, but in a temporary manner, so that an array of measurements would be waste way less memory:
compute_geolpda_orientation_matrix: func ["Takes a rotation matrix as provided by GeolPDA, and outputs a structural measurement, for measured plane and/or line" geolpda_matrix [string! block!]] [ ;{{{ } } }
	; (function was previously named matrix2struct_measure)
	; DEBUG ######
		; L'exemple de matrice pour une pseudomesure de faille Nm30/60/E/55/S/N:
		matrix: {-0.7   0     0.7 0.6   0.6  -0.5 0.4   0.8   0.4}
	; ################
	; If matrix is given as a string!, convert it to a block!:
	if (type? matrix) = string! [matrix: to-block matrix]
	; Check if matrix is well a 9 elements block!:
	if (length? matrix) != 9 [
		print rejoin ["Error, rotation matrix given as argument has " length? matrix " elements instead of 9: matrix must be a 3x3 matrix written as 9 elements"] 
		return none]
	; Check if all 9 elements are numeric:
	bad: false
	foreach v matrix [
		if (all [((type? v) != number!) ((type? v) != decimal!) ((type? v) != integer!)]) [bad: true]
		]
	if bad [ print rejoin ["Error, rotation matrix given as argument contains elements which are not numeric"] return none]
	; If we got that far, no check error found.
	; Build an orientation object!:
	o: orientation/new matrix
	; Get its contents, put it into a *light* object! (without methods):
	res: make object! [
		plane_direction:        o/plane_direction
		plane_dip:              o/plane_dip
		plane_quadrant_dip:     o/plane_quadrant_dip
		plane_downdip_azimuth:  o/plane_downdip_azimuth
		line_azimuth:           o/line_azimuth
		line_plunge:            o/line_plunge
	]
	return res
] ;}}}

; test:
;>> probe compute_geolpda_orientation_matrix {-0.7   0     0.7 0.6   0.6  -0.5 0.4   0.8   0.4}
;make object! [
;    plane_direction: 35.5376777919744
;    plane_dip: 66.4218215217982
;    plane_quadrant_dip: "E"
;    plane_downdip_azimuth: 125.537677791974
;    line_azimuth: 0
;    line_plunge: 53.130102354156
;]
;
