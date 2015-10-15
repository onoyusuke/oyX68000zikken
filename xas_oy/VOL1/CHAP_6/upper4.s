*	�p���������p�啶���ϊ��t�B���^�@��S��

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
	move.w	#STDIN,-(sp)	*
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
	move.w	#STDOUT,-(sp)	*
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

	move.w	#STDOUT,-(sp)	*�W���o�͂̑��u�������o��
	clr.w	-(sp)		*
	DOS	_IOCTRL		*
	addq.l	#4,sp		*

	move.b	d0,devflg	*devflg�̑�V�r�b�g���P�ł����
				*�@�L�����N�^�f�o�C�X
	rts

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

*
*	���[�N�G���A
*
	.bss
	.even
*
rptr:	.ds.l	1		*�ǂݍ��݃|�C���^�igetchar�Ŏg�p�j
rctr:	.ds.l	1		*�ǂݍ��݃J�E���^�igetchar�Ŏg�p�j
wptr:	.ds.l	1		*�����o���|�C���^�iputchar�Ŏg�p�j
wctr:	.ds.l	1		*�����o���J�E���^�iputchar�Ŏg�p�j
*
devflg:	.ds.b	1		*�o�͐�t���O�iputchar,puteof�Ŏg�p�j
				*	bit7=0...�t�@�C��
				*	    =1...�L�����N�^�f�o�C�X
*
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
