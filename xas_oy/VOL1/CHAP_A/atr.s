*	�t�@�C��������\������

	.include	doscall.mac
	.include	const.h
*
	.text
	.even
*
ent:
	lea.l	mysp,sp		*sp�̏�����

	bsr	chkarg		*�R�}���h���C���̉��

	bsr	do		*���C������

	DOS	_EXIT		*����I��

*
*	���C������
*
do:
	bsr	chkname		*�t�@�C�����ɑ΂���O����

	move.w	#$3f,-(sp)	*�ŏ��̃t�@�C������������
	pea.l	arg		*
	pea.l	filbuf		*
	DOS	_FILES		*
	lea.l	10(sp),sp	*

loop:	tst.l	d0		*�t�@�C���͌����������H
	bmi	done		*�@������Ȃ���Ώ�������

	bsr	setpath		*����ꂽ�t�@�C������
				*�@�t���p�X�ɍč\������

	bsr	doit		*�t�@�C���P������������

	pea.l	filbuf		*���̃t�@�C������������
	DOS	_NFILES		*
	addq.l	#4,sp		*

	bra	loop		*�J��Ԃ�

done:	rts

*
*	�t�@�C���P������������
*
doit:
	bsr	prtatr		*�t�@�C��������\������

	pea.l	filbuf+30	*�t�@�C������\������
	DOS	_PRINT		*
	addq.l	#4,sp		*

	pea.l	crlfms		*���s����
	DOS	_PRINT		*
	addq.l	#4,sp		*

	rts

*
*	�t�@�C��������\������
*
prtatr:
	lea.l	atrtbl,a0	*a0=�t�@�C�������\���p�f�[�^

	move.b	filbuf+21,d1	*d1.b=00ADVSHR
	lsl.b	#2,d1		*d1.b=ADVSHR00

	moveq.l	#6-1,d2		*�����͂U���

pratr0:	moveq.l	#0,d0		*
	move.b	(a0)+,d0	*d0=�\���p�t�@�C�������i�����j
	move.w	d0,-(sp)	*������X�^�b�N�ɐς�ł���

	lsl.b	#1,d1		*�t�@�C���������P�r�b�g�V�t�g
				*�@1)d1.b=DVSHR000,�b=A
				*�@2)d1.b=VSHR0000,�b=D
				*	�@�@�F
	bcs	pratr1		*���̑������Z�b�g����Ă����
				*�@���ɃX�^�b�N�ɐς�ł��鑮����
				*�@���̂܂ܕ\������
	move.w	#'-',(sp)	*�����łȂ����
				*�@�X�^�b�N�g�b�v��'-'�ɒu��������
pratr1:	DOS	_PUTCHAR	*�����P��\������
	addq.l	#2,sp		*

	dbra	d2,pratr0	*�J��Ԃ�

	move.w	#TAB,-(sp)	*�^�u���ЂƂo�͂���
	DOS	_PUTCHAR	*
	addq.l	#2,sp		*

	rts

