include macros2.asm
include number.asm
.MODEL LARGE
.386
.STACK 200h
.DATA

@min dd ?
@minmax dd ?
_0 dd 0
_1 dd 1
_10 dd 10
_12 dd 12
_12_ dd 12.
_12_5 dd 12.5
_2 dd 2
_5 dd 5
_Mayor_a_1_o_Menor_a_0 db "Mayor a 1 o Menor a 0", '$', 21 dup (?)
__5 dd .5
_condicion_doble db "condicion doble", '$', 15 dup (?)
_condicion_doble_con_OR db "condicion doble con OR", '$', 22 dup (?)
_distinto_de_1 db "distinto de 1", '$', 13 dup (?)
_hasta_obtener_0 db "hasta obtener 0", '$', 15 dup (?)
_hola db "hola", '$', 4 dup (?)
_igual_a_1 db "igual a 1", '$', 9 dup (?)
_no_deberia_entrar db "no deberia entrar", '$', 17 dup (?)
_no_elegiste_1 db "no elegiste 1", '$', 13 dup (?)
_que db "que", '$', 3 dup (?)
_tal db "tal", '$', 3 dup (?)
_true db "true", '$', 4 dup (?)
c dd ?
entero dd ?
flotante dd ?
@aux dd ?

.CODE
start:
MOV EAX,@DATA
MOV DS,EAX
MOV ES,EAX

FLD c
FILD entero
FILD entero
FILD _12
FSTP entero
FLD _12_
FSTP flotante
FLD __5
FSTP c
FLD _12_5
FSTP c
FILD entero
FILD _1
FADD
FSTP @aux
FSTP entero
FILD entero
FILD _1
FSUB
FSTP @aux
FSTP entero
FILD entero
FILD _2
FMUL
FSTP @aux
FSTP entero
FILD entero
FILD _2
FDIV
FSTP @aux
FSTP entero
DisplayFloat _1, 2
newLine 1
FILD entero
FILD _1
FXCH
FCOM
FSTSW AX
SAHF
JNE @et34
DisplayFloat entero, 2
newLine 1
JMP @et35
@et34:
displayString _distinto_de_1
newLine 1
@et35:
FILD entero
FILD _1
FXCH
FCOM
FSTSW AX
SAHF
JE @et41
DisplayFloat flotante, 2
newLine 1
JMP @et42
@et41:
displayString _igual_a_1
newLine 1
@et42:
FILD entero
FILD _1
FXCH
FCOM
FSTSW AX
SAHF
JA @et52
FILD entero
FILD _0
FXCH
FCOM
FSTSW AX
SAHF
JB @et52
displayString _condicion_doble
newLine 1
JMP @et53
@et52:
displayString _Mayor_a_1_o_Menor_a_0
newLine 1
@et53:
FILD entero
FILD _1
FXCH
FCOM
FSTSW AX
SAHF
JB @et62
FILD entero
FILD _0
FXCH
FCOM
FSTSW AX
SAHF
JNA @et63
displayString _condicion_doble_con_OR
newLine 1
@et62:
@et62:
@et63:
FILD entero
FILD _0
FXCH
FCOM
FSTSW AX
SAHF
JE @et75
getFloat entero
FILD entero
FILD _1
FXCH
FCOM
FSTSW AX
SAHF
JNE @et74
displayString _no_elegiste_1
newLine 1
JMP @et62
@et74:
FILD _1
@et75:
FSTP entero
displayString _hasta_obtener_0
newLine 1
@et77:
FILD entero
FILD _0
FXCH
FCOM
FSTSW AX
SAHF
JE @et91
@et82:
FILD entero
FILD _0
FXCH
FCOM
FSTSW AX
SAHF
JE @et90
getFloat entero
JMP @et82
JMP @et77
@et90:
@et91:
FSTP entero
DisplayFloat entero, 2
newLine 1
FILD _10
FILD _10
FILD _5
FILD _2
FXCH
FCOM
FSTSW AX
SAHF
JNA @et104
FSTP @min
@et104:
FXCH
FCOM
FSTSW AX
SAHF
JNA @et107
FSTP @min
@et107:
FXCH
FCOM
FSTSW AX
SAHF
JNE @et111
displayString _true
newLine 1
FILD _5
@et111:
FILD _10
FILD _5
FILD _2
FXCH
FCOM
FSTSW AX
SAHF
JNA @et118
FSTP @min
@et118:
FXCH
FCOM
FSTSW AX
SAHF
JNA @et121
FSTP @min
@et121:
FXCH
FCOM
FSTSW AX
SAHF
JNE @et125
displayString _no_deberia_entrar
newLine 1
FILD _2
@et125:
FILD _10
FILD _5
FILD _2
FXCH
FCOM
FSTSW AX
SAHF
JAE @et132
FSTP @min
@et132:
FXCH
FCOM
FSTSW AX
SAHF
JAE @et135
FSTP @min
@et135:
FXCH
FCOM
FSTSW AX
SAHF
JNE @et139
displayString _true
newLine 1
FILD _5
@et139:
FILD _10
FILD _5
FILD _2
FXCH
FCOM
FSTSW AX
SAHF
JAE @et146
FSTP @min
@et146:
FXCH
FCOM
FSTSW AX
SAHF
JAE @et149
FSTP @min
@et149:
FXCH
FCOM
FSTSW AX
SAHF
JNE @et153
displayString _no_deberia_entrar
newLine 1
@et153:
MOV EAX, 4c00h
INT 21h
END start;

