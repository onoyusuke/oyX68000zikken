*	grput�̓��쎎���p�v���O����

	.include	doscall.mac
	.include	iocscall.mac
*
	.xref	grput
*	.xref	setcliprect
*
	.text
	.even
*
ent:
	lea.l	inisp,sp

	clr.l	-(sp)		*�X�[�p�[�o�C�U���[�h��
	DOS	_SUPER		*

	lea.l	arg0,a1		*��ʂ���p�^�[������荞��
	IOCS	_GETGRM		*

*	pea	window		*�N���b�s���O�E�B���h�E�̐ݒ�
*	jsr	setcliprect	*
*	addq.l	#4,sp		*

	moveq.l	#14,d1		*256x256,65536
	IOCS	_CRTMOD		*��ʏ�����
	IOCS	_G_CLR_ON	*

	moveq.l	#1,d1		*d1 = �p�x����

	lea.l	arg,a1		*a1 = �����󂯓n���̈�
loop:	pea.l	(a1)		*�`��
	jsr	grput		*
	addq.l	#4,sp		*

	add.w	d1,8(a1)	*�p�x�𑝌�����

	DOS	_KEYSNS		*�L�[���������܂�
	tst.l	d0		*�@�J��Ԃ�
	beq	loop		*

	neg.w	d1		*��]�������]

	DOS	_INKEY		*�X�y�[�X�������ꂽ��
	cmpi.b	#$20,d0		*�@�ꎞ��~����
	bne	done		*
pause:	DOS	_INKEY		*
	cmpi.b	#$20,d0		*
	beq	loop		*

done:	move.w	#-1,-(sp)	*�L�[��ǂݎ̂Ă�
	DOS	_KFLUSH		*

	move.l	#$0010_0000,-(sp)	*width 96
	DOS	_CONCTRL	*��ʍď�����
	DOS	_EXIT
*
	.data
	.even
*
HSIZE	equ	128
VSIZE	equ	128
*
arg:				*grput�̈���
*	.dc.w	96,96,159,159	*�k��
	.dc.w	64,64,191,191	*���{
*	.dc.w	32,32,223,223	*�g��
	.dc.w	0
	.dc.l	pat+(HSIZE*4)*(VSIZE/2)+(HSIZE/2)*2
	.dc.w	HSIZE-1,VSIZE-1
	.dc.l	temp
*
arg0:				*IOCS GETGRM�̈���
	.dc.w	256-HSIZE,256-VSIZE
	.dc.w	255+HSIZE,255+VSIZE
	.dc.l	pat
	.dc.l	pate
*
window:	.dc.w	80,80,175,175
*
	.bss
	.even
*
pat:	.ds.w	HSIZE*VSIZE*4	*�`��p�^�[��
pate:
temp:	.ds.w	512*4		*grput�̃��[�N
*
	.stack
	.even
*
	.ds.l	4096
inisp:
	.end	ent
