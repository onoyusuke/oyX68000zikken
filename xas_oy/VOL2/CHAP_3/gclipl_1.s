*	�����̋�`�̈�N���b�s���O�i���_�����j

	.include	rect.h
*
	.xdef	gclipline
	.xref	cliprect
	.xref	ucliprect
*
*	�[�_���ރR�[�h
*
LT_MINX_BIT	equ	0
GT_MAXX_BIT	equ	1
LT_MINY_BIT	equ	2
GT_MAXY_BIT	equ	3
*
LT_MINX		equ	1
GT_MAXX		equ	2
LT_MINY		equ	4
GT_MAXY		equ	8

*
*	�[�_���ރR�[�h�����߂�}�N��
*
CHKVIS	macro	XX,YY,CODE
	local	skip0,skip1,skip2,skip3
	movea.l	a0,a1
	moveq.l	#0,CODE
	cmp.w	(a1)+,XX
	bge	skip0
	addq.w	#LT_MINX,CODE
skip0:	cmp.w	(a1)+,YY
	bge	skip1
	addq.w	#LT_MINY,CODE
skip1:	cmp.w	(a1)+,XX
	ble	skip2
	addq.w	#GT_MAXX,CODE
skip2:	cmp.w	(a1)+,YY
	ble	skip3
	addq.w	#GT_MAXY,CODE
skip3:	
	.endm
*
	.text
	.even
*
*	����(d0.w,d1.w)-(d2.w,d3.w)��
*	cliprect�Ŏw�肳�ꂽ��`�̈�ŃN���b�v����
*	���S�s���̏ꍇ��Z=0�Ŗ߂�
gclipline:
	lea.l	cliprect,a0	*�N���b�s���O�͈�
	CHKVIS	d0,d1,d6	*d6 = �n�_�̕��ރR�[�h
	CHKVIS	d2,d3,d7	*d7 = �I�_�̕��ރR�[�h

	add.w	d7,d6		*d6��d7��
				*�@�Ƃ���0�ł����
	beq	done		*�@�����͊��S�ɉ�
	sub.w	d7,d6		*

	move.w	d6,d4		*d6��d7��and��
	and.w	d7,d4		*�@��0�ł����
	bne	done		*�@�����͊��S�ɕs��

	lea.l	ucliprect,a0	*�N���b�s���O�͈́i�Q�^�����j
	move.w	#$8000,d4	*$8000�̃Q�^�𗚂�����
	add.w	d4,d0		*
	add.w	d4,d1		*
	add.w	d4,d2		*
	add.w	d4,d3		*

	tst.w	d6		*�n�_�͉����H
	beq	skip1		*�@���Ȃ�N���b�s���O�s�v
	bsr	gcliplinesub	*�n�_���N���b�v
	bne	done		*�Ȃ����s��������

skip1:	move.w	d7,d6		*�I�_�͉����H
	beq	skip2		*�@���Ȃ�N���b�s���O�s�v
	exg.l	d0,d2		*�n�_�ƏI�_�����ւ���
	exg.l	d1,d3		*
	bsr	gcliplinesub	*�I�_���N���b�v
	bne	done		*�Ȃ����s��������
	exg.l	d0,d2		*���ւ����n�_�ƏI�_��
	exg.l	d1,d3		*���ɖ߂�

skip2:	move.w	#$8000,d4	*�Q�^��E������
	sub.w	d4,d0		*
	sub.w	d4,d1		*
	sub.w	d4,d2		*
	sub.w	d4,d3		*

	moveq.l	#0,d4		*Z = 1
done:	rts

*
*	�Е��̒[�_(d0.w,d1.w)���N���b�v����
*
gcliplinesub:
	move.w	d0,a1		*�N���b�s���O�O�̍��W��
	move.w	d1,a2		*�@�o���Ă���
	move.w	d2,a3		*
	move.w	d3,a4		*
	moveq.l	#2-1,d4		*�N���b�s���O�񐔃J�E���^
	move.w	d6,ccr		*----NZVC
	bcs	minxclip	*bit 0 = 1�Ȃ�΍��̕ӂɃN���b�v
	bvs	maxxclip	*bit 1 = 1�Ȃ�ΉE�̕ӂɃN���b�v
	beq	minyclip	*bit 2 = 1�Ȃ�Ώ�̕ӂɃN���b�v
*	bmi	maxyclip	*bit 3 = 1�Ȃ�Ή��̕ӂɃN���b�v

*
*	MAXY�ŃN���b�v����
*
maxyclip:		*�P��ڂ̃G���g��
	move.w	MAXY(a0),d5
	cmp.w	d5,d3
	bne	maxylp
	move.w	d2,d0
	move.w	d3,d1
	bra	yclipn
maxylp:	move.w	d1,d6
	add.w	d3,d6
	roxr.w	#1,d6
	cmp.w	d5,d6
	beq	yclipq
	bcs	maxy0
	move.w	d6,d1
	add.w	d2,d0
	roxr.w	#1,d0
	bra	maxylp
maxy0:	move.w	d6,d3
	add.w	d0,d2
	roxr.w	#1,d2
	bra	maxylp
maxyclip2:		*�Q��ڈȍ~�̃G���g��
	subq.w	#1,d4
	bcs	outofscrn
	cmp.w	MAXY(a0),d3
	bhi	outofscrn
	move.w	a1,d0
	move.w	a2,d1
	bra	maxyclip
outofscrn:
	moveq.l	#-1,d4		*Z = 0
	rts

*
*	MINY�ŃN���b�v����
*
minyclip2:		*�Q��ڈȍ~�̃G���g��
	subq.w	#1,d4
	bcs	outofscrn
	cmp.w	MINY(a0),d3
	bcs	outofscrn
	move.w	a1,d0
	move.w	a2,d1
minyclip:		*�P��ڂ̃G���g��
	move.w	MINY(a0),d5
	cmp.w	d5,d3
	bne	minylp
	move.w	d2,d0
	move.w	d3,d1
	bra	yclipn
minylp:	move.w	d1,d6
	add.w	d3,d6
	roxr.w	#1,d6
	cmp.w	d5,d6
	beq	yclipq
	bcs	miny0
	move.w	d6,d3
	add.w	d0,d2
	roxr.w	#1,d2
	bra	minylp
miny0:	move.w	d6,d1
	add.w	d2,d0
	roxr.w	#1,d0
	bra	minylp

yclipq:	move.w	d6,d1
	add.w	d2,d0
	roxr.w	#1,d0
	move.w	a3,d2
	move.w	a4,d3
yclipn:	cmp.w	MINX(a0),d0
	bcs	minxclip2
	cmp.w	MAXX(a0),d0
	bhi	maxxclip2
	moveq.l	#0,d4		*Z = 1
	rts

*
*	MAXX�ŃN���b�v����
*
maxxclip2:		*�Q��ڈȍ~�̃G���g��
	subq.w	#1,d4
	bcs	outofscrn
	cmp.w	MAXX(a0),d2
	bhi	outofscrn
	move.w	a1,d0
	move.w	a2,d1
maxxclip:		*�P��ڂ̃G���g��
	move.w	MAXX(a0),d5
	cmp.w	d5,d2
	bne	maxxlp
	move.w	d2,d0
	move.w	d3,d1
	bra	xclipn
maxxlp:	move.w	d0,d6
	add.w	d2,d6
	roxr.w	#1,d6
	cmp.w	d5,d6
	beq	xclipq
	bcs	maxx0
	move.w	d6,d0
	add.w	d3,d1
	roxr.w	#1,d1
	bra	maxxlp
maxx0:	move.w	d6,d2
	add.w	d1,d3
	roxr.w	#1,d3
	bra	maxxlp

*
*	MINX�ŃN���b�v����
*
minxclip2:		*�Q��ڈȍ~�̃G���g��
	subq.w	#1,d4		*2�ӂŃN���b�s���O�ς݂Ȃ�
	bcs	outofscrn	*�@���S�s��������
	cmp.w	MINX(a0),d2	*x1 < MINX�Ȃ�
	bcs	outofscrn	*�@���S�s��
	move.w	a1,d0		*�N���b�s���O�O�̍��W����
	move.w	a2,d1		*�@��蒼��

minxclip:		*�P��ڂ̃G���g��
	move.w	MINX(a0),d5	*d5 = �N���b�v����x���W
	cmp.w	d5,d2		*x1 = MINX�Ȃ�
	bne	minxlp		*
	move.w	d2,d0		*�@���̓_(x1,y1)�����߂�_
	move.w	d3,d1		*
	bra	xclipn
minxlp:	move.w	d0,d6		*
	add.w	d2,d6		*
	roxr.w	#1,d6		*d6 = Mx = (x0+x1)/2
	cmp.w	d5,d6		*Mx = MINX�Ȃ�
	beq	xclipq		*�@���ꂪ���߂�_
	bcs	minx0
			*Mx > MINX�Ȃ�
	move.w	d6,d2		*x1 = Mx
	add.w	d1,d3		*
	roxr.w	#1,d3		*y1 = My
	bra	minxlp		*�@�Ƃ��ČJ��Ԃ�
			*Mx < MINX�Ȃ�
minx0:	move.w	d6,d0		*x0 = Mx
	add.w	d3,d1		*
	roxr.w	#1,d1		*y0 = My
	bra	minxlp		*�@�Ƃ��ČJ��Ԃ�

xclipq:	move.w	d6,d0		*x0 = Mx
	add.w	d3,d1		*
	roxr.w	#1,d1		*y0 = My
	move.w	a3,d2		*x1�𕜋A
	move.w	a4,d3		*y1�𕜋A
xclipn:	cmp.w	MINY(a0),d1
	bcs	minyclip2
	cmp.w	MAXY(a0),d1
	bhi	maxyclip2
	moveq.l	#0,d4		*Z = 1
	rts

	.end
