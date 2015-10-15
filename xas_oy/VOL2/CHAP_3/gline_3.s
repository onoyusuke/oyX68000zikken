*	�����`��i������Bresenham�{���[�`��j

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

	cmp.w	d3,d2		*dy��dx�Ȃ��
	bcs	yline		*�@y�ɂ��ă��[�v
	beq	xyline		*dy��dx�Ȃ��45�x�̐�

			*dx��dy�̂Ƃ�
xline:	move.w	d2,d1		*d1 = dx
	neg.w	d1		*d1 = e = -dx
	move.w	d2,d6		*d6 = n = dx
	add.w	d2,d2		*d2 = 2*dx
	add.w	d3,d3		*d3 = 2*dy
	subq.w	#1,d6		*dbra�̓�����v�Z�ɓ����
	lsr.w	#1,d6		*�@���[�v�J�E���^�𔼌�
	scs.b	d4		*��s�N�Z���̂Ƃ���0
	addq.l	#2,a2		*�v���f�N�������g���镪�␳
				*do {
xline0:	move.w	d0,(a0)+	*  pset(x++,y)
	move.w	d0,-(a2)	*  pset(--x',y')
	add.w	d3,d1		*  e += 2*dy
	bmi	xline1		*  if (e >= 0) {
	adda.w	d5,a0		*    y += sy
	suba.w	d5,a2		*    y'-= sy
	sub.w	d2,d1		*    e -= 2*dx
				*  }
xline1:	dbra	d6,xline0	*} while (--n >= 0)

	tst.b	d4		*��s�N�Z���H
	beq	done		*�@��������Ȃ�
	bra	odd		*�����̃s�N�Z����_��

			*dx��dy�̂Ƃ�
yline:	move.w	d3,d1		*d1 = dy
	neg.w	d1		*d1 = e = -dy
	move.w	d3,d6		*d6 = n = dy
	add.w	d2,d2		*d2 = 2*dx
	add.w	d3,d3		*d3 = 2*dy
	subq.w	#1,d6		*dbra�̂��Ƃ��v�Z�ɓ����
	lsr.w	#1,d6		*�@���[�v�J�E���^�𔼌�
	scs.b	d4		*��s�N�Z���̂Ƃ���0
	move.w	d5,d7		*d7 = d5 + 2
	addq.w	#2,d7		*
				*do {
yline0:	add.w	d2,d1		*  e += 2*dx
	bpl	yline1		*  if (e < 0) {
	move.w	d0,(a0)		*    pset(x,y)
	adda.w	d5,a0		*    y += sy
	move.w	d0,(a2)		*    pset(x',y')
	suba.w	d5,a2		*    y'-= sy
				*  }
	dbra	d6,yline0
	bra	done0
				*  else {
yline1:	move.w	d0,(a0)+	*    pset(x++,y)
	adda.w	d5,a0		*    y += sy
	move.w	d0,(a2)		*    pset(x',y')
	suba.w	d7,a2		*    x'--, y'-= sy
	sub.w	d3,d1		*    e -= 2*dy
				*  }
	dbra	d6,yline0	*} while (--n >= 0)

done0:	tst.b	d4		*��s�N�Z���H
	beq	done		*�@��������Ȃ�
odd:	move.w	d0,(a0)		*�����̃s�N�Z����_��

done:	movem.l	(sp)+,d0-d7/a0-a5
	rts
*
hor_line:		*��������
	sub.w	d0,d2		*d2 = dx = x1-x0
	move.w	(a5),d0		*d0 = �`��F
hloop:	move.w	d0,(a0)+	*pset(x++,y)
	dbra	d2,hloop
	bra	done

xyline:			*45�x�̐���
	addq.w	#2,d5		*d5 = 2�}GNBYTE
ver_line:		*��������
	move.w	(a5),d0		*d0 = �`��F
vloop:	move.w	d0,(a0)		*pset(x,y)
	adda.w	d5,a0		*y += sx
	dbra	d3,vloop	*dy+1��J��Ԃ�
	bra	done

	.end
