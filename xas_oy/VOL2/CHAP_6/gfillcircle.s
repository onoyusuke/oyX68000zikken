*	�~�E�ȉ~��h��ׂ��ĕ`��

	.include	gconst.h
*
	.xdef	gfillcircle
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
	.offset	0	*gfillcircle�̈����\��
*
X0:	.ds.w	1	*���S���W
Y0:	.ds.w	1	*
XR:	.ds.w	1	*�����������a
YR:	.ds.w	1	*�����������a
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
	.offset	-56	*���[�N
*
WORKTOP:
X1:	.ds.w	1	*��P�����~x���W
Y1:	.ds.w	1	*��P�����~y���W
X2:	.ds.w	1	*��Q�����~x���W
Y2:	.ds.w	1	*��Q�����~y���W
EX1:	.ds.l	1	*x�k���덷��1
EY1:	.ds.l	1	*y�k���덷��1
EX2:	.ds.l	1	*x�k���덷��2
EY2:	.ds.l	1	*y�k���덷��2
EXDX:	.ds.l	1	*x�k���덷���␳�l
EXDY:	.ds.l	1	*x�k���덷������
EYDX:	.ds.l	1	*y�k���덷���␳�l
EYDY:	.ds.l	1	*y�k���덷������
CRECT:	.ds.b	LRECT	*�V�t�g�����E�B���h�E
*
	.text
	.even
*
gfillcircle:
ARGPTR	=	8
	link	a6,#WORKTOP
	movem.l	d0-d7/a0-a5,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = ������

	movem.w	(a1),d0-d3/d7	*(d0,d1) = (x0,y0) = ���S���W
				*d2 = XR = �����������a
				*d3 = YR = �����������a
				*d7 = �`��F

	tst.w	d2		*XR��0�Ȃ��
	bmi	done		*�@�G���[�I��
	tst.w	d3		*YR��0�Ȃ��
	bmi	done		*�@�G���[�I��

	lea.l	CRECT(a6),a4	*(x0,y0)�����_�ɂȂ�悤
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

	move.l	d3,d0		*a2 = (0,YR)��G-RAM�A�h���X
	moveq.l	#GSFTCTR,d6	*
	lsl.l	d6,d0		*
	lea.l	0(a0,d0.l),a2	*
	neg.l	d0		*a3 = (0,-YR)��G-RAM�A�h���X
	lea.l	0(a0,d0.l),a3	*

	move.l	d3,X2(a6)	*(x2,y2) = (0,YR)
	swap.w	d2
	move.l	d2,X1(a6)	*(x1,y1) = (XR,0)
	swap.w	d2

	move.l	d2,d0		*x�k���덷����
	neg.l	d0		*�@��������
	move.l	d0,EX1(a6)	*

	move.l	d3,d0		*y�k���덷����
	neg.l	d0		*�@��������
	move.l	d0,EY1(a6)	*

	add.w	d2,d2		*d2 = 2XR
	add.w	d3,d3		*d3 = 2YR
	subq.l	#2,d2		*d2 = 2(XR-1)
	subq.l	#2,d3		*d3 = 2(YR-1)
	move.l	d3,EXDX(a6)	*x�k���덷���␳�l
	move.l	d2,EXDY(a6)	*x�k���덷������
	move.l	d2,EYDX(a6)	*y�k���덷���␳�l
	move.l	d3,EYDY(a6)	*y�k���덷������
	addq.l	#2,d2		*d2 = 2XR
	addq.l	#2,d3		*d3 = 2XR

	adda.l	d2,a0		*a0 = a1 = (x1,y1)��G-RAM�A�h���X
	movea.l	a0,a1		*

	move.l	d2,d5		*d5 = 2XR
	add.l	d5,d5		*d5 = -4XR = (x1,y1)��(-x1,y1)�Ƃ�
	neg.l	d5		*	�A�h���X�̍�
	moveq.l	#0,d6		*d6 =    0 =(x2,y2)��(-x2,y2)�Ƃ�
				*	�A�h���X�̍�

	cmp.w	d3,d2		*2XR��2YR�̑傫������
	bcc	init1		*�@d2�Ɏc��
	move.w	d3,d2		*d2 = max(2XR,2YR) = 2R

init0:	move.l	d6,EY1(a6)	*�c���ȉ~������
	move.l	d6,EYDX(a6)	*�@y�͏k�����Ȃ�
	move.l	d6,EYDY(a6)	*
	bra	init2

init1:	move.l	d6,EX1(a6)	*�����ȉ~������
	move.l	d6,EXDX(a6)	*�@x�͏k�����Ȃ�
	move.l	d6,EXDY(a6)	*

init2:	tst.w	d2		*XR = YR = 0�Ȃ��
	bne	do		*

	movem.w	X1(a6),d0-d1	*�@(x0,y0)�ɓ_��ł��ďI��
	PSET	d0,d1,d7,(a0)	*
	bra	done

do:	move.l	d2,d4		*d4 = -2R+1 = F-2
	neg.l	d4		*
	addq.l	#1,d4		*

	add.l	d2,d2		*d2 = 4x = 4R
	moveq.l	#0,d3		*d3 = 4y = 0

	move.l	EX1(a6),EX2(a6)	*x�k���덷��2��������
	move.l	EY1(a6),EY2(a6)	*y�k���덷��2��������

	move.w	d7,d0		*d7 = �`��F�i���/���ʃ��[�h�Ƃ��j
	swap.w	d7		*
	move.w	d0,d7		*

	.xref	ghline
	lea.l	ghline,a5	*a5 = ���������`�惋�[�`��

loop:
*P0	reg	(a0)		*    -x1-x2  x2 x1
*P1	reg	(a1)		*-y2	 P7  P3
*P2	reg	(a2)		*-y1  P5	P1
*P3	reg	(a3)		*
*P4	reg	0(a0,d5.l)	*
*P5	reg	0(a1,d5.l)	* y1  P4	P0
*P6	reg	0(a2,d6.l)	* y2	 P6  P2
*P7	reg	0(a3,d6.l)	*

	add.l	d3,d4		*F+=4y+2
	addq.l	#2,d4		*
	bmi	vmove		*F��0�Ȃ�ΐ����ړ�

dmove:			*�΂߈ړ�
	subq.l	#4,d2		*4x
	sub.l	d2,d4		*F -= 4x

xcalc1:	move.l	EX1(a6),d0	*�k�����l������
	add.l	EXDY(a6),d0	*�@x1���X�V����
	bmi	xskip1		*
				*
	subq.w	#1,X1(a6)	*x1--
	subq.l	#2,a0		*P0�����ֈړ�
	subq.l	#2,a1		*P1�����ֈړ�
	addq.l	#4,d5		*P4��P0�ɋߕt����
				*
	sub.l	EXDX(a6),d0	*
				*
xskip1:	move.l	d0,EX1(a6)	*

ycalc1:	move.l	EYDY(a6),d0	*�k�����l������
	add.l	d0,EY2(a6)	*�@y2���X�V����
	bmi	yskip1		*

	movem.w	X2(a6),d0-d1	*P2-P6, P3-P7��`��
	exg.l	d5,d6		*
	exg.l	a0,a2		*
	exg.l	a1,a3		*
	bsr	drawlines	*
	exg.l	d5,d6		*
	exg.l	a0,a2		*
	exg.l	a1,a3		*

	subq.w	#1,Y2(a6)	*y2--
	lea.l	-GNBYTE(a2),a2	*P2����ֈړ�
	lea.l	GNBYTE(a3),a3	*P3�����ֈړ�
				*
	move.l	EYDX(a6),d0	*
	sub.l	d0,EY2(a6)	*
				*
yskip1:
vmove:			*�����ړ�
	addq.l	#4,d3		*4y

ycalc2:	move.l	EYDY(a6),d0	*�k�����l������
	add.l	d0,EY1(a6)	*�@y1���X�V����
	bmi	yskip2		*

	movem.w	X1(a6),d0-d1	*P0-P4, P1-P5��`��
	bsr	drawlines	*

	addq.w	#1,Y1(a6)	*y1++
	lea.l	GNBYTE(a0),a0	*P0�����ֈړ�
	lea.l	-GNBYTE(a1),a1	*P1����ֈړ�
				*
	move.l	EYDX(a6),d0	*
	sub.l	d0,EY1(a6)	*
				*
yskip2:
xcalc2:	move.l	EX2(a6),d0	*�k�����l������
	add.l	EXDY(a6),d0	*�@x2���X�V����
	bmi	xskip2		*

	addq.w	#1,X2(a6)	*x2++
	addq.l	#2,a2		*P2���E�ֈړ�
	addq.l	#2,a3		*P3���E�ֈړ�
	subq.l	#4,d6		*P6��P2���牓������
				*
	sub.l	EXDX(a6),d0	*
				*
xskip2:	move.l	d0,EX2(a6)	*

	cmp.l	d3,d2		*4x��4y�̂�����
	bge	loop		*�@�J��Ԃ�

	movem.w	X1(a6),d0-d1	*�`��̃^�C�~���O�����ꂽ��
	bsr	drawlines	*

done:	movem.l	(sp)+,d0-d7/a0-a5
	unlk	a6
	rts

*
*	P0-P4��P1-P5, ���邢��, P2-P6��P3-P7�̂Q�{�̐�����`��
*
drawlines:
	movem.l	d2/a0,-(sp)

	lea.l	0(a0,d5.l),a0	*P0-P4�i�܂���P2-P6�j��`��
	movem.l	d0-d1,-(sp)	*
	bsr	drawline	*
	movem.l	(sp)+,d0-d1	*

	neg.l	d1		*P1-P5�i�܂���P3-P7�j��`��
	lea.l	0(a1,d5.l),a0	*
	bsr	drawline	*

	movem.l	(sp)+,d2/a0
	rts

*
*	�����������P�{�`��
*
drawline:
	cmp.l	CRECT+LMINY(a6),d1	*���S�ɃE�B���h�E�O�̏ꍇ��e��
	blt	skip			*
	cmp.l	CRECT+LMAXY(a6),d1	*
	bgt	skip			*
	cmp.l	CRECT+LMINX(a6),d0	*
	blt	skip			*

	move.l	d0,d1		*d1 = �`�������̉E�[x���W
	neg.l	d0		*d0 = �`�������̍��[x���W

	cmp.l	CRECT+LMAXX(a6),d0	*���S�ɃE�B���h�E�O�̏ꍇ��e��
	bgt	skip			*

	move.l	CRECT+LMINX(a6),d2	*�E�B���h�E���[�ŃN���b�v
	cmp.l	d2,d0			*
	bge	minskp			*
	sub.l	d2,d0			*
	suba.l	d0,a0			*���؂�����������
	suba.l	d0,a0			*�@G-RAM�A�h���X���X�V����
	move.l	d2,d0			*

minskp:	move.l	CRECT+LMAXX(a6),d2	*�E�B���h�E�E�[�ŃN���b�v
	cmp.l	d2,d1			*
	ble	maxskp			*
	move.l	d2,d1			*

maxskp:	sub.l	d0,d1		*d1 = �`�������̒���-1
	addq.w	#1,d1		*d1 = �`�������̒���
	bclr.l	#0,d1		*��H
	beq	notodd		*
	move.w	d7,(a0)+	*�@��s�N�Z���̕�
notodd:	neg.w	d1		*

	move.l	d7,d0
	jsr	0(a5,d1.w)	*���������`��

skip:	rts

	.end
