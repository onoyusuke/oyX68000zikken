*	文字列の連結

	.include	doscall.mac
*
	.text
	.even
*
ent:
	lea.l	mysp,sp		*spの初期化

	lea.l	str1,a0		*連結先へのポインタ
	lea.l	str2,a1		*連結元へのポインタ
	bsr	strcat		*文字列連結

	pea.l	str1		*連結した文字列を
	DOS	_PRINT		*表示してみる
	addq.l	#4,sp		*

	DOS	_EXIT		*終了
*
*文字列連結サブルーチン
strcat:
	tst.b	(a0)+		*(a0)は0か？
	bne	strcat		*そうでなければ繰り返す
	subq.l	#1,a0		*行きすぎたから１つ戻る
strcpy:
	move.b	(a1)+,(a0)+	*1文字転送
	bne	strcpy		*終了コードまで繰り返す
	rts
*
str2:	.dc.b	'1234ABCD',0	*連結元
str1:	.dc.b	'5678EFGH',0	*連結先
	.ds.b	256		*ゆとり
*
	.stack
	.even
*
mystack:
	.ds.l	256		*スタック領域
mysp:
	.end
