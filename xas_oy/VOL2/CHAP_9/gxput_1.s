*	�O���t�B�b�N�p�^�[�����g��/�k�����ăv�b�g����i��P�Łj

	.include	gconst.h
	.include	gmacro.h
*
	.xdef	gxput
	.xref	gramadr
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
*
	.text
	.even
*
gxput:
ARGPTR	=	4+8*4+7*4
	movem.l	d0-d7/a0-a6,-(sp)

	movea.l	ARGPTR(sp),a6	*a6 = ������

	movem.w	(a6)+,d0-d3	*d0�`d3 = �`��͈͂̍��W
	MINMAX	d0,d2		*x0��x1��ۏ؂���
	MINMAX	d1,d3		*y0��y1��ۏ؂���

	movea.l	(a6)+,a1	*a1 = �p�^�[���擪�A�h���X
	movem.w	(a6)+,a2-a3	*a2 = �p�^�[�����s�N�Z����-1
				*a3 = �p�^�[���c�s�N�Z����-1

	sub.w	d0,d2		*d2 = �`��͈͂̉��s�N�Z����-1
	sub.w	d1,d3		*d3 = �`��͈͂̏c�s�N�Z����-1

	jsr	gramadr		*a0 = �`��捶��G-RAM�A�h���X

	lea.l	1(a2),a4	*a4 = �p�^�[���P���C�����s�N�Z����
	adda.l	a4,a4		*a4 = �p�^�[���P���C�����o�C�g��

	move.w	d2,d0		*
	neg.w	d0		*d0 = x�ɂ��Ă̌덷�������l
	bne	fix0		*�`��敝���P�s�N�Z�������Ȃ��ꍇ��
	move.w	d0,a2		*�@���܍��킹
fix0:	move.w	d2,d4		*d4 = x���[�v�J�E���^�����l
	add.w	d2,d2		*d2 = x�ɂ��Ă̌덷���␳�l
	add.w	a2,a2		*a2 = x�ɂ��Ă̌덷������

	move.w	d3,d1		*
	neg.w	d1		*d1 = y�ɂ��Ă̌덷�������l
	bne	fix1		*�`��捂���P�s�N�Z�������Ȃ��ꍇ��
	move.w	d1,a3		*�@���܍��킹
fix1:	move.w	d3,d5		*d5 = y���[�v�J�E���^�����l
	add.w	d3,d3		*d3 = y�ɂ��Ă̌덷���␳�l
	add.w	a3,a3		*a3 = y�ɂ��Ă̌덷������

yloop:	movea.l	a0,a5		*a5 = �`���
	movea.l	a1,a6		*a6 = �Q�ƌ�

	move.w	d0,d6		*d6 = x�덷��
	move.w	d4,d7		*d7 = x���[�v�J�E���^
xloop:	move.w	(a6),(a5)+	*�P�s�N�Z����������
	add.w	a2,d6		*x�ɂ��Ă̌덷��ݐς�����
	ble	xnext		*
xinclp:	addq.l	#2,a6		*�Q�ƌ�x���W��i�߂�
	sub.w	d2,d6		*x�덷����␳����
	bgt	xinclp		*�덷����0�ȉ��ɂȂ�܂ŌJ��Ԃ�
xnext:	dbra	d7,xloop	*�������J��Ԃ�

	add.w	a3,d1		*y�ɂ��Ă̌덷��ݐς�����
	ble	ynext		*
yinclp:	adda.l	a4,a1		*�Q�ƌ�y���W��i�߂�
	sub.w	d3,d1		*y�덷����␳����
	bgt	yinclp		*�덷����0�ȉ��ɂȂ�܂ŌJ��Ԃ�

ynext:	lea.l	GNBYTE(a0),a0	*�`���y���W��i�߂�
	dbra	d5,yloop	*�������J��Ԃ�

done:	movem.l	(sp)+,d0-d7/a0-a6
	rts

	.end
