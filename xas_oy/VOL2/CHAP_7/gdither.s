*	オーダードディザにより階調を落とす

DERGB_BREAK_HIGHWORD	=	1
	.include	gconst.h
	.include	gmacro.h
*
	.xdef	gdither
	.xref	gramadr
	.xref	gcliprect
	.xref	dithermatrix
*
MATSIZ	equ	8	*ディザマトリクスの大きさ
*
	.offset	0	*gditherの引数構造
*
X0:	.ds.w	1	*矩形座標
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
NBIT:	.ds.w	1	*変換後のRGBごとのビット数（1～5）
SCL:	.ds.w	1	*ディザマトリクスの重みの逆数（基準値２^NBIT）
*
	.text
	.even
*
gdither:
ARGPTR	=	8
	link	a6,#0
	movem.l	d0-d7/a0-a4,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = 引数列
	movem.w	(a1)+,d0-d3	*d0～d3に座標を取り出す

	jsr	gcliprect	*クリッピングする
	bmi	done		*N=1なら描画の必要なし

	jsr	gramadr		*G-RAM上のアドレスを得る

	sub.w	d0,d2		*d2 = 横ピクセル数-1
	sub.w	d1,d3		*d3 = 縦ピクセル数-1
	lsl.w	#3,d1

	move.w	(a1)+,d4	*落とす階調に応じた
	subq.w	#1,d4		*　スケーリング用のテーブルを得る
	bmi	done		*
	cmpi.w	#5+1,d4		*
	bcc	done		*
	lsl.w	#5,d4		*
	lea.l	ctbl(pc),a4	*
	adda.w	d4,a4		*

	swap.w	d3		*d3 = マトリクスの重みの逆数
	move.w	(a1),d3		*
	beq	done		*
	swap.w	d3		*

	lea.l	dithermatrix,a2
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
	_DERGB	d5,d6,d7	*RGBに分解する
	mulu.w	d3,d5		*適当な重みを掛ける
	mulu.w	d3,d6		*
	mulu.w	d3,d7		*

	andi.w	#MATSIZ-1,d0	*d0 = ディザマトリクスの列インデックス
	move.b	(a3,d0.w),d2	*d2 = 加算する震え成分
	ext.w	d2		*

	add.w	d2,d5		*RGBごとに震え成分を加える
	add.w	d2,d6		*
	add.w	d2,d7		*

	clr.w	d1		*最小輝度以上を保証
	MAX	d1,d5		*
	MAX	d1,d6		*
	MAX	d1,d7		*

	divu.w	d3,d5		*RGB32階調に再変換
	divu.w	d3,d6		*
	divu.w	d3,d7		*

	move.w	#RGBMAX,d1	*最大輝度以下を保証
	MIN	d1,d5		*
	MIN	d1,d6		*
	MIN	d1,d7		*

	move.b	(a4,d5.w),d5	*階調に応じてスケーリング
	move.b	(a4,d6.w),d6	*
	move.b	(a4,d7.w),d7	*

	_RGB	d5,d6,d7	*カラーコードに再構成
	move.w	d7,(a1)+	*書き込む

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

done:	movem.l	(sp)+,d0-d7/a0-a4
	unlk	a6
	rts
*
ctbl:	.dc.b	00,00,00,00,00,00,00,00	*RGB各２階調
	.dc.b	00,00,00,00,00,00,00,00
	.dc.b	31,31,31,31,31,31,31,31
	.dc.b	31,31,31,31,31,31,31,31
*
	.dc.b	00,00,00,00,00,00,00,00	*RGB各４階調
	.dc.b	10,10,10,10,10,10,10,10
	.dc.b	21,21,21,21,21,21,21,21
	.dc.b	31,31,31,31,31,31,31,31
*
	.dc.b	00,00,00,00,04,04,04,04	*RGB各８階調
	.dc.b	09,09,09,09,13,13,13,13
	.dc.b	18,18,18,18,22,22,22,22
	.dc.b	27,27,27,27,31,31,31,31
*
	.dc.b	00,00,02,02,04,04,06,06	*RGB各16階調
	.dc.b	08,08,10,10,12,12,14,14
	.dc.b	17,17,19,19,21,21,23,23
	.dc.b	25,25,27,27,29,29,31,31
*
	.dc.b	00,01,02,03,04,05,06,07	*RGB各32階調
	.dc.b	08,09,10,11,12,13,14,15
	.dc.b	16,17,18,19,20,21,22,23
	.dc.b	24,25,26,27,28,29,30,31

	.end
