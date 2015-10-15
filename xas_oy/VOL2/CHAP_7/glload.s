*	�Ȉ�GL3�t�@�C�����[�_

	.include	doscall.mac
	.include	iocscall.mac
*
CR	equ	13
LF	equ	10
*
ROPEN	equ	0
STDERR	equ	2
*
SIZE	equ	512*1024
GRAMTOP	equ	$c00000
*
CSCREEN	equ	16
DOS_GL3	equ	5
*
CHKGRAM	equ	0
CHECK	equ	-1
BROKEN	equ	3
*
	.text
	.even
*
ent:
	lea.l	inisp(pc),sp	*sp������������

	moveq.l	#CHKGRAM,d1	*G-RAM��
	moveq.l	#CHECK,d2	*�@�g�p�\���H
	IOCS	_TGUSEMD	*
	cmpi.b	#BROKEN,d0	*�N�����g�����ςȂ��H
	beq	gramok		*�@�����Ȃ�g����
	tst.b	d0		*�N���g���Ă��Ȃ��H
	bne	rsrvd		*�@�N�����g���Ă���

gramok:	tst.b	(a2)+		*�t�@�C�����̎w��͂���H
	beq	usage		*�@�Ȃ�����

	move.w	#ROPEN,-(sp)	*�t�@�C�����J��
	move.l	a2,-(sp)	*
	DOS	_OPEN		*
	addq.l	#6,sp		*
	move.w	d0,d3		*d3 = �t�@�C���n���h��
	bmi	nfound		*

	move.w	#DOS_GL3,-(sp)	*��ʂ�512x512,65536�F��
	move.w	#CSCREEN,-(sp)	*�@������
	DOS	_CONCTRL	*
	addq.l	#4,sp		*

	moveq.l	#CHKGRAM,d1	*G-RAM���e��
	moveq.l	#BROKEN,d2	*�@�����󂵂܂���
	IOCS	_TGUSEMD	*
*
	move.l	#SIZE,-(sp)	*�t�@�C������G-RAM��
	move.l	#GRAMTOP,-(sp)	*�@���ړǂݍ���
	move.w	d3,-(sp)	*
	DOS	_READ		*
	lea.l	10(sp),sp	*
	tst.l	d0		*
	bmi	reader		*

	move.w	d3,-(sp)	*�t�@�C�������
	DOS	_CLOSE		*
	addq.l	#2,sp		*

	DOS	_EXIT		*����I��

*
*	�g�p�@�̕\�����G���[�I��
*
usage:	lea.l	usgmes(pc),a0
	bra	error
rsrvd:	lea.l	errms1(pc),a0
	bra	error
nfound:	lea.l	errms2(pc),a0
	bra	error
reader:	lea.l	errms3(pc),a0
	*
error:	move.w	#STDERR,-(sp)	*�W���G���[�o�͂�
	move.l	a0,-(sp)	*�@���b�Z�[�W��
	DOS	_FPUTS		*�@�o�͂���
	addq.l	#6,sp		*
	*
	move.w	#1,-(sp)	*�I���R�[�h�P��������
	DOS	_EXIT2		*�@�G���[�I��
*
	.data
	.even
*
usgmes:	.dc.b	'�@�@�\�FGL3�t�@�C�������[�h����',CR,LF
	.dc.b	'�g�p�@�FGLLOAD �t�@�C����.GL3',CR,LF,0
errms1:	.dc.b	'GLLOAD�FG-RAM�͑��̃v���O�������g�p���ł�',CR,LF,0
errms2:	.dc.b	'GLLOAD�F�w��̉摜�t�@�C����������܂���',CR,LF,0
errms3:	.dc.b	'GLLOAD�F�摜�t�@�C�����ǂݍ��߂܂���',CR,LF,0
*
	.stack
	.even
*
	.ds.l	4096		*�X�^�b�N�̈�
inisp:

	.end	ent
