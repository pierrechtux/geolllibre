rebol [
	Title:   "Rebol routines called by geolllibre gll_* programs"
	IDEA:    "TODO make an automatic system of imports, where a program named abc_ghea_jh_lkk.r would automatically include any file named abc_ghea_jh_*.r and any file named abc_ghea_jh_routines.r. Doing this recursively would make an easy to maintain tree of dependencies"
	Name:    gll_routines.r
	Version: 1.0.4
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
  Copyright (C) 2019 Pierre Chevalier <pierrechevaliergeol@free.fr>

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
	1.0.4	[8-Mar-2014/0:08:07+1:00   {Calculs de structures à partir des mesures d'orientations du GeolPDA semblent corrects}]
	1.0.5	[23-Apr-2014/14:44:58+1:00 {Functions concerning GeolPDA moved here, from gll_geolpda_fetch_data.r and gll_geolpda_report_generator.r}]
	2.0    	[21-Sep-2018/19:39:10+2:00 {Bof, no more history here: see git log, rather}]
]	]

;;;TODO FONCTION POUR RÉCUPÉRER UNE VARIABLE D'ENVIRONNEMENT, OU UN PARAMÈTRE DE .GLL_PREFERENCES => postponed; strange beheviour from scripts, sometimes not reading environment variables, for unknown reason.
;get_env_or_gll_preferences: func ["Function to retreive environment variables or a value from .gll_preferences var] [ ; {{{
;
;gll_varenv: [ GLL_BD_HOST POSTGEOL GLL_BD_NAME GLL_BD_PORT GLL_BD_USER ]
;foreach v gll_varenv [
;	v: to-string v
;; v: to-string gll_varenv/1
;; v: to-string gll_varenv/2
;; v: to-string gll_varenv/3
;; v: to-string gll_varenv/4
;; v: to-string gll_varenv/4
;; v: to-string gll_varenv/5
;??? v
;;	code: [
;		a: rejoin [ "if (not error? try [varenv_" lowercase v {: get-env "} v {"]) [ } lowercase v ": " (v) ": varenv_" (v) "]"]
;print to-string a
;do a
;]
;
;?? varenv_gll_bd_host
;?? varenv_postgeol
;?? varenv_gll_bd_name
;?? varenv_gll_bd_port
;?? varenv_gll_bd_user
;
;;	return sql_result
;;] ; }}}

; Get preferences (dbname dbhost user passw opid tmp_schema) from .gll_preferences file. Récupération des préférences (dbname dbhost user passw opid tmp_schema) à partir du fichier .gll_preferences: {{{
; .gll_preferences is a plain text file, simply containing variables definition, it is a plain rebol script, intended to be LOADed.
catch [
if error? try [	do load to-file system/options/home/.gll_preferences
		throw ".gll_preferences loaded from ~"]
	[print "-"]
if error? try [	do load to-file %/usr/bin/.gll_preferences
		throw ".gll_preferences loaded from /usr/bin/"			]
	[print "-"]
if error? try [	do load to-file rejoin [ system/options/path ".gll_preferences"]
		throw ".gll_preferences loaded from current directory"		]
	[print "-"]
if error? try [ do load to-file system/options/home/.gll_preferences] [
	do load to-file %.gll_preferences		; modif chez Corentin sur windows 7
		throw {.gll_preferences loaded from "system/options/home/"}	]
	[print "- No .gll_preferences file found."
	;TODO set some default values
	dbname: postgeol: "postgeol"
	dbhost:      "localhost"
	dbport:      5432
	user:        "geononymous"
	passw:       "chut"
	geologist:   "Anonymous Geologo"
	opid:        0
	tmp_schema:  "tmp_imports"
	working_directory: %~/geolllibre/
	dir_geolpda_local:           %~/geolpda/android_cp/geolpda/
	dir_dcim_local:              %~/photos/
	dir_oruxmaps_local:          %~/gps/oruxmaps/
	]
] ;}}}
; Get more preferences from environment variables. Récupération d'autres préférences à partir de variables d'environnement:{{{

; List "interesting" environment variables:
vars: [
BROWSER
DISPLAY
CONNINFO
EDITOR
HOSTNAME
LANG
HOSTTYPE
LC_NUMERIC
LOGNAME
OSTYPE
GDM_LANG
GROUPS
SHELL
GTK_MODULES
HOME
SHELLOPTS
SHLVL
SSH_AGENT_PID
SSH_AUTH_SOCK
TERM
UID
USER
WINDOWID
XAUTHORITY
XDG_CURRENT_DESKTOP
XDG_GREETER_DATA_DIR
XDG_RUNTIME_DIR
XDG_SEAT
XDG_SEAT_PATH
XDG_SESSION_CLASS
XDG_SESSION_DESKTOP
XDG_SESSION_ID
XDG_SESSION_PATH
XDG_SESSION_TYPE
XDG_VTNR
XTERM_LOCALE
XTERM_SHELL
]

; For each of these variables, get its value:
foreach v vars [
	v: to-string v
	do rejoin [v {: get-env "} uppercase v {"}]
]

; Just to check:
;foreach v vars [ print get v ]

;}}}

