_PRINT		equ	$ff09
_EXIT		equ	$ff00
*
	pea	mes
	.dc.w	_PRINT
	addq.l	#4,sp
mes:	.dc.b	'PRINT TEST',$0d,$0a,0
	.dc.w	_EXIT
