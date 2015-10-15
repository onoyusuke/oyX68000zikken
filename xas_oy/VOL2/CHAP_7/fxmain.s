*	�G�t�F�N�g�n�T�u���[�`���Q�̃��C�����[�`��

	.include	doscall.mac
	.include	iocscall.mac
*
	.xref	gnegate
*
NARG	equ	4	*�����̌�
*
FPACK	macro	callno
	.dc.w	callno
	endm
*
__STOL	equ	$fe10	*10�i�����񁨐��l�ϊ�
__STOH	equ	$fe12	*16�i�����񁨐��l�ϊ�
__RAND	equ	$fe0e	*�����i0�`32767�j
*
CR	equ	13
LF	equ	10
TAB	equ	9
SPACE	equ	32
*
STDERR	equ	2
*
	.text
	.even
*
ent:
	lea.l	inisp,sp

	bsr	getarg		*�������擾����

	moveq.l	#-1,d1		*��ʂ͏���������Ă��邩�H
	IOCS	_APAGE		*
	tst.b	d0		*
	bmi	error		*��������������

	clr.l	-(sp)		*�X�[�p�[�o�C�U���[�h�ֈڍs����
	DOS	_SUPER		*

	pea.l	argbuf		*�T�u���[�`�����Ăяo��
	jsr	gnegate		*
*	addq.l	#4,sp		*

	DOS	_EXIT

*
*	NARG�̐��l���o�b�t�@�ɃZ�b�g����
*
getarg:
	tst.b	(a2)+		*�󕶎���Ȃ�
	beq	noarg		*�@�f�t�H���g�l���̗p

	movea.l	a2,a0		*a0 = �R�}���h���C��
	lea.l	argbuf,a1	*a1 = �����i�[�o�b�t�@
	moveq.l #NARG-1,d1	*d1 = ���[�v�J�E���^
getpr0:	bsr	skipsp		*��s����󔒂��΂�
	move.b	(a0)+,d0	*������I�[�H
	beq	usage		*�@�����Ȃ����������Ȃ�
	cmpi.b	#'#',d0		*
	beq	codarg		*
	cmpi.b	#'?',d0		*
	beq	colarg		*
	cmpi.b	#'$',d0		*
	beq	hexarg		*
	subq.l	#1,a0		*
decarg:	FPACK	__STOL		*10�i
	bra	argchk		*
colarg:	FPACK	__RAND		*0�`65534�̗���
	add.w	d0,d0		*
	bra	argset		*
codarg:	FPACK	__RAND		*0�`511�̗���
	lsr.w	#6,d0		*
	bra	argset		*
hexarg:	FPACK	__STOH		*16�i
argchk:	bcs	usage		*���܂��ϊ��ł��Ȃ�����
argset:	move.w	d0,(a1)+	*�������i�[
	dbra	d1,getpr0	*�K�v�Ȃ����J��Ԃ�
noarg:	rts
*
skpsp0:	addq.l	#1,a0
skipsp:	cmpi.b	#SPACE,(a0)
	beq	skpsp0
	cmpi.b	#TAB,(a0)
	beq	skpsp0
	rts
*
usage:	lea.l	usgmes,a0
	bra	error0
*
error:	lea.l	errmes,a0
error0:	move.w	#STDERR,-(sp)	*�W���G���[�o�͂�
	pea.l	(a0)		*�@���b�Z�[�W���o�͂���
	DOS	_FPUTS		*
	addq.l	#6,sp		*
	move.w	#1,-(sp)	*�I���R�[�h�P��������
	DOS	_EXIT2		*�@�G���[�I��
*
	.data
	.even
*
argbuf:	.dc.w	0,0,511,511	*�f�t�H���g����
*
usgmes:	.dc.b	'�@�@�\�F�摜�̐F�𔽓]����',CR,LF
	.dc.b	'�g�p�@�FGNEGATE [x0 y0 x1 y1]',CR,LF,0
errmes: .dc.b	'�O���t�B�b�N��ʂ�����������Ă��܂���',CR,LF,0
*
	.stack
	.even
*
mystack:
	.ds.l	4096		*�X�^�b�N�̈�
inisp:

	.end	ent
