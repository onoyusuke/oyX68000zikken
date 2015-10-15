*	パレットを初期化する（65536色モード時）

	.include	doscall.mac
	.include	gconst.h
*
	.xdef	ginitpalet_l
*
	.text
	.even
*
ginitpalet_l:
	movem.l	d0-d2/a0,-(sp)

	lea.l	GPALET,a0
	move.l	#$0001_0001,d0
	move.l	#$0202_0202,d1

	moveq.l	#512/4-1,d2
loop:	move.l	d0,(a0)+
	add.l	d1,d0
	dbra	d2,loop

	movem.l	(sp)+,d0-d2/a0
	rts

	.end
