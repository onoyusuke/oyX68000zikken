*	���������`�惋�[�v�W�J��

	.include	gconst.h
*
	.xdef	gvline
*
	.text
	.even
*
.ifdef	_1024
vloop:	move.w	d0,-$7800(a0)	*����16��
	move.w	d0,-$7000(a0)	*�@����������`��
	move.w	d0,-$6800(a0)
	move.w	d0,-$6000(a0)
	move.w	d0,-$5800(a0)
	move.w	d0,-$5000(a0)
	move.w	d0,-$4800(a0)
	move.w	d0,-$4000(a0)
	move.w	d0,-$3800(a0)
	move.w	d0,-$3000(a0)
	move.w	d0,-$2800(a0)
	move.w	d0,-$2000(a0)
	move.w	d0,-$1800(a0)
	move.w	d0,-$1000(a0)
	move.w	d0,-$0800(a0)
	move.w	d0,(a0)
	adda.l	d5,a0
.else
vloop:	move.w	d0,-$7c00(a0)	*����32��
	move.w	d0,-$7800(a0)	*�@����������`��
	move.w	d0,-$7400(a0)
	move.w	d0,-$7000(a0)
	move.w	d0,-$6c00(a0)
	move.w	d0,-$6800(a0)
	move.w	d0,-$6400(a0)
	move.w	d0,-$6000(a0)
	move.w	d0,-$5c00(a0)
	move.w	d0,-$5800(a0)
	move.w	d0,-$5400(a0)
	move.w	d0,-$5000(a0)
	move.w	d0,-$4c00(a0)
	move.w	d0,-$4800(a0)
	move.w	d0,-$4400(a0)
	move.w	d0,-$4000(a0)
	move.w	d0,-$3c00(a0)
	move.w	d0,-$3800(a0)
	move.w	d0,-$3400(a0)
	move.w	d0,-$3000(a0)
	move.w	d0,-$2c00(a0)
	move.w	d0,-$2800(a0)
	move.w	d0,-$2400(a0)
	move.w	d0,-$2000(a0)
	move.w	d0,-$1c00(a0)
	move.w	d0,-$1800(a0)
	move.w	d0,-$1400(a0)
	move.w	d0,-$1000(a0)
	move.w	d0,-$0c00(a0)
	move.w	d0,-$0800(a0)
	move.w	d0,-$0400(a0)
	move.w	d0,(a0)
	adda.l	d5,a0
.endif
gvline:	dbra	d3,vloop
	rts

	.end
