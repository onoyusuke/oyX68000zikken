*	DOS�R�[���ɂ�镶����\��

	.include	doscall.mac
*
	.text
	.even
*
ent:
	lea.l	mysp,sp		*sp�̏�����

	pea.l	str		*������擪�A�h���X���v�b�V��
	DOS	_PRINT		*������\��
	addq.l	#4,sp		*�X�^�b�N�␳

	DOS	_EXIT		*�I��
*
str:	.dc.b	'1234ABCD'	*�\�����镶����
	.dc.b	$0d,$0a,0	*
*
	.stack
	.even
*
mystack:
	.ds.l	256		*�X�^�b�N�̈�
mysp:
	.end
