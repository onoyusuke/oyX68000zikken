*	gfillpoly�̓��쎎���p�v���O����

	.include	doscall.mac
	.include	edge.h
*
NMAXPOINT	equ	7	*���_�̍ő吔�i2�`32767�j
NMAXEDGE	equ	NMAXPOINT*2+1	*�ӂ̍ő吔
*
	.xref	gfillpoly
	.xref	gclippoly
	.xref	genedgelist
	.xref	setcliprect
*
FPACK	macro	callno
	.dc.w	callno
	.endm
*
__RAND		equ	$fe0e
*
	.offset	0
*
EDGES:	.ds.l	1	*�Ӄ��X�g�擪�A�h���X
EDGEED:	.ds.l	1	*�Ӄ��X�g�ŏI�A�h���X
EDGARY:	.ds.l	1	*EDGBUF�̃|�C���^�z��p���[�N
COL:	.ds.l	1	*�`��F
*
	.text
	.even
*
ent:
	lea.l	inisp,sp

	move.l	#$0010_0005,-(sp)	*512x512,65536
	DOS	_CONCTRL	*��ʏ�����

	clr.l	-(sp)		*�X�[�p�[�o�C�U���[�h��
	DOS	_SUPER		*

*	pea.l	window		*�N���b�s���O�E�B���h�E�̐ݒ�
*	jsr	setcliprect	*
*	addq.l	#4,sp		*

	lea.l	arg,a1		*a1 = �����󂯓n���̈�
loop:	bsr	setarg		*�������Z�b�g

	pea.l	edges
	pea.l	pnts2
	pea.l	pnts
	jsr	gclippoly	*�N���b�s���O����
	addq.l	#4,sp
	jsr	genedgelist	*�Ӄ��X�g���쐬��
	addq.l	#8,sp
	move.l	a0,EDGEED(a1)	*�Ӄ��X�g�ŏI�A�h���X

	pea.l	(a1)		*�`��
	jsr	gfillpoly	*
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
setarg:
	lea.l	pnts,a0
	move.w	#NMAXPOINT,(a0)+
	move.w	#NMAXPOINT*2-1,d1
arglp:	FPACK	__RAND
	lsr.w	#7,d0		*0��d0��255
	addi.w	#128,d0		*128��d0��383
*	lsr.w	#6,d0		*0��d0��511
	move.w	d0,(a0)+
	dbra	d1,arglp

	FPACK	__RAND
	move.w	d0,COL(a1)
	rts
*
	.data
	.even
*
arg:	.dc.l	edges		*gfillpoly�ւ̈���
	.dc.l	edges		*
	.dc.l	edgary		*
	.dc.w	0		*�`��F
*
window:	.dc.w	64,64,511-64,511-64
*
	.bss
	.even
*
pnts:	.ds.w	1		*�N���b�s���O�O�̒��_
	.ds.l	NMAXPOINT
pnts2:	.ds.w	1		*�N���b�s���O��̒��_
	.ds.l	NMAXEDGE	*
edges:	.ds.b	NMAXEDGE*EDGBUFSIZ	*EDGBUF�̔z��
edgary:	.ds.l	NMAXEDGE+1	*EDGBUF�̃|�C���^�z��
				*�i�Ԑl�̕����܂ށj
*
	.stack
	.even
*
	.ds.l	2048
inisp:
	.end	ent
