	.include	gconst.h
*
	.xdef	gcopyline_R
*
	.dcb.w	GNPIXEL/2,$2121	*move.l -(a1),-(a0)
gcopyline_R:
	rts

	.end
