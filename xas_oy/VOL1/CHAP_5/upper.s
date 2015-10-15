*	英小文字→英大文字変換フィルタの出来そこない

	.include	doscall.mac
*
	.text
	.even
*
ent:
	lea.l	mysp,sp		*spの初期化

loop:	pea	buff		*1行入力
	DOS	_GETS		*
	addq.l	#4,sp		*

	lea.l	str,a0		*a0=入力文字列先頭
	cmpi.b	#$1a,(a0)	*先頭は^Zか？
	beq	skip		*そうであれば終了

	bsr	strupr		*小文字→大文字変換

	pea.l	str		*変換結果を表示
	DOS	_PRINT		*
	addq.l	#4,sp		*

	pea.l	crlf		*改行
	DOS	_PRINT		*
	addq.l	#4,sp		*

	bra	loop		*えんえんと繰り返す
skip:
	DOS	_EXIT		*終了
*
*英小文字→英大文字変換サブルーチン
strupr:
	tst.b	(a0)		*文字列の終わりか？
	beq	strup1		*そうであれば変換終了

	cmpi.b	#'a',(a0)	*英小文字か？
	bcs	strup0		*
	cmpi.b	#'z'+1,(a0)	*
	bcc	strup0		*

	subi.b	#$20,(a0)	*小文字なら大文字に変換

strup0:	addq.l	#1,a0		*ポインタを進める
	bra	strupr		*繰り返す
strup1:	rts			*サブルーチンからリターン
*
buff:	.dc.b	255		*入力可能最大文字数
cnt:	.dc.b	0		*入力された文字数
str:	.ds.b	256		*文字列入力バッファ
*
crlf:	.dc.b	$0d,$0a,0	*改行コードだけの文字列
*
	.stack
	.even
*
mystack:
	.ds.l	256		*スタック領域
mysp:
	.end
