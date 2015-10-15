*	�F�̍������킹

	.include	gconst.h
	.include	gmacro.h
*
	.xdef	gmixcolor
	.xref	gramadr
	.xref	gcliprect
*
	.offset	0	*gmixcolor�̈����\��
*
X0:	.ds.w	1	*��`���W
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
COL:	.ds.w	1	*������F
*
	.text
	.even
*
gmixcolor:
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

	move.w	#GNBYTE-2,d1	*d1 = ���C���Ԃ̃A�h���X�̍�
	sub.w	d2,d1		*�i�E�[���牺�̃��C���̍��[�܂Łj
	sub.w	d2,d1		*

	move.w	COL(a1),d4	*d0 = ������F
	DERGB	d4,d5,d6,d7	*

loop1:	move.w	d2,d4
	swap.w	d1		*���W�X�^������Ȃ�����
	swap.w	d2		*�@�f�[�^���W�X�^��
	swap.w	d3		*�@��ʃ��[�h���g��
loop2:	move.w	(a0),d0		*�F�R�[�h�����o��
	DERGB	d0,d1,d2,d3	*�@RGB���Ƃ�
	MEAN	d5,d1		*�@�F�����̕��ς����
	MEAN	d6,d2		*
	MEAN	d7,d3		*

	RGB	d1,d2,d3,d0	*�J���[�R�[�h�ɍč\��
	move.w	d0,(a0)+	*�P�s�N�Z����������
	dbra	d4,loop2	*�������J��Ԃ�

	swap.w	d1
	swap.w	d2
	swap.w	d3
	adda.w	d1,a0		*�������̃��C����
	dbra	d3,loop1	*�������J��Ԃ�

done:	movem.l	(sp)+,d0-d7/a0-a1
	unlk	a6
	rts

	.end
