_PUTCHAR equ $ff02
_EXIT	equ $ff00
*
 	move.w #'a',-(sp)
	.dc.w	_PUTCHAR
	addq.l #2,sp
	.dc.w _EXIT
