#!/usr/bin/rebol_core -qs
rebol [
	Title:   "Import assay data from lab into database"
	Name:    gll_bdexplo_import_lab_data_eav.r
	Version: 1.1.0
	Date:    "20-Aug-2013/13:47:08+2:00"
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
	History: [
	1.0.0 [5-Aug-2013/17:53:46 {
		Je fais un script traitant d'un seul coup les résultats 
		analytiques livrés en EAV par Bureau Veritas depuis un 
		systême LIMS.
		Je fais ça en pseudo-code, converti en rebol.}]
	1.0.1 [15-Aug-2013/09:34:48 {
		print "JE NE MARCHE PAS!"	laissé ce script ainsi sur duran à la 
		quit				SMI, de manière à ce qu'il ne tourne PAS
						tant que ça ne marche pas correctement.
						Il faudra éditer, loggé en tant que smiexplo 
						sur duran, le fichier
						/usr/bin/gll_bdexplo_import_lab_data_eav.r
						et y coller le contenu de ce fichier.}]
	1.1.0 [15-Aug-2013/19:14:48 {
		Traitement de données scindées en deux fichiers .csv: usage:
		gll_bdexplo_import_lab_data_eav.r abj13000032_header.csv abj13000032_dataqc.csv
		Réussite, à Cocody Riviera Deux dans embouteillages inénarrables... 
		Tout a marché parfaitement; en revanche, ça a été _très_ long: TODO voir pourquoi}]
	1.1.0 [20-Aug-2013/19:13:50+2:00 {
		Modification pour le format fourni par Veritas avec en-tête et valeurs dans le même fichier}]
	1.1.1 [21-Aug-2013/18:59:58+2:00 {
		Modification pour utilisation à Ity, en incluant les dépendances dans un seul script}]
	1.1.2 [21-Aug-2013/19:26:38+2:00 {
		Correction de bogue mineure, le chemin du fichier n'était pas stocké dans public.lex_datasource; puis appel à rebol_core et non rebol (view implicite), puis UTF8}]
	1.1.3 [ 21-Aug-2013/20:42:43+2:00 {
		Inclusion du code complet de gll_routines, après échec à Ity}]
	1.1.4 [ 21-Aug-2013/20:49:44+2:00 {
		Pas de tests pour chercher gll_routines, après échec à Ity}]
	1.1.5 [ 21-Aug-2013/21:00:39+2:00 {
		.gll_preferences zappé, chargé explicitement (pas beau du tout, réparer TODO}]
	1.1.6 [ 17-Sep-2013/15:18:57+2:00 {suppression du champ job_number, devenu inutile}]
	]
	]
; initialisation: {{{ } } }
; Récupération des routines (et des préférences):
change-dir system/options/path				; on se met dans le répertoire courant (...)

; on a 4 choix:
;catch [
;if error? try [gll_routines: load to-file system/options/home/bin/gll_routines.r
;		throw "gll_routines loaded from ~/bin/"					]
;	[print "-"]
;if error? try [gll_routines: load to-file %/usr/bin/gll_routines.r	
;		throw "gll_routines loaded from /usr/bin/"				]
;	[print "-"]
;if error? try [gll_routines: load to-file rejoin [ system/options/path "gll_routines.r"]	
;		throw "gll_routines loaded from current directory"			]
;	[print "-"]
;if error? try [gll_routines:
;	; mis le contenu de gll_routines.r ici, en faisant en sorte que ça marche
;; En désespoir de cause, si rien de tout cela n'est trouvé, on inclut une 
;; version fixe, "compilée" ainsi:
;;;editor compress to-string read to-file system/options/home/bin/gll_routines.r
;{{{
gll_routines: load [
;   :r bin/gll_routines.r
;/*{{{*/ } } }
rebol [
	Title:   "Routines called by gll_bdexplo* programs"
	Name:    gll_routines
	Version: 1.0.1
	Date:    "21-Aug-2013/16:25:11+2:00"
	Author:  "Pierre Chevalier"
	]
; routines appelées par les programmes rebol de geolllibre


; Récupération des préférences (dbname dbhost user passw opid tmp_schema):
;catch [
;if error? try [	do load to-file system/options/home/.gll_preferences
;		throw ".gll_preferences loaded from ~"]
;	[print "-"]
;if error? try [	do load to-file %/usr/bin/.gll_preferences
;		throw ".gll_preferences load from /usr/bin/"			]
;	[print "-"]
;if error? try [	do load to-file rejoin [ system/options/path ".gll_preferences"]
;		throw ".gll_preferences loaded from current directory"		]
;	[print "-"]
;if error? try [ do load to-file system/options/home/.gll_preferences] [
;	do load to-file %.gll_preferences		; modif chez Corentin sur windows 7
;		throw {.gll_preferences loaded from "system/options/home/"}	]
;	[print "- No .gll_preferences file found."]
;]

; je mets direct le .gll_preferences ici (...):
dbhost: "192.168.1.29"
dbname: "bdexplo"
user:   "smiexplo"
passw: reverse decompress #{789C2BC94BCD4D2D292ECD0200135403E009000000}
opid:	18
tmp_schema:	"tmp_imports"



do [
; inclusion du pilote de Nenad: {{{

REBOL [
	Title: "PostgresQL Protocol"
    Author: "SOFTINNOV"
    Email: pgsql@softinnov.com
    Web: http://rebol.softinnov.org/pgsql/
    Date: 09/02/2003
    File: %pgsql-protocol.r
    Version: 0.9.0
    Purpose: "PostgresQL client protocol implementation for /Core"
]

make root-protocol [

	scheme: 'pgSQL
    port-id: 5432
	port-flags: system/standard/port-flags/pass-thru or 32 ; /binary

	fast-query: none

	sys-copy: 	get in system/words 'copy
	sys-insert: get in system/words 'insert
	sys-pick: 	get in system/words 'pick
	sys-close: 	get in system/words 'close
	net-log: 	get in net-utils	'net-log	
	
	throws: [closed "closed"]
	
;------ Internals --------

	defs: [
		types [
			16		bool			[to logic! find ["t" "true" "y" "yes" "1"]]
			17		bytea			[to-rebol-binary]
			18		char			[to char!]
			19		name			none
			20		int8			[to decimal!]
			21		int2			[to integer!]
			23		int4			[to integer!]
			24		regproc			none
			25		text			none
			26		oid				[to integer!]
			27		tid				none
			28		xid				none
			29		cid				none
			32		SET				none
			210		smgr			none
			600		point 			none
			601		lseg			none
			602		path			none
			603		box				none
			604		polygon			none
			628		line			none
			650		cidr			none
			700		float4			[to decimal!]
			701		float8			[to decimal!]
			702		abstime			none
			703		reltime			none
			704		tinterval		none
			705		unknown			none
			718		circle			none
			790		money			[to money!]
			829		macaddr			none
			869		inet			[to-rebol-inet]
			1033	aclitem			none
			1042	bpchar			none
			1043	varchar			none
			1082	date			[try-to-date]
			1083	time			none
			1114	timestamp		none
			1184	timestamptz		none
			1186	interval		none
			1266	timetz			none
			1560	bit				none
			1562	varbit			none
			1700	numeric			none
			1790	refcursor		none
		]
	]

	locals-class: context [
	;--- Internals (do not touch!)---
		buf-size: 64 * 1024
		state:
		last-status:
		stream-end?:
		buffer:
		cancel-key: none
	;-------
		auto-commit: on		; not used, just reserved for /Command compatibility.
		rows: 10			; not used, just reserved for /Command compatibility.
		auto-conv?: on
		auto-ping?: off		; not yet supported
		matched-rows:
		cursor:
		columns:
		;protocol:			
		;version:
		process-id:
		last-notice:
		error-code:
		error-msg:
		conv-list: none
	]

	column-class: context [name: length: type: flags: none]

	conv-model: make block! length? defs/types
	
;------ Type Conversion ------
	
	extract-conv-list: does [
		blk: defs/types
		forskip blk 3 [append conv-model sys-copy/deep reduce [blk/2 blk/3]]
	]
	
	set 'change-type-handler func [p [port!] type [word!] blk [block!]][
		head change/only next find p/locals/conv-list type blk
	]
	
	try-to-date: func [val][error? try [val: to-date val] val]
	
	to-rebol-inet: func [val][
		set [a b] parse val "/"
		either b [reduce [to tuple! a to integer! b]][to tuple! a]
	]
	
	special: charset [#"'" #"\"]
	digit: charset [#"0" - #"9"]
		
	to-rebol-binary: func [val /local out a b c][
		out: make binary! length? val
		parse/all val [
			some [
				#"\" [
					a: special (sys-insert tail out first a)
					| a: digit b: digit c: digit (
						sys-insert tail out to char! (a/1 - 48 * 8 + b/1 - 48 * 8 + c/1 - 48)
					)
				] | a: skip (sys-insert tail out first a)
			] | end
		]
		out
	]
		
	convert-types: func [p [port!] rows [block!] /local row i
		convert-body action cols col conv-func tmp
	][
		cols: p/locals/columns
		convert-body: make block! 1
		action: [if tmp: sys-pick row (i)]
		foreach col cols [
			i: index? find cols col
			if 'none <> conv-func: select p/locals/conv-list col/type [
				append convert-body append/only compose action head
					sys-insert at compose [change/only at row (i) :tmp] 5 conv-func
			]
		]
		if not empty? convert-body [foreach row rows :convert-body]
	]
	
	decode: func [int [integer!]][any [select defs/types int 'unknown]]

	printable: exclude charset [#" " - #"~"] charset [#"\" #"'"]
	
	to-octal: func [val][
		head sys-insert tail sys-copy "\\" reduce [
			first to string! to integer! val / 64
			first to string! to integer! (remainder val 64) / 8
			to string! remainder val 8
		]
	]
	
	sql-escape: func [value [string!] /local out mark][
		out: make string! 3 * length? value
		parse/all value [
			some [
				mark: [
					printable (sys-insert tail out first mark)
					| skip (sys-insert tail out to-octal to integer! first mark)
				]
			] | end
		]
		out
	]
	
	to-sql: func [value /local res][
		switch/default type?/word value [
			none!	["NULL"]
			date!	[
				rejoin ["'" value/year "-" value/month "-" value/day
					either value: value/time [
						rejoin [" " value/hour	":" value/minute ":" value/second]
					][""] "'"
				]
			]
			time!	[join "'" [value/hour ":" value/minute ":" value/second "'"]]
			money!	[to-sql form value]
			string!	[join "'" [sql-escape value "'"]]
			binary!	[to-sql to string! value]
			tuple!  [to-sql to string! value]
			pair!	[rejoin ["(" value/x "," value/y ")"]]
		][form value]
	]
	
	map-rebol-values: func [data [block!] /local args sql mark][
		args: reduce next data
		sql: sys-copy sys-pick data 1
		mark: sql
		while [found? mark: find mark #"?"][
			mark: sys-insert remove mark either tail? args ["NULL"][to-sql args/1]
			if not tail? args [args: next args]
		]
		net-log sql
		sql
	]

;------ Data reading ------

	int: int32: string: field: fields: len: col: msg: byte: bitmap: bytes: pos: sz: none

	read-byte:	[copy byte skip (byte: to integer! to char! :byte)]
	read-int:	[copy bytes 2 skip (int: to integer! to binary! bytes)]
	read-int32:	[copy bytes 4 skip (int32: to integer! to binary! bytes)]
	read-bytes:	[read-int32 (int32: int32 - sz) copy bytes [int32 skip]]
					
	read: func [[throw] port [port!] /local len][
		pl: port/locals
		if -1 = len: read-io port/sub-port pl/buffer pl/buf-size - length? pl/buffer [
			sys-close port/sub-port
			throw throws/closed
		]
		if positive? len [net-log ["low level read of " len "bytes"]]
		if negative? len [throw "IO error"]
		len
    ]
    
	read-stream: func [port [port!] /wait f-state [word!] /records rows /part count
		/local final complete msg pl pos stopped row stop error test-error test-exit a-data
	][
		pl: port/locals
		bind protocol-rules 'final
		final: f-state
		error: none
		test-error: [if error [pl/stream-end?: true make error! error]]
		test-exit: [
			all [wait pl/state = final]
			all [records part count = length? rows]
		]
		if empty? pl/buffer [read port]
		forever [
			complete: parse/all/case pl/buffer protocol-rules
			either all [complete not wait all [not error tail? pos]][
				clear pl/buffer
				do test-error
				break
			][
				remove/part pl/buffer (index? pos) - 1
				if any test-exit [do test-error	break]
			]
			read port
		]
		if pl/state = 'ready [pl/stream-end?: true]
	]

	protocol-rules: [
		some [ 
			pos: (stop: either any test-exit [length? pos tail pos][pos]) :stop ; exit from parser when needed
			[																	; in a Core2.5 compatible way.
				#"A" [
					read-int32 (net-log join "from " int32)
					copy msg to #"^@" (net-log pl/last-notice: msg) skip
				]
				| #"C" [
					copy msg to #"^@" skip (
						pos: find/reverse tail pl/last-status: msg #" "
						pl/matched-rows: either pos [to integer! trim pos][0]
						pl/state: 'completed
						final: 'ready
					)
				]
				| [#"D" (sz: 4) | #"B" (sz: 0)] [
					(if decimal? fields: divide length? pl/columns 8 [fields: 1 + to integer! fields])
					copy bitmap [fields skip]
					(
						row: make block! length? pl/columns
						fields: length? trim/with sys-copy bitmap: enbase/base bitmap 2 "0"
					)
					fields [read-bytes (append row any [bytes ""])]
					(
						fields: length? pl/columns
						foreach field bitmap [
							row: either field = #"0" [sys-insert row none][next row]
							if zero? fields: fields - 1 [break]
						]
						sys-insert/only tail rows head row
						pl/state: 'fetching-rows
					)
				]
				| #"E" [
					copy error to #"^@" skip (
						if newline = last error [remove back tail error]
						if find [auth pass-required auth-ok] pl/state [
							sys-close port/sub-port
							make error! error
						]
						final: 'ready
					)
				]
				| #"G" [
				
				]
				| #"H" [

				]
				| #"I" [
					skip (pl/state: 'empty final: 'ready)
				]
				| #"K" [
					read-int32 (pl/process-id: int32)
					read-int32 (pl/cancel-key: int32)
				]
				| #"N" [
					copy msg to #"^@" (net-log pl/last-notice: msg) skip
				]
				| #"P" [
					copy msg to #"^@" (pl/cursor: msg) skip
				]
				| #"R" [
					read-int32 a-data: (
						unsupported: func [msg][
							sys-close port/sub-port
							make error! join msg ": unsupported auth method"
						]
						switch int32 [
							0 [pl/state: 'auth-ok]
							1 [unsupported "Kerberos V4"]
							2 [unsupported "Kerberos V5"]
							3 [
								reply-password port none 
								pl/state: 'pass-required
							]
							4 [unsupported "Crypt"]
							5 [
								reply-password port sys-copy/part a-data 4
								a-data: skip a-data 4
								pl/state: 'pass-required
							]
							6 [unsupported "SCM Credential"]
						]
					) :a-data
				]
				| #"T" [
					read-int (pl/columns: make block! max int 1)
					int [
						(col: make column-class [])
						copy string to #"^@" (col/name: string) skip
						read-int32	(col/type: decode int32)
						read-int	(col/length: int)
						read-int32	(col/flags: int32)
						(append pl/columns :col)
					] (pl/state: 'fields-fetched)
				]
				| #"V" [

				]
				| #"Z" (pl/state: 'ready)
			]
		] | end
	]
	
	flush-pending-data: func [port [port!] /local pl len][
		pl: port/locals
		if not pl/stream-end? [
			net-log "flushing unread data..."
			read-stream/records/wait port [] 'ready
			net-log "flush end."
			pl/stream-end?: true
			pl/state: 'ready
		]
	]

;------ Data sending ------

	write-int32: func [value [integer!]][to string! debase/base to-hex value 16]

	write-string: func [value [string!]][head sys-insert tail sys-copy value #"^@"]

	write-lim-string: func [len [integer!] value [string!]][
		head sys-insert/dup tail sys-copy value #"^@" (len - length? value) 
	]
	
	send-packet: func [port [port!] data [string!]][
		write-io port/sub-port to binary! data length? data
		port/locals/stream-end?: false
	]
	
	insert-query: func [port [port!] data [string! block!]][
		send-packet port rejoin ["Q" data #"^@"]
		port/locals/state: 'query-sent
		read-stream/wait port 'fields-fetched
		none
	]
	
	try-reconnect: func [port [port!]][
		net-log "Connection closed by server! Reconnecting..."
		if throws/closed = catch [open port][net-error "Server down!"]
	]
	
	reply-password: func [port data /local tmp][
		data: either data [
			tmp: lowercase enbase/base checksum/method join port/pass port/user 'md5 16
			join "md5" lowercase enbase/base checksum/method join tmp data 'md5 16
		][port/pass]		
		send-packet port rejoin [
			write-int32 5 + length? data		; 4 + 1 for '\0'
			write-string data
		]
	]
	
	do-handshake: func [port [port!] /local pl client-param][
		pl: port/locals: make locals-class []
		pl/state: 'auth
		pl/buffer: make binary! pl/buf-size
		pl/conv-list: sys-copy/deep conv-model

		send-packet port rejoin [
			write-int32 296
			write-int32 131072 ; v2.0
			write-lim-string 64 port/target
			write-lim-string 32 port/user
			write-lim-string 64 ""
			write-lim-string 64 ""
			write-lim-string 64 ""
		]
		
		read-stream/wait port 'ready
		net-log "Connected to server. Handshake OK"
	]

;------ Public interface ------

    init: func [port [port!] spec /local scheme args][
        if url? spec [net-utils/url-parser/parse-url port spec]
        fast-query: either args: find port/target #"?" [
			port/target: sys-copy/part port/target args
			dehex sys-copy next args
		][none]
        scheme: port/scheme 
        port/url: spec 
        if none? port/host [
            net-error reform ["No network server for" scheme "is specified"]
        ] 
        if none? port/port-id [
            net-error reform ["No port address for" scheme "is specified"]
        ]
        if none? port/target [
		    net-error reform ["No database name for" scheme "is specified"]
        ]
        if none? port/user [port/user: make string! 0]
        if none? port/pass [port/pass: make string! 0]
        if port/pass = "?" [port/pass: ask/hide "Password: "]
    ]
    
    open: func [port [port!]][
        open-proto port   
        port/sub-port/state/flags: 524835 ; force /direct/binary mode
        do-handshake port
        port/locals/stream-end?: true	; force stream-end, so 'copy won't timeout !
        if fast-query [
        	insert port fast-query
        	fast-query: none
        ]
        port/state/tail: 10		; for 'pick to work properly
    ]
    
    close: func [port [port!]][
    	port/sub-port/timeout: 4
    	either error? try [
    		send-packet port "X"
    	][net-log "Error on closing port!"][net-log "Close ok."]
        sys-close port/sub-port
    ]
	
	insert: func [[throw] port [port!] data [string! block!] /local res][
		flush-pending-data port
		port/locals/columns: none
		
		if all [port/locals/auto-ping? data <> [ping]][
			net-log "sending ping..."
			res: catch [insert-cmd port [ping]]
			if any [res = throws/closed not res][try-reconnect port]
		]
		if throws/closed = catch [
			if all [string? data data/1 = #"["][data: load data]
			res: either block? data [
				if empty? data [net-error "No data!"]
				either string? data/1 [
					insert-query port map-rebol-values data
				][
					net-error "command dialect not yet supported"
					;insert-cmd port data
				]
			][
				insert-query port data
			]
		][net-error  "Connection lost - Port closed!"]
		res
	]
	
	pick: func [port [port!] data][
		either any [none? data data = 1][
			either port/locals/stream-end? [sys-copy []][copy/part port 1]
		][none]
	]
	
	copy: func [port /part n [integer!] /local rows][
		either not port/locals/stream-end? [
			either all [value? 'part part][
				rows: make block! n
				read-stream/records/part port rows n
			][
				rows: make block! port/locals/rows
				read-stream/records/wait port rows 'ready
				port/locals/stream-end?: true
			]
			if port/locals/auto-conv? [convert-types port rows]
			recycle
			rows
		][none]
	]
	
	; init 'conv-model
	extract-conv-list
	
	;--- Register ourselves. 
	net-utils/net-install pgSQL self 5432
]

;}}}
]

