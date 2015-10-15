*	�W���G���[�o�͂����_�C���N�g����
*
*	�쐬�@�Fas rderr
*		lk rderr child memoff
*
	.include	doscall.mac
	.include	const.h
*
	.xref	child		*�O���Q��
	.xref	memoff		*
*
	.text
	.even
*
ent:
	lea.l	mysp,sp		*sp�̏�����

	bsr	memoff		*�]���ȃ��������J������

	bsr	chkarg		*�R�}���h���C���̉��

	bsr	do		*���C������

	DOS	_EXIT		*�I��

*
*	���C������
*
do:
	bsr	err_redirect	*�W���G���[�o�͂�
				*�@���_�C���N�g
	move.l	a2,-(sp)	*�`���C���h�v���Z�X�N��
	bsr	child		*
	addq.l	#4,sp		*

	move.l	d0,-(sp)	*EXEC�̃G���[�R�[�h��ޔ�

	move.w	#STDERR,-(sp)	*�W���G���[�o�͂��N���[�Y
	DOS	_CLOSE		*�i���蓖�Ă�con�ɖ߂�j
	addq.l	#2,sp		*

	move.l	(sp)+,d0	*d0.l=EXEC�̏I���R�[�h
	bmi	error2		*���Ȃ�G���[

	rts

*
*	�W���G���[�o�͂�filnam�Ƀ��_�C���N�g����
*
err_redirect:
wopen:
	move.w	#ARCHIVE,-(sp)	*�w�肳�ꂽ�t�@�C����
	pea.l	filnam		*�@�V�K�쐬����
	DOS	_CREATE		*
	addq.l	#6,sp		*
	tst.l	d0		*�G���[�H
	bpl	wopen0		*�@�G���[���Ȃ���΃I�[�v������

	move.w	#WOPEN,-(sp)	*create�ŃG���[�����������Ƃ���
	pea.l	filnam		*�@open���g����
	DOS	_OPEN		*�@������x���C�g�I�[�v�����Ă݂�
	addq.l	#6,sp		*
	tst.l	d0		*�G���[�H
	bmi	error1		*�@�����Ȃ獡�x�����G���[�I��

wopen0:	move.w	d0,d1		*d1.w=�o�͐�t�@�C���n���h��

	move.w	#STDERR,-(sp)	*�I�[�v�������t�@�C���n���h����
	move.w	d1,-(sp)	*�@�W���G���[�o�͂�
	DOS	_DUP2		*�@�����R�s�[
	addq.l	#4,sp		*
	tst.l	d0		*�G���[�H
	bmi	error1		*�@�����Ȃ�G���[�I��

	move.w	d1,-(sp)	*���܃I�[�v�������t�@�C���n���h����
	DOS	_CLOSE		*�@��������Ȃ�����
	addq.l	#2,sp		*�@�N���[�Y���Ă��܂�

	rts

*
*	�R�}���h���C���̉��
*
chkarg:
	addq.l	#1,a2		*a2=�R�}���h���C��������擪

	bsr	nextarg		*�X�y�[�X���X�L�b�v����
	tst.b	(a2)		*�R�}���h���C�����������邩�H
	beq	usage		*�@�Ȃ��Ȃ����������Ȃ�
	lea.l	filnam,a0	*a0=�t�@�C�����؂�o���̈�
	bsr	getarg		*�����P��a0�ȍ~�Ɏ��o��

	lea.l	-100(sp),sp	*100�o�C�g�̃��[�J���G���A��
	move.l	sp,-(sp)	*�@DOS�R�[�����g����
	move.l	a0,-(sp)	*�@�t�@�C������
	DOS	_NAMECK		*�@�W�J���Ă݂�
	lea.l	100+8(sp),sp	*
	tst.l	d0		*d0���O�łȂ����
	bne	usage		*�@�t�@�C�����̎w��Ɍ�肪����

	bsr	nextarg		*����ɃX�y�[�X���΂�
	tst.b	(a2)		*�܂����邩�H
	beq	usage		*�@���s���ׂ��R�}���h���Ȃ�

	rts

*
*	�X�y�[�X���΂����̈����擪�܂Ń|�C���^��i�߂�
*
nextarg:
	bsr	skipsp		*�X�y�[�X���X�L�b�v

	cmpi.b	#'/',(a2)	*�����̐擪��
	beq	usage		*�@/,-�ł����
	cmpi.b	#'-',(a2)	*�@�g�p�@��\��
	beq	usage		*

	rts

*
*	a2�̎w���ʒu��������P����
*	a0�̎w���̈�փR�s�[����
*
getarg:
	move.l	a0,-(sp)	*�o���W�X�^�Ҕ�
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
	movea.l	(sp)+,a0	*�p���W�X�^���A
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

	DOS	_EXIT

*
*	�g�p�@�̕\�����I���E�G���[�I��
*
usage:
	lea	usgmes,a0
	bra	err0
*
error1:
	lea	errms1,a0	*�t�@�C���I�[�v�����G���[
	bra	err0

error2:
	lea	errms2,a0	*�`���C���h�v���Z�X�������G���[
*	bra	err0
	*
err0:	move.w	#STDERR,-(sp)	*�W���G���[�o�͂�
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
usgmes:	.dc.b	'�@�@�\�F�W���G���[�o�͂��t�@�C���ɐ؂�ւ��Ă���',CR,LF
	.dc.b	TAB,'�w��̃R�}���h�����s���܂�',CR,LF
	.dc.b	'�g�p�@�FRDERR�@�؂�ւ���t�@�C���@���s�R�}���h'
crlfms:	.dc.b	CR,LF,0
errms1:	.dc.b	'RDERR: �t�@�C�����쐬�ł��܂���ł���',CR,LF,0
errms2:	.dc.b	'RDERR: �R�}���h���N���ł��܂���ł���',CR,LF,0

*
*	���[�N�G���A
*
	.bss
	.even
*
wfno:	.ds.w	1		*���_�C���N�g��t�@�C���n���h��
filnam:	.ds.b	256		*�t�@�C�����؂�o���p�o�b�t�@
*
	.stack
	.even
*
mystack:			*�X�^�b�N�̈�
	.ds.l	1024		*
mysp:

	.end	ent		*���s�J�n�A�h���X��ent
