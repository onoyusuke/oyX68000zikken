*	�`���C���h�v���Z�X��P�ɋN�����Ă݂�
*
*	�쐬�@�Fas chldtest
*		lk chldtest child memoff
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

	pea.l	cmd		*�`���C���h�v���Z�X�N��
	bsr	child		*
	addq.l	#4,sp		*
	tst.l	d0		*�G���[�H
	bmi	error		*�@�����Ȃ�G���[�I��

	DOS	_EXIT		*�I��
*
error:				*�G���[�I��
	pea	errmes
	DOS	_PRINT
	addq.l	#4,sp

	move.w	#1,-(sp)
	DOS	_EXIT2
*
	.data
	.even
*
cmd:	.dc.b	'attrib *.*',0		*�N���R�}���h
errmes:	.dc.b	'�R�}���h���N���ł��܂���',0
*
	.stack
	.even
*
mystack:			*�X�^�b�N�̈�
	.ds.l	1024
mysp:

	.end	ent		*���s�J�n�A�h���X��ent
