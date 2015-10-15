*	���U�C�N����

DERGB_BREAK_HIGHWORD	=	0
	.include	gconst.h
	.include	gmacro.h
*
	.xdef	gmosaic
	.xref	gramadr
	.xref	gcliprect
*
	.offset	0	*gmosaic�̈����\��
*
X0:	.ds.w	1	*��`���W
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
MOSSIZ:	.ds.w	1	*���U�C�N�̑傫���i�Q�`32�j
*
	.text
	.even
*
gmosaic:
ARGPTR	=	8
	link	a6,#0
	movem.l	d0-d7/a0-a5,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = ������
	movem.w	(a1),d0-d4	*d0�`d3�ɍ��W�����o��

	jsr	gcliprect	*�N���b�s���O����
	bmi	done		*N=1�Ȃ�`��̕K�v�Ȃ�

	jsr	gramadr		*G-RAM��̃A�h���X�𓾂�

	sub.w	d0,d2		*d2 = ���s�N�Z����-1
	sub.w	d1,d3		*d3 = �c�s�N�Z����-1

	cmpi.w	#1,d4		*�ʎq�����x����
	ble	done		*�@�Q�`32�܂�
	cmpi.w	#32,d4		*
	bgt	done		*

	addq.w	#1,d2		*d2 = ���s�N�Z����
	addq.w	#1,d3		*d3 = �c�s�N�Z����
	move.w	d2,d6		*d6 = ���s�N�Z����
	ext.l	d2		*
	ext.l	d3		*
	divu.w	d4,d2		*d2 = ����s�N�Z����
	divu.w	d4,d3		*d3 = �c��s�N�Z����

	swap.w	d2
	sub.w	d2,d6		*d6 = WID = �[������������`�̉��s�N�Z����
	swap.w	d2

	moveq.l	#GSFTCTR,d0	*d1 = GNB*SIZ
	move.w	d4,d1		*
	lsl.w	d0,d1		*

	movea.w	d1,a4		*a4 = GNB*SIZ-H*2
	suba.w	d4,a4		*
	suba.w	d4,a4		*

	sub.w	d6,d1		*d1 = GNB*SIZ-WID*2
	sub.w	d6,d1		*

	lea.l	GNBYTE.w,a5	*a5 = GNB-SIZ*2
	suba.w	d4,a5		*
	suba.w	d4,a5		*

	subq.w	#1,d2		*d2 = ����s�N�Z����-1
	bmi	done		*
	subq.w	#1,d3		*d3 = �c��s�N�Z����-1
	bmi	done		*

	move.w	d4,d0		*a3 = ���� = SIZ*SIZ
	mulu.w	d0,d0		*
	move.l	d0,a3		*

	subq.w	#1,d4		*a2 = SIZ-1
	move.w	d4,a2		*

loop1:	move.w	d2,d0		*d0 = ����s�N�Z����-1
	swap.w	d1
	swap.w	d2
	swap.w	d3
loop2:	movea.l	a0,a1		*a1 = �`��惉�C�����[

	move.l	a3,d4
	lsr.w	#1,d4		*d4.l = �̋P�x���v�i�����l=����/2�j
	move.l	d4,d5		*d5.l = �Ԃ̋P�x���v
	move.l	d4,d6		*d6.l = �΂̋P�x���v

	move.w	a2,d7		*d7 = SIZ-1
loop3:	swap.w	d7
	move.w	a2,d7		*d7 = SIZ-1
loop4:	move.w	(a1)+,d3	*�P�s�N�Z�����o��
	_DERGB	d1,d2,d3	*RGB�ɕ�������
	add.w	d1,d4		*RGB���ƂɋP�x��ݐ�
	add.w	d2,d5		*
	add.w	d3,d6		*
	dbra	d7,loop4	*��s�N�Z���̉������J��Ԃ�
	swap.w	d7
	adda.l	a5,a1		*��s�N�Z���̎����C�����[��
	dbra	d7,loop3	*��s�N�Z���̍������J��Ԃ�

	move.w	a3,d7		*d7 = ���ω��̕���
	divu.w	d7,d4		*d4 = �̕��ϋP�x
	divu.w	d7,d5		*d5 = �Ԃ̕��ϋP�x
	divu.w	d7,d6		*d6 = �΂̕��ϋP�x
	_RGB	d4,d5,d6	*RGB�ɍč\��

	move.w	a2,d4		*��s�N�Z����h��ׂ�
loop5:	move.w	a2,d5		*
loop6:	move.w	d6,(a0)+	*
	dbra	d5,loop6	*
	adda.l	a5,a0		*
	dbra	d4,loop5	*

	suba.l	a4,a0		*�E�ׂ̑�s�N�Z����
	dbra	d0,loop2	*����s�N�Z�������J��Ԃ�

	swap.w	d1
	swap.w	d2
	swap.w	d3
	adda.w	d1,a0		*�P�i�����[�̑�s�N�Z����
	dbra	d3,loop1	*�c��s�N�Z�������J��Ԃ�

done:	movem.l	(sp)+,d0-d7/a0-a5
	unlk	a6
	rts

	.end

�C������

92-01-01��
���̂�GNBYTE�{����̂�mulu���g���Ă����̂�lsl�ɏC��

92-02-01��
�C�������ɂ܂������֌W�Ȃ����Ƃ������Ă������i���`���j�̂��C��
�i���e�̕ω��Ȃ��j