; Include Nenad's postgeol driver. Inclusion du pilote postgresql de Nenad: {{{
do [

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
		/local final complete msg pl pos utopped row stop error test-error test-exit a-data
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
; Include Nenad's mysql driver. Inclusion du pilote mysql de Nenad: {{{
do [
; :r /home/pierre/.rebol/view/public/rebol.softinnov.org/old/mysql/mysql-r099/mysql-protocol.r

REBOL [
	Title: "mySQL Protocol"
    Author: "Nenad Rakocevic"
    Email: dockimbel@free.fr
    Web: http://rebol.dhs.org/mysql/
    Date: 25/07/2001
    File: %mysql-protocol.r
    Version: 0.9.9
    Purpose: "mySQL client protocol support"
    Comment: "v1.0 Candidate 1"
]

make root-protocol [

	scheme: 'mySQL
    port-id: 3306
	port-flags: system/standard/port-flags/pass-thru or 32 ; /binary

	fast-query: none

	sys-copy: 	get in system/words 'copy
	sys-insert: get in system/words 'insert
	sys-pick: 	get in system/words 'pick
	sys-close: 	get in system/words 'close
	net-log: 	get in net-utils	'net-log

	std-header-length: 4
	std-comp-header-length:	3

	throws: [closed "closed"]

;------ Internals --------

	defs: [
		cmd [
			;sleep			0
			quit			1
			init-db			2
			query			3
			;field-list		4
			create-db		5
			drop-db			6
			reload			7
			shutdown		8
			statistics		9
			;process-info	10
			;connect		11
			process-kill	12
			debug			13
			ping			14
			;time			15
			;delayed-insert	16
			change-user		17
		]
		refresh [
			grant		1	; Refresh grant tables
			log			2	; Start on new log file
			tables		4	; Close all tables
			hosts		8	; Flush host cache
			status		16	; Flush status variables
			threads		32	; Flush status variables
			slave		64	; Reset master info and restart slave thread
			master		128 ; Remove all bin logs in the index
		]					; and truncate the index
		types [
			0		decimal
			1		tiny
			2		short
			3		long
			4		float
			5		double
			6		null
			7		timestamp
			8		longlong
			9		int24
			10		date
			11		time
			12		datetime
			13		year
			14		newdate
			247		enum
			248		set
			249		tiny-blob
			250		medium-blob
			251		long-blob
			252		blob
			253		var-string
			254		string
		]
		flag [
			not-null		1		; field can't be NULL
			primary-key		2		; field is part of a primary key
			unique-key 		4		; field is part of a unique key
			multiple-key	8		; field is part of a key
			blob			16
			unsigned		32
			zero-fill		64
			binary			128
			enum			256		; field is an enum
			auto-increment	512		; field is a autoincrement field
			timestamp		1024	; field is a timestamp
			set				2048	; field is a set
			num				32768	; field is num (for clients)
		]
		client [
			long-password		1		; new more secure passwords
			found-rows			2		; Found instead of affected rows
			long-flag			4		; Get all column flags
			connect-with-db		8		; One can specify db on connect
			no-schema			16		; Don't allow db.table.column
			compress			32		; Can use compression protcol
			odbc				64		; Odbc client
			local-files			128		; Can use LOAD DATA LOCAL
			ignore-space		256		; Ignore spaces before '('
			change-user			512		; Support the mysql_change_user()
			interactive			1024	; This is an interactive client
			ssl					2048	; Switch to SSL after handshake
			ignore-sigpipe		4096	; IGNORE sigpipes
			transactions		8196	; Client knows about transactions
		]
	]

	locals-class: make object! [
	;--- Internals (do not touch!)---
		seq-num: 0
		buf-size: 10000
		last-status:
		stream-end?:
		buffer: none
	;-------
		cache: none
		auto-commit: on		; not used, just reserved for /Command compatibility.
		rows: 10			; not used, just reserved for /Command compatibility.
		auto-conv?: on
		auto-ping?: on
		matched-rows:
		columns:
		protocol:
		version:
		thread-id:
		crypt-seed:
		capabilities:
		error-code:
		error-msg:
		conv-list: none
	]

	column-class: make object! [
		table: name: length: type: flags: decimals: none
	]

	conv-model: [
		decimal			[to decimal!]
		tiny			[to integer!]
		short			[to integer!]
		long			[to integer!]
		float			[to decimal!]
		double			none
		null			none
		timestamp		none
		longlong		none
		int24			[to integer!]
		date			[to date!]
		time			[to time!]
		datetime		[to date!]
		year			[to integer!]
		newdate			none
		enum			none
		set				none
		tiny-blob		none
		medium-blob		none
		long-blob		none
		blob			none
		var-string		none
		string			none
	]

	set 'change-type-handler func [p [port!] type [word!] blk [block!]][
		head change/only next find p/locals/conv-list type blk
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
					sys-insert at compose [change at row (i) :tmp] 5 conv-func
			]
		]
		if not empty? convert-body [foreach row rows :convert-body]
	]

	decode: func [int [integer!] /features /flags /type /local list name value][
		either type [
			any [select defs/types int 'unknown]
		][
			list: make block! 10
			foreach [name value] either flags [defs/flag][defs/client][
				if value = (int and value) [append list :name]
			]
			list
		]
	]

	encode-refresh: func [blk [block!] /local total name value][
		total: 0
		foreach name blk [
			either value: select defs/refresh :name [
				total: total + value
			][
				net-error reform ["Unknown argument:" :name]
			]
		]
		total
	]

	sql-escape: func [value [string!] /local chars no-chars want escaped
		escape mark
	][
		chars: charset want: {^(00)^/^-^M^(08)'"\}
		no-chars: complement chars
		escaped: ["\0" "\n" "\t" "\r" "\b" "\'" {\"} "\\"]
		escape: func [value][
			mark: sys-insert remove mark sys-pick escaped index? find want value
		]
		parse/all value [any [mark: chars (escape mark/1) :mark | no-chars]]
		value
	]

	to-sql: func [value /local res][
		switch/default mold type? value [
			"none!"		["NULL"]
			"date!"		[
				rejoin ["'" value/year "-" value/month "-" value/day
					either value: value/time [
						rejoin [" " value/hour	":" value/minute ":" value/second]
					][""] "'"
				]
			]
			"time!"		[join "'" [value/hour ":" value/minute ":" value/second "'"]]
			"money!"	[head remove find mold value "$"]
			"string!"	[join "'" [sql-escape sys-copy value "'"]]
			"binary!"	[to-sql to string! value]
			"block!"	[
				if empty? value: reduce value [return "(NULL)"]
				res: append make string! 100 #"("
				forall value [repend res [to-sql value/1 #","]]
				head change back tail res #")"
			]
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
		sql
	]

	show-server: func [obj [object!]][
		net-log reform [						newline
			"----- Server ------" 				newline
			"Version:"			obj/version		newline
			"Protocol version:"	obj/protocol 	newline
			"Thread ID:" 		obj/thread-id 	newline
			"Crypt Seed:"		obj/crypt-seed	newline
			"Capabilities:"		mold obj/capabilities newline
			"-------------------"
		]
	]

;------ Encryption functions ------

	scrambler: make object! [
		to-pair: func [value [integer!]][system/words/to-pair reduce [value 1]]
		xor-pair: func [p1 p2][to-pair p1/x xor p2/x]
		or-pair: func [p1 p2][to-pair p1/x or p2/x]
		and-pair: func [p1 p2][to-pair p1/x and p2/x]
		remainder-pair: func [val1 val2 /local new][
			val1: either negative? val1/x [abs val1/x + 2147483647.0][val1/x]
			val2: either negative? val2/x [abs val2/x + 2147483647.0][val2/x]
			to-pair to-integer val1 // val2
		]
		floor: func [value][
			value: to-integer either negative? value [value - .999999999999999][value]
			either negative? value [complement value][value]
		]

		hash-v9: func [data [string!] /local nr nr2 byte][
			nr: 1345345333x1
			nr2: 7x1
			foreach byte data [
				if all [byte <> #" " byte <> #"^(tab)"][
					byte: to-pair to-integer byte
					nr: xor-pair nr (((and-pair 63x1 nr) + nr2) * byte) + (nr * 256x1)
					nr2: nr2 + byte
				]
			]
			nr
		]

		hash-v10: func [data [string!] /local nr nr2 adding byte][
			nr: 1345345333x1
			adding: 7x1
			nr2: to-pair to-integer #12345671
			foreach byte data [
				if all [byte <> #" " byte <> #"^(tab)"][
					byte: to-pair to-integer byte
					nr: xor-pair nr (((and-pair 63x1 nr) + adding) * byte) + (nr * 256x1)
					nr2: nr2 + xor-pair nr (nr2 * 256x1)
					adding: adding + byte
				]
			]
			nr: and-pair nr to-pair to-integer #7FFFFFFF
			nr2: and-pair nr2 to-pair to-integer #7FFFFFFF
			reduce [nr nr2]
		]

		crypt-v9: func [data [string!] seed [string!] /local
			new max-value clip-max hp hm nr seed1 seed2 d b i
		][
			if any [none? data empty? data][return ""]

			new: make string! length? seed
			max-value: to-pair to-integer #01FFFFFF
			clip-max: func [value][remainder-pair value max-value]
			hp: hash-v9 seed
			hm: hash-v9 data
			nr: clip-max xor-pair hp hm
			seed1: nr
			seed2: nr / 2x1

			foreach i seed [
				seed1: clip-max ((seed1 * 3x1) + seed2)
				seed2: clip-max (seed1 + seed2 + 33x1)
				d: seed1/x / to-decimal max-value/x
				append new to-char floor (d * 31) + 64
			]
			new
		]

		crypt-v10: func [data [string!] seed [string!] /local
			new max-value clip-max pw msg seed1 seed2 d b i
		][
			if any [none? data empty? data][return ""]

			new: make string! length? seed
			max-value: to-pair to-integer #3FFFFFFF
			clip-max: func [value][remainder-pair value max-value]
			pw: hash-v10 seed
			msg: hash-v10 data

			seed1: clip-max xor-pair pw/1 msg/1
			seed2: clip-max xor-pair pw/2 msg/2

			foreach i seed [
				seed1: clip-max ((seed1 * 3x1) + seed2)
				seed2: clip-max (seed1 + seed2 + 33x1)
				d: seed1/x / to-decimal max-value/x
				append new to-char floor (d * 31) + 64
			]
			seed1: clip-max (seed1 * 3x1) + seed2
			seed2: clip-max seed1 + seed2 + 33x0
			d: seed1/x / to-decimal max-value/x
			b: to-char floor (d * 31)

			forall new [new/1: new/1 xor b]
			head new
		]

		scramble: func [data [string!] port [port!]][
			either port/locals/protocol > 9 [
				crypt-v10 data port/locals/crypt-seed
			][
				crypt-v9 data port/locals/crypt-seed
			]
		]
	]

	scramble: get in scrambler 'scramble

;------ Data reading ------

	b0: b1: b2: b3: int: int24: long: string: field: len: none
	byte-char: complement charset []
	null: to-char 0
	null-flag: false

	read-string: [[copy string to null null] | [copy string to end]]
	read-byte: [copy byte byte-char (byte: to integer! to char! :byte)]
	read-int: [
		read-byte (b0: byte)
		read-byte (b1: byte	int: b0 + (256 * b1))
	]
	read-int24: [
		read-byte (b0: byte)
		read-byte (b1: byte)
		read-byte (b2: byte	int24: b0 + (256 * b1) + (65536 * b2))
	]
	read-long: [
		read-byte (b0: byte)
		read-byte (b1: byte)
		read-byte (b2: byte)
		read-byte (
			b3: byte
			long: to integer! b0 + (256 * b1) + (65536 * b2) + (16777216.0 * b3)
		)
	]
	read-long64: [
		read-long
		skip 4 byte (net-log "Warning: long64 type detected !")
	]
	read-length: [
		#"^(FB)" (len: 0 null-flag: true)
		| #"^(FC)" read-int (len: int)
		| #"^(FD)" read-int24 (len: int24)
		| #"^(FE)" read-long (len: long)
		| read-byte (len: byte)
	]
	read-nbytes: [
		#"^(01)" read-byte (len: byte)
		| #"^(02)" read-int (len: int)
		| #"^(03)" read-int24 (len: int24)
		| #"^(04)" read-long (len: long)
		| none (len: 255)
	]
	read-field: [
		(null-flag: false)
		read-length s: (either null-flag [field: none]
			[field:	sys-copy/part s len s: skip s len]) :s
	]

	read: func [[throw] port [port!] data [binary!] size [integer!] /local len][
		if -1 = len: read-io port/sub-port data size [
			sys-close port/sub-port
			throw throws/closed
		]
		net-log ["low level read of " len "bytes"]
		len
    ]

	defrag-read: func [port [port!] buf [binary!] expected [integer!]][
		clear buf
		while [expected > length? buf][
			read port buf expected - length? buf
		]
	]

	read-packet: func [port [port!] /local packet-len pl status][
		pl: port/locals
		pl/stream-end?: false

	;--- reading header ---
		defrag-read port pl/buffer std-header-length

		parse/all pl/buffer [
			read-int24  (packet-len: int24)
			read-byte	(pl/seq-num: byte)
		]
	;--- reading data ---
		if packet-len > pl/buf-size [
			net-log ["Expanding buffer, old:" pl/buf-size "new:" packet-len]
			pl/buffer: make binary! pl/buf-size: packet-len
		]
		defrag-read port pl/buffer packet-len
		if packet-len <> length? pl/buffer [
			net-error "Error: inconsistent packet length !"
		]
		pl/last-status: status: to integer! pl/buffer/1
		pl/error-code: pl/error-msg: none

		if status = 255 [
			parse/all next pl/buffer either [none? pl/protocol pl/protocol > 9][
				[	read-int 	(pl/error-code: int)
					read-string (pl/error-msg: string)]
			][
				pl/error-code: 0
				[	read-string (pl/error-msg: string)]
			]
			pl/stream-end?: true
			net-error reform ["ERROR" any [pl/error-code ""]":" pl/error-msg]
		]
		if all [status = 254 packet-len = 1][pl/stream-end?: true]
		pl/buffer
	]

	read-packet-via: func [port [port!] /local pl tmp][
		pl: port/locals
		if empty? pl/cache [
			read-packet port
			if pl/stream-end? [return #{}]	; empty set !
		]
		tmp: pl/cache			; swap cache<=>buffer
		pl/cache: pl/buffer
		pl/buffer: :tmp
		read-packet port
		pl/cache
	]

	read-columns-number: func [port [port!] /local colnb][
		parse/all/case read-packet port [
			read-length (if zero? colnb: len [port/locals/stream-end?: true])
			read-length	(port/locals/matched-rows: len)
			read-length
		]
		if not zero? colnb [port/locals/matched-rows: none]
		colnb
	]

	read-columns-headers: func [port [port!] cols [integer!] /local pl col][
		pl: port/locals
		pl/columns: make block! cols
		loop cols [
			col: make column-class []
			parse/all/case read-packet port [
				read-field	(col/table:	field)
				read-field	(col/name: 	field)
				read-nbytes	(col/length: len)
				read-nbytes	(col/type: decode/type len)
				read-field	(
					col/flags: decode/flags to integer! field/1
					col/decimals: to integer! field/2
				)
			]
			append pl/columns :col
		]
		read-packet	port			; check the ending flag
		if not pl/stream-end? [
			flush-pending-data port
			net-error "Error: end of columns stream not found"
		]
		pl/stream-end?: false		; prepare correct state for
		clear pl/cache				; rows reading.
	]

	read-rows: func [port [port!] /part n [integer!]
		/local row-data row rows cols count
	][
		rows: make block! max any [n 0] port/locals/rows
		cols: length? port/locals/columns
		count: 0
		forever [
			row-data: read-packet-via port
			if empty? row-data [return []]		; empty set
			row: make block! cols
			parse/all/case row-data [any [read-field (append row field)]]
			append/only rows row
			if port/locals/stream-end? or all [part n = count: count + 1][break]	; end of stream or rows # reached
		]
		if port/locals/auto-conv? [convert-types port rows]
		recycle		; lot of garbage to recycle here ! :)
		rows
	]

	read-cmd: func [port [port!] cmd [integer!] /local res][
		either cmd = defs/cmd/statistics [
			to-string read-packet port
		][
			res: read-packet port
			either all [cmd = defs/cmd/ping zero? port/locals/last-status]
				[true][none]
		]
	]

	flush-pending-data: func [port [port!] /local pl len][
		pl: port/locals
		if not pl/stream-end? [
			net-log "flushing unread data..."
			until [
				clear pl/buffer
				len: read port pl/buffer pl/buf-size
				pl/buf-size > len
			]
			net-log "flush end."
			pl/stream-end?: true
		]
	]

;------ Data sending ------

	write-byte: func [value [integer!]][to char! value]

	write-int: func [value [integer!]][
		join to char! value // 256 to char! value / 256
	]

	write-int24: func [value [integer!]][
		join to char! value // 256 [
			to char! (to integer! value / 256) and 255
			to char! (to integer! value / 65536) and 255
		]
	]

	write-long: func [value [integer!]][
		join to char! value // 256 [
			to char! (to integer! value / 256) and 255
			to char! (to integer! value / 65536) and 255
			to char! (to integer! value / 16777216) and 255
		]
	]

	write-string: func [value [string!]][
		join value to char! 0
	]

	send-packet: func [port [port!] data [string!]][
		data: to-binary rejoin [
			write-int24 length? data
			write-byte port/locals/seq-num: port/locals/seq-num + 1
			data
		]
		write-io port/sub-port data length? data
		port/locals/stream-end?: false
	]

	send-cmd: func [port [port!] cmd [integer!] cmd-data /local cmds][
		cmds: defs/cmd
		port/locals/seq-num: -1
		send-packet port rejoin [
			write-byte cmd
			switch/default cmd reduce [
				cmds/quit			[""]
				cmds/shutdown		[""]
				cmds/statistics		[""]
				cmds/debug			[""]
				cmds/ping			[""]
				cmds/reload			[write-byte encode-refresh cmd-data]
				cmds/process-kill	[write-long sys-pick cmd-data 1]
				cmds/change-user	[
					rejoin [
						write-string sys-pick cmd-data 1
						write-string scramble sys-pick cmd-data 2 port
						write-string sys-pick cmd-data 3
					]
				]
			][either string? cmd-data [cmd-data][sys-pick cmd-data 1]]
		]
	]

	insert-query: func [port [port!] data [string! block!] /local colnb][
		send-cmd port defs/cmd/query data
		colnb: read-columns-number port
		if not any [zero? colnb port/locals/stream-end?][
			read-columns-headers port colnb
		]
		none
	]

	insert-cmd: func [port [port!] data [block!] /local type res][
		type: select defs/cmd data/1
		either type [
			send-cmd port type next data
			res: read-cmd port type
			port/locals/stream-end?: true
			res
		][
			port/locals/stream-end?: true
			net-error reform ["Unknown command" data/1]
		]
	]

	try-reconnect: func [port [port!]][
		net-log "Connection closed by server! Reconnecting..."
		if throws/closed = catch [open port][net-error "Server down!"]
	]

	do-handshake: func [port [port!] /local pl client-param][
		pl: port/locals: make locals-class []
		pl/buffer: make binary! pl/buf-size
		pl/cache: make binary! pl/buf-size
		pl/conv-list: sys-copy/deep conv-model

		parse/all read-packet port [
			read-byte 	(pl/protocol: byte)
			read-string (pl/version: string)
			read-long 	(pl/thread-id: long)
			read-string	(pl/crypt-seed: string)
			read-int	(pl/capabilities: decode/features int)
			to end
		]

		if pl/protocol = -1 [
			sys-close port/sub-port
			net-error "Server configuration denies access to locals source^/Port closed!"
		]

		show-server pl

		client-param: defs/client/found-rows or defs/client/connect-with-db
		client-param: either pl/protocol > 9 [
			client-param or defs/client/long-password
		][
			client-param and complement defs/client/long-password
		]

		send-packet port rejoin [
			write-int client-param
			write-int24 (length? port/user) + (length? port/pass)
				+ 7 + std-header-length
			write-string port/user
			write-string scramble port/pass port
			write-string port/target
		]

		read-packet port
		net-log "Connected to server. Handshake OK"
	]

;------ Public interface ------

    init: func [port [port!] spec /local scheme args][
    	either args: find spec #"?" [
    		spec: sys-copy/part spec args
    		fast-query: dehex sys-copy next args
    	][
    		fast-query: none
    	]
        if url? spec [net-utils/url-parser/parse-url port spec]
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
        port/sub-port/state/flags: 524835	; force /direct/binary mode
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
    		flush-pending-data port
    		send-cmd port defs/cmd/quit []
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
			res: either block? data [
				if empty? data [net-error "No data!"]
				either string? data/1 [
					insert-query port map-rebol-values data
				][
					insert-cmd port data
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

	copy: func [port /part data [integer!]][
		either not port/locals/stream-end? [
			either all [value? 'part part][read-rows/part port data]
				[read-rows port]
		][none]
	]

	;--- Register ourselves.
	net-utils/net-install mySQL self 3306
]


] ;}}}
; Include CSV.r utility. Inclusion de l'utilitaire CSV.r : {{{
do [
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
; Include csv-tools.r utility. Inclusion de l'utilitaire csv-tools.r:;{{{
do [

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
; Include btn-sqlite.r utility. Inclusion de l'utilitaire btn-sqlite.r:;{{{
do [
; Library to access sqlite geolpda database:
;{{{
;do %~/rebol/library/scripts/btn-sqlite.r

REBOL [
	Title: "better-than-nothing sqlite3 handler"
	Purpose: "easy access to sqlite3 database without /Pro or /Command features"
	Comment: "based on mysql-protocol 1.0.2 by Nenad Rakocevic / SOFTINNOV"
	Author: "Piotr Gapinski"
	Email: {news [at] rowery! olsztyn.pl}
	File: %btn-sqlite.r
	Date: 2006-01-30
	Version: 0.2.2
	Copyright: "Olsztynska Strona Rowerowa http://www.rowery.olsztyn.pl/"
	License: "GNU General Public License (GPL)"
	History: [0.1.0 2006-01-20 0.1.1 2006-01-20 0.2.0 2006-01-25 0.2.1 2006-01-27 0.2.2 2006-01-30]
	Library: [
		level: 'intermediate
		platform: [Linux Windows]
		type: [protocol tool]
		domain: [protocol database]
		tested-under: [
			view 1.3.2 on [Linux WinXP]
			core 2.6.2 on [Linux WinXP]
		]
		support: none
		license: 'GPL
	]
]

make root-protocol [
	scheme: 'btn
	port-id: 0
	port-flags: system/standard/port-flags/pass-thru
	awake: none
	open-check: none

	sqlite: none
	options: none
	linux?: equal? fourth system/version 4

	sys-copy: get in system/words 'copy
	sys-insert: get in system/words 'insert
	sys-pick: get in system/words 'pick
	sys-close: get in system/words 'close
	sys-write: get in system/words 'write
	net-log: get in net-utils 'net-log

	init: func [[catch] port spec] [
	        if not url? spec [net-error "Bad URL"]
		net-utils/url-parser/parse-url port spec
		if none? port/target [net-error reform ["No database name for" port/scheme "is specified"]]

		port/locals: make object! [columns: none rows: 0 values: none sqlite-rc: 0 index: 0]
		port/url: spec

		sqlite: any [
			select [3 "sqlite3.exe" 4 "/usr/bin/sqlite3"] (fourth system/version)
			"sqlite3"
		]
		options: {-html -header}
	]

	open: func [port [port!]][
		port/state/flags: port/state/flags or port-flags
	]

	close: func [port [port!]][]

	sql-escape: func [value [string!] /local chars no-chars want escaped escape mark] [
		chars: charset want: {^(00)^/^-^M^(08)'"\}
		no-chars: complement chars
		escaped: ["\0" "\n" "\t" "\r" "\b" "\'" {\"} "\\"]
		escape: func [value][
			mark: sys-insert remove mark sys-pick escaped index? find want value
		]
		parse/all value [any [mark: chars (escape mark/1) :mark | no-chars]]
		value
	]

	to-sql: func [value /local res] [
		switch/default type?/word value [
			none!	["NULL"]
			date!	[
				rejoin ["'" value/year "-" value/month "-" value/day
					either value: value/time [
						rejoin [" " value/hour ":" value/minute ":" value/second]
					][""] "'"
				]
			]
			time!	[join "'" [value/hour ":" value/minute ":" value/second "'"]]
			money!	[head remove find mold value "$"]
			string!	[join "'" [sql-escape sys-copy value "'"]]
			binary!	[to-sql to string! value]
			block!	[
					if empty? value: reduce value [return "(NULL)"]
					res: append make string! 100 #"("
					forall value [repend res [to-sql value/1 #","]]
					head change back tail res #")"
				]
		][form value]
	]

	map-rebol-values: func [data [block!] /local args sql mark] [
		args: reduce next data
		sql: sys-copy sys-pick data 1
		mark: sql
		while [found? mark: find mark #"?"][
			mark: sys-insert remove mark either tail? args ["NULL"] [to-sql args/1]
			if not tail? args [args: next args]
		]
		sql
	]

	insert-query: func [port [port!] data [string! block!] /local cmd] [
		cmd: reform [sqlite options port/target rejoin [{"} data {"}]]
		net-log ["call" cmd]
		port/locals/sqlite-rc: call/wait/output cmd port/state/inBuffer
	]

	parse-schema: func [port [port!] /local headers parts] [
		headers: sys-copy []
		parts: [<th> copy header to </th> (append headers any [header ""]) | skip]

		parse/all port/state/inBuffer [some parts to end]
		net-log ["found" (length? headers) "columns"]
		headers
	]

	parse-rows: func [port [port!] items-per-row [integer!] /local values parts rows] [
		values: sys-copy []
		parts: [<td> copy value to </td> (append values any [value ""]) | skip]

		parse/all port/state/inBuffer [some parts to end]
		rows: sys-copy []

		if all [
			not empty? values
			not zero? items-per-row
		][
			net-log ["found" ((length? values) / items-per-row) "rows" items-per-row "columns per row"]
			forskip values items-per-row [append/only rows sys-copy/part values items-per-row]
		]
		rows
	]

	insert: func [[throw] port [port!] data [string! block!] /local items-per-row] [
		port/state/inBuffer: make string! 4096
		port/locals/values: none
		port/locals/rows: 0
		port/locals/index: 0

		;; execute sql

		if all [(string? data) (data/1 = #"[")] [data: load data]
		either block? data [
			if empty? data [net-error "No data!"]
			insert-query port data: map-rebol-values data
		][
			insert-query port data: replace/all data {"} {'}
		]

		;; parse output

		port/locals/columns: parse-schema port
		items-per-row: length? port/locals/columns

		port/locals/values: parse-rows port items-per-row
		port/locals/rows: length? port/locals/values

		zero? port/locals/sqlite-rc
	]

	read-rows-html: func [port [port!] /part n [integer!] /local rows] [
		if any [
			not zero? port/locals/sqlite-rc	;; sqlite error
			empty? port/locals/values	;; no sql output
		][
			return []
		]

		values: skip port/locals/values port/locals/index
		either all [value? 'part n] [sys-copy/part values n] [sys-copy values]
	]

	copy: func [port /part data [integer!] /local rows][
		rows: either all [value? 'part part] [read-rows-html/part port data] [read-rows-html port]
		net-log ["copy" (length? rows) "rows" "at" "index" port/locals/index]
		port/locals/index:  port/locals/index + length? rows
		rows
	]

	net-utils/net-install :scheme self :port-id
]

comment {
	; example
	db: open btn://localhost/test.db3
	insert db "CREATE TABLE t1 (a int, b text, c text)"
	repeat i 25 [
		insert db [{INSERT INTO t1 VALUES (?, ?, ?)} i (join "cool" i) (join "cool" (25 + 1 - i))]
	]
	insert db "SELECT * FROM t1"
	probe db/locals/columns
	res: copy/part db 10
	probe res
	probe length? res
	insert db "DROP TABLE t1"
	close db
	halt
}
;}}}
]
;/*}}}*/

; === functions and objects definitions ==========
; utility functions related to database:
connection_db:               does      [ "Connect to database" ;{{{
	; on fait une connexion à la base de données:
	;do %~/rebol/telech/pgsql-r090/pgsql-protocol.r
	if error? try 	[
			db: open to-url rejoin ["pgsql://" user ":" passw "@" dbhost ":" dbport "/" dbname]
			print rejoin [{Connected to database } dbname { hosted by } dbhost { on port } dbport {, logged in as role } user]
	] 		[
			print rejoin [{Error while trying to connect to database } dbname { hosted by } dbhost { on port } dbport {, as role } user]
	]
] ;}}}
run_query:                   func      [ "Utility function: sends a SQL query, returns the result as a block named sql_result; sql_result_fields contains the fields" sql] [ ; {{{
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
run_sql_string_update:       does      [ "Utility function, similar to run_query, for UPDATEs" ;{{{
	append journal_sql rejoin ["--" now ]
	append journal_sql sql_string_update
	insert db sql_string_update
	?? journal_sql
	] ;}}}
do_psql:                     func      [ "Prend du SQL en entrée, et fait tourner psql avec, en renvoyant la sortie" sql_text] [ ;{{{
	;TODO: ajouter un raffinement /unaligned qui rajoute le flag "-A" pour psql
	;TODO: pouvoir choisir psql (pour les plateformes à la noix qui l'ont pas dans le $PATH...)
	return call_wait_output_error rejoin [{echo "} sql_text {" | psql -X -h } dbhost { -p } dbport { -U } user { -d } dbname]
re
	] ;}}}
compare_schemas_2_bdexplos:  function  [ "Compare structure from two running instances of bdexplo" dbhost1 dbname1 dbhost2 dbname2][][ ; {{{
	;dbhost1: "autan"  dbname1: "bdexplo"  dbhost2: "autan"  dbname2: "bdexplo_smi"
	;TODO à déplacer dans un module utilitaire plus général, à distribuer hors gll, pour tout postgresql
	schemas_exclus: ["amc" "backups" "bof" "information_schema" "input" "pg_catalog" "pg_toast" "pg_toast_temp_1" "smi" "tanguy" "tmp_a_traiter" "tmp_imports" "tmp_ntoto" "zz_poubelle" "tmp_a_traiter" "pierre" "input" "marie_cecile" "tanguy" "kalvin"]

	; première solution: on fait un pg_dump de la base
	;   => 	abandonné, le résultat n'est pas trié, et incomparable,
	;	même avec le secours de pg_dump_splitsort.py	{{{
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

	comment [ ; {{{
	;pg_dump -s -h autan bdexplo -N amc -N  amc                -N  backups             -N  bof                -N information_schema  -N  input               -N  pg_catalog          -N  pg_toast            -N  pg_toast_temp_1     -N  smi                 -N  tanguy              -N  tmp_a_traiter       -N  tmp_imports         -N  tmp_ntoto           -N  zz_poubelle        > schema_bdexplo_autan_.sql
	;pg_dump -U postgres -s -h duran bdexplo -N information_schema -N  input               -N  pg_catalog          -N  pg_toast            -N  pg_toast_temp_1     -N  tanguy              -N  tmp_imports         -N  zz_poubelle        > schema_bdexplo_duran_.sql
	;#vimdiff schema_bdexplo_autan_.sql schema_bdexplo_duran_.sql
	;grep -v '^--' < schema_bdexplo_autan_.sql | grep -v '^$' > schema_bdexplo_autan_nocomment_.sql
	;grep -v '^--' < schema_bdexplo_duran_.sql | grep -v '^$' > schema_bdexplo_duran_nocomment_.sql
	;vimdiff schema_bdexplo_autan_nocomment_.sql schema_bdexplo_duran_nocomment_.sql
	] ; }}}
	;}}}

	; seconde solution: on fait pour chaque table un pg_dump, qu'on agrège au fur et à mesure
	fabrique_cmd: does [ ;{{{
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
	call/wait/error cmd err ;TODO replace by call_wait_output_error; sort out first how we pass the output, for the use of err in the next line.
	if err [print rejoin ["Error while dumping database structure using command: " newline cmd newline {Error message, if any: "} err {"}]]

	dbhost: dbhost2
	dbname: dbname2
	filename: "tt_gll_2.sql"
	filename2: copy filename
	close db
	connection_db
	fabrique_cmd
	err: copy ""
	call/wait/error cmd err ; TODO replace by call_wait_output_error; see above
	if err [print rejoin ["Error while dumping database structure using command: " newline cmd newline {Error message, if any: "} err {"}]]

	; les dumps sont générés, on les compare:
	print "Structure dumps generated, comparison: "
	cmd: rejoin ["diff " filename1 " " filename2]
	print cmd
	tt: copy ""
	err: copy ""
	call/wait/output/error cmd tt err ; TODO replace by call_wait_output_error; see above
	if err [print "Error while running diff"]
	print "diff output:"
	print tt

	return tt
]; }}}
sql_result_csv:              does      [ "Utility function to be run after run_query: returns a .csv dataset from sql_result_fields and sql_result datasets" ; {{{
	tt: copy []
	append/only tt sql_result_fields
	append      tt sql_result
	return Mold-CSV tt
] ;}}}
; general utility functions:
; Definition of standard charsets useful for PARSEing: {{{
	letter: charset [#"a" - #"z" #"A" - #"Z"]
	digit: charset  [#"0" - #"9"]
	space: charset  [#" "]
	letter-or-digit: union letter digit
	letter-or-digit-nospace: exclude letter-or-digit space
	digit-decimalplace: union digit charset [#"."]
;}}}
chk_file_exists:             func      [ "Simply checks for the existence of a file" file_in] [ ;{{{
	if error? try [
	file_in_reader: open/string/lines/read to-file file_in
	close file_in_reader
	return true] [
	return false ]
	] ;}}}
trim_last_char:              func      [ "Trims last character from a given string" txt] [ ;{{{
	txt: (copy/part txt ((length? txt) - 1))
	return txt
	] ;}}}
trim_first_char:             func      [ "Trims first character from a given string" txt] [ ;{{{
	txt: (copy/part at txt 2 ((length? txt) - 1))
	return txt
	] ;}}}
substring:                   func      [ "substring: useless, but still, sometimes useful" string [string!] offset [integer!] length [integer!]] [ ;{{{
    copy/part at string offset length
];}}}
left:                        func      [ "as useless but still sometimes useful, as substring" string [string!] length [integer!] ] [ ;{{{
    copy/part string length
] ;}}}
right:                       func      [ "as useless but still sometimes useful, as substring" string [string!] length [integer!] ] [ ;{{{
	offset: (length? string) - length + 1
    copy/part at string offset length
]
;>> right "bonjour" 4
;== "jour"
;>> left "bonjour" 3
;== "bon"
;}}}
pad:                         func      [ "Pads a value with leading zeroes or a specified fill character." ;{{{
  val [string! number!] n [integer!]
  /with c [char!] "Optional Fill Character"
][
  head insert/dup val: form val any [all [with c] #"0"] n - length? val] ;}}}
continue:                    does      [ {continue: as in python; to use in a loop, do: "loop [catch[...]]"} ; {{{
;suivant conseil Nenad, pour mimer le comportement d'un continue dans une boucle
throw 'continue] ;}}}
timestamp_:                  does      [ "Gets an underscored timestamp" ; {{{
trim_last_char trim_last_char replace/all replace/all replace/all to-iso-date now " " "__" "-" "_" ":" "_"]
;}}}
print-list:                  func      [ l [block!]] [" A very simple function, to quickly print a list" ;{{{
	foreach i l [
		print i
	]
]
;}}}
print_lang:                  func      [ txt ] [ "A very simple function, to print a text from a block of strings, depending on a language.  A sort of i18n àlamordmoilnœud."; {{{
	switch (left lang 2) [
		"fr" [print (reduce (txt/1))]
		"en" [print (reduce (txt/2))]
]	]
;}}}
call_wait_output_error:      func      [ "Run a shell call and get stdio output, and err output" ; {{{
		;TODO make a wrapper call_wait_output_error including this code, and replace all call/... by this wrapper in the geolllibre codebase => done
	cmd [string!] "command to be run by the shell"
	] [
		;print rejoin["Running: " cmd]  ; too verbose in numerous cases TODO do that if a DEBUG flag is on.
		call_output:  copy "" copy			; used to be called tt
		call_error: copy ""					; used to be called err
		call/wait/output/error cmd call_output call_error
		prin call_output
		if (call_error != "") [print rejoin ["Error: " newline call_error]]
		return call_output
] ;}}}]
contig_sequences:            function  [ {Function taking input = list of values, integers or dates; output = list of list of contiguous sequences with only starts and ends.  Single items (not contiguous with any other) are listed as a single-item sublist.} ;{{{
	input_serie [series!]
	]
	[
	in_sequence val output
	]
	[
	sort input_serie
	output: copy ""
	in_sequence: false
	start_sequence: does [ append output rejoin ["[" val      ] in_sequence: true  ]
	end_sequence:   does [ append output rejoin [" " val "] " ] in_sequence: false ]
	for i 1 (length? input_serie) 1 [
		val: input_serie/(:i)
		either val + 1 = input_serie/(:i + 1) [
			; next item is contiguous
			unless in_sequence [ start_sequence ]
		] [
			; next item is not contiguous
			either in_sequence [
				end_sequence
			][
				append output rejoin ["[" input_serie/(:i) "] "]
				in_sequence: false
			]
		]
	]
	return to-block output
];}}}
confirm:                     func      [ "Confirms a user choice." ; gotten from r3 => no, rewritten, rather ; {{{
    question [series!]
][
until [
	response: ask rejoin [question " (y-o-s-1 or n-0)? " ]
	parse (lowercase response) [ ["1" | "o" | "n" | "y" | "s" | "0"]]
]
return parse (lowercase response) [ ["o" | "y" | "s" | "1"]]
]
;}}}
run_clipboard_rebol_code:    does      [ "A utility that automatically runs Rebol code in the clipboard, or just highlighted text in X systems." ; {{{ } } }
;run_clipboard_rebol_code: does [ "A utility to automatically run Rebol code in the clipboard, or just highlighted in X systems" ; { {{
;Un utilitaire pour faire tourner automatiquement le code Rebol surligné:
 timewait: 0.2
 changed: false
 wait-duration: :0:2
 code_before: copy ""
 err: copy []
 write clipboard:// ""
 c: open/binary/no-wait [scheme: 'console]
 print "Press any key to suspend automatic execution of code in the clipboard..."
 enroute: true
 forever [
  if not none? wait/all [c timewait] [
   ask "Automatic clipboard code execution suspended; press Enter to resume..."
   print "Automatic clipboard code execution resumed; press any key to suspend..."
  ]
; enroute: not enroute changed: true]
;  if changed [
;   either enroute [
;   ][
;   ]
;  changed: false
;  ]
;  if enroute [
   code: copy read clipboard://
   if code != code_before [
    ;print "début"
    code_before: copy code
    print ";======================================================="
    print ";========== Code from clipboard: =========="
    print code
    print ";======== Code evaluation output: ========="
    if error? try [ do load code ] [
     print ";### code not valid ###"
     ;err: disarm :err
     ;print probe disarm err
     ;print reform [
     ; err/id err/where err/arg1
     ; newline
     ;]
     print ";######################"
    ]
    print ";==========================================^/"
   ]
;  ]
  wait timewait
] ]

;
;;Un utilitaire pour faire tourner automatiquement le code Rebol surligné:
; timewait: 0.2
; code_before: copy ""
; err: copy []
; write clipboard:// ""
; forever [
;  code: copy read clipboard://
;  if code != code_before [
;   ;print "début"
;   code_before: copy code
;   print ";======================================================="
;   print ";========== Code from clipboard: =========="
;   print code
;   print ";======== Code evaluation output: ========="
;   if error? try [ do load code ] [
;    print ";### code not valid ###"
;    ;err: disarm :err
;    ;print probe disarm err
;    ;print reform [
;    ; err/id err/where err/arg1
;    ; newline
;    ;]
;    print ";######################"
;   ]
;   print ";==========================================^/"
;  ]
;  wait timewait
;] ]
;}}}





; Les dates du GeolPDA sont au format epoch en millisecondes; voici deux fonctions pour convertir les epoch en date et réciproquement:
; Dates from GeolPDA are expressed as epoch in millisecond; these are two functions converting these epoch to date and vice versa.
epoch-to-date:               func      [ "Converts an epoch to a date" ; {{{
; from http://www.rebol.net/cookbook/recipes/0051.html
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
];}}}
date-to-epoch:               func      [ "Converts a date to an epoch" ; {{{
	"Return date in unix time format from a date in REBOL format"
	rebol-date [date!] "Date in REBOL time format"
	][
	if rebol-date/time = none [
    rebol-date: to-date rejoin [rebol-date "/00:00:00"]
	]
	rebol-date: rebol-date - now/zone
	return to-integer (rebol-date - 1-Jan-1970 * 86400) +
	(rebol-date/time/hour * 3600) +
	(rebol-date/time/minute * 60) + rebol-date/time/second
] ;}}}
epoch_ms_to_AAAAMMJJ_hhmmss: func      [ "Converts directly epoch ms format (pictures from GeolPDA) to AAAAMMJJ_hhmmss.jpg (default pictures names on android)" epoch_ms] [ ;{{{
; et voici une fonction pour convertir directement le format epoch ms de GeolPDA en date au format des noms des photos par défaut d'android, à savoir AAAAMMJJ_hhmmss.jpg:
	tmp: to-date epoch-to-date (to-integer ((to-decimal epoch_ms) / 1000))
	return rejoin [ tmp/year pad tmp/month 2 pad tmp/day 2 "_" pad tmp/time/hour 2 pad tmp/time/minute 2 pad to-integer tmp/time/second 2]
]
;}}}
AAAAMMJJ_hhmmss_to_epoch_ms: func      [ "Converts directly AAAAMMJJ_hhmmss (default pictures names on android) to epoch ms format (pictures from GeolPDA)" timestamp ] [ ; {{{
; et voici la réciproque, pour convertir des dates au format des noms des photos par défaut d'android, à savoir AAAAMMJJ_hhmmss.jpg en epoch en ms:
;	timestamp: "20160915_145150"
	y: m: d: hr: min: sec: copy ""
	parse timestamp [ copy y 4 digit copy m 2 digit copy d 2 digit "_" copy hr 2 digit copy min 2 digit copy sec 2 digit end]
	; ?? y ?? m ?? d ?? hr ?? min ?? sec
	tmp: make date! rejoin [d "-" m "-" y "/" hr ":" min ":" sec]
	;return ((date-to-epoch tmp) * 1000)
	; TODO ** Math Error: Math or number overflow
	return (date-to-epoch tmp) * 1000.0
]
;}}}
epoch_ms_to_date:            func      [ "Converts directly epoch ms format (pictures from GeolPDA) to dd/mm/yyyy (default date on rebol)" epoch_ms] [ ;{{{
; et une fonction pour convertir directement le format epoch ms de GeolPDA en date au format rebol:
	tmp: to-date epoch-to-date (to-integer ((to-decimal epoch_ms) / 1000))
	return to-date rejoin [ pad tmp/day 2 "/" pad tmp/month 2 "/" tmp/year ]
]
;}}}

; Functions concerning GeolPDA data management:
synchronize_geolpda_files: does [ "Synchronises data from files retreived from a GeolPDA"; {{{
	print "Synchronization process..."
			;DONE move the next piece of code in synchronize_geolpda_files (!...) => done. TODO => test
	; Apparently due to the new MTP protocol used to connect to Android devices,
	; directories with abundant (actual use case: 133) files lead to errors in
	; the MTP mounted filesystem.  Therefore, we make another directory to store
	; archived photos which have already been synchronised, this directory being
	; ignored:
	dir_photos_transferred: rejoin [dir_mount_geolpda_android "photos_transferred"]
	unless exists? dir_photos_transferred [
		; directory does not already exists: create it:
		make-dir dir_photos_transferred ]
	; Make a timestamped subdirectory, in order to avoid, as much as possible,
	; the "photos_transferred" directory saturation (which may well lock MTP).
	append dir_photos_transferred rejoin ["/" timestamp_]
	make-dir dir_photos_transferred
	; first solution, using rsync: abandoned, as rsync does not seem to cope well with MTP protocol used on recent (as of 2016_09_21__23_23_08) android devices: ; {{{
	;; TODO: make this platform-independent:
	;; as is, it will /only work on a platform where rsync is installed and correctly accessible in the $PATH
	;;rsync --inplace -auv --del --exclude="tmp/" /mnt/galaxy1/geolpda/ geolpda/android_cp/geolpda/
	;;###################### DISABLED, WAY TOO DANGEROUS! ################################################
	;;###################### RE-ENABLED, bravement...     ################################################
	;; For security (some files were just deleted...), first do a --dry-run , then confirm:
	;print {Dry run:}
	;;cmd: rejoin [{rsync --dry-run --inplace -auv --del --exclude="tmp/" } dir_mount_geolpda_android { } dir_geolpda_local ]
	;call_wait_output_error rejoin [{rsync --dry-run -azcv --exclude="photos_transferred/" } dir_mount_geolpda_android { } dir_geolpda_local ]  ; way more prudent options
	;prin "Perform these actions: y/n?"
	;either ((lowercase input ) = "y") (crochet qui ne passe curieusement pas dans un commentaire...)
	; really do the synchronization:
	;	call_wait_output_error replace cmd "rsync --dry-run" "rsync "
	;	print "Press any key to continue..."
	;	input
	;}}}
	; Second solution, implemented in raw code:
	; Get photos listings:
	ls_photos_local:  read to-file rejoin [dir_geolpda_local         "photos/" ]
	ls_photos_device: read to-file rejoin [dir_mount_geolpda_android "photos/" ]
	photos_to_transfer: exclude ls_photos_device ls_photos_local ; for the (abnormal, yet possible) case if photos are still in the android device in the geolpda/photos directory while they have already been transferred in the local directory.
	either ((length? photos_to_transfer) < 1) [ print "No photos to be transferred."] [
		prin "Photos to be transferred: "
		print photos_to_transfer
		prin "Perform the transfer: Y/n?"
		tt: input
		either  ((lowercase tt ) = "y") OR (tt = "") [
			print "copying files:"
			foreach f photos_to_transfer [
				prin rejoin [to-string f " "]
				copy-file (to-file rejoin [dir_mount_geolpda_android "photos/" f]) (rejoin [dir_geolpda_local "photos/"])
			]
			; Move photos in the dir_photos_transferred directory:
			; Rebol apparently does not provide a way to move files to directories,
			; so the shell will do:
			cmd: rejoin ["mv " dir_mount_geolpda_android "photos/* " dir_photos_transferred "/"]
			print "On android device, move photo files to an archive directory:"
			call_wait_output_error cmd
			;TODO: idea for GeolPDA: instead of dumping all pictures in one subdirectory, make one subdirectory per day (again, to avoid that pesky directory saturation).
			; Reduce GeolPDA pictures sizes in the local copy:{{{
			size_max: 700
			print rejoin ["Reduction of pictures to " size_max " pixels:"]
			dir_red: rejoin [dir_geolpda_local "photos/reduced" ]
			dir_ori: rejoin [dir_geolpda_local "photos/original"]
			unless exists? dir_red [ make-dir dir_red ]
			unless exists? dir_ori [ make-dir dir_ori ]
			foreach f photos_to_transfer [
				if find f "jpg" [
					call_wait_output_error rejoin ["convert -geometry " size_max " " dir_geolpda_local "photos/" f " " dir_red "/" f ]
					call_wait_output_error rejoin ["mv " dir_geolpda_local "photos/" f " " dir_ori]
				] ]
			call_wait_output_error rejoin ["mv " dir_red "/* " dir_geolpda_local "photos/ && rmdir " dir_red]
			; TODO apply rotation, if any, to file
			; TODO set timestamp to exif timestamp
			; TODO add geotags, if any gpx?
		] [ print "No synchronization done."]
	]
	print "DCIM pictures synchronization and reduction process:"
	; Get photos listings:
	tt: rejoin [dir_dcim_local now/year "/reduit_700/"]
	unless exists? to-file tt [make-dir tt]
	ls_photos_local:  read to-file tt
	ls_photos_device: read to-file         dir_mount_dcim_android

	; Treat the case when image files from device are not named according to usual convention (i.e. "20170414_120621.jpg")
	; used commonly in Android device, but using a prefixed "IMG_" convention (i.e. "IMG_20170414_120621.jpg").
	; Radical treatment: rename files in their original directory.  Not very subtle, I must admit.
	if (find to-string ls_photos_device "IMG" ) [
		print "Files not following usual convention aaaammjj_hhmmss.jpg, prefixed with IMG_: to be renamed:"
		old_wd: copy pwd
		cd :dir_mount_dcim_android
		foreach p ls_photos_device [
			if (find (to-string p) "IMG") [
				rename to-file p to-file (replace (to-string p) "IMG_" "")
			]
			cd :old_wd
		]
		ls_photos_device: read to-file         dir_mount_dcim_android
	]

	sort ls_photos_local
	sort ls_photos_device

	either ((length? photos_to_transfer) > 1) [
		; In case there were GeolPDA photos transferred:
		; first photo to transfer: oldest one among the GeolPDA photos which have already been transferred:
		sort photos_to_transfer
		date_start: first parse epoch_ms_to_AAAAMMJJ_hhmmss replace (to-string (first photos_to_transfer)) ".jpg" "" "_"
		date_start: to-date rejoin [substring date_start 1 4 "-" substring date_start 5 2 "-" substring date_start 7 2]
		; last one: youngest one among the same list:
		date_end:   first parse epoch_ms_to_AAAAMMJJ_hhmmss replace (to-string (last  photos_to_transfer)) ".jpg" "" "_"
		date_end: to-date rejoin [substring date_end 1 4 "-" substring date_end 5 2 "-" substring date_end 7 2]
	] [
		; No photos were transferred: get dates from observation points: => impossible, the process of getting data from sqlite database has not yet taken place:
		; TODO problem to be solved later.
		print "No photos were transferred."
	]

	ls_photos_device_to_be_transferred: copy []
	foreach p ls_photos_device [
		if (find p ".jpg") [
			t: first parse (to-string p) "_"
			if all	[
					(( to-decimal t) >= (to-decimal (replace/all (to-iso-date date_start) "-" "")))
					(( to-decimal t) <= (to-decimal (replace/all (to-iso-date date_end  ) "-" "")))
				] [
					append ls_photos_device_to_be_transferred p
	]	]	]
	prin "Photos from DCIM directory (not taken using GeolPDA) to be transferred:"
	print ls_photos_device_to_be_transferred
	prin "Perform the transfer: Y/n?"
	tt: input
	either ((lowercase tt ) = "y") OR (tt = "") [
		print "copying files:"
		foreach f ls_photos_device_to_be_transferred [
			copy-file (to-file rejoin [dir_mount_dcim_android f]) (rejoin [dir_dcim_local now/year])
		]
		; Reduce pictures sizes in the local copy:
		print rejoin ["Reduction of pictures to " size_max " pixels:"]
		dir_red: rejoin [dir_dcim_local now/year "/reduit_700" ] 	; TODO make directory name more generic and less French
		dir_ori: rejoin [dir_dcim_local now/year "/original"   ]
		unless exists? dir_red [ make-dir dir_red ]
		unless exists? dir_ori [ make-dir dir_ori ]
		foreach f ls_photos_device_to_be_transferred [
			if find f "jpg" [
				call_wait_output_error rejoin ["convert -geometry " size_max " " dir_dcim_local now/year "/" f " " dir_red "/" f ]
				call_wait_output_error rejoin ["mv " dir_dcim_local now/year "/" f " " dir_ori] ;# TODO ACHTUNG! ÇA NE MARCHERA PAS SI ON DOMPE LES DONNÉES DE L'ANNÉE PRÉCÉDENTE! CORRIGER!
			] ]
		; TODO apply rotation, if any, to file
		; TODO set timestamp to exif timestamp
		; TODO add geotags, if any gpx?
		; make symlinks in GeolPDA photos directory:
		;cmd: rejoin ["ln -s " dir_dcim_local now/year "/reduit_700/* " dir_geolpda_local "/photos/"]
		;call_wait_output_error cmd
		cmd_big: copy ""
		foreach f ls_photos_device_to_be_transferred [
			; TODO generally, wherever reduit_700 is read (like below), test if reduit_700 subdirectory exists before trying to read it; if it doesn't, create it.
			cmd: rejoin ["ln -s " dir_dcim_local now/year "/reduit_700/" f " " dir_geolpda_local "photos/"]
			;call_wait_output_error cmd
			append cmd_big rejoin [cmd newline]
		]
		call_wait_output_error cmd_big
	] [ print "No synchronization done."]
;_______________________________________________________________________________________________________________________________
];}}}
synchronize_oruxmaps_tracklogs: does [; {{{
;	; first attempt, using rsync:{{{
;	; TODO: make this platform-independent:
;	; as is, it will /only work on a platform where rsync is installed and correctly accessible in the $PATH
;	print "Synchronization process..."
;	; For security first do a --dry-run , then confirm:
;	print {"Dry run:}
;	call_wait_output_error rejoin [{rsync --dry-run --inplace -auv --del --exclude="tmp/" } (dirize dir_mount_oruxmaps_android/tracklogs) { } (dirize dir_oruxmaps_local/tracklogs) ]
;	prin "Perform these actions [Yn]?"
;	if ((lowercase input ) = "y") [
;		; really do the synchronization:
;		cmd: replace cmd "rsync --dry-run" "rsync "
;		call_wait_output_error cmd
;	]
;	print "Press any key to continue..."
;	input
;	}}}
	; second try, using rebol commands (instead if rsync which stalled on MTP connexions):
	print "Synchronization process..."
	ls_gpx_telephone: copy []
	foreach f read (dirize dir_mount_oruxmaps_android/tracklogs) [ if find f "gpx" [ append ls_gpx_telephone f] ]
	ls_gpx_local: read (dirize dir_oruxmaps_local/tracklogs) ; ATTENTION! il y avait la ligne suivante: 	ls_gpx_local: read (dirize dir_oruxmaps_local)
	gpx_files_to_be_copied: exclude ls_gpx_telephone ls_gpx_local
	common_gpx_files:     intersect ls_gpx_telephone ls_gpx_local
	foreach f common_gpx_files [
		?? f
;		input
		size_telephone: size? to-file rejoin [dir_mount_oruxmaps_android/tracklogs "/" f]
		size_local:     size? to-file rejoin [dir_oruxmaps_local/tracklogs "/" f]
		unless (size_local = size_telephone) [
			?? size_local
			?? size_telephone
			append gpx_files_to_be_copied f
		] ]
	print-list gpx_files_to_be_copied
;	print "anykey"
;	input
	; TODO previous line does not work as expected
	foreach f gpx_files_to_be_copied [copy-file (to-file rejoin [dir_mount_oruxmaps_android/tracklogs "/" f]) (to-file rejoin [dir_oruxmaps_local/tracklogs "/" f])]

];}}}

get_bdexplo_max__id: does [; TODO REMOVE THIS FUNCTION Remove records from dataset from GeolPDA which are already in database: 2014_02_12__10_32_25: much more simple: get the maximum of _id in the bdexplo database (the field is waypoint_name): {{{
;TODO function name not very appropriate: to be changed to something better
if error? try [
	x: run_query rejoin [{SELECT count(*) FROM public.field_observations WHERE device = '} geolpda_device {';}]
	either ( x/1/1 = 0 ) [
		; case of an empty database, or if no records are present for the device geolpda_device:
		max_waypoint_name: 0
		]
		[
		run_query rejoin [{SELECT max(waypoint_name::numeric) FROM public.field_observations WHERE device = '} geolpda_device {';}]
		max_waypoint_name: to-integer to-string first (copy sql_result)
		]
	]
	[
	print rejoin ["Error: there are certainly non-numeric values in waypoint_name field from public.field_observations table in " dbname " database."
	flag_ERROR: true]
	]
; and, later, only consider data with higher _id
];}}}
get_postgeol_max_timestamp_epoch_ms: does [ ; Even more simple than get_postgeol_max__id: get the maximum of timestamp_epoch_ms in the postgeol database:{{{
if error? try [
	x: run_query rejoin [{SELECT count(*) FROM public.field_observations WHERE device = '} geolpda_device {';}]
	either ( x/1/1 = 0 ) [
		; case of an empty database, or if no records are present for the device geolpda_device:
		tmp: 1340710529053 ; first time ever the GeolPDA was used in production.
		]
		[
		run_query rejoin [{SELECT max(timestamp_epoch_ms::numeric) FROM public.field_observations WHERE device = '} geolpda_device {';}]
		tmp: to-integer to-string first (copy sql_result)
		]
	]
	[
	print rejoin ["Error: probably some incorrect values in timestamp_epoch_ms field from public.field_observations table in " dbname " database."
	flag_ERROR: true]
	]
	return tmp		; the function used to set a global variable max_timestamp_epoch_ms => replaced by a tmp variable, and return its value
; and, later, only consider data with higher timestamp_epoch_ms
] ;}}}

chk_directories_mount_and_local: does [;{{{
	all [
		exists? dir_mount_geolpda_android
		exists? dir_geolpda_local
	]
];}}}

get_geolpda_data_from_csv: does [ ; Inutile si on n'utilise pas le .csv: {{{
; l'en-tête du csv => (TODO: les noms de champs sont à réviser!):
;lines/1 == {_id,poiname,poitime,elevation,poilat,poilon,photourl,audiourl,note}

observations: copy []    ; un tableau contenant les observations
foreach line lines [     ; on remplit ce tableau
	if line == "" [ break ]
	t: parse/all line ","
	append observations reduce [to-list skip t 1]
]
;?? observations

; On enlève la première ligne d'en-tête:
remove observations

; On trie la table: {{{
;sort observations
; non, ça déconnait, pour Fred Rossi, qui, les [ 27-Feb-2013 28-Feb-2013 1-Mar-2013 ], avait des identifiants sans zéros préfixant, donc des tris asciibétiques aberrants: [ ;{{{
;TotBol1
;TotBol10
;TotBol11
;TotBol12
;TotBol13
;TotBol14
;TotBol15
;TotBol16
;TotBol17
;TotBol18
;TotBol19
;TotBol2
;TotBol20
;TotBol21
;TotBol22
;TotBol3
;TotBol4
;TotBol5
;TotBol6
;TotBol7
;TotBol8
;TotBol9
;] ;}}}
; Donc on trie la table par timestamp, plutôt:
field: 2    ; le champ sur lequel trier: timestamp = 2, en l'occurrence
sort/compare observations func [a b] [(at a field) < (at b field)]
; }}}

; TODO récupérer les données d'orientations
] ;}}}
get_geolpda_data_from_sqlite: does [ ; Open sqlite GeolPDA, get data:{{{
; Library to access sqlite GeolPDA database:
do %~/rebol/library/scripts/btn-sqlite.r

print "Open GeolPDA database..."
change-dir dir_geolpda_local
copy-file %geolpda %geolpda_copy.db
	; => not terrible; this file copy is /only due to the
	;    fact that the btn (better than nothing) driver does
	;    not support sqlite file without extension...
db: open to-url rejoin [{btn://localhost/} dir_geolpda_local {geolpda_copy.db}]

; Get data: as db is the same name as defined for default
; database connexion in gll_routines.r, we can use the functions:
; observations: {{{
run_query "SELECT * FROM poi ORDER BY poitime"	; ORDER BY évitera de trier par la suite
	; DEBUG TODO remove ça
	; write %qq1 sql_result_csv

; Comparison of field list: to be sure that the table structure matches the
; one used at the time of coding (23-Oct-2013/9:24:01+2:00)
unless sql_result_fields = ["_id" "poiname" "poitime" "elevation" "poilat" "poilon" "photourl" "audiourl" "note"] [
	print "WARNING! field names differ from GeolPDA reference implementation"
	print "Error, halting"
	halt
]
geolpda_observations:        copy sql_result
geolpda_observations_fields: copy sql_result_fields
;print rejoin [tab length? geolpda_observations " records in observations table"]
;}}}
; orientations:{{{
run_query "SELECT * FROM orientation"
; Comparison of field list: to be sure that the table structure matches the
; one used at the time of coding (23-Oct-2013/9:24:01+2:00)
unless sql_result_fields = ["_id" "poi_id" "orientationtype" "rot1" "rot2" "rot3" "rot4" "rot5" "rot6" "rot7" "rot8" "rot9" "v1" "v2" "v3"] [
	print "ATTENTION! field names differ from GeolPDA reference implementation"
	print "Error, halting"
	halt
]
; If we reached here, we are ok; now, it is necessary to also fetch the full id from observations by JOINing:
;run_query "SELECT poiname, orientation._id, poi_id, orientationtype, rot1, rot2, rot3, rot4, rot5, rot6, rot7, rot8, rot9, v1, v2, v3 FROM orientation LEFT JOIN poi ON poi._id = orientation.poi_id"
; also, make a block from the matrix measurements:
run_query "SELECT poiname, orientation._id, poi_id, orientationtype, '[' || rot1 || ' ' || rot2 || ' ' || rot3 || ' ' || rot4 || ' ' || rot5 || ' ' || rot6 || ' ' || rot7 || ' ' || rot8 || ' ' || rot9 || ']' AS rotation_matrix FROM orientation LEFT JOIN poi ON poi._id = orientation.poi_id"

geolpda_orientations: 			copy sql_result
geolpda_orientations_fields: 	copy sql_result_fields
;non: == ["poiname" "_id" "poi_id" "orientationtype" "rot1" "rot2" "rot3" "rot4" "rot5" "rot6" "rot7" "rot8" "rot9" "v1" "v2" "v3"]
;     == ["poiname" "_id" "poi_id" "orientationtype" "rotation_matrix"]
print rejoin [tab length? geolpda_orientations " records in orientations measurements table"]

;}}}

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
print "Dates with observations data in database: "
if (none? date_start) [
	foreach j jours [print j]   ; <= la liste des jours, triée
]
] ;}}}
get_geolpda_data_from_postgresql: does [;{{{
	; if we are not yet connected to the database:
	connection_db
	print rejoin ["Open GeolPDA data in field_observations table on " dbname " database hosted by " dbhost "..."]
	; observations: {{{
	;run_query "SELECT * FROM public.field_observations ORDER BY date"	; ORDER BY évitera de trier par la suite
	; mettre les mêmes champs que dans get_geolpda_data_from_sqlite:
	;         "_id" "poiname"           "poitime" "elevation" "poilat" "poilon" "photourl" "audiourl" "note"] [
	;>> print geolpda_observations_fields
	; opid year        obs_id         date waypoint_name               x              y        z  description                                                                                                                                                                                                                                                                    code_litho code_unit srid geologist icon_descr comments sample_id datasource numauto photos                                                                                                        audio timestamp_epoch_ms db_update_timestamp          username  device                        time
	;>> print mold geolpda_observations/3500
	;[18   2013 "PCh2013_0577" 13-Apr-2013          "297" "-8.1067910187" "6.8693919299" "309.20" {Ech argiles blanches à microboulettes (br.à microc), plans pénétratifs, pX striés et lustrés. Très près surface (probt 3à4m, en tenant compte du décapage), juste sous OxFe avec texture planaire, // structures, ~Nm90/35/S. Plans microstriés dans argiles: objectif strr I}      none      none 4326     "PCh"      none      none      none       none   22257 {1365843316640.jpg;1365843355359.jpg;1365843376191.jpg;1365843399022.jpg;1365843702791.jpg;1365843811907.jpg} ""    1365843013433.0    "2014-02-04 01:21:08.713399" "pierre" "GeolPDA on Samsung Galaxy S2" none]

	run_query "SELECT waypoint_name, obs_id, timestamp_epoch_ms, z, y, x, photos, audio, description, sample_id FROM public.field_observations ORDER BY date, timestamp_epoch_ms, obs_id"	; ORDER BY évitera de trier par la suite => ORDER will work even if timestamp_epoch_ms is not defined (which should never be the case for GeolPDA data, but...), and will sort by obs_id within the same date
		; DEBUG TODO remove ça
		; write %qq1 sql_result_csv
	geolpda_observations:        copy sql_result
	geolpda_observations_fields: copy sql_result_fields
	print rejoin [tab length? geolpda_observations " records in observations table"]
	;}}}
	; orientations:{{{
	run_query "SELECT * FROM public.field_observations_struct_measures ORDER BY obs_id, geolpda_poi_id, geolpda_id"
	;>> ?? sql_result_fields
	;sql_result_fields: ["opid" "obs_id" "measure_type" "structure_type" "north_ref" "direction" "dip" "dip_quadrant" "pitch" "pitch_quadrant" "movement" "valid" "comments" "numauto" "db_update_timestamp" "username" "datasource" "rotation_matrix" "geolpda_id" "geolpda_poi_id" "sortgroup"]
	; non, pas bon, il faut reconstruire les champs tels qu'issus du GeolPDA:
	;poiname _id poi_id orientationtype rot1 rot2 rot3 rot4 rot5 rot6 rot7 rot8 rot9 v1 v2 v3
	;>> print geolpda_orientations/1
	;PCh2012_0276 1 0 L -0.825988829135895 0.563685536384583 -0.0010570005979389 -0.562389075756073 -0.823959052562714 0.0693530738353729 0.0382223948836327 0.0578793101012707 0.997591555118561 0.0 0.0 0.0

	;SELECT
	;obs_id, geolpda_id, geolpda_poi_id, measure_type, rotation_matrix
	;/*
	;opid,
	;structure_type, north_ref,
	;direction, dip, dip_quadrant, pitch, pitch_quadrant, movement, valid, comments, numauto, db_update_timestamp, username, datasource,
	;sortgroup
	;*/
	;FROM public.field_observations_struct_measures WHERE obs_id ILIKE 'PCh2012_____' ORDER BY obs_id, geolpda_poi_id, geolpda_id;

	run_query "SELECT obs_id, geolpda_id, geolpda_poi_id, measure_type, rotation_matrix FROM public.field_observations_struct_measures ORDER BY obs_id, geolpda_poi_id, geolpda_id"

	geolpda_orientations: 			copy sql_result
	geolpda_orientations_fields: 	copy sql_result_fields
	print rejoin [tab length? geolpda_orientations " records in orientations measurements table"]

	;}}}
] ;}}}
update_field_observations_struct_measures_from_rotation_matrix: function [ ;{{{ ; old name: computes_structural_measurements_from_geolpda_matrix
	"Updates field_observations_struct_measures table in bdexplo database, fields (north_ref, direction, dip, dip_quadrant, pitch, pitch_quadrant, movement) are computed from rotation_matrix field, which comes from GeolPDA measurements"
	/criteria {optional criteria to select records to be updated}
	sql_criteria [string!] {criteria, must be a valid SQL statement; i.e. "WHERE opid = 4 AND obs_id ILIKE 'GF2012%'}
	/overwrite "if specified, overwrites existing data in output fields; by default, records with data in north_ref, direction, etc. are *not* updated by this function"
	] [ sql_string measures m o  ] [ ; local variables
	; on va chercher les informations, avec les restrictions si besoin:
	; gather informations, with restrictions, if necessary:
	sql_string: copy "SELECT opid, obs_id, rotation_matrix, numauto FROM public.field_observations_struct_measures "
	if criteria [ append sql_string sql_criteria ]
	unless overwrite [
		either find sql_string "WHERE" [
			append sql_string " AND "
		][	append sql_string " WHERE "]
		append sql_string " (north_ref IS NULL OR direction IS NULL OR dip IS NULL OR dip_quadrant IS NULL OR pitch IS NULL OR pitch_quadrant IS NULL OR movement IS NULL) "
	]
	either find sql_string "WHERE" [
		append sql_string " AND "
	][	append sql_string " WHERE "]
	append sql_string " rotation_matrix IS NOT NULL;" ; it would not make sense to run this function on records without a GeolPDA measurement, which is stored in rotation_matrix field...
	run_query sql_string
	measures: copy sql_result
	;print-list measures
	sql_string: copy {}	;make another SQL statement, which will contain the UPDATE clauses
	; if there is anything to add:
	if ((length? measures) > 0) [  ; the case when no structural measurements were imported never rose until 2018_10_15__19_44_23! => bugfix.
		foreach m measures [ ; iteration over structural measurements in measures
			; NB: SELECT opid, obs_id, rotation_matrix, numauto
			; on crée un objet mesure structurale:
			o: orientation/new first (to-block m/3)
			; on en prend les informations, et on les met dans le sql à faire jouer:
			append sql_string rejoin ["UPDATE public.field_observations_struct_measures SET north_ref = '" o/north_reference "', direction = " o/plane_direction ", dip = " o/plane_dip ", dip_quadrant = '" o/plane_quadrant_dip "', pitch = " o/line_pitch ", pitch_quadrant = '" o/line_pitch_quadrant "', movement = '" o/line_movement "' WHERE numauto = " m/4 ]

			either overwrite [
				append sql_string rejoin [";" newline]
			][	append sql_string rejoin [" AND (north_ref IS NULL OR direction IS NULL OR dip IS NULL OR dip_quadrant IS NULL OR pitch IS NULL OR pitch_quadrant IS NULL OR movement IS NULL);" newline] ]
			; NB: on fait le choix de convertir toutes les informations, quel que soit le type de géométrie (plan, plan-ligne, ligne...); ce n'est qu'ultérieurement qu'on piochera les valeurs utiles dans les champs appropriés, en fonction du type de géométrie.
	]	]
	comment: [; prudemment, dans la phase de débogage:
		;, on ne fait qu'imprimer sur stdout la requête à faire tourner:
		;print sql_string
		; on la copie dans le presse-papiers:
		write clipboard:// sql_string
		print "=> résultat dans le clipboard"
		; on la range dans un féchier à la noix:
		fileout: %qqzz
		write fileout sql_string
		print "=> résultat dans fichier qqzz"
	]
	; actually do the work: insert the generated query string sql_string into the database:
	insert db sql_string
	; TODO: nothing prints out: it would be neat to have some kind of output, just for information purpose: get the outcome of the query, somehow, and print it?
	] ; }}}

;}}}

;****************************************************************************************************************
;TODO spécifier les variables dans les fonctions comme locales, pour éviter trop d'effets de bord indésirables***
;****************************************************************************************************************

; Conversion from decimal degrees to degrees, minutes, seconds ande vice-versa:
dd2dms:                      function  [ {Converts decimal degrees to degrees, minutes, seconds, formatted as DD°MM'SS.SSS"} ;{{{
	dd [string! decimal!]
	/quadrant_lat "Appends latitude N or S to output"
	/quadrant_lon "Appends longitude E or W to output"
	/seconds_accuracy "Specify accuracy for seconds value in output; default is 3 decimal places"
	seconds_decplaces [integer!] "Must be a positive integer value"
	]
	[
	default_seconds_decplaces sign minutes seconds degrees output
	]
	[
	default_seconds_decplaces: 3
	;my $dd = shift;
	;print dd
	sign: sign? dd
	dd: absolute dd
	minutes: (dd - (round/down dd)) * 60
	seconds: (minutes - (round/down minutes)) * 60
	minutes: round/down minutes
	degrees: modulo (round/down dd) 356
	output: copy ""
	unless any [quadrant_lon quadrant_lat] [
		if (sign == -1) [
			if (degrees = 0) 	[
				print "Error, value < 0 and degrees = 0: must specify latitude or longitude using /quadrant_lat or /quadrant_lon"
				return none 	]
		degrees: degrees * sign		]	]
	if quadrant_lon [
		either (dd < 0) [output: "W"] [output: "E"] ]
	if quadrant_lat [
		either (dd < 0) [output: "S"] [output: "N"] ]
	either seconds_accuracy [
		if (seconds_decplaces < 0) [
			print "Error: seconds_decplaces negative amount => default"
			seconds_decplaces: default_seconds_decplaces ]
	] [
		seconds_decplaces: default_seconds_decplaces
	]
	seconds: round/to seconds (to-decimal rejoin ["1E-" seconds_decplaces])
	;append output rejoin [degrees "°" minutes "'" seconds {"}]	; TODO BUG: "°" does not appear on output: probably an extended character related error => check with other flavours of Rebol
	append output rejoin [degrees "d" minutes "m" seconds "s"]	; FIXME:    for the moment, use of d m s instead of ° ' "
	return output
	] ;}}}
dms2dd:                      function  [ "Converts degrees, minutes, seconds to decimal degrees" dms [string!] ] ;{{{
	[ sign rule_quadrant rule_degree rule_minute rule_second degrees minutes seconds ]
	[
	comment [
		; sort of unit tests: expression must return almost zero
				dms: {48 deg 17' 33.39"}	; test
				print (dms2dd dms) - 48.2926083333333		; must return zero
				dms: {11d21'18"W}			; autre test	; *FAIL* if written with °: dms: {11°21'18"W}
				print (dms2dd dms) - ( -11.355)
				dms: {W24deg42min3.33"}		; encore un
				print (dms2dd dms) - -24.700925
				dms: {E24deg42min3.33"}		; encore un
				print (dms2dd dms) - 24.700925
				dms: {24deg42min3.33E"}		; encore un
				print (dms2dd dms) - 24.700925
				dms: {W4d55'65.6"}			; en encore un	; *FAIL* if written with °: dms: {W4°55'65.6"}
				print (dms2dd dms) - -4.93488888888889
	]
	replace/all dms " " ""	; remove all whitespaces
	; detect if positive (longitude East or latitude North) or not:
	sign: 1	; defaults to positive
	rule_quadrant: [ [["N" | "E"] (sign: 1)] | [["S" | "W" | "O"] (sign: -1)] ] ; signs switches to -1 if S or W
	; gets quadrant if any, and gets rid of it, at both ends of input string:
	if (parse/case to-string (first dms) rule_quadrant) [
		dms: right dms ((length? dms) - 1) ]
	if (parse/case to-string (last  dms) rule_quadrant) [
		dms: left  dms ((length? dms) - 1) ]
	;PRINT DMS	; DEBUG
	;PRINT SIGN	; DEBUG
	; parse remaining input string using various symbols for degrees, minutes and seconds:
	rule_degree: ["degrees" | "degres"   | "degree"  | "degrés" | "degré" | "deg" | "d" | "°" | "o" ]
	rule_minute: ["minutes" | "minute"   | "mn"                           | "min" | "m" | "'"       ]
	rule_second: ["seconds" | "secondes" | "seconde" | "second"           | "sec" | "s" | {"}       ]
	;?? dms	;DEBUG
	degrees: minutes: seconds: none
	parse/all dms [copy degrees any digit-decimalplace rule_degree copy minutes any digit-decimalplace rule_minute copy seconds any digit-decimalplace rule_second to end]
	;?? dms ?? degrees	?? minutes ?? seconds		;DEBUG
	if (none? seconds) [seconds: 0]	; cases when seconds are not mentioned
	if (none? minutes) [minutes: 0]	; RARE cases when minutes are not mentioned
	degrees: to-decimal degrees
	minutes: to-decimal minutes
	seconds: to-decimal seconds
	return ((degrees + (minutes / 60) + (seconds / 3600)) * sign)
	]
;}}}
dd2dms_lon_lat_from_qgis:    function  [ {Converts a pair of longitude,latitude coordinates separated by a comma, as it comes from the QGIS "Saisie de coordonnées" extension from decimal degrees to degrees, minutes, seconds, formatted as DD°MM'SS.SSS} ;{{{
	xy [string!]
	/quadrant_lat "Appends latitude N or S to output"
	/quadrant_lon "Appends longitude E or W to output"
	/seconds_accuracy "Specify accuracy for seconds value in output; default is 3 decimal places"
	seconds_decplaces [integer!] "Must be a positive integer value"
	]
	[
	;default_seconds_decplaces sign minutes seconds degrees output
	londd latdd
	]
	[
	replace xy " " ""  ; Remove spaces, if any
	xy: parse xy ","   ; xy has now two coordinates
	londd: to-decimal xy/1
	latdd: to-decimal xy/2
	refined: false
	cmd: "londms: dd2dms"        		; Construction of command to convert longitude
	if quadrant_lon [ append cmd "/quadrant_lon" refined: true ]
	if seconds_accuracy [ append cmd rejoin [ "/seconds_accuracy " seconds_decplaces refined: true ] ]
	unless refined [ append cmd " " ]	; Add an extra space to separate function name with refinements from argument
	append cmd londd
	do cmd								; londms is now defined

	cmd: "latdms: dd2dms"        		; Construction of command to convert latitude
	if quadrant_lat [ append cmd "/quadrant_lat" refined: true ]
	if seconds_accuracy [ append cmd rejoin [ "/seconds_accuracy " seconds_decplaces refined: true ] ]
	unless refined [ append cmd " " ]	; Add an extra space to separate function name with refinements from argument
	append cmd latdd
	do cmd								; latdms is now defined
	return rejoin [ lon ", " lat ]
] ;}}}

; from LouGit:
copy-file:                   func      [ {Copies file from source to destination. Destination can be a directory or a filename.} source [file!] target [file! url!]] [ ;{{{
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
process_cases_table:         function  [ "Processes a matrix (table) of cases, which is a simple multi-line string containing a first line of variables, then one line per case, with the criteria, and the value to be returned for every case. All items are tab or space separated, so that a matrix can be easily pasted to-from a spreadsheet." case_matrix] [mm code v tt ii count] [ ;{{{
; A generic function, which processes a matrix of cases, a bit like in the erosion study expert-case on Reunion Island:
; exemple: {{{
 ; une matrice de cas, volontairement simple, avec des tabulations séparant les choses, de manière à pouvoir coller depuis un simple tableur. Une ligne avec les variables en premier, puis une ligne par cas, avec la dernière chaÃ®ne qui correspond à ce que renverra la fonction:

;case_matrix: {
;v1 v2  v3
;<1  0  >1  "pas bon"
;>1  0 >=1  "bon"
;<1  0  >1  "moyen"
;}

;process_cases_table case_matrix
;On doit aboutir à un bloc de code du type:
;if (all [(v1 < 1) (v2 = 0) (v3 > 1)]) [return "pas bon"]
;if (all [(v1 < 1) (v2 = 0) (v3 > 1)]) [return "pas bon"]
;if (all [(v1 < 1) (v2 = 0) (v3 > 1)]) [return " pas bon"]
;if (all [(v1 > 1) (v2 = 0) (v3 >= 1)]) [return "bon"]
;if (all [(v1 < 1) (v2 = 0) (v3 >1)] [return "moyen"]
;}}}
	mm: parse/all case_matrix "^/"
	foreach ii mm [if ((to-string first mm) = "") [remove first mm mm: next mm ]] 	; skip empty lines, if any
	code: copy {case [^/} 															; final code, returned by function
	v: make block! [] 																; read the variables into v variables block!
	foreach ii (to-block parse (first mm) "") [append v to-word ii]
	mm: next mm 																	;read one line: these are lines with criteria
	while [ not (tail? mm) ] [ 														; while not at the end
		criteria: parse first mm ""
		append code " (all ["
		count: 0
		loop (length? v) [ 															; as many times as variables count:
			count: count + 1
			append code rejoin ["( " v/:count " "]
			any [
				parse/all criteria/:count [copy tt ["=<" | "=>"]                                  (append code rejoin [reverse tt " "]) copy tt to end (append code rejoin [tt " "])]	; comparison, misspelled
				parse/all criteria/:count [copy tt ["<=" | ">=" | "<" | ">"  | "==" | "=" | "!="] (append code rejoin [tt " "])         copy tt to end (append code rejoin [tt " "])]	; comparison
				parse/all criteria/:count [copy tt to end                                         (append code rejoin [" = " tt " "])]                                                   ; no operator: add "="
				]
			append code ") "
		]
		append code rejoin [ {] ) [} mold (criteria/(:count + 1)) "]^/"]
		mm: next mm 																;read one line: these are lines with criteria
	]
	append code "]"
	;print code
	return code
];}}}
mkdiraujourdhui:             function  [ "A simple mkdiraujourdhui utility: creates in the current directory a directory named after the date, i.e. 2015_03_08"] [ tt ] [;{{{
tt: now
make-dir to-file rejoin [tt/year "_" pad tt/month 2 "_" pad tt/day 2]
];}}}


; Functions less general, more specific to GeolLLibre.
gll_create_new_operation:    does      [ "Creation of a new operation in the public.operations (master table): at the moment, just a mere procedure, to be greatly improved." ; {{{
	helptxt: {Creation of a new operation: it INSERTs a record in public.operations table, with a new opid value, which will be the max incremented by 1.  An "operation" is a homogeneous set of data, typically an area, a licence, operated by a single operator over years; or an area studied by a scientific team.}
	; Define opid as the maximum incremented:
	new_opid: (first first run_query "SELECT max(opid) FROM public.operations") + 1
	; Print the little help text defined above:
	print helptxt
	; Inform the user of the new opid number:
	print rejoin ["New opid: " new_opid]
	; Ask the user all necessary information:
	operator:  ask {Operator: typically, company owning a licence (i.e. "GeckoMines SARL"): }
	full_name: ask {Operation full name (i.e. "Native Hydrogen exploration project"): }
	operation: ask {Operation short name, 4 characters (i.e. "GKMH"): }
	year:      to-integer ask {Starting year of operation (optional): }
	lat_min:   to-decimal ask {Minimal latitude, decimal degrees: }
	lat_max:   to-decimal ask {Maximal latitude, decimal degrees: }
	lon_min:   to-decimal ask {Minimal longitude, decimal degrees: }
	lon_max:   to-decimal ask {Maximal longitude, decimal degrees: }
	confidentiality: to-logic ask {Confidentiality (boolean: 1/0: }
	comments:  ask {Comments (optional): }
	; TODO: check, re-ask, make sure that information is reliable, plausible, etc.
	; Now that the information has been gathered, make a SQL INSERT statement:
	sql_string: rejoin [{INSERT INTO public.operations (opid,operation,full_name,operator,year,confidentiality,lat_min,lon_min,lat_max,lon_max,comments) VALUES (} new_opid " , '" operation "', '" full_name "', '" operator "', " year ", " confidentiality ", " lat_min ", " lon_min ", " lat_max ", " lon_max ", '" comments "');"]
	insert db sql_string
	print "Done..."
	insert db "COMMIT;"
	print "commited => end."
	print rejoin ["Inserted record, output from database: " newline
		(first run_query rejoin ["SELECT * FROM public.operations WHERE opid = " new_opid ";"])
	]
];}}}

; fonctions pour la gestion des datasource:
test_datasource_available:   func      [ "Teste si new_datasource_id est libre dans la base" new_datasource_id ] [ ;{{{
	 sql_string: rejoin ["SELECT * FROM public.lex_datasource WHERE opid = '"
	                      opid "' AND datasource_id = " new_datasource_id ";"]
	 res: to-string run_query sql_string
	 ;print probe res
	 either ( res = "") [ return true ] [return false ]
	] ;}}}
get_new_datasource_id:       does      [ ; récupère le premier datasource_id libre {{{
	; 2013_07_09__09_13_51
		; on n'INSERTe pas tout de suite: on fait valider d'abord, dans une ihm
	tt: run_query rejoin ["SELECT max(datasource_id) AS max_datasource_id FROM public.lex_datasource WHERE opid = " opid ";"]
	either ((to-string tt) = "none") [
		new_datasource_id: 1	; pas encore de datasource dans cet opid, on inaugure
		] [
		max_datasource_id: to-integer to-string tt
		new_datasource_id: max_datasource_id + 1
		;TODO: il faudrait plutôt faire un return new_datasource_id, pour éviter la pollution de l'espace de noms principal, et tous les effets de bords qui s'ensuivent; également, cloisonner les variables locales des fonctions, ce pour toutes les fonctions.
	]
	] ;}}}

generate_sql_string_update:  func      [ "Insertion dans public.lex_datasource => TODO renommer cette fonction" new_datasource_id file_in] [ ;{{{
	sql_string_update: rejoin [ "INSERT INTO public.lex_datasource (opid, filename, datasource_id) VALUES (" opid ", '" file_in "', " new_datasource_id ");" ]
	] ;}}}
get_datasource_dependant_information:            func      [ ;{{{
	"Returns the list of tables where a given datasource is mentioned in the current opid, with the count of records concerned" datasource] [
	tables: run_query "SELECT tablename FROM pg_tables WHERE schemaname = 'public' AND tableowner <> 'postgres';"
	; Ôt des tables inutiles, où datasource n'est pas référencé:
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

; usage: {{{
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
delete_datasource_and_dependant_information:     func      ["Deletes a datasource from all tables from bdexplo where its datasource_id is mentioned" datasource] [ ; {{{
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
		;prin rejoin ["-- DÃTRUIRE LES " i/2 "ENREGISTREMENTS DANS " i/1 " (yYoO/nN)? "]
		;r: input
		;either any [(r = 'y') (r = 'Y') (r = 'o') (r = 'O')]  [
			sql: rejoin ["DELETE FROM public." t " WHERE opid = "opid " AND datasource = " datasource "; -- (" n " records should be deleted)"]
			print sql
			;print "--on est timide pour le moment, on ne fait qu'afficher le SQL qui fera le boulot: à vous de le coller où il convient"
		;] [
		;print " Records kept"
		;]
	]
	; éliminons de lex_datasource, bien sÃ»r:
	sql: rejoin ["DELETE FROM public.lex_datasource WHERE opid = " opid " AND datasource_id = " datasource ";"]
	print sql
] ;}}}

; fonctions et objets utilisés pour les structures: géométrie dans l'espace, vecteurs, objets structuraux, etc.
azimuth_vector:              func      [ {Returns the azimuth of a 3D vector (block! containing 3 numerics), with reference to North = y axis} v [block!]] [;{{{
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
; test de la fonction: {{{
	;u: [0.5 0.5 1] ; azim = N45
	;azimuth_vector u
	;== 45.0
	;u: [-0.45 .45 1]
	;>> azimuth_vector u
	;== 315.0
;}}}
;}}}

;=======================================
orientation: make object! [ ;--## An orientation object, which fully characterises a plane and/or a line: ;==={{{
	; ## Les données initiales: {{{
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
	north_reference: 			"Nm"			; default to magnetic North; could be Nu for UTM north, or Ng for geographic North
	matrix: 					copy []			; bloc of 3 blocs of 3 values between 0 and 1: rotation matrix = GeolPDA measurement fully characterising orientation of measuring device
	plane_normal_vector: 		copy []			; unit vector normal to GeolPDA measuring device, screen side; vector going downwards if measurement overturned
	axis_vector: 				make block! []	; unit vector long axis of GeolPDA measuring device, oriented upwards = oriented line
	plane_downdip_azimuth: 		make decimal! 0	; down-dip azimuth of plane, in degrees ; pour l'azimut de downdip: Azimut de OD = , en fait, azimut de ON
	plane_direction: 			make decimal! 0	; direction of the plane, from 0 to 180°
	plane_dip: 					make decimal! 0	; dip of the plane, from 0 to 90°
	plane_quadrant_dip: 		copy ""			; quadrant (N, E, S, W) towards where plane dips
	line_azimuth: 				make decimal! 0	; line azimuth
	line_plunge: 				make decimal! 0	; line plunge
	line_pitch: 				make decimal! 0	; pitch angle of line
	line_pitch_quadrant: 		copy ""			; quadrant (N, E, S, W) towards where line pitches
	line_movement: 				copy ""			; movement (N, I or R, D, S) for faults and equivalents (NB: Inverse & Reverse mean the same)
	line_movement_vertical: 	copy ""			; vertical component of movement (N, I or R)
	line_movement_horizontal: 	copy ""			; horizontal component of movement (D, S)
	overturned: 				make logic! 0	; true if plane overturned: convention = GeolPDA measuring device with screen facing down
	comments: 					copy ""			; comments, if any
	; NOTE: *all* these variables are determined, since the matrix rotation (measurement data from GeolPDA) fully determines plane and line. If the measurement /only concerns a line, or /only a line, the relevant values are /only to be considered.
	a: b: c: d: e: f: g: h: i: make decimal! 0	; (only for coder's convenience... variables in the matrix; TODO: one day, get rid of these)
	;--## methods:
	; construction:
	new: func ["Constructor, builds an orientation object! based on a measurement, as given by GeolPDA device, a rotation matrix represented by a suite of 9 values provided as a block!" m [block!]] [;{{{
		make self [
			; Convert matrix m to a block of blocks named matrix:
			foreach [u v w] m [append/only matrix to-block reduce [u v w]]
			; variables abcdefghi: juste pour un souci d'ergonomie du codeur: {{{
			; la notation de la matrice de rotation est bien plus pratique à manier sous forme de abcdefghi, dans les formules:
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
				comment [; DEBUG
				a: matrix/1/1
				b: matrix/1/2
				c: matrix/1/3
				d: matrix/2/1
				e: matrix/2/2
				f: matrix/2/3
				g: matrix/3/1
				h: matrix/3/2
				i: matrix/3/3
				]
			; Better, more rebolish: (but doesn't work... :-/ {{{
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
			;1) on détecte les jeux et l'overturn: {{{
			; As if the measurement was a fault, determination of the attitude (overturned or not) and movement, both vertical and horizontal components.
			; Cancelled: nice tentative, but merdalors, fonctionne pas, zut: {{{
			comment [
			; table with cases of attitude and movements; result of the matrix "nNS" reads as: (overturned: 0(normal) or 1(overturned), movement vertical, movement horizontal
			table_cases_rotation_movements: {
			 i  h  g
			>0 >0 >0 "0NS"
			>0 >0 <0 "0ND"
			>0 <0 <0 "0IS"
			>0 <0 >0 "0ID"
			<0 >0 >0 "1IS"
			<0 >0 <0 "1ID"
			<0 <0 <0 "1ND"
			<0 <0 >0 "1NS"
			}
			; case determination
			code: process_cases_table table_cases_rotation_movements
			res: do code
			; BUG: une fois le code appelé, les variables i et autres ont été oubliées: ???
			?? res	;DEBUG
			overturned:               to-logic  to-integer to-string res/1
			line_movement_vertical:   to-string res/2
			line_movement_horizontal: to-string res/3
			]
			;}}}
			case [	; more verbose, less elegant, but merdalors:
				(all [(i > 0) (h > 0)  (g > 0)]) [ overturned: false line_movement_vertical: "N" line_movement_horizontal: "S" ]
				(all [(i > 0) (h > 0)  (g < 0)]) [ overturned: false line_movement_vertical: "N" line_movement_horizontal: "D" ]
				(all [(i > 0) (h < 0)  (g < 0)]) [ overturned: false line_movement_vertical: "I" line_movement_horizontal: "D" ] ;****
				(all [(i > 0) (h < 0)  (g > 0)]) [ overturned: false line_movement_vertical: "I" line_movement_horizontal: "S" ] ;****

				(all [(i < 0) (h > 0)  (g > 0)]) [ overturned: true  line_movement_vertical: "I" line_movement_horizontal: "S" ]
				(all [(i < 0) (h > 0)  (g < 0)]) [ overturned: true  line_movement_vertical: "I" line_movement_horizontal: "D" ]
				(all [(i < 0) (h < 0)  (g < 0)]) [ overturned: true  line_movement_vertical: "N" line_movement_horizontal: "D" ]
				(all [(i < 0) (h < 0)  (g > 0)]) [ overturned: true  line_movement_vertical: "N" line_movement_horizontal: "S" ]
			]
			;}}}
			; Calculation of variables:
			; Definition of vectors which fully caracterise the geometry:
			; plane normal vector:: {{{
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
			; axis vector: : {{{
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
	;down_dip_vect: func [] [;{{{ ;=> annulé: en fait, on s'en fout.
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
			;2) on met les vecteurs tous dans le même sens:
			; la normale vers le haut,
			if overturned [
				plane_normal_vector: reduce [plane_normal_vector/1 * -1 plane_normal_vector/2 * -1 plane_normal_vector/3 * -1]
			]
			; la linéation vers le bas.
			if (axis_vector/3 > 0) [
				axis_vector: reduce [axis_vector/1 * -1 axis_vector/2 * -1 axis_vector/3 * -1]
			]
			;3) on calcule les angles pour la représentation conventionnelle
			plane_downdip_azimuth: azimuth_vector plane_normal_vector
			plane_direction: plane_downdip_azimuth - 90
			if (plane_direction <   0) [plane_direction: plane_direction + 180]
			if (plane_direction > 180) [plane_direction: plane_direction - 180]
			; dip of the plane, from 0 to 90°:
			plane_dip: absolute arccosine ( plane_normal_vector/3 ) ; = plongement de OD: ;== 39.8452276492299 ; => correct ; absolute, to avoid problem in arcsine for pitch angle
			case [
				((plane_downdip_azimuth >   315) or (plane_downdip_azimuth <=  45))	[plane_quadrant_dip: "N"]
				((plane_downdip_azimuth >   45) and (plane_downdip_azimuth <= 135))	[plane_quadrant_dip: "E"]
				((plane_downdip_azimuth >  135) and (plane_downdip_azimuth <= 225))	[plane_quadrant_dip: "S"]
				((plane_downdip_azimuth >  225) and (plane_downdip_azimuth <= 315)) [plane_quadrant_dip: "W"]
			]
			line_azimuth: azimuth_vector axis_vector
			;if (axis_vector/3 > 0) [line_azimuth: line_azimuth + 180] ; case when line upwards; convention is azimuth of down lineation <= eliminated case, see above
			;line_plunge: -90 + (arccosine ( axis_vector/3 ))
			line_plunge: absolute arcsine (axis_vector/3)
			;line_pitch: arcsine ( sine (line_plunge) / sine (plane_dip) )	;###BUG? recorrigé en relisant article:
			;line_pitch: arctangent ( (tangent line_plunge) / (sine plane_dip) )	; non...
			;line_pitch: arctangent ( (tangent (line_azimuth - plane_direction)) / (sine plane_dip) )	; toujours VRAIMENT pas...
			;line_pitch: arctangent ((sine plane_dip) / ((sine (line_azimuth - plane_direction)) * tangent plane_dip))	; non!
			;line_pitch: arctangent ((tangent (line_azimuth - plane_direction)) / (cosine plane_dip) * (sine plane_dip))	; toujours pas...
			;line_pitch: absolute arcsine ( ( sine line_plunge ) / ( sine plane_dip ) )	; tout refait; ah, je retombe sur ma première formule.
			line_pitch: absolute arcsine ( minimum 1 ( ( sine line_plunge ) / ( sine plane_dip ) ) )   ; tout refait; ah, je retombe sur ma première formule. Workaround for case where ( sine line_plunge ) / ( sine plane_dip ) slightly exceeds 1 (due to ? it is theoretically impossible that plane_dip < line_plunge; in present case, probably a precision problem for a pitch 90 case)
			comment [;PAS BON:==========================================
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
			];==========================================================
			either (line_azimuth - plane_downdip_azimuth < 0) [	; la ligne est à "gauche" de la plus grande pente
				case [
					(plane_quadrant_dip = "E") [ line_pitch_quadrant: "N" ]
					(plane_quadrant_dip = "S") [ line_pitch_quadrant: "E" ]
					(plane_quadrant_dip = "W") [ line_pitch_quadrant: "S" ]
					(plane_quadrant_dip = "N") [ line_pitch_quadrant: "W" ]
					]
				][												; la ligne est à "droite" de la plus grande pente
				case [
					(plane_quadrant_dip = "E") [ line_pitch_quadrant: "S" ]
					(plane_quadrant_dip = "S") [ line_pitch_quadrant: "W" ]
					(plane_quadrant_dip = "W") [ line_pitch_quadrant: "N" ]
					(plane_quadrant_dip = "N") [ line_pitch_quadrant: "E" ]
					]
				]

			;;line_movement: => inutile {{{
			;		; Avec les conventions prises (GeolPDA en position "lisible" sur une
			;		; mesure de faille normale sans surplomb), ça va être ON ^ AO qui tourne
			;		; dans le sens du mouvement (le tire-bouchon de Maxwell se trouve coincé
			;		; dans la faille en mouvement ou dans la guimauve qui flue).
			;	; Mais déterminons le mouvement de manière un peu moins lyrique et plus pragmatique:
			;	; la composante verticale du mouvement:
			;	; on prend le delta azimut de la ligne (mouvement bloc inférieur) - azimut de la
			;	; ligne de plus grande pente du plan, comme discriminant:
			;	delta_azim_line_plane: line_azimuth - plane_downdip_azimuth
			;	if (delta_azim_line_plane <   0) [ delta_azim_line_plane: delta_azim_line_plane + 360 ]
			;	if (delta_azim_line_plane > 360) [ delta_azim_line_plane: delta_azim_line_plane - 360 ]
			;	either (delta_azim_line_plane >  90)    [ line_movement_vertical:   "N" ] [ line_movement_vertical:   "I" ]
			;	either (delta_azim_line_plane > 180)    [ line_movement_horizontal: "D" ] [ line_movement_horizontal: "S" ]
			; TODO il faudra certainement déterminer un line_pitch_noorient, qui est très probablement l'angle qu'on vient d'obtenir
			; In fact, result is that line_pitch is < 0 when movement inverse:
			;either (line_pitch < 0) [
			;							line_pitch: -1 * line_pitch
			;							if (line_movement_vertical != "I") [alert "error!"]
			;							line_movement_vertical: "I"
			;						] [
			;							line_movement_vertical: "N"]
			;;overturned:
			;if (i < 0) [
			;	overturned: true
			;	plane_dip: 180 - plane_dip
			;	if line_movement_vertical = "I"   [line_movement_vertical: "N"]
			;	if line_movement_vertical = "N"   [line_movement_vertical: "I"]
			;	if line_movement_horizontal = "D" [line_movement_horizontal: "S"]
			;	if line_movement_horizontal = "S" [line_movement_horizontal: "S"]
			;	]
			;;if (plane_dip > 90) [
			;;	plane_dip: 180 - plane_dip
			;;]	;}}}
			; also, reset line_plunge to a positive value:
			;line_plunge: absolute line_plunge	; => done already
			either (line_pitch < 45) [ line_movement: line_movement_horizontal] [ line_movement: line_movement_vertical ]     ; pitch petit: mouvement décrochant dominant; pitch grand: mouvement vertical dominant
		]
	];}}}
	; outputs:
	print_matrix: does [ ;{{{
		;return rejoin ["Matrix: " tab self/matrix]
		tt: copy ""
		foreach [item] self/matrix [
			append tt rejoin [ "(" tab item/1 tab item/2 tab item/3 tab ")" newline]
		]
		return tt
		;		"Normal vector: " 		probe plane_normal_vector newline
		;		"Axis vector: " 		probe axis_vector newline
		;		"Down-Dip azimuth: "	plane_downdip_azimuth newline
		;		"Dip: " 				plane_dip newline
		;		"Plane direction: " 	plane_direction newline
	];}}}
	print_plane: does [ ;{{{
		return rejoin [
			;"Plane "
			north_reference to-string to-integer self/plane_direction "/" to-string to-integer self/plane_dip "/" self/plane_quadrant_dip
		]
	];}}}
	print_line:  does [ ;{{{
		return rejoin [
			;"Line "
			north_reference to-string to-integer self/line_azimuth "/" to-string to-integer self/line_plunge
		]
	];}}}
;	print_plane_line: does [ ;{{{
;		return rejoin [print_matrix newline print_plane newline print_line]
;	];}}}
	print_plane_line: does [ ;{{{
		;Prints a human-readable string; numeric values converted to integers
		sep: "/" ; separator
		return rejoin [
			;"Plane+line "
			north_reference to-integer plane_direction sep to-integer plane_dip sep plane_quadrant_dip sep to-integer line_pitch sep line_pitch_quadrant]
	];}}}
	print_plane_line_movement: does [ ;{{{
		;Prints a human-readable string; numeric values converted to integers
		sep: "/" ; separator
		return rejoin [
			;"Plane+line, movement "
			north_reference to-integer plane_direction sep to-integer plane_dip sep plane_quadrant_dip sep to-integer line_pitch sep line_pitch_quadrant sep line_movement]
	];}}}
	print_tectri: does [ ;{{{
		;Prints a tectri-readable string; numeric values converted to integers
		sep: " " ; separator
		return rejoin [to-integer plane_direction sep to-integer plane_dip sep plane_quadrant_dip sep to-integer line_pitch sep line_pitch_quadrant sep line_movement " " comments]
	];}}}


	trace_structural_symbol: func [diag [object!]] ["Return a DRAW dialect block containing the structural symbol";{{{
		;Je tente de passer en rebol le code python que je fis pour tracer le té de pendage dans le GeolPDA: {{{
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
		;# question de goÃ»t et d'esthétique; on met ça
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
		;# Calcul des coordonnées des points A,B,C,L: {{{
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
		;; => TRÈS piégeux en Rebol; si on met:{{{
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
		; => en VID, plutôt:;{{{
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

;### attention:
diagram: make object! [ ;--## A diagram, which will contain a DRAW string with the T trace from the orientation measurement: ;{{{
	; attributes:
		; plot is a DRAW dialect block containing the diagram:
			plot: copy [pen black]
		; to offset and scale the output of the plot:
			offset: 110x110
			scale:  100
	; methods:
		; functions to trace graphics elements in the plot block:
		plot_reset: does [	plot: copy [pen black]]
		trace_line: func ["traces a line from A point to B point; both are block!s" A [block!] B [block!]] [; {{{
			append plot [line]
			x: (     A/1  * scale) + offset/1
			y: ((0 - A/2) * scale) + offset/2
			append plot as-pair x y
			x: (     B/1  * scale) + offset/1
			y: ((0 - B/2) * scale) + offset/2
			append plot as-pair x y
		];}}}
		trace_circle: func [{traces a circle from center (block! containing xy coordinates) with diameter} center [block!] diameter [number!]] [; {{{
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
;### attention, duplicata avec rondibet.r

;--## structure containing the variables of a structural measurement, using French usual conventions: ;{{{

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
parse_tecto_measure:         func      [{Converts a string structural measurement in the form "Nm85/80/N/70/W/I Overturned plane" to a structural_measurement_convention_fr object} m] [ ; {{{
	; m is for the string containing the structural measurement, with the associated comment
	; RAZ variables, to avoid side-effects:
		NORTH_REF_: DIP_QUADRANT_: PITCH_QUADRANT_: MOVEMENT_: COMMENTS_: copy ""
		DIRECTION_: DIP_: PITCH_: 0
	; rules to parse the structural measurement:
		rule_north_ref:       ["N" ["m" | "g" | "u"]]		; rule for North reference: (m)agnetic, (g)eographic or (u)tm
		separator: charset    ["/" "," "-"]					; separator between elements
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
generate_tectri_file:        function  [ ;{{{
	"Generates a file for TecTri from structural measurements contained in bdexplo database in field_observations_struct_measures table"
	/criteria {optional criteria to select records to be exported}
		sql_criteria [string!] {criteria, must be a valid SQL statement; i.e. "WHERE opid = 4 AND obs_id ILIKE 'GF2012%'}
	/unique_filename "specifies a unique output filename for all measurements"
		filename [string! file!] "output filename, default extension is .tec"
	/onefileperobservation "generates one file per observation; if no file prefix is specified, files are named according to observation identifier (obs_id field) followed by .tec extension"
	/fileprefix "option to set a prefix to output filename"
		prefix [string!] "file prefix"
	;/table "table to query data from"
	;	structures_measures_table [string!] "table name: default is field_observations_struct_measures , it can also be dh_struct_measures"
][
	; local variables:
	sql_string measures newline_ newline obs_id_current obs_id_previous i header_written
][
	; 2015_02_03__15_19_08 add possibility to query from drill hole structural data
	; => no, table structures should be homogeneised first; rather, make another similar function.
	;either table [
	;	; an alternative table is provided: check if it exists:
	;	if error? try [
	;		sql_string: rejoin ["SELECT * FROM " structures_measures_table " LIMIT 0"]
	;		print sql_string
	;		run_query sql_string
	;		] [
	;		print rejoin ["Error: table " structures_measures_table " cannote be queried."]
	;		return none
	;		]
	;	] [
	;	structures_measures_table: "public.field_observations_struct_measures"	; default
	;	]
	; 21_07_2014__10_18_56
	; get data:
		sql_string: copy "SELECT tmp.*, field_observations.description FROM (SELECT opid, obs_id, measure_type, structure_type, north_ref, direction, dip, dip_quadrant, pitch, pitch_quadrant, movement, comments, datasource, sortgroup, device, numauto FROM public.field_observations_struct_measures "
		if criteria [ append sql_string sql_criteria ]
		append sql_string " ) AS tmp JOIN public.field_observations ON (tmp.opid = field_observations.opid AND tmp.obs_id = field_observations.obs_id) ORDER BY tmp.opid, tmp.obs_id, tmp.numauto;"
		;write clipboard:// sql_string
		run_query sql_string
		measures: copy sql_result
		print rejoin [length? measures " structural measurements selected"]
		;print-list measures

	; definitions so that TecTri can correctly read the generated file, with CRLF ending lines:
		crlf: #{0D0A}
		newline_: newline
		newline: crlf
	; initiate some variables:
		;sep: " " ; separator: space
		sep: "^-" ; separator: tabulation
		obs_id_current:   copy ""
		obs_id_previous: copy ""
		i: 0
		unless prefix [prefix: copy ""]
		header_written: false
		comment: copy ""
		filenames: copy []

	; determine filename, if unique:
	if unique_filename [
		replace filename " " "_"
		filename: lowercase filename
		if ((substring filename ((length? filename) - 3) 4) != ".tec") [append filename ".tec"]
		filename: to-file filename
		print rejoin ["Unique output filename: " filename]
		append filenames filename
	]

	; iteration over list of structural measurements
	foreach m measures [
		;print i
		i: i + 1
		obs_id_current: copy m/2
		; convert the none values to empty strings "", to avoid having "none" written in the file contents:
		for j 1 (length? m) 1 [
			if none? m/:j [ poke m j "" ]
		]
		either (obs_id_current != obs_id_previous) [ ; test if we are in the same observation (obs_id)
			; new obs_id
			obs_id_previous: copy obs_id_current
			unless unique_filename [
				filename: to-file rejoin [prefix lowercase obs_id_current ".tec"]	; define one output filename per individual observation
				print rejoin ["Output filename: " filename]
				append filenames filename
			]
			unless header_written [
				unless unique_filename [
					write filename rejoin [m/12 " " m/17 " - "]
				]
				write filename rejoin ["File generated from " dbhost " host, " dbname " database, field_observations_struct_measures table on " now ]
				if criteria [ write/append/binary filename rejoin [" with criteria: " sql_criteria] ]
				write/append/binary filename newline
				if unique_filename [header_written: true]
			]
			;write/append/binary filename line_measure m
			;write/append/binary filename newline
		][
			; same obs_id
			;write/append/binary filename to-string m/2	; test
			;write/append/binary filename line_measure m
			;write/append/binary filename newline
		]
	; write the measurement line in TecTri-readable format:
	set [dir dip dipq pi piqd mov] reduce [m/6 m/7 m/8 m/9 m/10 m/11]
		; first, in order to TecTri to be able to correctly parse data, fill undefined data concerning lines with fake data, with a warning:
		warning: copy ""
		if pi = "" [
			pi: "33"
			append warning "undefined pitch => FAKE; "
		]
		if piqd = "" [
			either (any [dipq = "N" dipq = "S"]) [piqd: "E"] [piqd: "S"]
			append warning "undefined pitch quadrant => FAKE; "
		]
		if mov = "" [
			mov: "N"
			append warning "undefined movement => FAKE; "
		]
		unless warning = "" [
			warning: rejoin ["(WARNING: " (substring warning 1 (length? warning) - 2) ") "]
		]

		line: rejoin [dir sep dip sep dipq sep pi sep piqd sep mov sep]
		; if unique_filename, add the description from field_observations to the comments output column:
		;if unique_filename [		;=> in fact, even if data is not in a unique file, probably better
			comment: rejoin [m/2 " <" m/3 "> " "<" m/4 "> " warning]
			if (m/12 = "") and (m/17 != "") [append comment m/17]
			if (m/12 != "") and (m/17 = "") [append comment m/12]
			if (m/12 != "") and (m/17 != "") [append comment rejoin [m/12 " - " m/17]]
		;]
		append line comment
		; if a sort group is mentioned, append it to line:
		unless (m/14 = "") [ append line rejoin ["[" m/14 "]"] ]
		write/append/binary filename line
		write/append/binary filename newline
	]
	prin "File "
	if ((length? filenames) > 1) [prin "s"]
	print "conversion to ISO-8859-1 for TecTri use:"
	foreach filename filenames [
		call_wait_output_error rejoin ["iconv --from-code=UTF-8 --to-code=ISO-8859-1 " filename " > " filename "_ && mv -f " filename "_ " filename]
		;print filename
	]
	newline: newline_
];}}}
; WARNING: code duplication between generate_tectri_file and generate_tectri_file_from_dh_structures
; => TODO remove duplicate code, rationalize.
generate_tectri_file_from_dh_structures: function [ ;{{{
	"Generates a file for TecTri from structural measurements contained in bdexplo database in dh_struct_measures table"
	/criteria {optional criteria to select records to be exported}
		sql_criteria [string!] {criteria, must be a valid SQL statement; i.e. "WHERE opid = 4 AND obs_id ILIKE 'GF2012%'}
	/unique_filename "specifies a unique output filename for all measurements"
		filename [string! file!] "output filename, default extension is .tec"
	/onefileperobservation "generates one file per observation; if no file prefix is specified, files are named according to observation identifier (obs_id field) followed by .tec extension"
	/fileprefix "option to set a prefix to output filename"
		prefix [string!] "file prefix"
][
	; local variables:
	sql_string measures newline_ newline id_current id_previous i header_written
][
	; 2015_02_03__15_19_08 made another function similar to generate_tectri_file ; should be merged into a single one, once data table structures are similar enough.
	; get data:
		sql_string: copy "SELECT tmp.*, dh_struct_measures.struct_description FROM (SELECT opid, id, depto, measure_type, structure_type, north_ref, direction, dip, dip_quadrant, pitch, pitch_quadrant, movement, datasource, sortgroup, numauto FROM public.dh_struct_measures  "
		if criteria [ append sql_string sql_criteria ]
		append sql_string " ) AS tmp JOIN public.dh_struct_measures ON (tmp.opid = dh_struct_measures.opid AND tmp.id = dh_struct_measures.id AND tmp.depto = dh_struct_measures.depto) ORDER BY tmp.opid, tmp.id, tmp.depto, tmp.numauto;"
		;write clipboard:// sql_string
		run_query sql_string
		measures: copy sql_result
		print rejoin [length? measures " structural measurements selected"]
		;print-list measures

	; definitions so that TecTri can correctly read the generated file, with CRLF ending lines:
		crlf: #{0D0A}
		newline_: newline
		newline: crlf
	; initiate some variables:
		;sep: " " ; separator: space
		sep: "^-" ; separator: tabulation
		id_current:   copy ""
		id_previous: copy ""
		i: 0
		unless prefix [prefix: copy ""]
		header_written: false
		comment: copy ""
		filenames: copy []

	; determine filename, if unique:
	if unique_filename [
		replace filename " " "_"
		filename: lowercase filename
		if ((substring filename ((length? filename) - 3) 4) != ".tec") [append filename ".tec"]
		filename: to-file filename
		print rejoin ["Unique output filename: " filename]
		append filenames filename
	]

	; iteration over list of structural measurements
	foreach m measures [
		;print i
		i: i + 1
		id_current: copy m/2
		; convert the none values to empty strings "", to avoid having "none" written in the file contents:
		for j 1 (length? m) 1 [
			if none? m/:j [ poke m j "" ]
		]
		either (id_current != id_previous) [ ; test if we are in the same observation (obs_id)
			; new obs_id
			id_previous: copy id_current
			unless unique_filename [
				filename: to-file rejoin [prefix lowercase id_current ".tec"]	; define one output filename per individual observation
				print rejoin ["Output filename: " filename]
				append filenames filename
			]
			unless header_written [
				unless unique_filename [
					write filename rejoin [m/16 " - "]
				]
				write filename rejoin ["File generated from " dbhost " host, " dbname " database, dh_struct_measures table on " now ]
				if criteria [ write/append/binary filename rejoin [" with criteria: " sql_criteria] ]
				write/append/binary filename newline
				if unique_filename [header_written: true]
			]
			;write/append/binary filename line_measure m
			;write/append/binary filename newline
		][
			; same obs_id
			;write/append/binary filename to-string m/2	; test
			;write/append/binary filename line_measure m
			;write/append/binary filename newline
		]
	; write the measurement line in TecTri-readable format:
	set [dir dip dipq pi piqd mov] reduce [m/7 m/8 m/9 m/10 m/11 m/12]
		; first, in order to TecTri to be able to correctly parse data, fill undefined data concerning lines with fake data, with a warning:
		warning: copy ""
		if pi = "" [
			pi: "33"
			append warning "undefined pitch => FAKE; "
		]
		if piqd = "" [
			either (any [dipq = "N" dipq = "S"]) [piqd: "E"] [piqd: "S"]
			append warning "undefined pitch quadrant => FAKE; "
		]
		if mov = "" [
			mov: "N"
			append warning "undefined movement => FAKE; "
		]
		unless warning = "" [
			warning: rejoin ["(WARNING: " (substring warning 1 (length? warning) - 2) ") "]
		]

		line: rejoin [dir sep dip sep dipq sep pi sep piqd sep mov sep]
		; if unique_filename, add the description from field_observations to the comments output column:
		;if unique_filename [		;=> in fact, even if data is not in a unique file, probably better
			comment: rejoin [m/2 "/" m/3 " <" m/4 "> " "<" m/5 "> " warning]
			if (m/16 != "") [append comment m/16]
		;]
		append line comment
		; if a sort group is mentioned, append it to line:
		unless (m/14 = "") [ append line rejoin ["[" m/14 "]"] ]
		write/append/binary filename line
		write/append/binary filename newline
	]
	prin "File "
	if ((length? filenames) > 1) [prin "s"]
	print "conversion to ISO-8859-1 for TecTri use:"
	foreach filename filenames [
		call_wait_output_error rejoin ["iconv --from-code=UTF-8 --to-code=ISO-8859-1 " filename " > " filename "_ && mv -f " filename "_ " filename]
		;print filename
	]
	newline: newline_
];}}}

; Fonctions utilisées pour faire des programmes de sondages:
cogo:                        func      [ "COordinates GO, modifies x and y variables" azim distance ][; {{{
    x: x + (distance * (sine    azim))
    y: y + (distance * (cosine  azim))
    ;return reduce [x y]
];}}}
xyz_from_dh_collar:          func      ["une fonction qui retourne les x, y, z d'un sondage" id] [ ;{{{
    sql: rejoin ["SELECT x, y, z FROM dh_collars WHERE id = '" id "'"]
	result: run_query sql
    return reduce [to-decimal result/1/1 to-decimal result/1/2 to-decimal result/1/3]
]
;# /*}}}*/
plante_un_sondage_ici:       func      [ "append current values to list planned holes, optional parameter = comment" /comment comm [string!]] [ ;{{{
	;?? comm
	unless comment [comm: copy ""]
	; correct when an azimuth azim_ng is incorrect, either < 0 or > 360:
		if ( azim_ng <   0 ) [ azim_ng: azim_ng + 360]
		if ( azim_ng > 360 ) [ azim_ng: azim_ng - 360]
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
	_comments: make string! comm
	] )
	number: number + 1
	;probe last sondages_prevus
	];}}}
mark_set:                    does      [ ; set a mark, to go back afterwards; {{{
	mark_x: x
	mark_y: y
	mark_z: z
];}}}
mark_go:                     does      [  ; go back to a previously marked place; {{{
	x: mark_x
	y: mark_y
	z: mark_z
];}}}

; Functions used for maintenance of geolllibre.org server, aka linutopch, hosted in Gers as of 2014:
gll_linutopch_srv_util_delpads: func ["Deletes pads from etherpad-lite" pads [block!]] [ ; {{{
	foreach p pads [
		p: to-string p
		url: rejoin ["https://geolllibre.org/pad/p/" p]
		browse url
		if (confirm "Deleter ce pad?") [
			urldel: rejoin ["http://geolllibre.org/pad/api/1/deletePad?apikey=8df54105a3fb53511dd37a9df4c9325971dc2a6f25e349bbe715ea1aa4d11cc4&padID=" p]
			browse urldel
		] ] ]
;}}}

; === fin des définitions de fonctions ==========
; === end of functions' definitions =============

; on se met dans le répertoire courant
; change to current directory
change-dir system/options/path

; on renseigne un peu l'utilisateur sur la console
; print out some information to the user on the console
print "Gll preferences loaded: "
;?? dbhost
;?? dbname
;?? user
;?? tmp_schema
print rejoin ["Current working directory: " what-dir ]

; on lance la connexion à la base
; connect to the database
connection_db

; et on laisse finalement le champ libre au programme appelant, ou à l'invite interactive.
; and we eventually give way to the calling program, or to the shell.
