*	�F���]�i��F�ւ̒u���j

	.xdef	gnegate
	.xref	gxorcolor
*
	.offset	0	*gnegate�̈����\��
*
X0:	.ds.w	1	*��`���W
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
*
	.text
	.even
*
gnegate:
ARGPTR	=	8+4
	move.l a1,-(sp)
	link	a6,#0

	movea.l	ARGPTR(a6),a1	*a1 = ������
	move.w	#$ffff,-(sp)	*�`��F = ffffh
	move.l	4(a1),-(sp)	*(x1,y1)
	move.l	(a1),-(sp)	*(x0,y0)
	pea.l	(sp)		*gxorcolor�ւ̈�����
	jsr	gxorcolor

	unlk	a6
	movea.l	(sp)+,a1
	rts

	.end
