*	�p���������p�啶���ϊ��t�B���^�@��P��

	.include	doscall.mac
*
	.text
	.even
*
ent:
	lea.l	mysp,sp		*sp�̏�����

loop:	DOS	_GETC		*�P��������
	bsr	toupper		*���������啶���ϊ�
	move.w	d0,-(sp)	*�P�����o��
	DOS	_PUTCHAR	*
	addq.l	#2,sp		*
	bra	loop		*���񂦂�ƌJ��Ԃ�
*
*�p���������p�啶���ϊ��T�u���[�`��
toupper:
	cmpi.b	#'a',d0		*�p���������H
	bcs	toupr0		*
	cmpi.b	#'z'+1,d0	*
	bcc	toupr0		*
	subi.b	#$20,d0		*�������Ȃ�啶���ɕϊ�
toupr0:	rts			*�T�u���[�`�����烊�^�[��
*
	.stack
	.even
*
mystack:
	.ds.l	256		*�X�^�b�N�̈�
mysp:
	.end
