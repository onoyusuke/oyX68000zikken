_PRINT		equ	$ff09
_EXIT		equ	$ff00
*
	pea	mes
	.dc.w	_PRINT
	addq.l	#4,sp
	.dc.w	_EXIT
mes:	.dc.b	'Hello, World...',$0d,$0a,'16 Aug 2015',$0d,$0a,0
