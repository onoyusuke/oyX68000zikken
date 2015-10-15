*	平滑化（中央値フィルタ）

	.include	gconst.h
	.include	gmacro.h
*
	.xdef	gmedian
	.xref	gramadr
	.xref	gcliprect
*
DR	equ	2	*右の点とのアドレスの差
DD	equ	GNBYTE	*下の点とのアドレスの差
*
	.offset	0	*gmedianの引数構造
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
gmedian:
	link	a6,#WORKTOP
	movem.l	d0-d7/a0-a2,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = 引数列
	movem.w	(a1),d0-d3	*d0～d3に座標を取り出す

	jsr	gcliprect	*クリッピングする
	bne	done		*Z=0なら描画の必要なし

	jsr	gramadr		*G-RAM上のアドレスを得る

	sub.w	d0,d2		*d2 = 横ピクセル数-1
	sub.w	d1,d3		*d3 = 縦ピクセル数-1

	move.w	#GNBYTE-2,d1	*d1 = ライン間のアドレスの差
	sub.w	d2,d1		*（右端から下のラインの左端まで）
	sub.w	d2,d1		*

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

	adda.w	d1,a0		*すぐ下のラインへ
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
gsub:	movem.l	d1-d4/a0-a1,-(sp)
	lea.l	-PBUFSIZ*3(sp),sp

	movea.l	sp,a0
	moveq.l	#5-1,d4
gloop:	move.w	(a1)+,d0	*中心の点
	DERGB	d0,d5,d6,d7	*RGBに分解
	move.w	d5,PBUFSIZ*2(a0)	*g
	move.w	d6,PBUFSIZ(a0)		*r
	move.w	d7,(a0)+		*b
	dbra	d4,gloop

	movea.l	sp,a0
	moveq.l	#0,d0
	bsr	median
	lsl.w	#5,d0
	bsr	median
	lsl.w	#5,d0
	bsr	median
	add.w	d0,d0

	lea.l	PBUFSIZ*3(sp),sp
	movem.l	(sp)+,d1-d4/a0-a1
	rts
*
median:
	movem.w	(a0)+,d1-d5
	MINMAX	d1,d2
	MINMAX	d1,d3
	MINMAX	d1,d4
	MINMAX	d1,d5	
	MINMAX	d2,d3
	MINMAX	d2,d4
	MINMAX	d2,d5
	MINMAX	d3,d4
	MINMAX	d3,d5
	or.w	d3,d0
	rts

	.end
