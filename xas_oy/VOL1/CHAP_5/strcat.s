*	������̘A��

	.include	doscall.mac
*
	.text
	.even
*
ent:
	lea.l	mysp,sp		*sp�̏�����

	lea.l	str1,a0		*�A����ւ̃|�C���^
	lea.l	str2,a1		*�A�����ւ̃|�C���^
	bsr	strcat		*������A��

	pea.l	str1		*�A�������������
	DOS	_PRINT		*�\�����Ă݂�
	addq.l	#4,sp		*

	DOS	_EXIT		*�I��
*
*������A���T�u���[�`��
strcat:
	tst.b	(a0)+		*(a0)��0���H
	bne	strcat		*�����łȂ���ΌJ��Ԃ�
	subq.l	#1,a0		*�s������������P�߂�
strcpy:
	move.b	(a1)+,(a0)+	*1�����]��
	bne	strcpy		*�I���R�[�h�܂ŌJ��Ԃ�
	rts
*
str2:	.dc.b	'1234ABCD',0	*�A����
str1:	.dc.b	'5678EFGH',0	*�A����
	.ds.b	256		*��Ƃ�
*
	.stack
	.even
*
mystack:
	.ds.l	256		*�X�^�b�N�̈�
mysp:
	.end
