*	�R�}���h���C���������
*	�����Ƃ��ăt�@�C�������Q�K�v�Ƃ�
*	/A,/B�Q�̃X�C�b�`�����ꍇ

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
*	���C�������i���͉������Ȃ��j
*
do:
	rts

*
*	�R�}���h���C���̉��
*
chkarg:
	addq.l	#1,a2		*a2=�R�}���h���C��������擪

	lea.l	arg1,a0		*a0=�����؂�o���̈�

	moveq.l	#2-1,d2		*�ȉ����Q��J��Ԃ�

ckarg0:	bsr	nextarg		*�X�y�[�X���X�L�b�v��
				*�@�X�C�b�`������Ώ�������
	tst.b	(a2)		*���������邩�H
	beq	usage		*�@�Ȃ��Ȃ����������Ȃ�

	bsr	getarg		*�����P��a0�ȍ~�Ɏ��o��

	pea.l	nambuf		*DOS�R�[�����g����
	move.l	a0,-(sp)	*�@�t�@�C������
	DOS	_NAMECK		*�@�W�J���Ă݂�
	addq.l	#8,sp		*
	tst.l	d0		*d0���O�łȂ����
	bne	usage		*�@�t�@�C�����̎w��Ɍ�肪����

	lea.l	256(a0),a0	*a0 = a0+256

	dbra	d2,ckarg0	*d2.w��-1�ɂȂ�܂ŌJ��Ԃ�

	bsr	nextarg		*����ɃX�y�[�X���΂�
	tst.b	(a2)		*���������邩�H
	bne	usage		*�@����Ȃ����������

	rts

*
*	�X�y�[�X���΂����̈����擪�܂Ń|�C���^��i�߂�
*	�X�C�b�`������Ώ������Ă��܂�
*
nextarg:
	bsr	skipsp		*�X�y�[�X���X�L�b�v

	cmpi.b	#'/',(a2)	*�����̐擪��
	beq	nxarg0		*�@/,-�ł����
	cmpi.b	#'-',(a2)	*�@�X�C�b�`
	beq	nxarg0		*

	rts			*�X�C�b�`�͂����Ȃ�
*
nxarg0:	addq.l	#1,a2		*'/'��'-'�̕��|�C���^��i�߂�
	move.b	(a2)+,d0	*�P�������o��
	bsr	toupper		*�啶���ɕϊ����Ă���
	cmpi.b	#'A',d0		*A�X�C�b�`�H
	beq	asw		*�@�����Ȃ番��
	cmpi.b	#'B',d0		*B�X�C�b�`�H
	beq	bsw		*�@�����Ȃ番��
	bra	usage		*�����ȃX�C�b�`���w�肳�ꂽ
*
asw:	tst.b	Aflg		*A�X�C�b�`�̓�d�w��H
	bne	usage		*�@�����Ȃ�G���[
	move.b	#$ff,Aflg	*A�X�C�b�`ON
	bra	nextarg		*���̃X�C�b�`�����邩������Ȃ�
*
bsw:	tst.b	Bflg		*A�X�C�b�`�̏ꍇ��
	bne	usage		*�@����Ă��邱�Ƃ͓���
	move.b	#$ff,Bflg	*
	bra	nextarg		*

*
*	�p���������p�啶���ϊ�
*
toupper:
	cmpi.b	#'a',d0		*�p���������H
	bcs	toupr0		*
	cmpi.b	#'z'+1,d0	*
	bcc	toupr0		*
	subi.b	#$20,d0		*�������Ȃ�啶���ɕϊ�
toupr0:	rts

*
*	a2�̎w���ʒu��������P����
*	a0�̎w���̈�փR�s�[����
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
skipsp:				*�T�u���[�`���͂�������n�܂�
	cmpi.b	#SPACE,(a2)	*�X�y�[�X���H
	beq	skpsp0		*�@�����Ȃ��΂�
	cmpi.b	#TAB,(a2)	*TAB���H
	beq	skpsp0		*�@�����Ȃ��΂�
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
*	�f�[�^
*
	.data
	.even
*
Aflg:	.dc.b	0	*/A�X�C�b�`on/off�t���O�i=0...off,<>0...on�j
Bflg:	.dc.b	0	*/B�X�C�b�`on/off�t���O�i=0...off,<>0...on�j
*
usgmes:	.dc.b	'�@�@�\�F���̓t�@�C�����~�~����'
	.dc.b			'�o�̓t�@�C���ɏ����o���܂�',CR,LF
	.dc.b	'�g�p�@�FARG2 ���̓t�@�C���@�o�̓t�@�C��',CR,LF
	.dc.b	'	/A	�����𖳎����܂�',CR,LF
	.dc.b	'	/B	�����������ƌ��Ȃ��܂�'
crlfms:	.dc.b	CR,LF,0

*
*	���[�N�G���A
*
	.bss
	.even
*
arg1:	.ds.b	256		*�����؂�o���p�o�b�t�@�P
arg2:	.ds.b	256		*�����؂�o���p�o�b�t�@�Q
nambuf:	.ds.b	91		*�t�@�C�����W�J�p�o�b�t�@
*
	.stack
	.even
*
mystack:
	.ds.l	256		*�X�^�b�N�̈�
mysp:
	.end
