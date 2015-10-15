*	�R�}���h���C���������
*	�����Ƃ��ăt�@�C�������P�K�v�Ƃ���ꍇ

	.include	doscall.mac
	.include	const.h
*
	.text
	.even
*
ent:
	lea.l	mysp,sp		*sp�̏�����

	bsr	chkarg		*�R�}���h���C���̉��

	bsr	do		*���C������

	DOS	_EXIT		*����I��

*
*	���C�������i���͗^����ꂽ������\�����邾���j
*
do:
	pea.l	arg		*������\������
	DOS	_PRINT		*
	addq.l	#4,sp		*
	bsr	crlf		*���s����
	rts

*
*	���s����
*
crlf:
	pea.l	crlfms
	DOS	_PRINT
	addq.l	#4,sp
	rts

*
*	�R�}���h���C���̉��
*
chkarg:
	addq.l	#1,a2		*a2=�R�}���h���C��������擪
	bsr	skipsp		*�X�y�[�X���X�L�b�v����
	tst.b	(a2)		*���������邩�H
	beq	usage		*�@�Ȃ��Ȃ����������Ȃ�

	cmpi.b	#'/',(a2)	*�����̐擪��
	beq	usage		*�@'/'��
	cmpi.b	#'-',(a2)	*�@'-'�ł����
	beq	usage		*�@�����ƃw���v���������̂��낤

	lea.l	arg,a0		*a0=�����؂�o���̈�
	bsr	getarg		*�����P��a0�ȍ~�Ɏ��o��

	bsr	skipsp		*����ɃX�y�[�X���X�L�b�v
	tst.b	(a2)		*���������邩�H
	bne	usage		*�@����Ȃ����������

	pea.l	nambuf		*DOS�R�[�����g����
	move.l	a0,-(sp)	*�@�t�@�C������
	DOS	_NAMECK		*�@�W�J���Ă݂�
	addq.l	#8,sp		*
	tst.l	d0		*d0���O�łȂ����
	bne	usage		*�@�t�@�C�����̎w��Ɍ�肪����

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

*
*	�g�p�@�̕\�����I��
*
usage:
	move.w	#STDERR,-(sp)	*�W���G���[�o�͂�
	pea.l	usgmes		*�@�w���v���b�Z�[�W��
	DOS	_FPUTS		*�@�o�͂���
	addq.l	#6,sp		*�X�^�b�N�␳

	move.w	#1,-(sp)	*�I���R�[�h�P��������
	DOS	_EXIT2		*�@�G���[�I��

*
*	���b�Z�[�W�f�[�^
*
	.data
	.even
*
usgmes:	.dc.b	'�@�@�\�F�w��t�@�C�����~�~���܂�',CR,LF
	.dc.b	'�g�p�@�FARG1 �t�@�C����'
crlfms:	.dc.b	CR,LF,0

*
*	���[�N�G���A
*
	.bss
	.even
*
arg:	.ds.b	256		*�����؂�o���p�o�b�t�@
nambuf:	.ds.b	91		*�t�@�C�����W�J�p�o�b�t�@
*
	.stack
	.even
*
mystack:
	.ds.l	256		*�X�^�b�N�̈�
mysp:
	.end
