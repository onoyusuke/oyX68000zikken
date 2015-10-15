	.include	doscall.mac
*
	.xdef	allmem		*外部定義
*
	.text
	.even
*
*allmem()
*機能：	確保できる最大のメモリブロックを確保する
*	d0.lに確保した先頭アドレスを持って戻る
*	d0.lが負の場合はエラー
*レジスタ破壊：d0.l,ccr
*
*	ex)
*		bsr	allmem
*		tst.l	d0
*		bmi	error
*
allmem:
	move.l	#$ffffff,-(sp)
	DOS	_MALLOC
	andi.l	#$ffffff,d0
	move.l	d0,(sp)
	DOS	_MALLOC
	addq.l	#4,sp
	rts

	.end
