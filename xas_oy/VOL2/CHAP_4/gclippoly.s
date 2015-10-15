*	���p�`��cliprect�Ŏw�肳�ꂽ��`�̈�ŃN���b�s���O����i�b�p���C���Łj

	.include	rect.h
*
	.xdef	gclippoly
	.xdef	_gclippoly
	.xref	cliprect
*
	.text
	.even
*
gclippoly:
_gclippoly:
POINTS	=	8
POINTS2 =	12
	link	a6,#0
	movem.l	d0-d7/a0-a5,-(sp)

	movem.l	POINTS(a6),a1-a2
				*a1 = �N���b�s���O�O�̓_
				*a2 = �N���b�s���O��̓_
	lea.l	cliprect,a0	*a0 = �N���b�s���O�E�B���h�E

	clr.w	(a2)+		*���ɒ��_�̐���0�ɂ��Ă���

	move.w	(a1)+,d7	*d7 = �_�̐�
	beq	retn		*�_���^�����Ă��Ȃ�
	subq.w	#1,d7		*
	bne	do		*

			*�P�_�����^�����Ă��Ȃ��ꍇ
	movem.w	(a1),d0-d1
	cmp.w	MINY(a0),d1	*y��MINY �Ȃ�
	blt	done		*�@�s��
	cmp.w	MAXY(a0),d1	*y��MAXY �Ȃ�
	bgt	done		*�@�s��
	move.w	d0,(a2)+	*(x,y)��o�^����
	move.w	d1,(a2)+	*
	bra	done		*�@�N���b�s���O����

			*�Q�_�ȏ�^�����Ă����ꍇ
do:	moveq.l	#0,d0
	move.w	d7,d0
	lsl.l	#2,d0

	movem.w	0(a1,d0.l),d2-d3
				*(d2,d3) = �Ō�̓_
				*	 = �ŏ��̓_�ɂƂ��Ă�
				*	   ���O�̓_
	movea.w	#$8000,a5	*a5 = �Q�^
	bra	lpent
			*�N���b�s���O����_��(x,y)
			*���O�̓_��(x0,y0)�Ƃ���
loop:	movem.w	(a1)+,d2-d3	*(d2,d3) = (x0,y0)
lpent:	movem.w	(a1),d0-d1	*(d0,d1) = (x,y)
	moveq.l	#0,d4		*d4 = ���O�̓_�������ǂ����̃t���O
				*�@�@�i���ɉ��ƍl����j

cminy:	move.w	MINY(a0),d5	*d5 = MINY
	cmp.w	d5,d1		*y��MINY�Ȃ�
	blt	cminy0		*�@(x,y)��MINY�ŃN���b�v

	cmp.w	d5,d3		*y >= MINY ���� y0 >= MINY �Ȃ�
	bge	cmaxy		*�@MINY�ł̃N���b�s���O�͕s�v

			*(x,y)�͉���(x0,y0)�͕s��
	exg.l	d0,d2		*(x0,y0)��MINY�ŃN���b�v
	exg.l	d1,d3		*
	bsr	minyclip	*
	exg.l	d0,d2		*
	exg.l	d1,d3		*
	moveq.l	#-1,d4		*(x0,y0)���N���b�s���O����
	bra	cmaxy

cminy0:	cmp.w	d5,d3		*y��MINY ���� y0��MINY �Ȃ�
	blt	next		*�@�ӂ͊��S�s��

			*(x,y)�͕s����(x0,y0)�͉�
	bsr	minyclip	*(x,y)��MINY�ŃN���b�v

cmaxy:	move.w	MAXY(a0),d5	*d5 = MAXY
	addq.w	#1,d5		*d5 = MAXY+1 = MAXY'
				*�igfillpoly�̎蔲���Ή��j
	cmp.w	d5,d1		*y��MAXY'�Ȃ�
	bgt	cmaxy0		*�@(x,y)��MAXY'�ŃN���b�v

	cmp.w	d5,d3		*y��MAXY' ���� y0��MAXY'�Ȃ�
	ble	setp		*�@MAXY'�ŃN���b�s���O�͕s�v

			*(x,y)�͉���(x0,y0)�͕s��
	exg.l	d0,d2		*(x0,y0)��MAXY'�ŃN���b�v
	exg.l	d1,d3		*
	bsr	maxyclip	*
	exg.l	d0,d2		*
	exg.l	d1,d3		*
	moveq.l	#-1,d4		*(x0,y0)���N���b�s���O����
	bra	setp0

cmaxy0:	cmp.w	d5,d3		*y��MAXY' ���� y0��MAXY'�Ȃ�
	bgt	next		*�@�ӂ͊��S�s��

			*(x,y)�͕s����(x0,y0)�͉�
	bsr	maxyclip	*(x,y)��MINY�ŃN���b�v

