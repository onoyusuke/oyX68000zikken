*	文字列の複写

	.include	doscall.mac
*
	.text
	.even
*
ent:
	lea.l	mysp,sp		*spの初期化

	lea.l	str1,a0		*複写先へのポインタ
	lea.l	str2,a1		*複写元へのポインタ
	bsr	strcpy		*文字列複写

	pea.l	str1		*コピーした文字列を
	DOS	_PRINT		*表示してみる
	addq.l	#4,sp		*

	DOS	_EXIT		*終了
*
*文字列複写サブルーチン
strcpy:
	move.b	(a1)+,d0	*1文字取り出し
	move.b	d0,(a0)+	*転送
	bne	strcpy		*終了コードまで繰り返す
	rts
*
str2:	.dc.b	'1234ABCD',0	*複写元
str1:	.ds.b	256		*複写先
*
	.stack
	.even
*
mystack:
	.ds.l	256		*スタック領域
mysp:
	.end
