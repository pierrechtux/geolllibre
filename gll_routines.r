rebol [ 
	Title:   "Rebol routines called by geolllibre gll_* programs"
	IDEA:    "TODO make an automatic system of imports, where a program named abc_ghea_jh_lkk.r would automatically include any file named abc_ghea_jh_*.r and any file named abc_ghea_jh_routines.r. Doing tis recursively would make an easy to maintain tree of dependencies"
	Name:    gll_routines.r
	Version: 1.0.3
	Date:    26-Jan-2014/18:27:07+1:00
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
	1.0.1	[21-Aug-2013/16:25:11+2:00 {Ajout d'utilitaires, de fonctions communes, etc.}]
	1.0.2	[22-Sep-2013/10:31:32+2:00 {Mise au point de la comparaison de structures de bases}]
	1.0.3	[26-Jan-2014/18:27:07+1:00 {Inclusion d'objets et fonction en liaison avec des structures}]
]	]

; Récupération des préférences (dbname dbhost user passw opid tmp_schema): {{{ } } }
catch [
if error? try [	do load to-file system/options/home/.gll_preferences
		throw ".gll_preferences loaded from ~"]
	[print "-"]
if error? try [	do load to-file %/usr/bin/.gll_preferences
		throw ".gll_preferences load from /usr/bin/"			]
	[print "-"]
if error? try [	do load to-file rejoin [ system/options/path ".gll_preferences"]
		throw ".gll_preferences loaded from current directory"		]
	[print "-"]
if error? try [ do load to-file system/options/home/.gll_preferences] [
	do load to-file %.gll_preferences		; modif chez Corentin sur windows 7
		throw {.gll_preferences loaded from "system/options/home/"}	]
	[print "- No .gll_preferences file found."]
] ;}}}

