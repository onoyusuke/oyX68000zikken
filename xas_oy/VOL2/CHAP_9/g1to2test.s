*	g1to2, gshrink�̓��쎎���p�v���O����

	.include	doscall.mac
*
	.xref	g1to2
	.xref	gshrink
*
	.text
	.even
*
ent:
	lea.l	inisp,sp

	clr.l	-(sp)		*�X�[�p�[�o�C�U���[�h��
	DOS	_SUPER		*

	pea.l	arg		*gshrink��3/4�ɏk��
	jsr	gshrink		*
	addq.l	#4,sp		*

	pea.l	arg1		*g1to2�ł����1/2�ɏk��
	jsr	g1to2		*
	addq.l	#4,sp		*

	DOS	_EXIT
*
	.data
	.even
*
arg:				*gshrink�̈���
	.dc.w	0,0,511,511	*3/4
	.dc.w	383,383		*
	.dc.l	temp
*
arg1:				*g1to2�̈���
	.dc.w	0,0,511,511
*
	.bss
	.even
*
temp:	.ds.w	1024*3		*gshrink�̃��[�N
*
	.stack
	.even
*
	.ds.l	4096
inisp:
	.end	ent
