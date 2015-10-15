*	G-RAMアドレス関連モジュール

	.include	iocscall.mac
	.include	gconst.h
*
	.xdef	gramadr
	.xdef	apage
	.xdef	gbase
*
	.text
*
*	座標からG-RAMアドレスを求める
*	(d0.w,d1.w) → a0 = adr
*
gramadr:
	movem.l	d0-d1,-(sp)

	movea.w	d0,a0		*
	adda.w	d0,a0		*a0 = x*2

	moveq.l	#GSFTCTR,d0	*
	ext.l	d1		*
	asl.l	d0,d1		*d1 = y*1024 (or y*2048)
	adda.l	d1,a0		*a0 = (x,y)と(0,0)のG-RAMアドレスの差

	adda.l	gbase(pc),a0	*a0 = (x,y)のG-RAMアドレス

	movem.l	(sp)+,d0-d1
	rts

*
*	描画ページを設定する
*	d1.w = ページ番号(0～3)
*
apage:
	IOCS	_APAGE		*IOCSにもページ番号を伝える
	tst.l	d0		*エラー？
	bmi	apage0		*　そうなら終了

	move.w	d1,d0		*d0.w=ページ番号
	lsl.w	#19-16,d0	*ページ番号を
	swap.w	d0		*　$80000倍する
	clr.w	d0		*
	addi.l	#GPAGE0,d0	*G-RAMの先頭アドレスを足す
	move.l	d0,gbase	*ワークにしまう

	moveq.l	#0,d0	*APAGEの戻り値を復帰する
apage0:	rts
*
gbase:	.dc.l	GPAGE0		*(0,0)のG-RAMアドレス

	.end
