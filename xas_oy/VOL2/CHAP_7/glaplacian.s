*	���������i���v���V�A���j

DERGB_BREAK_HIGHWORD	=	1
	.include	gconst.h
	.include	gmacro.h
*
	.xdef	glaplacian
	.xref	gramadr
	.xref	gcliprect
	.xref	grayscale
*
DR	equ	2	*�E�̓_�Ƃ̃A�h���X�̍�
DD	equ	GNBYTE	*���̓_�Ƃ̃A�h���X�̍�
*
	.offset	0	*glaplacian�̈����\��
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
glaplacian:
	link	a6,#WORKTOP
	movem.l	d0-d7/a0-a5,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = ������
	movem.w	(a1),d0-d3	*d0�`d3�ɍ��W�����o��

	jsr	gcliprect	*�N���b�s���O����
	bne	done		*Z=0�Ȃ�`��̕K�v�Ȃ�

	jsr	gramadr		*G-RAM��̃A�h���X�𓾂�

	sub.w	d0,d2		*d2 = ���s�N�Z����-1
	sub.w	d1,d3		*d3 = �c�s�N�Z����-1

	lea.l	GNBYTE-2.w,a5	*a5 = ���C���Ԃ̃A�h���X�̍�
	suba.w	d2,a5		*�i�E�[���牺�̃��C���̍��[�܂Łj
	suba.w	d2,a5		*

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
	lea.l	grayscale,a3
	RGBtoYx_INIT	a4
loop1:	move.w	d2,d4		*d4 = ���s�N�Z����-1-1
	swap.w	d2
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

	adda.l	a5,a0		*�������̃��C����
	swap.w	d2
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

done:	movem.l	(sp)+,d0-d7/a0-a5
	unlk	a6
	rts
*
gsub:
	move.w	(a1)+,d7	*���S�̓_
	_DERGB	d5,d6,d7	*RGB�ɕ�����
	RGBtoYx	d5,d6,d7,d2	*�@�P�xIc�𓾂�

	lsl.w	#2,d2		*���̂S�{����
	moveq.l	#4-1,d0		*�@���͂̂S�_�̋P�x��������
sublp:	move.w	(a1)+,d7	*
	_DERGB	d5,d6,d7	*
	RGBtoYx	d5,d6,d7,d1	*
	sub.w	d1,d2		*
	dbra	d0,sublp	*

	addi.w	#RGBMAX*4,d2	*-31*4�`+31*4��
	lsr.w	#3,d2		*�@0�`31�ɕϊ�
	add.w	d2,d2		*�Ή�����D�F��
	move.w	(a3,d2.w),d0	*�@�J���[�R�[�h�ɒu��������
	lea.l	-PBUFSIZ(a1),a1
	rts

	.end