*
*	files���s�ɐ旧���ăt�@�C�����ɑO������������
*
chkname:
	pea.l	nambuf		*�t�@�C������W�J����
	pea.l	arg		*
	DOS	_NAMECK		*
	addq.l	#8,sp		*

	tst.l	d0		*d0���O�Ȃ�
	bmi	usage		*�@�t�@�C�����̎w��Ɍ�肪����

	beq	nowild		*d0���O�Ȃ烏�C���h�J�[�h�w��Ȃ�

	cmpi.w	#$00ff,d0	*d0��FFH�Ȃ�
	bne	wild		*�@���C���h�J�[�h�w�肠��

noname:			*�t�@�C�������w�肳��Ă��Ȃ��ꍇ
	lea.l	arg,a0		*�o�b�t�@arg��
	lea.l	nambuf,a1	*�@nameck�œW�J�����p�X���{'*.*'
	bsr	strcpy		*�@���č\������
	lea.l	kome0,a1	*
	bsr	strcpy		*

wild:			*���C���h�J�[�h���w�肳�ꂽ�ꍇ
				*�������Ȃ��Ă悢
cknam0:	rts

nowild:			*���C���h�J�[�h���w�肳��Ă��Ȃ��ꍇ
	move.w	#SUBDIR,-(sp)	*�T�u�f�B���N�g���ł���Ɖ��肵��
	pea.l	arg		*�@�������Ă݂�
	pea.l	filbuf		*
	DOS	_FILES		*
	lea.l	10(sp),sp	*
	
	tst.l	d0		*�����������H
	bmi	cknam0		*�@������Ȃ���΃t�@�C�����낤

	lea.l	arg,a0		*�o�b�t�@arg��
	lea.l	komekome,a1	*�@���Ƃ̃t�@�C�����{'\*.*'
	bsr	strcat		*�@���č\������

	bra	chkname		*nameck�Ńt�@�C������W�J���邽�߂�
				*�@�T�u���[�`���擪�ɖ߂�

*
*	files,nfiles�Ō��t�����t�@�C�������t���p�X�ɍ\��������
*		arg�ȍ~�Ɋi�[����
*
setpath:
	lea.l	arg,a0		*a0=�R�s�[��
	lea.l	nambuf,a1	*a1=nameck�œW�J�����p�X��
	bsr	strcpy		*�R�s�[����
	lea.l	filbuf+30,a1	*a1=files,nfiles�Ō��t�����t�@�C����
	bsr	strcpy		*�A������
	rts

*
*	�R�}���h���C���̉��
*
chkarg:
	addq.l	#1,a2		*a2=�R�}���h�s������擪
	bsr	skipsp		*�X�y�[�X���X�L�b�v����
*	tst.b	(a2)		*���������邩�H
*	beq	usage		*�@�Ȃ��Ȃ����������Ȃ�
			*�D�݂ɂ���Ă��̂Q�s�𕜊������悤

	cmpi.b	#'/',(a2)	*�����̐擪��
	beq	usage		*�@'/'��
	cmpi.b	#'-',(a2)	*�@'-'�ł����
	beq	usage		*�@�����ƃw���v���������̂��낤

	lea.l	arg,a0		*a0=�����؂�o���̈�
	bsr	getarg		*�����P��a0�ȍ~�Ɏ��o��

	bsr	skipsp		*����ɃX�y�[�X���X�L�b�v
	tst.b	(a2)		*���������邩�H
	bne	usage		*�@����Ȃ����������

	rts

*
*	a2�̎w���ʒu��������P����a0�̎w���̈�փR�s�[����
*
getarg:
	move.l	a0,-(sp)	*�o���W�X�^�Ҕ�
gtarg0:	tst.b	(a2)		*1)������̏I�[�R�[�h��
	beq	gtarg1		*
	cmpi.b	#SPACE,(a2)	*2)�X�y�[�X��
	beq	gtarg1		*
	cmpi.b	#TAB,(a2)	*3)�^�u��
	beq	gtarg1		*
	cmpi.b	#'-',(a2)	*4)�n�C�t����
	beq	gtarg1		*
	cmpi.b	#'/',(a2)	*5)�X���b�V��
	beq	gtarg1		*
	move.b	(a2)+,(a0)+	*�@�������܂œ]����
	bra	gtarg0		*�@�J��Ԃ�
gtarg1:	clr.b	(a0)		*������I�[�R�[�h����������
	movea.l	(sp)+,a0	*�p���W�X�^���A
	rts

*
*	�R�}���h�s�擪�̃X�y�[�X���X�L�b�v����
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
*	������̘A������ѕ���
*	���^�[����a0�͕����񖖂�00H���w��
*
strcat:
	tst.b	(a0)+		*(a0)��0���H
	bne	strcat		*�����łȂ���ΌJ��Ԃ�
	subq.l	#1,a0		*�s������������P�߂�
strcpy:
	move.b	(a1)+,(a0)+	*�P��������
	bne	strcpy		*�I���R�[�h�܂ł�]������
	subq.l	#1,a0		*a0�͐i�݉߂��Ă���
				*a0�͕����񖖂�00H���w��
	rts

*
*	�g�p�@�̕\�����I��
*
usage:
	move.w	#STDERR,-(sp)	*�W���G���[�o�͂�
	pea.l	usgmes		*�@�w���v���b�Z�[�W��
	DOS	_FPUTS		*�@�o�͂���
	addq.l	#6,sp		*�X�^�b�N�␳

	move.w	#1,-(sp)	*�I���R�[�h�P��������
	DOS	_EXIT2		*�@�G���[�I��

*
*	���b�Z�[�W�f�[�^
*
	.data
	.even
*
usgmes:	.dc.b	'�@�@�\�F�t�@�C��������\�����܂�',CR,LF
	.dc.b	TAB,'�t�@�C�����ɂ̓��C���h�J�[�h���g�p�ł��܂�',CR,LF
	.dc.b	'�g�p�@�FATR�m�t�@�C�����n'
crlfms:	.dc.b	CR,LF,0

komekome:
	.dc.b	'\'
kome0:	.dc.b	'*.*',0

atrtbl:	.dc.b	'ADVSHR'	*�����\���p

*
*	���[�N�G���A
*
	.bss
	.even
*
arg:	.ds.b	256		*�����؂�o���p�o�b�t�@
			*files�Ŏg���o�b�t�@�͋����A�h���X�ɒu��
filbuf:	.ds.b	53		*�t�@�C�����i�[�p�o�b�t�@
			*nameck�Ŏg���o�b�t�@�͊�A�h���X�ł��悢
nambuf:	.ds.b	91		*�t�@�C�����W�J�p�o�b�t�@
*
	.stack
	.even
*
mystack:
	.ds.l	256		*�X�^�b�N�̈�
mysp:
	.end
