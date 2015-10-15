	INCLUDE fefunc.h
	.GLOBL	_a
	.GLOBL	_main
	.XREF	__main
	.TEXT
_foo:
	LINK	A6,#-4
	MOVE.L	D7,-(SP)
	MOVE.L	8(A6),-4(A6)	*e = x;
	MOVE.L	12(A6),L5	*h = y;
	MOVE.L	L4,D7		*f = g;
	MOVE.L	(SP)+,D7
	UNLK	A6
	RTS
_main:
	LINK	A6,#0
	MOVE.L	#50000,-(SP)	*
	MOVE.L	_c,-(SP)	*
	JSR	_foo		*foo( c, 50000 );
	ADDQ.L	#8,SP		*
	MOVEQ.L #0,D0		*return 0;
	UNLK	A6		*
	RTS			*
	.DATA
_a:
	.DC.L	$00000001
_c:
	.DC.L	$00000001
L4:
	.DC.L	$00000001
	.EVEN
	.BSS
_d:
	.DS.B	4
	.COMM	_b,4
L5:
	.DS.B	4
	.END
