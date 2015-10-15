*	rgbからhsvへの変換

	.include	gmacro.h
*
	.xdef	rgbtohsv
*
	.text
	.even
*
*	d0.w = gggggrrrrrbbbbb0
*	→ d0.l = hhhhhhhhhhhhhhhh_000sssss_000vvvvv
*
rgbtohsv:
	movem.l	d1-d7,-(sp)

	DERGB	d0,d3,d4,d5

	moveq.l	#0,d7		*仮にbが最大と仮定
	move.w	d3,d2		*
	cmp.w	d4,d2		*
	bge	skip0		*
	moveq.l	#2,d7		*rが最大と仮定
	move.w	d4,d2		*
skip0:	cmp.w	d5,d2		*
	bge	skip1		*
	moveq.l	#4,d7		*gが最大
	move.w	d5,d2		*

skip1:	move.w	d3,d6		*
	MIN	d4,d6		*
	MIN	d5,d6		*d6 = t
	neg.w	d6
	add.w	d2,d6		*d6 = v-t

*	d2 = v = max(r,g,b)
*	d6 = v - t = max(r,g,b) - min(r,g,b)
*	d7 = 0 ... v = b
*	   = 2 ... v = r
*	   = 4 ... v = g

	moveq.l	#0,d1		*s = 0
	tst.w	d2		*v=0？
	beq	sskip		*
	move.w	d6,d1		*d1 = v-t
	mulu.w	#31*2,d1	*d1 = 31*2*(v-t)
	add.w	d2,d1		*d1 = 31*2*(v-t)+v
	move.w	d2,d0		*d0 = v
	add.w	d0,d0		*d0 = 2*v
	divu.w	d0,d1		*d1 = s = (31*2*(v-t)+v)/(2*v)
				*	= (31*(v-t)+0.5)/v

sskip:	moveq.l	#-1,d0		*h = -1（無彩色の色相は不定）
	tst.w	d1		*s=0？
	beq	hskip
	neg.w	d3
	add.w	d2,d3		*b = v-b
	neg.w	d4
	add.w	d2,d4		*r = v-r
	neg.w	d5
	add.w	d2,d5		*g = v-g

	move.w	jmptbl(pc,d7),d7
	jsr	jmptbl(pc,d7)

	asl.w	#6,d7		*d7 = 32*2*(xx-yy)
	add.w	d6,d7		*d7 = 32*2*(xx-yy)+(v-t)
	ext.l	d7
	add.w	d6,d6		*d6 = 2*(v-t)
	divs.w	d6,d7		*d7 = (32*2*(xx-yy)+(v-t)/(2*(v-t))
				*   = (32*(xx-yy)+0.5)/(v-t)
	add.w	d7,d0		*d0 = h
	bpl	hskip
	addi.w	#192,d0		*h≧0を保証

hskip:	swap.w	d0		*hsvをIOCS形式に構成
	move.b	d1,d0		*
	lsl.w	#8,d0		*
	move.b	d2,d0		*

	movem.l	(sp)+,d1-d7
	rts
*
jmptbl:
x	=	jmptbl
	.dc.w	MtoC-x
	.dc.w	YtoM-x
	.dc.w	CtoY-x
*
MtoC:	move.w	#4*32,d0
	move.w	d5,d7
	sub.w	d4,d7		*d7 = gg-rr
	rts
*
YtoM:	moveq.l	#0,d0
	move.w	d3,d7
	sub.w	d5,d7		*d7 = bb-gg
	rts
*
CtoY:	move.w	#2*32,d0
	move.w	d4,d7
	sub.w	d3,d7		*d7 = rr-bb
	rts

	.end
