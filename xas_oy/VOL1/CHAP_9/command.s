	.include	doscall.mac
*
	.xdef	command		*�O����`
	.xref	child		*�O���Q��
*
	.text
	.even
*
*command(cmd)
*�@�\�F	command.x���`���C���h�v���Z�X�Ƃ��ċN������
*	d0.l��EXEC�̏I���R�[�h�������Ė߂�
*	d0.l�����̏ꍇ�̓G���[
*���W�X�^�j��Fd0.l,ccr
*
*	ex)
*		pea.l	cmd
*		bsr	command
*		addq.l	#4,sp
*		tst.l	d0
*		bmi	error
*		     �F
*	cmd:	.dc.b	'dir | more',0
*
temp	=	-256
str	=	8
*
command:
	link	a6,#-256
	movem.l	a0-a1,-(sp)

	lea.l	temp(a6),a0	*�ꎞ�̈��
	lea.l	comstr,a1	*  'command '�̕������
	move.w	#255-1,d0	*�@�R�s�[����
com0:	move.b	(a1)+,(a0)+	*
	dbeq	d0,com0		*

	subq.l	#1,a0		*a0�͍s���߂��Ă���

	movea.l	str(a6),a1	*�^����ꂽ�������
com1:	move.b	(a1)+,(a0)+	*�@����ɘA������
	dbeq	d0,com1		*�i���v��255�o�C�g�܂Łj

	clr.b	(a0)		*�O�̂��߂̏I�[�R�[�h

	pea.l	temp(a6)	*"command "+str��
	bsr	child		*�@���s����
	addq.l	#4,sp		*

	movem.l	(sp)+,a0-a1
	unlk	a6
	rts
*
	.data
	.even
*
comstr:	.dc.b	'command ',0

	.end
