	.include	doscall.mac
*
	.xdef	allmem		*�O����`
*
	.text
	.even
*
*allmem()
*�@�\�F	�m�ۂł���ő�̃������u���b�N���m�ۂ���
*	d0.l�Ɋm�ۂ����擪�A�h���X�������Ė߂�
*	d0.l�����̏ꍇ�̓G���[
*���W�X�^�j��Fd0.l,ccr
*
*	ex)
*		bsr	allmem
*		tst.l	d0
*		bmi	error
*
allmem:
	move.l	#$ffffff,-(sp)
	DOS	_MALLOC
	andi.l	#$ffffff,d0
	move.l	d0,(sp)
	DOS	_MALLOC
	addq.l	#4,sp
	rts

	.end
