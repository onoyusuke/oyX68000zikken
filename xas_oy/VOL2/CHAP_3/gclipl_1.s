*	線分の矩形領域クリッピング（中点分割）

	.include	rect.h
*
	.xdef	gclipline
	.xref	cliprect
	.xref	ucliprect
*
*	端点分類コード
*
LT_MINX_BIT	equ	0
GT_MAXX_BIT	equ	1
LT_MINY_BIT	equ	2
GT_MAXY_BIT	equ	3
*
LT_MINX		equ	1
GT_MAXX		equ	2
LT_MINY		equ	4
GT_MAXY		equ	8

*
*	端点分類コードを求めるマクロ
*
CHKVIS	macro	XX,YY,CODE
	local	skip0,skip1,skip2,skip3
	movea.l	a0,a1
	moveq.l	#0,CODE
	cmp.w	(a1)+,XX
	bge	skip0
	addq.w	#LT_MINX,CODE
skip0:	cmp.w	(a1)+,YY
	bge	skip1
	addq.w	#LT_MINY,CODE
skip1:	cmp.w	(a1)+,XX
	ble	skip2
	addq.w	#GT_MAXX,CODE
skip2:	cmp.w	(a1)+,YY
	ble	skip3
	addq.w	#GT_MAXY,CODE
skip3:	
	.endm
*
	.text
	.even
*
*	線分(d0.w,d1.w)-(d2.w,d3.w)を
*	cliprectで指定された矩形領域でクリップする
*	完全不可視の場合はZ=0で戻る
gclipline:
	lea.l	cliprect,a0	*クリッピング範囲
	CHKVIS	d0,d1,d6	*d6 = 始点の分類コード
	CHKVIS	d2,d3,d7	*d7 = 終点の分類コード

	add.w	d7,d6		*d6とd7が
				*　ともに0であれば
	beq	done		*　線分は完全に可視
	sub.w	d7,d6		*

	move.w	d6,d4		*d6とd7のandが
	and.w	d7,d4		*　非0であれば
	bne	done		*　線分は完全に不可視

	lea.l	ucliprect,a0	*クリッピング範囲（ゲタ履き）
	move.w	#$8000,d4	*$8000のゲタを履かせる
	add.w	d4,d0		*
	add.w	d4,d1		*
	add.w	d4,d2		*
	add.w	d4,d3		*

	tst.w	d6		*始点は可視か？
	beq	skip1		*　可視ならクリッピング不要
	bsr	gcliplinesub	*始点をクリップ
	bne	done		*なおかつ不可視だった

skip1:	move.w	d7,d6		*終点は可視か？
	beq	skip2		*　可視ならクリッピング不要
	exg.l	d0,d2		*始点と終点を取り替える
	exg.l	d1,d3		*
	bsr	gcliplinesub	*終点をクリップ
	bne	done		*なおかつ不可視だった
	exg.l	d0,d2		*取り替えた始点と終点を
	exg.l	d1,d3		*元に戻す

skip2:	move.w	#$8000,d4	*ゲタを脱がせる
	sub.w	d4,d0		*
	sub.w	d4,d1		*
	sub.w	d4,d2		*
	sub.w	d4,d3		*

	moveq.l	#0,d4		*Z = 1
done:	rts

*
*	片方の端点(d0.w,d1.w)をクリップする
*
gcliplinesub:
	move.w	d0,a1		*クリッピング前の座標を
	move.w	d1,a2		*　覚えておく
	move.w	d2,a3		*
	move.w	d3,a4		*
	moveq.l	#2-1,d4		*クリッピング回数カウンタ
	move.w	d6,ccr		*----NZVC
	bcs	minxclip	*bit 0 = 1ならば左の辺にクリップ
	bvs	maxxclip	*bit 1 = 1ならば右の辺にクリップ
	beq	minyclip	*bit 2 = 1ならば上の辺にクリップ
*	bmi	maxyclip	*bit 3 = 1ならば下の辺にクリップ

*
*	MAXYでクリップする
*
maxyclip:		*１回目のエントリ
	move.w	MAXY(a0),d5
	cmp.w	d5,d3
	bne	maxylp
	move.w	d2,d0
	move.w	d3,d1
	bra	yclipn
maxylp:	move.w	d1,d6
	add.w	d3,d6
	roxr.w	#1,d6
	cmp.w	d5,d6
	beq	yclipq
	bcs	maxy0
	move.w	d6,d1
	add.w	d2,d0
	roxr.w	#1,d0
	bra	maxylp