setp:	tst.w	d4		*(x0,y0)���N���b�s���O�����̂Ȃ�
	beq	setp1		*
setp0:	move.w	d2,(a2)+	*�@�N���b�s���O����(x0,y0)��
	move.w	d3,(a2)+	*�@�o�^����
setp1:	move.w	d0,(a2)+	*�N���b�s���O����(x,y)��o�^����
	move.w	d1,(a2)+	*

next:	dbra	d7,loop		*���ׂĂ̓_�ɂ��ČJ��Ԃ�

	movea.l	POINTS2(a6),a1	*�ŏ��̓_��
	move.w	2(a1),(a2)+	*�@�o�b�t�@�Ō�ɏ�������
	move.w	4(a1),(a2)+	*�@�}�`�����

done:	movea.l	POINTS2(a6),a1	*�N���b�s���O���
	addq.l	#2,a1		*
	suba.l	a1,a2		*
	move.l	a2,d0		*
	lsr.l	#2,d0		*�@�_�̐��𐔂���

	swap.w	d0		*�_�̐���65536�ȏ�Ȃ�
	tst.w	d0		*
	beq	setn		*
	moveq.l	#0,d0		*�@�듮��h�~��0�ɂ��Ă��܂�

setn:	swap.w	d0		*
	move.w	d0,-(a1)	*�_�̐����L�^����

retn:	movem.l	(sp)+,d0-d7/a0-a5
	unlk	a6
	rts
*
maxyclip:		*MAXY'�ŃN���b�s���O����
	cmp.w	d5,d3		*���Α��̒[�_��MAXY'��Ȃ�
	beq	just		*�@���̓_�����߂�_

	move.w	d2,a3		*���Α��̒[�_��
	move.w	d3,a4		*�@���W��ۑ�
	add.w	a5,d0		*���[�_��MAXY'��
	add.w	a5,d1		*�@8000h�̃Q�^�𕢂�����
	add.w	a5,d2		*�@������������
	add.w	a5,d3		*
	add.w	a5,d5		*

			*�N���b�s���O����_��(x1,y1)
			*���Α��̓_��(x2,y2)
			*���҂̒��_��(mx,my)�Ƃ���
maxylp:	move.w	d1,d6		*
	add.w	d3,d6		*
	roxr.w	#1,d6		*d6 = my = ���_��y���W
	cmp.w	d5,d6		*my = MAXY'�Ȃ�
	beq	yclipq		*�@�N���b�s���O����
	bcs	maxy0
			*y1 �� my �� MAXY' �� y2
	move.w	d6,d1		*y1 = my
	add.w	d2,d0		*
	roxr.w	#1,d0		*x1 = mx
	bra	maxylp		*�@�ƍX�V���ČJ��Ԃ�

			*y1 �� MAXY' �� my �� y2
maxy0:	move.w	d6,d3		*y2 = my
	add.w	d0,d2		*
	roxr.w	#1,d2		*x1 = mx
	bra	maxylp		*�@�ƍX�V���ČJ��Ԃ�
*
minyclip:		*MINY�ŃN���b�s���O����
	cmp.w	d5,d3
	beq	just

	move.w	d2,a3
	move.w	d3,a4
	add.w	a5,d0
	add.w	a5,d1
	add.w	a5,d2
	add.w	a5,d3
	add.w	a5,d5

minylp:	move.w	d1,d6
	add.w	d3,d6
	roxr.w	#1,d6
	cmp.w	d5,d6
	beq	yclipq
	bcc	miny0

	move.w	d6,d1
	add.w	d2,d0
	roxr.w	#1,d0
	bra	minylp

miny0:	move.w	d6,d3
	add.w	d0,d2
	roxr.w	#1,d2
	bra	minylp

yclipq:	move.w	d6,d1		*d1 = ���߂�y���W
	add.w	d2,d0		*
	roxr.w	#1,d0		*d0 = ����ɑΉ�����x���W

	sub.w	a5,d0		*�Q�^��E������
	sub.w	a5,d1		*
	move.w	a3,d2		*���Α��̓_��
	move.w	a4,d3		*�@���W�𕜋A
	rts
*
just:	move.w	d2,d0		*���Α��̓_��
	move.w	d3,d1		*�@���傤�ǋ��߂�_
	rts

	.end

�C������

92-01-01��
�_�̐���0�`1�̂Ƃ�����ɕs�����������̂��C��

93-09-01��
GCLIB.A�̃t���Z�b�g���ɔ����C�b�p�̊O����`��ǉ�
