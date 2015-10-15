	.include	doscall.mac
*
	.text
	.even
*
start:
	move.b	#10,d0		*d0 = 10
	move.b	#20,d1		*d1 = 20
	add.b	d1,d0		*d0 = d0 + d1

	DOS	_EXIT		*èIóπ

	.end
