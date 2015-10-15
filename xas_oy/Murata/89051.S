* AからZを表示する
_PUTCHAR	equ $ff02
_EXIT		equ $ff00
*
		.text
		.even
start:
		move.w	#'A',d1
loop:	move.w	d1,-(sp)
		.dc.w	_PUTCHAR
		add.l	#2,sp
		add.w 	#1,d1
		cmp.w 	#'Z'+1,d1

		bne		loop

		bsr		crlf

		.dc.w	_EXIT
crlf:

*
	.end
