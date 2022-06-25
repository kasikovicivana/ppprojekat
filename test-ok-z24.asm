
mapa1_1:
		WORD	1
mapa2_1:
		WORD	1
mapa2_3:
		WORD	1
main:
		PUSH	%14
		MOV 	%15,%14
		SUBS	%15,$4,%15
@main_body:
		MOV 	$1,mapa1_1
		MOV 	$2,mapa2_1
		MOV 	$5,mapa2_3
		MOV 	$2,mapa1_1
		MOV 	mapa1_1,-4(%14)
		MOV 	-4(%14),%13
		JMP 	@main_exit
@main_exit:
		MOV 	%14,%15
		POP 	%14
		RET