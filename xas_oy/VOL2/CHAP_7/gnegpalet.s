*	パレットレベルで色反転する

	.include	doscall.mac
	.include	gconst.h
*
	.xdef	gnegatepalet
*
	.text
	.even
*
gnegatepalet:
	movem.l	d0/a0,-(sp)

	lea.l	GPALET,a0	*パレットレジスタ
	moveq.l	#512/4-1,d0	*　512バイトを４バイト単位で
loop:	not.l	(a0)+		*　ビット反転する
	dbra	d0,loop		*

	movem.l	(sp)+,d0/a0
	rts

	.end
