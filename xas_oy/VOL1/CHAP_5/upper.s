*	�p���������p�啶���ϊ��t�B���^�̏o�������Ȃ�

	.include	doscall.mac
*
	.text
	.even
*
ent:
	lea.l	mysp,sp		*sp�̏�����

loop:	pea	buff		*1�s����
	DOS	_GETS		*
	addq.l	#4,sp		*

	lea.l	str,a0		*a0=���͕�����擪
	cmpi.b	#$1a,(a0)	*�擪��^Z���H
	beq	skip		*�����ł���ΏI��

	bsr	strupr		*���������啶���ϊ�

	pea.l	str		*�ϊ����ʂ�\��
	DOS	_PRINT		*
	addq.l	#4,sp		*

	pea.l	crlf		*���s
	DOS	_PRINT		*
	addq.l	#4,sp		*

	bra	loop		*���񂦂�ƌJ��Ԃ�
skip:
	DOS	_EXIT		*�I��
*
*�p���������p�啶���ϊ��T�u���[�`��
strupr:
	tst.b	(a0)		*������̏I��肩�H
	beq	strup1		*�����ł���Εϊ��I��

	cmpi.b	#'a',(a0)	*�p���������H
	bcs	strup0		*
	cmpi.b	#'z'+1,(a0)	*
	bcc	strup0		*

	subi.b	#$20,(a0)	*�������Ȃ�啶���ɕϊ�

strup0:	addq.l	#1,a0		*�|�C���^��i�߂�
	bra	strupr		*�J��Ԃ�
strup1:	rts			*�T�u���[�`�����烊�^�[��
*
buff:	.dc.b	255		*���͉\�ő啶����
cnt:	.dc.b	0		*���͂��ꂽ������
str:	.ds.b	256		*��������̓o�b�t�@
*
crlf:	.dc.b	$0d,$0a,0	*���s�R�[�h�����̕�����
*
	.stack
	.even
*
mystack:
	.ds.l	256		*�X�^�b�N�̈�
mysp:
	.end
