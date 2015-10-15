*	AS.X�̃G���[���b�Z�[�W������肵��
*		�G���[�t�@�C�����쐬����
*
	.include	doscall.mac
	.include	const.h
	.include	files.h
*
	.xref	memoff
	.xref	child
*
STRMAX	equ	256		*������̍ő咷
BUFSIZ	equ	300		*�P�s�o�b�t�@�̑傫��
*
	.text
	.even
*
ent:
	lea.l	mysp(pc),sp	*sp�̏�����

	bsr	memoff		*�]���ȃ��������J������

	bsr	chkarg		*�R�}���h���C���̉��

	pea.l	break(pc)	*���f���̖߂�A�h���X��
	move.w	#_CTRLVC,-(sp)	*�@�Z�b�g
	DOS	_INTVCS		*
	move.w	#_ERRJVC,(sp)	*
	DOS	_INTVCS		*
	addq.l	#6,sp		*

	bsr	do		*���C������

	DOS	_WAIT		*AS.X�̏I���R�[�h�𓾂�
	move.w	d0,-(sp)	*�@��������̂܂܎�����
	DOS	_EXIT2		*�@�I������

*
*	���C������
*
do:
	bsr	set_vector	*DOS�R�[���̃x�N�^������������

	lea.l	cmdlin(pc),a0	*�q�v���Z�X���N�����邽�߂�
	lea.l	prog(pc),a1	*�@�R�}���h���C�����쐬����
	bsr	strcpy		*
	movea.l	a2,a1		*
	bsr	strcpy		*

	pea.l	cmdlin(pc)	*�q�v���Z�X�N��
	bsr	child		*
	addq.l	#4,sp		*
	tst.l	d0		*
	bmi	error1		*���Ȃ�G���[

	bsr	reset_vector	*�x�N�^�����ɖ߂�

	rts

*
*	DOS�R�[��write�����������Ƃ����ɗ���
*
	.offset	0
*
FNO:	.ds.w	1	*�t�@�C���n���h��
DATPTR:	.ds.l	1	*�o�̓f�[�^�ւ̃|�C���^
DATLEN:	.ds.l	1	*�o�̓f�[�^�̃o�C�g��
*
	.text
*
write:
	cmpi.w	#STDOUT,FNO(a6)	*�o�͐�͕W���o�͂��H
	bne	write0		*�����łȂ����
				*�@�I���W�i���̏������[�`����

	movem.l	d1-d2/a0-a3,-(sp)	*�o

	movea.l	bufptr(pc),a0	*a0=�o�b�t�@���̎��̈ʒu
	movea.l	DATPTR(a6),a1	*a1=�o�̓f�[�^
	move.l	DATLEN(a6),d1	*d1=�o�̓f�[�^�̃o�C�g��
	lea.l	buff+BUFSIZ-1(pc),a2
				*a2=�o�b�t�@�̏��
				*�i�I�[�R�[�h�̕����l���j
wrt0:	move.b	(a1)+,d0	*�P�o�C�g���o��
	move.b	d0,(a0)+	*�@�o�b�t�@�ɓ]������
	cmpi.b	#LF,d0		*�P�s�����܂������H
	beq	wrt1		*�@�����Ȃ�P�s�o��
	cmpa.l	a2,a0		*�o�b�t�@�̏���ɒB������
	bcs	wrt2		*�@�����łȂ��Ȃ�X�L�b�v
wrt1:	bsr	putline		*�P�s�o�͂���
wrt2:	subq.l	#1,d1		*�f�[�^�̃J�E���^���P���炵
	bne	wrt0		*�@<>0�Ȃ�J��Ԃ�

	move.l	a0,bufptr	*�|�C���^�X�V

	movem.l	(sp)+,d1-d2/a0-a3	*�p
	*
write0:	jmp	0		*�I���W�i����write��
write_org	equ	write0+2

*
*	�P�s���̏���
*
putline:
	move.w	efno(pc),d2	*d2=�G���[�t�@�C���̃t�@�C���n���h��
	bne	putln0		*d2<>0�Ȃ�t�@�C���̓I�[�v���ς�

	move.w	#ARCHIVE,-(sp)	*�G���[�t�@�C����V�K�쐬
	pea.l	efname(pc)	*
	DOS	_CREATE		*
	addq.l	#6,sp		*
	move.w	d0,d2		*
	bmi	putln3		*�G���[�łȂ����
	move.w	d2,efno		*�@�t�@�C���n���h�������[�N��

putln0:	clr.b	(a0)		*������̏I�[�R�[�h����������
	lea.l	buff(pc),a0	*a0=�o�͂���f�[�^�擪

	lea.l	errstr(pc),a3	*�G���[���b�Z�[�W���H
	bsr	strcmp		*
	beq	putln1		*�@�����Ȃ�׍H���Ă���o��

	lea.l	wrnstr(pc),a3	*�x�����b�Z�[�W���H
	bsr	strcmp		*
	bne	putln2		*�@�����łȂ���ΐ��̂܂܏o��

			*�G���[/�x�����b�Z�[�W�������ꍇ
putln1:	move.w	d2,-(sp)	*�\�[�X�t�@�C������
	pea.l	fname(pc)	*�@�G���[�t�@�C���֏����o��
	DOS	_FPUTS		*
	addq.l	#6,sp		*
		*a0�̓G���[���b�Z�[�W���̍s�ԍ����w���Ă���

putln2:	move.w	d2,-(sp)	*�c��̃��b�Z�[�W��
	move.l	a0,-(sp)	*�@�G���[�t�@�C���֏����o��
	DOS	_FPUTS		*
	addq.l	#6,sp		*

putln3:	lea.l	buff(pc),a0	*�|�C���^������
	rts

*
*	a0�̎w��������擪��a3�̎w���������
*		��v���邩�ǂ������ׂ�
*	��v�����ꍇ	Z=1,a0=��v���������̒���
*	�s��v�̏ꍇ	Z=0,a0�͕ۑ������
*
strcmp:
	move.l	a0,-(sp)	*a0=���r������擪
				*a3=��r����������擪
strcp0:	tst.b	(a3)		*��r�����񂪂����Ȃ����
	beq	strcp1		*�@��v����
				*�����łȂ����
	cmpm.b	(a0)+,(a3)+	*�@��r���Ă݂�
	beq	strcp0		*�@��v���Ă���Ԃ͌J��Ԃ�
				*�s��v�����o���ꂽ��
	movea.l	(sp)+,a0	*���r������𕜋A����
	rts			*�@�߂�
strcp1:	addq.l	#4,sp		*�Ҕ����Ă�����a0�͂�������Ȃ�
	rts			*��v����

*
*	DOS $ff40 write�̃x�N�^������������
*
set_vector:
	pea.l	write(pc)	*�u�������鏈�����[�`���擪
	move.w	#_WRITE,-(sp)	*
	DOS	_INTVCS		*
	move.l	d0,write_org	*���̃x�N�^��Ҕ�
	st.b	hooked		*�x�N�^��������������𗧂Ă�
	addq.l	#6,sp
	rts

*
*	DOS $ff40 write�̃x�N�^�����ɖ߂�
*
reset_vector:
	tst.b	hooked		*�x�N�^�����������Ă��Ȃ��Ȃ�
	beq	rvec0		*�@�������Ȃ�

	move.l	write_org(pc),-(sp)	*WRITE�̌��̃A�h���X
	move.w	#_WRITE,-(sp)		*
	DOS	_INTVCS			*
	addq.l	#6,sp			*

	clr.b	hooked		*�t���O���N���A

rvec0:	rts

*
*	�R�}���h���C���̉��
*
chkarg:
	addq.l	#1,a2		*a2=�R�}���h���C��������擪
	move.l	a2,-(sp)	*���ƂŎg������ۑ����Ă���

	bsr	fstarg		*�󔒂ƃX�C�b�`���X�L�b�v����
	lea.l	temp(pc),a0	*�ŏ��̃X�C�b�`�ł͂Ȃ��P���
	bsr	getarg		*�@�\�[�X�t�@�C�����ƌ��Ȃ�
				*�@temp�ȉ��Ɏ��o��

	movea.l	(sp)+,a2	*a2=AS.X�֓n������

*fname�ȉ��Ƀt���p�X�̃\�[�X�t�@�C�����{TAB�̕�������쐬����
	lea.l	fname(pc),a0	*a0=�t�@�C�����i�[�̈�
	tst.b	(a2)
	beq	ckarg1
	pea.l	nambuf(pc)	*�t�@�C������W�J���Ă݂�
	pea.l	temp(pc)	*
	DOS	_NAMECK		*
	addq.l	#8,sp		*
	tst.l	d0		*
	bne	error2		*���Ȃ�G���[
	lea.l	nambuf(pc),a1	
	bsr	strcpy		*�h���C�u���{�p�X��
	lea.l	nambuf+NAME(pc),a1
	bsr	strcpy		*�@�t�@�C������������
	lea.l	nambuf+EXT(pc),a1
	tst.b	(a1)		*�g���q�͏ȗ�����Ă��邩�H
	bne	ckarg0		*����΂悵
	lea.l	sext(pc),a1	*�Ȃ����'.S'��₤
ckarg0:	bsr	strcpy		*�g���q��������

	move.b	#TAB,(a0)+	*���ł�TAB��t�������Ă���

ckarg1:	clr.b	(a0)		*�I�[�R�[�h

	rts

*
*	�R�}���h���C������
*	�@�X�C�b�`�ł͂Ȃ��ŏ��̒P��ʒu�𓾂�(a2)
*
fstarg:
	bsr	skipsp		*�X�y�[�X���X�L�b�v

	cmpi.b	#'/',(a2)	*�����̐擪��
	beq	farg0		*�@/,-�ł����
	cmpi.b	#'-',(a2)	*
	bne	farg1		*
farg0:	bsr	skipsw		*�X�C�b�`�P���X�L�b�v
	bra	fstarg		*�X�C�b�`���Ȃ��Ȃ�܂ŌJ��Ԃ�

farg1:	rts

*
*	�X�C�b�`�P���X�L�b�v����
*
skipsw:
	addq.l	#1,a2		*'/'��'-'�̕���i�߂�
	lea.l	temp(pc),a0	*�@temp�ȉ���
*	bra	getarg		*�@�]������
				*�i�]������������͎g��Ȃ��j

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
*	�R�}���h���C���擪�̃X�y�[�X���X�L�b�v����
*
skpsp0:	addq.l	#1,a2		*�|�C���^��i��
				*�J��Ԃ�
skipsp:			*�T�u���[�`���͂�������n�܂�
	cmpi.b	#SPACE,(a2)	*�X�y�[�X���H
	beq	skpsp0		*�@�����Ȃ��΂�
	cmpi.b	#TAB,(a2)	*TAB���H
	beq	skpsp0		*�@�����Ȃ��΂�
	rts

*
*	������̕���
*	���^�[����a0�͕����񖖂�00H���w��
*
strcpy:
	move.b	(a1)+,(a0)+	*�P��������
	bne	strcpy		*�I���R�[�h�܂ł�]������
	subq.l	#1,a0		*a0�͐i�݉߂��Ă���
				*a0�͕����񖖂�00H���w��
	rts

*
*	���f/�G���[�I��
*
*
break:	lea.l	brkmes(pc),a0	*^C�Ȃǂɂ�钆�f
	bra	errout
error1:	lea.l	errms1(pc),a0	*AS.X���N���ł��Ȃ�
	bra	errout
error2:	lea.l	errms2(pc),a0	*�s���ȃt�@�C����
	*
errout:	bsr	reset_vector	*�x�N�^�����ɖ߂�

	move.w	#STDERR,-(sp)	*�W���G���[�o�͂�
	move.l	a0,-(sp)	*�@���b�Z�[�W��
	DOS	_FPUTS		*�@�o�͂���
	addq.l	#6,sp		*

	move.w	#1,-(sp)	*�I���R�[�h�P��������
	DOS	_EXIT2		*�@�G���[�I��

*
*	�f�[�^�����[�N
*
	.data
	.even
*
bufptr:	.dc.l	buff		*�o�b�t�@���̎��̏������݈ʒu
efno:	.dc.w	0		*�G���[�t�@�C���̃t�@�C���n���h��
				*=0�Ȃ�΃I�[�v������Ă��Ȃ�
hooked:	.dc.b	0		*�x�N�^���������ς݂��ǂ����̃t���O
prog:	.dc.b	'AS.X ',0	*�q�v���Z�X�Ƃ��ċN������v���O������
*
errms1:	.dc.b	'ASX�FAS.X���N���ł��܂���ł���',CR,LF,0
errms2:	.dc.b	'ASX�F�\�[�X�t�@�C�����̎w��Ɍ�肪����܂�',CR,LF,0
brkmes:	.dc.b	'ASX�F���f���܂���',CR,LF,0
crlfms:	.dc.b	CR,LF,0
*
errstr:	.dc.b	'line ',0		*AS.X�̃G���[���b�Z�[�W�`��
wrnstr:	.dc.b	'Warning: Line ',0	*AS.X�̌x�����b�Z�[�W�`��
efname:	.dc.b	'AS.ERR',0		*�G���[�t�@�C����
sext:	.dc.b	'.S',0			*�\�[�X�t�@�C���̊g���q
*
	.bss
	.even
*
cmdlin:	.ds.b	STRMAX		*�R�}���h���C���쐬�p
fname:	.ds.b	STRMAX		*�A�Z���u������t�@�C�����i�t���p�X�j
temp:				*�R�}���h���C�������P���̃o�b�t�@
				*�@�i�_�~�[�j
buff:	.ds.b	BUFSIZ		*AS.X�̃��b�Z�[�W���P�s���ߍ��ރo�b�t�@
nambuf:	.ds.b	NAMBUFSIZ	*nameck�p�o�b�t�@
*
	.stack
	.even
*
mystack:
	.ds.l	1024		*�X�^�b�N�̈�
mysp:
	.end