maxy0:	move.w	d6,d3
	add.w	d0,d2
	roxr.w	#1,d2
	bra	maxylp
maxyclip2:		*２回目以降のエントリ
	subq.w	#1,d4
	bcs	outofscrn
	cmp.w	MAXY(a0),d3
	bhi	outofscrn
	move.w	a1,d0
	move.w	a2,d1
	bra	maxyclip
outofscrn:
	moveq.l	#-1,d4		*Z = 0
	rts

*
*	MINYでクリップする
*
minyclip2:		*２回目以降のエントリ
	subq.w	#1,d4
	bcs	outofscrn
	cmp.w	MINY(a0),d3
	bcs	outofscrn
	move.w	a1,d0
	move.w	a2,d1
minyclip:		*１回目のエントリ
	move.w	MINY(a0),d5
	cmp.w	d5,d3
	bne	minylp
	move.w	d2,d0
	move.w	d3,d1
	bra	yclipn
minylp:	move.w	d1,d6
	add.w	d3,d6
	roxr.w	#1,d6
	cmp.w	d5,d6
	beq	yclipq
	bcs	miny0
	move.w	d6,d3
	add.w	d0,d2
	roxr.w	#1,d2
	bra	minylp
miny0:	move.w	d6,d1
	add.w	d2,d0
	roxr.w	#1,d0
	bra	minylp

yclipq:	move.w	d6,d1
	add.w	d2,d0
	roxr.w	#1,d0
	move.w	a3,d2
	move.w	a4,d3
yclipn:	cmp.w	MINX(a0),d0
	bcs	minxclip2
	cmp.w	MAXX(a0),d0
	bhi	maxxclip2
	moveq.l	#0,d4		*Z = 1
	rts

*
*	MAXXでクリップする
*
maxxclip2:		*２回目以降のエントリ
	subq.w	#1,d4
	bcs	outofscrn
	cmp.w	MAXX(a0),d2
	bhi	outofscrn
	move.w	a1,d0
	move.w	a2,d1
maxxclip:		*１回目のエントリ
	move.w	MAXX(a0),d5
	cmp.w	d5,d2
	bne	maxxlp
	move.w	d2,d0
	move.w	d3,d1
	bra	xclipn
maxxlp:	move.w	d0,d6
	add.w	d2,d6
	roxr.w	#1,d6
	cmp.w	d5,d6
	beq	xclipq
	bcs	maxx0
	move.w	d6,d0
	add.w	d3,d1
	roxr.w	#1,d1
	bra	maxxlp
maxx0:	move.w	d6,d2
	add.w	d1,d3
	roxr.w	#1,d3
	bra	maxxlp

*
*	MINXでクリップする
*
minxclip2:		*２回目以降のエントリ
	subq.w	#1,d4		*2辺でクリッピング済みなら
	bcs	outofscrn	*　完全不可視だった
	cmp.w	MINX(a0),d2	*x1 < MINXなら
	bcs	outofscrn	*　完全不可視
	move.w	a1,d0		*クリッピング前の座標から
	move.w	a2,d1		*　やり直す

minxclip:		*１回目のエントリ
	move.w	MINX(a0),d5	*d5 = クリップするx座標
	cmp.w	d5,d2		*x1 = MINXなら
	bne	minxlp		*
	move.w	d2,d0		*　その点(x1,y1)が求める点
	move.w	d3,d1		*
	bra	xclipn
minxlp:	move.w	d0,d6		*
	add.w	d2,d6		*
	roxr.w	#1,d6		*d6 = Mx = (x0+x1)/2
	cmp.w	d5,d6		*Mx = MINXなら
	beq	xclipq		*　それが求める点
	bcs	minx0
			*Mx > MINXなら
	move.w	d6,d2		*x1 = Mx
	add.w	d1,d3		*
	roxr.w	#1,d3		*y1 = My
	bra	minxlp		*　として繰り返す
			*Mx < MINXなら
minx0:	move.w	d6,d0		*x0 = Mx
	add.w	d3,d1		*
	roxr.w	#1,d1		*y0 = My
	bra	minxlp		*　として繰り返す

xclipq:	move.w	d6,d0		*x0 = Mx
	add.w	d3,d1		*
	roxr.w	#1,d1		*y0 = My
	move.w	a3,d2		*x1を復帰
	move.w	a4,d3		*y1を復帰
xclipn:	cmp.w	MINY(a0),d1
	bcs	minyclip2
	cmp.w	MAXY(a0),d1
	bhi	maxyclip2
	moveq.l	#0,d4		*Z = 1
	rts

	.end