connection_db: does [
	; on fait une connexion à la base de données:
	;do %~/rebol/telech/pgsql-r090/pgsql-protocol.r
	db: open to-url rejoin ["pgsql://" user ":" passw "@" dbhost "/" dbname ]

	run_query: func [sql] [             ; fonction utilitaire
		insert db sql  ; send a SQL query
		sql_result: copy db
		; prendre en compte le résultat de requêtes de type UPDATE ou DELETE
		;either requete_select: [][]
		sql_result_fields: make block! []
		foreach champ db/locals/columns [ append sql_result_fields champ/name ]
		return sql_result]
	]

; des fonctions:
test_datasource_available: func [ new_datasource_id ] [
	; Teste si new_datasource_id est libre dans la base: 
	 sql_string: rejoin ["SELECT * FROM public.lex_datasource WHERE opid = '" 
	                      opid "' AND datasource_id = " new_datasource_id ";"]
	 res: to-string run_query sql_string
	 ;print probe res
	 either ( res = "") [ return true ] [return false ]
	]

chk_file_exists: func [file_in] [
	if error? try [
	file_in_reader: open/string/lines/read to-file file_in
	close file_in_reader
	return true] [
	return false ]
	]

get_new_datasource_id: does [
	; 2013_07_09__09_13_51
		; on n'INSERTe pas tout de suite: on fait valider d'abord, dans une ihm
	sql_string: rejoin ["SELECT max(datasource_id) AS max_datasource_id FROM public.lex_datasource WHERE opid = " opid ";"]
	run_query sql_string
	max_datasource_id: to-integer to-string run_query sql_string
	new_datasource_id: max_datasource_id + 1
	]

