*	�N�s���i���v���V�A�����Ƃ̍����j

DERGB_BREAK_HIGHWORD	=	1
	.include	gconst.h
	.include	gmacro.h
*
	.xdef	gsharp
	.xref	gramadr
	.xref	gcliprect
*
DR	equ	2	*�E�̓_�Ƃ̃A�h���X�̍�
DD	equ	GNBYTE	*���̓_�Ƃ̃A�h���X�̍�
*
	.offset	0	*gsharp�̈����\��
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
gsharp:
	link	a6,#WORKTOP
	movem.l	d0-d7/a0-a3,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = ������
	movem.w	(a1),d0-d3	*d0�`d3�ɍ��W�����o��

	jsr	gcliprect	*�N���b�s���O����
	bne	done		*Z=0�Ȃ�`��̕K�v�Ȃ�

	jsr	gramadr		*G-RAM��̃A�h���X�𓾂�

	sub.w	d0,d2		*d2 = ���s�N�Z����-1
	sub.w	d1,d3		*d3 = �c�s�N�Z����-1

	lea.l	GNBYTE-2.w,a3	*a3 = ���C���Ԃ̃A�h���X�̍�
	sub.w	d2,a3		*�i�E�[���牺�̃��C���̍��[�܂Łj
	sub.w	d2,a3		*

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
	swap.w	d2
	swap.w	d3
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

	adda.l	a3,a0		*�������̃��C����
	swap.w	d3
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

done:	movem.l	(sp)+,d0-d7/a0-a2
	unlk	a6
	rts
*
gsub:
	move.w	(a1)+,d0	*���S�̓_
	_DERGB	d1,d2,d0	*RGB���ƂɂW�{
	lsl.w	#3,d1		*
	lsl.w	#3,d2		*
	lsl.w	#3,d0		*

	moveq.l	#4-1,d7		*���͂̂S�_�̐F��
sublp:	move.w	(a1)+,d3	*�@RGB���ƂɌ�����
	_DERGB	d5,d6,d3	*
	sub.w	d5,d1		*
	sub.w	d6,d2		*
	sub.w	d3,d0		*
	dbra	d7,sublp	*

	moveq.l	#0,d7		*�ŏ��P�x�ȏ��ۏ�
	MAX	d7,d1		*
	MAX	d7,d2		*
	MAX	d7,d0		*

	addq.w	#2,d1		*�l�̌ܓ����S�Ŋ���
	lsr.w	#2,d1		*
	addq.w	#2,d2		*
	lsr.w	#2,d2		*
	addq.w	#2,d0		*
	lsr.w	#2,d0		*

	moveq.l	#RGBMAX,d7	*�ő�P�x�ȉ���ۏ�
	MIN	d7,d1		*
	MIN	d7,d2		*
	MIN	d7,d0		*

	_RGB	d1,d2,d0	*�J���[�R�[�h�ɍč\��
	lea.l	-PBUFSIZ(a1),a1
	rts

	.end
