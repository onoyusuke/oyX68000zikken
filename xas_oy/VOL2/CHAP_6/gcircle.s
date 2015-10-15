*	�~��`��

	.include	gconst.h
*
	.xdef	gcircle
	.xref	gramadr
	.xref	cliprect
*
PSET	macro	X,Y,COL,ADR	*�N���b�s���O����
	local	skip		*�@�_��ł}�N��
	movea.l	a4,a5		*
	cmp.l	(a5)+,X		*
	blt	skip		*
	cmp.l	(a5)+,Y		*
	blt	skip		*
	cmp.l	(a5)+,X		*
	bgt	skip		*
	cmp.l	(a5)+,Y		*
	bgt	skip		*
	move.w	COL,ADR		*
skip:				*
	.endm			*
*
	.offset	0	*gcircle�̈����\��
*
X0:	.ds.w	1	*���S���W
Y0:	.ds.w	1	*
R:	.ds.w	1	*���a
COL:	.ds.w	1	*�`��F
*
	.offset	0	*�N���b�s���O�̈�
*
LMINX:	.ds.l	1
LMINY:	.ds.l	1
LMAXX:	.ds.l	1
LMAXY:	.ds.l	1
LRECT:
*
	.text
	.even
*
gcircle:
ARGPTR	=	8
	link	a6,#-LRECT
	movem.l	d0-d7/a0-a5,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = ������

	movem.w	(a1),d0-d2/d7	*(d0,d1) = (x0,y0) = ���S���W
				*d2 = R = ���a
				*d7 = �`��F

	tst.w	d2		*R��0�Ȃ��
	bmi	done		*�@�G���[�I��

	lea.l	-LRECT(a6),a4	*(x0,y0)�����_�ɂȂ�悤
	lea.l	cliprect,a5	*�@�N���b�s���O�̈��
				*�@���s�ړ�����
	moveq.l	#2-1,d6		*
rloop:	moveq.l	#0,d5		*
	move.w	(a5)+,d5	*
	sub.l	d0,d5		*
	move.l	d5,(a4)+	*
				*
	moveq.l	#0,d5		*
	move.w	(a5)+,d5	*
	sub.l	d1,d5		*
	move.l	d5,(a4)+	*
				*
	dbra	d6,rloop	*
				*
	lea.l	-LRECT(a4),a4	*a4 = �V�t�g��̃N���b�s���O�̈�

	jsr	gramadr		*a0 = (x0,y0)��G-RAM�A�h���X

*********�ȉ��@���W�l�͂��ׂ�(-x0,-y0)�̃Q�^�����\��*********

	move.l	d2,d0		*a2 = (0,R)��G-RAM�A�h���X
	moveq.l	#GSFTCTR,d6	*
	lsl.l	d6,d0		*
	lea.l	0(a0,d0.l),a2	*
	neg.l	d0		*a3 = (0,-R)��G-RAM�A�h���X
	lea.l	0(a0,d0.l),a3	*

	move.l	d2,d0		*(d0,d1) = (x,y) = (R,0)
	moveq.l	#0,d1		*

	add.w	d2,d2		*d2 = 2R
	adda.l	d2,a0		*a0 = a1 = (x,y)��G-RAM�A�h���X
	movea.l	a0,a1		*

	move.l	d2,d4		*d4 = -2R+1 = F-2
	neg.l	d4		*
	addq.l	#1,d4		*

	add.l	d2,d2		*d2 = 4x = 4R
	moveq.l	#2,d3		*d3 = 4y+2 = 2

	move.l	d2,d5		*d5 = -4R = (x,y)��(-x,y)�Ƃ�
	neg.l	d5		*	�A�h���X�̍�
	moveq.l	#0,d6		*d6 =   0 = (y,x)��(-y,x)�Ƃ�
				*	�A�h���X�̍�
loop:
P0	reg	(a0)		*    -x -y  y  x
P1	reg	(a1)		*-x	P7  P3
P2	reg	(a2)		*-y  P5	       P1
P3	reg	(a3)		*
P4	reg	0(a0,d5.l)	*
P5	reg	0(a1,d5.l)	* y  P4	       P0
P6	reg	0(a2,d6.l)	* x	P6  P2
P7	reg	0(a3,d6.l)	*

	PSET	d0,d1,d7,P0	*P0(x,y)
	PSET	d1,d0,d7,P2	*P2(y,x)
	neg.l	d1
	PSET	d0,d1,d7,P1	*P1(x,-y)
	PSET	d1,d0,d7,P6	*P3(-y,x)
	neg.l	d0
	PSET	d0,d1,d7,P5	*P5(-x,-y)
	PSET	d1,d0,d7,P7	*P7(-y,-x)
	neg.l	d1
	PSET	d0,d1,d7,P4	*P4(-x,y)
	PSET	d1,d0,d7,P3	*P6(y,-x)
	neg.l	d0

	add.l	d3,d4		*F += 4y+2
	bmi	vmove		*F��0�Ȃ�ΐ����ړ�

dmove:			*�΂߈ړ�
	subq.w	#1,d0		*x--
	subq.l	#4,d2		*4x
	sub.l	d2,d4		*F -= 4x

	subq.l	#2,a0		*P0�����ֈړ�
	subq.l	#2,a1		*P1�����ֈړ�
	lea.l	-GNBYTE(a2),a2	*P2����ֈړ�
	lea.l	GNBYTE(a3),a3	*P3�����ֈړ�
	addq.l	#4,d5		*P4��P0�ɋߕt����

vmove:			*�����ړ�
	addq.w	#1,d1		*y++
	addq.l	#4,d3		*4y+2

	lea.l	GNBYTE(a0),a0	*P0�����ֈړ�
	lea.l	-GNBYTE(a1),a1	*P1����ֈړ�
	addq.l	#2,a2		*P2���E�ֈړ�
	addq.l	#2,a3		*P3���E�ֈړ�
	subq.l	#4,d6		*P6��P2���牓������

	cmp.w	d1,d0		*x��y�̂�����
	bge	loop		*�@�J��Ԃ�

done:	movem.l	(sp)+,d0-d7/a0-a5
	unlk	a6
	rts

	.end

�C������

94-11-29��
�񐔒l�V���{����equ�Œ�`���Ă����̂�reg�ɕύX