generate_sql_string_update: func [new_datasource_id file_in] [
	sql_string_update: rejoin [ "INSERT INTO public.lex_datasource (opid, filename, datasource_id) VALUES (" opid ", '" file_in "', " new_datasource_id ");" ]
	]
run_sql_string_update: does [
	append journal_sql rejoin ["--" now ]
	append journal_sql sql_string_update
	insert db sql_string_update
	?? journal_sql
	]

trim_last_char: func [txt] [
	comment ["Trims last character from a given string"]
	txt: (copy/part txt ((length? txt) - 1))
	return txt
]



; on se met dans le répertoire courant
change-dir system/options/path

; on renseigne un peu l'utilisateur
print "Gll preferences loaded: "
?? dbhost
?? dbname
?? user
?? tmp_schema
print rejoin ["Current working directory: " what-dir ]



;/*}}}*/
]
;}}}
;		throw "gll_routines loaded from current script copy"			]
;	]

if error? try [do gll_routines] [print "Problem, routines not found, cannot continue." quit]

;;; valeurs par défaut à Ity, le plus passe-partout possible
;dbhost: "192.168.1.29"
;dbname: "bdexplo"
;user:   "smiexplo"
;passw: reverse decompress #{789C2BC94BCD4D2D292ECD0200135403E009000000}
;opid:	18
;tmp_schema:	"tmp_imports"
;]


