*	32階調モノクロ化

DERGB_BREAK_HIGHWORD	=	1
	.include	gconst.h
	.include	gmacro.h
*
	.xdef	gmonotone
	.xref	gramadr
	.xref	gcliprect
	.xref	grayscale
*
	.offset	0	*gmonotoneの引数構造
*
X0:	.ds.w	1	*矩形座標
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
*
	.text
	.even
*
gmonotone:
ARGPTR	=	8
	link	a6,#0
	movem.l	d0-d6/a0-a3,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = 引数列
	movem.w	(a1),d0-d3	*d0～d3に座標を取り出す

	jsr	gcliprect	*クリッピングする
	bne	done		*Z=0なら描画の必要なし

	jsr	gramadr		*G-RAM上のアドレスを得る

	sub.w	d0,d2		*d2 = 横ピクセル数-1
	sub.w	d1,d3		*d3 = 縦ピクセル数-1

	lea.l	GNBYTE-2.w,a3	*a3 = ライン間のアドレスの差
	suba.w	d2,a3		*（右端から下のラインの左端まで）
	suba.w	d2,a3		*

	lea.l	grayscale,a1
	RGBtoYx_INIT	a2
loop1:	move.w	d2,d1		*d1 = 横ピクセル数-1
loop2:	move.w	(a0),d6		*色コードを取り出し
	_DERGB	d4,d5,d6	*RGBに分解する
	MAX	d5,d4		*R,G,Bの最大値を
	MAX	d6,d4		*　d4に求め
	add.w	d4,d4		*hsv(H,S,d4)の色で
	move.w	(a1,d4.w),(a0)+	*　点を打つ
	dbra	d1,loop2	*横幅分繰り返す

	adda.l	a3,a0		*すぐ下のラインへ
	dbra	d3,loop1	*高さ分繰り返す

done:	movem.l	(sp)+,d0-d6/a0-a3
	unlk	a6
	rts

	.end
