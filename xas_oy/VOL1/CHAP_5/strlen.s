*	������̒����𐔂��\������

	.include	doscall.mac
*
	.text
	.even
*
ent:
	lea.l	mysp,sp		*sp�̏�����

	lea.l	str1,a0		*������ւ̃|�C���^
	bsr	strlen		*������̒����𐔂���

	bsr	prtdec		*���ʂ�10�i�\��
				*���s�͂��Ă��Ȃ�
	DOS	_EXIT		*�I��
*
*������̒����𐔂���T�u���[�`��
strlen:
	moveq.l	#-1,d0		*�J�E���^�̏�����
strlen0:
	addq.w	#1,d0		*�J�E���g
	tst.b	(a0)+		*�I���R�[�h���H
	bne	strlen0		*�����łȂ���ΌJ��Ԃ�
	rts
*
*D0.W��10�i���l�߂ŕ\������T�u���[�`��
prtdec:
	movem.l	d0/a0,-(sp)	*d0,a0���X�^�b�N�ɑҔ�

	andi.l	#$0000ffff,d0	*��ʃ��[�h���N���A
	lea.l	bufend,a0	*�|�C���^������
prtdec0:
	divu.w	#10,d0		*d0.l��10�Ŋ���
				*	��ʃ��[�h = �]��
				*	���ʃ��[�h = ��
	swap.w	d0		*��ʃ��[�h�Ɖ��ʃ��[�h������
				*	��ʃ��[�h = ��
				*	���ʃ��[�h = �]��
	addi.w	#'0',d0		*0�`9 �� '0'�`'9'
	move.b	d0,-(a0)	*1���i�[
	clr.w	d0		*���̏��Z�ɔ�����
				*	��ʃ��[�h = �������̏�
				*	���ʃ��[�h = 0
	swap.w	d0		*��ʃ��[�h�Ɖ��ʃ��[�h������
				*	��ʃ��[�h = 0
				*	���ʃ��[�h = �������̏�
	bne	prtdec0

	move.l	a0,-(sp)
	DOS	_PRINT
	addq.l	#4,sp

	movem.l	(sp)+,d0/a0
	rts
*
str1:	.dc.b	'1234567890ABCDEFGHIJK',0	*�e�X�g������
*
buff:	.ds.b	5		*10�i������i�[�̈�
bufend:	.dc.b	0		*������̏I���R�[�h
*
	.stack
	.even
*
mystack:
	.ds.l	256		*�X�^�b�N�̈�
mysp:
	.end
