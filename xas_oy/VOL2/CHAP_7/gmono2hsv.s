*	単色化（任意色相, YIQのYを輝度に使う版）

DERGB_BREAK_HIGHWORD	=	1
	.include	gconst.h
	.include	gmacro.h
*
	.xdef	gmonotone2_hsv
	.xref	hsvtorgb
	.xref	gramadr
	.xref	gcliprect
*
	.offset	0	*gmonotone2_hsvの引数構造
*
X0:	.ds.w	1	*矩形座標
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
H:	.ds.w	1	*色相
S:	.ds.w	1	*飽和度
*
	.text
	.even
*
gmonotone2_hsv:
ARGPTR	=	8
TBLSIZ	=	RGBGRAD*2
	link	a6,#-TBLSIZ
	movem.l	d0-d6/a0-a3,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = 引数列
	movem.w	(a1)+,d0-d3	*d0～d3に座標を取り出す

	jsr	gcliprect	*クリッピングする
	bne	done		*Z=0なら描画の必要なし

	jsr	gramadr		*G-RAM上のアドレスを得る

	sub.w	d0,d2		*d2 = 横ピクセル数-1
	sub.w	d1,d3		*d3 = 縦ピクセル数-1

	move.l	(a1),d1		*hsv(H,S,0)～hsv(H,S,31)の
	lea.l	-TBLSIZ(a6),a1	*　色テーブルを作っておく
	lsl.w	#8,d1		*
	moveq.l	#RGBGRAD-1,d4	*
loop0:	move.l	d1,d0		*
	jsr	hsvtorgb	*
	move.w	d0,(a1)+	*
	addq.b	#1,d1		*
	dbra	d4,loop0	*

	lea.l	GNBYTE-2.w,a3	*a3 = ライン間のアドレスの差
	suba.w	d2,a3		*（右端から下のラインの左端まで）
	suba.w	d2,a3		*

	lea.l	-TBLSIZ(a6),a1
	RGBtoYx_INIT	a2
loop1:	move.w	d2,d1		*d1 = 横ピクセル数-1
loop2:	move.w	(a0),d6		*色コードを取り出し
	_DERGB	d4,d5,d6	*RGBに分解する
	RGBtoYx	d4,d5,d6,d0	*Yをd0に求め
				*
	add.w	d0,d0		*hsv(H,S,d0)の色で
	move.w	(a1,d0.w),(a0)+	*　点を打つ
	dbra	d1,loop2	*横幅分繰り返す

	adda.l	a3,a0		*すぐ下のラインへ
	dbra	d3,loop1	*高さ分繰り返す

done:	movem.l	(sp)+,d0-d6/a0-a3
	unlk	a6
	rts

	.end
