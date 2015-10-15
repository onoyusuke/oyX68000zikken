*	32768�F��256�F�ϊ�

	.include	gconst.h
	.include	gmacro.h
*
MATSIZ	equ	8	*�f�B�U�}�g���N�X�̑傫��
*
	.xdef	gltom
	.xref	gramadr
	.xref	gcliprect
	.xref	dithermatrix
*
	.offset	0	*gltom�̈����\��
*
X0:	.ds.w	1	*��`���W
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
*
	.text
	.even
*
gltom:
ARGPTR	=	8
	link	a6,#0
	movem.l	d0-d7/a0-a3,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = ������
	movem.w	(a1),d0-d3	*d0�`d3�ɍ��W�����o��

	jsr	gcliprect	*�N���b�s���O����
	bmi	done		*N=1�Ȃ�`��̕K�v�Ȃ�

	jsr	gramadr		*G-RAM��̃A�h���X�𓾂�

	sub.w	d0,d2		*d2 = ���s�N�Z����-1
	sub.w	d1,d3		*d3 = �c�s�N�Z����-1
	lsl.w	#3,d1

	lea.l	dithermatrix,a2
	move.w	d0,d4		*d4 = ���[x���W
loop1:	movea.l	a0,a1		*a1 = ���C�����[
	andi.w	#(MATSIZ-1)*MATSIZ,d1
				*d1 = �f�B�U�}�g���N�X�̍s�C���f�b�N�X
	lea.l	0(a2,d1),a3	*a3 = �f�B�U�}�g���N�X�̍s

	swap.w	d4
	move.w	d2,d4		*d4 = ���s�N�Z����-1
	swap.w	d1
	swap.w	d2
loop2:	move.w	(a1),d1		*�P�s�N�Z�����o��
	DERGB	d1,d5,d6,d7	*RGB�ɕ�������
	lsl.w	#4,d5		*RGB512�K���ɕϊ�����
	lsl.w	#4,d6		*
	lsl.w	#4,d7		*

	andi.w	#MATSIZ-1,d0	*d0 = �f�B�U�}�g���N�X�̗�C���f�b�N�X
	move.b	0(a3,d0),d2	*d2 = ���Z����k������
	ext.w	d2		*

	add.w	d2,d5		*RGB���Ƃɐk��������������
	add.w	d2,d6		*
	add.w	d2,d7		*

	clr.w	d1		*�ŏ��P�x�ȏ��ۏ�
	MAX	d1,d5		*
	MAX	d1,d6		*
	MAX	d1,d7		*

	move.w	#RGBMAX*16,d1	*�ő�P�x�ȉ���ۏ�
	MIN	d1,d5		*
	MIN	d1,d6		*
	MIN	d1,d7		*

	lsr.w	#6,d5		*���ʃr�b�g��؂�̂Ă�
	lsr.w	#6,d6		*
	lsr.w	#7,d7		*

	move.w	d7,d1		*256�F���[�h�̃p���b�g�R�[�h
	lsl.w	#3,d1		*�@�ɍ\������
	or.w	d6,d1		*
	lsl.w	#3,d1		*
	or.w	d5,d1		*

	move.w	d1,(a1)+	*��������

	addq.w	#1,d0		*�f�B�U�}�g���N�X�̗��i�߂�
	dbra	d4,loop2	*�������J��Ԃ�

	swap.w	d1
	swap.w	d2
	swap.w	d4
	move.w	d4,d0		*�f�B�U�}�g���N�X��C���f�b�N�X�����Z�b�g
	addq.w	#MATSIZ,d1	*�f�B�U�}�g���N�X�̍s��i�߂�
	lea.l	GNBYTE(a0),a0	*�������̃��C����
	dbra	d3,loop1	*�������J��Ԃ�

done:	movem.l	(sp)+,d0-d7/a0-a3
	unlk	a6
	rts

	.end
