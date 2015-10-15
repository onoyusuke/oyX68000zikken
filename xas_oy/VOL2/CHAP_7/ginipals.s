*	パレットを初期化する（16色モード時）

	.include	doscall.mac
	.include	gconst.h
*
	.xdef	ginitpalet_s
*
RGBDAT	macro	B,R,G
	.dc.w	B*2+R*64+G*2048
	.endm
*
	.text
	.even
*
ginitpalet_s
	movem.l	d0/a0-a1,-(sp)

	lea.l	GPALET,a0
	lea.l	paletdata_s(pc),a1

	moveq.l	#16/2-1,d0
loop:	move.l	(a1)+,(a0)+
	dbra	d0,loop

	movem.l	(sp)+,d0/a0-a1
	rts
*
paletdata_s:
	RGBDAT	00,00,00
	RGBDAT	10,10,10
	RGBDAT	16,00,00
	RGBDAT	31,00,00
	RGBDAT	00,16,00
	RGBDAT	00,31,00
	RGBDAT	16,16,00
	RGBDAT	31,31,00
	RGBDAT	00,00,16
	RGBDAT	00,00,31
	RGBDAT	16,00,16
	RGBDAT	31,00,31
	RGBDAT	00,16,16
	RGBDAT	00,31,31
	RGBDAT	21,21,21
	RGBDAT	31,31,31

	.end
