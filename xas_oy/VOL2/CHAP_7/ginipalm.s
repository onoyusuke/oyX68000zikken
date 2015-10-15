*	パレットを初期化する（256色モード時）

	.include	doscall.mac
	.include	gconst.h
*
	.xdef	ginitpalet_m
*
BDAT4	macro	B1,B2,B3,B4
	.dc.w	B1*2,B2*2,B3*2,B4*2
	.endm
*
RDAT4	macro	R1,R2,R3,R4
	.dc.w	R1*64,R2*64,R3*64,R4*64
	.endm
*
GDAT4	macro	G1,G2,G3,G4
	.dc.w	G1*2048,G2*2048,G3*2048,G4*2048
	.endm
*
	.text
	.even
*
ginitpalet_m:
	movem.l	d0-d5/a0-a3,-(sp)

	lea.l	GPALET,a0

	lea.l	gdata(pc),a3
	moveq.l	#4-1,d3
gloop:	move.w	(a3)+,d5

	lea.l	rdata(pc),a2
	move.w	#8-1,d2
rloop:	move.w	(a2)+,d4
	or.w	d5,d4

	lea.l	bdata(pc),a1
	moveq.l	#8-1,d1
bloop:	move.w	(a1)+,d0
	or.w	d4,d0
	move.w	d0,(a0)+

	dbra	d1,bloop
	dbra	d2,rloop
	dbra	d3,gloop

	movem.l	(sp)+,d0-d5/a0-a3
	rts
*
bdata:	BDAT4	00,04,09,13
	BDAT4	18,22,27,31
*
rdata:	RDAT4	00,04,09,13
	RDAT4	18,22,27,31
*
gdata:	GDAT4	00,10,21,31

	.end
