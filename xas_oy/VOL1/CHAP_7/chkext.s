	.text
	.even
*
*	�g���q���ȗ�����Ă�����
*	�K���Ȋg���q��₤
*
chkext:
	tst.b	nambuf+86	*�g���q�͂��邩
	bne	chkex0		*�@����Ȃ牽�����Ȃ�

	lea.l	arg,a0		*�p�ӂ��Ă���g���q��
	lea.l	dext,a1		*�@�A������
	bsr	strcat		*

chkex0:	rts

*
*	�������A������
*	a0=��A��������,a1=�A��������
*
strcat:
	tst.b	(a0)+		*(a0)��0���H
	bne	strcat		*�����łȂ���ΌJ��Ԃ�
	subq.l	#1,a0		*�s������������P�߂�
strcpy:
	move.b	(a1)+,(a0)+	*1�����]��
	bne	strcpy		*�I���R�[�h�܂ŌJ��Ԃ�
	rts
*
	.data
	.even
*
dext:	.dc.b	'.$$$',0	*�₤�g���q
