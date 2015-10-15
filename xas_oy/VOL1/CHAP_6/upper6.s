*	�p���������p�啶���ϊ��t�B���^�@�ŏI��

	.include	doscall.mac
	.include	const.h
*
	.text
	.even
*
BUFFSIZE	equ	1024	*�o�b�t�@�̑傫��
*
ent:
	lea.l	mysp,sp		*sp�̏�����

	bsr	init		*���o�͊֌W�̏�����

	bsr	do		*�t�B���^�{��

	bsr	puteof		*�t�@�C���G���h�R�[�h���o��

	bsr	flushbuff	*�����o���o�b�t�@��f���o��
	tst.l	d0		*
	bmi	werror		*

	bsr	nl		*���s����i�W���G���[�o�́j

	DOS	_ALLCLOSE	*�S�t�@�C���N���[�Y

	DOS	_EXIT		*�I��

*
*	���������啶���ϊ����C�����[�v
*
do:
loop:	bsr	getchar		*�P�o�C�g�ǂݍ���
	tst.l	d0		*�G���[���H
	bmi	rerror		*�����Ȃ�G���[�I��

	cmpi.b	#EOF,d0		*�t�@�C���G���h�R�[�h���H
	beq	done		*�����Ȃ�I��

	cmpi.b	#$80,d0		*80H��菬�������
	bcs	hankaku		*	ASCII�R�[�h
	cmpi.b	#$a0,d0		*80H�ȏ�A0H�����Ȃ�
	bcs	zenkaku		*	�V�t�gJIS�̂P�o�C�g��
	cmpi.b	#$e0,d0		*A0H�ȏ�E0H�����Ȃ�
	bcs	hankaku		*	ASCII�J�^�J�i
				*E0H�ȏ�Ȃ�
				*	�V�t�gJIS�̂P�o�C�g��

zenkaku:		*�S�p�����̏���
	bsr	putchar		*�P�o�C�g�����o��
	tst.l	d0		*
	bmi	werror		*

	bsr	getchar		*�����P�o�C�g�ǂݍ���
	tst.l	d0		*
	bmi	rerror		*

	bsr	putchar		*���̂܂܏o�͂���
	tst.l	d0		*
	bmi	werror		*

	bra	loop		*�J��Ԃ�

hankaku:		*���p�����̏���
	bsr	toupper		*���������啶���ϊ�

	bsr	putchar		*�P�o�C�g�����o��
	tst.l	d0		*
	bmi	werror		*

	bra	loop		*�J��Ԃ�

done:	rts		*�ϊ��I��

*
*	�p���������p�啶���ϊ�
*
toupper:
	cmpi.b	#'a',d0		*�p���������H
	bcs	toupr0		*
	cmpi.b	#'z'+1,d0	*
	bcc	toupr0		*
	subi.b	#$20,d0		*�������Ȃ�啶���ɕϊ�
toupr0:	rts			*�T�u���[�`�����烊�^�[��

*
*	�t�@�C���G���h�R�[�h�̏o�́i�t�@�C���ɑ΂��Ă̂݁j
*
puteof:
	tst.b	devflg		*�o�͐悪
	bmi	pteof0		*�@�t�@�C���̂Ƃ��̂�
	moveq.l	#EOF,d0		*�@EOF�R�[�h��
	bsr	putchar		*�@�o�͂���
	tst.l	d0		*
	bmi	werror		*
pteof0:	rts

*
*	�P�o�C�g���͂���
*
getchar:
	move.l	a0,-(sp)	*�o���W�X�^��Ҕ�

	tst.l	rctr		*�o�b�t�@�Ƀf�[�^�͂��邩�H
	bne	getc0		*����΂���������o��

	bsr	fillbuff	*�o�b�t�@�𖞂���

	tst.l	d0		*d0<0...�G���[, d0 = 0...EOF
	bmi	getc1		*�G���[����������
	beq	eof		*�t�@�C�����I�����

getc0:	movea.l	rptr,a0		*�|�C���^�����o��
	moveq.l	#0,d0		*��ʃo�C�g���O�ɂ��Ă���
	move.b	(a0)+,d0	*�o�b�t�@����P�o�C�g���o��
	move.l	a0,rptr		*�|�C���^���X�V����
	subq.l	#1,rctr		*�J�E���^���X�V����
	bra	getc1
*
eof:	moveq.l	#EOF,d0		*EOF�R�[�h�������ċA��

getc1:	movea.l	(sp)+,a0	*�p���W�X�^�𕜋A
	rts

*
*	���̓o�b�t�@�𖞂���
*
fillbuff:
	move.l	#BUFFSIZE,-(sp)	*�o�b�t�@�Ƀf�[�^��ǂݍ���
	pea.l	rbuff		*
	move.w	rfno,-(sp)	*
	DOS	_READ		*
	lea.l	10(sp),sp	*

	move.l	#rbuff,rptr	*�|�C���^���ď�����
	move.l	d0,rctr		*�J�E���^���ď�����
	rts

*
*	�P�o�C�g�o�͂���
*
putchar:
	move.l	a0,-(sp)	*�o���W�X�^��Ҕ�

	andi.l	#$0000_00ff,d0	*��ʃr�b�g���}�X�N����

	movea.l	wptr,a0		*�|�C���^�����o��
	move.b	d0,(a0)+	*�o�b�t�@�ɂP�o�C�g�ǉ�����
	move.l	a0,wptr		*�|�C���^���X�V����
	addq.l	#1,wctr		*�J�E���^���X�V����

	cmpi.l	#BUFFSIZE,wctr	*�o�b�t�@����t�ɂȂ������H
	bcc	putc0		*�����Ȃ�o�b�t�@���e��f���o��

	tst.b	devflg		*�o�͐�̓L�����N�^�f�o�C�X���H
	bpl	putc1		*�����łȂ���΃��^�[��
	cmpi.b	#LF,d0		*�o�̓f�[�^��LF�R�[�h��
	bne	putc1		*�����łȂ���΃��^�[��

	move.w	#-1,-(sp)	*�L�[�o�b�t�@����ɂ���
	DOS	_KFLUSH		*
	addq.l	#2,sp		*

putc0:	bsr	flushbuff	*�o�b�t�@���e��f���o��

putc1:	movea.l	(sp)+,a0	*�p���W�X�^�𕜋A
	rts

*
*	�����o���o�b�t�@���e��f���o��
*
flushbuff:
	tst.l	wctr		*�o�b�t�@����ł����
	beq	flush0		*�@�Ȃɂ����Ȃ�

	move.l	wctr,-(sp)	*�o�b�t�@���e�������o��
	pea.l	wbuff		*
	move.w	wfno,-(sp)	*
	DOS	_WRITE		*
	lea.l	10(sp),sp	*
	tst.l	d0		*�G���[�H
	bmi	flush0		*�@�G���[�R�[�h�������ċA��
				*d0.l = ���ۂɏ����o�����o�C�g��
	sub.l	wctr,d0		*d0.l=wctr ... d0.l = 0�@��G���[
				*d0.l<wctr ... d0.l < 0�@�G���[

	move.l	#wbuff,wptr	*�|�C���^���ď�����
	clr.l	wctr		*�J�E���^���ď�����

flush0:	rts

*
*	���o�͏�����
*
init:
	move.l	#rbuff,rptr	*�ǂݍ��݃o�b�t�@�ւ̃|�C���^
	move.l	#wbuff,wptr	*�����o���o�b�t�@�ւ̃|�C���^
	clr.l	rctr		*�ǂݍ��ݗp�J�E���^
	clr.l	wctr		*�����o���p�J�E���^

	addq.l	#1,a2		*a2=�R�}���h���C��
	bsr	ropen		*rfno=���͐�̃t�@�C���n���h��
	bsr	wopen		*wfno=�o�͐�̃t�@�C���n���h��

	bsr	nextarg		*���̈�����
	tst.b	(a2)		*�@���邩�H
	bne	usage		*���������߂���

	rts

*
*	���͐�t�@�C���n���h���𓾂�
*
ropen:
	bsr	nextarg		*���̈����̐擪�A�h���X�𓾂�
	tst.b	(a2)		*������͂܂����邩�H
	beq	ropen0		*�Ȃ���΃t�@�C�����w��Ȃ�

*�t�@�C�����̎w�肪�������ꍇ
	bsr	getarg		*�t�@�C������temp�ɔ����o��

	move.w	#ROPEN,-(sp)	*�w�肳�ꂽ�t�@�C����
	pea.l	temp		*�@���[�h�I�[�v������
	DOS	_OPEN		*
	addq.l	#6,sp		*
	bra	ropen1

*�t�@�C�����̎w�肪�Ȃ������ꍇ
ropen0:	move.w	#STDIN,-(sp)	*�W�����͂̃t�@�C���n���h����
	DOS	_DUP		*�@��������
	addq.l	#2,sp		*

*d0�ɂ�
*�@�t�@�C�����̎w�肪�������Ƃ��̓I�[�v�������t�@�C���n���h����
*�@�w�肪�Ȃ������Ƃ��͕W�����͂𕡐������t�@�C���n���h���������Ă���
ropen1:	tst.l	d0		*�G���[�H
	bmi	rerror		*�@�����Ȃ�G���[�I��

	move.w	d0,rfno		*���͐�t�@�C���n���h�������܂�

	move.w	#STDIN,-(sp)	*�W�����͂��N���[�Y����
	DOS	_CLOSE		*�@�L�[�{�[�h(CON)�Ɋ��蓖�Ă�߂�
	addq.l	#2,sp		*
	tst.l	d0		*�G���[�H
	bmi	rerror		*�@�����Ȃ�G���[�I��

	rts

*
*	�o�͐�t�@�C���n���h���𓾂�
*
wopen:
	move.w	#STDOUT,wfno	*���ɕW���o�͂̃n���h�����Z�b�g���Ă���

	bsr	nextarg		*���̈����̐擪�A�h���X�𓾂�
	tst.b	(a2)		*������͂܂����邩�H
	beq	wopen1		*�Ȃ���΃t�@�C�����w��Ȃ�

*�t�@�C�����̎w�肪�������ꍇ
	bsr	getarg		*�t�@�C������temp�ɔ����o��

	move.w	#ARCHIVE,-(sp)	*�w�肳�ꂽ�t�@�C����
	pea.l	temp		*�@�V�K�쐬����
	DOS	_CREATE		*
	addq.l	#6,sp		*
	tst.l	d0		*�G���[�H
	bpl	wopen0		*�@�G���[���Ȃ���΃I�[�v������

	move.w	#WOPEN,-(sp)	*create�ŃG���[�����������Ƃ���
	pea.l	temp		*�@open���g����
	DOS	_OPEN		*�@������x���C�g�I�[�v�����Ă݂�
	addq.l	#6,sp		*
	tst.l	d0		*�G���[�H
	bmi	werror		*�@�����Ȃ獡�x�����G���[�I��

wopen0:	move.w	d0,wfno		*�o�͐�t�@�C���n���h�������܂�

*�t�@�C�����̎w�肪�Ȃ������ꍇ�͒��ڂ����ɂ���iwfno = STDIN�j
*�t�@�C�����̎w�肪�������ꍇ��wfno�ɏo�͐�n���h���������Ă���
wopen1:	move.w	wfno,-(sp)	*�o�͐�̑��u�������o��
	clr.w	-(sp)		*
	DOS	_IOCTRL		*
	addq.l	#4,sp		*

	move.b	d0,devflg	*devflg�̑�V�r�b�g���P�ł����
				*�@�L�����N�^�f�o�C�X
	rts

*
*	���̈����擪�܂Ń|�C���^��i�߂�
*
nextarg:
	bsr	skipsp		*�X�y�[�X���X�L�b�v

	cmpi.b	#'/',(a2)	*�����̐擪��
	beq	usage		*�@/,-,?�ł����
	cmpi.b	#'-',(a2)	*�@�g�p�@��\�����ďI������
	beq	usage		*
	cmpi.b	#'?',(a2)	*
	beq	usage		*

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
*	�����P�����ꎞ�o�b�t�@�ɃR�s�[����
*
getarg:
	lea.l	temp,a0		*a0=�]����
gtarg0:	tst.b	(a2)		*1)������̏I�[�R�[�h��
	beq	gtarg1		*
	cmpi.b	#SPACE,(a2)	*2)�X�y�[�X��
	beq	gtarg1		*
	cmpi.b	#TAB,(a2)	*3)�^�u��
	beq	gtarg1		*
	cmpi.b	#'-',(a2)	*4)�n�C�t����
	beq	gtarg1		*
	cmpi.b	#'/',(a2)	*5)�X���b�V��
	beq	gtarg1		*
	move.b	(a2)+,(a0)+	*�@�������܂œ]����
	bra	gtarg0		*�@�J��Ԃ�
gtarg1:	clr.b	(a0)		*������I�[�R�[�h����������
	rts

*
*	�g�p�@�̕\���E�I��
*
usage:
	lea.l	usgmes,a0	*�g�p�@
	bra	error

*
*	�J�[�\������ʂ̍��[�ɂȂ���Ή��s����
*
nl:
	move.w	#-1,-(sp)	*�J�[�\�����W�����o��
	move.w	#-1,-(sp)	*
	move.w	#3,-(sp)	*
	DOS	_CONCTRL	*
	addq.l	#6,sp		*
				*d0.l = xxxx_yyyy
	swap.w	d0		*d0.l = yyyy_xxxx
	tst.w	d0		*x���W�͂O���H
	beq	nl0		*�@�O�Ȃ�Ȃɂ����Ȃ�

ltnl:	move.l	a0,-(sp)	*�o
	lea.l	crlfms,a0	*���s����
	bsr	puterr		*
	movea.l	(sp)+,a0	*�p

nl0:	rts

*
*	���b�Z�[�W�\���i�W���G���[�o�͂ցj
*
puterr:	move.w	#STDERR,-(sp)	*�W���G���[�o�͂�
	move.l	a0,-(sp)	*�@�������
	DOS	_FPUTS		*�@�o�͂���
	addq.l	#6,sp		*�X�^�b�N�␳
	rts

*
*	�G���[�I��
*
rerror:	lea.l	rerrms,a0	*�ǂݍ��ݎ��G���[
	bra	error
werror:	lea.l	werrms,a0	*�����o�����G���[
	*
error:	bsr	puterr		*���b�Z�[�W��\��

	move.w	#1,-(sp)	*�I���R�[�h�P��������
	DOS	_EXIT2		*�@�G���[�I��

*
*	���b�Z�[�W�f�[�^
*
	.data
	.even
*
rerrms:	.dc.b	CR,LF,'UPPER�F���܂��ǂݍ��߂܂���ł���',CR,LF,0
werrms:	.dc.b	CR,LF,'UPPER�F���܂������o���܂���ł���',CR,LF,0
crlfms:	.dc.b	CR,LF,0
usgmes:	.dc.b	'�g�p�@�FUPPER�m���̓t�@�C���m�o�̓t�@�C���n�n',CR,LF
	.dc.b	'	���p�p��������啶���ɕϊ����܂�',CR,LF
	.dc.b	'	�o�̓t�@�C�����ȗ����ꂽ�ꍇ��'
	.dc.b	'�W���o�͂֏o�͂��܂�',CR,LF
	.dc.b	'	���̓t�@�C�����ȗ����ꂽ�ꍇ��'
	.dc.b	'�W�����͂�����͂��܂�',CR,LF
	.dc.b	0

*
*	���[�N�G���A
*
	.bss
	.even
*
rptr:	.ds.l	1		*�ǂݍ��݃|�C���^�igetchar�Ŏg�p�j
rctr:	.ds.l	1		*�ǂݍ��݃J�E���^�igetchar�Ŏg�p�j
rfno:	.ds.w	1		*���̓t�@�C���n���h���igetchar�Ŏg�p�j
wptr:	.ds.l	1		*�����o���|�C���^�iputchar�Ŏg�p�j
wctr:	.ds.l	1		*�����o���J�E���^�iputchar�Ŏg�p�j
wfno:	.ds.w	1		*�o�̓t�@�C���n���h���iputchar�Ŏg�p�j
*
devflg:	.ds.b	1		*�o�͐�t���O�iputchar,puteof�Ŏg�p�j
				*	bit7=0...�t�@�C��
				*	    =1...�L�����N�^�f�o�C�X
*
temp:				*�ꎞ�o�b�t�@�i���̂�rbuff�j
rbuff:	.ds.b	BUFFSIZE	*�ǂݍ��݃o�b�t�@�igetchar�Ŏg�p�j
wbuff:	.ds.b	BUFFSIZE	*�����o���o�b�t�@�iputchar�Ŏg�p�j
*
	.stack
	.even
*
mystack:
	.ds.l	256		*�X�^�b�N�̈�
mysp:
	.end
