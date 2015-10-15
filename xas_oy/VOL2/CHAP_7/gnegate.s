*	色反転（補色への置換）

	.xdef	gnegate
	.xref	gxorcolor
*
	.offset	0	*gnegateの引数構造
*
X0:	.ds.w	1	*矩形座標
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
*
	.text
	.even
*
gnegate:
ARGPTR	=	8+4
	move.l a1,-(sp)
	link	a6,#0

	movea.l	ARGPTR(a6),a1	*a1 = 引数列
	move.w	#$ffff,-(sp)	*描画色 = ffffh
	move.l	4(a1),-(sp)	*(x1,y1)
	move.l	(a1),-(sp)	*(x0,y0)
	pea.l	(sp)		*gxorcolorへの引数列
	jsr	gxorcolor

	unlk	a6
	movea.l	(sp)+,a1
	rts

	.end
