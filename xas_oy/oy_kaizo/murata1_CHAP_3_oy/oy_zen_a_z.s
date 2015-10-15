*	全角の'A'～'Z'を表示する

_EXIT		equ	$ff00
_PUTCHAR	equ	$ff02

	.text
	.even
*
start:
	move.w	#$0060,d1	*シフトJISコード'Ａ'の下位バイト

loop:	move.w	#$0082,-(sp)	*上位バイトを
	.dc.w	_PUTCHAR	*　出力
	move.w	d1,(sp)		*下位バイトを
	.dc.w	_PUTCHAR	*　出力
	add.l	#2,sp		*スタックポインタ補正

	add.b	#1,d1		*次の文字
	cmp.b	#$63,d1		*最後まで表示したか？
	bne	loop		*そうでなければ繰り返す

	bsr	crlf		*改行

	.dc.w	_EXIT		*終了
*
crlf:
	move.w	#$0d,-(sp)	*CRコードを
	.dc.w	_PUTCHAR	*　出力
	move.w	#$0a,(sp)	*LFコードを
	.dc.w	_PUTCHAR	*　出力
	add.l	#2,sp		*スタック補正
	rts			*リターン
*
	.end
