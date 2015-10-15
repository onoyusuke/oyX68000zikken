*	文字列の比較

	.include	doscall.mac
*
	.text
	.even
*
ent:
	lea.l	mysp,sp		*spの初期化

	lea.l	str1,a0		*被比較文字列へのポインタ
	lea.l	str2,a1		*比較文字列へのポインタ
	bsr	strcmp		*文字列比較

	beq	match		*一致したか？

not:	pea.l	notmes		*一致しなかった
	bra	match0

match:	pea.l	matmes		*一致した
match0:	DOS	_PRINT		*それなりのメッセージを
	addq.l	#4,sp		*	表示

	DOS	_EXIT		*終了
*
*文字列比較サブルーチン
strcmp:
	tst.b	(a1)		*比較文字列は終わりか？
	beq	strcmp0		*そうであればループを抜ける
	cmpm.b	(a1)+,(a0)+	*1文字比較
	beq	strcmp		*一致している間繰り返す
	rts			*一致しなかった
strcmp0:
	cmpm.b	(a1)+,(a0)+	*ラストチャンス
	rts
*
str1:	.dc.b	'1234ABCD',0	*非比較文字列
str2:	.dc.b	'1234ABCD',0	*比較文字列
*
matmes:	.dc.b	'一致しました',$0d,$0a,0
notmes:	.dc.b	'一致しません',$0d,$0a,0
*
	.stack
	.even
*
mystack:
	.ds.l	256		*スタック領域
mysp:
	.end
