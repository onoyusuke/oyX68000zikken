*	RAW���[�h��COOKED���[�h�̈Ⴂ������
*
	.include	doscall.mac
	.include	const.h
	.include	driver.h
*
	.text
	.even
*
ent:
	lea.l	mysp,sp		*sp�̏�����

	move.w	#WOPEN,-(sp)	*CON���������݃��[�h��
	pea.l	connam		*�@�I�[�v������
	DOS	_OPEN		*
	addq.l	#6,sp		*

	move.w	d0,d1		*d1=�o�͐�

	move.w	#COOKED_MODE,d0	*COOKED���[�h�ɂ���
	bsr	setmode		*
	bsr	out		*�e�X�g�f�[�^���o��

	move.w	#RAW_MODE,d0	*RAW���[�h�ɂ���
	bsr	setmode		*
	bsr	out		*�e�X�g�f�[�^���o��

	move.w	d1,-(sp)	*�N���[�Y
	DOS	_CLOSE		*
	addq.l	#2,sp		*

	DOS	_EXIT

*
*	�t�@�C���n���h��d1.w��
*	���u���d0.w���Z�b�g����
*
setmode:
	move.w	d0,-(sp)	*���u���
	move.w	d1,-(sp)	*�t�@�C���n���h��
	move.w	#1,-(sp)
	DOS	_IOCTRL
	addq.l	#6,sp
	rts

*
*	�t�@�C���n���h��d1.w��
*	mes�ȉ��̃f�[�^���o�͂���
*

meslen	=	mesend-mes

out:
	move.l	#meslen,-(sp)
	pea.l	mes
	move.w	d1,-(sp)
	DOS	_WRITE
	lea.l	10(sp),sp
	rts

*
*	�f�[�^
*
	.data
	.even
*
connam:	.dc.b	'CON',0
*
mes:	.dc.b	'12345678901234567890'
	.dc.b	'12345678901234567890'
*			�F
	.dc.b	'12345678901234567890'
	.dc.b	'12345678901234567890'
	.dc.b	CR,LF
mesend:
*
	.stack
	.even
*
mystack:
	.ds.l	256		*�X�^�b�N�̈�
mysp:
	.end
