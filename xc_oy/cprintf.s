*************************************************************************
*cprintf：コンソールにフォーマットデータを書き込む			*
*	int		cprintf(format,...);				*
*	const char	*format;					*
*vcprintf：コンソールにフォーマットデータを書き込む			*
*	int		vcprintf(format,arg);				*
*	const char	*format;					*
*	va_list		arg;						*
*************************************************************************
* Copyright 1990 SHARP/Hudson		(1990/05/05)			*

	xdef	_cprintf
	xdef	_vcprintf

	xref	_putch
	xref	__fmtout

	.offset	4
format	ds.l	1
arg	ds.l	1

	.text
_vcprintf:
	move.l	arg(sp),-(sp)
	bra	_cprint0
_cprintf:
	pea	arg(sp)
_cprint0:
	move.l	format+4(sp),-(sp)
	clr.l	-(sp)
	pea	_putch
	jsr	__fmtout
	lea	16(sp),sp
	rts
