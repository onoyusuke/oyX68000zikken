*	�O���t�B�b�N�摜���k������

	.include	gconst.h
	.include	gmacro.h
*
	.xdef	gshrink
	.xref	gramadr
	.xref	gcliprect
*
FPACK	macro	callno
	.dc.w	callno
	.endm

__UDIV	equ	$fe05
*
GCM	macro	M,N	*�ő���񐔂����߂�}�N��
	local	loop
	move.w	N,d0
loop:	moveq.l	#0,N
	move.w	d0,N
	divu.w	M,N
	move.w	M,d0
	swap.w	N
	move.w	N,M
	bne	loop
	.endm
*
	.offset	0	*gshrink�̈����\��
*
X0:	.ds.w	1	*�`�����W
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
XL:	.ds.w	1	*�k����̉��s�N�Z����-1
YL:	.ds.w	1	*�k����̏c�s�N�Z����-1
TEMP:	.ds.l	1	*��Ɨp���[�N�i�ő�U�j�o�C�g�j
*
	.offset	-42
*
WORK:
EX:	.ds.l	1
DEX:	.ds.l	1
CEX:	.ds.l	1
EY:	.ds.l	1
DEY:	.ds.l	1
CEY:	.ds.l	1
XSTEP:	.ds.w	1
YSTEP:	.ds.w	1
DENOM:	.ds.l	1
DXL:	.ds.w	1
SXL:	.ds.w	1
PATSIZ:	.ds.w	1
BUFF:	.ds.l	1
_a6:	.ds.l	1	*�}0
_a7:	.ds.l	1
ARGPTR:	.ds.l	1
*
	.text
	.even
*
gshrink:
	link	a6,#WORK
	movem.l	d0-d7/a0-a5,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = ������

	movem.w	(a1)+,d0-d3/a2-a3
				*d0�`d3=�`��͈͂̍��W
				*a2=�k���㉡�s�N�Z����-1
				*a3=�k����c�s�N�Z����-1
	movea.l	(a1),a4		*a4=�P���C���o�b�t�@
	move.l	a4,BUFF(a6)	*

	jsr	gcliprect	*�N���b�s���O����
	bne	done		*Z=0�Ȃ�`��̕K�v�Ȃ�

	jsr	gramadr		*a0=�`��捶��G-RAM�A�h���X
	movea.l	a0,a1

	sub.w	d0,d2		*d2=�`��͈͂̉��s�N�Z����-1
	beq	done
	sub.w	d1,d3		*d3=�`��͈͂̏c�s�N�Z����-1
	beq	done

	cmp.w	a2,d2		*�g��͂ł��Ȃ�
	bcs	done		*
	cmp.w	a3,d3		*
	bcs	done		*

	move.w	a2,d7		*
	addq.w	#1,d7		*
	add.w	d7,d7		*
	move.w	d7,PATSIZ(a6)	*�p�^�[���P���C���̃o�C�g��

	move.w	d2,SXL(a6)	*�k��������-1
	move.w	a2,DXL(a6)	*x���[�v�J�E���^�����l
	move.w	a3,d7		*d7=y���[�v�J�E���^�����l

	swap.w	d7		*d7�̉��ʃ��[�h��Ҕ�
	move.w	d2,d6
	move.w	d3,d7
	addq.w	#1,a2		*a2=�p�^�[��
	addq.w	#1,a3

	addq.w	#1,d2		*x�����k������񕪂���
	move.w	d2,d1		*
	move.w	a2,d4		*
	GCM	d1,d4		*
	divu.w	d0,d2		*���q
	move.l	a2,d4		*
	divu.w	d0,d4		*����

	addq.w	#1,d3		*y�����k������񕪂���
	move.w	d3,d1		*
	move.w	a3,d5		*
	GCM	d1,d5		*
	divu.w	d0,d3		*���q
	move.l	a3,d5		*
	divu.w	d0,d5		*����

	move.w	d2,d0		*
	mulu.w	d3,d0		*
	move.l	d0,DENOM(a6)	*���ς���T�u�s�N�Z����

	move.w	d2,d4
	subq.w	#1,d2		*���ς���T�u�s�N�Z����
	move.w	d2,XSTEP(a6)	*�@�������̐�-1
	move.w	d3,d5
	subq.w	#1,d3		*���ς���T�u�s�N�Z����
	move.w	d3,YSTEP(a6)	*�@�c�����̐�-1

	move.w	a2,d0		*x�Ɋւ���p�����[�^�v�Z
	mulu.w	d4,d0		*���^���g��
	subq.l	#1,d0		*
	neg.l	d0		*
	move.l	d0,EX(a6)	*
	neg.l	d0		*
	add.l	d0,d0		*
	move.l	d0,CEX(a6)	*
	move.w	d6,d2		*
	add.l	d2,d2		*
	move.l	d2,DEX(a6)	*

	move.w	a3,d0		*y�Ɋւ���p�����[�^�v�Z
	mulu.w	d5,d0		*���^���g��
	subq.l	#1,d0		*
	neg.l	d0		*
	move.l	d0,EY(a6)	*
	neg.l	d0		*
	add.l	d0,d0		*
	move.l	d0,CEY(a6)	*
	move.w	d7,d3		*
	add.l	d3,d3		*
	move.l	d3,DEY(a6)	*debug 94-06-28

	bsr	dergb		*�ŏ��̃��C����rgb�ɕ���
	movea.l	a5,a2		*a2=rgb���Ƃ̗ݎZ�p�o�b�t�@

	move.l	EY(a6),d5
	swap.w	d7		*d7�𕜋A

yloop:	move.l	a0,-(sp)

	moveq.l	#0,d0		*rgb���Ƃ̗ݎZ�p�o�b�t�@��
	movea.l	a2,a5		*�@0�ŏ�����
	move.w	DXL(a6),d4	*
clrlp:	move.l	d0,(a5)+	*
	move.l	d0,(a5)+	*
	move.l	d0,(a5)+	*
	dbra	d4,clrlp	*

	move.w	YSTEP(a6),d6
yloop2:	movea.l	a2,a4
	movea.l	BUFF(a6),a5

	swap.w	d6
	swap.w	d7
	movem.l	d5/a1-a3,-(sp)

	movem.w	(a5)+,a0-a2	*a0�`a2=�Q�Ƃ���_��brg

	move.l	DEX(a6),d3
	move.l	CEX(a6),a3
	move.w	XSTEP(a6),d5

	move.l	EX(a6),d4
	move.w	DXL(a6),d7
