*	G-RAM�A�h���X�֘A���W���[��

	.include	iocscall.mac
	.include	gconst.h
*
	.xdef	gramadr
	.xdef	apage
	.xdef	gbase
*
	.text
*
*	���W����G-RAM�A�h���X�����߂�
*	(d0.w,d1.w) �� a0 = adr
*
gramadr:
	movem.l	d0-d1,-(sp)

	movea.w	d0,a0		*
	adda.w	d0,a0		*a0 = x*2

	moveq.l	#GSFTCTR,d0	*
	ext.l	d1		*
	asl.l	d0,d1		*d1 = y*1024 (or y*2048)
	adda.l	d1,a0		*a0 = (x,y)��(0,0)��G-RAM�A�h���X�̍�

	adda.l	gbase(pc),a0	*a0 = (x,y)��G-RAM�A�h���X

	movem.l	(sp)+,d0-d1
	rts

*
*	�`��y�[�W��ݒ肷��
*	d1.w = �y�[�W�ԍ�(0�`3)
*
apage:
	IOCS	_APAGE		*IOCS�ɂ��y�[�W�ԍ���`����
	tst.l	d0		*�G���[�H
	bmi	apage0		*�@�����Ȃ�I��

	move.w	d1,d0		*d0.w=�y�[�W�ԍ�
	lsl.w	#19-16,d0	*�y�[�W�ԍ���
	swap.w	d0		*�@$80000�{����
	clr.w	d0		*
	addi.l	#GPAGE0,d0	*G-RAM�̐擪�A�h���X�𑫂�
	move.l	d0,gbase	*���[�N�ɂ��܂�

	moveq.l	#0,d0	*APAGE�̖߂�l�𕜋A����
apage0:	rts
*
gbase:	.dc.l	GPAGE0		*(0,0)��G-RAM�A�h���X

	.end