; si passw n'est pas défini, on le demande:
if any [(error? try [(none? passw)]	)
	(passw = none			)
	(passw = ""			)] [
passw: ask/hide "password: "		]

;on récupère le code de gll_bdexplo_new_datasource.r
if error? try [load to-file system/options/home/bin/gll_bdexplo_new_datasource.r	] [
if error? try [do load to-file %usr/bin/gll_bdexplo_new_datasource.r			] [
if error? try [do load to-file %gll_bdexplo_new_datasource.r				] [
;; En désespoir de cause, on inclut le code "mort" ici:
;; editor compress to-string read to-file system/options/home/geolllibre/gll_bdexplo_new_datasource.r
;/*{{{*/
do load #{
789CBD585B73DBC6157E267EC509D28EA898222539C90338AEC651DCD4AD6FB1
D5CCB41A86B30416E4DA0016DA5DE8329DE6B7F4ADD57B5FFACC3FD6EF2C0012
2229C59EA4E5782C90387BEEE73BE7ECE79F8D2A6B4633558C8C9CE98C0E2E6C
503F9D07BD33E532191151F8AD4C5521495021AF28114E585D99580E481409A5
2ACBC82DA47F3113565226AFA76BAA30E8BD12B96744F32C9BCE12795D667A0A
5E1DAAA1097A3F4863952E223A1A1E0E0F83DEB7C2D5C7C2E3AF0FFE586507C7
87478F47C7C7D1F1E3E8E8EB47C7D1E121983FADDC421BD0856F943446D2E942
5E8A0CCF7839098231A94239855FAC70CC3E502981509B1372E686CE7BFE33A6
B7CBDBB82A97B7C69351222D195D39586EA92F9DFFA134CBDB1424B288A5DD0F
124D991609397D003748B237D6C97CA44BE660470B9D4BEF5DB6BBE535349065
B5628665A52CFDC424C1042EDF64F7DB8D735E4D5D91550514CC96FF20BDFC0F
C1E30E4497EC78B2B151A5F37A5A59B8000E887551C898359A26B3D6D8F58F04
3699208EDCA667C8DD94F284DE234285C8A6F62223A8D9F91AD1F984266C8FA2
525858D4127B6FA9C23A53792996DE7DFF624010270B8AA19DA4AAA04B95488E
9093163AE3245D6A65985B86E3CE88C28AE678296161E148780A84B742200B2B
0DFC38A3F09B67DF3D7F45676F9FBE7AF7F4F4ECF9EB57E330605FA9012DFF29
2817265EC8CF58162B96EAA2661B05BDDCCEA7303AA244E30DF2BE571A0541E1
33245385DF2B2BE6929E50B87EF5501E1304E58879AAE20592903A9F27BF5B9B
5E70C444D529A7A94A48544EE7C8BF8B4AE66C6D3F17D7F4888EF63BC2751575
BEFD5C596DAA7374FCF8CBAF3E569D8E9C179BD94FFDC5F2DF4E72CC9BF4A146
87014269DC008E9348851C38A14B950C48BA7888CC07B70481E56C6D951AB6DA
9746A676F51AE24A04180197F49B3FBC7EF98CF54146731837AB15AA431A33EB
02542A6646C50DC95EC7CEA2CA7156B3F66B7AEA3F3ADA8F82B9741B6E842FBC
D078A1D5B597C587ABAC0E1232BA4D287E57E87C0685933D61E6151358A6C8D4
BCF0CE8A759E033765144805D8349BA0815316D9860A979C8DA8AD3D9551B177
03FC354AFA025A73B6A819B87F8BFB80728DAF089D345C4229CD8D28179C58C8
F94CDC0055368C8C6A281CD39FA1AD27A84B928DB6A83978AF8D571F150A7715
7B5CB7F0C57B60482A94DB67305139875F1A0E38BFC42312509ADD698688CE44
FC2131BAA4AB8572FC83888DB636605D0E0E0EE88D304EB169483B24143C8EDC
5885A2D109CDE852C690217D9A5E2A5BAD203F60B31CB733F43248268FAEB59E
9C52BDC51185BF6F6CF336D7EF7C9DF5364151E6A5BB39F13CA6AA60446C9F23
0A439AF0993482EB53CD480E0854C5BC25F1AAD00CCE45B2DCE3DE888966AEA0
CFC338A4F0D45B9A6EAB173601630A6D656D95D3ABB7CC66AD9A9188BD75BEB3
8CBC33800919824361CB9B8B017D0190603990C05FC4C34085D7D5A5517838FF
6218DB4BFA6278FAEE8749CD7EE4E4B58B761B4A76A1AF28F58F637A0DBC47D9
A814B1842A9C40BE0D76F20A097351ED716FDB43A218E93D414D9DF4E3C587A9
E72EAF9545EE3792F63D68F70822DE6C46BE9320352F2487BC54F2AA51DBC84E
BB5D6B4E847F5EF9869C268D0C9171C731F2BD46E8CF297CA58B012CC97836F2
880697712B1C70CEA07D70B54A6BC50DA76DE2AD42ACC36D7FD57943CD1FFFBF
910EBDB4CE98BFEABABEB7729B2D44653859541D639BACF23637263419F9D5E1
E1F59787AB52EB0899C94C5F3D5C741DA8044D5B396746A0C7CE54A6DCF2D6F7
D7368B22AEFFD4CF5F1E80D1EE0B6091F2CEE8B20B91C5BE329173B1AC79DD44
5D79ED519FA62DCBB0768E70303FE129A19E2990571586371E641F03161A69A8
1C3F3BE4D239C667E8190B06C7E5BF0C9E451C434285B9094ED6701A03EC7038
64119C2CABA0631CAE1B0D37679557F93EDDB16BAD73D3C7BAD3705DBF48EF92
DB2BD57FA29087A8F3F085B0AEC375B7F550618365AA0D6DF1F3C8751782C078
A3A76D9AC6F90C80CEEE33881DA3EDF236A2662E6925AD10BB071DB364BB7D46
E45F74B4E9D31611B5A5BCE3380E72339BC303F788F0253D59632710303CF30D
AA4B35A6F9F2B658CD0D3CD3A29989EAA2122AFCC5E2EFE0154FB55D1A64A2CA
C40C75B4757885616E054C4DB2E90F83C6ED32D99CCE767830A4D448EEFBAB75
2C6C91652ED184B152F1E03EAD8330AD4A90C9FA7D6D175E362ADC4356637A4B
DB80D6BDEA4375189C7FA20D226360BE019B54FA6933E95A14D18FA390B866EF
60A657CC6D42A7FB39DCBB17EEB0352874553442DE699A39D7F9F8D5E0B77242
9BDC8D8CF36DD78102B8E69DE315EC4C38DFF859809FEBB4D5DC6FFF34F0A0AE
8A8AFB2F3B9730866099E245A4E9E46B277F5767B4646091859173B4C71ABF6A
082AAB59A6E2E15DD83861276E29DA84924C55ECCC13206CDD0FFD24DE1D539E
CE046330B4DD553F3CCE6E1FAF3BB11FCC9A8973E764BA7338E36161E7D682A6
005FC17DA93239C6274CC4E8C9F14214735E2AF5FAA2A25F41630EE8FE897772
679F3C7DFDF2E5F3B3B1BF42E85D540A9BF479D0CCE23C892302991F62163C79
7DE4480EBCF1F301C8FD74CEE9801967CC2FB0E4679C6EBE75E138403DF7EFEE
FF3CB8F6853F8D6CAE467E874611393B4A8DCE474915FB5590E7B8907A3DEC80
AB55E8BE4DF47FAC0436D263D60316C77E17DDD8BBEC9572F16284AE2FAA8CC7
9062EE16273BD7A6F3E0A899893FCA2E4C8C6F9FBEF371990B93F8016E1B8E1C
FA2187BAD9739A8926400E1FAF85DDA33C6D2C0F0F77961D268D8EFD82D15C52
4026CB9DACC4C21A8C32B1C0A455CF9B414319F89B2FC7257589ED1C7BA337B3
059560B516B4C36FA9E20F3B7D7AE4CBA9D0EE93FB597D73F0FF6B05BE4C51AF
9B76F305D0CAF00DA57E95F6DA7AE8E115E5AEE45F7975F818DBC130D64606BB
7CE073205C71E4495216214C7B606A18375743689FEFBE7FD1BDED63949D496E
2258A11BB2EDF34696C832C4B02FEC875FD8CDA2DDDD2CFC71D4FFCB08FE3F09
27FB7CBD290A5461BF91CC977A37E13E75BF87FBDC0177B63FF8F9AECA1FDB5B
3E45F2AE1EC40E44BEDCB97C5F8D738090B089E8F6A5D524A87B57300666F1C5
193723F6E4DF90B46374532C7D19AFD9638EB73FEC5300FD6ABA8AFCE635515A
15F1FAD2A39E18C6F53CB54385DEF8137003D49320B268EDA9CE126C6A0B9D3C
51056F23C1DF83FF02F5A46671B0180000
}

;/*}}}*/
]]]

