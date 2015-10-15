*	線分の矩形領域クリッピング

	.include	rect.h
*
	.xdef	gclipline
	.xref	ucliprect
*
	.text
	.even
*
*	線分(d0.w,d1.w)-(d2.w,d3.w)を
*	cliprectで指定された矩形領域でクリップする
*	完全不可視の場合はZ=0で戻る
*
gclipline:
	movem.w	ucliprect,a0-a3	*a0～a3 = ウィンドウ（ゲタ履き）

	move.w	#$8000,d4	*座標に$8000のゲタを履かせる
	add.w	d4,d0		*
	add.w	d4,d1		*
	add.w	d4,d2		*
	add.w	d4,d3		*

	bsr	gcliplinesub	*始点をクリップ
	bne	done		*なおかつ不可視だった

	exg.l	d0,d2		*始点と終点を取り替える
	exg.l	d1,d3		*
	bsr	gcliplinesub	*終点をクリップ
	bne	done		*なおかつ不可視だった
	exg.l	d0,d2		*取り替えた始点と終点を
	exg.l	d1,d3		*元に戻す

	move.w	#$8000,d4	*ゲタを脱がせる
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
	move.w	d0,d4		*クリッピング前の座標を
	move.w	d1,d5		*　覚えておく

*
*	MINXでクリップする
*
minxclip:
	cmp.w	a0,d0		*MINX≧x0ならば
	bcc	minyclip	*　MINXでのクリッピングは不要
	cmp.w	a0,d2		*MINX＜x0かつMINX＜x1ならば
	bcs	outofscrn	*　完全不可視
	move.w	a0,d7		*d7 = MINX

	moveq.l	#0,d6
	sub.w	d2,d0		*d0 = abs(x0-x1)
	bcc	minx0		*
	neg.w	d0		*
	addq.w	#1,d6		*d6 = 符号反転回数
minx0:	sub.w	d3,d1		*d1 = abs(y0-y1)
	bcc	minx1		*
	neg.w	d1		*
	addq.w	#1,d6		*d6 = 符号反転回数
minx1:	sub.w	d4,d7		*d7 = abs(x0-MINX)
	bcc	minx2		*
	neg.w	d7		*
	addq.w	#1,d6		*d6 = 符号反転回数
minx2:	mulu.w	d7,d1		*d1 = abs(y0-y1)*abs(x0-MINX)
	divu.w	d0,d1		*d1 /= abs(x0-x1)
	btst.l	#0,d6		*符号反転回数が奇数回ならば
	beq	minx3		*　結果の符号を反転する
	neg.w	d1		*
minx3:	add.w	d5,d1		*d1 = MINXに対応するy
	move.w	a0,d0		*d0 = MINX

*
*	MINYでクリップする
*
minyclip:
	cmp.w	a1,d1
	bcc	maxxclip
	cmp.w	a1,d3
	bcs	outofscrn
	move.w	a1,d7

	moveq.l	#0,d6
	move.w	d5,d1
	sub.w	d3,d1
	bcc	miny0
	neg.w	d1
	addq.w	#1,d6
miny0:	move.w	d4,d0
	sub.w	d2,d0
	bcc	miny1
	neg.w	d0
	addq.w	#1,d6
miny1:	sub.w	d5,d7
	bcc	miny2
	neg.w	d7
	addq.w	#1,d6
miny2:	mulu.w	d7,d0
	divu.w	d1,d0
	btst.l	#0,d6
	beq	miny3
	neg.w	d0
miny3:	add.w	d4,d0		*d0 = MINYに対応するx
	cmp.w	a0,d0		*x0＜MINXならば
	bcs	outofscrn	*　完全不可視
	move.w	a1,d1		*d1 = MINY

*
*	MAXXでクリップする
*
maxxclip:
	cmp.w	a2,d0
	bls	maxyclip
	cmp.w	a2,d2
	bhi	outofscrn
	move.w	a2,d7

	moveq.l	#0,d6
	move.w	d4,d0
	sub.w	d2,d0
	bcc	maxx0
	neg.w	d0
	addq.w	#1,d6
maxx0:	move.w	d5,d1
	sub.w	d3,d1
	bcc	maxx1
	neg.w	d1
	addq.w	#1,d6
maxx1:	sub.w	d4,d7
	bcc	maxx2
	neg.w	d7
	addq.w	#1,d6
maxx2:	mulu.w	d7,d1
	divu.w	d0,d1
	btst.l	#0,d6
	beq	maxx3
	neg.w	d1
maxx3:	add.w	d5,d1		*d1 = MAXXに対応するy
	cmp.w	a1,d1		*y0＜MINYならば
	bcs	outofscrn	*　完全不可視
	move.w	a2,d0		*d0 = MAXX

*
*	MAXYでクリップする
*
maxyclip:
	cmp.w	a3,d1
	bls	visible
	cmp.w	a3,d3
	bhi	outofscrn
	move.w	a3,d7

	moveq.l	#0,d6
	move.w	d5,d1
	sub.w	d3,d1
	bcc	maxy0
	neg.w	d1
	addq.w	#1,d6
maxy0:	move.w	d4,d0
	sub.w	d2,d0
	bcc	maxy1
	neg.w	d0
	addq.w	#1,d6
maxy1:	sub.w	d5,d7
	bcc	maxy2
	neg.w	d7
	addq.w	#1,d6
maxy2:	mulu.w	d7,d0
	divu.w	d1,d0
	btst.l	#0,d6
	beq	maxy3
	neg.w	d0
maxy3:	add.w	d4,d0		*d0 = MAXYに対応するx
	cmp.w	a0,d0		*d0＜MINXならば
	bcs	outofscrn	*　完全不可視
	cmp.w	a2,d0		*d0＞MAXXならば
	bhi	outofscrn	*　完全不可視
	move.w	a3,d1		*d1 = MAXY

visible:
	moveq.l	#0,d4		*Z=1
	rts

outofscrn:
	moveq.l	#-1,d4		*Z=0
	rts

	.end
