*	��`�̈�̕���

	.include	gconst.h
	.include	gmacro.h
*
	.xdef	gcopy
	.xref	gramadr
	.xref	gcliprect
	.xref	gcopyline_L
	.xref	gcopyline_R
*
	.offset	0	*gcopy�̈����\��
*
X0:	.ds.w	1	*�]�������W
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
X2:	.ds.w	1	*�]���捶������W
Y2:	.ds.w	1	*
*
	.text
	.even
*
gcopy:
ARGPTR	=	8
	link	a6,#0
	movem.l	d0-d7/a0-a3,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = ������
	movem.w	(a1),d0-d3	*d0�`d3�ɍ��W�����o��

	jsr	gcliprect	*�]�����̈���N���b�s���O����
	bmi	done		*N=1�Ȃ�]���̕K�v�Ȃ�

	jsr	gramadr		*�����G-RAM��̃A�h���X�𓾂�

	sub.w	d0,d2		*d2 = ���s�N�Z����-1
	sub.w	d1,d3		*d3 = �c�s�N�Z����-1

	movem.w	(a1)+,d4-d7	*(x0,y0)-(x1,y1)
	MINMAX	d4,d6		*d4��d6��ۏ�
	MINMAX	d5,d7		*d5��d7��ۏ�

				*�]�����̈���N���b�s���O�����Ƃ���
	sub.w	d4,d0		*�@d0 = �؂���ꂽ���[�s�N�Z����
	sub.w	d5,d1		*�@d1 = �؂���ꂽ��[�s�N�Z����

	movem.w	(a1)+,d4-d5	*(x2,y2)
	add.w	d0,d4		*�؂���ꂽ������x2,y2�����炷
	add.w	d1,d5		*
	move.w	d4,d0		*x2'
	move.w	d5,d1		*y2'
	add.w	d4,d2		*x3'
	add.w	d5,d3		*y3'

	sub.w	d2,d6		*d6 = x1'-x3' = x0'-x2'
	sub.w	d3,d7		*d7 = y1'-y3' = y0'-y2'

	jsr	gcliprect	*�]����̈���N���b�s���O����
	bmi	done		*N=1�Ȃ�]���̕K�v�Ȃ�

	movea.l	a0,a1		*a1 = �]�����A�h���X
	jsr	gramadr		*a0 = �]����A�h���X

	sub.w	d0,d2		*d2 = �ŏI�I�ȓ]���̈�̉��s�N�Z����-1
	sub.w	d1,d3		*d3 = �ŏI�I�ȓ]���̈�̏c�s�N�Z����-1

				*�]����̈���N���b�s���O�����Ƃ���
	sub.w	d4,d0		*�@d0 = �؂���ꂽ���[�s�N�Z����
	sub.w	d5,d1		*�@d1 = �؂���ꂽ��[�s�N�Z����

	add.w	d0,d0		*d0,d1�̕�����
	adda.w	d0,a1		*�@�]�����A�h���X�����炷
	ext.l	d1		*
	moveq.l	#GSFTCTR,d0	*
	lsl.l	d0,d1		*
	adda.l	d1,a1		*

	addq.w	#1,d2		*d2 = �ŏI�I�ȓ]���̈�̉��s�N�Z����
	move.w	#GNBYTE,d1	*d1 = ���C���Ԃ̃A�h���X�̍�

	tst.w	d6		*1)x0'��x2'����
	bpl	nright		*
	tst.w	d7		*2)y0' = y2'�Ȃ��
	beq	right		*�@�^�E�ւ̃R�s�[

nright:			*�^�E�ȊO
	lea.l	next(pc),a2	*
	bclr.l	#0,d2		*���s�N�Z�����͊���H
	beq	skip		*
	lea.l	odd(pc),a2	*��s�N�Z���̂Ƃ�

skip:	lea.l	gcopyline_L,a3	*�������̓]��
	suba.w	d2,a3		*

	add.w	d2,d2		*
	sub.w	d2,d1		*

	tst.w	d7		*y0'<y2'
	bge	down		*�@�Ȃ��
			*�������ւ̓]��
up:	add.w	d2,d1
	add.w	d2,d1
	neg.w	d1

	moveq.l	#0,d0		*��ʃ��[�h���N���A
	move.w	d3,d0		*d0.l = ���C����-1
	moveq.l	#GSFTCTR,d2	*1024�i�܂���2048�j�{
	lsl.l	d2,d0		*
	adda.l	d0,a0		*a0 = �]����̈��
				*�@��ԉ��̃��C���̍��[�A�h���X
	adda.l	d0,a1		*a1 = �]�����̈��
				*�@��ԉ��̃��C���̍��[�A�h���X
			*���܂͍��킹�����獇��

down:			*�ォ�牺�ւ̓]��
loop:	jsr	(a3)		*�P���C���]��
	jmp	(a2)		*
odd:	move.w	(a1),(a0)	*��s�N�Z���̏ꍇ
next:	adda.w	d1,a0		*�]������������̃��C����
	adda.w	d1,a1		*�]�������������̃��C����
	dbra	d3,loop		*�������J��Ԃ�

done:	movem.l	(sp)+,d0-d7/a0-a3
	unlk	a6
	rts
*
right:			*�^�E�ւ̃R�s�[�͓��ʈ���
	move.w	d2,d0		*d0 = ���s�N�Z����
	add.w	d0,d0		*d0 = �P���C�����̃o�C�g��
	adda.w	d0,a0		*a0 = ���ʐ惉�C���E�[�{�Q
	adda.w	d0,a1		*a1 = ���ʌ����C���E�[�{�Q
	add.w	d0,d1

	lea.l	rnext(pc),a2	*
	bclr.l	#0,d2		*���s�N�Z�����͊���H
	beq	rskip		*
	lea.l	rodd(pc),a2	*��s�N�Z���̂Ƃ�

rskip:	lea.l	gcopyline_R,a3	*�t�����̓]��
	suba.w	d2,a3		*

rloop:	jsr	(a3)		*�P���C���]��
	jmp	(a2)		*
rodd:	move.w	-(a1),-(a0)	*��s�N�Z���̏ꍇ
rnext:	adda.w	d1,a0		*�]������������̃��C����
	adda.w	d1,a1		*�]�������������̃��C����
	dbra	d3,rloop	*�������J��Ԃ�

	bra	done

	.end