; connection à la base
connection_db

; si pas de journal des instructions SQL, on en crée un vide
if error? try [ type? journal_sql ] [journal_sql: [] ]

; un peu d'espace pour la grande instruction SQL:
sql_string: make string! 10000
; }}}
; IFDEBUG: ÉVITER V    ####################################################
;if system/options/args = none [print "Pabon" 	quit]
;if length? system/options/args < 2 [print rejoin ["Pabon: ifo utiliser avec deux fichiers; par exemple: " newline "gll_bdexplo_import_lab_data_eav.r abj13000032_header.csv abj13000032_dataqc.csv"]
;					quit]

if error? try [
if any [((length? system/options/args) <> 1) (system/options/args = none)] [
	[print rejoin ["Error, one single file must be provided as arguments." newline "Example:" newline "gll_bdexplo_import_lab_data_eav.r ABJ13000003.CSV"] quit]
	]
] [print rejoin ["Error, one single file must be provided as arguments." newline "Example:" newline "gll_bdexplo_import_lab_data_eav.r ABJ13000003.CSV"] quit]

; pour format séparé en 2 .csv:
;file_in_header: to-file pick system/options/args 1
;file_in_dataqc: to-file pick system/options/args 2

file_in: to-file pick system/options/args 1
;>> to-file reduce to-string (what-dir to-string file_in)
;== %/home/pierre/smi/transferts/from/sidiki_fofana/2013_08_20/tt/ABJ13000003.CSV
file_in: to-file reduce to-string rejoin [what-dir to-string file_in]

