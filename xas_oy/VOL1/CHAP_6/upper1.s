*	英小文字→英大文字変換フィルタ　第１版

	.include	doscall.mac
*
	.text
	.even
*
ent:
	lea.l	mysp,sp		*spの初期化

loop:	DOS	_GETC		*１文字入力
	bsr	toupper		*小文字→大文字変換
	move.w	d0,-(sp)	*１文字出力
	DOS	_PUTCHAR	*
	addq.l	#2,sp		*
	bra	loop		*えんえんと繰り返す
*
*英小文字→英大文字変換サブルーチン
toupper:
	cmpi.b	#'a',d0		*英小文字か？
	bcs	toupr0		*
	cmpi.b	#'z'+1,d0	*
	bcc	toupr0		*
	subi.b	#$20,d0		*小文字なら大文字に変換
toupr0:	rts			*サブルーチンからリターン
*
	.stack
	.even
*
mystack:
	.ds.l	256		*スタック領域
mysp:
	.end
