*	������̕���

	.include	doscall.mac
*
	.text
	.even
*
ent:
	lea.l	mysp,sp		*sp�̏�����

	lea.l	str1,a0		*���ʐ�ւ̃|�C���^
	lea.l	str2,a1		*���ʌ��ւ̃|�C���^
	bsr	strcpy		*�����񕡎�

	pea.l	str1		*�R�s�[�����������
	DOS	_PRINT		*�\�����Ă݂�
	addq.l	#4,sp		*

	DOS	_EXIT		*�I��
*
*�����񕡎ʃT�u���[�`��
strcpy:
	move.b	(a1)+,d0	*1�������o��
	move.b	d0,(a0)+	*�]��
	bne	strcpy		*�I���R�[�h�܂ŌJ��Ԃ�
	rts
*
str2:	.dc.b	'1234ABCD',0	*���ʌ�
str1:	.ds.b	256		*���ʐ�
*
	.stack
	.even
*
mystack:
	.ds.l	256		*�X�^�b�N�̈�
mysp:
	.end