do [ ; inclusion du pilote postgresql de Nenad: {{{ } } }

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
] ;}}}
connection_db: does [ ;{{{ } } }
	; on fait une connexion à la base de données:
	;do %~/rebol/telech/pgsql-r090/pgsql-protocol.r
	if error? try 	[
			db: open to-url rejoin ["pgsql://" user ":" passw "@" dbhost "/" dbname]
			print rejoin [{Connected to database } dbname { hosted by } dbhost {, logged in as role } user]
	] 		[
			print rejoin [{Error while trying to connect to database } dbname { hosted by } dbhost {, as role } user]
	]
] ;}}}
do [ ; inclusion de l'utilitaire CSV.r : {{{ } } }
;do %~/rebol/library/scripts/csv.r
;:r ~/rebol/library/scripts/csv.r

REBOL [
    Title: "CSV"
    Date: 29-Sep-2002
    Name: 'CSV
    File: %CSV.r
    Purpose: ".CSV file manipulation functions."
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    Example: [
    write %Test.csv Mold-CSV [
        ["Column One" "Column Two" "Total Column"] 
        [1 2 3] 
        [2 3 5] 
        [3 4 7]
    ] 
    read %Test.csv 
    delete %Test.csv
]
    library: [
        level: 'beginner 
        platform: none 
        type: 'tool 
        domain: 'DB 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

Mold-CSV: function [
	"Molds an array of values into a CSV formatted string."
	Array [block!]	"The array of values."
	] [Page Line Heading Type] [
	Page: make block! length? Array
	Line: make string! 1000
	if parse Array/1 [
		some [
			set Heading [word! | string!] into [
				'string! (Type: "String")
				| 'date! (Type: "Date")
				| 'logic! (Type: "Boolean")
				| 'integer! (Type: "Int")
				| 'decimal! (Type: "float")
				] (
				all [
					string? Heading
					found? find Heading #","
					Heading: mold Heading
					]
				repend Line [
					Heading #":" Type #","
					]
				)
			]
		end
		] [
		Array: next Array
		remove back tail Line
		append Line newline
		append Page copy Line
		]
	clear Line
	foreach Row Array [
		foreach Item Row [
			;all [				; modif, to match sql2csv output
			;	string? :Item
			;	found? find Item #","
			;	Item: mold Item
			;	]
			;all [
			;	none? :Item
			;	;Item: #" "	; A blank/space works better as a "none" value.
			;	;Item: ""	; A blank/space works better as a "none" value => not, to be coherent with sql2csv output
			;	]
			if (logic? :Item) [
				either :Item [
					Item: "t"
				] [
					Item: "f"
				]
			]
			switch :Item [
				"true"  [Item: "t"]
				"false" [Item: "f"]
			]
			either (none? :Item) [
				] [
				Item: rejoin [{"} :Item {"}]
				]
			insert tail Line join :Item #","
			]
		remove back tail Line
		append Line newline
		append Page copy Line
		clear Line
		]
	rejoin Page
	]

]
;}}}
do [	; inclusion de l'utilitaire csv-tools.r:;/*{{{*/ } } }

;do %~/rebol/library/scripts/csv.r
;:r ~/rebol/library/scripts/csv-tools.r

REBOL [
	Title: "CSV Handling Tools"
	Author: "Brian Hawley"
	File: %csv-tools.r
	Date: 20-Dec-2011
	Version: 1.1.5
	Purpose: "Loads and formats CSV data, for enterprise or mezzanine use."
	Library: [
		level: 'intermediate
		platform: 'all
		type: [tool idiom]
		domain: [database text file]
		tested-under: [2.7.8.3.1 2.100.111.3.1]
		license: 'mit
	]
	History: [
		1.0.0 5-Dec-2011 "Initial public release"
		1.1.0 6-Dec-2011 "Added LOAD-CSV /part option"
		1.1.1 13-Dec-2011 "Added money! special case to TO-CSV"
		1.1.2 18-Dec-2011 "Fixed TO-ISO-DATE for R2 with datetimes"
		1.1.3 19-Dec-2011 "Sped up TO-ISO-DATE using method from Graham Chiu"
		1.1.4 20-Dec-2011 "Added /with option to TO-CSV"
		1.1.5 20-Dec-2011 "Fixed a bug in the R2 TO-CSV with the number 34"
	]
]

comment {
This script includes versions of these functions for both R2 and R3. The R2
versions require either 2.7.7+ or many functions from R2/Forward. The R3
functions work with any version since the PARSE revamp.

The behavior of the functions is very similar to that of the mezzanines of
recent releases of REBOL, with similar treatment of function options and
error handling, and demonstrates some more modern REBOL techniques. It may be
useful to compare the R2 and R3 versions of the functions, to see how the
changes between the two platforms affects how you would optimize code. The
LOAD-CSV functions both take into account the limitations of their respective
PARSE dialects when it comes to handling string and binary code, and PARSE
control flow behavior.

The standards implemented here are http://tools.ietf.org/html/rfc4180 for CSV
and http://en.wikipedia.org/wiki/ISO_8601 for date formatting, falling back to
Excel compatibility where the standards are ambiguous or underspecified, such
as for handling of malformed data. All standard platform newlines are handled
even if they are all used in the same file; the complexity of doing this is
why the newline delimiter is not an option at this time. Binary CSV works.
Passing a block of sources to LOAD-CSV loads them all into the same output
block, in the order specified.

There was no point in indluding a SAVE-CSV since it's pretty much a one-liner.
Just use WRITE/lines MAP-EACH x data [TO-CSV :x].

Warning: LOAD-CSV reads the entire source data into memory before parsing it.
You can use LOAD-CSV/part and then LOAD-CSV/into to do the parsing in parts.
An incremental reader is possible, but might be better done as a csv:// scheme.
}

either system/version > 2.100.0 [ ; R3

to-iso-date: func [
	"Convert a date to ISO format (Excel-compatible subset)"
	date [date!] /utc "Convert zoned time to UTC time"
] [
	if utc [date: date/utc] ; Excel doesn't support the Z suffix
	either date/time [ajoin [
		next form 10000 + date/year "-"
		next form 100 + date/month "-"
		next form 100 + date/day " "  ; ... or T
		next form 100 + date/hour ":"
		next form 100 + date/minute ":"
		next form 100 + date/second  ; ... or offsets
	]] [ajoin [
		next form 10000 + date/year "-"
		next form 100 + date/month "-"
		next form 100 + date/day
	]]
]

to-csv: funct/with [
	"Convert a block of values to a CSV-formatted line in a string."
	data [block!] "Block of values"
	/with "Specify field delimiter (preferably char, or length of 1)"
	delimiter [char! string! binary!] {Default ","}
	; Empty delimiter, " or CR or LF may lead to corrupt data
] [
	output: make block! 2 * length? data
	delimiter: either with [to-string delimiter] [","]
	unless empty? data [append output format-field first+ data]
	foreach x data [append append output delimiter format-field :x]
	to-string output
] [
	format-field: func [x [any-type!] /local qr] [
		; Parse rule to put double-quotes around a string, escaping any inside
		qr: [return [insert {"} any [change {"} {""} | skip] insert {"}]]
		case [
			none? :x [""]
			any-string? :x [parse copy x qr]
			:x =? #"^(22)" [{""""}]  ; =? is the most efficient equality in R3
			char? :x [ajoin [{"} x {"}]]
			money? :x [find/tail form x "$"]
			scalar? :x [form x]
			date? :x [to-iso-date x]
			any [any-word? :x binary? :x any-path? :x] [parse to-string :x qr]
			'else [cause-error 'script 'expect-set reduce [
				[any-string! any-word! any-path! binary! scalar! date!] type? :x
			]]
		]
	]
]

load-csv: funct [
	"Load and parse CSV-style delimited data. Returns a block of blocks."
	source [file! url! string! binary! block!] "File or url will be read"
	/binary "Don't convert the data to string (if it isn't already)"
	/with "Specify field delimiter (preferably char, or length of 1)"
	delimiter [char! string! binary!] {Default ","}
	/into "Insert into a given block, rather than make a new one"
	output [block!] "Block returned at position after the insert"
	/part "Get only part of the data, and set to the position afterwards"
	count [integer!] "Number of lines to return"
	after [any-word! any-path! none!] "Set to source after decoded"
] [
	if block? source [ ; Many sources, load them all into the same block
		unless into [output: make block! length? source]
		unless with [delimiter: #","]
		foreach x source [
			assert/type [x [file! url! string! binary!]]
			output: apply :load-csv [x binary true delimiter true output]
		]
		return either into [output] [head output]
	]
	; Read the source if necessary
	if any [file? source url? source] [
		source: either binary [read source] [read/string source]
		assert/type [source [string! binary!]] ; It could be something else
		; /string or not may not affect urls, but it's not this function's fault
	]
	; Use to-string if string conversion needed, pass-through function otherwise
	emit: either any [string? source binary] [func [x] [:x]] [:to-string]
	; Prep output and local vars
	unless into [output: make block! 1]
	line: [] val: make source 0
	; Parse rules
	if all [not char? delimiter: any [delimiter ","] empty? delimiter] [
		cause-error 'script 'invalid-arg delimiter
	]
	either binary? source [ ; You need binary constants when binary parsing
		unless binary? delimiter [delimiter: to-binary delimiter]
		dq: #{22} valchars: [to [delimiter | #{0D0A} | #{0D} | #{0A} | end]]
	][ ; You need string or char constants when string parsing
		if binary? delimiter [delimiter: to-string delimiter]
		dq: {"} valchars: [to [delimiter | crlf | cr | lf | end]]
	]
	value: [
		; Value in quotes, with Excel-compatible handling of bad syntax
		dq (clear val) x: to [dq | end] y: (insert/part tail val x y)
		any [dq x: dq to [dq | end] y: (insert/part tail val x y)]
		[dq x: valchars y: (insert/part tail val x y) | end]
		(insert tail line emit copy val) |
		; Raw value
		copy x valchars (insert tail line emit x)
	]
	if part [part: [if (positive? -- count)]] ; Test must succeed to continue
	parse source [any [
		not end part (line: make block! length? line)
		value any [delimiter value] [crlf | cr | lf | end]
		(output: insert/only output line) source:
	]]
	if after [set after source]
	either into [output] [head output]
]

] [ ; else R2

to-iso-date: func [
	"Convert a date to ISO format (Excel-compatible subset)"
	date [date!] /utc "Convert zoned time to UTC time"
] [
	if utc [date: date + date/zone date/zone: none] ; Excel doesn't support the Z suffix
	either date/time [ajoin [
		next form 10000 + date/year "-"
		next form 100 + date/month "-"
		next form 100 + date/day " "  ; ... or T
		next form 100 + date/time/hour ":"
		next form 100 + date/time/minute ":"
		next form 100 + date/time/second  ; ... or offsets
	]] [ajoin [
		next form 10000 + date/year "-"
		next form 100 + date/month "-"
		next form 100 + date/day
	]]
]

to-csv: funct/with [
	"Convert a block of values to a CSV-formatted line in a string."
	[catch]
	data [block!] "Block of values"
	/with "Specify field delimiter (preferably char, or length of 1)"
	delimiter [char! string! binary!] {Default ","}
	; Empty delimiter, " or CR or LF may lead to corrupt data
] [
	output: make block! 2 * length? data
	delimiter: either with [to-string delimiter] [","]
	unless empty? data [insert tail output format-field first data data: next data]
	foreach x data [insert insert tail output delimiter format-field get/any 'x]
	to-string output
] [
	format-field: func [x [any-type!]] [case [
		any [not value? 'x error? get/any 'x] [throw-error 'script 'expect-set [
			[any-string! any-word! any-path! binary! scalar! date!] type? get/any 'x
		]]
		none? :x [""]
		any-string? :x [ajoin [{"} replace/all copy x {"} {""} {"}]]
		:x == #"^(22)" [{""""}]  ; Weirdly, = and =? return true when x is 34
		char? :x [ajoin [{"} x {"}]]
		money? :x [find/tail form x "$"]
		scalar? :x [form x]
		date? :x [to-iso-date x]
		any [any-word? :x binary? :x any-path? :x] [
			ajoin [{"} replace/all to-string :x {"} {""} {"}]
		]
		'else [throw-error 'script 'expect-set reduce [
			[any-string! any-word! any-path! binary! scalar! date!] type? :x
		]]
	]]
]

load-csv: funct [
	"Load and parse CSV-style delimited data. Returns a block of blocks."
	[catch]
	source [file! url! string! binary! block!] "File or url will be read"
	/binary "Don't convert the data to string (if it isn't already)"
	/with "Specify field delimiter (preferably char, or length of 1)"
	delimiter [char! string! binary!] {Default #","}
	/into "Insert into a given block, rather than make a new one"
	output [block! list!] "Block returned at position after the insert"
	/part "Get only part of the data, and set to the position afterwards"
	count [integer!] "Number of lines to return"
	after [any-word! none!] "Set to data at position after decoded part"
] [
	if block? source [ ; Many sources, load them all into the same output block
		unless into [output: make block! length? source]
		unless with [delimiter: ","]
		x: [file! url! string! binary!]
		foreach y source [
			unless find x type?/word y [
				cause-error 'script 'expect-set reduce [x type? :y]
			]
			either binary [
				output: load-csv/binary/with/into y delimiter output
			] [
				output: load-csv/with/into y delimiter output
			]
		]
		return either into [output] [head output]
	]
	; Read the source if necessary
	if any [file? source url? source] [throw-on-error [
		source: either binary [read/binary source] [read source]
	]]
	unless binary [source: as-string source] ; No line conversion
	; Use either a string or binary value emitter
	emit: either binary? source [:as-binary] [:as-string]
	; Prep output and local vars
	unless into [output: make block! 1]
	line: [] val: make string! 0
	; Parse rules
	valchars: remove/part charset [#"^(00)" - #"^(FF)"] crlf
	case [
		any [char? delimiter: any [delimiter ","] last? delimiter] [ ; One char
			valchars: compose [any (remove/part valchars delimiter)]
		]
		empty? delimiter [throw-error 'script 'invalid-arg delimiter]
		'else [ ; Multi-character delimiter needs special handling
			remove/part valchars copy/part as-string delimiter 1
			valchars: compose/deep [any [
				some (valchars) | y: delimiter :y break | (first as-string delimiter)
			]]
		]
	]
	value: [
		; Value in quotes, with Excel-compatible handling of bad syntax
		{"} (clear val) x: [to {"} | to end] y: (insert/part tail val x y)
		any [{"} x: {"} [to {"} | to end] y: (insert/part tail val x y)]
		[{"} x: valchars y: (insert/part tail val x y) | end]
		(insert tail line emit copy val) |
		; Raw value
		x: valchars y: (insert tail line emit copy/part x y)
	]
	part: pick [ ; Rule must fail and go to the alternate in order to continue
		[end skip]  ; Will always fail, so the break won't be reached
		[(cont: if positive? count [count: count - 1 [end skip]]) cont]
		; While count is positive, cont is set to [end skip], which will fail
		; and go the alternate. Otherwise, cont is set to none, which will
		; succeed, and then the subsequent break will stop the parsing.
		; Parsing control flow can get a little convoluted at times in R2.
	] not part
	; as-string because R2 doesn't parse binary that well
	parse/all as-string source [z: any [
		end break | part break |
		(line: make block! length? line)
		value any [delimiter value] [crlf | cr | lf | end]
		(output: insert/only output line)
	] z:]
	if after [set after either binary? source [as-binary z] [z]]
	also either into [output] [head output]
		(source: output: line: val: x: y: none) ; Free the locals
]

]

]
;/*}}}*/

; === functions and objects definitions ==========
; functions related to database:
run_query: func ["Utility function: sends a SQL query, returns the result as a block named sql_result; sql_result_fields contains the fields" sql] [ ; {{{ } } }
	if error? try [	insert db sql  ; send a SQL query
			] [ print "**Error**"	; TODO mieux gérer l'erreur
			]
	sql_result: copy db
	; TODO prendre en compte le résultat de requêtes de type UPDATE ou DELETE
	;either requete_select: [][]
	sql_result_fields: make block! []
	foreach field db/locals/columns [
		either ((type? field) = object!) [
			; using postgresql driver
			append sql_result_fields field/name
		][
			; using btn sqlite driver
			append sql_result_fields field
		]
	]
	return sql_result
] ; }}}
run_sql_string_update: does [ ;{{{ } } }
	append journal_sql rejoin ["--" now ]
	append journal_sql sql_string_update
	insert db sql_string_update
	?? journal_sql
	] ;}}}
do_psql: func ["Prend du SQL en entrée, et fait tourner psql avec, en renvoyant la sortie" sql_text] [ ;{{{ } } }
	;TODO: ajouter un raffinement /unaligned qui rajoute le flag "-A" pour psql
	;TODO: pouvoir choisir psql (pour les plateformes à la noix qui l'ont pas dans le $PATH...)
	cmd: rejoin [{echo "} sql_text {" | psql -X -d } dbname { -h } dbhost]
	tt:  copy ""
	err: copy ""
	call/wait/output/error cmd tt err
	return tt
	] ;}}}
compare_schemas_2_bdexplos: function ["Compare structure from two running instances of bdexplo" dbhost1 dbname1 dbhost2 dbname2][][ ; {{{ } } }
	;dbhost1: "autan"  dbname1: "bdexplo"  dbhost2: "autan"  dbname2: "bdexplo_smi"
	;TODO à déplacer dans un module utilitaire plus général, à distribuer hors gll, pour tout postgresql
	schemas_exclus: ["amc" "backups" "bof" "information_schema" "input" "pg_catalog" "pg_toast" "pg_toast_temp_1" "smi" "tanguy" "tmp_a_traiter" "tmp_imports" "tmp_ntoto" "zz_poubelle" "tmp_a_traiter" "pierre" "input" "marie_cecile" "tanguy" "kalvin"]

	; première solution: on fait un pg_dump de la base
	;   => 	abandonné, le résultat n'est pas trié, et incomparable,
	;	même avec le secours de pg_dump_splitsort.py	{{{ } } }
	;fabrique_cmd: does [
	;	cmd: rejoin ["pg_dump -s -h " dbhost " " dbname " -U postgres"]
	;	foreach s schemas_exclus [
	;		append cmd rejoin [ " -N " to-string s]
	;		]
	;	append cmd "> tmp_schema"
	;]
	
	;dbhost: dbhost1
	;dbname: dbname1
	;fabrique_cmd
	;cmd1: rejoin [cmd "1.sql"]
	;
	;dbhost: dbhost2
	;dbname: dbname2
	;fabrique_cmd
	;cmd2: rejoin [cmd "2.sql"]
	;
	;tt:  copy ""
	;err: copy ""
	;call/wait/output/error cmd1 tt err
	;call/wait/output/error cmd2 tt err
	;cmd: {pg_dump_splitsort.py tmp_schema1.sql
	;mv 0000_prologue.sql tmp_schema1_0000_prologue.sql
	;pg_dump_splitsort.py tmp_schema2.sql
	;mv 0000_prologue.sql tmp_schema2_0000_prologue.sql
	;#vimdiff tmp_schema1_0000_prologue.sql tmp_schema2_0000_prologue.sql
	;}
	;call/wait cmd
	;print cmd1
	;print cmd2
	;print cmd
	
	comment [ ; {{{ } } }
	;pg_dump -s -h autan bdexplo -N amc -N  amc                -N  backups             -N  bof                -N information_schema  -N  input               -N  pg_catalog          -N  pg_toast            -N  pg_toast_temp_1     -N  smi                 -N  tanguy              -N  tmp_a_traiter       -N  tmp_imports         -N  tmp_ntoto           -N  zz_poubelle        > schema_bdexplo_autan_.sql
	;pg_dump -U postgres -s -h duran bdexplo -N information_schema -N  input               -N  pg_catalog          -N  pg_toast            -N  pg_toast_temp_1     -N  tanguy              -N  tmp_imports         -N  zz_poubelle        > schema_bdexplo_duran_.sql
	;#vimdiff schema_bdexplo_autan_.sql schema_bdexplo_duran_.sql 
	;grep -v '^--' < schema_bdexplo_autan_.sql | grep -v '^$' > schema_bdexplo_autan_nocomment_.sql
	;grep -v '^--' < schema_bdexplo_duran_.sql | grep -v '^$' > schema_bdexplo_duran_nocomment_.sql
	;vimdiff schema_bdexplo_autan_nocomment_.sql schema_bdexplo_duran_nocomment_.sql
	] ; }}}
	;}}}

	; seconde solution: on fait pour chaque table un pg_dump, qu'on agrège au fur et à mesure
	fabrique_cmd: does [ ;{{{ } } }
		write to-file filename rejoin ["-- bdexplo dump generated by gll_routines.r/compare_schemas_2_bdexplos: " newline "-- host:" dbhost " dbname: " dbname newline "-- " now]
		; la liste des tables avec leurs schémas:
		tables: run_query "SELECT schemaname, tablename FROM pg_tables WHERE tableowner <> 'postgres' ORDER BY schemaname, tablename;"
		cmd: copy {}
		foreach t tables [	; pour chaque table
			;print "----------------------"	DEBUG
			;?? t
			;print t/1
			;print t/2
			if not (find schemas_exclus t/1) [ ; si le schéma n'est pas dans la liste des schémas exclus, on procède:
				;filename: rejoin ["tt_" dbhost "_" dbname "_" t/1 "_" t/2]
				;?? filename
				append cmd rejoin ["pg_dump -s -h " dbhost " " dbname " -U postgres -t " t/1 "." t/2 { | grep -v "^^--" >> } filename newline]
		]	]
		;print cmd
	] ; }}}
	
	dbhost: dbhost1
	dbname: dbname1
	filename: "tt_gll_1.sql"
	filename1: copy filename
	close db
	connection_db
	fabrique_cmd
	err: copy ""
	call/wait/error cmd err
	if err [print rejoin ["Error while dumping database structure using command: " newline cmd newline {Error message, if any: "} err {"}]]
	
	dbhost: dbhost2
	dbname: dbname2
	filename: "tt_gll_2.sql"
	filename2: copy filename
	close db
	connection_db
	fabrique_cmd
	err: copy ""
	call/wait/error cmd err
	if err [print rejoin ["Error while dumping database structure using command: " newline cmd newline {Error message, if any: "} err {"}]]

	; les dumps sont générés, on les compare:
	print "Structure dumps generated, comparison: "
	cmd: rejoin ["diff " filename1 " " filename2]
	print cmd
	tt: copy ""
	err: copy ""
	call/wait/output/error cmd tt err
	if err [print "Error while running diff"]
	print "diff output:"
	print tt

	return tt
]; }}}
sql_result_csv: does ["Utility function to be run after run_query: returns a .csv dataset from sql_result_fields and sql_result datasets" ; {{{ } } }
	tt: copy []
	append/only tt sql_result_fields
	append      tt sql_result
	return Mold-CSV tt
] ;}}}

