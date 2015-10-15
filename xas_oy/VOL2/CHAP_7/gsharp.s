*	鮮鋭化（ラプラシアン像との合成）

DERGB_BREAK_HIGHWORD	=	1
	.include	gconst.h
	.include	gmacro.h
*
	.xdef	gsharp
	.xref	gramadr
	.xref	gcliprect
*
DR	equ	2	*右の点とのアドレスの差
DD	equ	GNBYTE	*下の点とのアドレスの差
*
	.offset	0	*gsharpの引数構造
*
X0:	.ds.w	1	*矩形座標
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
*
	.offset	0	*５ピクセル分の作業用バッファ
*
C:	.ds.w	1	*中心
L:	.ds.w	1	*左
U:	.ds.w	1	*上
R:	.ds.w	1	*右
D:	.ds.w	1	*下
PBUFSIZ:
*
	.offset	-GNBYTE-PBUFSIZ	*スタックフレーム
*
WORKTOP:
PBUF:	.ds.b	PBUFSIZ	*５ピクセル分の作業用バッファ
LBUF:	.ds.b	GNBYTE	*１ライン分のバッファ
_a6:	.ds.l	1	*±0
_pc:	.ds.l	1
ARGPTR:	.ds.l	1
*
	.text
	.even
*
gsharp:
	link	a6,#WORKTOP
	movem.l	d0-d7/a0-a3,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = 引数列
	movem.w	(a1),d0-d3	*d0～d3に座標を取り出す

	jsr	gcliprect	*クリッピングする
	bne	done		*Z=0なら描画の必要なし

	jsr	gramadr		*G-RAM上のアドレスを得る

	sub.w	d0,d2		*d2 = 横ピクセル数-1
	sub.w	d1,d3		*d3 = 縦ピクセル数-1

	lea.l	GNBYTE-2.w,a3	*a3 = ライン間のアドレスの差
	sub.w	d2,a3		*（右端から下のラインの左端まで）
	sub.w	d2,a3		*

	movea.l	a0,a1		*一番上のラインを
	lea.l	LBUF(a6),a2	*　バッファにコピーしておく
	move.w	d2,d4		*
loop0:	move.w	(a1)+,(a2)+	*
	dbra	d4,loop0	*

	subq.w	#1,d2		*d2 = 横ピクセル数-1-1
	bmi	done
	subq.w	#1,d3		*d3 = 縦ピクセル数-1-1
	bmi	done

	lea.l	PBUF(a6),a1
loop1:	move.w	d2,d4		*d4 = 横ピクセル数-1-1
	swap.w	d2
	swap.w	d3
	lea.l	LBUF(a6),a2	*a2 = １ラインのバッファ
	move.w	(a0),L(a1)	*左端のみ(x-1,y)の代わりに(x,y)
loop2:	move.w	(a0),C(a1)	*(x,y)
	move.w	(a2),U(a1)	*(x,y-1)
	move.w	DR(a0),R(a1)	*(x+1,y)
	move.w	DD(a0),D(a1)	*(x,y+1)
	bsr	gsub		*色を混ぜ合わせる
	move.w	(a0),(a2)+	*下のライン用に覚えておく
	move.w	(a0),L(a1)	*(x-1,y)
	move.w	d0,(a0)+	*１ピクセル書き込む
	dbra	d4,loop2	*x1-x0-1回繰り返す

			*右端の処理
	move.w	(a0),C(a1)	*(x,y)
	move.w	(a2),U(a1)	*(x,y-1)
	move.w	(a0),R(a1)	*(x+1,y)の代わりに(x,y)
	move.w	DD(a0),D(a1)	*(x,y+1)
	bsr	gsub		*色を混ぜ合わせる
	move.w	(a0),(a2)+	*下のライン用に覚えておく
	move.w	d0,(a0)+	*１ピクセル書き込む

	adda.l	a3,a0		*すぐ下のラインへ
	swap.w	d3
	swap.w	d2
	dbra	d3,loop1	*y1-y0-1回繰り返す

			*最下ラインの処理
	move.w	d2,d4		*d4 = 横ピクセル数-2
	lea.l	LBUF(a6),a2	*a2 = １ラインのバッファ
	move.w	(a0),L(a1)	*左端のみ
				*(x-1,y)の代わりに(x,y)
loop3:	move.w	(a0),C(a1)	*(x,y)
	move.w	(a2)+,U(a1)	*(x,y-1)
	move.w	DR(a0),R(a1)	*(x+1,y)
	move.w	(a0),D(a1)	*(x,y+1)の代わりに(x,y)
	bsr	gsub		*色を混ぜ合わせる
	move.w	(a0),L(a1)	*(x-1,y)
	move.w	d0,(a0)+	*１ピクセル書き込む
	dbra	d4,loop3	*x1-x0-1回繰り返す

			*右下隅の処理
	move.w	(a0),C(a1)	*(x,y)
	move.w	(a2),U(a1)	*(x,y-1)
	move.w	(a0),R(a1)	*(x+1,y)の代わりに(x,y)
	move.w	(a0),D(a1)	*(x,y+1)の代わりに(x,y)
	bsr	gsub		*色を混ぜ合わせる
	move.w	d0,(a0)		*１ピクセル書き込む

done:	movem.l	(sp)+,d0-d7/a0-a2
	unlk	a6
	rts
*
gsub:
	move.w	(a1)+,d0	*中心の点
	_DERGB	d1,d2,d0	*RGBごとに８倍
	lsl.w	#3,d1		*
	lsl.w	#3,d2		*
	lsl.w	#3,d0		*

	moveq.l	#4-1,d7		*周囲の４点の色を
sublp:	move.w	(a1)+,d3	*　RGBごとに減じる
	_DERGB	d5,d6,d3	*
	sub.w	d5,d1		*
	sub.w	d6,d2		*
	sub.w	d3,d0		*
	dbra	d7,sublp	*

	moveq.l	#0,d7		*最小輝度以上を保証
	MAX	d7,d1		*
	MAX	d7,d2		*
	MAX	d7,d0		*

	addq.w	#2,d1		*四捨五入しつつ４で割る
	lsr.w	#2,d1		*
	addq.w	#2,d2		*
	lsr.w	#2,d2		*
	addq.w	#2,d0		*
	lsr.w	#2,d0		*

	moveq.l	#RGBMAX,d7	*最大輝度以下を保証
	MIN	d7,d1		*
	MIN	d7,d2		*
	MIN	d7,d0		*

	_RGB	d1,d2,d0	*カラーコードに再構成
	lea.l	-PBUFSIZ(a1),a1
	rts

	.end
