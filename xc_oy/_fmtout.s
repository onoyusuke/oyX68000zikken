*************************************************************************
*_fmtout�F�w��֐��֕ҏW�o��						*
*	int		_fmtout(func,stream,format,arg);		*
*	int		(*func)();					*
*	FILE		*stream;					*
*	const char	*format;					*
*	va_list		arg;						*
*************************************************************************
* Copyright 1990 SHARP/Hudson		(1990/05/05)			*

*****************************************
*	�R���g���[���E�t���O		*
*****************************************

leftadj	equ	31			. ���l�߃t���O
signflg	equ	30			. �����t���t���O
precflg	equ	29			. �������L��t���O
longflg	equ	28			. �������� ���������������t���O
large	equ	27			. �啶���t���O
zeropad	equ	26			. �[���E�p�f�B���O�t���O
endflg	equ	25			. �I���t���O
aster	equ	24			. ���w��
sharp	equ	23			. ���w��
spacef	equ	22			. space�w��
shrtflg	equ	21			. ���������� ���������������t���O

*****************************************
*	�R���g���[���E�R�[�h		*
*****************************************

CR	equ	$0d			. ���A�R�[�h
LF	equ	$0a			. ���s�R�[�h

	xdef	__fmtout

	xref	_ecvt
	xref	_fcvt

	include	stdio.mac
	include	fefunc.h

*****************************************
*	�X�^�b�N�E�G���A		*
*****************************************

	.offset	0
tbuff	ds.b	620			. ��ƃo�b�t�@
savreg	ds.l	9			. ���W�X�^�E�Z�[�u�̈�
rtnadr	ds.l	1			. ���A�A�h���X
outent	ds.l	1			. �o�̓v���O�����G���g��
device	ds.l	1			. �o�͐�w��
format	ds.l	1			. �o�̓t�H�[�}�b�g�ʒu
argtop	ds.l	1			. �o�͈����擪�ʒu�Z�b�g

	.text
__fmtout:
	movem.l	d3-d7/a3-a6,-(sp)	. ��ƃ��W�X�^�E�Z�[�u
	lea	-620(sp),sp		. ��ƃo�b�t�@�m��
	movea.l	outent(sp),a6		. ���U���o�̓v���O�����G���g��
	move.l	device(sp),d6		. ���U���o�͐�w��
	movea.l	format(sp),a4		. ���S���o�̓t�H�[�}�b�g�ʒu
	movea.l	argtop(sp),a5		. ���T���o�͈����擪�ʒu�Z�b�g
	clr.l	d7			. ���V���o�͕������݌v

_fmtout_loop:
	clr.l	d4			. ���S���t���O�̈揉����
	clr.l	d5			. ���T���v���o�͕������N���A
	lea	8(sp),a3		. ���R����ƃo�b�t�@
	bsr	_edtout			. �ҏW����
	btst.l	#endflg,d4		. �I���H
	beq	_fmtout_loop
*					. �o�͖���
_fmtout_end:
	lea	620(sp),sp		. ��ƃo�b�t�@�ԋp
	move.l	d7,d0			. ���^�[���l �� �o�͕������݌v
	movem.l	(sp)+,d3-d7/a3-a6	. ��ƃ��W�X�^�E���J�o��
	rts				. �Ăяo�����֕��A

*****************************************
*	�ҏW����			*
*****************************************

_edtout:
	move.b	(a4)+,d0		. �P�������o��
	bne	_edtout_nex
	bset.l	#endflg,d4		. �ҏW�I���t���O�I��
	bra	_edtout_ext		. �ҏW�I��

_edtout_nex:
	movea.l	a4,a2			. ���Q�����S �ꎞ�ޔ�
	cmpi.b	#'%',d0			. �ϊ��w��H
	bne	_not_cnv		. ���ϊ�
	bsr	_convx			. �ϊ�����
	bra	_edtout_ext

_not_cnv:
	bsr	_nconvx			. ���ϊ�����
_edtout_ext:
	rts

*****************************************
*	�ϊ�����			*
*****************************************

_convx:
	move.b	(a4)+,d0		. �P�����f�d�s
	bne	_parameter_get
	bset.l	#endflg,d4		. �I���t���O�E�I��
	rts

*****************************************
*	�ϊ��p�����[�^�f�d�s		*
*****************************************

_parameter_get:
	cmpi.b	#'-',d0			. ���l�ߕҏW�H
	bne	no_left
	bset.l	#leftadj,d4		. ���l�߃t���O�E�I��
	bra	_convx

no_left:
	cmpi.b	#'+',d0			. flag +
	bne	no_sign
	bset.l	#signflg,d4
	bra	_convx

no_sign:
	cmpi.b	#' ',d0			. flag blank
	bne	no_blank
	bset.l	#spacef,d4
	bra	_convx

no_blank:
	cmpi.b	#'#',d0			. flag #
	bne	no_sharp
	bset.l	#sharp,d4
	bra	_convx

no_sharp:
	moveq.l	#-1,d3			. ���R���o�q�d�b�h�r�m�^�v�h�c�s�g
	cmpi.b	#'0',d0			. �y�d�q�n�l�ߕҏW�H
	bne	check_aster
	bset.l	#zeropad,d4		. '�O' �p�f�B���O�t���O�E�I��
	bra	width_set		. skip_sign

check_aster:
	cmpi.b	#'*',d0			. ���w��
	bne	width_set
	move.l	(a5)+,d1
	bpl	_width_plus
	neg.l	d1
	bset.l	#leftadj,d4
_width_plus:
	move.w	d1,d3			. �v�h�c�s�g�Đݒ�
	move.b	(a4)+,d0		. �P�����f�d�s
	beq	_nconvx_0
	bra	prechk

*****************************************
*	�v�h�c�s�g�l��			*
*****************************************

width_set:
	cmp.b	#'0',d0
	bcs	prechk
	cmp.b	#'9',d0
	bhi	prechk
	bsr	_atoix
	bmi	_nconvx_0
	move.w	d0,d3			. ���O���v�h�c�s�g

*****************************************
*	�o�q�d�b�h�r�m�l��		*
*****************************************

	swap	d0

prechk:
	cmpi.b	#'.',d0			. �����_�H
	bne	_long_direc
	bset.l	#precflg,d4		. �����_�t���O�I��
	move.b	(a4)+,d0
	beq	_nconvx_0

	cmpi.b	#'*',d0			. ���w��
	bne	prechk2
	move.l	(a5)+,d1
	bpl	_prec_plus
	neg.l	d1
	bset.l	#leftadj,d4
_prec_plus:
	swap	d3
	move.w	d1,d3			. �o�q�d�b�h�r�m�Đݒ�
	swap	d3			. ���R���o�q�d�b�h�r�m�^�v�h�c�s�g
	move.b	(a4)+,d0		. �P�����f�d�s
	beq	_nconvx_0
	bra	_long_direc

prechk2:
	cmp.b	#'0',d0
	bcs	_long_direc
	cmp.b	#'9',d0
	bhi	_long_direc
	bsr	_atoix
	bmi	_nconvx_0
	swap	d3
	move.w	d0,d3
	swap	d3			. ���R���o�q�d�b�h�r�m�^�v�h�c�s�g
	swap	d0			. ���O��������

*****************************************
*	�������� �������������� ����	*
*****************************************

_long_direc:
	cmpi.b	#'l',d0			. �������k�w��H
	beq	_long_set
	cmpi.b	#'L',d0
	beq	_long_set
	cmpi.b	#'h',d0			. �������g�w��H
	beq	_short_set
	cmpi.b	#'H',d0
	bne	_large_chk

_short_set:
	bset.l	#shrtflg,d4		. �����������t���O�Z�b�g
	bra	_long_short

_long_set:
	bset.l	#longflg,d4		. ���������t���O�Z�b�g
_long_short:
	move.b	(a4)+,d0		. �P�����f�d�s
	beq	_nconvx_0

*****************************************
*	�啶������			*
*****************************************

_large_chk:
	cmpi.b	#'A',d0
	bcs	_nconvx_0		. ���ϊ�����
	cmpi.b	#'Z',d0
	bhi	_comand_chk
	bset.l	#large,d4		. �啶���t���O�Z�b�g

*****************************************
*	�啶�����珬�����֕ϊ�		*
*****************************************

	add.b	#'a'-'A',d0		. �������֕ϊ�
	bra	_conv_chk

*****************************************
*	�ϊ��R�}���h����		*
*****************************************

_comand_chk:
	cmpi.b	#'a',d0
	bcs	_nconvx_0		. ���ϊ�����
	cmpi.b	#'z',d0
	bhi	_nconvx_0		. ���ϊ�����
_conv_chk:
	cmpi.b	#'b',d0
	bcs	_nconvx_0		. ���ϊ�����
	cmpi.b	#'c',d0
	bcs	_fmtout_bin		. �Q�i���\�� (b/B)
	cmpi.b	#'d',d0
	bcs	_fmtout_char		. �P�����\�� (c/C)
	cmpi.b	#'e',d0
	bcs	_fmtout_dec		. �����t���P�O�i�����\�� (d/D)
	cmpi.b	#'h',d0
	bcs	_fmtout_float		. ���������_�\�� (e/E f/F g/G)
	cmpi.b	#'i',d0
	beq	_fmtout_dec		. �����t���P�O�i�����\�� (i/I)
	cmpi.b	#'n',d0
	beq	_fmtout_chrlen		. �o�͕������̒ʒm�i�ϊ������ł͂Ȃ��j
	cmpi.b	#'o',d0
	beq	_fmtout_oct		. �W�i���\�� (o/O)
	cmpi.b	#'p',d0
	beq	_fmtout_ptr		. �|�C���^�̂P�U�i���\��
	cmpi.b	#'s',d0
	beq	_fmtout_string		. ������\�� (s/S)
	cmpi.b	#'u',d0
	beq	_fmtout_dec		. ���������P�O�i�����\�� (u/U)
	cmpi.b	#'x',d0
	beq	_fmtout_hex		. �P�U�i���\�� (x/X)
	bra	_nconvx_0		. ���ϊ�����

*****************************************
*	�o�͕������̒ʒm(n/N)		*
*****************************************

_fmtout_chrlen:
	move.l	(a5)+,a0
	move.l	d7,(a0)			. �o�͕������݌v
	rts

*****************************************
*	���������_(f/F e/E g/G)		*
*****************************************

_fmtout_float:
	clr.l	d2
	move.b	d0,d2
	move.l	(a5)+,d0		. ���O�����������_��ʃ��[�h
	move.l	(a5)+,d1		. ���P�����������_���ʃ��[�h
	cmpi.b	#'g',d2			. (g/G) �ϊ��H
	beq	_fmtout_float_g
	cmpi.b	#'f',d2			. (f/F) �ϊ��H
	beq	_fmtout_float_f
*					. (e/E) �ϊ�
_fmtout_float_e:
	cmp.w	#-1,d3
	bne	ewidndef
	move.w	#1,d3			. width
ewidndef:
	swap	d3
	cmp.w	#-1,d3
	bne	eprcndef
	move.w	#6,d3			. precision
eprcndef:
	move.w	d3,d2
	swap	d3
	bsr	ecnv_st
	bsr	ecnv2_st
_fmtout_float_leng:
	lea	1(a3),a0		. ���O����Ɨ̈�A�h���X
	cmp.b	#'-',(a0)
	beq	_fmtout_leng_get
	btst.l	#signflg,d4
	bne	plsetf
	btst.l	#spacef,d4
	beq	_fmtout_leng_get
	move.b	#' ',-(a0)
	bra	_fmtout_leng_get
plsetf:
	move.b	#'+',-(a0)
	bra	_fmtout_leng_get

*					. (f/F) �ϊ�
_fmtout_float_f:
	cmp.w	#-1,d3
	bne	fwidndef
	move.w	#1,d3			. width
fwidndef:
	swap	d3
	cmp.w	#-1,d3
	bne	fprcndef
	move.w	#6,d3			. precision
fprcndef:
	move.w	d3,d2
	swap	d3
	subq.l	#8,sp
	move.l	sp,a0
	lea	4(sp),a1
	move.l	a1,-(sp)
	move.l	a0,-(sp)
	move.l	d2,-(sp)
	movem.l	d0-d1,-(sp)
	jsr	_fcvt			. �e �ϊ� �b�`�k�k
	lea	20(sp),sp
	movem.l	(sp)+,d1-d2		. d1=decpt,d2=sign
	move.l	d0,a0			. d0=ascii data
	bsr	fcnv_st
	bra	_fmtout_float_leng

*					. (g/G) �ϊ�
_fmtout_float_g:
	cmp.w	#-1,d3
	bne	gwidndef
	move.w	#1,d3			. width
gwidndef:
	swap	d3
	cmp.w	#-1,d3
	bne	gprcndef
	move.w	#14,d3			. precision
gprcndef:
	move.w	d3,d2
	swap	d3
	movem.l	d0-d2,-(sp)
	subq.l	#8,sp
	move.l	sp,a0
	lea	4(sp),a1
	move.l	a1,-(sp)
	move.l	a0,-(sp)
	move.l	d2,-(sp)
	movem.l	d0-d1,-(sp)
	jsr	_fcvt			. �e �ϊ� �b�`�k�k
	lea	20(sp),sp
	movem.l	(sp)+,d1-d2		. d1=decpt,d2=sign
	move.l	d0,a0			. a0=ascii data
	subq.l	#1,d1			. d1=e???
	cmp.w	#-4,d1
	blt	g_ecnv
	move.l	d3,d0
	swap	d0
	cmp.w	d0,d1
	ble	g_fcnv
g_ecnv:
	movem.l	(sp)+,d0-d2
	bsr	ecnv_st
	bsr	zerocut
	bsr	ecnv2_st
	bra	_fmtout_float_leng

g_fcnv:
	addq.l	#1,d1			. d1=decpt
	lea	12(sp),sp
	bsr	fcnv_st
	bsr	zerocut
	bra	_fmtout_float_leng

*	sub 1
zerocut:
	btst.l	#sharp,d4		. #�Ȃ�(0)�̏ȗ��͂Ȃ�
	bne	zerocut_end
	clr.b	(a1)
	lea	1(a3),a0
zeroct0:
	move.b	(a0)+,d0
	beq	zerocut_end
	cmp.b	#'.',d0
	bne	zeroct0
zeroct1:
	move.b	-(a1),d0
	cmp.b	#'0',d0
	beq	zeroct1
	cmp.b	#'.',d0
	bne	zeroct2
	btst.l	#sharp,d4		. #�łȂ��Ȃ�Ȃ�(.)���J�b�g
	beq	zeroct3
zeroct2:
	addq.l	#1,a1
zeroct3:
	clr.b	(a1)
zerocut_end:
	rts

*	sub 2
ecnv_st:
	addq.w	#1,d2
	subq.l	#8,sp
	move.l	sp,a0
	lea	4(sp),a1
	move.l	a1,-(sp)
	move.l	a0,-(sp)
	move.l	d2,-(sp)
	movem.l	d0-d1,-(sp)
	jsr	_ecvt			. �d �ϊ� �b�`�k�k
	movem.l	(sp)+,d1-d2
	lea	12(sp),sp
	bclr.l	#31,d1
	or.l	d2,d1
	movem.l	(sp)+,d1-d2		. d1=decpt,d2=sign
	bne	nozero
	moveq.l	#1,d1
nozero:
	move.l	d0,a0			. a0=ascii data
	lea	1(a3),a1		. buffer
	tst.l	d2
	beq	skpsign
	move.b	#'-',(a1)+
skpsign:
	bsr	a0getd0
	move.b	d0,(a1)+
	bsr	priod_set
	rts

*	sub 3
ecnv2_st:
	move.b	#'e',d0
	btst.l	#large,d4		. �啶���t���O�Z�b�g
	beq	small_eok
	move.b	#'E',d0
small_eok:
	move.b	d0,(a1)+		. 'e' / 'E'
	move.b	#'+',d0
	subq.l	#1,d1
	tst.l	d1
	bpl	plus_ok
	move.b	#'-',d0
	neg.l	d1
plus_ok:
	move.b	d0,(a1)+
	divu	#100,d1
	add.b	#'0',d1
	move.b	d1,(a1)+
	clr.w	d1
	swap	d1
	divu	#10,d1
	add.b	#'0',d1
	move.b	d1,(a1)+
	swap	d1
	add.b	#'0',d1
	move.b	d1,(a1)+
	clr.b	(a1)
	rts

*	sub 4
fcnv_st:
	lea	1(a3),a1		. buffer
	tst.l	d2
	beq	skpsign_f
	move.b	#'-',(a1)+
skpsign_f:
	tst.l	d1
	bmi	f_minus
	beq	f_minus
	subq.l	#1,d1
f_plus:
	bsr	a0getd0
	move.b	d0,(a1)+
	dbra	d1,f_plus
	bsr	priod_set
	clr.b	(a1)
	rts
f_minus:
	neg.l	d1
	move.l	d3,d0
	swap	d0
	move.b	#'0',(a1)+
	btst.l	#sharp,d4		. #�Ȃ�(.)���Z�b�g
	bne	priset2
	tst.w	d0
	beq	priod_ed2
priset2:
	move.b	#'.',(a1)+
	tst.w	d0
	beq	priod_ed2
	subq.w	#1,d1
	bmi	priod_e2
zerost:
	move.b	#'0',(a1)+
	subq.w	#1,d0
	beq	priod_ed2
	dbra	d1,zerost
priod_e2:
	move.l	d0,d1
priod_el:
	bsr	a0getd0
	move.b	d0,(a1)+
	subq.w	#1,d1
	bne	priod_el
priod_ed2:
	clr.b	(a1)
	rts

*	sub 5
priod_set:
	move.l	d3,d0
	swap	d0
	btst.l	#sharp,d4		. #�Ȃ�(.)���Z�b�g
	bne	priset
	tst.w	d0
	ble	priod_end
priset:
	move.b	#'.',(a1)+
	subq.w	#1,d0
	bmi	priod_end
	movem.l	d1,-(sp)
	move.l	d0,d1
prccpy:
	bsr	a0getd0
	move.b	d0,(a1)+
	dbra	d1,prccpy
	movem.l	(sp)+,d1
priod_end:
	rts

*	sub 6
a0getd0:
	move.b	(a0)+,d0
	bne	a0endd0
	move.b	#'0',d0
	subq.l	#1,a0
a0endd0:
	rts

_fmtout_leng_get:
	movea.l	a0,a1			. ���P���f�[�^�E�g�b�v �A�h���X
d_strlen:
	tst.b	(a1)+			. �k������
	bne	d_strlen
	move.l	a1,d5			. �v���o�͕����������P �| ���O �| �P
	sub.l	a0,d5
	subq.l	#1,d5			. ���T���v���o�͕�����
	bra	_fmtout_directive

*****************************************
*	�P���� (c/C)			*
*****************************************

_fmtout_char:
	cmp.w	#-1,d3
	bne	cwidndef
	move.w	#1,d3			. width
cwidndef:
	swap	d3
	cmp.w	#-1,d3
	bne	cprcndef
	move.w	#1,d3			. precision
cprcndef:
	swap	d3
	lea	3(a5),a0		. �f�[�^�A�h���X
	tst.l	(a5)+
	moveq.l	#1,d5			. �P�o�C�g�w��
	bra	_fmtout_directive

*****************************************
*	������ (s/S)			*
*****************************************

_fmtout_string:
	move.l	(a5)+,d0		. �f�[�^�A�h���X
	bmi	eofmsp
	bne	_strlck
	move.l	#nullms,d0
	bra	_strlck
eofmsp:
	move.l	#eofms,d0

*****************************************
*	�f�[�^���l��			*
*****************************************

_strlck:
	move.l	d0,a0
	movea.l	a0,a1			. ���P �� �f�[�^�E�g�b�v �A�h���X
_strlen:
	tst.b	(a1)+			. �k������
	bne	_strlen
	move.l	a1,d5			. �v���o�͕����� �� ���P �| ���O �| �P
	sub.l	a0,d5
	subq.l	#1,d5			. ���T �� �v���o�͕�����
	cmp.w	#-1,d3
	bne	swidndef
	clr.w	d3			. width
swidndef:
	swap	d3
	cmp.w	#-1,d3
	bne	sprcndef
	move.w	d5,d3			. precision
sprcndef:
	cmp.w	d3,d5
	bcs	_string_non_prec
	move.w	d3,d5
_string_non_prec:
	swap	d3
	bra	_fmtout_directive

*****************************************
*	�P�O�i���ϊ����� (d/D i/D)	*
*****************************************

*****************************************
*	�����E���� ����			*
*****************************************

_fmtout_dec:
	move.l	a3,-(sp)
	lea	-34(sp),sp
	move.l	sp,a0
	move.l	(a5)+,d1		. ���P����������������
	btst.l	#shrtflg,d4
	beq	_dec_no_short
	cmpi.b	#'u',d0
	bne	_dec_sign_short
	and.l	#$0000ffff,d1
	bra	_dec_no_short
_dec_sign_short:
	ext.l	d1
_dec_no_short:
	clr.l	d5
	cmpi.b	#'u',d0			. �����`�F�b�N
	beq	_fmt_dec_set
	tst.l	d1
	bmi	_fmt_dec_mi
	btst.l	#signflg,d4		. '�{' �����w��
	bne	_fmt_dec_pl
	btst.l	#spacef,d4
	beq	_fmt_dec_set
	move.b	#' ',(a3)+
	bra	_fmt_dec_set2
_fmt_dec_pl:
	move.b	#'+',(a3)+
	bra	_fmt_dec_set2
_fmt_dec_mi:
	move.b	#'-',(a3)+
	neg.l	d1			. �����ϊ�
_fmt_dec_set2:
	addq.l	#1,d5
_fmt_dec_set:
	tst.l	d1
	beq	_fmtout_dec_zero

*****************************************
*	�[���E�T�v���X			*
*****************************************

	lea	table,a1
_fmtout_unsgn_loop0:
	move.l	(a1)+,d0		. ���O������
	cmp.l	d0,d1			. ���O�F���P
	bcs	_fmtout_unsgn_loop0

*****************************************
*	�P�O�i���֕ϊ�			*
*****************************************

_fmtout_unsgn_loop1:
	moveq.l	#'0'-1,d2
_fmtout_unsgn_loop2:
	addq.b	#1,d2
	sub.l	d0,d1			. d1 = d1 - d0
	bcc	_fmtout_unsgn_loop2	. �J��Ԃ�
	add.l	d0,d1
	move.b	d2,(a0)+
	move.l	(a1)+,d0
	bne	_fmtout_unsgn_loop1
_fmt_dec_end:
	clr.b	(a0)
	move.l	sp,a0
	moveq.l	#-1,d1
_dec_len:
	addq.w	#1,d1
	tst.b	(a0)+
	bne	_dec_len
	move.l	sp,a0
	bra	_fmt_hex_end

*****************************************
*	�[�� �Z�b�g			*
*****************************************

_fmtout_dec_zero:
	move.b	#'0',(a0)+		. �[���Z�b�g
	bra	_fmt_dec_end

*****************************************
*	�Q�i���\���G���g�� (b/B)	*
*****************************************

_fmtout_bin:
	move.l	#$00010001,d1		. �R���g���[���E���W�X�^ �Z�b�g
	bra	_cnv17f

*****************************************
*	�W�i���\���G���g�� (o/O)	*
*****************************************

_fmtout_oct:
	move.l	#$00030007,d1		. �R���g���[���E���W�X�^ �Z�b�g
	bra	_cnv17f

*****************************************
*	�|�C���^�\���G���g�� (p/P)	*
*****************************************

_fmtout_ptr:
	move.l	#$0008000a,d3		. %#10.8lx �܂��� %#10.8lX
	and.l	#$08000000,d4
	or.l	#$b4800000,d4

*****************************************
*	�P�U�i���\���G���g�� (x/X)	*
*****************************************

_fmtout_hex:
	move.l	#$0004000f,d1		. �R���g���[���E���W�X�^ �Z�b�g

*****************************************
*	�Q�E�W�E�P�U�i���ϊ�����	*
*****************************************

_cnv17f:
	movem.l	a3,-(sp)
	clr.l	d5

*****************************************
*	�i���L�q����			*
*****************************************

	bclr.l	#sharp,d4		. #
	beq	_fmt_xob
	move.b	#'0',(a3)+
	addq.w	#1,d5
	cmpi.w	#1,d1
	bne	_cnv17f_sharp_1
	move.b	#'b',(a3)+		. �Q�i��
	bra	_cnv17f_sharp_2

_cnv17f_sharp_1:
	cmpi.w	#$f,d1
	bne	_fmt_xob
	move.b	#'x',(a3)+		. �P�U�i��
_cnv17f_sharp_2:
	addq.w	#1,d5
	btst.l	#large,d4		. �啶���w��H
	beq	_fmt_xob
	sub.b	#'a'-'A',-1(a3)		. �啶���֕ϊ�
_fmt_xob:
	move.l	sp,a0
	lea	-34(sp),sp
	move.l	(a5)+,d0		. ���O���������������� ������
	btst.l	#shrtflg,d4
	beq	_hex_no_short
	and.l	#$0000ffff,d0
_hex_no_short:
	clr.b	-(a0)
	move.l	d0,d2			. ���Q���ҏW�l

	movem.l	d5,-(sp)
	clr.l	d5

*****************************************
*	�O ���� �X �� �A�X�L�[��	*
*****************************************

_cnv17f_loop:
	addq.l	#1,d5
	and.b	d1,d2			. �}�X�N ���P�����O�P�A���O�V�A���O��
	cmpi.b	#9,d2
	bgt	_cnv17f_alpha		. d2 > 9
	add.b	#'0',d2			. ascii numeric
	bra	_cnv17f_set

*****************************************
*    �P�O ���� �P�T �� �A�X�L�[��       *
*****************************************

_cnv17f_alpha:
	add.b	#'A'-10,d2		. LARGE 'A' - 'F'
	btst.l	#large,d4		. LARGE or SMALL
	bne	_cnv17f_set
	add.b	#'a'-'A',d2		. SMALL 'A' - 'F'

*****************************************
*	���̌��̎��o��		*
*****************************************

_cnv17f_set:
	move.b	d2,-(a0)		. �P�����Z�b�g
	swap	d1			. ���P���P�A�R�A�S
	lsr.l	d1,d0			. d0 = d0 / 2,8,16
	swap	d1
	move.l	d0,d2			. ���Q �� �ҏW�l
	bne	_cnv17f_loop
	move.l	d5,d1
	movem.l	(sp)+,d5
_fmt_hex_end:
	cmp.w	#-1,d3
	bne	dwidndef
	move.w	#1,d3			. width
dwidndef:
	swap	d3
	cmp.w	#-1,d3
	bne	dprcndef
	move.w	#1,d3			. precision
dprcndef:
	move.w	d3,d0
	swap	d3
	sub.w	d1,d0
	ble	no_zero_st
	subq.w	#1,d0
zero_stl:
	move.b	#'0',(a3)+
	addq.l	#1,d5
	dbra	d0,zero_stl
no_zero_st:
	addq.l	#1,d5
	move.b	(a0)+,(a3)+
	bne	no_zero_st
	subq.l	#1,d5
	lea	34(sp),sp
	movem.l	(sp)+,a3
	move.l	a3,a0

*****************************************
*	�ҏW�f�[�^�o��			*
*****************************************

*****************************************
*	�p�f�B���O�����I��		*
*****************************************

_fmtout_directive:
	cmp.w	d3,d5
	bcs	_fmtout_width_exist
	move.w	d5,d3
_fmtout_width_exist:
	btst.l	#leftadj,d4		. ���l�߁H
	bne	_fmtout_directive1
	btst.l	#zeropad,d4		. �[���E�p�f�B���O�H
	beq	_fmtout_directve_padspc
	lea	zero,a1			. ���P������ '�O' �A�h���X
	move.b	(a0),d0
	cmp.b	#'0',d0			. 0x1af 0b101 0123
	beq	_fmtout_directve_hex
	cmp.b	#' ',d0			. space
	beq	_fmtout_directve_sign
	cmpi.b	#'+',d0			. '�{' �����t��
	beq	_fmtout_directve_sign
	cmpi.b	#'-',d0			. '�|' �����t��
	bne	_fmtout_directve_next

*****************************************
*	�����̏o��			*
*****************************************

_fmtout_directve_sign:
	bsr	output_device		. d3 = �c��o�C�g��
	tst.b	(a0)+			. �P�������X�V
	subq.w	#1,d5			. �v���������|�P
	bra	_fmtout_directve_next

_fmtout_directve_hex:
	move.b	1(a0),d0
	or.b	#$20,d0
	cmp.b	#'b',d0
	beq	_fmtout_directve_bin
	cmp.b	#'x',d0
	bne	_fmtout_directve_next
_fmtout_directve_bin:
	bsr	output_device		. d3 = �c��o�C�g��
	tst.b	(a0)+			. �P�������X�V
	subq.w	#1,d5			. �v���������|�P
	bsr	output_device		. d3 = �c��o�C�g��
	tst.b	(a0)+			. �P�������X�V
	subq.w	#1,d5			. �v���������|�P
	bra	_fmtout_directve_next

_fmtout_directve_padspc:
	lea	space,a1		. ���P������ '�@' �A�h���X

*****************************************
*	���p�f�B���O����		*
*****************************************

_fmtout_directve_next:
	cmp.w	d3,d5			. �����������F������������
	bcc	_fmtout_directive1	. ���������� ���� ������������
_fmtout_padchar_left:
	exg.l 	a1,a0  			. �p�b�f�B���O�����A�h���X
_fmtout_padchar_left_1:
	bsr	output_device		. ������o��
	cmp.w	d3,d5			. �����������F������������
	bcs	_fmtout_padchar_left_1	. ���������� ��������������
	exg.l	a1,a0

*****************************************
*	�w��f�[�^�̏o��		*
*****************************************

_fmtout_directive1:
	tst.w	d5
	beq	_fmtout_padchar_right
	bsr	output_device		. ������o��
	tst.b	(a0)+
	tst.w	d3			. d3 = �c��o�C�g��
	ble	_fmtout_directive_ext
	subq.w	#1,d5			. �v���������|�P
	bne	_fmtout_directive1

*****************************************
*	�E�p�f�B���O����		*
*****************************************

_fmtout_padchar_right:
	tst.w	d3			. d3 = �c��o�C�g��
	ble	_fmtout_directive_ext
	lea	space,a0		. ���P �� ���� �f�@�f�A�h���X
_fmtout_padchar_right_1:
	bsr	output_device		. ������o��
	bne	_fmtout_padchar_right_1	. ���������� ��������������
_fmtout_directive_ext:
	rts				. return to _edtout

*****************************************
*	�w��P�����o��			*
*****************************************

*	�b�b�����R�|���O �̉��Z����

output_device:
	movem.l	d1-d5/d7/a0-a6,-(sp)
	move.b	(a0),d0
	andi.l	#$FF,d0			. output data
	movem.l	d0/d6,-(sp)
	jsr	(a6)
	movem.l	(sp)+,d0/d6
	movem.l	(sp)+,d1-d5/d7/a0-a6
	moveq.l	#1,d0			. output count
	add.l	d0,d7
	sub.w	d0,d3			. d3 = �c��o�C�g��
	rts

*****************************************
*	���ϊ�����			*
*****************************************

*****************************************
*	�ҏW�w��G���[���G���g��	*
*****************************************

_nconvx_0:
	clr.l	d4			. �R���g���[���E�t���O�N���A
	movea.l	a2,a4			. �󎚐擪�A�h���X����
	move.b	(a4)+,d0		. ���O���P������

*****************************************
*	�ҏW�w�薳�����G���g��		*
*****************************************

_nconvx:
	lea	-1(a4),a0		. ���O���f�[�^�E�o�b�t�@�擪

*****************************************
*	������I���ʒu�T�[�`		*
*****************************************

_nconvx_loop:
	move.b	(a4)+,d0		. �P���� ������
	beq	_nconvx_output		. '���O' ���o
	cmpi.b	#'%',d0			. '��' ���o
	bne	_nconvx_loop

*****************************************
*	�����񒷃Z�b�g			*
*****************************************

_nconvx_output:
	tst.b	-(a4)			. �P�����o�b�N
	move.l	a4,d5
	sub.l	a0,d5			. ���T �� �v���o�͕�����
	move.w	d5,d3			. �v�h�c�s�g �� �k�d�m�f�s�g
	bra	_fmtout_directive

*****************************************
*	������� ���������� �ɕϊ�	*
*****************************************

_atoix:
	clr.l	d1			. ��ƃ��W�X�^�E�N���A

*****************************************
*	�����`�F�b�N			*
*****************************************

_atoix_loop:
	cmpi.b	#'0',d0
	bcs	_atoix_ext		.  d0 < '0'
	cmpi.b	#'9',d0
	bhi	_atoix_ext		.  d0 > '9'

*****************************************
*	�A�X�L�[����o�C�i����		*
*****************************************

	andi.w	#$000f,d0		. ascii ==> binary
	add.w	d1,d1			. d1 * 2
	add.w	d1,d0
	lsl.w	#2,d1			. (d1 * 2) * 4
	add.w	d0,d1			. d1 = d1 * 10 + d0
	move.b	(a4)+,d0		. ������ �f�d�s
	bne	_atoix_loop

*****************************************
*	�k�����o			*
*****************************************

	moveq.l	#-1,d1			. �m �������A�y ����������
	rts

*****************************************
*	�ϊ��l�Z�b�g			*
*****************************************

_atoix_ext:
	swap	d0			. ���O�i�����j��������
	move.w	d1,d0			. ���O�i�����j���ϊ��l
	clr.l	d1			. �y �������A�m ����������
	rts

*****************************************
*	�R���X�^���g�E�e�[�u��		*
*****************************************

	.even

*****************************************
*	�P�O�i���ϊ��p�e�[�u��		*
*****************************************

table:	dc.l	1000000000
	dc.l	100000000
	dc.l	10000000
	dc.l	1000000
	dc.l	100000
	dc.l	10000
	dc.l	1000
	dc.l	100
	dc.l	10
	dc.l	1
	dc.l	0			. ���������@��������

*****************************************
*	�����ҏW�p�f�[�^		*
*****************************************

space:	dc.b	' '			. �X�y�[�X�E�p�b�h�p
zero:	dc.b	'0'			. �[���E�p�b�h�p
crtn:	dc.b	$0d			. �b�q
dummy:	dc.b	$00			. �_�~�[
nullms:	dc.b	'(NULL)',0
eofms:	dc.b	'(ERROR)',0
	.even
