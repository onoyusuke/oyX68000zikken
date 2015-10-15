*	矩形領域の左右反転

	.include	gconst.h
*
	.xdef	ghreverse
	.xref	gramadr
	.xref	gcliprect
*
	.offset	0	*ghreverseの引数構造
*
X0:	.ds.w	1	*矩形座標
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
*
	.text
	.even
*
ghreverse:
ARGPTR	=	8
	link	a6,#0
	movem.l	d0-d3/a0-a3,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = 引数列
	movem.w	(a1),d0-d3	*d0～d3に座標を取り出す

	jsr	gcliprect	*クリッピングする
	bmi	done		*N=1なら描画の必要なし

	jsr	gramadr		*左上のG-RAM上のアドレスを得る

	sub.w	d0,d2		*d2 = 横ピクセル数-1
	sub.w	d1,d3		*d3 = 縦ピクセル数-1

	add.w	d2,d2
	lea.l	0(a0,d2.w),a2	*a2 = ライン右端アドレス
	move.w	#GNBYTE,d1	*d1 = ライン間のアドレスの差

loop1:	movea.l	a0,a1		*a1 = ライン左端
	movea.l	a2,a3		*a3 = ライン右端

loop2:	move.w	(a1),d0		*交換
	move.w	(a3),(a1)+	*
	move.w	d0,(a3)		*
	subq.l	#2,a3		*

	cmpa.l	a3,a1		*すれ違うまで
	bcs	loop2		*　繰り返す

	adda.w	d1,a0		*つぎのラインへ
	adda.w	d1,a2		*つぎのラインへ
	dbra	d3,loop1	*高さ分繰り返す

done:	movem.l	(sp)+,d0-d3/a0-a3
	unlk	a6
	rts

	.end
