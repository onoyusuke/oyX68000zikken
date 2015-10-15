*	IOCTRL�ɂ��o�͂𗘗p����
*	ADPCM�h���C�o�̃T���v�����O���g����ݒ肷��
*
	.include	doscall.mac
	.include	const.h
*
	.text
	.even
*
ent:
	lea.l	mysp,sp		*sp�̏�����

	bsr	chksw		*�R�}���h���C���̉��

	bsr	do		*���C������

	DOS	_EXIT		*����I��

*
*	���C������
*
do:
	move.w	#RWOPEN,-(sp)	*'PCM'��ǂݏ������p���[�h��
	pea.l	pcmnam		*�I�[�v�����Ă݂�
	DOS	_OPEN		*
	addq.l	#6,sp		*

	move.w	d0,d1		*d1=�t�@�C���n���h��
	bmi	error1		*���ł���΃I�[�v���ł��Ȃ�����
				*�iPCM�h���C�o���g�ݍ��܂�Ă��Ȃ��j

	move.w	d1,-(sp)	*�I�[�v�������t�@�C���n���h����
	clr.w	-(sp)		*�@���u�����擾����
	DOS	_IOCTRL		*
	addq.l	#4,sp		*

	tst.b	d0		*���u���̑�V�r�b�g���O�Ȃ��
	bpl	error1		*�@�f�o�C�X�ł͂Ȃ�
				*�@�iPCM�h���C�o�����݂����A
				*�@�@���R�����̃t�@�C�����������j

	add.w	d0,d0		*���u���̑�14�r�b�g���O�Ȃ��
	bpl	error2		*�@IOCTRL��������Ă��Ȃ�

	move.l	#2,-(sp)	*�o�̓f�[�^�͂Q�o�C�g
	pea.l	mode		*�o�̓f�[�^�A�h���X
	move.w	d1,-(sp)	*�t�@�C���n���h��
	move.w	#3,-(sp)	*�o�̓��[�h
	DOS	_IOCTRL		*
	lea.l	12(sp),sp	*

	tst.l	d0		*�߂�l�����Ȃ�G���[
	bmi	error2		*

	move.w	d1,-(sp)	*�t�@�C���n���h�����N���[�Y
	DOS	_CLOSE		*
	addq.l	#2,sp		*

	rts			*��������

*
*	�I�v�V�����X�C�b�`�̉��
*
chksw:
	tst.b	(a2)+		*�R�}���h���C�������͂��邩�H
	beq	usage		*�@�Ȃ���΃G���[
				*a2=�R�}���h���C��������擪
chksw0:	bsr	skipsp		*�擪�̃X�y�[�X���΂�
	cmpi.b	#'/',(a2)	*�擪��'/'��'-'�łȂ���΃G���[
	beq	chksw1		*
	cmpi.b	#'-',(a2)	*
	bne	usage		*
chksw1:	addq.l	#1,a2		*
	move.b	(a2)+,d0	*�X�C�b�`�����o��

	subi.b	#'0',d0		*���������l�ϊ�
	bcs	usage		*
	cmpi.b	#4+1,d0		*����̃`�F�b�N
	bcc	usage		*

	move.b	d0,mode		*���[�N�Ɋi�[����

	bsr	skipsp		*�X�y�[�X���΂�
	tst.b	(a2)		*�܂������񂪂����
	bne	usage		*�@���������߂���

	rts

*
*	�R�}���h���C���擪�̃X�y�[�X���X�L�b�v����
*
skpsp0:	addq.l	#1,a2		*�|�C���^��i��
				*�J��Ԃ�
skipsp:				*�T�u���[�`���͂�������n�܂�
	cmpi.b	#SPACE,(a2)	*�X�y�[�X���H
	beq	skpsp0		*�@�����Ȃ��΂�
	cmpi.b	#TAB,(a2)	*TAB���H
	beq	skpsp0		*�@�����Ȃ��΂�
	rts

*
*	�G���[�I��/�g�p�@�̕\��
*
usage:
	lea.l	usgmes,a0	*�g�p�@���b�Z�[�W
	bra	errout
*
error1:	lea.l	errms1,a0	*PCM�h���C�o���Ȃ�
	bra	errout
error2:	lea.l	errms2,a0	*IOCTRL���󂯕t���Ȃ�
	*
errout:	move.w	#STDERR,-(sp)	*�W���G���[�o�͂�
	move.l	a0,-(sp)	*�@���b�Z�[�W��
	DOS	_FPUTS		*�@�o�͂���
	addq.l	#6,sp		*

	move.w	#1,-(sp)	*�I���R�[�h�P��������
	DOS	_EXIT2		*�@�G���[�I��

*
*	�f�[�^
*
	.data
	.even
*
pcmnam:	.dc.b	'PCM',0		*�o�͐�f�o�C�X��
mode:	.dc.b	$00,$03		*�o�̓f�[�^
*
usgmes:	.dc.b	'�@�@�\�FPCM�h���C�o�̃T���v�����O���g����'
	.dc.b		'�ݒ肵�܂�',CR,LF
	.dc.b	'�g�p�@�FPCMMODE�m�X�C�b�`�n',CR,LF
	.dc.b	TAB,'/0	3.9kHz',CR,LF
	.dc.b	TAB,'/1	5.2kHz',CR,LF
	.dc.b	TAB,'/2	7.8kHz',CR,LF
	.dc.b	TAB,'/3	10.4kHz',CR,LF
	.dc.b	TAB,'/4	15.6kHz�i�W����ԁj',CR,LF
	.dc.b	0
*
errms1:	.dc.b	'PCMMODE�FPCM�h���C�o���g�ݍ��܂�Ă��܂���',CR,LF,0
errms2:	.dc.b	'PCMMODE�F���܂��ݒ�ł��܂���ł���',CR,LF,0
*
	.stack
	.even
*
mystack:
	.ds.l	256		*�X�^�b�N�̈�
mysp:
	.end
