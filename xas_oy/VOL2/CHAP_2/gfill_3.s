*	��`�̓h��ׂ��i�Q�s�N�Z�������������ݔŁj

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
	movem.l	d0-d3/a0-a2,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = ������
	movem.w	(a1),d0-d3	*d0�`d3�ɍ��W�����o��

	jsr	gcliprect	*�N���b�s���O����
	bmi	done		*N=1�Ȃ�`��̕K�v�Ȃ�

	jsr	gramadr		*�����G-RAM��̃A�h���X�𓾂�

	sub.w	d0,d2		*d2 = ���s�N�Z����-1
	sub.w	d1,d3		*d3 = �c�s�N�Z����-1

	move.w	COL(a1),d0	*d0 = �`��F
	swap.w	d0		*
	move.w	COL(a1),d0	*

	addq.w	#1,d2		*d2 = ���s�N�Z����
	lea.l	next(pc),a2	*
	bclr.l	#0,d2		*���s�N�Z�����͊���H
	beq	skip		*
	lea.l	odd(pc),a2	*��s�N�Z���̂Ƃ�

skip:	lea.l	hline0(pc),a1	*
	suba.w	d2,a1		*a1 = ���s�N�Z�����i�����j��
				*�@���������`�惋�[�`���擪

	move.w	#GNBYTE,d1	*d1=���C���Ԃ̃A�h���X�̍�
	add.w	d2,d2		*
	sub.w	d2,d1		*

loop:	jmp	(a1)		*�P���C���`��
hline:	.dcb.w	GNPIXEL/2,$20c0	*move.l	d0,(a0)+
hline0:	jmp	(a2)
odd:	move.w	d0,(a0)		*��s�N�Z���̏ꍇ
next:	adda.w	d1,a0		*�������̃��C����
	dbra	d3,loop		*�������J��Ԃ�

done:	movem.l	(sp)+,d0-d3/a0-a2
	unlk	a6
	rts

	.end
