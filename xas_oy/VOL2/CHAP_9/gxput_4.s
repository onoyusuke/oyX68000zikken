*	�O���t�B�b�N�p�^�[�����g��/�k�����ăv�b�g����i�ŏI�Łj

	.include	gconst.h
	.include	gmacro.h
*
	.xdef	gxput
	.xref	gramadr
	.xref	cliprect
	.xref	ucliprect
*
	.offset	0	*gxput�̈����\��
*
X0:	.ds.w	1	*�`�����W
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
PAT:	.ds.l	1	*�p�^�[���A�h���X
XL:	.ds.w	1	*�p�^�[��������-1
YL:	.ds.w	1	*�p�^�[���c����-1
TEMP:	.ds.l	1	*�e�[�u���p
*
	.text
	.even
*
gxput:
ARGPTR	=	4+8*4+7*4
	movem.l	d0-d7/a0-a6,-(sp)

	movea.l	ARGPTR(sp),a6	*a6 = ������

	movem.w	(a6)+,d0-d3	*�`��͈͂̍��W�����o��
	MINMAX	d0,d2		*x0��x1��ۏ؂���
	MINMAX	d1,d3		*y0��y1��ۏ؂���

	movea.l	(a6)+,a1	*a1 = �p�^�[���擪�A�h���X
	movem.w	(a6)+,a2-a3	*a2 = �p�^�[�����s�N�Z����-1
				*a3 = �p�^�[���c�s�N�Z����-1
	movea.l	(a6),a6		*a6 = �e�[�u���p���[�N

	lea.l	cliprect,a0	*a0 = �N���b�s���O�͈�
	cmp.w	(a0)+,d2	*x1��minx�Ȃ�E�B���h�E�O
	blt	done
	cmp.w	(a0)+,d3	*y1��miny�Ȃ�E�B���h�E�O
	blt	done
	cmp.w	(a0)+,d0	*x0��maxx�Ȃ�E�B���h�E�O
	bgt	done
	cmp.w	(a0)+,d1	*y0��maxy�Ȃ�E�B���h�E�O
	bgt	done

	lea.l	ucliprect,a0	*a0 = �N���b�s���O�͈́i�Q�^�����j
	move.w	#$8000,d5	*x0,y0,x1,y1��8000H�̃Q�^�𗚂�����
	add.w	d5,d0		*
	add.w	d5,d1		*
	add.w	d5,d2		*
	add.w	d5,d3		*

	move.w	a2,d4		*d4 = �p�^�[�����s�N�Z����-1
	move.w	a3,d5		*d5 = �p�^�[���c�s�N�Z����-1
	move.w	d2,a4		*d2��a4�ɑҔ�
	move.w	d3,a5		*d3��a5�ɑҔ�

minxclip:		*MINX�ŃN���b�s���O����
	move.w	(a0)+,d6	*d6 = minx
	cmp.w	d6,d0		*x0��minx�Ȃ�
	bcc	minyclip	*�@�N���b�s���O�s�v

	cmp.w	d6,d2
	bne	minx0

	move.w	d2,d0
	move.w	d4,d3
	bra	minx3

minx0:	moveq.l	#0,d3
minxlp:	move.w	d0,d7
	add.w	d2,d7
	roxr.w	#1,d7
	cmp.w	d6,d7
	beq	minx2
	bcs	minx1

	move.w	d7,d2
	add.w	d3,d4
	roxr.w	#1,d4
	bra	minxlp

minx1:	move.w	d7,d0
	add.w	d4,d3
	roxr.w	#1,d3
	bra	minxlp

minx2:	move.w	d7,d0		*d0 = x0 = minx
	add.w	d4,d3
	roxr.w	#1,d3		*d3 = �p�^�[�������[�ɂ͂ݏo�镪
minx3:	move.w	a2,d4		*d4 = �p�^�[�����s�N�Z����-1
	sub.w	d3,a2		*�͂ݏo�����p�^�[���̉������l�߂�
	add.w	d3,d3		*
	adda.w	d3,a1		*�͂ݏo�����p�^�[����؂�̂Ă�
	move.w	a4,d2		*d2�𕜋A
	move.w	a5,d3		*d3�𕜋A

minyclip:		*MINY�ŃN���b�s���O����
	addq.w	#1,d4		*d4 = �p�^�[���P���C�����̃s�N�Z����
	add.w	d4,d4		*d4 = �p�^�[���P���C�����̃o�C�g��

	move.w	(a0)+,d6
	cmp.w	d6,d1
	bcc	maxxclip

	cmp.w	d6,d3
	bne	miny0

	move.w	d3,d1
	move.w	d5,d2
	bra	miny3

miny0:	moveq.l	#0,d2
minylp:	move.w	d1,d7
	add.w	d3,d7
	roxr.w	#1,d7
	cmp.w	d6,d7
	beq	miny2
	bcs	miny1

	move.w	d7,d3
	add.w	d2,d5
	roxr.w	#1,d5
	bra	minylp

miny1:	move.w	d7,d1
	add.w	d5,d2
	roxr.w	#1,d2
	bra	minylp

miny2:	move.w	d7,d1
	add.w	d5,d2
	roxr.w	#1,d2
miny3:	sub.w	d2,a3
	mulu.w	d4,d2
	adda.l	d2,a1
	move.w	a4,d2
	move.w	a5,d3

maxxclip:		*MAXX�ŃN���b�s���O����
	move.w	d4,d6		*d6 = �p�^�[���P���C�����o�C�g��

	move.w	(a0)+,d4	*d4 = maxx
	sub.w	d2,d4		*d4 = maxx-x1
	bmi	maxyclip	*
	moveq.l	#0,d4		*�E�[�ɂ͂͂ݏo�Ă��Ȃ�����

maxyclip:
	move.w	(a0)+,d5	*d5 = maxy
	sub.w	d3,d5		*d5 = maxy-y1
	bmi	clipped
	moveq.l	#0,d5		*���[�ɂ͂͂ݏo�Ă��Ȃ�����

clipped:
	sub.w	d0,d2		*d2 = �`��͈͂̉��s�N�Z����-1
	sub.w	d1,d3		*d3 = �`��͈͂̏c�s�N�Z����-1

	move.w	#$8000,d7	*�Q�^��E������
	sub.w	d7,d0		*
	sub.w	d7,d1		*

	jsr	gramadr		*a0 = �`��捶��G-RAM�A�h���X

	move.w	d2,d0		*
	neg.w	d0		*d0 = x�ɂ��Ă̌덷�������l
	bne	fix0		*�`��敝���P�s�N�Z�������Ȃ��ꍇ��
	move.w	d0,a2		*�@���܍��킹
fix0:	add.w	d2,d4		*d4 = x���[�v�J�E���^�����l
	add.w	d2,d2		*d2 = x�ɂ��Ă̌덷������
	add.w	a2,a2		*a2 = x�ɂ��Ă̌덷���␳�l

	movea.l	a6,a4		*a4 = ���[�`���쐬��擪�A�h���X
	move.w	d4,d7		*d7 = x���[�v�J�E���^
iloop:	moveq.l	#0,d1		*d1 = x�����̃A�h���X����(�O�ɏ�����)
	add.w	a2,d0		*x�ɂ��Ă̌덷��ݐς�����
	ble	inext		*
iinclp:	addq.w	#2,d1		*�A�h���X�̑�����ݐς���
	sub.w	d2,d0		*x�덷����␳����
	bgt	iinclp		*�덷����0�ȉ��ɂȂ�܂ŌJ��Ԃ�
inext:	move.l	pset(pc),(a4)+	*move,lea�̂Q���߂���������
	move.w	d1,(a4)+	*�A�h���X�̑�������������
	dbra	d7,iloop	*�������J��Ԃ�

	move.w	term(pc),-4(a4)	*rts���߂���������
	FLUSH_CACHE

	move.w	d3,d1		*
	neg.w	d1		*d1 = y�ɂ��Ă̌덷�������l
	bne	fix1		*�`��捂���P�s�N�Z�������Ȃ��ꍇ��
	move.w	d1,a3		*�@���܍��킹
fix1:	add.w	d3,d5		*d5 = y���[�v�J�E���^�����l
	add.w	d3,d3		*d3 = y�ɂ��Ă̌덷������
	add.w	a3,a3		*a3 = y�ɂ��Ă̌덷���␳�l

yloop:	movea.l	a0,a5		*a5 = �`���
	movea.l	a1,a4		*a4 = �Q�ƌ�

	jsr	(a6)		*�P���C���`�悷��

	add.w	a3,d1		*y�ɂ��Ă̌덷��ݐς�����
	ble	ynext		*
yinclp:	adda.w	d6,a1		*�Q�ƌ�y���W��i�߂�
	sub.w	d3,d1		*y�덷����␳����
	bgt	yinclp		*�덷����0�ȉ��ɂȂ�܂ŌJ��Ԃ�

ynext:	lea.l	GNBYTE(a0),a0	*�`���y���W��i�߂�
	dbra	d5,yloop	*�������J��Ԃ�

done:	movem.l	(sp)+,d0-d7/a0-a6
term:	rts

pset:	move.w	(a4),(a5)+	*�P�s�N�Z���������ޖ���
	lea.l	0.w(a4),a4	*�Q�ƈʒu���ړ����閽��

	.end
