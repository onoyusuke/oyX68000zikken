*	gline�̃e�X�g�p�v���O����

	.include	doscall.mac
	.include	iocscall.mac
*
	.xref	gline
*	.xref	setcliprect
*
CR	equ	13
LF	equ	10
*
FPACK	macro	callno
	.dc.w	callno
	endm
*
__RAND		equ	$fe0e	*�����i0�`32767�j
__IUSING	equ	$fe18	*������������ϊ�
				*�i�����w����j
*
	.text
	.even
*
ent:
	lea.l	inisp,sp

	move.l	#$0010_0005,-(sp)
				*512x512,65536�F��
	DOS	_CONCTRL	*�@������

	clr.l	-(sp)		*�X�[�p�[�o�C�U���[�h�ֈڍs
	DOS	_SUPER		*

*	pea.l	window		*�N���b�s���O
*	jsr	setcliprect	*�@�E�B���h�E��
*	addq.l	#4,sp		*�@�ݒ肷��

	lea.l	argbuf,a1	*a1 = �����󂯓n���̈�

	IOCS	_ONTIME		*�J�n���̎����𓾂�
	move.l	d0,-(sp)	*

	move.w	#50000-1,d7	*50000�{�̃����_���Ȑ�����`��
loop:	bsr	setarg		*
	pea.l	(a1)		*
	jsr	gline		*
	addq.l	#4,sp		*
*IOCS	_LINE			*
	dbra	d7,loop		*

	IOCS	_ONTIME		*�I�����̎����𓾂�
	sub.l	(sp)+,d0	*d0 = ���[�v�̎��s����
	bpl	tskip2		*
	addi.l	#24*3600*100,d0	*

tskip2:	lea.l	temp,a0		*���Ԃ�
	moveq.l	#7,d1		*�@10�i�V���E�l�߂�
	FPACK	__IUSING	*�@������ɕϊ�����

	bsr	conv		*1/100�b�P�ʂ���b�P�ʂ�
	pea.l	temp		*�`��ɗv����
	DOS	_PRINT		*�@���Ԃ�\������
	pea.l	secmes		*
	DOS	_PRINT		*

	DOS	_EXIT

*
*	�����_���Ɏn�_/�I�_�����߂�
*
setarg:
	movea.l	a1,a0
	move.w	#4-1,d6
arglp:	FPACK	__RAND
	lsr.w	#6,d0	*0��d0��511
*lsr.w	#5,d0		*0��d0��1023
*subi.w	#256,d0		*-256��d0��767
	move.w	d0,(a0)+
	dbra	d6,arglp
	rts

*
*	1/100�b�P�ʂ���P�b�P�ʂ֕ϊ�����i�����񃌃x���j
*
conv:
	lea.l	temp+7,a1
	lea.l	temp+8,a2
	moveq.l	#$20,d1
	moveq.l	#'0',d2
	clr.b	(a2)
	move.b	-(a1),-(a2)
	move.b	-(a1),d0
	cmp.b	d1,d0
	bne	skip1
	move.b	d2,d0
skip1:	move.b	d0,-(a2)
	move.b	#'.',-(a2)
	move.b	-(a2),d0
	cmp.b	d1,d0
	bne	skip2
	move.b	d2,(a2)
skip2:	rts
*
	.data
	.even
*
window:	.dc.w	128,128,511-128,511-128
argbuf:	.dc.w	0,0,0,0,63	*������
	.dc.w	$ffff		*���C���X�^�C���iIOCS�p�j
secmes:	.dc.b	' sec.',CR,LF,0
*
	.bss
	.even
*
temp:	.ds.b	10	*���l��������ϊ��p
*
	.stack
	.even
*
	.ds.l	4096
inisp:
	.end	ent
