*	�����`��i������Bresenham�{�኱�̍œK���j

	.include	gconst.h
*
	.xdef	gline
	.xref	gramadr
	.xref	gclipline
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

gline0:	jsr	gramadr		*�n�_��G-RAM�A�h���X�𓾂�

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
	add.w	d2,d2		*d2 = dx*2
	add.w	d3,d3		*d3 = dy*2
				*do {
xline0:	move.w	d0,(a0)+	*  pset(x++,y)
	add.w	d3,d1		*  e += 2*dy
	bmi	xline1		*  if (e >= 0) {
	adda.w	d5,a0		*    y += sy
	sub.w	d2,d1		*    e -= 2*dx
				*  }
xline1:	dbra	d6,xline0	*} while (--n >= 0)
	bra	done

			*dx��dy�̂Ƃ�
yline:	move.w	d3,d1		*d1 = dy
	neg.w	d1		*d1 = e = -dy
	move.w	d3,d6		*d6 = n = dy
	add.w	d2,d2		*d2 = dx*2
	add.w	d3,d3		*d3 = dy*2
				*do {
yline0:	add.w	d2,d1		*  e += 2*dx
	bpl	yline1		*  if (e < 0) {
	move.w	d0,(a0)		*    pset(x,y)
	adda.w	d5,a0		*    y += sy
				*  }
	dbra	d6,yline0
	bra	done
				*  else {
yline1:	move.w	d0,(a0)+	*    pset(x++,y)
	adda.w	d5,a0		*    y += sy
	sub.w	d3,d1		*    e -= 2*dy
				*  }
	dbra	d6,yline0	*} while (--n >= 0)

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
