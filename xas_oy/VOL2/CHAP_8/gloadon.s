*	�摜���d�ˍ��킹�ă��[�h����

	.include	doscall.mac
	.include	iocscall.mac
	.include	gconst.h
*
	.xref	gputon
*
CR	equ	13
LF	equ	10
*
ROPEN	equ	0
STDERR	equ	2
*
MAXMEM	equ	GNBYTE*GNPIXEL
MINMEM	equ	GNBYTE
*
	.offset	0	*gputon�̈����\��
*
X0:	.ds.w	1	*��`�̈�
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
PAT:	.ds.l	1	*�p�^�[��
COL:	.ds.l	1	*�����F
*
	.text
	.even
*
ent:
	lea.l	inisp(pc),sp

	tst.b	(a2)+		*�R�}���h�s�����͂��邩�H
	beq	usage		*�@�Ȃ���Ύg�p�@��\�����ďI��

	lea.l	16(a0),a0	*�v���O�����̌��̗]���ȃ�������؂����
	suba.l	a0,a1		*
	movem.l	a0-a1,-(sp)	*
	DOS	_SETBLOCK	*
	addq.l	#8,sp		*

	moveq.l	#-1,d1		*�O���t�B�b�N��ʂ͏���������Ă��邩�H
	IOCS	_APAGE		*
	tst.b	d0		*
	bmi	ninit		*���������Ȃ�G���[�I��

	clr.l	-(sp)		*�X�[�p�[�o�C�U���[�h�ֈڍs
	DOS	_SUPER		*

	move.l	#MAXMEM,d1	*�t�@�C���ǂݍ��ݗp�̃��������m�ۂ���
	move.w	#GNPIXEL,d2	*
	moveq.l	#1,d3		*
	move.l	#MINMEM,d4	*
memlp:	move.l	d1,-(sp)	*
	DOS	_MALLOC		*
	addq.l	#4,sp		*
	tst.l	d0		*
	bpl	memok		*
	lsr.l	#1,d1		*
	lsr.w	#1,d2		*
	add.w	d3,d3		*
	cmp.l	d4,d1		*
	bcc	memlp		*
	bra	nomem		*�������s��������
*
memok:	movea.l	d0,a0
	move.w	d2,d4
	subq.w	#1,d2
	subq.w	#1,d3

*	a0 = �t�@�C���ǂݍ��ݗp�o�b�t�@
*	a2 = �t�@�C����
*	d1 = ��x�ɏ�������o�C�g��
*	d2 = ��x�ɏ������郉�C�����|�P
*	d3 = �����񐔁|�P�i�����[�v�J�E���^�j
*	d4 = ��x�ɏ������郉�C����

	lea.l	argbuf(pc),a1	*gputon�ւ̈����̏�����
	clr.l	X0(a1)
	move.w	#GNPIXEL-1,X1(a1)
	move.w	d2,Y1(a1)
	move.l	a0,PAT(a1)
*
	move.w	#ROPEN,-(sp)	*�t�@�C���I�[�v��
	pea.l	(a2)		*
	DOS	_OPEN		*
	addq.l	#6,sp		*
	move.w	d0,d2		*d2 = �t�@�C���n���h��
	bmi	nfound		*
*
	pea.l	2.w		*�t�@�C���擪�̂Q�o�C�g��ǂݍ���
	pea.l	COL(a1)		*�@�����F�Ƃ���
	move.w	d2,-(sp)	*
	DOS	_READ		*
	lea.l	10(sp),sp	*
	subq.l	#2,d0		*
	bne	rerror		*
*
	move.w	d0,-(sp)	*�t�@�C���������߂�
	move.l	d0,-(sp)	*
	move.w	d2,-(sp)	*
	DOS	_SEEK		*
	addq.l	#8,sp		*
*
putlp:	move.l	d1,-(sp)	*�t�@�C������ǂݍ���
	pea.l	(a0)		*
	move.w	d2,-(sp)	*
	DOS	_READ		*
	lea.l	10(sp),sp	*
	tst.l	d0		*
	bmi	rerror		*

	pea.l	(a1)		*�`��
	jsr	gputon		*
	addq.l	#4,sp		*

	add.w	d4,Y0(a1)	*���̕`��ʒu
	add.w	d4,Y1(a1)	*

	dbra	d3,putlp	*�J��Ԃ�

	DOS	_EXIT
*
usage:	lea.l	usgmes(pc),a0
	bra	error
ninit:	lea.l	errms1(pc),a0
	bra	error
nomem:	lea.l	errms2(pc),a0
	bra	error
nfound:	lea.l	errms3(pc),a0
	bra	error
rerror:	lea.l	errms4(pc),a0
	*
error:	move.w	#STDERR,-(sp)
	pea.l	(a0)
	DOS	_FPUTS

	move.w	#1,-(sp)
	DOS	_EXIT2
*
	.data
	.even
*
usgmes:	.dc.b	'�@�@�\�FGL3�t�@�C�����d�ˍ��킹���[�h����',CR,LF
	.dc.b	'�g�p�@�FGLOADON�@�t�@�C����',CR,LF,0
errms1:	.dc.b	'GLOADON�FG-RAM������������Ă��܂���',CR,LF,0
errms2:	.dc.b	'GLOADON�F�������s���ł�',CR,LF,0
errms3:	.dc.b	'GLOADON�F�w��̃t�@�C����������܂���',CR,LF,0
errms4:	.dc.b	'GLOADON�F�t�@�C�������܂��ǂݍ��߂܂���',CR,LF,0
*
	.bss
	.even
*
argbuf:	.ds.w	4	*��`�̈�
	.ds.l	1	*�p�^�[��
	.ds.w	1	*�����F
*
	.stack
	.even
*
	.ds.l	4096
inisp:

	.end	ent