;comment [ ;DEBUG: jeu de test
;	;file_in: %~/smi/transferts/from/sidiki_fofana/2013_08_11/tt/abj13000028.csv
;	;file_in: %~/smi/transferts/from/sidiki_fofana/2013_08_14/abj13000003_dataqc.csv
;	;file_in: %~/smi/transferts/from/sidiki_fofana/2013_08_14/abj13000003_dataqc.csv
;; DEBUG              ####################################################
;
; ;{{{IFDEBUG: FAIRE TOURNER } } } 
;	;change-dir %~/smi/transferts/from/sidiki_fofana/2013_08_15/tt
;	;arg1: "abj13000032_header.csv"
;	;arg2: "abj13000032_dataqc.csv"
;	;file_in_header: to-file arg1
;	;file_in_dataqc: to-file arg2
;	change-dir  %~/smi/transferts/from/sidiki_fofana/2013_08_20/tt/
;	arg1: "ABJ13000003.CSV"
;	file_in: to-file arg1
;
;;}}}

; test si les fichiers existent:
;if not chk_file_exists file_in_header [print "Pabon"	quit]
;if not chk_file_exists file_in_dataqc [print "Pabon"	quit]
if not chk_file_exists file_in [print rejoin "Problem, unable to open file " to-string file_in " ; cannot continue." quit]

