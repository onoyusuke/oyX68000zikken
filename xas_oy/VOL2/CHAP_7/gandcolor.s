*	and���[�h�̃{�b�N�X�t�B��

	.include	gconst.h
*
	.xdef	gandcolor
	.xdef	gfill_and
	.xref	gramadr
	.xref	gcliprect
*
	.offset	0	*gandcolor�̈����\��
*
X0:	.ds.w	1	*�`�����W
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
COL:	.ds.w	1	*�`��F
*
	.text
	.even
*
gandcolor:
gfill_and:
ARGPTR	=	8
	link	a6,#0
	movem.l	d0-d4/a0-a1,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = ������
	movem.w	(a1),d0-d3	*d0�`d3�ɍ��W�����o��

	jsr	gcliprect	*�N���b�s���O����
	bmi	done		*N=1�Ȃ�`��̕K�v�Ȃ�

	jsr	gramadr		*G-RAM��̃A�h���X�𓾂�

	sub.w	d0,d2		*d2 = ���s�N�Z����-1
	sub.w	d1,d3		*d3 = �c�s�N�Z����-1

	move.w	COL(a1),d0	*d0 = �`��F

	move.w	#GNBYTE-2,d1	*d1 = ���C���Ԃ̃A�h���X�̍�
	sub.w	d2,d1		*�i�E�[���牺�̃��C���̍��[�܂Łj
	sub.w	d2,d1		*

loop1:	move.w	d2,d4		*d4 = ���s�N�Z����-1
loop2:	and.w	d0,(a0)+	*
	dbra	d4,loop2	*�������J��Ԃ�

	adda.w	d1,a0		*�������̃��C����
	dbra	d3,loop1	*�������J��Ԃ�

done:	movem.l	(sp)+,d0-d4/a0-a1
	unlk	a6
	rts

	.end