; fonctions utilitaires:
; Definition of standard charsets useful for PARSEing: {{{ } } } 
	letter: charset [#"a" - #"z" #"A" - #"Z"]
	digit: charset  [#"0" - #"9"]
	space: charset  [#" "]
	letter-or-digit: union letter digit
	letter-or-digit-nospace: exclude letter-or-digit space
	digit-decimalplace: union digit charset [#"."]
;}}}
chk_file_exists: func ["Simply checks for the existence of a file" file_in] [ ;{{{ } } }
	if error? try [
	file_in_reader: open/string/lines/read to-file file_in
	close file_in_reader
	return true] [
	return false ]
	] ;}}}
trim_last_char: func ["Trims last character from a given string" txt] [ ;{{{ } } }
	txt: (copy/part txt ((length? txt) - 1))
	return txt
	] ;}}}
substring: func ["substring: useless, but still, sometimes useful" string [string!] offset [integer!] length [integer!]] [ ;{{{ } } }
    copy/part at string offset length
];}}}
pad: func [ ;{{{ } } }
 "Pads a value with leading zeroes or a specified fill character."
  val [string! number!] n [integer!]
  /with c [char!] "Optional Fill Character"
][
  head insert/dup val: form val any [all [with c] #"0"] n - length? val] ;}}}
; continue: as in python; to use in a loop, do: "loop [catch[...]]"/*{{{*/ } } }
continue: does [;suivant conseil Nenad, pour mimer le comportement d'un continue dans une boucle

throw 'continue]
;/*}}}*/
; Les dates du geolpda sont au format epoch en millisecondes;
; voici une fonction pour convertir les epoch en date: [{{{ TODO erase this function from gll_geolpda_report_generator.r
epoch-to-date: func [
	"Return REBOL date from unix time format"
	epoch [integer!] "Date in unix time format"
	] [
	day:       1-Jan-1970 + (to-integer (epoch / 86400))
	hours:     to-integer   (((epoch // 86400)) /  3600)
	minutes:   to-integer  ((((epoch // 86400)) // 3600) /  60)
	seconds:   to-integer  ((((epoch // 86400)) // 3600) // 60)
	return (rejoin [day "/" hours ":" minutes ":" seconds]) ; + now/zone 
															   ; ^ TODO un 
															   ;beau jour, 
															   ;remettre ça;
															   ;ça boguait.
] ;}}}]
; et voici une fonction pour convertir directement le format epoch ms de geolpda en date au format des noms des photos par défaut d'android, à savoir AAAAMMJJ_hhmmss.jpg: {{{ } } }
epoch_ms_geolpda_to_AAAAMMJJ_hhmmss: func ["Converts directly epoch ms format (pictures from geolpda) to AAAAMMJJ_hhmmss.jpg (default pictures names on android)" epoch_ms] [
	tmp: to-date epoch-to-date (to-integer ((to-decimal epoch_ms) / 1000))
	return rejoin [ tmp/year pad tmp/month 2 pad tmp/day 2 "_" pad tmp/time/hour 2 pad tmp/time/minute 2 pad to-integer tmp/time/second 2]
]
;}}}

; Conversion from decimal degrees to degrees, minutes, seconds ande vice-versa:
dd2dms: func ["Converts decimal degrees to degrees, minutes, seconds" dd] [ ;{{{ } } }
	;my $dd = shift;
	;print dd
	minutes: (dd - (round/down dd)) * 60
	seconds: (minutes - (round/down minutes)) * 60
	minutes: round/down minutes
	degrees: round/down dd
	return rejoin [degrees "," minutes "," seconds]
	] ;}}}
dms2dd: func ["Converts degrees, minutes, seconds to decimal degrees" dms] [ ;{{{ } } }
	; 	dms: {48 deg 17' 33.39"}	; test
	replace/all dms " " ""	; remove all whitespaces
	rule_degree: ["degrees" | "deg" | "d" | "°"]
	rule_minute: ["minutes" | "min" | "m" | "'"]
	rule_second: ["seconds" | "sec" | "s" | {"}]
	degrees: minutes: seconds: none
	parse/all dms [copy degrees any digit-decimalplace rule_degree copy minutes any digit-decimalplace rule_minute copy seconds any digit-decimalplace rule_second to end]
	degrees: to-decimal degrees
	minutes: to-decimal minutes
	seconds: to-decimal seconds
	dd: degrees + (minutes / 60) + (seconds / 3600)
	return dd
	] ;}}}

; from LouGit:
copy-file: func [{Copies file from source to destination. Destination can be a directory or a filename.} source [file!] target [file! url!]] [ ;{{{ } } }
	if (source = target) [alert "Error: source and destination are the same" return none]
	; open source		;o)
	port_source: open/direct/binary/read to-file source
	filename: (second split-path source)
	if (dir? target) [		; target is a directory: check if a file named like source already exists there
		if ((last (to-string target)) != slash) [append target slash]
		if (exists? to-file rejoin [target filename]) [
			if (not (request/confirm rejoin ["Overwrite existing file " target file "?"])) [ return none ]
		]
		target: rejoin [target filename]
	]
	if (exists? to-file rejoin [target filename]) [
		; file exists!
		if (not (request/confirm rejoin ["Overwrite existing file " target "?"])) [ return none ]
	]
	; solution proposée sur stackoverflow
	port_target: open/direct/binary/write to-file target
	bytes_per: 1024 * 100
	while [not none? data: copy/part port_source bytes_per] [insert port_target data]
	close port_target
	close port_source
	; => oups, pas bon!

]; }}}

; fonctions pour la gestion des datasource:
test_datasource_available: func ["Teste si new_datasource_id est libre dans la base" new_datasource_id ] [ ;{{{ } } }
	 sql_string: rejoin ["SELECT * FROM public.lex_datasource WHERE opid = '" 
	                      opid "' AND datasource_id = " new_datasource_id ";"]
	 res: to-string run_query sql_string
	 ;print probe res
	 either ( res = "") [ return true ] [return false ]
	] ;}}}
