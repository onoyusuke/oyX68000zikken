*	G-RAM�փO���t�B�b�N�p�^�[������������

	.include	gconst.h
	.include	gmacro.h
*
	.xdef	gput
	.xref	gramadr
	.xref	gcliprect
	.xref	gcopyline_L
*
	.offset	0	*gput�̈����\��
*
X0:	.ds.w	1	*�`�����W
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
PAT:	.ds.l	1	*�p�^�[��
*
	.text
	.even
*
gput:
ARGPTR	=	8
	link	a6,#0
	movem.l	d0-d7/a0-a3,-(sp)

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

	movea.l	PAT(a1),a1	*a1 = �p�^�[���f�[�^
	add.w	d0,d0		*�N���b�s���O����������
	adda.w	d0,a1		*
	add.w	d1,d1		*
	mulu.w	d6,d1		*
	adda.l	d1,a1		*�@�p�^�[���f�[�^���΂�

	addq.w	#1,d2		*d2 = ���s�N�Z����
	sub.w	d2,d6		*d6 = �X�L�b�v����s�N�Z����
	add.w	d6,d6		*d6 = �X�L�b�v����o�C�g��

	lea.l	next(pc),a2	*
	bclr.l	#0,d2		*���s�N�Z�����͊���H
	beq	skip		*
	lea.l	odd(pc),a2	*��s�N�Z���̂Ƃ�

skip:	lea.l	gcopyline_L,a3	*a3 = �P���C�����̓]�����[�`��
	suba.w	d2,a3		*

	move.w	#GNBYTE,d1	*d1 = ���C���Ԃ̃A�h���X�̍�
	add.w	d2,d2		*
	sub.w	d2,d1		*

loop:	jsr	(a3)		*�P���C���]��
	jmp	(a2)		*
odd:	move.w	(a1)+,(a0)	*��s�N�Z���̏ꍇ
next:	adda.w	d1,a0		*�������̃��C����
	adda.w	d6,a1		*�N���b�s���O������
				*�@�p�^�[�����΂�
	dbra	d3,loop		*�������J��Ԃ�

done:	movem.l	(sp)+,d0-d7/a0-a3
	unlk	a6
	rts

	.end
