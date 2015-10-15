	.include	gconst.h
*
	.xdef	gcopyline_L
*
	.dcb.w	GNPIXEL/2,$20d9	*move.l (a1)+,(a0)+
gcopyline_L:
	rts

	.end
