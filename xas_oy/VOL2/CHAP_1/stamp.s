*	256�F���[�h�p�ȈՊȈՂ��G�����c�[��

	.include	doscall.mac
	.include	iocscall.mac
*
CFKEYMOD	equ	14	*CONCTRL���[�h�ԍ�
CSCREEN		equ	16	*
CCURON		equ	17	*
CCUROFF		equ	18	*
*
HIDEFKEY	equ	3	*�t�@���N�V�����L�[�s��\��
DOS_GM3		equ	4	*��ʃ��[�h512x512,256�F
*
DISABLESKEY	equ	0	*�\�t�g�E�F�A�L�[�{�[�h�֎~
ENABLESKEY	equ	-1	*�\�t�g�E�F�A�L�[�{�[�h����
*
GVRAMUSEMD	equ	0	*TGUSEMD�̌���/�ݒ�Ώۂ�G-VRAM
CHECKUSEMD	equ	-1	*����
USING		equ	2	*�g�p��
BROKEN		equ	3	*�g�p��
*
WINH		equ	272	*���j���[�E�B���h�E��
WINV		equ	104	*���j���[�E�B���h�E����
*
USERPAGE	equ	1	*�`����s�����
BIT_USERPAGE	equ	%0010	*
MENUPAGE	equ	0	*���j���[��\��������
BIT_MENUPAGE	equ	%0001	*
*
				*���j���[�\��
SHOWMENU	equ	BIT_USERPAGE|BIT_MENUPAGE
				*���j���[��\��
HIDEMENU	equ	BIT_USERPAGE
*
GAIJITOP	equ	$eb9f	*�S�p�O���̐擪�����R�[�h
FONT16		equ	$0008	*8x16,16x16
*
PATMAX		equ	8	*�y���p�^�[���̍ő吔

*
*	�O���t�B�b�N�`��IOCS�f�[�^�󂯓n���̈�̍\��
*
	.offset 0
*
X0:	.ds.w	1	*POINT	*FILL	*BOX
Y0:	.ds.w	1	*	*	*
RETCOL:			*	*	*
X1:	.ds.w	1	*	*	*
POINTBUFSIZ:		*	*	*
Y1:	.ds.w	1		*	*
COL:	.ds.w	1		*	*
FILLBUFSIZ:			*	*
LS:	.ds.w	1			*
BOXBUFSIZ:				*

*
*	�t�H���g�ǂݍ��ݗ̈�̍\��
*
	.offset 0
*
XLEN:	.ds.w	1
YLEN:	.ds.w	1
FPAT:	.ds.w	16	*16x16
FNTBUFSIZ:
*
	.text
	.even
*
ent:
	lea.l	inisp(pc),sp		*sp������������

	moveq.l	#GVRAMUSEMD,d1		*�O���t�B�b�N��ʂ�
	moveq.l	#CHECKUSEMD,d2		*�@�g�p�\���H
	IOCS	_TGUSEMD		*
	cmpi.b	#BROKEN,d0		*�N�����g�����ςȂ��H
	beq	gramok			*�@�����Ȃ�g����
	tst.b	d0			*�N���g���Ă��Ȃ��H
	bne	quit			*�@�N�����g���Ă���

gramok:	moveq.l	#USING,d2		*�O���t�B�b�N��ʂ̎g�p��錾����
	IOCS	_TGUSEMD		*

	bsr	init			*��ʂȂǂ̏�����

	pea.l	break(pc)		*���f���̖߂�A�h���X��ݒ�
	move.w	#_CTRLVC,-(sp)		*
	DOS	_INTVCS			*
	move.w	#_ERRJVC,(sp)		*
	DOS	_INTVCS			*
	addq.l	#6,sp			*

	bsr	setupmenu		*���j���[�E�B���h�E�̏�����
	bsr	main			*���C������

break:	bsr	windup			*��n��

	move.w	#-1,-(sp)		*�L�[�o�b�t�@�N���A
	DOS	_KFLUSH			*
	addq.l	#2,sp			*

quit:	DOS	_EXIT			*�I��

*
*	���C������
*
main:
	IOCS	_MS_GETDT		*�{�^���̏�Ԃ��擾
	tst.b	d0			*�E�{�^����������Ă���H
	bne	rdown
	tst.w	d0			*���{�^����������Ă���H
	bpl	main
*
ldown:				*���{�^���������ꂽ
	IOCS	_MS_CURGT		*�}�E�X�J�[�\���ʒu���擾
	move.w	d0,d1			*d1.w = y
	clr.w	d0
	swap.w	d0			*d0.w = x
	tst.b	menuflag		*�E�B���h�E�͕\�������H
	beq	pset

	move.w	winx(pc),d2		*d2.w = �E�B���h�E�\���ʒux
	move.w	winy(pc),d3		*d3.w = �E�B���h�E�\���ʒuy

	cmp.w	d2,d0			*�E�B���h�E�ォ�ǂ����`�F�b�N
	bcs	pset			*
	cmp.w	d3,d1			*
	bcs	pset			*
	addi.w	#WINH,d2		*
	addi.w	#WINV,d3		*
	cmp.w	d2,d0			*
	bcc	pset			*
	cmp.w	d3,d1			*
	bcc	pset			*

				*�E�B���h�E���ŃN���b�N���ꂽ
	sub.w	winx(pc),d0		*d0.w = ���[�J��x���W
	sub.w	winy(pc),d1		*d1.w = ���[�J��y���W
	move.w	d0,pntbuf+X0		*x,y���ꂼ���Ҕ����Ă���
	move.w	d1,pntbuf+Y0		*

	subq.w	#8,d0
	bcs	drag			*�E�B���h�E�̍��]��
	subq.w	#8,d1
	bcs	drag			*�E�B���h�E�̏�]��
	cmp.w	#256,d0
	bcc	drag			*�E�B���h�E�̉E�]��
	cmp.w	#16,d1
	bcc	ldown1
				*��i�̃��j���[��
	cmp.w	#224,d0
	bcs	ldown0
done:				*�I���{�b�N�X��
	rts				*���C�����[�v�𔲂���

ldown0:	subi.w	#32,d0
	bcs	drag			*�y�����j���[��荶
	divu.w	#24,d0
	swap.w	d0
	cmpi.w	#16,d0
	bcc	drag			*�y���p�^�[���̌��Ԃ̗]��
	swap.w	d0
*
selpen:				*�y�����j���[��
	move.w	d0,d2			*d2.w = �y���ԍ�
	addi.w	#GAIJITOP,d0		*�V�p�^�[����ݒ�
	move.w	d0,curpat		*

	moveq.l	#MENUPAGE,d1		*���j���[�p�y�[�W��
	IOCS	_APAGE			*�@�؂芷����

	lea.l	curpen(pc),a1		*�ȑO�̘g������
	move.w	#255,COL(a1)		*
	IOCS	_BOX			*

	mulu.w	#24,d2			*�V���ɘg��`��
	addi.w	#38,d2			*
	move.w	d2,X0(a1)		*
	addi.w	#19,d2			*
	move.w	d2,X1(a1)		*
	move.w	#1,COL(a1)		*
	IOCS	_BOX			*

	bsr	lwait			*���{�^�����������̂�҂�

	bra	ldown2			*�`��p�y�[�W�ɖ߂�

ldown1:	subi.w	#24,d1
	bcs	drag			*�y�����j���[��
					*�@�F���j���[�̌��Ԃ̗]��
	cmpi.w	#64,d1
	bcc	drag			*�E�B���h�E�̉��]��
*
selcol:				*�F���j���[��
	moveq.l	#MENUPAGE,d1		*���j���[�p�y�[�W��
	IOCS	_APAGE			*�@�؂芷����

scloop:	lea.l	pntbuf(pc),a1		*�}�E�X�J�[�\���ʒu����
	IOCS	_POINT			*�@�F���E��
	move.w	RETCOL(a1),d0		*
	move.w	d0,curcol		*�J�����g�J���[�ɃZ�b�g

	lea.l	coldat(pc),a1		*�J�����g�J���[��
	move.w	d0,COL(a1)		*�@���j���[����̘g��
	IOCS	_FILL			*�@�h��ׂ�

	IOCS	_MS_GETDT		*���{�^����������Ă��邠����
	tst.w	d0			*�@�J��Ԃ�
	bpl	ldown2			*
					*
	IOCS	_MS_CURGT		*
	sub.w	winy(pc),d0		*
	move.w	d0,pntbuf+Y0		*
	swap.w	d0			*
	sub.w	winx(pc),d0		*
	move.w	d0,pntbuf+X0		*
					*
	bra	scloop			*

ldown2:	moveq.l	#USERPAGE,d1		*�`��p�y�[�W�ɖ߂�
	IOCS	_APAGE			*

	bra	main			*���C�����[�v��
*
drag:				*�E�B���h�E�̊O�g�ŃN���b�N���ꂽ
	bsr	lwait			*���{�^�����������̂�҂�
	bra	menuon			*�E�B���h�E��`������
*
pset:				*�E�B���h�E�O�ŃN���b�N���ꂽ
	lea.l	setdat(pc),a1		*�}�E�X�J�[�\���̈ʒu��
	subq.w	#8,d0			*�@�p�^�[����`��
	move.w	d0,X0(a1)		*
	subq.w	#8,d1			*
	move.w	d1,Y0(a1)		*
	IOCS	_SYMBOL			*

	bra	main			*���C�����[�v��
*
rdown:				*�E�{�^���������ꂽ
	move.l	#(WINH/2)<<16,ofst	*�\���ʒu�I�t�Z�b�g
	tst.b	menuflag		*���j���[�͕\�������H
	beq	menuon
*
menuoff:			*���j���[�E�B���h�E������
	sf.b	menuflag		*�t���O��Q������
	moveq.l	#HIDEMENU,d1		*���j���[�y�[�W��\��
	IOCS	_VPAGE			*

	bsr	rwait			*�E�{�^�����������̂�҂�

	bra	main			*���C�����[�v��
*
menuon:				*���j���[�E�B���h�E���o��
	st.b	menuflag		*�t���O�𗧂Ă�
	IOCS	_MS_CURGT		*�}�E�X�J�[�\���ʒu���擾
	move.w	d0,d1			*d1.w = y
	swap.w	d0			*d0.w = x

	sub.w	ofst+X0(pc),d0		*�E�B���h�E��
	bcc	mon0			*�@��ʂ���͂ݏo���Ȃ��悤
	clr.w	d0			*�@��������
mon0:	sub.w	ofst+Y0(pc),d1		*
	bcc	mon1			*
	clr.w	d1			*
mon1:	cmp.w	#512-WINH,d0		*
	bcs	mon2			*
	move.w	#512-WINH,d0		*
mon2:	cmp.w	#512-WINV,d1		*
	bcs	mon3			*
	move.w	#512-WINV,d1		*

mon3:	move.w	d0,winx			*�\���ʒu���i�[
	move.w	d1,winy			*

	moveq.l	#0,d2			*�E�B���h�E��ړI�̈ʒu��
	sub.w	d0,d2			*�@�ړ�����
	andi.w	#511,d2			*
	moveq.l	#0,d3			*
	sub.w	d1,d3			*
	andi.w	#511,d3			*
	moveq.l	#BIT_MENUPAGE,d1	*
	IOCS	_HOME			*

	moveq.l	#SHOWMENU,d1		*���j���[�y�[�W�\��
	IOCS	_VPAGE			*

	bsr	rwait			*�E�{�^�����������̂�҂�

	bra	main			*���C�����[�v��

*
rwait:				*�E�{�^�����������̂�҂�
	IOCS	_MS_GETDT
	tst.b	d0
	bne	rwait
	rts
*
lwait:				*���{�^�����������̂�҂�
	IOCS	_MS_GETDT
	tst.w	d0
	bmi	lwait
	rts

*
*	������
*
init:
	link	a6,#0
				*���
	move.w	#DOS_GM3,-(sp)		*��ʂ�512x512,256�F��
	move.w	#CSCREEN,-(sp)		*�@������
	DOS	_CONCTRL		*
	move.w	d0,scrnmsav		*���݂̉�ʃ��[�h��Ҕ�

	move.w	#HIDEFKEY,-(sp)		*�t�@���N�V�����L�[�s��
	move.w	#CFKEYMOD,-(sp)		*�@��\���ɐݒ�
	DOS	_CONCTRL		*
	move.w	d0,fkeymsav		*���݂̃t�@���N�V�����L�[�s
					*�@���[�h��Ҕ�

	move.w	#CCUROFF,-(sp)		*�J�[�\����\�����[�h
	DOS	_CONCTRL		*

				*�O��
	bsr	savfont			*�Ҕ�
	bsr	deffont			*��`

				*�}�E�X
	IOCS	_MS_INIT		*�}�E�X������
	IOCS	_MS_CURON		*�}�E�X�J�[�\���\��
	moveq.l	#DISABLESKEY,d1		*�\�t�g�E�F�A�L�[�{�[�h��
	IOCS	_SKEY_MOD		*�@�g�p���֎~

	unlk	a6
	rts

*
*	���j���[�̏�����
*	�i���炩���ߑS���`���Ă���)
*
setupmenu:
	moveq.l	#MENUPAGE,d1		*���j���[�p�y�[�W��
	IOCS	_APAGE			*�@�؂芷����

	moveq.l	#HIDEMENU,d1		*���j���[�p�y�[�W��\��
	IOCS	_VPAGE			*

	lea.l	fildat(pc),a1		*�E�B���h�E�g��h��ׂ�
	IOCS	_FILL			*

	lea.l	boxes(pc),a1		*BOX��K�v�Ȃ����`��
boxlp:	tst.w	(a1)			*
	bmi	boxed			*
	IOCS	_BOX			*
	lea.l	BOXBUFSIZ(a1),a1	*
	bra	boxlp			*

boxed:	lea.l	mendat(pc),a1		*�y���p�^�[�����j���[��
	IOCS	_SYMBOL			*�@�`��

	bsr	makecoltbl		*�J���[�e�[�u��

	moveq.l	#USERPAGE,d1		*�`��p�y�[�W�ɐ؂芷����
	IOCS	_APAGE			*

	sf.b	menuflag		*�t���O��Q������

	rts

*
*	256�F�̐F�e�[�u����`��
*
makecoltbl:
	link	a6,#-FILLBUFSIZ

	lea.l	-FILLBUFSIZ(a6),a1	*a1 = FILL�p�����̈�

	moveq.l	#0,d1			*d1 = �F

	move.w	#32,Y0(a1)		*�ŏ���(8,32)-(8+7,32+7)����
	move.w	#32+7,Y1(a1)		*

	moveq.l	#8-1,d6			*�c�ɂW��
clp0:	move.w	#8,X0(a1)
	move.w	#8+7,X1(a1)

	moveq.l	#32-1,d7		*����32��
clp1:	move.w	d1,COL(a1)		*�l�p��`��
	IOCS	_FILL			*

	addq.w	#8,X0(a1)		*�E�ɂW�s�N�Z���ړ�
	addq.w	#8,X1(a1)		*
	addq.w	#1,d1			*���̐F
	dbra	d7,clp1			*���P�񕪌J��Ԃ�

	addq.w	#8,Y0(a1)		*���ɂW�s�N�Z���ړ�
	addq.w	#8,Y1(a1)		*
	dbra	d6,clp0			*�J��Ԃ�

	unlk	a6
	rts

*
*	��n��
*
windup:
	link	a6,#0

	move.w	scrnmsav(pc),-(sp)	*��ʃ��[�h��߂�
	move.w	#CSCREEN,-(sp)		*
	DOS	_CONCTRL		*

	move.w	fkeymsav(pc),-(sp)	*�t�@���N�V�����L�[�s��
	move.w	#CFKEYMOD,-(sp)		*�@���[�h��߂�
	DOS	_CONCTRL		*

	move.w	#CCURON,-(sp)		*�J�[�\���\�����[�h
	DOS	_CONCTRL		*

	bsr	rstfont			*�O���t�H���g���A

	IOCS	_MS_INIT		*�}�E�X������
	moveq.l	#ENABLESKEY,d1		*�\�t�g�E�F�A�L�[�{�[�h��
	IOCS	_SKEY_MOD		*�@�g�p������

	moveq.l	#GVRAMUSEMD,d1		*G-VRAM���e�͔j�󂵂�
	moveq.l	#BROKEN,d2		*
	IOCS	_TGUSEMD		*

	unlk	a6
	rts

*
*	�O���̐擪�W�����̃t�H���g�p�^�[����Ҕ�����
*
savfont:
	lea.l	fontbuf(pc),a1
	move.l	#FONT16<<16|GAIJITOP,d1
	moveq.l	#PATMAX-1,d2
savlp:	IOCS	_FNTGET
	addq.w	#1,d1
	lea.l	FNTBUFSIZ(a1),a1
	dbra	d2,savlp
	rts

*
*	�O���̐擪�W�����Ƀt�H���g�p�^�[����ݒ肷��
*
deffont:
	lea.l	fontdat+FPAT(pc),a1
defnt0:	move.l	#FONT16<<16|GAIJITOP,d1
	moveq.l	#PATMAX-1,d2
deflp:	IOCS	_DEFCHR
	addq.w	#1,d1
	lea.l	FNTBUFSIZ(a1),a1
	dbra	d2,deflp
	rts

*
*	savfont�őҔ������t�H���g�p�^�[���𕜋A����
*
rstfont:
	lea.l	fontbuf+FPAT(pc),a1
	bra	defnt0

*
*	�f�[�^�����[�N
*
	.data
	.even
*
fontdat:
	.dc.w	16,16			*eb9f
	.dc.w	%0000000000000000	*0
	.dc.w	%0000000000000000
	.dc.w	%0000000000000000
	.dc.w	%0011111110111111
	.dc.w	%0010000001010001
	.dc.w	%0001000001010010
	.dc.w	%0001000000101100
	.dc.w	%0000100000101000
	.dc.w	%0000100000010000
	.dc.w	%0000010000010000
	.dc.w	%0000010000001000
	.dc.w	%0000101000001000
	.dc.w	%0001101000000100
	.dc.w	%0010010100000100
	.dc.w	%0100010100000010
	.dc.w	%0111111011111110

	.dc.w	16,16			*eba0
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0080,$0000,$0000,$0000,$0000,$0000,$0000,$0000

	.dc.w	16,16			*eba1
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0180
	.dc.w	$0180,$0000,$0000,$0000,$0000,$0000,$0000,$0000

	.dc.w	16,16			*eba2
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$01c0
	.dc.w	$01c0,$01c0,$0000,$0000,$0000,$0000,$0000,$0000

	.dc.w	16,16			*eba3
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0410,$0220,$0140
	.dc.w	$0080,$0140,$0220,$0410,$0000,$0000,$0000,$0000

	.dc.w	16,16			*eba4
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0c00,$0600,$0300
	.dc.w	$0180,$00c0,$0060,$0030,$0000,$0000,$0000,$0000

	.dc.w	16,16			*eba5
	.dc.w	$0000,$03e0,$07f0,$0ff8,$1ffc,$3ffe,$7fff,$7fff
	.dc.w	$7fff,$7fff,$7fff,$3ffe,$1ffc,$0ff8,$07f0,$03e0

	.dc.w	16,16			*eba6
	.dc.w	$0000,$7fff,$7fff,$7fff,$7fff,$7fff,$7fff,$7fff
	.dc.w	$7fff,$7fff,$7fff,$7fff,$7fff,$7fff,$7fff,$7fff

fildat:	.dc.w	0,0			*�E�B���h�E�g�h��ׂ��p
	.dc.w	WINH-1,WINV-1
	.dc.w	255

boxes:					*�E�B���h�E���g�`��p
box1:	.dc.w	2,2,WINH-2-1,WINV-2-1,1,$ffff
box2:	.dc.w	6,6,33,25,1,$ffff
curpen:
box3:	.dc.w	38,6,57,25,1,$ffff	*�J�����g�y���������g
box4:	.dc.w	230,6,265,25,1,$ffff
box5:	.dc.w	6,30,265,97,1,$ffff
	.dc.w	-1

mendat:	.dc.w	40,8			*���j���[�\���p
	.dc.l	patstr
	.dc.b	1,1
	.dc.w	1
	.dc.b	1,0

coldat:	.dc.w	8,8,31,23,255		*�J�����g�J���[�\���p

setdat:	.dc.w	0,0			*�_�`��p
	.dc.l	curpat
	.dc.b	1,1
curcol:	.dc.w	255
	.dc.b	1,0

curpat:	.dc.b	$eb,$9f,0		*�J�����g�y���p�^�[��

patstr:	.dc.b	$eb,$9f,$20,$eb,$a0,$20	*���j���[������
	.dc.b	$eb,$a1,$20,$eb,$a2,$20
	.dc.b	$eb,$a3,$20,$eb,$a4,$20
	.dc.b	$eb,$a5,$20,$eb,$a6,$20
	.dc.b	'�I��',0
*
	.bss
	.even
*
fontbuf:	.ds.b	FNTBUFSIZ*8	*�t�H���g�Ҕ�̈�
ofst:
pntbuf:		.ds.b	POINTBUFSIZ	*IOCS POINT�p
winx:		.ds.w	1		*���j���[�E�B���h�E�\���ʒu
winy:		.ds.w	1		*
scrnmsav:	.ds.w	1		*��ʃ��[�h�Ҕ�p
fkeymsav:	.ds.w	1		*�t�@���N�V�����L�[�s���[�h�Ҕ�p
menuflag:	.ds.b	1		*���j���[�\��/��\���t���O
*
	.stack
	.even
*
	.ds.l	1024		*�X�^�b�N�̈�
inisp:
	.end	ent
