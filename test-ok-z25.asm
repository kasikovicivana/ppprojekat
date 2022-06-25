
mapa1_1:
		WORD	1
mapa2_1:
		WORD	1
mapa2_3:
		WORD	1
mapa2_4:
		WORD	1
mapa3_4:
		WORD	1
mapa3_2:
		WORD	1
main:
		PUSH	%14
		MOV 	%15,%14
		SUBS	%15,$4,%15
@main_body:
		MOV 	$1,mapa1_1
		MOV 	$2,mapa2_1
		MOV 	$5,mapa2_3
		MOV 	$2,mapa2_4
		MOV 	$2,mapa3_4
		MOV 	$5,mapa3_2
		MOV 	$3,mapa1_1
		ADDS	mapa1_1,mapa1_1,%0
		MOV 	%0,-4(%14)
		MOV 	-4(%14),%13
		JMP 	@main_exit
@main_exit:
		MOV 	%14,%15
		POP 	%14
		RET