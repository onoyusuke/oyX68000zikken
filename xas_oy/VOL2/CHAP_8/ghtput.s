*	G-RAM�փO���t�B�b�N�p�^�[�����������ށi�������j

	.include	gconst.h
	.include	gmacro.h
*
	.xdef	ghalftoneput
	.xref	gramadr
	.xref	gcliprect
*
	.offset	0	*ghalftoneput�̈����\��
*
X0:	.ds.w	1	*��`�̈�
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
PAT:	.ds.l	1	*�p�^�[��
*COL:	.ds.w	1
*
	.text
	.even
*
ghalftoneput:
ARGPTR	=	8
	link	a6,#0
	movem.l	d0-d7/a0-a1,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = ������
	movem.w	(a1),d0-d3	*d0�`d3�ɍ��W�����o��

	jsr	gcliprect	*�N���b�s���O����
	bmi	done		*N=1�Ȃ�`��̕K�v�Ȃ�

	jsr	gramadr		*�����G-RAM��̃A�h���X�𓾂�

	sub.w	d0,d2		*d2 = ���s�N�Z����-1
	sub.w	d1,d3		*d3 = �c�s�N�Z����-1

	movem.w	(a1),d4-d7	*d4�`d7�ɂ����W�����o��
	MINMAX	d4,d6		*d4��d6��ۏ�
	MINMAX	d5,d7		*d5��d7��ۏ�

	sub.w	d4,d0		*d0 = �؂���ꂽ���[�s�N�Z����
	sub.w	d5,d1		*d1 = �؂���ꂽ��[�s�N�Z����

	sub.w	d4,d6		*d6 = ���̃p�^�[���̉��s�N�Z����-1
	addq.w	#1,d6		*d6 = ���̃p�^�[���̉��s�N�Z����

*move.w	COL(a1),d5	*d5 = �����F
	movea.l	PAT(a1),a1	*a1 = �p�^�[���擪�A�h���X
	add.w	d0,d0		*�N���b�s���O����������
	adda.w	d0,a1		*
	add.w	d1,d1		*
	mulu.w	d6,d1		*
	adda.l	d1,a1		*�@�p�^�[�����΂�

	sub.w	d2,d6		*
	subq.w	#1,d6		*
	add.w	d6,d6		*d6 = �X�L�b�v����o�C�g��

	move.w	#GNBYTE-2,d1	*d1 = ���C���Ԃ̃A�h���X�̍�
	sub.w	d2,d1		*
	sub.w	d2,d1		*

	move.w	d6,d0		*d0 = �X�L�b�v����o�C�g��

loop1:	move.w	d2,d4		*d4 = ���s�N�Z����-1
	swap.w	d0
	swap.w	d1
	swap.w	d2
	swap.w	d3
loop2:	move.w	(a1)+,d0	*�p�^�[��������P�s�N�Z��
	DERGB	d0,d1,d2,d3	*�@RGB�ɕ�������
	move.w	(a0),d0		*��ʂ�����P�s�N�Z��
	DERGB	d0,d5,d6,d7	*�@RGB�ɕ�������
	MEAN	d5,d1		*RGB���Ƃɕ��ς�����
	MEAN	d6,d2		*
	MEAN	d7,d3		*
	RGB	d1,d2,d3,d0	*�@�J���[�R�[�h�ɍč\������
	move.w	d0,(a0)+	*�@��������
	dbra	d4,loop2	*�������J��Ԃ�

	swap.w	d0
	swap.w	d1
	swap.w	d2
	swap.w	d3
	adda.w	d1,a0		*���̃��C����
	adda.w	d0,a1		*�N���b�s���O�������p�^�[�����΂�
	dbra	d3,loop1	*���C�������J��Ԃ�

done:	movem.l	(sp)+,d0-d7/a0-a1
	unlk	a6
	rts

	.end

�C������

92-01-01��
�N���b�s���O�ɐ������Ή��ł��Ă��Ȃ������̂��C��

92-02-01��
�C����{���ɔ��f�����邽�߂ɍs���𒲐߁i���e�̕ω��Ȃ��j
