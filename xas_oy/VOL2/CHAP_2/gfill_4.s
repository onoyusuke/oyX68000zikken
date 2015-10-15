*	��`�̓h��ׂ��i16�s�N�Z�������������ݔŁj

	.include	gconst.h
*
	.xdef	gfill
	.xref	gramadr
	.xref	gcliprect
*
*	128�s�N�Z���������ރ}�N��
*
H128	macro
	movem.l	d0/d4-d7/a3-a5,-(a1)
	movem.l	d0/d4-d7/a3-a5,-(a1)
	movem.l	d0/d4-d7/a3-a5,-(a1)
	movem.l	d0/d4-d7/a3-a5,-(a1)
	movem.l	d0/d4-d7/a3-a5,-(a1)
	movem.l	d0/d4-d7/a3-a5,-(a1)
	movem.l	d0/d4-d7/a3-a5,-(a1)
	movem.l	d0/d4-d7/a3-a5,-(a1)
	.endm
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
	movem.l	d0-d7/a0-a5,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = ������
	movem.w	(a1),d0-d3	*d0�`d3�ɍ��W�����o��

	jsr	gcliprect	*�N���b�s���O����
	bmi	done		*N=1�Ȃ�`��̕K�v�Ȃ�

	jsr	gramadr		*�����G-RAM��̃A�h���X�𓾂�

	sub.w	d0,d2		*d2 = ���s�N�Z����-1
	sub.w	d1,d3		*d3 = �c�s�N�Z����-1

	move.w	COL(a1),d0	*d0 = �`��F
	move.w	d0,d7		*
	swap.w	d0		*
	move.w	d7,d0		*

	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5

	addq.w	#1,d2		*d2 = ���s�N�Z����
	adda.w	d2,a0		*
	adda.w	d2,a0		*a0 = (x1+1,y0)��G-RAM�A�h���X

	moveq.l	#16-1,d1	*
	and.w	d2,d1		*d1 = ���s�N�Z���� % 16
	sub.w	d1,d2		*d2 = (���s�N�Z���� / 16) * 16

	lsr.w	#2,d2		*d2 = (���s�N�Z���� / 16) * 4
	lea.l	hline0(pc),a2	*
	suba.w	d2,a2		*a2 = (���s�N�Z����/16)*16�s�N�Z������
				*�@���������`�惋�[�`��

loop1:	movea.l	a0,a1
	jmp	(a2)		*�P���C���`��

.ifdef	_1024
	H128	*1024
	H128	* :
	H128	* :
	H128	* :
.endif
	H128	*512
	H128	*384
	H128	*256
	H128	*128

hline0:	move.w	d1,d2		*16�s�N�Z���ɖ����Ȃ�
	bra	next2		*�@�[����`��
loop2:	move.w	d0,-(a1)	*
next2:	dbra	d2,loop2	*

next1:	lea.l	GNBYTE(a0),a0	*�������̃��C����
	dbra	d3,loop1	*�������J��Ԃ�

done:	movem.l	(sp)+,d0-d7/a0-a5
	unlk	a6
	rts

	.end
