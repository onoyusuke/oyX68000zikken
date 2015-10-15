*	�p�^�[������]/�g��/�k�����ăv�b�g����

	.include	gconst.h
	.include	gmacro.h
*
	.xdef	grput
	.xref	gramadr
	.xref	ucliprect
	.xref	sintable
*
	.offset	0	*grput�̈����\��
*
X0:	.ds.w	1	*�`�����W
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
DEG:	.ds.w	1	*��]�p�x�i���j
PAT:	.ds.l	1	*�p�^�[���A�h���X�i���j
XL:	.ds.w	1	*�p�^�[���̉��̒���-1�i���j
YL:	.ds.w	1	*�p�^�[���̏c�̒���-1�i���j
TEMP:	.ds.l	1	*��Ɨp�������ւ̃|�C���^
*
*(��)	�@�@���@XL�@��
*	������������������
*	���@���@�@�@���@��
*	���������������������@�@�@�@�@�@�@�@
*	���@���_�@�@���@��
*	���@���@pat ���@��YL�@�@�@
*	���������������������@�@�@�@�@�@�@�@
*	���@���@�@�@���@���@�@�@
*	������������������
*
	.text
	.even
*
grput:
ARGPTR	=	4+8*4+7*4
	movem.l	d0-d7/a0-a6,-(sp)

	movea.l	ARGPTR(sp),a6	*a6 = ������

	bsr	rotate		*��]�̌v�Z������

	movea.l	TEMP(a6),a5
	movea.l	a5,a4
	movem.w	d0-d1/d4-d5,-(sp)
	bsr	line_comp	*�����P���C������
				*�@�_�̏E���������߂�

	lea.l	ucliprect,a0	*���E�[��
	move.w	X0(a6),d1	*�@�N���b�s���O������
	move.w	X1(a6),d2	*
	bsr	clip		*
	bmi	done2		*

	movea.l	a5,a2
	bsr	expand_comp	*�����P���C������
				*�@�g��/�k�����l������
				*�@�_�̏E���������߂�

	movea.l	a5,a4
	movem.w	(sp)+,d0-d3
	bsr	line_comp	*�����P���C������
				*�@�_�̏E���������߂�

	lea.l	ucliprect+2,a0	*�㉺�[��
	move.w	Y0(a6),d1	*�@�N���b�s���O������
	move.w	Y1(a6),d2	*
	bsr	clip		*
	bmi	done		*

	movea.l	a5,a3
	bsr	expand_comp	*�����P���C������
				*�@�g��/�k�����l������
				*�@�_�̏E���������߂�

	move.w	(a2)+,d0	*(d0,d1) = �`��J�n�ʒu
	move.w	(a3)+,d1	*
	jsr	gramadr		*a0 = ����G-RAM��A�h���X

	move.w	(a2)+,d7	*d7 = �`��͈͉������̒���-1
	move.w	(a3)+,d5	*d5 = �`��͈͏c�����̒���-1

	move.w	d7,d0		*d0 =
	addq.w	#1,d0		*�@���C���E�[��
	add.w	d0,d0		*�@���̃��C�����[�Ƃ�
	neg.w	d0		*�@G-RAM��̃A�h���X�̍�
	addi.w	#GNBYTE,d0	*

yloop:	movea.l	a1,a4		*a4 = �Q�Ƃ���p�^�[����ʒu
	movea.l	a2,a5		*a5 = �P���C�����̎Q�ƈʒu��
				*�@�ړ��ʂ̃e�[�u��
	move.w	d7,d6
xloop:	move.w	(a4),(a0)+	*�P�_�`�悷��
	adda.w	(a5)+,a4	*�Q�ƈʒu���ړ�����
	dbra	d6,xloop	*�������J��Ԃ�

	adda.w	(a3)+,a1	*�Q�ƈʒu���c�Ɉړ�����
	adda.w	d0,a0		*a0 = ���̃��C�����[
	dbra	d5,yloop	*�������J��Ԃ�

done:	movem.l	(sp)+,d0-d7/a0-a6
	rts
done2:	addq.l	#8,sp
	bra	done

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

	add.w	X,X		*x���W��2/3�ɂ���
	add.w	X,X		*
	addq.w	#3,X		*
	ext.l	X		*
	divs.w	#6,X		*

	.endm

*
*	�p�^�[���̊p�R�_����]����
*
rotate:
	move.w	DEG(a6),d4	*d4 = �p�x

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

	movem.w	XL(a6),d0-d1	*d0,d1 = �p�^�[���̏c���̑傫��

	move.w	d0,a5

	add.w	d0,d0		*x�����̒�����1.5�{����
	add.w	a5,d0		*
	lsr.w	#1,d0		*

	move.w	d0,d2
	move.w	d1,d3

	lsr.w	#1,d0		*(d0,d1) = ��]�̒��S
	lsr.w	#1,d1		*

	move.w	d0,a2		*(a2,a3) = ��]�̒��S
	move.w	d1,a3		*

	sub.w	d0,d2		*(d0,d1) = �p�^�[�����S��
	neg.w	d0		*�@���_�Ƃ��鍶����̍��W
	neg.w	d1		*(d2,d1) = �p�^�[�����S��
				*�@���_�Ƃ���E����̍��W

	move.w	d1,a4
	ROTP	d0,d1		*����̓_����]����

	exg.l	d1,a4		*(d2,d1) = �p�^�[�����S��
				*�@���_�Ƃ���E����̍��W
	ROTP	d2,d1		*�E��̓_����]����

	move.w	a5,d4		*�����̓_����]����
	sub.w	d2,d4		*
	move.w	d3,d5		*
	sub.w	d1,d5		*

	move.w	d1,d3
	move.w	a4,d1

*	����	(d0,d1)
*	�E��	(d2,d3)
*	����	(d4,d5)

	movea.l	PAT(a6),a1	*(d0,d1)�ɑΉ�����
	adda.w	d0,a1		*�@�p�^�[����̈ʒu��
	adda.w	d0,a1		*�@���߂�
	move.w	a5,d6		*
	addq.w	#1,d6		*
	add.w	d6,d6		*
	add.w	d6,d6		*
	muls.w	d1,d6		*
	adda.l	d6,a1		*
	rts

*
*	�p�^�[����̐���(d0,d1)-(d2,d3)�ɉ�����
*	�|�C���^���ړ����鑊�΃A�h���X�̕\���쐬����
*
line_comp:
	sub.w	d0,d2
	move.w	d2,d4
	ABS	d2
	SGN	d4

	sub.w	d1,d3
	move.w	d3,d5
	ABS	d3
	SGN	d5

	add.w	d4,d4
	move.w	XL(a6),d0
	addq.w	#1,d0
	add.w	d0,d0
	add.w	d0,d0
	muls.w	d0,d5

	cmp.w	d3,d2
	bcs	yline

xline:	move.w	d2,d0	*�X�����ɂ₩�Ȑ����̏ꍇ

	move.w	d2,d1		*Bresenham�̃A���S���Y����
	neg.w	d1		*�@�K�v�ȃp�����[�^�̌v�Z
	move.w	d2,d6		*
	add.w	d2,d2		*
	add.w	d3,d3		*

xline0:	move.w	d4,d7		*�A�h���X�̑��ΓI�Ȉړ��ʂ�
	add.w	d3,d1		*
	bmi	xline1		*
	add.w	d5,d7		*
	sub.w	d2,d1		*
xline1:	move.w	d7,(a5)+	*�@�e�[�u���ɓo�^���Ă���
	dbra	d6,xline0
	rts

yline:	move.w	d3,d0	*�X�����}�Ȑ����̏ꍇ

	move.w	d3,d1		*Bresenham�̃A���S���Y����
	neg.w	d1		*�@�K�v�ȃp�����[�^�̌v�Z
	move.w	d3,d6		*
	add.w	d2,d2		*
	add.w	d3,d3		*

yline0:	move.w	d5,d7		*�A�h���X�̑��ΓI�Ȉړ��ʂ�
	add.w	d2,d1		*
	bmi	yline1		*
	add.w	d4,d7		*
	sub.w	d3,d1		*
yline1:	move.w	d7,(a5)+	*�@�e�[�u���ɓo�^���Ă���
	dbra	d6,yline0
	rts

*
*	�N���b�s���O����
*
	.offset	0
*				MINX
Min:	.ds.w	1	*MINX	MINY
	.ds.w	1	*MINY	MAXX
Max:	.ds.w	1	*MAXX	MAXY
	.ds.w	1	*MAXY	----
*
	.offset	0
*
D0SAV:	.ds.w	1
D2SAV:	.ds.w	1
NPIX:	.ds.w	1
*
	.text
*
clip:
	MINMAX	d1,d2		*d1��d2��ۏ؂���

	addi.w	#$8000,d1	*�Q�^�𗚂�����
	addi.w	#$8000,d2	*
	moveq.l	#0,d3
	movem.w	d0/d2-d3,-(sp)
minclip:			*���[/��[�ŃN���b�v
	move.w	Min(a0),d6
	cmp.w	d6,d1
	bcc	maxclip		*�E�B���h�E��������

	cmp.w	d6,d2
	bcc	min0
	bne	outofscrn	*���S�ɃE�B���h�E�O

	move.w	d2,d1
	bra	maxclip

min0:	moveq.l	#0,d3
minlp:	move.w	d1,d7
	add.w	d2,d7
	roxr.w	#1,d7
	cmp.w	d6,d7
	beq	min2
	bcs	min1

	move.w	d7,d2
	add.w	d3,d0
	roxr.w	#1,d0
	bra	minlp

min1:	move.w	d7,d1
	add.w	d0,d3
	roxr.w	#1,d3
	bra	minlp

min2:	move.w	d7,d1
	add.w	d3,d0
	roxr.w	#1,d0		*d0 = �E�B���h�E�O�ɂ͂ݏo��
				*�@�p�^�[���̃s�N�Z����
	sub.w	d0,NPIX(sp)

	subq.w	#1,d0
	bcs	min3
skiplp:	adda.w	(a4)+,a1	*�؂�̂Ă���
	dbra	d0,skiplp	*�@�Q�ƊJ�n�ʒu��
				*�@���炷
min3:	move.w	D0SAV(sp),d0
	move.w	D2SAV(sp),d2

maxclip:			*�E�[/���[�ŃN���b�v
	move.w	Max(a0),d6
	cmp.w	d6,d2
	bls	clipped		*�E�B���h�E��������

	cmp.w	d6,d1
	bls	max0
	bne	outofscrn	*���S�ɃE�B���h�E�O

	moveq.l	#0,d0
	move.w	d1,d2
	bra	clipped

max0:	move.w	d1,d4
	moveq.l	#0,d3
maxlp:	move.w	d4,d7
	add.w	d2,d7
	roxr.w	#1,d7
	cmp.w	d6,d7
	beq	max2
	bcs	max1

	move.w	d7,d2
	add.w	d3,d0
	roxr.w	#1,d0
	bra	maxlp

max1:	move.w	d7,d4
	add.w	d0,d3
	roxr.w	#1,d3
	bra	maxlp

max2:	move.w	d7,d2
	add.w	d3,d0
	roxr.w	#1,d0

clipped:			*�N���b�s���O����
	subi.w	#$8000,d1	*�Q�^��E������
	subi.w	#$8000,d2	*

	addq.l	#4,sp
	add.w	(sp)+,d0	*d0 = �p�^�[�����
				*�@�_���E���΂ߐ�����
	rts			*N = 0

outofscrn:
	addq.l	#6,sp
	moveq.l	#-1,d0		*N = 1
	rts

*
*	�΂߂ɐ؂�o�����p�^�[����
*	�`���̑傫���ɍ��킹�Ċg��/�k�����邽�߂�
*	�e�[�u�����쐬����
*
expand_comp:
	move.w	d1,(a5)+	*�N���b�s���O���
				*�@�`��捶���x/y���W
	sub.w	d1,d2
	move.w	d2,(a5)+	*�`�敝/����
	beq	exdone

	move.w	d2,d1		*Bresenham�̃A���S���Y����
	neg.w	d1		*�@�K�v�ȃp�����[�^�̌v�Z
	move.w	d2,d3		*
	add.w	d2,d2		*
	add.w	d0,d0		*

explp1:	moveq.l	#0,d4		*�A�h���X�̑��ΓI�Ȉړ��ʂ�
	add.w	d0,d1		*
	ble	expnxt		*
explp2:	add.w	(a4)+,d4	*
	sub.w	d2,d1		*
	bgt	explp2		*
expnxt:	move.w	d4,(a5)+	*�@�e�[�u���ɓo�^���Ă���
	dbra	d3,explp1

exdone:	rts

	.end
