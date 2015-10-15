*	矩形の塗り潰し（第１版）

	.include	gconst.h
*
	.xdef	gfill
	.xref	gramadr
	.xref	gcliprect
*
	.offset	0	*gfillの引数構造
*
X0:	.ds.w	1	*描画先座標
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
COL:	.ds.w	1	*描画色
*
	.text
	.even
*
gfill:
ARGPTR	=	8
	link	a6,#0
	movem.l	d0-d4/a0-a1,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = 引数列
	movem.w	(a1),d0-d3	*d0〜d3に座標を取り出す

	jsr	gcliprect	*クリッピングする
	bmi	done		*N=1なら描画の必要なし

	jsr	gramadr		*G-RAM上のアドレスを得る

	sub.w	d0,d2		*d2 = 横ピクセル数-1
	sub.w	d1,d3		*d3 = 縦ピクセル数-1

	move.w	COL(a1),d0	*d0 = 描画色

loop1:	movea.l	a0,a1		*a1 = 左端アドレス
	move.w	d2,d4		*d4 = 横ピクセル数-1
loop2:	move.w	d0,(a1)+	*１ピクセル点を打つ
	dbra	d4,loop2	*横幅分繰り返す

	lea.l	GNBYTE(a0),a0	*すぐ下のラインへ
	dbra	d3,loop1	*高さ分繰り返す

done:	movem.l	(sp)+,d0-d4/a0-a1
	unlk	a6
	rts

	.end
