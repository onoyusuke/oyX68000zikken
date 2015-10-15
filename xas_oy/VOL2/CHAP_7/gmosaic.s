*	モザイク処理

DERGB_BREAK_HIGHWORD	=	0
	.include	gconst.h
	.include	gmacro.h
*
	.xdef	gmosaic
	.xref	gramadr
	.xref	gcliprect
*
	.offset	0	*gmosaicの引数構造
*
X0:	.ds.w	1	*矩形座標
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
MOSSIZ:	.ds.w	1	*モザイクの大きさ（２～32）
*
	.text
	.even
*
gmosaic:
ARGPTR	=	8
	link	a6,#0
	movem.l	d0-d7/a0-a5,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = 引数列
	movem.w	(a1),d0-d4	*d0～d3に座標を取り出す

	jsr	gcliprect	*クリッピングする
	bmi	done		*N=1なら描画の必要なし

	jsr	gramadr		*G-RAM上のアドレスを得る

	sub.w	d0,d2		*d2 = 横ピクセル数-1
	sub.w	d1,d3		*d3 = 縦ピクセル数-1

	cmpi.w	#1,d4		*量子化レベルは
	ble	done		*　２～32まで
	cmpi.w	#32,d4		*
	bgt	done		*

	addq.w	#1,d2		*d2 = 横ピクセル数
	addq.w	#1,d3		*d3 = 縦ピクセル数
	move.w	d2,d6		*d6 = 横ピクセル数
	ext.l	d2		*
	ext.l	d3		*
	divu.w	d4,d2		*d2 = 横大ピクセル数
	divu.w	d4,d3		*d3 = 縦大ピクセル数

	swap.w	d2
	sub.w	d2,d6		*d6 = WID = 端数を除いた矩形の横ピクセル数
	swap.w	d2

	moveq.l	#GSFTCTR,d0	*d1 = GNB*SIZ
	move.w	d4,d1		*
	lsl.w	d0,d1		*

	movea.w	d1,a4		*a4 = GNB*SIZ-H*2
	suba.w	d4,a4		*
	suba.w	d4,a4		*

	sub.w	d6,d1		*d1 = GNB*SIZ-WID*2
	sub.w	d6,d1		*

	lea.l	GNBYTE.w,a5	*a5 = GNB-SIZ*2
	suba.w	d4,a5		*
	suba.w	d4,a5		*

	subq.w	#1,d2		*d2 = 横大ピクセル数-1
	bmi	done		*
	subq.w	#1,d3		*d3 = 縦大ピクセル数-1
	bmi	done		*

	move.w	d4,d0		*a3 = 分母 = SIZ*SIZ
	mulu.w	d0,d0		*
	move.l	d0,a3		*

	subq.w	#1,d4		*a2 = SIZ-1
	move.w	d4,a2		*

loop1:	move.w	d2,d0		*d0 = 横大ピクセル数-1
	swap.w	d1
	swap.w	d2
	swap.w	d3
loop2:	movea.l	a0,a1		*a1 = 描画先ライン左端

	move.l	a3,d4
	lsr.w	#1,d4		*d4.l = 青の輝度合計（初期値=分母/2）
	move.l	d4,d5		*d5.l = 赤の輝度合計
	move.l	d4,d6		*d6.l = 緑の輝度合計

	move.w	a2,d7		*d7 = SIZ-1
loop3:	swap.w	d7
	move.w	a2,d7		*d7 = SIZ-1
loop4:	move.w	(a1)+,d3	*１ピクセル取り出す
	_DERGB	d1,d2,d3	*RGBに分解する
	add.w	d1,d4		*RGBごとに輝度を累積
	add.w	d2,d5		*
	add.w	d3,d6		*
	dbra	d7,loop4	*大ピクセルの横幅分繰り返す
	swap.w	d7
	adda.l	a5,a1		*大ピクセルの次ライン左端へ
	dbra	d7,loop3	*大ピクセルの高さ分繰り返す

	move.w	a3,d7		*d7 = 平均化の分母
	divu.w	d7,d4		*d4 = 青の平均輝度
	divu.w	d7,d5		*d5 = 赤の平均輝度
	divu.w	d7,d6		*d6 = 緑の平均輝度
	_RGB	d4,d5,d6	*RGBに再構成

	move.w	a2,d4		*大ピクセルを塗り潰す
loop5:	move.w	a2,d5		*
loop6:	move.w	d6,(a0)+	*
	dbra	d5,loop6	*
	adda.l	a5,a0		*
	dbra	d4,loop5	*

	suba.l	a4,a0		*右隣の大ピクセルへ
	dbra	d0,loop2	*横大ピクセル数分繰り返す

	swap.w	d1
	swap.w	d2
	swap.w	d3
	adda.w	d1,a0		*１段下左端の大ピクセルへ
	dbra	d3,loop1	*縦大ピクセル数分繰り返す

done:	movem.l	(sp)+,d0-d7/a0-a5
	unlk	a6
	rts

	.end

修正履歴

92-01-01版
何故かGNBYTE倍するのにmuluを使っていたのをlslに修正

92-02-01版
修正履歴にまったく関係ないことが書いてあった（あ～あ）のを修正
（内容の変化なし）
