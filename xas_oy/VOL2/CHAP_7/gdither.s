*	�I�[�_�[�h�f�B�U�ɂ��K���𗎂Ƃ�

DERGB_BREAK_HIGHWORD	=	1
	.include	gconst.h
	.include	gmacro.h
*
	.xdef	gdither
	.xref	gramadr
	.xref	gcliprect
	.xref	dithermatrix
*
MATSIZ	equ	8	*�f�B�U�}�g���N�X�̑傫��
*
	.offset	0	*gdither�̈����\��
*
X0:	.ds.w	1	*��`���W
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
NBIT:	.ds.w	1	*�ϊ����RGB���Ƃ̃r�b�g���i1�`5�j
SCL:	.ds.w	1	*�f�B�U�}�g���N�X�̏d�݂̋t���i��l�Q^NBIT�j
*
	.text
	.even
*
gdither:
ARGPTR	=	8
	link	a6,#0
	movem.l	d0-d7/a0-a4,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = ������
	movem.w	(a1)+,d0-d3	*d0�`d3�ɍ��W�����o��

	jsr	gcliprect	*�N���b�s���O����
	bmi	done		*N=1�Ȃ�`��̕K�v�Ȃ�

	jsr	gramadr		*G-RAM��̃A�h���X�𓾂�

	sub.w	d0,d2		*d2 = ���s�N�Z����-1
	sub.w	d1,d3		*d3 = �c�s�N�Z����-1
	lsl.w	#3,d1

	move.w	(a1)+,d4	*���Ƃ��K���ɉ�����
	subq.w	#1,d4		*�@�X�P�[�����O�p�̃e�[�u���𓾂�
	bmi	done		*
	cmpi.w	#5+1,d4		*
	bcc	done		*
	lsl.w	#5,d4		*
	lea.l	ctbl(pc),a4	*
	adda.w	d4,a4		*

	swap.w	d3		*d3 = �}�g���N�X�̏d�݂̋t��
	move.w	(a1),d3		*
	beq	done		*
	swap.w	d3		*

	lea.l	dithermatrix,a2
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
	_DERGB	d5,d6,d7	*RGB�ɕ�������
	mulu.w	d3,d5		*�K���ȏd�݂��|����
	mulu.w	d3,d6		*
	mulu.w	d3,d7		*

	andi.w	#MATSIZ-1,d0	*d0 = �f�B�U�}�g���N�X�̗�C���f�b�N�X
	move.b	(a3,d0.w),d2	*d2 = ���Z����k������
	ext.w	d2		*

	add.w	d2,d5		*RGB���Ƃɐk��������������
	add.w	d2,d6		*
	add.w	d2,d7		*

	clr.w	d1		*�ŏ��P�x�ȏ��ۏ�
	MAX	d1,d5		*
	MAX	d1,d6		*
	MAX	d1,d7		*

	divu.w	d3,d5		*RGB32�K���ɍĕϊ�
	divu.w	d3,d6		*
	divu.w	d3,d7		*

	move.w	#RGBMAX,d1	*�ő�P�x�ȉ���ۏ�
	MIN	d1,d5		*
	MIN	d1,d6		*
	MIN	d1,d7		*

	move.b	(a4,d5.w),d5	*�K���ɉ����ăX�P�[�����O
	move.b	(a4,d6.w),d6	*
	move.b	(a4,d7.w),d7	*

	_RGB	d5,d6,d7	*�J���[�R�[�h�ɍč\��
	move.w	d7,(a1)+	*��������

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

done:	movem.l	(sp)+,d0-d7/a0-a4
	unlk	a6
	rts
*
ctbl:	.dc.b	00,00,00,00,00,00,00,00	*RGB�e�Q�K��
	.dc.b	00,00,00,00,00,00,00,00
	.dc.b	31,31,31,31,31,31,31,31
	.dc.b	31,31,31,31,31,31,31,31
*
	.dc.b	00,00,00,00,00,00,00,00	*RGB�e�S�K��
	.dc.b	10,10,10,10,10,10,10,10
	.dc.b	21,21,21,21,21,21,21,21
	.dc.b	31,31,31,31,31,31,31,31
*
	.dc.b	00,00,00,00,04,04,04,04	*RGB�e�W�K��
	.dc.b	09,09,09,09,13,13,13,13
	.dc.b	18,18,18,18,22,22,22,22
	.dc.b	27,27,27,27,31,31,31,31
*
	.dc.b	00,00,02,02,04,04,06,06	*RGB�e16�K��
	.dc.b	08,08,10,10,12,12,14,14
	.dc.b	17,17,19,19,21,21,23,23
	.dc.b	25,25,27,27,29,29,31,31
*
	.dc.b	00,01,02,03,04,05,06,07	*RGB�e32�K��
	.dc.b	08,09,10,11,12,13,14,15
	.dc.b	16,17,18,19,20,21,22,23
	.dc.b	24,25,26,27,28,29,30,31

	.end
