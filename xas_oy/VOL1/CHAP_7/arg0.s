*	�R�}���h���C���������
*	������K�v�Ƃ��Ȃ��ꍇ

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
*	���C�������i���͉������Ȃ��j
*
do:
	rts

*
*	�R�}���h���C���̉��
*
chkarg:
	addq.l	#1,a2		*a2=�R�}���h���C��������擪
	bsr	skipsp		*�X�y�[�X���X�L�b�v����
	tst.b	(a2)		*�]�v�Ȉ��������邩�H
	bne	usage		*�@�����Ȃ�g�p�@��\��
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
usgmes:	.dc.b	'�@�@�\�F�������~�~���܂�',CR,LF
	.dc.b	'�g�p�@�FARG0',CR,LF
	.dc.b	0
*
	.stack
	.even
*
mystack:
	.ds.l	256		*�X�^�b�N�̈�
mysp:
	.end
