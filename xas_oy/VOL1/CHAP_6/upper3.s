*	�p���������p�啶���ϊ��t�B���^�@��R��

	.include	doscall.mac
*
CR	equ	$0d
LF	equ	$0a
EOF	equ	$1a
*
	.text
	.even
*
ent:
	lea.l	mysp,sp		*sp�̏�����

loop:	clr.w	-(sp)		*�P��������
	DOS	_FGETC		*
	addq.l	#2,sp		*

	tst.l	d0		*�G���[���H
	bmi	done		*�����Ȃ�I��

	cmpi.b	#EOF,d0		*�t�@�C���G���h�R�[�h���H
	beq	done		*�����Ȃ�I��

	cmpi.b	#LF,d0		*LF�R�[�h���H
	beq	loop		*�����Ȃ疳��

	cmpi.b	#CR,d0		*CR�R�[�h���H
	beq	cr_lf		*�����Ȃ�LF,CR�ɂ��ďo��

	cmpi.b	#$80,d0		*80H��菬�������
	bcs	hankaku		*	ASCII�R�[�h
	cmpi.b	#$a0,d0		*80H�ȏ�A0H�����Ȃ�
	bcs	zenkaku		*	�V�t�gJIS�̂P�o�C�g��
	cmpi.b	#$e0,d0		*A0H�ȏ�E0H�����Ȃ�
	bcs	hankaku		*	ASCII�J�^�J�i
				*E0H�ȏ�Ȃ�
				*	�V�t�gJIS�̂P�o�C�g��
*
zenkaku:
	move.w	d0,-(sp)	*�V�t�gJIS�̂P�o�C�g�ڂ�
	DOS	_PUTCHAR	*	���̂܂܏o��
	addq.l	#2,sp		*

	DOS	_GETC		*�����P�o�C�g�����Ă���
	move.w	d0,-(sp)	*�V�t�gJIS�̂Q�o�C�g�ڂ�
	DOS	_PUTCHAR	*	���̂܂܏o��
	addq.l	#2,sp		*

	bra	loop		*�J��Ԃ�
*
hankaku:
	bsr	toupper		*���������啶���ϊ�

	move.w	d0,-(sp)	*�P�����o��
	DOS	_PUTCHAR	*
	addq.l	#2,sp		*

	bra	loop		*�J��Ԃ�
*
cr_lf:
	move.w	d0,-(sp)	*d0�ɂ�CR�R�[�h�������Ă���
	DOS	_PUTCHAR	*CR�R�[�h���o��
	move.w	#LF,(sp)	*LF�R�[�h���o��
	DOS	_PUTCHAR	*
	addq.l	#2,sp		*

	bra	loop		*�J��Ԃ�
*
done:
	DOS	_EXIT		*�I��
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
