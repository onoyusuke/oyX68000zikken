*	�p�^�[����C�ӎl�p�`�ɂ͂ߍ���Ńv�b�g����i��P�Łj

	.include	gconst.h
	.include	gmacro.h
*
	.xdef	gtput
	.xref	gramadr
	.xref	cliprect
*
PSET	macro	X,Y,COL,ADR	*�N���b�s���O����
	local	skip		*�@�_��ł}�N��
	lea.l	cliprect,a5	*
	cmp.w	(a5)+,X		*
	blt	skip		*
	cmp.w	(a5)+,Y		*
	blt	skip		*
	cmp.w	(a5)+,X		*
	bgt	skip		*
	cmp.w	(a5)+,Y		*
	bgt	skip		*
	move.w	COL,ADR		*
skip:				*
	.endm			*

*
	.offset	0	*gtput�̈����\��
*
X0:	.ds.w	1	*�`�����W	A
Y0:	.ds.w	1	*
X1:	.ds.w	1	*		B
Y1:	.ds.w	1	*
X2:	.ds.w	1	*		C
Y2:	.ds.w	1	*
X3:	.ds.w	1	*		D
Y3:	.ds.w	1	*
PAT:	.ds.l	1	*�p�^�[���A�h���X
XL:	.ds.w	1	*�p�^�[���̉��̒���-1
YL:	.ds.w	1	*�p�^�[���̏c�̒���-1
*
	.offset	0	*���������p���[�N
*
X:	.ds.w	1	*x���W
Y:	.ds.w	1	*y���W
DX:	.ds.w	1	*y�X�V����e��������萔
DY:	.ds.w	1	*x�X�V����e�ɉ�����萔
SX:	.ds.w	1	*x��������
SY:	.ds.w	1	*y��������
E:	.ds.w	1	*�덷��e
LEN:	.ds.w	1	*�����̃s�N�Z����-1
SDX:	.ds.w	1	*���x���ߗpe�␳�l
SDY:	.ds.w	1	*���x���ߗpe����
EDG:
*
	.offset	-EDG*2-2*4	*�X�^�b�N�t���[��
*
WORKTOP:
ST:	.ds.b	EDG	*�n�_�֘A���[�N
ED:	.ds.b	EDG	*�I�_�֘A���[�N
PHE:	.ds.w	1	*�����X�P�[�����O�pe�����l
PHDY:	.ds.w	1	*�����X�P�[�����O�pe����
PVDX:	.ds.w	1	*�����X�P�[�����O�pe�␳�l
PVDY:	.ds.w	1	*�����X�P�[�����O�pe����
_A6:	.ds.l	1	*0
_SP:	.ds.l	1	*4
ARGPTR:	.ds.l	1	*8
*
	.text
	.even
*
gtput:
	link	a6,#WORKTOP
	movem.l	d0-d7/a0-a5,-(sp)

	movea.l	ARGPTR(a6),a5	*a5=������

	movem.w	X0(a5),d0-d3	*AB�𔭐����邽�߂�
	lea.l	ST(a6),a0	*�i���n�_�̌o�H�����߂邽�߂́j
	bsr	init		*�@�덷������̏�����
	movea.l	a1,a3		*a3=�n�_���ړ�����T�u���[�`��

	movem.w	X3(a5),d0-d1	*DC�𔭐����邽�߂�
	movem.w	X2(a5),d2-d3	*�i���I�_�̌o�H�����߂邽�߂́j
	lea.l	ED(a6),a0	*�@�덷������̏�����
	bsr	init		*
	movea.l	a1,a4		*a4=�I�_���ړ�����T�u���[�`��

	move.w	ST+LEN(a6),d7	*d7=AB�̒���-1
	move.w	ED+LEN(a6),d0	*d0=DC�̒���-1
	lea.l	xline-xlinex(a3),a3
				*AB�̕��������Ɖ��肵
				*�@���Ɏn�_�̑��x���߂��E��

	cmp.w	d0,d7		*AB��DC�̒��������������
	beq	equskp		*�@�n�_,�I�_�Ƃ��ɑ��x���ߕs�v
	bcc	maxskp		*AB�̕����������
				*�@�n�_�ɂ��Ă͑��x���ߕs�v
				*DC�̕����������
				*�@�I�_�ɂ��Ă͑��x���ߕs�v
	move.w	d0,d7		*d7=DC�̒���-1
	lea.l	xlinex-xline(a3),a3	*�n�_�̑��x���߂𕜊�����

equskp:	lea.l	xline-xlinex(a4),a4	*�I�_�̑��x���߂��E��

maxskp:	move.w	d7,d5		*d7=d5=AB��DC�̒����̒�����
	neg.w	d5		*d5=�n�_�i�܂��͏I�_�j��
				*�@�ړ����x���ߗpe

	move.w	d7,d0		*
	add.w	d0,d0		*
	move.w	d0,ST+SDX(a6)	*�n�_�ړ����x���ߗpe�␳�l
	move.w	d0,ED+SDX(a6)	*�I�_�ړ����x���ߗpe�␳�l
	move.w	d0,PVDX(a6)	*�p�^�[���𐂒��ɂȂ��鑬�x��
				*�@���ߗpe�␳�l

	move.w	YL(a5),d0	*d0=�p�^�[����-1
	move.w	d0,d6		*d6=�p�^�[���𐂒��ɂȂ��鑬�x��
	neg.w	d6		*�@���ߗpe
	tst.w	d7		*
	bne	fix0		*�`��捂���P�s�N�Z�������Ȃ��ꍇ��
	move.w	d7,d0		*�@���܍��킹
fix0:	add.w	d0,d0		*�p�^�[���𐂒��ɂȂ��鑬�x��
				*�@���ߗpe����
	move.w	d0,PVDY(a6)	*

	movea.l	PAT(a5),a1	*a1=�p�^�[���擪�A�h���X

	move.w	XL(a5),d0	*d0=�p�^�[����-1
	movea.w	d0,a5		*a5=�p�^�[���P���C�����o�C�g��
	addq.l	#1,a5		*
	adda.l	a5,a5		*

	move.w	d0,d1		*�p�^�[���𐅕��ɂȂ��鑬�x��
	add.w	d1,d1		*�@���ߗpe����
	move.w	d1,PHDY(a6)	*

	neg.w	d0		*�p�^�[���𐅕��ɂȂ��鑬�x��
	move.w	d0,PHE(a6)	*�@���ߗpe

	movem.w	ED+X(a6),d2-d3	*(d2.w,d3.w)=�I�_���W
	move.w	ED+E(a6),d4	*d4.w=�I�_�ړ��o�H����pe
	swap.w	d2		*���ꂼ�ꃌ�W�X�^��
	swap.w	d3		*�@��ʃ��[�h�ɕۑ�
	swap.w	d4		*
	move.w	ST+X(a6),d2	*(d2.w,d3.w)=�n�_���W
	move.w	ST+Y(a6),d3	*
	move.w	ST+E(a6),d4	*d4.w=�n�_�ړ��o�H����pe

loop:
*	d2.l	�n�_,�I�_��x���W
*	d3.l	�n�_,�I�_��y���W
*	d4.l	�n�_,�I�_�ړ��o�H����pe
*		�i��ʃ��[�h�F�I�_/���ʃ��[�h�F�n�_�j
*	d5.w	�n�_�i�܂��͏I�_�j�ړ����x���ߗpe
*	d6.w	�p�^�[���𐂒��ɂȂ��鑬�x�̒��ߗpe
*	d7.w	���[�v�J�E���^
*	a1	�Q�ƒ��̃p�^�[���㐅���������[�A�h���X
*	a3	�n�_���ړ�����T�u���[�`��
*	a4	�I�_���ړ�����T�u���[�`��
*	a5	�p�^�[���P���C���o�C�g��

	move.w	d2,d0		*d0=�n�_��x���W
	move.w	d3,d1		*d1=�n�_��y���W

	swap.w	d2		*d2.w=�I�_��x���W
	swap.w	d3		*d3.w=�I�_��y���W
	swap.w	d4

	bsr	put1line	*�P���C�����`�悷��

	lea.l	ED(a6),a0	*�I�_���X�V����
	jsr	(a4)		*

	swap.w	d2
	swap.w	d3
	swap.w	d4

	lea.l	ST(a6),a0	*�n�_���X�V����
	jsr	(a3)		*

	add.w	PVDY(a6),d6	*�ړ����x���l������
	ble	nextln		*�@�p�^�[���̐��������Q�ƈʒu��
				*�@�ړ�����
skppat:	adda.l	a5,a1		*
	sub.w	PVDX(a6),d6	*
	bgt	skppat		*

nextln:	dbra	d7,loop		*�K�v�Ȃ����J��Ԃ�

	movem.l	(sp)+,d0-d7/a0-a5
	unlk	a6
	rts

*
*	�P���C�����`�悷��
*
put1line:
	movem.l	d2-d7/a1/a3-a5,-(sp)

	jsr	gramadr		*a0=�n�_��G-RAM�A�h���X

	sub.w	d0,d2		*�n�_�ƏI�_�����Ԑ�����
	move.w	d2,d4		*�@�������邽�߂�
	ABS	d2		*�@�p�����[�^�̏�����
	move.w	d2,a2		*
	add.w	a2,a2		*
	SGN	d4		*
				*
	sub.w	d1,d3		*
	move.w	d3,d5		*
	ABS	d3		*
	move.w	d3,a3		*
	add.w	a3,a3		*
	SGN	d5		*

	move.w	d5,d6		*d6=y���W���X�V�����Ƃ���
	moveq.l	#GSFTCTR,d7	*�@G-RAM�A�h���X�̕ω���
	asl.w	d7,d6		*

	move.w	PHDY(a6),a4	*�p�^�[���𐅕��ɂȂ��鑬�x��
				*�@���ߗpe����

	cmp.w	d3,d2		*�����̌X���ɉ�����
	bcs	yput		*�@������U�蕪����

xput:			*�Ȃ��炩�ȌX���̐����֒���t����ꍇ
	move.w	d2,d7		*d7=���[�v�J�E���^
	neg.w	d2		*d2=�덷��e
	bne	fix1		*�`��敝���P�s�N�Z�������Ȃ��ꍇ��
	move.w	d2,a4		*�@���܍��킹
fix1:	move.w	PHE(a6),d3	*�p�^�[���𐅕��ɂȂ��鑬�x��
				*�@���ߗpe

xloop:	PSET	d0,d1,(a1),(a0)	*�P�s�N�Z���`��

	add.w	a4,d3		*�ړ����x���l������
	ble	xput1		*�@�p�^�[���̐��������Q�ƈʒu��
				*�@�X�V����
xput0:	addq.l	#2,a1		*
	sub.w	a2,d3		*
	bgt	xput0		*

xput1:	add.w	d4,d0		*x+=sx
	adda.w	d4,a0		*
	adda.w	d4,a0		*

	add.w	a3,d2		*e+=dy
	bmi	xnext

	add.w	d5,d1		*y+=sy
	adda.w	d6,a0		*

	sub.w	a2,d2		*e-=dx

xnext:	dbra	d7,xloop

	movem.l	(sp)+,d2-d7/a1/a3-a5
	rts

yput:			*�}�ȌX���̐����֒���t����ꍇ
	move.w	d3,d2
	move.w	d2,d7
	neg.w	d2
	bne	fix2
	move.w	d2,a4
fix2:	move.w	PHE(a6),d3

yloop:	PSET	d0,d1,(a1),(a0)

	add.w	a4,d3
	ble	yput1

yput0:	sub.w	a3,d3
	addq.l	#2,a1
	bgt	yput0

yput1:	add.w	d5,d1
	adda.w	d6,a0

	add.w	a2,d2
	bmi	ynext

	add.w	d4,d0
	adda.w	d4,a0
	adda.w	d4,a0

	sub.w	a3,d2

ynext:	dbra	d7,yloop

	movem.l	(sp)+,d2-d7/a1/a3-a5
	rts

*
*	AB,DC�����̂��߂̏�����
*
init:
	sub.w	d0,d2		*d2=d4=x1-x0
	move.w	d2,d4		*
	ABS	d2		*d2=dx=abs(x1-x0)
	SGN	d4		*d4=sx=sgn(x1-x0)

	sub.w	d1,d3		*d3=d5=y1-y0
	move.w	d3,d5		*
	ABS	d3		*d3=dy=abs(y1-y0)
	SGN	d5		*d5=sy=sgn(y1-y0)

	cmp.w	d3,d2		*�X���ɉ�����
	bcs	yinit		*�@������U�蕪����

			*dx��dy�̏ꍇ
xinit:	move.w	d2,d6		*d6=dx
	neg.w	d6		*d6=e=-dx
	add.w	d3,d2		*d2=dx+dy
	move.w	d2,d7		*d7=dx+dy
				*�@=�����̃s�N�Z����-1
	add.w	d2,d2		*d2=2dx+2dy
				*�@=y���W�X�V����e�␳�l
	add.w	d3,d3		*d3=2dy
				*�@=x���W�X�V����e����
	movem.w	d0-d7,X(a0)	*���[�N�Ɋi�[����

	move.w	d2,SDY(a0)	*���x���ߗpe����
	lea.l	xlinex(pc),a1	*a1=�X�����Ȃ��炩�Ȑ�����
				*�@�P�s�N�Z������������
				*�@�T�u���[�`��
	rts

			*dx��dy�̏ꍇ
yinit:	move.w	d3,d6		*d6=dy
	neg.w	d6		*d6=e=-dy
	add.w	d2,d3		*d3=dx+dy
	move.w	d3,d7		*d7=dx+dy
				*  =�����̃s�N�Z����-1
	add.w	d2,d2		*d2=2dx
				*�@=x���W�X�V����e����
	add.w	d3,d3		*d3=2dx+2dy
				*�@=y���W�X�V����e�␳�l
	movem.w	d0-d7,X(a0)	*���[�N�Ɋi�[����

	move.w	d3,SDY(a0)	*���x���ߗpe����
	lea.l	ylinex(pc),a1	*a1=�X�����}�Ȑ�����
				*�@�P�s�N�Z������������
				*�@�T�u���[�`��
	rts

*
*	�ړ����x���l�����Ďn�_,�I�_���ړ�����
*	�i�Ȃ��炩�ȌX���̐����p�j
*
xlinex:	add.w	SDY(a0),d5	*���x�̒���
	bmi.s	xline1		*
				*
	sub.w	SDX(a0),d5	*

xline:	add.w	DY(a0),d4	*e+=2dy
	bmi	xline0

	add.w	SY(a0),d3	*y+=sy
	sub.w	DX(a0),d4	*e-=2(dx+dy)
	rts

xline0:	add.w	SX(a0),d2	*x+=sx
xline1:	rts

*
*	�ړ����x���l�����Ďn�_,�I�_���ړ�����
*	�i�}�ȌX���̐����p�j
*
ylinex:	add.w	SDY(a0),d5	*���x�̒���
	bmi.s	yline1		*
				*
	sub.w	SDX(a0),d5	*

yline:	add.w	DX(a0),d4	*e+=2dx
	bmi	yline0

	add.w	SX(a0),d2	*x+=sx
	sub.w	DY(a0),d4	*e-=2(dx+dy)
	rts

yline0:	add.w	SY(a0),d3	*y+=sy
yline1:	rts

	.end
