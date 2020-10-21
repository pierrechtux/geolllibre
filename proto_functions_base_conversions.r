#!/usr/bin/rebol -wqs
rebol []

debug: true
test: true

comment [ ;****************{{{
;3.2. Converting to other bases from base-10

print   base-convert/to-base 99 2   ;; 99 in binary
;   == "1100011"
print 1 + 2 + 32 + 64
print   base-convert/to-base 999 8 ;; 999 in octal
;   == "1747"
print   base-convert/to-base 14600926 16  ;; large number in hex
;   == "DECADE"
print   base-convert/to-base 1024 29  ;; 1024 in base 29
;   == "169"
print   base-convert/to-base 177 "#@"  ;; 177 in base-2 using "#" and "@" rather than 0 and 1
;   == "@#@@###@"

;=>;======== code evaluation output: ========= {{{
;1100011
;
;
;
;print 4 + 32 + 64
;
;
;1747
;DECADE
;169
;@#@@###@
;========================================== }}}

;3.3. Converting from other bases to base-10

print   base-convert/from-base "4444" 5  ;;"4444" in base 5
;   == 624
print   base-convert/from-base "1000000000000000000000001" 2
;   == 16777217
print   base-convert/from-base "AA" 31  ;; "AA" in base 31 (310 + 10)
;   == 320

print base-convert/from-base "1100100" 2
] ;****************}}}
 
; Build easily accessible functions to convert back and forth between commonly used bases:
; Manual definition, nah: {{{
;bin2octal:   
;octal2bin:   
;bin2decimal:   
;decimal2bin:   
;bin2hex:     
;hex2bin:       
;octal2decimal: 
;decimal2octal: 
;octal2hex:    
;hex2octal
;}}}
; Better generate all possible conversion functions from a range of possible bases:
bases: [bin 2 octal 8 decimal 10 hex 16 gers 32 eusk 64]       ; bases: binary 2, octal 8, decimal 10, hexadecimal 16, gers 32, eusk 64
; Well, no: valid bases for Sunanda's library are only up to 36, see this error message:
	;** User Error: Maximum base should be 36
; So let's skip eusk for the time being:
bases: [bin 2 octal 8 decimal 10 hex 16 gers 32]               ; bases: binary 2, octal 8, decimal 10, hexadecimal 16, gers 32, eusk 64

; Iteration of all possible combinations of bases: 
foreach [dep basedep] bases [                                  ; dep: departure base  ; basedep: departure base number
	foreach [arr basearr] bases [                              ; arr: arrival base    ; basearr: arrival base number
		debug_print ""
		funcname: rejoin [to-string dep "2" to-string arr]     ; construction of function name
		print funcname
			; construction of function definition:
		def_func: rejoin [funcname {: function ["Converts value from base } basedep { to base } basearr {" arg]  [t]} newline]
		either dep = arr [
				append def_func {[return arg]}                  ; trivial conversion between the same bases
			]
			[
				append def_func rejoin [{[t: base-convert/from-base to-string arg } basedep newline]
				; TODO add error handling when arg is not expressed in basedep
				append def_func rejoin [{??? arg} newline]
				append def_func rejoin [{??? t} newline]
				append def_func rejoin [{t: base-convert/to-base t } basearr newline]
				append def_func rejoin [{??? t} newline]
				append def_func {return t]} 
			]
		debug_print "Définition de la fonction à générer:"
		debug_print mold def_func
		do def_func
;		??? test
;		if test [
;			print reduce [funcname 10]
;		]

		]
]

if test [
tt: func [arg [block!]] [print to-string arg do [print arg print ""]]
print newline

flag: true
while [flag = true] [
prin "Entre un décimal à convertir en binaire, octal, hexadecimal et gersois (0 pour finir): "
x: input 
if x = 0 [flag: false continue]
tt [
decimal2bin x
]
tt [
decimal2octal x
]
tt [
decimal2decimal x
]
tt [
decimal2hex x
]
tt [
decimal2gers x
]
]

print newline
loop 30 [
prin "Entre un binaire à convertir en binaire, octal, hexadecimal et gersois (0 pour finir): "
x: input 
unless x = 0 [
tt [
bin2bin x
]
tt [
bin2octal x
]
tt [
bin2decimal x
]
tt [
bin2hex x
]
tt [
bin2gers x
]
]
]
]



var: 10
??? var
print base-convert/to-base var 32

