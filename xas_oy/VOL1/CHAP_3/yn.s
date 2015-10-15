*	キー入力に応じてYかNを表示する

_EXIT		equ	$ff00
_PUTCHAR	equ	$ff02
_GETC		equ	$ff08

	.text
	.even
*
start:
loop:	.dc.w	_GETC		*1文字入力
	cmp.b	#'Y',d0		*'Y'か？
	beq	yes		*そうなら'Y'の表示処理へ
	cmp.b	#'N',d0		*'N'か？
	beq	no		*そうなら'N'の表示処理へ
	bra	loop		*どちらでもなければやり直し
*
yes:	move.w	#'Y',-(sp)	*'Y'を表示
	.dc.w	_PUTCHAR
	add.l	#2,sp
	.dc.w	_EXIT		*終了
*
no:	move.w	#'N',-(sp)	*'N'を表示
	.dc.w	_PUTCHAR
	add.l	#2,sp
	.dc.w	_EXIT		*終了
*
	.end
