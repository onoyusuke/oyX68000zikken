*	D0.W��10�i���l�߂ŕ\������T�u���[�`��

	.include	doscall.mac
*
	.text
	.even
*
prtdec:
	movem.l	d0/a0,-(sp)	*�od0,a0���X�^�b�N�ɑҔ�

	andi.l	#$0000ffff,d0	*��ʃ��[�h���N���A
	lea.l	bufend,a0	*�|�C���^������
prtdec0:
	divu.w	#10,d0		*d0.l��10�Ŋ���
	swap.w	d0		*��ʃ��[�h�Ɖ��ʃ��[�h������
	addi.w	#'0',d0		*0�`9 �� '0'�`'9'
	move.b	d0,-(a0)	*1���i�[
	clr.w	d0		*���̏��Z�ɔ�����
	swap.w	d0		*��ʃ��[�h�Ɖ��ʃ��[�h������
	bne	prtdec0

	move.l	a0,-(sp)	*�ϊ������������\������
	DOS	_PRINT		*
	addq.l	#4,sp		*

	movem.l	(sp)+,d0/a0	*�pd0,a0�𕜋A
	rts
*
	.data
	.even
*
buff:	.ds.b	5		*10�i������i�[�̈�
bufend:	.dc.b	0		*������̏I���R�[�h

	.end
