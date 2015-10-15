*	32768色→256色変換

	.include	gconst.h
	.include	gmacro.h
*
MATSIZ	equ	8	*ディザマトリクスの大きさ
*
	.xdef	gltom
	.xref	gramadr
	.xref	gcliprect
	.xref	dithermatrix
*
	.offset	0	*gltomの引数構造
*
X0:	.ds.w	1	*矩形座標
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
*
	.text
	.even
*
gltom:
ARGPTR	=	8
	link	a6,#0
	movem.l	d0-d7/a0-a3,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = 引数列
	movem.w	(a1),d0-d3	*d0～d3に座標を取り出す

	jsr	gcliprect	*クリッピングする
	bmi	done		*N=1なら描画の必要なし

	jsr	gramadr		*G-RAM上のアドレスを得る

	sub.w	d0,d2		*d2 = 横ピクセル数-1
	sub.w	d1,d3		*d3 = 縦ピクセル数-1
	lsl.w	#3,d1

	lea.l	dithermatrix,a2
	move.w	d0,d4		*d4 = 左端x座標
loop1:	movea.l	a0,a1		*a1 = ライン左端
	andi.w	#(MATSIZ-1)*MATSIZ,d1
				*d1 = ディザマトリクスの行インデックス
	lea.l	0(a2,d1),a3	*a3 = ディザマトリクスの行

	swap.w	d4
	move.w	d2,d4		*d4 = 横ピクセル数-1
	swap.w	d1
	swap.w	d2
loop2:	move.w	(a1),d1		*１ピクセル取り出す
	DERGB	d1,d5,d6,d7	*RGBに分解する
	lsl.w	#4,d5		*RGB512階調に変換する
	lsl.w	#4,d6		*
	lsl.w	#4,d7		*

	andi.w	#MATSIZ-1,d0	*d0 = ディザマトリクスの列インデックス
	move.b	0(a3,d0),d2	*d2 = 加算する震え成分
	ext.w	d2		*

	add.w	d2,d5		*RGBごとに震え成分を加える
	add.w	d2,d6		*
	add.w	d2,d7		*

	clr.w	d1		*最小輝度以上を保証
	MAX	d1,d5		*
	MAX	d1,d6		*
	MAX	d1,d7		*

	move.w	#RGBMAX*16,d1	*最大輝度以下を保証
	MIN	d1,d5		*
	MIN	d1,d6		*
	MIN	d1,d7		*

	lsr.w	#6,d5		*下位ビットを切り捨てる
	lsr.w	#6,d6		*
	lsr.w	#7,d7		*

	move.w	d7,d1		*256色モードのパレットコード
	lsl.w	#3,d1		*　に構成する
	or.w	d6,d1		*
	lsl.w	#3,d1		*
	or.w	d5,d1		*

	move.w	d1,(a1)+	*書き込む

	addq.w	#1,d0		*ディザマトリクスの列を進める
	dbra	d4,loop2	*横幅分繰り返す

	swap.w	d1
	swap.w	d2
	swap.w	d4
	move.w	d4,d0		*ディザマトリクス列インデックスをリセット
	addq.w	#MATSIZ,d1	*ディザマトリクスの行を進める
	lea.l	GNBYTE(a0),a0	*すぐ下のラインへ
	dbra	d3,loop1	*高さ分繰り返す

done:	movem.l	(sp)+,d0-d7/a0-a3
	unlk	a6
	rts

	.end