; commencer une transaction:
insert db "BEGIN TRANSACTION;"

;##################################

; générer un datasource_id: {{{
print "New datasource_id generation..."
get_new_datasource_id
either (test_datasource_available new_datasource_id) [
	print rejoin ["Ok, proposed datasource_id " new_datasource_id " free in database" ]
	generate_sql_string_update new_datasource_id file_in
	; NB: sql_string_update contient maintenant le SQL à jouer à la fin
	] [
	print rejoin ["Problem, proposed datasource_id " new_datasource_id " already referenced in database: ^/" res ]
	quit ]
; sql_string contient l'ensemble des instructions à jouer, et on peut oublier sql_string_update:
sql_string: rejoin ["" newline sql_string_update]
;}}}
; lecture partie métadonnées (en-tête fichier) et reste des données, dans 2 block!s, header et data: {{{ } } } 
print rejoin ["Reading data from " to-string file_in "..."]
lines: read/lines file_in
header: copy []
data:   copy []
flag_header: true
foreach line lines [
	either flag_header [
		append/only header line
		if any [
			(line = newline) 
			(line = none) 
			(line = "") 
			;((copy/part line 6) = "Jobno,")
			] 
			[flag_header: false]
		] [
		append/only data line
		]
	]
; header contient maintenant les lignes d'en-tête, et
; data   contient maintenant les lignes de données.

; conversion du contenu de header en variables:
foreach l header [
	t: parse/all l ","
	do rejoin [(lowercase to-string t/1) {"} t/2 {"}]
	]

; si tout va bien, les variables suivantes sont définies:/*{{{*/ } } }
labname 
client
validated
job_number
number_of_samples
project
shipment_id
p_o_number
received

; exemple pour le fichier ABJ13000003.CSV:
;
;>> labname 
;== "ACME ANALYTICAL LABORATORIES LTD."
;>> client
;== "Societe Des Mines D'Ity (SMI)"
;>> validated
;== "31-May-13"
;>> job_number
;== "ABJ13000003"
;>> number_of_samples
;== "6"
;>> project
;== "None Given"
;>> shipment_id
;== "BV130425SMI"
;>> p_o_number
;== "2013 04 25"
;>> received
;== "29-May-13"

; /*}}}*/

; contrôle de l'en-tête: {{{ } } }
; non: {{{  } } }
;>> i: 1                                                      
;== 1
;>> foreach x header_h [print rejoin [ {header_h/} i { = "} x {"}] i: i + 1]
;header_h/1 = "Labname"
;header_h/2 = "Client"
;header_h/3 = "Validated"
;header_h/4 = "Job_number"
;header_h/5 = "Number_of_samples"
;header_h/6 = "Project"
;header_h/7 = "Shipment_id"
;header_h/8 = "P_O_number"
;header_h/9 = "Received"
; }}}
either all [
not none? labname 
not none? client
not none? validated
not none? job_number
not none? number_of_samples
not none? project
not none? shipment_id
not none? p_o_number
not none? received
] [
; print " tout baigne "
] [ print rejoin ["Error: data header from " to-string file_in " differs from expected format: " newline ]
	quit]