get_new_datasource_id: does [ ; récupère le premier datasource_id libre {{{ } } }
	; 2013_07_09__09_13_51
		; on n'INSERTe pas tout de suite: on fait valider d'abord, dans une ihm
	tt: run_query rejoin ["SELECT max(datasource_id) AS max_datasource_id FROM public.lex_datasource WHERE opid = " opid ";"]
	either to-string tt = "none" [
		new_datasource_id: 1	; pas encore de datasource dans cet opid, on inaugure
		] [
		max_datasource_id: to-integer to-string tt
		new_datasource_id: max_datasource_id + 1
	]
	] ;}}}
generate_sql_string_update: func ["Insertion dans public.lex_datasource => TODO renommer cette fonction" new_datasource_id file_in] [ ;{{{ } } }
	sql_string_update: rejoin [ "INSERT INTO public.lex_datasource (opid, filename, datasource_id) VALUES (" opid ", '" file_in "', " new_datasource_id ");" ]
	] ;}}}
get_datasource_dependant_information: func [ ;{{{ } } }
	"Returns the list of tables where a given datasource is mentioned in the current opid, with the count of records concerned" datasource] [
	tables: run_query "SELECT tablename FROM pg_tables WHERE schemaname = 'public' AND tableowner <> 'postgres';"
	; ôt des tables inutiles, où datasource n'est pas référencé:
	;length? tables
	; == 43
	tables_inutiles: [
		["lex_datasource"]
		["dh_followup"]
		["operation_active"]
		["operations"]
		["dh_collars"]
		["dh_mineralised_intervals"]
		["formations_group_lithos"]
		["lab_ana_batches_expedition"]
		["lab_ana_columns_definition"]
		["conversions_oxydes_elements"]
		["units"]
	]
	tables: exclude tables tables_inutiles
	;length? tables
	;== 34
	sort tables
	
	; vérifions en premier lieu que le datasource demandé existe bien dans lex_datasource:
	lex_datasource_record: run_query rejoin ["SELECT * FROM public.lex_datasource WHERE opid = "opid " AND datasource_id = " datasource ";"]
	if ((length? lex_datasource_record) = 0) [
		print rejoin ["-- Attention! datasource " datasource " introuvable dans public.lex_datasource pour l'opération " opid ", pas d'arrêt néanmoins."]
		;return none 	; on laisse aller, pour pouvoir traiter des cas improbables où des datasources "fantômes" se promènent
	]
	output: make block! []
	foreach t tables [
		t: to-string t
		either error? try [
			sql: rejoin ["SELECT count(*) FROM public." t " WHERE opid = "opid " AND datasource = " to-string datasource ";"]	;print sql
			nb_records_du_datasource: to-integer first first run_query sql											;?? nb_records_du_datasource
		] [
			print rejoin ["-- Erreur (certainement: pas de champ datasource dans la table " t "); continue"]
		] [
			either ((to-integer nb_records_du_datasource) = 0) [
				;print rejoin ["-- Table " t ": datasource " datasource " non mentionné pour opération " opid]
			] [
				print rejoin ["-- Table " t " contient " nb_records_du_datasource " enregistrements correspondant au datasource " datasource " pour l'opid " opid ]
				append/only output reduce [t nb_records_du_datasource]
			]
		]
	]
	return output
] 

