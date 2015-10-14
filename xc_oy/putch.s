*************************************************************************
*putch：コンソールへ１文字書き込みます					*
*	int		putch(c);					*
*	int		c;						*
*************************************************************************
* Copyright 1990 SHARP/Hudson		(1990/05/05)			*

	xdef	_putch

	include	doscall.mac

	.offset	4
c	ds.l	1

	.text
_putch:
	move.l	c(sp),d0
	move.w	d0,-(sp)
	DOS	_PUTCHAR
	clr.l	d0
	move.w	(sp)+,d0
	rts
