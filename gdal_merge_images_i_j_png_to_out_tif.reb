#!/usr/bin/rebol -qs
rebol []
print "Merge through gdal of files named e.g. 8.png to 35.png into 8_35.tif GeoTiff file.  If no argument is provided, process all files in current directory.  Processed files are moved to vu/ subdirectory."

; Get routines, preferences, and connect to database, if not already done:
if [none? dir_geolpda_local] [
	do load to-file system/options/home/bin/gll_routines.r ]

fichiers_a_traiter_en_ordre: copy []
; Process command line arguments:
either (none? system/options/args) [
	; il n'y a rien en paramètres:
	; on traite tous les fontchiers présents:
	; Old version, without user input:
	fichiers: read %.
	foreach f fichiers [
	 f: to-string f
	 if (parse f [any digit ".png"]) [
		;all [((left f 1) = "0") or ((left f 1) = "1")  ((right f 3) = "png")]
	  append fichiers_a_traiter_en_ordre to-integer (replace f ".png" "")
	 ]
	]
	sort fichiers_a_traiter_en_ordre
	prem: first fichiers_a_traiter_en_ordre
	der:  last fichiers_a_traiter_en_ordre
	]
	[
	arguments: copy system/options/args
	; on traite les options en -quelquechose et on les ôte, pour ne garder que les dates:
	; process options -something and discard them, in order to only keep dates arguments:
	arguments: head arguments
	if error? try [
		switch length? arguments [
			2 		[	prem: to-integer pick arguments 1
						der:  to-integer pick arguments 2	]
			1 		[	prem: 1
						der:  to-integer pick arguments 1	]
			0 		[	print "No arguments supplied on command-line; input numbers corresponding to .png files to be processed:"
						prin "First file number: "
						prem: to-integer input
						prin "Last file number:"
						der:  to-integer input				]
			(> 2) 	[ 	print "Too many arguments supplied on command-line; exit"	
						halt								] ]
	] [
		print "Error: one or two arguments may be used: ending number (starting number being 1 by default) or starting number followed by ending number. Exit."
		halt
	] 

]

ligne_cmd_gdal: rejoin ["gdal_merge.py -of GTiff -o " prem "_" der ".tif "]

either ((length? fichiers_a_traiter_en_ordre) = 0) [
	for i prem der 1 [
		append ligne_cmd_gdal rejoin [i ".png "]
		]
	]
	[
	foreach f fichiers_a_traiter_en_ordre [
		append ligne_cmd_gdal rejoin [f ".png "]
		]	
	]

out: copy ""
print "Command line being processed:"
print ligne_cmd_gdal
;call/wait/output ligne_cmd_gdal out
;print out
call/wait ligne_cmd_gdal

make-dir %vu
ligne_cmd: copy "mv"
for i prem der 1 [
	call/wait rejoin ["mv " i ".p* vu/"]
]

