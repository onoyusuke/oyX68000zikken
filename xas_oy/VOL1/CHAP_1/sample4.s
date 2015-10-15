_GETC		equ	$ff08
_PUTCHAR	equ	$ff02
_EXIT		equ	$ff00
*
	.dc.w	_GETC
	move.w	d0,-(sp)
	.dc.w	_PUTCHAR
	addq.l	#2,sp
	.dc.w	_EXIT
