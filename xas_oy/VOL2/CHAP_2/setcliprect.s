*	�N���b�s���O�E�B���h�E�̐ݒ�

	.include	iocscall.mac
	.include	gconst.h
*
	.xdef	setcliprect
	.xdef	cliprect
	.xdef	ucliprect
*
	.text
	.even
*
setcliprect:
ARGPTR	=	8
	link	a6,#0
	movem.l	d1-d4,-(sp)

	movea.l	ARGPTR(a6),a1	*a1=����
	movem.w	(a1),d1-d4	*d1�`d4�ɍ��W�����o��
	IOCS	_WINDOW		*�@IOCS�ɓ`����
	tst.l	d0		*�G���[�Ȃ�
	bmi	retn		*�@������

	movem.w	d1-d4,cliprect	*�N���b�s���O�E�B���h�E��
				*�@���W���o���Ă���
	move.w	#$8000,d0	*$8000�̃Q�^�𗚂�����
	add.w	d0,d1		*
	add.w	d0,d2		*
	add.w	d0,d3		*
	add.w	d0,d4		*
	movem.w	d1-d4,ucliprect	*�@�ʂɊo���Ă���

	moveq.l	#0,d0		*����I��
retn:	movem.l	(sp)+,d1-d4
	unlk	a6
	rts
*
cliprect:
	.dc.w	0		*�N���b�s���O�̈�
	.dc.w	0		*
	.dc.w	GNPIXEL-1	*
	.dc.w	GNPIXEL-1	*
ucliprect:
	.dc.w	$8000		*�N���b�s���O�̈�
	.dc.w	$8000		*�i$8000�̃Q�^�����j
	.dc.w	$8000+GNPIXEL-1	*
	.dc.w	$8000+GNPIXEL-1	*

	.end
