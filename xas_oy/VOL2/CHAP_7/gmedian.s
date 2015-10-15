*	�������i�����l�t�B���^�j

	.include	gconst.h
	.include	gmacro.h
*
	.xdef	gmedian
	.xref	gramadr
	.xref	gcliprect
*
DR	equ	2	*�E�̓_�Ƃ̃A�h���X�̍�
DD	equ	GNBYTE	*���̓_�Ƃ̃A�h���X�̍�
*
	.offset	0	*gmedian�̈����\��
*
X0:	.ds.w	1	*��`���W
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
*
	.offset	0	*�T�s�N�Z�����̍�Ɨp�o�b�t�@
*
C:	.ds.w	1	*���S
L:	.ds.w	1	*��
U:	.ds.w	1	*��
R:	.ds.w	1	*�E
D:	.ds.w	1	*��
PBUFSIZ:
*
	.offset	-GNBYTE-PBUFSIZ	*�X�^�b�N�t���[��
*
WORKTOP:
PBUF:	.ds.b	PBUFSIZ	*�T�s�N�Z�����̍�Ɨp�o�b�t�@
LBUF:	.ds.b	GNBYTE	*�P���C�����̃o�b�t�@
_a6:	.ds.l	1	*�}0
_pc:	.ds.l	1
ARGPTR:	.ds.l	1
*
	.text
	.even
*
gmedian:
	link	a6,#WORKTOP
	movem.l	d0-d7/a0-a2,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = ������
	movem.w	(a1),d0-d3	*d0�`d3�ɍ��W�����o��

	jsr	gcliprect	*�N���b�s���O����
	bne	done		*Z=0�Ȃ�`��̕K�v�Ȃ�

	jsr	gramadr		*G-RAM��̃A�h���X�𓾂�

	sub.w	d0,d2		*d2 = ���s�N�Z����-1
	sub.w	d1,d3		*d3 = �c�s�N�Z����-1

	move.w	#GNBYTE-2,d1	*d1 = ���C���Ԃ̃A�h���X�̍�
	sub.w	d2,d1		*�i�E�[���牺�̃��C���̍��[�܂Łj
	sub.w	d2,d1		*

	movea.l	a0,a1		*��ԏ�̃��C����
	lea.l	LBUF(a6),a2	*�@�o�b�t�@�ɃR�s�[���Ă���
	move.w	d2,d4		*
loop0:	move.w	(a1)+,(a2)+	*
	dbra	d4,loop0	*

	subq.w	#1,d2		*d2 = ���s�N�Z����-1-1
	bmi	done
	subq.w	#1,d3		*d3 = �c�s�N�Z����-1-1
	bmi	done

	lea.l	PBUF(a6),a1
loop1:	move.w	d2,d4		*d4 = ���s�N�Z����-1-1
	lea.l	LBUF(a6),a2	*a2 = �P���C���̃o�b�t�@
	move.w	(a0),L(a1)	*���[�̂�(x-1,y)�̑����(x,y)
loop2:	move.w	(a0),C(a1)	*(x,y)
	move.w	(a2),U(a1)	*(x,y-1)
	move.w	DR(a0),R(a1)	*(x+1,y)
	move.w	DD(a0),D(a1)	*(x,y+1)
	bsr	gsub		*�F���������킹��
	move.w	(a0),(a2)+	*���̃��C���p�Ɋo���Ă���
	move.w	(a0),L(a1)	*(x-1,y)
	move.w	d0,(a0)+	*�P�s�N�Z����������
	dbra	d4,loop2	*x1-x0-1��J��Ԃ�

			*�E�[�̏���
	move.w	(a0),C(a1)	*(x,y)
	move.w	(a2),U(a1)	*(x,y-1)
	move.w	(a0),R(a1)	*(x+1,y)�̑����(x,y)
	move.w	DD(a0),D(a1)	*(x,y+1)
	bsr	gsub		*�F���������킹��
	move.w	(a0),(a2)+	*���̃��C���p�Ɋo���Ă���
	move.w	d0,(a0)+	*�P�s�N�Z����������

	adda.w	d1,a0		*�������̃��C����
	dbra	d3,loop1	*y1-y0-1��J��Ԃ�

			*�ŉ����C���̏���
	move.w	d2,d4		*d4 = ���s�N�Z����-2
	lea.l	LBUF(a6),a2	*a2 = �P���C���̃o�b�t�@
	move.w	(a0),L(a1)	*���[�̂�
				*(x-1,y)�̑����(x,y)
loop3:	move.w	(a0),C(a1)	*(x,y)
	move.w	(a2)+,U(a1)	*(x,y-1)
	move.w	DR(a0),R(a1)	*(x+1,y)
	move.w	(a0),D(a1)	*(x,y+1)�̑����(x,y)
	bsr	gsub		*�F���������킹��
	move.w	(a0),L(a1)	*(x-1,y)
	move.w	d0,(a0)+	*�P�s�N�Z����������
	dbra	d4,loop3	*x1-x0-1��J��Ԃ�

			*�E�����̏���
	move.w	(a0),C(a1)	*(x,y)
	move.w	(a2),U(a1)	*(x,y-1)
	move.w	(a0),R(a1)	*(x+1,y)�̑����(x,y)
	move.w	(a0),D(a1)	*(x,y+1)�̑����(x,y)
	bsr	gsub		*�F���������킹��
	move.w	d0,(a0)		*�P�s�N�Z����������

done:	movem.l	(sp)+,d0-d7/a0-a2
	unlk	a6
	rts
*
gsub:	movem.l	d1-d4/a0-a1,-(sp)
	lea.l	-PBUFSIZ*3(sp),sp

	movea.l	sp,a0
	moveq.l	#5-1,d4
gloop:	move.w	(a1)+,d0	*���S�̓_
	DERGB	d0,d5,d6,d7	*RGB�ɕ���
	move.w	d5,PBUFSIZ*2(a0)	*g
	move.w	d6,PBUFSIZ(a0)		*r
	move.w	d7,(a0)+		*b
	dbra	d4,gloop

	movea.l	sp,a0
	moveq.l	#0,d0
	bsr	median
	lsl.w	#5,d0
	bsr	median
	lsl.w	#5,d0
	bsr	median
	add.w	d0,d0

	lea.l	PBUFSIZ*3(sp),sp
	movem.l	(sp)+,d1-d4/a0-a1
	rts
*
median:
	movem.w	(a0)+,d1-d5
	MINMAX	d1,d2
	MINMAX	d1,d3
	MINMAX	d1,d4
	MINMAX	d1,d5	
	MINMAX	d2,d3
	MINMAX	d2,d4
	MINMAX	d2,d5
	MINMAX	d3,d4
	MINMAX	d3,d5
	or.w	d3,d0
	rts

	.end