xloop:	moveq.l	#0,d0		*B
	moveq.l	#0,d1		*R
	moveq.l	#0,d2		*G
	move.w	d5,d6
xloop2:	add.l	a0,d0		*B
	add.l	a1,d1		*R
	add.l	a2,d2		*G

	add.l	d3,d4		*EX += DEX
	bmi	xnext2
	sub.l	a3,d4		*EX -= CEX
	movem.w	(a5)+,a0-a2	*�Q�ƌ�x���W��i�߂�
xnext2:	dbra	d6,xloop2

xnext:	add.l	d0,(a4)+	*R
	add.l	d1,(a4)+	*G
	add.l	d2,(a4)+	*B
	dbra	d7,xloop

	movem.l	(sp)+,d5/a1-a3
	swap.w	d7
	swap.w	d6

	add.l	DEY(a6),d5	*EY += DEY
	bmi	ynext2
	sub.l	CEY(a6),d5	*EY -= CEY
	lea.l	GNBYTE(a1),a1	*�Q�ƌ�y���W��i�߂�

	move.w	d6,d0		*�����������O�ł����
	or.w	d7,d0		*�@���̉��̃��C����
	beq	ynext		*�@rgb�ɕ�������K�v�͂Ȃ�

	bsr	dergb		*�P���C����rgb�ɕ�������

ynext2:	dbra	d6,yloop2

ynext:	movea.l	(sp)+,a0

	movea.l	a0,a3
	movea.l	a2,a5
	move.l	DENOM(a6),d1	*d1=���ς̕���

	move.w	DXL(a6),d6
drawlp:	move.l	(a5)+,d0
	FPACK	__UDIV
	move.w	d0,d2		*B
	move.l	(a5)+,d0
	FPACK	__UDIV
	move.w	d0,d3		*R
	move.l	(a5)+,d0
	FPACK	__UDIV		*G
	move.w	d0,d4
	RGB	d2,d3,d4,d0	*�J���[�R�[�h�ɍ\������
	move.w	d0,(a3)+	*�@��������
	dbra	d6,drawlp	*�������J��Ԃ�

	lea.l	GNBYTE(a0),a0	*�`���y���W��i�߂�
	dbra	d7,yloop	*�������J��Ԃ�

done:	movem.l	(sp)+,d0-d7/a0-a5
	unlk	a6
	rts

*
*	�P���C����rgb�ɕ�������
*	�o�b�t�@�ɓW�J����
dergb:
	movea.l	a1,a3
	movea.l	BUFF(a6),a5
	move.w	SXL(a6),d4
dergb0:	move.w	(a3)+,d0
	DERGB	d0,d1,d2,d3
	movem.w	d1-d3,(a5)
	addq.l	#6,a5
	dbra	d4,dergb0
	rts

	.end

�C������

94-07-01��
DEY��DEX�Ɩ������ɓ������Ȃ��Ă��܂��̂��C��
