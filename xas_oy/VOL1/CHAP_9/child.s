	.include	doscall.mac
*
	.xdef	child		*�O����`
*
*	EXEC���[�h
*
LOADEXEC	equ	0
PATHCHK		equ	2
*
	.text
	.even
*
*child(cmd)
*�@�\�F	�^����ꂽ�R�}���h���C���ɏ]����
*	�v���O�������`���C���h�v���Z�X�Ƃ��ċN������
*	d0.l��EXEC�̏I���R�[�h�������Ė߂�
*	d0.l�����̏ꍇ�̓G���[
*���W�X�^�j��Fd0.l,ccr
*
*	ex)
*		pea.l	cmd
*		bsr	child
*		addq.l	#4,sp
*		tst.l	d0
*		bmi	error
*		     �F
*	cmd:	.dc.b	'command /cdir',0
*
nambuf	=	-512
cmdlin	=	-256
str	=	8
*
child:
	link	a6,#-512	*512�o�C�g�̃��[�J���G���A
	movem.l	d1-d7/a0-a6,-(sp)

	movea.l	str(a6),a1	*�^����ꂽ�������
	lea.l	nambuf(a6),a0	*�@���[�J���G���A��
	move.w	#255-1,d0	*�@�ő�255�o�C�g
chld0:	move.b	(a1)+,(a0)+	*�@�R�s�[���Ă���
	dbeq	d0,chld0	*��㏑������邩��
	clr.b	(a0)		*�O�̂��߂̏I�[�R�[�h

	clr.l	-(sp)		*�����̊�
	pea.l	cmdlin(a6)	*�p�����[�^���i�[�̈�
	pea.l	nambuf(a6)	*�R�}���h���C����
				*�@�t���p�X���i�[�̈�
	move.w	#PATHCHK,-(sp)	*PATH����
	DOS	_EXEC		*
	tst.l	d0		*d0.l�����Ȃ�
	bmi	chld1		*�@�G���[

	move.w	#LOADEXEC,(sp)	*���[�h�����s
	DOS	_EXEC		*
chld1:	lea	14(sp),sp	*�X�^�b�N�␳ 4*3+2�o�C�g

	movem.l	(sp)+,d1-d7/a0-a6
	unlk	a6
	rts

	.end
