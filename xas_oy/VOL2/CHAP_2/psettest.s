*	�_��łe�X�g�v���O����

	.include	doscall.mac
	.include	iocscall.mac
*
	.xref	gramadr
*
CSCREEN		equ	16
DOS_GL3		equ	5
*
	.text
	.even
*
ent:
	lea.l	inisp(pc),sp	*sp������������

	move.w	#DOS_GL3,-(sp)	*��ʂ�512x512,65536�F��
	move.w	#CSCREEN,-(sp)	*�@������
	DOS	_CONCTRL	*
	addq.l	#4,sp		*

	clr.l	-(sp)		*�X�[�p�[�o�C�U���[�h��
	DOS	_SUPER		*�@�ڍs
	move.l	d0,(sp)		*���݂�ssp��Ҕ�

	move.w	#256,d0		*x = 256
	move.w	#256,d1		*y = 256
	jsr	gramadr		*G-RAM��̃A�h���X�𓾂�
	move.w	#65535,(a0)	*�_��ł�

	DOS	_SUPER		*
	addq.l	#4,sp		*���[�U�[���[�h�֕��A

	DOS	_EXIT		*�I��
*
	.stack
	.even
*
	.ds.l	4096
inisp:
	.end	ent