; usage: {{{ } } }
;get_datasource_dependant_information 912
;== [["lab_ana_results" 207.0]]
;>> get_datasource_dependant_information 912
;-- Table ancient_workings: datasource 912 non mentionné pour opération 18
;-- Table baselines: datasource 912 non mentionné pour opération 18
;-- Table dh_core_boxes: datasource 912 non mentionné pour opération 18
;-- Table dh_density: datasource 912 non mentionné pour opération 18
;-- Table dh_devia: datasource 912 non mentionné pour opération 18
;-- Table dh_litho: datasource 912 non mentionné pour opération 18
;-- Table dh_quicklog: datasource 912 non mentionné pour opération 18
;-- Table dh_sampling_bottle_roll: datasource 912 non mentionné pour opération 18
;-- Table dh_sampling_grades: datasource 912 non mentionné pour opération 18
;-- Table dh_struct_measures: datasource 912 non mentionné pour opération 18
;-- Table dh_tech: datasource 912 non mentionné pour opération 18
;-- Table dh_thinsections: datasource 912 non mentionné pour opération 18
;-- Table field_observations: datasource 912 non mentionné pour opération 18
;-- Table field_observations_struct_measures: datasource 912 non mentionné pour opération 18
;-- Table field_photos: datasource 912 non mentionné pour opération 18
;-- Table geoch_ana: datasource 912 non mentionné pour opération 18
;-- Table geoch_sampling: datasource 912 non mentionné pour opération 18
;-- Table geoch_sampling_grades: datasource 912 non mentionné pour opération 18
;-- Table gpy_mag_ground: datasource 912 non mentionné pour opération 18
;-- Table grade_ctrl: datasource 912 non mentionné pour opération 18
;-- Table index_geo_documentation: datasource 912 non mentionné pour opération 18
;-- Table lab_ana_batches_reception: datasource 912 non mentionné pour opération 18
;-- Table lab_ana_qaqc_results: datasource 912 non mentionné pour opération 18
;-- **Table lab_ana_results contient 207.0 enregistrements correspondant au datasource 912 pour l'opération 18
;-- Table lex_codes: datasource 912 non mentionné pour opération 18
;-- Table lex_standard: datasource 912 non mentionné pour opération 18
;-- Table licences: datasource 912 non mentionné pour opération 18
;-- Table mag_declination: datasource 912 non mentionné pour opération 18
;-- Table occurrences: datasource 912 non mentionné pour opération 18
;-- Table qc_sampling: datasource 912 non mentionné pour opération 18
;-- Table qc_standards: datasource 912 non mentionné pour opération 18
;-- Table shift_reports: datasource 912 non mentionné pour opération 18
;-- Table surface_samples_grades: datasource 912 non mentionné pour opération 18
;-- Table topo_points: datasource 912 non mentionné pour opération 18
;== [["lab_ana_results" 207.0]]
;}}}
;}}}
delete_datasource_and_dependant_information: func ["Delete a datasource from all tables from bdexplo where its datasource_id is mentioned" datasource] [ ; {{{ } } }
	if (none? datasource) [
		prin "Identifiant de datasource (champ datasource_id de la table lex_datasource), champs datasource des autres tables): "
		datasource: to-integer input
	]
	tables_a_traiter: get_datasource_dependant_information datasource
	if none? tables_a_traiter [return none]
	foreach i tables_a_traiter [
		t: i/1
		n: i/2
		print rejoin ["-- "t tab n]
		;prin rejoin ["-- DÉTRUIRE LES " i/2 "ENREGISTREMENTS DANS " i/1 " (yYoO/nN)? "]
		;r: input
		;either any [(r = 'y') (r = 'Y') (r = 'o') (r = 'O')]  [
			sql: rejoin ["DELETE FROM public." t " WHERE opid = "opid " AND datasource = " datasource "; -- (" n " records should be deleted)"]
			print sql
			;print "--on est timide pour le moment, on ne fait qu'afficher le SQL qui fera le boulot: à vous de le coller où il convient"
		;] [
		;print " Records kept"
		;]
	]
	; éliminons de lex_datasource, bien sûr:
	sql: rejoin ["DELETE FROM public.lex_datasource WHERE opid = " opid " AND datasource_id = " datasource ";"]
	print sql
] ;}}}

