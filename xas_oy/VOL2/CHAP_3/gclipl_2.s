*	�����̋�`�̈�N���b�s���O

	.include	rect.h
*
	.xdef	gclipline
	.xref	ucliprect
*
	.text
	.even
*
*	����(d0.w,d1.w)-(d2.w,d3.w)��
*	cliprect�Ŏw�肳�ꂽ��`�̈�ŃN���b�v����
*	���S�s���̏ꍇ��Z=0�Ŗ߂�
*
gclipline:
	movem.w	ucliprect,a0-a3	*a0�`a3 = �E�B���h�E�i�Q�^�����j

	move.w	#$8000,d4	*���W��$8000�̃Q�^�𗚂�����
	add.w	d4,d0		*
	add.w	d4,d1		*
	add.w	d4,d2		*
	add.w	d4,d3		*

	bsr	gcliplinesub	*�n�_���N���b�v
	bne	done		*�Ȃ����s��������

	exg.l	d0,d2		*�n�_�ƏI�_�����ւ���
	exg.l	d1,d3		*
	bsr	gcliplinesub	*�I�_���N���b�v
	bne	done		*�Ȃ����s��������
	exg.l	d0,d2		*���ւ����n�_�ƏI�_��
	exg.l	d1,d3		*���ɖ߂�

	move.w	#$8000,d4	*�Q�^��E������
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
	move.w	d0,d4		*�N���b�s���O�O�̍��W��
	move.w	d1,d5		*�@�o���Ă���

*
*	MINX�ŃN���b�v����
*
minxclip:
	cmp.w	a0,d0		*MINX��x0�Ȃ��
	bcc	minyclip	*�@MINX�ł̃N���b�s���O�͕s�v
	cmp.w	a0,d2		*MINX��x0����MINX��x1�Ȃ��
	bcs	outofscrn	*�@���S�s��
	move.w	a0,d7		*d7 = MINX

	moveq.l	#0,d6
	sub.w	d2,d0		*d0 = abs(x0-x1)
	bcc	minx0		*
	neg.w	d0		*
	addq.w	#1,d6		*d6 = �������]��
minx0:	sub.w	d3,d1		*d1 = abs(y0-y1)
	bcc	minx1		*
	neg.w	d1		*
	addq.w	#1,d6		*d6 = �������]��
minx1:	sub.w	d4,d7		*d7 = abs(x0-MINX)
	bcc	minx2		*
	neg.w	d7		*
	addq.w	#1,d6		*d6 = �������]��
minx2:	mulu.w	d7,d1		*d1 = abs(y0-y1)*abs(x0-MINX)
	divu.w	d0,d1		*d1 /= abs(x0-x1)
	btst.l	#0,d6		*�������]�񐔂����Ȃ��
	beq	minx3		*�@���ʂ̕����𔽓]����
	neg.w	d1		*
minx3:	add.w	d5,d1		*d1 = MINX�ɑΉ�����y
	move.w	a0,d0		*d0 = MINX

*
*	MINY�ŃN���b�v����
*
minyclip:
	cmp.w	a1,d1
	bcc	maxxclip
	cmp.w	a1,d3
	bcs	outofscrn
	move.w	a1,d7

	moveq.l	#0,d6
	move.w	d5,d1
	sub.w	d3,d1
	bcc	miny0
	neg.w	d1
	addq.w	#1,d6
miny0:	move.w	d4,d0
	sub.w	d2,d0
	bcc	miny1
	neg.w	d0
	addq.w	#1,d6
miny1:	sub.w	d5,d7
	bcc	miny2
	neg.w	d7
	addq.w	#1,d6
miny2:	mulu.w	d7,d0
	divu.w	d1,d0
	btst.l	#0,d6
	beq	miny3
	neg.w	d0
miny3:	add.w	d4,d0		*d0 = MINY�ɑΉ�����x
	cmp.w	a0,d0		*x0��MINX�Ȃ��
	bcs	outofscrn	*�@���S�s��
	move.w	a1,d1		*d1 = MINY

*
*	MAXX�ŃN���b�v����
*
maxxclip:
	cmp.w	a2,d0
	bls	maxyclip
	cmp.w	a2,d2
	bhi	outofscrn
	move.w	a2,d7

	moveq.l	#0,d6
	move.w	d4,d0
	sub.w	d2,d0
	bcc	maxx0
	neg.w	d0
	addq.w	#1,d6
maxx0:	move.w	d5,d1
	sub.w	d3,d1
	bcc	maxx1
	neg.w	d1
	addq.w	#1,d6
maxx1:	sub.w	d4,d7
	bcc	maxx2
	neg.w	d7
	addq.w	#1,d6
maxx2:	mulu.w	d7,d1
	divu.w	d0,d1
	btst.l	#0,d6
	beq	maxx3
	neg.w	d1
maxx3:	add.w	d5,d1		*d1 = MAXX�ɑΉ�����y
	cmp.w	a1,d1		*y0��MINY�Ȃ��
	bcs	outofscrn	*�@���S�s��
	move.w	a2,d0		*d0 = MAXX

*
*	MAXY�ŃN���b�v����
*
maxyclip:
	cmp.w	a3,d1
	bls	visible
	cmp.w	a3,d3
	bhi	outofscrn
	move.w	a3,d7

	moveq.l	#0,d6
	move.w	d5,d1
	sub.w	d3,d1
	bcc	maxy0
	neg.w	d1
	addq.w	#1,d6
maxy0:	move.w	d4,d0
	sub.w	d2,d0
	bcc	maxy1
	neg.w	d0
	addq.w	#1,d6
maxy1:	sub.w	d5,d7
	bcc	maxy2
	neg.w	d7
	addq.w	#1,d6
maxy2:	mulu.w	d7,d0
	divu.w	d1,d0
	btst.l	#0,d6
	beq	maxy3
	neg.w	d0
maxy3:	add.w	d4,d0		*d0 = MAXY�ɑΉ�����x
	cmp.w	a0,d0		*d0��MINX�Ȃ��
	bcs	outofscrn	*�@���S�s��
	cmp.w	a2,d0		*d0��MAXX�Ȃ��
	bhi	outofscrn	*�@���S�s��
	move.w	a3,d1		*d1 = MAXY

visible:
	moveq.l	#0,d4		*Z=1
	rts

outofscrn:
	moveq.l	#-1,d4		*Z=0
	rts

	.end
