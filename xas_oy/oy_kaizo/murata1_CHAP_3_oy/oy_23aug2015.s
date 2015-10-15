	.include	doscall.mac
*
	.text
	.even
*
start:
	move.l #$ff8000,d0
	movea.w d0,a1

*	movea.w #$8000,a0

	DOS	_EXIT		*èIóπ

	.end
