*	色の混ぜ合わせ

	.include	gconst.h
	.include	gmacro.h
*
	.xdef	gmixcolor
	.xref	gramadr
	.xref	gcliprect
*
	.offset	0	*gmixcolorの引数構造
*
X0:	.ds.w	1	*矩形座標
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
COL:	.ds.w	1	*加える色
*
	.text
	.even
*
gmixcolor:
ARGPTR	=	8
	link	a6,#0
	movem.l	d0-d7/a0-a1,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = 引数列
	movem.w	(a1),d0-d3	*d0〜d3に座標を取り出す

	jsr	gcliprect	*クリッピングする
	bmi	done		*N=1なら描画の必要なし

	jsr	gramadr		*左上のG-RAM上のアドレスを得る

	sub.w	d0,d2		*d2 = 横ピクセル数-1
	sub.w	d1,d3		*d3 = 縦ピクセル数-1

	move.w	#GNBYTE-2,d1	*d1 = ライン間のアドレスの差
	sub.w	d2,d1		*（右端から下のラインの左端まで）
	sub.w	d2,d1		*

	move.w	COL(a1),d4	*d0 = 加える色
	DERGB	d4,d5,d6,d7	*

loop1:	move.w	d2,d4
	swap.w	d1		*レジスタが足りないから
	swap.w	d2		*　データレジスタの
	swap.w	d3		*　上位ワードも使う
loop2:	move.w	(a0),d0		*色コードを取り出し
	DERGB	d0,d1,d2,d3	*　RGBごとに
	MEAN	d5,d1		*　色成分の平均を取る
	MEAN	d6,d2		*
	MEAN	d7,d3		*

	RGB	d1,d2,d3,d0	*カラーコードに再構成
	move.w	d0,(a0)+	*１ピクセル書き込む
	dbra	d4,loop2	*横幅分繰り返す

	swap.w	d1
	swap.w	d2
	swap.w	d3
	adda.w	d1,a0		*すぐ下のラインへ
	dbra	d3,loop1	*高さ分繰り返す

done:	movem.l	(sp)+,d0-d7/a0-a1
	unlk	a6
	rts

	.end
