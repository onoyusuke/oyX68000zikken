*	apage()

	.include	iocscall.mac
*
	.xdef	_apage
	.xref	apage
*
	.text
	.even
*
_apage:
PAGENO	=	4+3
	move.b	PAGENO(sp),d1
	bmi	getapage
	ext.w	d1
	jmp	apage
*
getapage:
	IOCS	_APAGE
	rts

	.end
