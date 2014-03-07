REBOL [
	title: "partie d'implementation de Tectri et Rosace en Rebol"
	version: 0.2
	author: "Pierre Chevalier"
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
	0.1	[07/05/2004 {objet rondibet=fenetre avec diagramme rond, rosace ou stereo. Hérité pour rosace.r et tectri.r. premier codage "en aveugle", sur visor. bcp de code reste a traduire de vb; faire tests de vitesses; faire 1 autre test en python}]
	0.2 [5-Mar-2014/23:12:49+1:00 {implémentation qui fonctionne}]
]	]

comment [
; un premier essai, la version 0.1, pas bon: {{{ } } }
rondibet: make object! [
	diamètre en cm
	diametre: make decimal! 5.0
	diagramme: [
	 box 200x200
	]
	trace_rond: function [][][
		append diagramme compose [
			circle 100x100 50
			text 100x10 "N"
			line 100x50 100x45
			line 150x100 155x100
			line 100x150 100x155
			line 50x100 45x100
		]
		view layout [
			box white 200x200 effect reduce ['draw diagramme ]
		]
	chg_diam_rondibet: function [][][
		;Change le diamètre du rondibet et de sa fenêtre; appelé par st_resize
		;                      ^^^^^^
		;                          \-> @#changer partout en rondibet => auquai
		HauteurBarreTitre: 285 ;hauteur de la barre de titre, utilisée dans st.resize
	] 
	]
]
;}}}
	; un second essai, bien mieux, fonctionnel, la version 0.2:{{{ } } }
	draw_block: copy []	; block in DRAW dialect, containing the rondibet
	append draw_block compose [	line-width .5]	; line-width

	factor: 100	; facteur d'échelle: on multiplie les valeurs de 0 à 1 pour que ça soient des entiers, une fois à l'échelle
	margin: 10	; nombre de pixels de marge

	trace_circle: func [x [integer! decimal!] y [integer! decimal!] r [integer! decimal!]] [
		x: to-integer ((x * factor) + factor); * 1.1)
		y: to-integer ((y * factor) + factor); * 1.1)
		x: x + margin
		y: y + margin
		r: to-integer (r * factor)
		append draw_block compose [
			circle (to-pair reduce [x y]) (r)
		]
	]
	trace_line: func [x1 [integer! decimal!] y1 [integer! decimal!] x2 [integer! decimal!] y2 [integer! decimal!]] [
		x1: to-integer ((x1 * factor) + factor); * 1.1)
		y1: to-integer ((y1 * factor) + factor); * 1.1)
		x2: to-integer ((x2 * factor) + factor); * 1.1)
		y2: to-integer ((y2 * factor) + factor); * 1.1)
		x1: x1 + margin
		y1: y1 + margin
		x2: x2 + margin
		y2: y2 + margin
		append draw_block compose [
			line (to-pair reduce [x1 y1])(to-pair reduce [x2 y2])
		]
	]
	init: does [
		; tour:
		trace_circle 0 0 1

		; croix centrale:
		tick: .03
		trace_line      -1 * tick           0        tick           0
		trace_line              0   -1 * tick           0        tick
		;réticule:
		tick: .15
		trace_line              1           0    1 + tick           0
		trace_line             -1           0   -1 - tick           0
		trace_line              0           1           0     1 + tick
		trace_line              0          -1           0    -1 - tick
	]
;test du code:

;stereo: make rondibet
rondibet/init
view layout [
    box ivory to-pair reduce [2 * (rondibet/factor + rondibet/margin) 2 * (rondibet/factor + rondibet/margin)]
	effect reduce ['draw rondibet/draw_block]
	btn #"q" "quitter" [quit]
]
;}}}
]
; un troisième essai, en reprenant ce que je codais le 07_10_2013__08_47_58:

rondibet: make object! [;{{{ } } }
	offset: [1.1 1.1]	; décalage du centre du diagramme
	scale:  100		; facteur d'échelle: on multiplie les valeurs de 0 à 1 pour que ça soient des entiers, une fois à l'échelle
	size: to-pair reduce [(to-integer 2 * scale * offset/1) (to-integer 2 * scale * offset/2)]	; size of the diagram
	plot: copy []	; block in DRAW dialect, containing the rondibet

	append plot compose [pen gray]
	append plot compose [line-width .5]	; line-width

	trace_line: func [A [block!] B [block!]] [;  } } }
		append plot [line]
		x: (     A/1  * scale) + (offset/1 * scale)
		y: ((0 - A/2) * scale) + (offset/2 * scale)
		append plot as-pair x y
		
		x: (     B/1  * scale) + (offset/1 * scale)
		y: ((0 - B/2) * scale) + (offset/2 * scale)
		append plot as-pair x y
	];
	trace_circle: func [center [block!] diameter [number!]] [;  } } }
		append plot [circle]
		x: (     center/1  * scale) + (offset/1 * scale)
		y: ((0 - center/2) * scale) + (offset/2 * scale)
		append plot as-pair x y
		append plot (diameter * scale)
	];

	; un rondibet:
	trace_circle [0 0] 1
	; les axes:
	;append plot [pen gray]
	;trace_line [0 -1.1] [0 1.1]
	;trace_line [-1.1 0] [1.1 0]

	; croix centrale:
	tick: .03
	trace_line  reduce [ (-1 * tick)            0 ] reduce [    tick              0 ]
	trace_line reduce  [           0   (-1 * tick) ] reduce [       0           tick ]
	;réticule:
	tick: .13
	trace_line  reduce [           1             0 ] reduce [(1 + tick)            0 ]
	trace_line  reduce [          -1             0 ] reduce [(-1 - tick)            0 ]
	trace_line  reduce [           0             1 ] reduce [       0     (1 + tick) ]
	trace_line  reduce [           0            -1 ] reduce [       0    (-1 - tick) ]


	append plot compose [pen black]

];}}}

comment [ ; test:
	A: [ 0    0  ]
	B: [ 0.5  0.5]
	C: [-0.5  0  ]
rondibet/trace_line A B
rondibet/trace_line B C

stereo: rondibet/plot	; très curieusement, si on passe rondibet/plot au draw, ça ne fonctionne pas; on doit passer par une variable locale intermédiaire
ui: [
		box ivory rondibet/size effect [
		;draw rondibet/plot	; ne fonctionne pas
		draw stereo			; fonctionne, si l'on passe par une variable intermédiaire
	]
	btn #"q" "quitte" 	[
						;unview halt
						quit 
						]
]
view layout ui
]

