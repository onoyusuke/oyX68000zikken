*	��`�̓h��ׂ��i���[�v�W�J�Łj

	.include	gconst.h
*
	.xdef	gfill
	.xref	gramadr
	.xref	gcliprect
*
	.offset	0	*gfill�̈����\��
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
gfill:
ARGPTR	=	8
	link	a6,#0
	movem.l	d0-d3/a0-a1,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = ������
	movem.w	(a1),d0-d3	*d0�`d3�ɍ��W�����o��

	jsr	gcliprect	*�N���b�s���O����
	bmi	done		*N=1�Ȃ�`��̕K�v�Ȃ�

	jsr	gramadr		*�����G-RAM��̃A�h���X�𓾂�

	sub.w	d0,d2		*d2 = ���s�N�Z����-1
	sub.w	d1,d3		*d3 = �c�s�N�Z����-1

	move.w	COL(a1),d0	*d0 = �`��F

	addq.w	#1,d2		*d2 = ���s�N�Z����
	add.w	d2,d2		*d2 = �P���C�����̃o�C�g��
	lea.l	next(pc),a1	*a1 = ���s�N�Z������
	suba.w	d2,a1		*�@���������`�惋�[�`��

	move.w	#GNBYTE,d1	*d1 = ���C���Ԃ̃A�h���X�̍�
	sub.w	d2,d1		*

loop:	jmp	(a1)		*�P���C���`��
	.dcb.w	GNPIXEL,$30c0	* move.w d0,(a0)+
next:	adda.w	d1,a0		*�������̃��C����
	dbra	d3,loop		*�������J��Ԃ�

done:	movem.l	(sp)+,d0-d3/a0-a1
	unlk	a6
	rts

	.end
