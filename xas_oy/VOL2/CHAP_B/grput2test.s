*	grput2�̃e�X�g�p�v���O����

	.include	doscall.mac
	.include	iocscall.mac
*
	.xref	grput2
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

				*512x512,65536
	move.l	#$0010_0005,-(sp)
	DOS	_CONCTRL	*��ʏ�����

	lea.l	arg,a1		*a1 = �����󂯓n���̈�
loop:	movea.l	a1,a0		*�������Z�b�g
	moveq.l	#4-1,d1		*
loop2:	FPACK	__RAND		*
	lsr.w	#6,d0		*
	move.w	d0,(a0)+	*
	dbra	d1,loop2	*
				*
	FPACK	__RAND		*
	divu.w	#360,d0		*
	swap.w	d0		*
	move.w	d0,(a0)+	*��]�p�x

	pea.l	(a1)		*�`��
	jsr	grput2		*
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
arg:				*grput2�̈���
	.dc.w	0,0,0,0
	.dc.w	0
	.dc.l	pat
	.dc.w	HSIZE-1,VSIZE-1
*
arg0:				*IOCS GETGRM�̈���
	.dc.w	256-HSIZE/2,256-VSIZE/2
	.dc.w	255+HSIZE/2,255+VSIZE/2
	.dc.l	pat
	.dc.l	pate
*
window:	.dc.w	80,80,175,175
*
	.bss
	.even
*
pat:	.ds.w	HSIZE*VSIZE	*�`��p�^�[��
pate:
*
	.stack
	.even
*
	.ds.l	4096
inisp:
	.end	ent
