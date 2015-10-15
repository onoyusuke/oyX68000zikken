*	�I�[�_�[�h�f�B�U�ɂ��Q�l��

	.include	gconst.h
	.include	gmacro.h
*
MATSIZ	equ	8	*�f�B�U�}�g���N�X�̑傫��
*
	.xdef	gdither_bin
	.xref	gramadr
	.xref	gcliprect
	.xref	dithermatrix
*
	.offset	0	*gdither_bin�̈����\��
*
X0:	.ds.w	1	*��`���W
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
T:	.ds.w	1	*�������l�i��l64�j
*
	.text
	.even
*
gdither_bin:
ARGPTR	=	8
	link	a6,#0
	movem.l	d0-d7/a0-a5,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = ������
	movem.w	(a1),d0-d3	*d0�`d3�ɍ��W�����o��

	jsr	gcliprect	*�N���b�s���O����
	bmi	done		*N=1�Ȃ�`��̕K�v�Ȃ�

	jsr	gramadr		*G-RAM��̃A�h���X�𓾂�

	sub.w	d0,d2		*d2 = ���s�N�Z����-1
	sub.w	d1,d3		*d3 = �c�s�N�Z����-1
	lsl.w	#3,d1

	swap.w	d3		*d3 = �}�g���N�X�̏d��
	move.w	T(a1),d3	*
	swap.w	d3		*

	lea.l	dithermatrix,a2
	RGBtoYx_INIT	a5
	move.w	d0,d4		*d4 = ���[x���W
loop1:	movea.l	a0,a1		*a1 = ���C�����[
	andi.w	#(MATSIZ-1)*MATSIZ,d1
				*d1 = �f�B�U�}�g���N�X�̍s�C���f�b�N�X
	lea.l	(a2,d1.w),a3	*a3 = �f�B�U�}�g���N�X�̍s

	swap.w	d4
	move.w	d2,d4		*d4 = ���s�N�Z����-1
	swap.w	d1
	swap.w	d2
	swap.w	d3
loop2:	move.w	(a1),d7		*�P�s�N�Z�����o��
	DERGB	d7,d1,d5,d6	*RGB�ɕ�������
	RGBtoYx	d1,d5,d6,d7	*���邳�����߂�
	lsl.w	#2,d7		*128�K���ɕϊ�

	andi.w	#MATSIZ-1,d0	*d0 = �f�B�U�}�g���N�X�̗�C���f�b�N�X
	move.b	(a3,d0.w),d2	*d2 = ���Z����k������
	ext.w	d2		*

	add.w	d2,d7		*�k��������������

	clr.w	d1		*rgb(0,0,0)
	cmp.w	d3,d7		*�������l�����H
	blt	skip		*
	move.w	#$fffe,d1	*rgb(1,1,1)

skip:	move.w	d1,(a1)+	*��������

	addq.w	#1,d0		*�f�B�U�}�g���N�X�̗��i�߂�
	dbra	d4,loop2	*�������J��Ԃ�

	swap.w	d1
	swap.w	d2
	swap.w	d3
	swap.w	d4
	move.w	d4,d0		*�f�B�U�}�g���N�X��C���f�b�N�X�����Z�b�g
	addq.w	#MATSIZ,d1	*�f�B�U�}�g���N�X�̍s��i�߂�
	lea.l	GNBYTE(a0),a0	*�������̃��C����
	dbra	d3,loop1	*�������J��Ԃ�

done:	movem.l	(sp)+,d0-d7/a0-a5
	unlk	a6
	rts

	.end