;}}}

;}}}

; contrôle de l'en-tête: {{{ } } }
data_h: parse/all first data ","
; {{{ } } }
;>> i: 1                                                      
;== 1
;>> foreach x data_h [print rejoin [ {data_h/} i { = "} x {"}] i: i + 1]
;data_h/1 = "Jobno"
;data_h/2 = "Orderno"
;data_h/3 = "Sampletype"
;data_h/4 = "Sampleid"
;data_h/5 = "Scheme"
;data_h/6 = "Analyte"
;data_h/7 = "Value"
;data_h/8 = "Unit"
;data_h/9 = "DetLim"
;data_h/10 = "UpLim"
; }}}
either all [
data_h/1 = "Jobno"
data_h/2 = "Orderno"
data_h/3 = "Sampletype"
data_h/4 = "Sampleid"
data_h/5 = "Scheme"
data_h/6 = "Analyte"
data_h/7 = "Value"
data_h/8 = "Unit"
data_h/9 = "DetLim"
data_h/10 = "UpLim"
] [
; print " tout baigne "
] [ print rejoin ["Error: data header from " to-string file_in " differs from expected format: " newline ]
	quit]
;}}}
print "Check: header data ok"

; importer les données dans les tables:
print "Generation of data input into database..."
s: "', '" ; séparation de 2 textes en SQL (raccourci)
;public.lab_ana_results: {{{ } } }
;>> labname 
;== "ACME ANALYTICAL LABORATORIES LTD."
; => attention, champ trop court dans la table public.lab_ana_results:
;  	labname             | character varying(10)
; => on tronque:		TODO améliorer
;>> first parse labname " "
;== "ACME"
labo: first parse labname " "

sql_string: rejoin [sql_string newline "INSERT INTO public.lab_ana_results (opid,      labname,   jobno,  orderno, sample_id, scheme, analyte, value, sampletype, unit,         datasource, detlim, uplim) VALUES " newline]
foreach line next data [
	b: make block! 100
	append b parse/all line ","
	sql_string:              rejoin [sql_string "("  opid ", '" labo     s  b/1 s     b/2 s      b/4 s   b/5 s    b/6 s  b/7 s       b/3 s b/8 "', " new_datasource_id ", "   b/9 ", " b/10 ")," newline]
	                        ;rejoin [sql_string "("  opid ", '" labname  s  h/1 s     h/2 s      h/4 s   h/5 s    h/6 s  h/7 "', "   h/3 s h/8 s new_datasource_id s   h/9 s h/10 ")," newline]
	]
sql_string: rejoin [copy/part sql_string ((length? sql_string) - 2) ";"]
;}}}

;public.lex_datasource: fait, cf.supra
prin "New datasource generated: "
print new_datasource_id

;public.lab_ana_batches_reception/*{{{*/ } } }

;labname
;client
;validated
;job_number
;number_of_samples
;project
;shipment_id
;p_o_number
;received

client: replace client "'" "\'" ; {Societe Des Mines D'Ity (SMI)}   >:-<
a: to-date validated
validated: rejoin [a/year "-" a/month "-" a/day]
a: to-date received
received:  rejoin [a/year "-" a/month "-" a/day]

tt: {INSERT INTO public.lab_ana_batches_reception 
    (opid,            jobno,             datasource,     labname , client , validated ,      number_of_samples ,     project , shipment_id , p_o_number , received ) VALUES }
tt: rejoin [tt newline "( "  opid ", '" job_number "', " new_datasource_id ", '" labname s client s validated  "', " number_of_samples ", '" project s shipment_id s p_o_number s received "');"]

sql_string: rejoin [sql_string newline tt]


;/*}}}*/


;write %rtr rejoin ["BEGIN TRANSACTION;" newline sql_string]
;write %test.sql sql_string
; =>	(ça marche:) {{{ } } }
;  # pierre@autan: ~/smi/transferts/from/sidiki_fofana/2013_08_15/tt        < 2013_08_15__18_16_50 >
;psql -h autan -d bdexplo -f toto.csv
;ERROR: ld.so: object '/lib/libreadline.so.5' from LD_PRELOAD cannot be preloaded: ignored.
;ERROR: ld.so: object '/lib/libreadline.so.5' from LD_PRELOAD cannot be preloaded: ignored.
;ERROR: ld.so: object '/lib/libreadline.so.5' from LD_PRELOAD cannot be preloaded: ignored.
;ERROR: ld.so: object '/lib/libreadline.so.5' from LD_PRELOAD cannot be preloaded: ignored.
;ERROR: ld.so: object '/lib/libreadline.so.5' from LD_PRELOAD cannot be preloaded: ignored.
;SET
;BEGIN
;INSERT 0 1
;INSERT 0 4
;INSERT 0 1
;COMMIT
;}}}
; => ça remarche: {{{ } } }
;  # pierre@autan: ~/smi/transferts/from/sidiki_fofana/2013_08_20/tt        < 2013_08_20__19_03_00 >
;psql -h autan -d bdexplo -f test.sql 
;SET
;BEGIN
;INSERT 0 1
;INSERT 0 297
;INSERT 0 1
;
; }}}
print "SQL statement to be run:"
print copy/part sql_string 300
print "..."

insert db sql_string
print "Done..."
insert db "COMMIT;"
print "commited => end."

