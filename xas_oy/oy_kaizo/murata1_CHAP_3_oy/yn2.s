*	キー入力に応じてYかNを表示する　２

_EXIT		equ	$ff00
_PUTCHAR	equ	$ff02
_GETC		equ	$ff08

	.text
	.even
*
start:
loop:	.dc.w	_GETC		*1文字入力
	cmp.b	#'Y',d0		*'Y'か？
	beq	print		*そうなら表示処理へ
	cmp.b	#'N',d0		*'N'か？
	bne	loop		*そうでなければやり直し
*
print:	move.w	d0,-(sp)	*'Y'か'N'を表示
	.dc.w	_PUTCHAR
	add.l	#2,sp
	.dc.w	_EXIT		*終了
*
	.end
