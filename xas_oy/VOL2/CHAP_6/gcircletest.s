*	gcircle�̃e�X�g�p�v���O����

	.include	doscall.mac
	.include	iocscall.mac
*
	.xref	gcircle
*	.xref	goval
*	.xref	gfillcircle
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

				*512x512,65536
	move.l	#$0010_0005,-(sp)
	DOS	_CONCTRL	*��ʏ�����

*	pea	window		*�N���b�s���O�E�B���h�E�̐ݒ�
*	jsr	setcliprect	*
*	addq.l	#4,sp		*

	lea.l	arg,a1		*a1 = �����󂯓n���̈�
loop:	movea.l	a1,a0		*�������Z�b�g
	FPACK	__RAND		*�@���Sx
	lsr.w	#6,d0		*
	move.w	d0,(a0)+	*
				*
	FPACK	__RAND		*�@���Sy
	lsr.w	#6,d0		*
	move.w	d0,(a0)+	*
				*
	FPACK	__RAND		*�@���a�ix�������a�j
	lsr.w	#7,d0		*
	move.w	d0,(a0)+	*
				*
*	FPACK	__RAND		*�@y�������a
*	lsr.w	#7,d0		*
*	move.w	d0,(a0)+	*
				*
	FPACK	__RAND		*�@�`��F
	move.w	d0,(a0)+	*

	pea.l	(a1)		*�`��
	jsr	gcircle		*
*	jsr	goval		*
*	jsr	gfillcircle	*
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
arg:				*gcircle, goval�̈���
	.dc.w	0,0,0,0,0
*
window:				*�N���b�s���O�E�B���h�E
	.dc.w	32,32,255-32,255-32
*
	.stack
	.even
*
	.ds.l	4096
inisp:
	.end	ent
