*	'A'～'Z'を表示するプログラム

_EXIT		equ	$ff00	*DOSコールexitのシンボル定義
_PUTCHAR	equ	$ff02	*DOSコールputcharのシンボル定義

	.text
	.even
*
start:
	move.w	#'A',d1		*表示を始める文字コードをd1へ

loop:	move.w	d1,-(sp)	*スタックに文字コードを積み
	.dc.w	_PUTCHAR	*DOSコールputcharを呼び出す
	add.l	#2,sp		*スタックポインタを補正する

	add.w	#1,d1		*d1=次に表示する文字コード
	cmp.w	#'Z'+1,d1	*d1は'Z'+1と等しいか？
				*（'Z'をすぎたか？）
	bne	loop		*そうでなければ処理を繰り返す

	bsr	crlf		*改行サブルーチンを呼び出す

	.dc.w	_EXIT		*実行終了

*	改行処理サブルーチン
*
crlf:
	move.w	#$0d,-(sp)	*CRコードを
	.dc.w	_PUTCHAR	*　出力
	add.l	#2,sp		*スタック補正

	move.w	#$0a,-(sp)	*LFコードを
	.dc.w	_PUTCHAR	*　出力
	add.l	#2,sp		*スタック補正

	rts			*メインルーチンへ戻る
*
	.end
