*	全角の'A'～'Z'を色（文字の属性）を変えながら表示する

_EXIT		equ	$ff00
_PUTCHAR	equ	$ff02
_CONCTRL	equ	$ff23

	.text
	.even
*
start:
	move.w	#$0060,d1	*シフトJISコード'Ａ'の下位バイト
	move.w	#1,d2		*文字属性=1（青ノーマル）

loop:	move.w	d2,-(sp)	*d2=文字属性
	move.w	#2,-(sp)	*conctrlモード2
	.dc.w	_CONCTRL	*つぎに表示する文字の属性を設定
	add.l	#4,sp		*スタックポインタ補正

	move.w	#$0082,-(sp)	*上位バイトを
	.dc.w	_PUTCHAR	*　出力
	move.w	d1,(sp)		*下位バイトを
	.dc.w	_PUTCHAR	*　出力
	add.l	#2,sp		*スタックポインタ補正

	add.b	#1,d2		*次の文字属性（変な表現？）
	and.b	#$0f,d2		*d2=d2%16

	add.b	#1,d1		*次の文字
	cmp.b	#$7a,d1		*最後まで表示したか？
	bne	loop		*そうでなければ繰り返す

	.dc.w	_EXIT		*終了
*
	.end
