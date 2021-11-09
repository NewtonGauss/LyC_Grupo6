FLD c
FILD entero
FILD entero
FILD _12
FSTP entero
FLD _12.
FSTP flotante
FLD _.5
FSTP c
FLD _12.5
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
displayFloat _1
newline 1
FILD entero
FILD _1
FXCH
FCOM
FSTSW AX
SAHF
JNE @et34
displayFloat entero
newline 1
JMP @et35
displayString _distinto_de_1
newline 1
@et35:
FILD entero
FILD _1
FXCH
FCOM
FSTSW AX
SAHF
JE @et41
displayFloat flotante
newline 1
JMP @et42
displayString _igual_a_1
newline 1
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
newline 1
JMP @et53
displayString _Mayor_a_1_o_Menor_a_0
newline 1
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
newline 1
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
newline 1
JMP @et62
@et74:
FILD _1
@et75:
FSTP entero
displayString _hasta_obtener_0
newline 1
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
displayFloat entero
newline 1
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
newline 1
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
newline 1
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
newline 1
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
newline 1
