*	gxput�̓��쎎���p�v���O����

	.include	doscall.mac
	.include	iocscall.mac
*
	.xref	gxput
*	.xref	gxputon
*	.xref	setcliprect
*
FPACK	macro	callno
	.dc.w	callno
	.endm
*
__RAND		equ	$fe0e
*
	.text
	.even
*
ent:
	lea.l	inisp,sp

	clr.l	-(sp)		*�X�[�p�[�o�C�U���[�h��
	DOS	_SUPER		*

	lea.l	arg0,a1		*��ʂ���p�^�[������荞��
	IOCS	_GETGRM		*

*	pea	window		*�N���b�s���O�E�B���h�E�̐ݒ�
*	jsr	setcliprect	*
*	addq.l	#4,sp		*

	moveq.l	#14,d1		*256x256,65536
	IOCS	_CRTMOD		*��ʏ�����
	IOCS	_G_CLR_ON	*

	lea.l	arg,a1		*a1 = �����󂯓n���̈�
loop:	movea.l	a1,a0		*�����ŕ`��͈͂����߂�
	moveq.l	#4-1,d1		*
loop2:	FPACK	__RAND		*
	lsr.w	#7,d0		*0��d0��255
	move.w	d0,(a0)+	*
	dbra	d1,loop2	*

	pea.l	(a1)		*�`��
	jsr	gxput		*
	addq.l	#4,sp		*

	DOS	_KEYSNS		*�L�[���������܂�
	tst.l	d0		*�@�J��Ԃ�
	beq	loop		*

	DOS	_INKEY		*�X�y�[�X�������ꂽ��
	cmpi.b	#$20,d0		*�@�ꎞ��~����
	bne	done		*
pause:	DOS	_INKEY		*
	cmpi.b	#$20,d0		*
	beq	loop		*

done:	move.w	#-1,-(sp)	*�L�[��ǂݎ̂Ă�
	DOS	_KFLUSH		*

	move.l	#$0010_0000,-(sp)	*width 96
	DOS	_CONCTRL	*��ʍď�����
	DOS	_EXIT
*
	.data
	.even
*
HSIZE	equ	128
VSIZE	equ	128
*
arg:				*gxput�̈���
	.dc.w	0,0,511,511
	.dc.l	pat
	.dc.w	HSIZE-1,VSIZE-1
	.dc.l	temp
*
arg0:				*IOCS GETGRM�̈���
	.dc.w	256-HSIZE/2,256-VSIZE/2
	.dc.w	255+HSIZE/2,255+VSIZE/2
	.dc.l	pat
	.dc.l	pate
*
window:				*�N���b�s���O�E�B���h�E
	.dc.w	32,32,255-32,255-32
*
	.bss
	.even
*
pat:	.ds.w	HSIZE*VSIZE	*�`��p�^�[��
pate:
temp:	.ds.w	512*3		*gxput�̃��[�N
*
	.stack
	.even
*
	.ds.l	4096
inisp:
	.end	ent
