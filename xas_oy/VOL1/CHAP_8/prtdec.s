*	D0.Wを10進左詰めで表示するサブルーチン

	.include	doscall.mac
*
	.text
	.even
*
prtdec:
	movem.l	d0/a0,-(sp)	*｛d0,a0をスタックに待避

	andi.l	#$0000ffff,d0	*上位ワードをクリア
	lea.l	bufend,a0	*ポインタ初期化
prtdec0:
	divu.w	#10,d0		*d0.lを10で割る
	swap.w	d0		*上位ワードと下位ワードを交換
	addi.w	#'0',d0		*0～9 → '0'～'9'
	move.b	d0,-(a0)	*1桁格納
	clr.w	d0		*次の除算に備える
	swap.w	d0		*上位ワードと下位ワードを交換
	bne	prtdec0

	move.l	a0,-(sp)	*変換した文字列を表示する
	DOS	_PRINT		*
	addq.l	#4,sp		*

	movem.l	(sp)+,d0/a0	*｝d0,a0を復帰
	rts
*
	.data
	.even
*
buff:	.ds.b	5		*10進文字列格納領域
bufend:	.dc.b	0		*文字列の終了コード

	.end
