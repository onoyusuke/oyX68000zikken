*	辺のリストを作成する（gfillpolyの前処理）	（Ｃ用微修正版）

	.include	edge.h
*
	.xdef	genedgelist
	.xdef	_genedgelist
*
	.text
	.even
*
genedgelist:
_genedgelist:
POINTS	=	8
EDGLST	=	12
	link	a6,#0
	movem.l	d0-d4/a1-a2,-(sp)

	movem.l	POINTS(a6),a0-a1
	exg.l	a0,a1

	move.w	(a1)+,d4	*d4 = 点の数
	subq.w	#2,d4		*
	bcs	gdone		*最低２点必要

geloop:	movem.w	(a1),d0-d3	*２点の座標を取り出す

	cmp.w	d1,d3
	beq	genext		*水平の辺は無視する

	bgt	gnedg1		*y0＜y1を保証する
	exg.l	d0,d2		*
	exg.l	d1,d3		*
gnedg1:	move.w	d0,X0(a0)	*X0(a0) = x0
	move.w	d1,Y0(a0)	*Y0(a0) = y0

	sub.w	d3,d1		*d1 = y0-y1 = -dy
	move.w	d1,E0(a0)	*E0 = -dy

	neg.w	d1
	move.w	d1,DY0(a0)	*DY0(a0) = y1-y0 = dy

	add.w	d1,d1
	move.w	d1,DEY(a0)	*DEY(a0) = dy*2

	moveq.l	#0,d1		*sgn(x1-x0)と
	sub.w	d0,d2		*abs(x1-x0)を求める
	beq	gnedg3		*
	bpl	gnedg2		*
	moveq.l	#-1,d1		*
	neg.w	d2		*
	bra	gnedg3		*
gnedg2:	moveq.l	#1,d1		*

gnedg3:	move.w	d1,SX(a0)	*SX(a0) = sgn(x1-x0)

	add.w	d2,d2
	move.w	d2,DEX(a0)	*DEX(a0)= dx*2

	lea.l	EDGBUFSIZ(a0),a0

genext:	addq.l	#4,a1		*１点分進める
	dbra	d4,geloop

gdone:	movem.l	(sp)+,d0-d4/a1-a2
	unlk	a6
	rts

	.end

修正履歴

93-09-01版
GCLIB.Aのフルセット化に伴い，Ｃ用の外部定義を追加