; fonctions et objets utilisés pour les structures: géométrie dans l'espace, vecteurs, objets structuraux, etc.
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
	]
; test de la fonction: {{{ } } }
	;u: [0.5 0.5 1] ; azim = N45
	;azimuth_vector u
	;== 45.0
	;u: [-0.45 .45 1]
	;>> azimuth_vector u
	;== 315.0
;}}}
;}}}

;=======================================
orientation: make object! [ ;--## An orientation object, which fully characterises a plane and/or a line: ;==={{{ } } }
	; ## Les données initiales: {{{ } } }
	;# J'ai pris une mesure de ma planchette dans ma position de
	;# travail chez moi, avec le téléphone pitchant vers la
	;# gauche.
	;# Ça revient à une mesure de faille Nm30/60/E/55/S/N.
	;# en tous cas, sans intérêt pour nous.
	;# À l'écran du GeolPDA, ça se présentait à peu près
	;# ainsi:
	;#
	;#       |  -0.7 |   0   |   0.7 |   0   |
	;#       |   0.6 |   0.6 |  -0.5 |   0   |
	;#       |   0.4 |   0.8 |   0.4 |   0   |
	;#       |   0   |   0   |   0   |   1   |
	;#
	;# J'ai recopié ça depuis l'écran du GeolPDA, en
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

	; L'exemple de matrice pour cette pseudomesure de faille 
	; Nm30/60/E/55/S/N:
	;	rotation_matrix: [ -0.7   0     0.7    0.6   0.6  -0.5    0.4   0.8   0.4]

				;(une autre mesure:)
				;rotation_matrix:	 [ 0.95   0.3    -0.1
				;					   -0.3   0.9    -0.3
				;					    0.0   0.3     0.95]
	; }}}
	;--## attributes:
	;     They are defined by the "new" constructor method:
	north_reference:			"Nm"			; default to magnetic North; could be Nu for UTM north, or Ng for geographic North
	matrix:						copy []			; bloc of 3 blocs of 3 values between 0 and 1: rotation matrix = GeolPDA measurement fully characterising orientation of measuring device
	plane_normal_vector:		copy []			; unit vector normal to GeolPDA measuring device, screen side; vector going downwards if measurement overturned
	axis_vector:				make block! []	; unit vector long axis of GeolPDA measuring device, oriented upwards = oriented line
	plane_downdip_azimuth:		make decimal! 0	; down-dip azimuth of plane, in degrees ; pour l'azimut de downdip: Azimut de OD = , en fait, azimut de ON
	plane_direction:			make decimal! 0	; direction of the plane, from 0 to 180°:
	plane_dip:					make decimal! 0	; Pendage du plan
	plane_quadrant_dip:			copy ""			; quadrant (N, E, S, W) towards where plane dips
	line_azimuth:				make decimal! 0	; line azimuth
	line_plunge:				make decimal! 0	; line plunge
	line_pitch:					make decimal! 0	; pitch angle of line
	line_pitch_quadrant:		copy ""			; quadrant (N, E, S, W) towards where line pitches
	line_movement: 				copy ""			; movement (N, I or R, D, S) for faults and equivalents
	line_movement_vertical:		copy ""			; vertical component of movement (N, I or R)
	line_movement_horizontal:	copy ""			; horizontal component of movement (D, S)
	overturned:					make logic! 0	; true if plane overturned: convention = GeolPDA measuring device with screen looking down
	comments:					copy ""			; comments, if any
	; NOTE: *all* these variables are determined, since the matrix rotation (measurement data from GeolPDA) fully determines plane and line. If the measurement /only concerns a line, or /only a line, the relevant values are /only to be considered.

	;--## methods:
	; construction:
	new: func ["Constructor, builds an orientation object! based on a measurement, as given by GeolPDA device, a rotation matrix represented by a suite of 9 values provided as a block!" m [block!]] [;{{{ } } }
		make self [
			; Convert matrix m to a block of blocks named matrix:
			foreach [u v w] m [append/only matrix to-block reduce [u v w]]
			; variables abcdefghi: juste pour un souci d'ergonomie du codeur: {{{ } } }
			; la notation de la matrice de rotation
			; est bien plus pratique à manier sous
			; forme de abcdefghi, dans les formules:
			; No: too ringard: => yes, ringard, but works... (cf.infra)
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
			; Calculation of variables:
			; Definition of vectors which fully caracterise the geometry:
			; plane normal vector:: {{{ } } }
			;=======================================================
			;# ON ou N (plane_Normal_vector): vecteur unitaire normal
			;# au plan du GeolPDA, se définit par xn,
			;# yn, zn: les calculs matriciels sont simplistes,
			;# il suffit de prendre la dernière colonne de la
			;# matrice de rotation matrix; ça se démontre en un tournemain;
			;# je mets plane_normal_vector sous forme linéaire:
			; ATTENTION! les indices changent, entre python et rebol, début 0 ou 1:
			;plane_normal_vector: reduce [	matrix/1/3
			;								matrix/2/3
			;								matrix/3/3 ]
			plane_normal_vector: reduce [ c f i ]
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
			; _normale_ avec le bloc supérieur érodé se mesure avec le téléphone 
			; en position _normale_.
			;OA: product_matrix_line rotation_matrix [0 1 0]
			;OA: to-vector OA
			;probe OA
			;OA/azim
			;OA/dip
			;OA/is_unit
			;OA/norm
			;# et A (axis_vector), vecteur unitaire dans
			;# l'allongement du GeolPDA, se définit par
			;# xa, ya, za: pareil, calculs simplistes,
			;# c'est la seconde colonne de la matrice
			;# rotation_matrix:
			;axis_vector: reduce [	self/matrix/1/2
			;						self/matrix/2/2
			;						self/matrix/3/2 ]
			axis_vector: reduce [ b e h ]
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
			; other variables:
			plane_downdip_azimuth: azimuth_vector plane_normal_vector 
			plane_direction: plane_downdip_azimuth - 90
			if (plane_direction <   0) [plane_direction: plane_direction + 180]
			if (plane_direction > 180) [plane_direction: plane_direction - 180]
			; dip of the plane, from 0 to 90°:
			plane_dip: arccosine ( plane_normal_vector/3 ) ; = plongement de OD: ;== 39.8452276492299 ; => correct
			case [
				((plane_downdip_azimuth >   315) or (plane_downdip_azimuth <=  45))	[plane_quadrant_dip: "N"]
				((plane_downdip_azimuth >   45) and (plane_downdip_azimuth <= 135))	[plane_quadrant_dip: "E"]
				((plane_downdip_azimuth >  135) and (plane_downdip_azimuth <= 225))	[plane_quadrant_dip: "S"]
				((plane_downdip_azimuth >  225) and (plane_downdip_azimuth <= 315)) [plane_quadrant_dip: "W"]
			]
			line_azimuth: azimuth_vector axis_vector
			if (axis_vector/3 > 0) [line_azimuth: line_azimuth + 180] ; case when line upwards; convention is azimuth of down lineation
			line_plunge: 90 - (arccosine ( axis_vector/3 ))
			line_pitch: arcsine ( sine (line_plunge) / sine (plane_dip) )
			;if (line_pitch < 0) [ line_pitch: line_pitch + 180 ]
			; TODO il faudra certainement déterminer un line_pitch_noorient, qui est très probablement l'angle qu'on vient d'obtenir
			;line_pitch_quadrant:	TODO
				case [
					(parse plane_quadrant_dip [ "E" | "W" ]) [
						; line_pitch_quadrant will be N or S
						either ( all [ (line_azimuth >= -90) (line_azimuth <=  90)] ) [line_pitch_quadrant: "N"] [line_pitch_quadrant: "S"]
						either ( all [ (line_azimuth >=  90) (line_azimuth <= 270)] ) [line_pitch_quadrant: "S"] [line_pitch_quadrant: "N"]
						]
					(parse plane_quadrant_dip [ "N" | "S" ]) [
						; line_pitch_quadrant will be E or W
						either ( all [ (line_azimuth >=   0) (line_azimuth <= 180)] ) [line_pitch_quadrant: "E"] [line_pitch_quadrant: "W"]
						either ( all [ (line_azimuth >= 180) (line_azimuth <= 360)] ) [line_pitch_quadrant: "W"] [line_pitch_quadrant: "E"]
						]
				]
			;line_movement:
					; Avec les conventions prises (GeolPDA en position "lisible" sur une 
					; mesure de faille normale sans surplomb), ça va être ON ^ AO qui tourne 
					; dans le sens du mouvement (le tire-bouchon de Maxwell se trouve coincé 
					; dans la faille en mouvement ou dans la guimauve qui flue).
				; Mais déterminons le mouvement de manière un peu moins lyrique et plus pragmatique:
				; la composante verticale du mouvement:
				; on prend le delta azimut de la ligne (mouvement bloc inférieur) - azimut de la
				; ligne de plus grande pente du plan, comme discriminant:
				delta_azim_line_plane: line_azimuth - plane_downdip_azimuth
				if (delta_azim_line_plane <   0) [ delta_azim_line_plane: delta_azim_line_plane + 360 ]
				if (delta_azim_line_plane > 360) [ delta_azim_line_plane: delta_azim_line_plane - 360 ]
				either	(delta_azim_line_plane >  90)	[ line_movement_vertical:   "N" ]	; jeu normal
														[ line_movement_vertical:   "I" ]	; jeu inverse
				either	(delta_azim_line_plane > 180)   [ line_movement_horizontal: "D" ]	; jeu dextre
														[ line_movement_horizontal: "S" ]	; jeu sénestre
				either (line_pitch < 45)	[ line_movement: line_movement_horizontal]		; pitch petit: mouvement décrochant dominant
											[ line_movement: line_movement_vertical  ]		; pitch grand: mouvement vertical dominant					
			;overturned:
			;____________JEANSUILA___________
			if (plane_dip > 90) [
				plane_dip: 180 - plane_dip
				overturned: true
			]
		]
	];}}}
	; outputs:
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

	print_tectri: does [ ;{{{ } } }
		;Prints a tectri-readable string; numeric values converted to integers
		sep: " " ; separator
		return rejoin [to-integer plane_direction sep to-integer plane_dip sep plane_quadrant_dip sep to-integer line_pitch sep line_pitch_quadrant sep line_movement " " comments]
	];}}}


	trace_structural_symbol: func [diag [object!]] ["Return a DRAW dialect block containing the structural symbol";{{{ } } }
		;Je tente de passer en rebol le code python que je fis pour tracer le té de pendage dans le geolpda: {{{ } } }
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
		;# GeolPDA:
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
		;##     simplement éviter de poser le GeolPDA à plat...
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
;=======================================

diagram: make object! [ ;--## A diagram, which will contain a DRAW string with the T trace from the orientation measurement: ;{{{ } } }
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

;--## structure containing the variables of a structural measurement, using French usual conventions: ;{{{ } } }

structural_measurement_convention_fr: make object! [
	; attributes:
	; coherent with relation field_observations_struct_measures in bdexplo database:
    measure_type:    make string! ""
    structure_type:  make string! ""
    north_ref:       make string! ""
    direction:       make integer! 0
    dip:             make integer! 0
    dip_quadrant:    make string! ""
    pitch:           make integer! 0
    pitch_quadrant:  make string! ""
    movement:        make string! ""
    comments:        make string! ""
	; methods:
	;valid TODO
	print: func ["Prints a human-readable string"] [
		sep: "/" ; separator
		return rejoin [north_ref direction sep dip sep dip_quadrant sep pitch sep pitch_quadrant sep movement " " comments]
	]
	;WARNING! method DUPLICATED in object orientation:
	print_tectri: func ["Prints a tectri-readable string"] [
		sep: " " ; separator
		return rejoin [direction sep dip sep dip_quadrant sep pitch sep pitch_quadrant sep movement " " comments]
	]
]

;}}}
parse_tecto_measure: func [{Converts a string structural measurement in the form "Nm85/80/N/70/W/I Overturned plane" to a structural_measurement_convention_fr object} m] [ ; {{{ } } }
	; m is for the string containing the structural measurement, with the associated comment
	; RAZ variables, to avoid side-effects:
		NORTH_REF_: DIP_QUADRANT_: PITCH_QUADRANT_: MOVEMENT_: COMMENTS_: copy ""
		DIRECTION_: DIP_: PITCH_: 0
	; rules to parse the structural measurement:
		rule_north_ref: ["N" ["m" | "g" | "u"]]		; rule for North reference: (m)agnetic, (g)eographic or (u)tm
		separator: charset ["/" "," "-"]			; separator between elements
		rule_angle_direction: [1 3 digit]
		rule_angle_dip:       [1 2 digit]
		rule_cardinal_point:  ["N" | "E" | "S" | "W" | "O"]
		rule_movement:        ["N" | "R" | "I" | "D" | "S"]
		; (VARIABLES are uppercase in the following parse rule, /only for code readability)
	rule_plane_line_movement_pitch: [COPY NORTH_REF_ rule_north_ref COPY DIRECTION_ rule_angle_direction separator COPY DIP_ rule_angle_dip separator COPY DIP_QUADRANT_ rule_cardinal_point separator COPY PITCH_ rule_angle_dip separator COPY PITCH_QUADRANT_ rule_cardinal_point separator COPY MOVEMENT_ rule_movement [" " | separator] COPY COMMENTS_ to end]
	parse/all m rule_plane_line_movement_pitch
	;rejoin [NORTH_REF DIRECTION DIP DIP_QUADRANT PITCH PITCH_QUADRANT MOVEMENT COMMENTS]

	output: make structural_measurement_convention_fr [
		; data structure coherent with relation field_observations_struct_measures in bdexplo database:
		measure_type:   "PLMS"
		;structure_type: "FAULT"
		north_ref:       to-string NORTH_REF_
		direction:       to-integer DIRECTION_
		dip:             to-integer DIP_
		dip_quadrant:    to-string DIP_QUADRANT_
		pitch:           to-integer PITCH_
		pitch_quadrant:  copy PITCH_QUADRANT_
		movement:        copy MOVEMENT_
		comments:        copy COMMENTS_
	]
	return output
	] ;}}}

