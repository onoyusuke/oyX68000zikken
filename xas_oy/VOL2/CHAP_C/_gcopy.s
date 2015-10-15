*	gcopy()

	.include	iocscall.mac
*
	.xdef	_gcopy
	.xref	gcopy
*
	.offset	8	*gcopy()ÇÃà¯êîç\ë¢
*
X0:	.ds.l	1
Y0:	.ds.l	1
X1:	.ds.l	1
Y1:	.ds.l	1
X2:	.ds.l	1
Y2:	.ds.l	1
*
	.text
	.even
*
_gcopy:
	link	a6,#0

	suba.l	a1,a1
	IOCS	_B_SUPER

	move.w	Y2+2(a6),-(sp)
	move.w	X2+2(a6),-(sp)
	move.w	Y1+2(a6),-(sp)
	move.w	X1+2(a6),-(sp)
	move.w	Y0+2(a6),-(sp)
	move.w	X0+2(a6),-(sp)

	pea.l	(sp)
	jsr	gcopy

	tst.l	d0
	bmi	done

	movea.l	d0,a1
	IOCS	_B_SUPER

done:	unlk	a6
	rts

	.end
