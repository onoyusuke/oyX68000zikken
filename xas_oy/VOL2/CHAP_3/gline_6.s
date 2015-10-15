*	�����`��i65536�{������Bresenham�j

	.include	gconst.h
*
	.xdef	gline
	.xref	gclipline
	.xref	gbase
*
	.offset	0	*gline�̈����\��
*
X0:	.ds.w	1	*�n�_���W
Y0:	.ds.w	1	*
X1:	.ds.w	1	*�I�_���W
Y1:	.ds.w	1	*
COL:	.ds.w	1	*�`��F
*
	.text
	.even
*
gline:
ARGPTR	=	4+8*4+6*4
	movem.l	d0-d7/a0-a5,-(sp)

	movea.l	ARGPTR(sp),a5	*a5 = ������
	movem.w	(a5)+,d0-d3	*d0�`d3�ɍ��W�����o��

	jsr	gclipline	*�N���b�s���O����
	bne	done		*Z=0�Ȃ犮�S�s��

 	cmp.w	d2,d0		*x0��x1��ۏ؂���
	ble	gline0		*
	exg.l	d0,d2		*
	exg.l	d1,d3		*

gline0:	move.w	d1,d6		*�n�_/�I�_��G-RAM�A�h���X�����߂�
	move.w	d3,d7		*
	ext.l	d6		*
	ext.l	d7		*
				*
	moveq.l	#GSFTCTR,d4	*
	asl.l	d4,d6		*
	asl.l	d4,d7		*
	add.w	d0,d6		*
	add.w	d0,d6		*
	add.w	d2,d7		*
	add.w	d2,d7		*
				*
	movea.l	gbase,a0	*
	movea.l	a0,a2		*
	add.l	d6,a0		*a0 = �n�_��G-RAM�A�h���X
	add.l	d7,a2		*a2 = �I�_��G-RAM�A�h���X

	move.w	#GNBYTE,d5	*d5 = ��1���C�����̃o�C�g��
	sub.w	d1,d3		*d3 = y1-y0
	beq	hor_line	*y0��y1�Ȃ琅����
	bpl	gline1
	neg.w	d3
	neg.w	d5
gline1:	sub.w	d0,d2		*d2 = x1-x0 ( >=0 )
	beq	ver_line	*x0��x1�Ȃ琂����
*���̎��_��
*	d2 = dx = abs(x1-x0) ( > 0 )
*	d3 = dy = abs(y1-y0) ( > 0 )
*	d5 = sy = sgn(y1-y0) ( -1 or 1 )
*	�i������d5��GNBYTE�{�ς݁j

	move.w	(a5),d0		*d0 = �`��F

	move.w	#$8000,d1	*d1 = e = -65536 * 1/2

	cmp.w	d3,d2		*dy��dx�Ȃ��
	bcs	yline		*�@y�ɂ��ă��[�v
	beq	xyline		*dy��dx�Ȃ��45�x�̐�

			*dx��dy�̂Ƃ�
xline:	swap.w	d3		*
	clr.w	d3		*d3 = 65536*dy
	divu.w	d2,d3		*d3 = 65536*dy/dx
	subq.w	#1,d2		*dbra�̓�����v�Z�ɓ����
	lsr.w	#1,d2		*�@���[�v�J�E���^�𔼌�
	scs.b	d4		*��s�N�Z���̂Ƃ���0
	addq.l	#2,a2		*�v���f�N�������g���镪�␳
				*do {
xline0:	move.w	d0,(a0)+	*  pset(x++,y)
	move.w	d0,-(a2)	*  pset(--x',y')
	add.w	d3,d1		*  e += 2*dy
	bcc	xline1		*  if (e >= 0) {
	adda.w	d5,a0		*    y += sy
	suba.w	d5,a2		*    y'-= sy
				*  }
xline1:	dbra	d2,xline0	*} while (--n >= 0)

	tst.b	d4		*��s�N�Z���H
	beq	done		*�@��������Ȃ�
	bra	odd		*�����̃s�N�Z����_��

			*dx��dy�̂Ƃ�
yline:	swap.w	d2		*
	clr.w	d2		*d2 = 65536*dx
	divu.w	d3,d2		*d2 = 65536*dx/dy
	subq.w	#1,d3		*dbra�̓�����v�Z�ɓ����
	lsr.w	#1,d3		*�@���[�v�J�E���^�𔼌�
	scs.b	d4		*��s�N�Z���̂Ƃ���0
	move.w	d5,d6		*d6 = d5 + 2
	addq.w	#2,d6		*
				*do {
yline0:	add.w	d2,d1		*  e += 2*dx
	bcs	yline1		*  if (e < 0) {
	move.w	d0,(a0)		*    pset(x,y)
	adda.w	d5,a0		*    y += sy
	move.w	d0,(a2)		*    pset(x',y')
	suba.w	d5,a2		*    y'-= sy
				*  }
	dbra	d3,yline0
	bra	done0
				*  else {
yline1:	move.w	d0,(a0)		*    pset(x++,y)
	adda.w	d6,a0		*    y += sy
	move.w	d0,(a2)		*    pset(x',y')
	suba.w	d6,a2		*    x'--, y'-= sy
				*  }
	dbra	d3,yline0	*} while (--n >= 0)

done0:	tst.b	d4		*��s�N�Z���H
	beq	done		*�@��������Ȃ�
odd:	move.w	d0,(a0)		*�����̃s�N�Z����_��

done:	movem.l	(sp)+,d0-d7/a0-a5
	rts
*
	.xref	ghline
	.xref	gvline
*
hor_line:		*��������
	sub.w	d0,d2		*d2 = dx = x1-x0
	move.w	(a5),d1		*d0.l = �`��F�i���/���ʂƂ��j
	move.w	d1,d0		*
	swap.w	d0		*
	move.w	d1,d0		*
	addq.w	#1,d2		*d2 = dx+1 = �s�N�Z����
	bclr.l	#0,d2		*
	beq	hskip		*
	move.w	d0,(a0)+	*��s�N�Z���̕�
hskip:	lea.l	ghline,a1
	suba.w	d2,a1
	jsr	(a1)
hline:	bra	done

xyline:			*45�x�̐���
	move.w	(a5),d0		*d0 = color
	addq.w	#1,d3		*d3 = dy+1
	moveq.l	#8-1,d4		*
	and.w	d3,d4		*d4 = �W�s�N�Z�������̒[��
	lsr.w	#3,d3		*d3 = (dy+1)/8
	lsl.w	#2,d4		*move��adda�łS�o�C�g
	neg.w	d4		*
	jmp	xynext(pc,d4)	*���[�v�̓r���ɔ�э���

xyloop:	move.w	d0,(a0)+	*pset(x++,y)
	adda.w	d5,a0		*y += sy
	move.w	d0,(a0)+	*pset(x++,y)
	adda.w	d5,a0		*y += sy
	move.w	d0,(a0)+	*pset(x++,y)
	adda.w	d5,a0		*y += sy
	move.w	d0,(a0)+	*pset(x++,y)
	adda.w	d5,a0		*y += sy
	move.w	d0,(a0)+	*pset(x++,y)
	adda.w	d5,a0		*y += sy
	move.w	d0,(a0)+	*pset(x++,y)
	adda.w	d5,a0		*y += sy
	move.w	d0,(a0)+	*pset(x++,y)
	adda.w	d5,a0		*y += sy
	move.w	d0,(a0)+	*pset(x++,y)
	adda.w	d5,a0		*y += sy
xynext:	dbra	d3,xyloop	*(dy+1)/8��J��Ԃ�
	bra	done

ver_line:		*��������
	tst.w	d5		*d5 = sy
	bpl	vskip		*a0 <= a2��
	movea.l	a2,a0		*�@�ۏ؂���
vskip:	move.l	#$0000_8000,d5	*long!
.ifdef	_1024	
	moveq.l	#16-1,d1	*d1 = dy%16
	and.w	d3,d1		*
	lsr.w	#4,d3		*d3 = dy/16
.else
	moveq.l	#32-1,d1	*d1 = dy%32
	and.w	d3,d1		*
	lsr.w	#5,d3		*d3 = dy/32
.endif
	move.w	d1,d2
	moveq.l	#GSFTCTR,d0
	lsl.w	d0,d2
	adda.w	d2,a0
	move.w	(a5),d0		*d0 = color
	addq.w	#1,d1
	lsl.w	#2,d1
	lea.l	gvline,a1
	suba.w	d1,a1
	jsr	(a1)
	bra	done

	.end
