*	矩形領域の上下反転

	.include	gconst.h
*
	.xdef	gvreverse
	.xref	gramadr
	.xref	gcliprect
*
	.offset	0	*gvreverseの引数構造
*
X0:	.ds.w	1	*矩形領域
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
*
	.text
	.even
*
gvreverse:
ARGPTR	=	8
	link	a6,#0
	movem.l	d0-d4/a0-a3,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = 引数列
	movem.w	(a1),d0-d3	*d0-d3に座標を取り出す

	jsr	gcliprect	*クリッピングする
	bmi	done		*N=1なら描画の必要なし

	jsr	gramadr		*左上のG-RAM上のアドレスを得る

	sub.w	d0,d2		*d2 = 横ピクセル数-1
	sub.w	d1,d3		*d3 = 縦ピクセル数-1

	move.w	d3,d0		*縦ピクセル数-1をGNBYTE倍する
	ext.l	d0		*
	moveq.l	#GSFTCTR,d1	*
	asl.l	d1,d0		*
	lea.l	0(a0,d0.l),a2	*a2 = 領域の左下隅アドレス
	lsr.w	#1,d3		*

	move.w	#GNBYTE,d1	*d1 = ライン間のアドレスの差

loop1:	movea.l	a0,a1		*a1 = 左上
	movea.l	a2,a3		*a3 = 左下

	move.w	d2,d4		*d4 = 横ピクセル数-1
loop2:	move.w	(a1),d0		*交換
	move.w	(a3),(a1)+	*
	move.w	d0,(a3)+	*
	dbra	d4,loop2	*横幅分繰り返す

	adda.w	d1,a0		*すぐ下のラインへ
	suba.w	d1,a2		*すぐ上のラインへ
	dbra	d3,loop1	*高さ/2回繰り返す

done:	movem.l	(sp)+,d0-d4/a0-a3
	unlk	a6
	rts

	.end
