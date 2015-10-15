*	微分処理（ラプラシアン）

DERGB_BREAK_HIGHWORD	=	1
	.include	gconst.h
	.include	gmacro.h
*
	.xdef	glaplacian
	.xref	gramadr
	.xref	gcliprect
	.xref	grayscale
*
DR	equ	2	*右の点とのアドレスの差
DD	equ	GNBYTE	*下の点とのアドレスの差
*
	.offset	0	*glaplacianの引数構造
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
glaplacian:
	link	a6,#WORKTOP
	movem.l	d0-d7/a0-a5,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = 引数列
	movem.w	(a1),d0-d3	*d0～d3に座標を取り出す

	jsr	gcliprect	*クリッピングする
	bne	done		*Z=0なら描画の必要なし

	jsr	gramadr		*G-RAM上のアドレスを得る

	sub.w	d0,d2		*d2 = 横ピクセル数-1
	sub.w	d1,d3		*d3 = 縦ピクセル数-1

	lea.l	GNBYTE-2.w,a5	*a5 = ライン間のアドレスの差
	suba.w	d2,a5		*（右端から下のラインの左端まで）
	suba.w	d2,a5		*

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
	lea.l	grayscale,a3
	RGBtoYx_INIT	a4
loop1:	move.w	d2,d4		*d4 = 横ピクセル数-1-1
	swap.w	d2
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

	adda.l	a5,a0		*すぐ下のラインへ
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

done:	movem.l	(sp)+,d0-d7/a0-a5
	unlk	a6
	rts
*
gsub:
	move.w	(a1)+,d7	*中心の点
	_DERGB	d5,d6,d7	*RGBに分解し
	RGBtoYx	d5,d6,d7,d2	*　輝度Icを得る

	lsl.w	#2,d2		*その４倍から
	moveq.l	#4-1,d0		*　周囲の４点の輝度を減じる
sublp:	move.w	(a1)+,d7	*
	_DERGB	d5,d6,d7	*
	RGBtoYx	d5,d6,d7,d1	*
	sub.w	d1,d2		*
	dbra	d0,sublp	*

	addi.w	#RGBMAX*4,d2	*-31*4～+31*4を
	lsr.w	#3,d2		*　0～31に変換
	add.w	d2,d2		*対応する灰色の
	move.w	(a3,d2.w),d0	*　カラーコードに置き換える
	lea.l	-PBUFSIZ(a1),a1
	rts

	.end
