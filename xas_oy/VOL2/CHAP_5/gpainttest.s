*	gpaint�̃e�X�g�p�v���O����

	.include	doscall.mac
	.include	iocscall.mac
*
	.xref	gpaint
*	.xref	setcliprect
*
	.offset	0
*
	.text
	.even
*
ent:
	lea.l	inisp,sp

	clr.l	-(sp)		*�X�[�p�[�o�C�U���[�h��
	DOS	_SUPER		*

				*512x512,65536
	move.l	#$0010_0005,-(sp)
	DOS	_CONCTRL	*��ʏ�����

*	pea	window		*�N���b�s���O�E�B���h�E�̐ݒ�
*	jsr	setcliprect	*
*	addq.l	#4,sp		*

	lea.l	linarg1,a1	*��ʂ��p�^�[���Ŗ��߂�
	lea.l	linarg2,a2	*
				*
	moveq.l	#0,d6		*
	move.w	#256-1,d7	*
loop:	move.w	d6,2(a1)	*
	move.w	d6,6(a1)	*
	IOCS	_LINE		*
	exg.l	a1,a2		*
	addq.w	#1,d6		*
				*
	move.w	d6,2(a1)	*
	move.w	d6,6(a1)	*
	IOCS	_LINE		*
	exg.l	a1,a2		*
	addq.w	#1,d6		*
	dbra	d7,loop		*

	pea.l	paintarg	*�h��ׂ�
	jsr	gpaint		*
	addq.l	#4,sp		*

*	lea.l	paintarg,a1
*	IOCS	_PAINT

	DOS	_EXIT
*
	.data
	.even
*
linarg1:			*IOCS LINE�̈���
	.dc.w	0,0,511,0,$c000,$8888
linarg2:
	.dc.w	0,1,511,1,$c000,$2222
*
paintarg:			*gpaint�̈���
	.dc.w	255,255
	.dc.w	$003f
	.dc.l	paintwork
	.dc.l	paintworkend
*
window:	.dc.w	64,64,511-64,511-64
*
	.bss
	.even
*
paintwork:
	.ds.b	$4000
paintworkend:
*
	.stack
	.even
*
	.ds.l	4096
inisp:
	.end	ent
