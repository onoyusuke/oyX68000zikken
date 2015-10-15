*	G-RAM�փO���t�B�b�N�p�^�[�����������ށi�d�ˍ��킹�j

	.include	gconst.h
	.include	gmacro.h
*
	.xdef	gputon
	.xref	gramadr
	.xref	gcliprect
*
	.offset	0	*gputon�̈����\��
*
X0:	.ds.w	1	*�`�����W
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
PAT:	.ds.l	1	*�p�^�[��
COL:	.ds.w	1	*�����F
*
	.text
	.even
*
gputon:
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

	move.w	COL(a1),d5	*d5 = �����F
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

loop1:	move.w	d2,d4		*d4 = ���s�N�Z����-1
loop2:	move.w	(a1)+,d0	*�p�^�[�����P�s�N�Z�����o��
	cmp.w	d0,d5		*�����F�H
	bne	skip		*�@�����łȂ����
	move.w	(a0),d0		*�_�~�[

skip:	move.w	d0,(a0)+	*�P�s�N�Z����������
	dbra	d4,loop2	*�������J��Ԃ�

	adda.w	d1,a0		*�������̃��C����
	adda.w	d6,a1		*�N���b�s���O������
				*�@�p�^�[�����΂�
	dbra	d3,loop1	*�������J��Ԃ�

done:	movem.l	(sp)+,d0-d7/a0-a1
	unlk	a6
	rts

	.end
