*	�p�^�[������]/�g��/�k�����ăv�b�g����i���R�ό`���p�Łj

*	.include	gconst.h
	.include	gmacro.h
*
.ifdef	_11
	.xdef	grput2_11
.else
	.xdef	grput2
.endif
	.xref	gtput
	.xref	sintable
*
*	sin(DEG)���e�[�u����������Ă���}�N��
*
ISIN	macro	TABLE,DEG
	local	skip1,skip2,skip3

	ext.l	DEG		*sin(-��) = -sin(��)
	bpl	skip1		*
	neg.w	DEG		*

skip1:	subi.w	#90,DEG		*sin(180�-��) = sin(��)
	bcs	skip2		*
	neg.w	DEG		*
skip2:	addi.w	#90,DEG		*0��deg��90�

	add.w	DEG,DEG
	move.w	0(TABLE,DEG),DEG

	tst.l	DEG		*sin(-��) = -sin(��)
	bpl	skip3		*
	neg.w	DEG		*
skip3:
	.endm

*
*	�_(X,Y)����]����}�N��
*
ROTP	macro	X,Y
	local	skip1,skip2

	move.w	X,d6
	move.w	Y,d7

	muls.w	d5,X		*x�cos(��)
	muls.w	d5,Y		*y�cos(��)
	muls.w	d4,d6		*x�sin(��)
	muls.w	d4,d7		*y�sin(��)

	sub.l	d7,X		*x�cos(��)-y�sin(��)
	bpl	skip1
	addi.l	#$3fff,X
skip1:	asl.l	#2,X
	swap.w	X

	add.l	d6,Y		*x�sin(��)+y�cos(��)
	bpl	skip2
	addi.l	#$3fff,Y
skip2:	asl.l	#2,Y
	swap.w	Y

	add.w	a2,X
	add.w	a3,Y

.ifndef	_11
	add.w	X,X		*x���W��2/3�ɂ���
	add.w	X,X		*
	addq.w	#3,X		*
	ext.l	X		*
	divs.w	#6,X		*
.endif
	.endm
*
	.offset	0	*grput2�̈����\��
*
X0:	.ds.w	1	*�`�����W
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
DEG:	.ds.w	1	*��]�p�x�i���j
PAT:	.ds.l	1	*�p�^�[���A�h���X
XL:	.ds.w	1	*�p�^�[���̉��̒���-1
YL:	.ds.w	1	*�p�^�[���̏c�̒���-1
*
	.offset	-48	*�X�^�b�N�t���[��
*
WORKTOP:
ARGBUF:	.ds.b	48	*gtput�ւ̈���
_A6:	.ds.l	1	*0
_SP:	.ds.l	1	*4
ARGPTR:	.ds.l	1	*8
*
	.text
	.even
*
.ifdef	_11
grput2_11:
.else
grput2:
.endif
	link	a6,#WORKTOP
	movem.l	d0-d7/a0-a3,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = ������
	move.w	DEG(a1),d4	*d4 = �p�x

	move.w	#360,d6		*�p�x��
	move.w	#180,d7		*�@-180߁`179߂�
	add.w	d7,d4		*�@���K������
	bpl	norm2		*
norm1:	add.w	d6,d4		*
	bmi	norm1		*
norm2:	cmp.w	d6,d4		*
	bcs	norm3		*
	sub.w	d6,d4		*
	bra	norm2		*
norm3:	sub.w	d7,d4		*

	moveq.l	#90,d5		*cos�� = sin(90�-��)
	sub.w	d4,d5		*
	cmp.w	d7,d5		*
	ble	rot		*
	sub.w	d6,d5		*

rot:	lea.l	sintable,a0
	ISIN	a0,d4		*d4 = sin(��)
	ISIN	a0,d5		*d5 = cos(��)

	movem.w	X0(a1),d0-d3	*d0�`d3�ɍ��W�����o��

	lea.l	ARGBUF(a6),a0	*a0 = gtput�֓n��������

.ifndef	_11
	move.w	d0,d6		*x0��1.5�{����
	add.w	d0,d0		*
	add.w	d6,d0		*
	asr.w	#1,d0		*

	move.w	d2,d6		*x1��1.5�{����
	add.w	d2,d2		*
	add.w	d6,d2		*
	asr.w	#1,d2		*
.endif

	move.w	d2,d6		*a2 = ��]�̒��Sx���W
	add.w	d0,d6		*
	asr.w	#1,d6		*
	move.w	d6,a2		*

	move.w	d3,d6		*a3 = ��]�̒��Sy���W
	add.w	d1,d6		*
	asr.w	#1,d6		*
	move.w	d6,a3		*

	sub.w	a2,d0		*(d0,d1) = �p�^�[�����S��
	sub.w	a3,d1		*�@���_�Ƃ��鍶����̍��W
	sub.w	a2,d2		*(d2,d1) = �p�^�[�����S��
				*�@���_�Ƃ���E����̍��W

	move.w	d1,d3		*d1��Ҕ�
	ROTP	d0,d1		*����̓_����]����
	move.w	d0,(a0)+	*���ʂ��L�^
	move.w	d1,(a0)+	*

	sub.w	X0(a1),d0	*�E���̓_����]����
	sub.w	Y0(a1),d1	*�i�ȗ��v�Z�j
	sub.w	X1(a1),d0	*
	sub.w	Y1(a1),d1	*
	neg.w	d0		*
	neg.w	d1		*
	move.w	d0,4(a0)	*���ʂ��L�^
	move.w	d1,6(a0)	*

	ROTP	d2,d3		*�E��̓_����]����
	move.w	d2,8(a0)	*���ʂ��L�^
	move.w	d3,10(a0)	*

	sub.w	X1(a1),d2	*�����̓_����]����
	sub.w	Y0(a1),d3	*�i�ȗ��v�Z�j
	sub.w	X0(a1),d2	*
	sub.w	Y1(a1),d3	*
	neg.w	d2		*
	neg.w	d3		*
	move.w	d2,(a0)+	*���ʂ��L�^
	move.w	d3,(a0)+	*

	addq.l	#8,a0

	move.l	PAT(a1),(a0)+	*�p�^�[���A�h���X���Z�b�g
	move.l	XL(a1),(a0)+	*�p�^�[���T�C�Y���Z�b�g

	pea.l	ARGBUF(a6)	*���R�ό`���[�`����
	jsr	gtput		*�@�Ăяo��
	addq.l	#4,sp		*

	movem.l	(sp)+,d0-d7/a0-a3
	unlk	a6
	rts
