*	gfill�̓��쎎���p�v���O����

	.include	doscall.mac
*
	.xref	gfill
*
CSCREEN		equ	16
DOS_GL3		equ	5
*
	.text
	.even
*
ent:
	lea.l	inisp,sp	*sp������������

	move.w	#DOS_GL3,-(sp)	*��ʂ�512x512,65536�F��
	move.w	#CSCREEN,-(sp)	*�@������
	DOS	_CONCTRL	*
	addq.l	#4,sp		*

	clr.l	-(sp)		*�X�[�p�[�o�C�U���[�h��
	DOS	_SUPER		*�@�ڍs
	move.l	d0,(sp)		*���݂�ssp��Ҕ�

	pea.l	arg		*������
	bsr	gfill		*�`��
	addq.l	#4,sp		*

	DOS	_SUPER		*
	addq.l	#4,sp		*���[�U�[���[�h�֕��A

	DOS	_EXIT		*�I��
*
	.data
	.even
*
arg:	.dc.w	100,100,200,200,12345
*
	.stack
	.even
*
	.ds.l	4096
inisp:
	.end	ent
