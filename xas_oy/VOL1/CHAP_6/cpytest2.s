*	�t�@�C���R�s�[�T���v���@���̂Q

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
	move.l	#1024,-(sp)	*1024�o�C�g�ǂݍ���
	pea.l	buffer		*
	move.w	d1,-(sp)	*�@
	DOS	_READ		*
	lea.l	10(sp),sp	*

	tst.l	d0		*d0.l��
	bmi	error		*�@���Ȃ�G���[
	beq	done		*�@�O�Ȃ�t�@�C���̏I���
				*�@����ȊO�Ȃ�ǂݍ��񂾃o�C�g��
	move.l	d0,d3		*d3.l = �ǂݍ��񂾃o�C�g��


	move.l	d3,-(sp)	*�ǂݍ��񂾕����������o��
	pea.l	buffer		*
	move.w	d2,-(sp)	*
	DOS	_WRITE		*
	lea.l	10(sp),sp	*

	tst.l	d0		*�G���[�H
	bmi	error		*�@�����Ȃ�G���[�I��
				*d0.l = ���ۂɏ����o�����o�C�g��
	cmp.l	d3,d0		*���ۂɎw�肵�����������o�������H
	bcs	error		*�@����Ȃ���΃G���[

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
buffer:	.ds.b	1024		*�ǂݍ��ݗp�o�b�t�@1024�o�C�g��
*
	.stack
	.even
*
mystack:
	.ds.l	256		*�X�^�b�N�̈�
mysp:
	.end