; Fonctions utilisées pour faire des programmes de sondages:
cogo: func [ "COordinates GO, modifies x and y variables" azim distance ][; {{{ } } }
    x: x + (distance * (sine    azim))
    y: y + (distance * (cosine  azim))
    ;return reduce [x y]
];}}}
xyz_from_dh_collar: func ["une fonction qui retourne les x, y, z d'un sondage" id] [ ;{{{ } } }
    sql: rejoin ["SELECT x, y, z FROM dh_collars WHERE id = '" id "'"]
	resultat: run_query sql
    return reduce [to-decimal resultat/1/1 to-decimal resultat/1/2 to-decimal resultat/1/3]
]
;# /*}}}*/
plante_un_sondage_ici: does [ ;append current values to list planned holes; {{{ } } }
	append/only sondages_prevus (make object! [ "Objet drill hole"
	_location: make string! location
	_id: make string! rejoin [prefix (pad reduce (number) nbdigits)]
	_x: make decimal! x
	_y: make decimal! y
	_z: make decimal! z
	_azim_ng: make decimal! azim_ng
	_dip_hz: make decimal! dip_hz
	_length: make decimal! length
	_dh_type: make string! dh_type
	_comments: make string! comments
	] )
	number: number + 1
	probe last sondages_prevus
	];}}}

; === fin des définitions de fonctions ==========


; on se met dans le répertoire courant
change-dir system/options/path

; on renseigne un peu l'utilisateur sur la console
print "Gll preferences loaded: "
?? dbhost
?? dbname
?? user
?? tmp_schema
print rejoin ["Current working directory: " what-dir ]

; on lance la connexion à la base
connection_db

