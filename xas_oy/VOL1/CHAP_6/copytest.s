*	�t�@�C���R�s�[�T���v��

	.include	doscall.mac
*
	.text
	.even
*
ent:
	lea.l	mysp,sp		*sp�̏�����

	clr.w	-(sp)		*���͐�t�@�C����
	pea.l	sour		*�@�ǂݍ��ݗp�ɃI�[�v��
	DOS	_OPEN		*
	addq.l	#6,sp		*

	tst.l	d0		*�G���[�H
	bmi	error		*�@�����Ȃ�G���[�I��

	move.w	d0,d1		*d1.w=���͐�t�@�C���n���h��

	move.w	#$0020,-(sp)	*�o�͐�t�@�C����V�K�쐬
	pea.l	dest		*
	DOS	_CREATE		*
	addq.l	#6,sp		*

	tst.l	d0		*�G���[�H
	bmi	error		*�@�����Ȃ�G���[�I��

	move.w	d0,d2		*d2.w=�o�͐�t�@�C���n���h��

loop:
	move.w	d1,-(sp)	*���͐�t�@�C���n���h������
	DOS	_FGETC		*�@�P�o�C�g�ǂݍ���
	addq.l	#2,sp		*

	tst.l	d0		*�G���[�H
	bmi	done		*�@�����Ȃ�t�@�C���G���h�ƌ��Ȃ�

	move.w	d2,-(sp)	*�o�͐�t�@�C���n���h����
	move.w	d0,-(sp)	*�@�P�o�C�g�����o��
	DOS	_FPUTC		*
	addq.l	#4,sp		*

	tst.l	d0		*�G���[�H
	bmi	error		*�@�����Ȃ�G���[�I��

	bra	loop		*�J��Ԃ�

done:	DOS	_ALLCLOSE	*�t�@�C�������
	DOS	_EXIT		*�I��

*
error:			*�G���[����
	pea.l	errmes		*�G���[���b�Z�[�W��\��
	DOS	_PRINT		*
	addq.l	#4,sp		*

	move.w	#1,-(sp)	*�I���R�[�h�P��������
	DOS	_EXIT2		*�@�I��

*
sour:	.dc.b	'FILE1',0	*�]�����t�@�C����
dest:	.dc.b	'FILE2',0	*�]����t�@�C����
errmes:	.dc.b	'�G���[�ł�'	*�G���[���b�Z�[�W
	.dc.b	$0d,$0a,0	*
*
	.stack
	.even
*
mystack:
	.ds.l	256		*�X�^�b�N�̈�
mysp:
	.end
