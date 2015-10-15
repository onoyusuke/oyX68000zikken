*	�f�o�C�X�h���C�o�̑g�ݍ��ݏ󋵂�\������
*
	.include	doscall.mac
	.include	const.h
	.include	driver.h
*
	.xref	itoh
*
PUTC	macro	chr		*�P�����o�̓}�N��
	move.w	chr,-(sp)
	DOS	_PUTCHAR
	addq.l	#2,sp
	endm
*
PUTSP	macro			*�X�y�[�X�P�o�̓}�N��
	PUTC	#SPACE
	endm
*
PUTS	macro	strptr		*������o�̓}�N��
	pea.l	strptr
	DOS	_PRINT
	addq.l	#4,sp
	endm
*
NEWLIN	macro			*���s�}�N��
	PUTS	crlfms
	endm
*
SELMES	macro	bit,str1,str2	*�����r�b�g�ɉ�����
	local	skip,done	*�@�Q��ނ̕������
	btst.l	#bit,d7		*�@�ǂ��炩��\������}�N��
	beq	skip
	PUTS	str1
	bra	done
skip:	PUTS	str2
done:
	endm
*
	.text
	.even
*
ent:
	lea.l	mysp,sp		*sp�̏�����

	clr.l	-(sp)		*�X�[�p�[�o�C�U���[�h�ֈڍs
	DOS	_SUPER		*
	move.l	d0,(sp)		*ssp�Ҕ�

	bsr	chkarg		*�R�}���h���C���̉��

	bsr	do		*���C������

	DOS	_SUPER		*���[�U�[���[�h�֕��A
	addq.l	#4,sp		*

	DOS	_EXIT		*����I��

*
*	���C������
*
do:
	bsr	seanul		*�f�o�C�X�h���C�o�����N��
				*�@�擪��T��
	tst.l	d1		*�����������Ȃ����
	bmi	error		*�@�G���[

	PUTS	title		*���o���\��

loop:	movea.l	d1,a0		*a0=�f�o�C�X�h���C�o�擪
	move.w	DEVATR(a0),d7	*d7.w=�f�o�C�X����

	bsr	prtadr		*�擪�A�h���X��\������
	bsr	prtnam		*�f�o�C�X����\������
	bsr	prtatr		*�f�o�C�X������\������
	SELMES	IOCTRL_BIT,okmes,notmes
				*IOCTRL��/�s��\������
	NEWLIN			*���s����

	move.l	DEVLNK(a0),d1	*d1=���̃f�o�C�X�h���C�o�擪
	cmpi.l	#-1,d1		*d1=-1�ł���ΏI��
	bne	loop		*�����łȂ���ΌJ��Ԃ�

	rts			*��������
*
HUMANST	equ	$6800		*Human68k�擪�A�h���X
NULATR	equ	$8024		*NUL�f�o�C�X�̃f�o�C�X����
*
seanul:
	lea.l	nulnam,a0	*a0=�����f�o�C�X��
	move.w	(a0)+,d0	*d0='NU'
	move.l	(a0)+,d1	*d1='L   '
	move.w	(a0)+,d2	*d2='  '

	lea.l	HUMANST,a0	*a0=Human�擪�A�h���X

seanl0:	cmp.w	(a0)+,d0	*�擪�Q�������r
	bne	seanl0		*��v����܂ŌJ��Ԃ�
				*�i�f�o�C�X�w�b�_�͕K��
				*�@�����Ԓn����n�܂�j
	cmp.l	(a0),d1		*�^�񒆂S�������r
	bne	seanl0		*��v���Ȃ���΂�蒼��

	cmp.w	4(a0),d2	*�㔼�Q�������r
	bne	seanl0		*��v���Ȃ���΂�蒼��

	cmpa.l	nulnam+2,a0	*�{����NUL�f�o�C�X���ǂ�����
	beq	notfound	*�@�`�F�b�N�P

	cmp.w	#NULATR,DEVATR-DEVNAM-2(a0)	*�`�F�b�N�Q
	bne	seanl0				*

	lea.l	DEVLNK-DEVNAM-2(a0),a0	*a0=�f�o�C�X�h���C�o�擪
	move.l	a0,d1			*d1=����
	rts
notfound:
	moveq.l	#-1,d1		*NUL�f�o�C�X��������Ȃ������I�H
	rts

*
*	�f�o�C�X�h���C�o�̐擪�A�h���X��\������
*
prtadr:
	pea.l	temp		*�A�h���X��16�i�W���ɕϊ�����
	move.l	a0,-(sp)	*
	bsr	itoh		*
	addq.l	#8,sp		*

	PUTS	temp+2		*���U���݂̂�\������

	PUTSP			*�X�y�[�X�o��
	rts

*
*	�f�o�C�X����\������
*
prtnam:
	lea.l	DEVNAM(a0),a1	*a1=�f�o�C�X���擪
	moveq.l	#0,d1		*��ʃo�C�g���N���A���Ă���
	moveq.l	#8-1,d2		*�f�o�C�X���͂W����

prtnm0:	move.b	(a1)+,d1	*�P�������o��
	cmpi.b	#SPACE,d1	*�R���g���[���R�[�h���H
	bcc	prtnm1		*�����łȂ���΂��̂܂ܕ\��
	moveq.l	#'.',d1		*'.'�ɕϊ�����
prtnm1:	PUTC	d1		*�P�����o��
	dbra	d2,prtnm0	*�J��Ԃ�
	rts

*
*	�f�o�C�X������\������
*
prtatr:
	btst.l	#ISCHRDEV_BIT,d7
	beq	prtat2

	PUTS	chrmes		*�ȉ��L�����N�^�f�o�C�X�p

	SELMES	ISRAW_BIT,rawmes,cokmes

	move.w	d7,d1

	lea.l	atrdat,a1
	moveq.l	#0,d2
	moveq.l	#4-1,d3
prtat0:	move.b	(a1)+,d2
	lsr.w	#1,d1
	bcs	prtat1
	moveq.l	#'-',d2
prtat1:	PUTC	d2
	dbra	d3,prtat0
	rts

prtat2:	PUTS	blkmes		*�u���b�N�f�o�C�X�̂Ƃ�
	rts

*
*	�R�}���h���C���̉��
*
chkarg:
	addq.l	#1,a2		*a2=�R�}���h���C��������擪
	bsr	skipsp		*�擪�̃X�y�[�X���΂�
	tst.b	(a2)
	bne	usage
	rts

*
*	�R�}���h���C���擪�̃X�y�[�X���X�L�b�v����
*
skpsp0:	addq.l	#1,a2		*�|�C���^��i��
				*�J��Ԃ�
skipsp:				*�T�u���[�`���͂�������n�܂�
	cmpi.b	#SPACE,(a2)	*�X�y�[�X���H
	beq	skpsp0		*�@�����Ȃ��΂�
	cmpi.b	#TAB,(a2)	*TAB���H
	beq	skpsp0		*�@�����Ȃ��΂�
	rts

*
*	�G���[�I��/�g�p�@�̕\��
*
usage:
	lea.l	usgmes,a0	*�g�p�@���b�Z�[�W
	bra	errout
*
error:	lea.l	errmes,a0	*NUL�h���C�o���Ȃ�
	*
errout:	move.w	#STDERR,-(sp)	*�W���G���[�o�͂�
	move.l	a0,-(sp)	*�@���b�Z�[�W��
	DOS	_FPUTS		*�@�o�͂���
	addq.l	#6,sp		*

	move.w	#1,-(sp)	*�I���R�[�h�P��������
	DOS	_EXIT2		*�@�G���[�I��

*
*	�f�[�^
*
	.data
	.even
*
*		 12345678
nulnam:	.dc.b	'NUL     '	*�����f�o�C�X��
*
title:	.dc.b	' �J�n  �f�o�C�X��       ����        IOCTRL',CR,LF
	.dc.b	'------ ---------- ----------------- ------',CR,LF,0
*		 12345678901234567890
chrmes:	.dc.b	'   CHR ',0
blkmes:	.dc.b	'   BLOCK            ',0
rawmes:	.dc.b	'(RAW)    ',0
cokmes:	.dc.b	'(COOKED) ',0
okmes:	.dc.b	'   ��',0
notmes:	.dc.b	'  �s��',0
*		 123456789
*
atrdat:	.dc.b	'IONC'		*�����\���p�f�[�^
*
usgmes:	.dc.b	'�@�@�\�F�f�o�C�X�h���C�o�̑g�ݍ��ݏ󋵂�'
	.dc.b		'�\�����܂�',CR,LF
	.dc.b	'�g�p�@�FDEVICE',CR,LF,0
*
errmes:	.dc.b	'DEVICE�F���肦�Ȃ����Ƃł����c',CR,LF
	.dc.b	'        NUL�f�o�C�X��������܂���'
crlfms:	.dc.b	CR,LF,0
*
	.bss
	.even
*
temp:	.ds.b	8+1		*16�i�ϊ��p���[�N
*
	.stack
	.even
*
mystack:
	.ds.l	256		*�X�^�b�N�̈�
mysp:
	.end
