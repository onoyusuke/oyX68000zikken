*	オーダードディザによる２値化

	.include	gconst.h
	.include	gmacro.h
*
MATSIZ	equ	8	*ディザマトリクスの大きさ
*
	.xdef	gdither_bin
	.xref	gramadr
	.xref	gcliprect
	.xref	dithermatrix
*
	.offset	0	*gdither_binの引数構造
*
X0:	.ds.w	1	*矩形座標
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
T:	.ds.w	1	*しきい値（基準値64）
*
	.text
	.even
*
gdither_bin:
ARGPTR	=	8
	link	a6,#0
	movem.l	d0-d7/a0-a5,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = 引数列
	movem.w	(a1),d0-d3	*d0～d3に座標を取り出す

	jsr	gcliprect	*クリッピングする
	bmi	done		*N=1なら描画の必要なし

	jsr	gramadr		*G-RAM上のアドレスを得る

	sub.w	d0,d2		*d2 = 横ピクセル数-1
	sub.w	d1,d3		*d3 = 縦ピクセル数-1
	lsl.w	#3,d1

	swap.w	d3		*d3 = マトリクスの重み
	move.w	T(a1),d3	*
	swap.w	d3		*

	lea.l	dithermatrix,a2
	RGBtoYx_INIT	a5
	move.w	d0,d4		*d4 = 左端x座標
loop1:	movea.l	a0,a1		*a1 = ライン左端
	andi.w	#(MATSIZ-1)*MATSIZ,d1
				*d1 = ディザマトリクスの行インデックス
	lea.l	(a2,d1.w),a3	*a3 = ディザマトリクスの行

	swap.w	d4
	move.w	d2,d4		*d4 = 横ピクセル数-1
	swap.w	d1
	swap.w	d2
	swap.w	d3
loop2:	move.w	(a1),d7		*１ピクセル取り出す
	DERGB	d7,d1,d5,d6	*RGBに分解する
	RGBtoYx	d1,d5,d6,d7	*明るさを求める
	lsl.w	#2,d7		*128階調に変換

	andi.w	#MATSIZ-1,d0	*d0 = ディザマトリクスの列インデックス
	move.b	(a3,d0.w),d2	*d2 = 加算する震え成分
	ext.w	d2		*

	add.w	d2,d7		*震え成分を加える

	clr.w	d1		*rgb(0,0,0)
	cmp.w	d3,d7		*しきい値未満？
	blt	skip		*
	move.w	#$fffe,d1	*rgb(1,1,1)

skip:	move.w	d1,(a1)+	*書き込む

	addq.w	#1,d0		*ディザマトリクスの列を進める
	dbra	d4,loop2	*横幅分繰り返す

	swap.w	d1
	swap.w	d2
	swap.w	d3
	swap.w	d4
	move.w	d4,d0		*ディザマトリクス列インデックスをリセット
	addq.w	#MATSIZ,d1	*ディザマトリクスの行を進める
	lea.l	GNBYTE(a0),a0	*すぐ下のラインへ
	dbra	d3,loop1	*高さ分繰り返す

done:	movem.l	(sp)+,d0-d7/a0-a5
	unlk	a6
	rts

	.end
