*	色強調

DERGB_BREAK_HIGHWORD	=	1
	.include	gconst.h
	.include	gmacro.h
*
	.xdef	gaccent
	.xref	gramadr
	.xref	gcliprect
*
	.offset	0	*gaccentの引数構造
*
X0:	.ds.w	1	*矩形座標
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
A:	.ds.w	1	*強調率（基準値64）
*
	.offset	-RGBGRAD*2*2	*スタックフレーム
*
WORKTOP:
ATBL:	.ds.w	RGBGRAD	*0～31をa倍したテーブル
BTBL:	.ds.w	RGBGRAD	*0～31をb=(a-1)/2倍したテーブル
_a6:	.ds.l	1	*±0
_pc:	.ds.l	1
ARGPTR:	.ds.l	1
*
	.text
	.even
*
gaccent:
	link	a6,#WORKTOP
	movem.l	d0-d7/a0-a2,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = 引数列
	movem.w	(a1)+,d0-d3	*d0～d3に座標を取り出す

	jsr	gcliprect	*クリッピングする
	bne	done		*Z=0なら描画の必要なし

	jsr	gramadr		*G-RAM上のアドレスを得る

	sub.w	d0,d2		*d2 = 横ピクセル数-1
	sub.w	d1,d3		*d3 = 縦ピクセル数-1

	move.w	(a1),d7		*d7 = a  （ただし64倍）
	move.w	d7,d6		*d6 = a-1（ただし64倍）
	subi.w	#64,d6		*

BOFST	=	BTBL-ATBL	*２つのテーブルのアドレスの差

	lea.l	ATBL(a6),a1	*0～31の値をa倍, (a-1)/2倍すると
	moveq.l	#0,d0		*　いくつになるか計算して
	moveq.l	#0,d1		*　テーブルにしておく
	moveq.l	#32-1,d4	*
loop0:	move.w	d1,d5		*
	lsr.w	#1,d5		*
	move.w	d5,BOFST(a1)	*
	move.w	d0,(a1)+	*
	add.w	d7,d0		*
	add.w	d6,d1		*
	dbra	d4,loop0	*

	lea.l	GNBYTE-2.w,a2	*a2=ライン間のアドレスの差
	suba.w	d2,a2		*（右端から下のラインの左端まで）
	suba.w	d2,a2		*

	lea.l	ATBL(a6),a1
loop1:	move.w	d2,d4		*d4=横ピクセル数-1
	swap.w	d2
loop2:	move.w	(a0),d7		*カラーコードを取り出し
	_DERGB	d5,d6,d7	*RGBに分解する
	add.w	d5,d5		*
	add.w	d6,d6		*
	add.w	d7,d7		*
	move.w	(a1,d5.w),d0		*d0 = Ab
	move.w	(a1,d6.w),d1		*d1 = Ar
	move.w	(a1,d7.w),d2		*d2 = Ag
	move.w	BOFST(a1,d5.w),d5	*d5 = Bb
	move.w	BOFST(a1,d6.w),d6	*d6 = Br
	move.w	BOFST(a1,d7.w),d7	*d7 = Bg

	sub.w	d6,d0		*d0 = b' = Ab-Br-Bg
	sub.w	d7,d0		*
	sub.w	d7,d1		*d1 = r' = Ar-Bg-Bb
	sub.w	d5,d1		*
	sub.w	d5,d2		*d2 = g' = Ag-Bb-Br
	sub.w	d6,d2		*

	asr.w	#6,d0		*1/64にする
	asr.w	#6,d1		*
	asr.w	#6,d2		*

	moveq.l	#0,d7		*最小輝度以上を保証
	MAX	d7,d0		*
	MAX	d7,d1		*
	MAX	d7,d2		*

	moveq.l	#RGBMAX,d7	*最大輝度以上を保証
	MIN	d7,d0		*
	MIN	d7,d1		*
	MIN	d7,d2		*

	_RGB	d0,d1,d2	*カラーコードに再構成して
	move.w	d2,(a0)+	*　点を打つ

	dbra	d4,loop2	*横幅分繰り返す

	swap.w	d2
	adda.l	a2,a0		*すぐ下のラインへ
	dbra	d3,loop1	*高さ分繰り返す

done:	movem.l	(sp)+,d0-d7/a0-a2
	unlk	a6
	rts

	.end
