*	������̔�r

	.include	doscall.mac
*
	.text
	.even
*
ent:
	lea.l	mysp,sp		*sp�̏�����

	lea.l	str1,a0		*���r������ւ̃|�C���^
	lea.l	str2,a1		*��r������ւ̃|�C���^
	bsr	strcmp		*�������r

	beq	match		*��v�������H

not:	pea.l	notmes		*��v���Ȃ�����
	bra	match0

match:	pea.l	matmes		*��v����
match0:	DOS	_PRINT		*����Ȃ�̃��b�Z�[�W��
	addq.l	#4,sp		*	�\��

	DOS	_EXIT		*�I��
*
*�������r�T�u���[�`��
strcmp:
	tst.b	(a1)		*��r������͏I��肩�H
	beq	strcmp0		*�����ł���΃��[�v�𔲂���
	cmpm.b	(a1)+,(a0)+	*1������r
	beq	strcmp		*��v���Ă���ԌJ��Ԃ�
	rts			*��v���Ȃ�����
strcmp0:
	cmpm.b	(a1)+,(a0)+	*���X�g�`�����X
	rts
*
str1:	.dc.b	'1234ABCD',0	*���r������
str2:	.dc.b	'1234ABCD',0	*��r������
*
matmes:	.dc.b	'��v���܂���',$0d,$0a,0
notmes:	.dc.b	'��v���܂���',$0d,$0a,0
*
	.stack
	.even
*
mystack:
	.ds.l	256		*�X�^�b�N�̈�
mysp:
	.end
