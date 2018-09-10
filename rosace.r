rebol [
 title: "essai d'implementation de Rosace en Rebol"
 version: 0.1
 description: {premier codage "en aveugle", sur visor. bcp de code reste a traduire de vb; faire tests de vitesses; faire 1 autre test en python}
 auteur: "Pierre Chevalier"
 date: 07/05/2004
 ]

;charge l'objet rondibet
; nb: les .r sont renommés en .r.txt, pour passer dans les mémos de pda
do %rondibet.r.txt

mesures: make block! []

;le jeu de mesures test traditionnels depuis 1994 au moins: TEST.ROS
append mesures [26 30 40 30 135 140 45 41 52 10]

rosace: make rondibet
;trace_rond: do rondibet/trace_rond

;variables globales ds vb
;DiamStereo
;flag

;fenetre principale
fen: layout [
	button "tracer"
		[
		redraw
		]
	]

redraw: make function! [] [
	print "REDRAW APPELE"
	RosaceTracage
	]
RosaceTracage: make function! [] [
	len_ticks: .04
	coté_signe: 1.2
	do rondibet/trace_rond
	]
view fen