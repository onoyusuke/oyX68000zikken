*	G-RAM����O���t�B�b�N�p�^�[������荞��

	.include	gconst.h
*
	.xdef	gget
	.xref	gramadr
	.xref	gcliprect
	.xref	gcopyline_L
*
	.offset	0	*gget�̈����\��
*
X0:	.ds.w	1	*��荞�ދ�`���W
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
BUF:	.ds.l	1	*�p�^�[����荞�ݗp�o�b�t�@
*
	.text
	.even
*
gget:
ARGPTR	=	8
	link	a6,#0
	movem.l	d0-d3/a0-a3,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = ������
	movem.w	(a1),d0-d3	*d0�`d3�ɍ��W�����o��

	jsr	gcliprect	*�N���b�s���O����
	bmi	done		*N=1�Ȃ�]���̕K�v�Ȃ�

	jsr	gramadr		*�����G-RAM��̃A�h���X�𓾂�

	sub.w	d0,d2		*d2 = ���s�N�Z����-1
	sub.w	d1,d3		*d3 = �c�s�N�Z����-1

	movea.l	BUF(a1),a1	*a1 = �]����
	exg.l	a0,a1		*a0 = �]����
				*a1 = G-RAM�A�h���X

	addq.w	#1,d2		*d2 = ���s�N�Z����
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
odd:	move.w	(a1),(a0)+	*��s�N�Z���̏ꍇ
next:	adda.w	d1,a1		*�������̃��C����
	dbra	d3,loop		*�������J��Ԃ�

done:	movem.l	(sp)+,d0-d3/a0-a3
	unlk	a6
	rts

	.end
