*	��`�̈�̏㉺���]

	.include	gconst.h
*
	.xdef	gvreverse
	.xref	gramadr
	.xref	gcliprect
*
	.offset	0	*gvreverse�̈����\��
*
X0:	.ds.w	1	*��`�̈�
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
*
	.text
	.even
*
gvreverse:
ARGPTR	=	8
	link	a6,#0
	movem.l	d0-d4/a0-a3,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = ������
	movem.w	(a1),d0-d3	*d0-d3�ɍ��W�����o��

	jsr	gcliprect	*�N���b�s���O����
	bmi	done		*N=1�Ȃ�`��̕K�v�Ȃ�

	jsr	gramadr		*�����G-RAM��̃A�h���X�𓾂�

	sub.w	d0,d2		*d2 = ���s�N�Z����-1
	sub.w	d1,d3		*d3 = �c�s�N�Z����-1

	move.w	d3,d0		*�c�s�N�Z����-1��GNBYTE�{����
	ext.l	d0		*
	moveq.l	#GSFTCTR,d1	*
	asl.l	d1,d0		*
	lea.l	0(a0,d0.l),a2	*a2 = �̈�̍������A�h���X
	lsr.w	#1,d3		*

	move.w	#GNBYTE,d1	*d1 = ���C���Ԃ̃A�h���X�̍�

loop1:	movea.l	a0,a1		*a1 = ����
	movea.l	a2,a3		*a3 = ����

	move.w	d2,d4		*d4 = ���s�N�Z����-1
loop2:	move.w	(a1),d0		*����
	move.w	(a3),(a1)+	*
	move.w	d0,(a3)+	*
	dbra	d4,loop2	*�������J��Ԃ�

	adda.w	d1,a0		*�������̃��C����
	suba.w	d1,a2		*������̃��C����
	dbra	d3,loop1	*����/2��J��Ԃ�

done:	movem.l	(sp)+,d0-d4/a0-a3
	unlk	a6
	rts

	.end
