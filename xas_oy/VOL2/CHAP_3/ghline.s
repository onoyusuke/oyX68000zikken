*	…•½ü•ª•`‰æƒ‹[ƒv“WŠJ•”

	.include	gconst.h
*
	.xdef	ghline
*
	.text
	.even
*
	.dcb.w	GNPIXEL/2,$20c0	*move.l d0,(a0)+
ghline:	rts

	.end
