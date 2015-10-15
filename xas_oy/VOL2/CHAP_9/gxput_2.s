*	�O���t�B�b�N�p�^�[�����g��/�k�����ăv�b�g����i�������Łj

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
TEMP:	.ds.l	1	*�e�[�u���p
*
	.text
	.even
*
gxput:
ARGPTR	=	4+6*4+7*4
	movem.l	d0-d5/a0-a6,-(sp)

	movea.l	ARGPTR(sp),a6	*a6 = ������

	movem.w	(a6)+,d0-d3	*�`��͈͂̍��W�����o��
	MINMAX	d0,d2		*x0��x1��ۏ؂���
	MINMAX	d1,d3		*y0��y1��ۏ؂���

	movea.l	(a6)+,a1	*a1 = �p�^�[���擪�A�h���X
	movem.w	(a6)+,a2-a3	*a2 = �p�^�[�����s�N�Z����-1
				*a3 = �p�^�[���c�s�N�Z����-1
	movea.l	(a6),a6		*a6 = �e�[�u���p���[�N

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
	add.w	d2,d2		*d2 = x�ɂ��Ă̌덷������
	add.w	a2,a2		*a2 = x�ɂ��Ă̌덷���␳�l

	movea.l	a6,a5		*a5 = �e�[�u���擪�A�h���X
	move.w	d4,d5		*d5 = x���[�v�J�E���^
iloop:	moveq.l	#0,d1		*d1 = x�̑���(�O�ɏ�����)
	add.w	a2,d0		*x�ɂ��Ă̌덷��ݐς�����
	ble	inext		*
iinclp:	addq.w	#2,d1		*x�̑����𑝂�
	sub.w	d2,d0		*x�덷����␳����
	bgt	iinclp		*�덷����0�ȉ��ɂȂ�܂ŌJ��Ԃ�
inext:	move.w	d1,(a5)+	*�e�[�u���ɓo�^
	dbra	d5,iloop	*�������J��Ԃ�

	move.w	d3,d1		*
	neg.w	d1		*d1 = y�ɂ��Ă̌덷�������l
	bne	fix1		*�`��捂���P�s�N�Z�������Ȃ��ꍇ��
	move.w	d1,a3		*�@���܍��킹
fix1:	move.w	d3,d5		*d5 = y���[�v�J�E���^�����l
	add.w	d3,d3		*d3 = y�ɂ��Ă̌덷������
	add.w	a3,a3		*a3 = y�ɂ��Ă̌덷���␳�l

	move.l	a6,d2		*d2 = �e�[�u���擪�A�h���X
yloop:	movea.l	a0,a5		*a5 = �`���
	movea.l	a1,a6		*a6 = �Q�ƌ�

	movea.l	d2,a2		*a2 = �e�[�u���擪�A�h���X
	move.w	d4,d0		*d0 = x���[�v�J�E���^
xloop:	move.w	(a6),(a5)+	*�P�s�N�Z����������
	adda.w	(a2)+,a6	*�Q�ƌ�x���W��i�߂�
	dbra	d0,xloop	*�������J��Ԃ�

	add.w	a3,d1		*y�ɂ��Ă̌덷��ݐς�����
	ble	ynext		*
yinclp:	adda.l	a4,a1		*�Q�ƌ�y���W��i�߂�
	sub.w	d3,d1		*y�덷����␳����
	bgt	yinclp		*�덷�������ɂȂ�܂ŌJ��Ԃ�

ynext:	lea.l	GNBYTE(a0),a0	*�`���y���W��i�߂�
	dbra	d5,yloop	*�������J��Ԃ�

done:	movem.l	(sp)+,d0-d5/a0-a6
	rts

	.end
