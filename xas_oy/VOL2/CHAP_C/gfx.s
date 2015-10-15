*	X-BASIC�p�G�t�F�N�g�n�O���t�B�b�N�֐�

	.include	doscall.mac
	.include	iocscall.mac
	.include	fdef.h
	.include	gmacro.h
*
*int_val	equ	$0002	*int�^�̈���
*ary1_c		equ	$0034	*char�^�P�����z��
*ary1_fic	equ	$0037	*���l�^�P�����z��
*int_ret	equ	$8001	*int�^�̖߂�l
*
	.xref	gandcolor
	.xref	gxorcolor
	.xref	gorcolor
	.xref	gaddcolor
	.xref	gsubcolor
	.xref	gmixcolor
	.xref	gnegate
	.xref	ghalftone
	.xref	gmonotone
	.xref	gmonotone2
	.xref	gmonotone2_hsv
	.xref	gmosaic
	.xref	gdefocus
	.xref	gmedian
	.xref	gaccent
	.xref	gdifferential
	.xref	glaplacian
	.xref	gsharp
	.xref	gdither
	.xref	gdither_bin
	.xref	gltom
	.xref	gltom2
	.xref	ggradfill
	.xref	ggradreplace
*
	.xref	hsvtorgb
	.xref	rgbtohsv
	.xref	ginitpalet_l
	.xref	ginitpalet_m
	.xref	ginitpalet_m2
	.xref	ginitpalet_s
	.xref	gnegatepalet
*
	.offset	0	*�X�^�b�N�t���[��
*
A6BUF:	.ds.l	1
RETADR:	.ds.l	1
ARGC:	.ds.w	1
ARG1:	.ds.b	10
ARG2:	.ds.b	10
ARG3:	.ds.b	10
ARG4:	.ds.b	10
ARG5:	.ds.b	10
ARG6:	.ds.b	10
ARG7:	.ds.b	10
ARG8:	.ds.b	10
ARG9:	.ds.b	10
*
	.offset	0	*�����o�b�t�@
*
TYPE:	.ds.w	1	*�^
FVAL:	.ds.l	1	*����
PVAL:			*�|�C���^�i�z��, ������j
LVAL:	.ds.w	1	*32�r�b�g��
WVAL:	.ds.b	1	*16�r�b�g��
BVAL:	.ds.b	1	*�W�r�b�g��
*
	.offset	0	*X-BASIC�̔z��
*
ADUMMY:	.ds.l	1
ADIM:	.ds.w	1	*������-1
ASIZ:	.ds.w	1	*�P�v�f�̃o�C�g��
ALEN:	.ds.w	1	*�v�f��-1
ADAT:			*�f�[�^�{��
*
	.text
	.even
*
information_table:
	.dc.l	dummy		*X-BASIC�N����
	.dc.l	dummy		*run
	.dc.l	dummy		*end
	.dc.l	dummy		*system,exit
	.dc.l	dummy		*BREAK,^C
	.dc.l	dummy		*^D
	.dc.l	dummy		*�\��
	.dc.l	dummy		*�\��
	.dc.l	token_table
	.dc.l	param_table
	.dc.l	exec_table
	.dc.l	0,0,0,0,0	*�\��
*
token_table:
	.dc.b	'gandcolor',0
	.dc.b	'gxorcolor',0
	.dc.b	'gorcolor',0
	.dc.b	'gaddcolor',0
	.dc.b	'gsubcolor',0
	.dc.b	'gmixcolor',0
	.dc.b	'gnegate',0
	.dc.b	'ghalftone',0
	.dc.b	'gmonotone',0
	.dc.b	'gmonotone2',0
	.dc.b	'gmonotone2_hsv',0
	.dc.b	'gmosaic',0
	.dc.b	'gdefocus',0
	.dc.b	'gmedian',0
	.dc.b	'gaccent',0
	.dc.b	'gdifferential',0
	.dc.b	'glaplacian',0
	.dc.b	'gsharp',0
	.dc.b	'gdither',0
	.dc.b	'gdither_bin',0
	.dc.b	'gltom',0
	.dc.b	'gltom2',0
	.dc.b	'ggradfill',0
	.dc.b	'ggradreplace',0
	.dc.b	'ginitpalet_l',0
	.dc.b	'ginitpalet_m',0
	.dc.b	'ginitpalet_m2',0
	.dc.b	'ginitpalet_s',0
	.dc.b	'gnegatepalet',0
	.dc.b	'hsvtorgb',0
	.dc.b	'rgbtohsv',0
	.dc.b	0		*�e�[�u���I�[
	.even
*
param_table:
	.dc.l	par_5	*gandcolor
	.dc.l	par_5	*gxorcolor
	.dc.l	par_5	*gorcolor
	.dc.l	par_5	*gaddcolor
	.dc.l	par_5	*gsubcolor
	.dc.l	par_5	*gmixcolor
	.dc.l	par_4	*gnegate
	.dc.l	par_4	*ghalftone
	.dc.l	par_4	*gmonotone
	.dc.l	par_4	*gmonotone2
	.dc.l	par_6	*gmonotone2_hsv
	.dc.l	par_5	*gmosaic
	.dc.l	par_4	*gdefocus
	.dc.l	par_4	*gmedian
	.dc.l	par_5	*gaccent
	.dc.l	par_4	*gdifferential
	.dc.l	par_4	*glaplacian
	.dc.l	par_4	*gsharp
	.dc.l	par_6	*gdither
	.dc.l	par_5	*gdither_bin
	.dc.l	par_4	*gltom
	.dc.l	par_4	*gltom2
	.dc.l	par_8	*ggradfill
	.dc.l	par_9	*ggradreplace
	.dc.l	par_0	*ginitpalet_l
	.dc.l	par_0	*ginitpalet_m
	.dc.l	par_0	*ginitpalet_m2
	.dc.l	par_0	*ginitpalet_s
	.dc.l	par_0	*gnegatepalet
	.dc.l	par_3	*hsvtorgb
	.dc.l	par_1a	*rgbtohsv
*
par_9:	.dc.w	int_val		*������int�X��
par_8:	.dc.w	int_val		*������int�W��
par_7:	.dc.w	int_val		*������int�V��
par_6:	.dc.w	int_val		*������int�U��
par_5:	.dc.w	int_val		*������int�T��
par_4:	.dc.w	int_val		*������int�S��
par_3:	.dc.w	int_val		*������int�R��
par_2:	.dc.w	int_val		*������int�Q��
par_1:	.dc.w	int_val		*������int�P��
par_0:	.dc.w	int_ret		*�߂�l��int
*
par_1a:	.dc.w	int_val		*������int�P��
	.dc.w	ary1_c		*������char�z��
	.dc.w	int_ret		*�߂�l��int
*
exec_table:
	.dc.l	x_gandcolor
	.dc.l	x_gxorcolor
	.dc.l	x_gorcolor
	.dc.l	x_gaddcolor
	.dc.l	x_gsubcolor
	.dc.l	x_gmixcolor
	.dc.l	x_gnegate
	.dc.l	x_ghalftone
	.dc.l	x_gmonotone
	.dc.l	x_gmonotone2
	.dc.l	x_gmonotone2_hsv
	.dc.l	x_gmosaic
	.dc.l	x_gdefocus
	.dc.l	x_gmedian
	.dc.l	x_gaccent
	.dc.l	x_gdifferential
	.dc.l	x_glaplacian
	.dc.l	x_gsharp
	.dc.l	x_gdither
	.dc.l	x_gdither_bin
	.dc.l	x_gltom
	.dc.l	x_gltom2
	.dc.l	x_ggradfill
	.dc.l	x_ggradreplace
	.dc.l	x_ginitpalet_l
	.dc.l	x_ginitpalet_m
	.dc.l	x_ginitpalet_m2
	.dc.l	x_ginitpalet_s
	.dc.l	x_gnegatepalet
	.dc.l	x_hsvtorgb
	.dc.l	x_rgbtohsv
*
*	������int�S�̊֐�
*
x_gnegate:
	lea.l	gnegate,a5
	bra	exec_4
x_ghalftone:
	lea.l	ghalftone,a5
	bra	exec_4
x_gmonotone:
	lea.l	gmonotone,a5
	bra	exec_4
x_gmonotone2:
	lea.l	gmonotone2,a5
	bra	exec_4
x_gdefocus:
	lea.l	gdefocus,a5
	bra	exec_4
x_gmedian:
	lea.l	gmedian,a5
	bra	exec_4
x_gdifferential:
	lea.l	gdifferential,a5
	bra	exec_4
x_glaplacian:
	lea.l	glaplacian,a5
	bra	exec_4
x_gsharp:
	lea.l	gsharp,a5
	bra	exec_4
x_gltom:
	lea.l	gltom,a5
	bra	exec_4
x_gltom2:
	lea.l	gltom2,a5
	bra	exec_4
*
*	������int�T�̊֐�
*
x_gandcolor:
	lea.l	gandcolor,a5
	bra	exec_5
x_gxorcolor:
	lea.l	gxorcolor,a5
	bra	exec_5
x_gorcolor:
	lea.l	gorcolor,a5
	bra	exec_5
x_gaddcolor:
	lea.l	gaddcolor,a5
	bra	exec_5
x_gsubcolor:
	lea.l	gsubcolor,a5
	bra	exec_5
x_gmixcolor:
	lea.l	gmixcolor,a5
	bra	exec_5
x_gmosaic:
	lea.l	gmosaic,a5
	bra	exec_5
x_gaccent:
	lea.l	gaccent,a5
	bra	exec_5
x_gdither_bin:
	lea.l	gdither_bin,a5
	bra	exec_5
*
*	������int�U�̊֐�
*
x_gdither:
	lea.l	gdither,a5
	bra	exec_6
x_gmonotone2_hsv:
	lea.l	gmonotone2_hsv,a5
	bra	exec_6
*
*	�O���f�[�V�����֌W
*
x_ggradfill:
	link	a6,#0
	lea.l	ggradfill,a5
	pea.l	temp
	move.w	ARG8+WVAL(a6),-(sp)
	move.w	ARG7+WVAL(a6),-(sp)
	bra	exec6
*
x_ggradreplace:
	link	a6,#0
	lea.l	ggradreplace,a5
	pea.l	temp
	move.w	ARG9+WVAL(a6),-(sp)
	move.w	ARG8+WVAL(a6),-(sp)
	move.w	ARG7+WVAL(a6),-(sp)
	bra	exec6
*
*	�p���b�g�֌W
*
x_ginitpalet_l:
	link	a6,#0
	lea.l	ginitpalet_l,a5
	bra	exec
x_ginitpalet_m:
	link	a6,#0
	lea.l	ginitpalet_m,a5
	bra	exec
x_ginitpalet_m2:
	link	a6,#0
	lea.l	ginitpalet_m2,a5
	bra	exec
x_ginitpalet_s:
	link	a6,#0
	lea.l	ginitpalet_s,a5
	bra	exec
x_gnegatepalet:
	link	a6,#0
	lea.l	gnegatepalet,a5
	bra	exec
*
*	�F�R�[�h�֌W
*
x_hsvtorgb:
	link	a6,#0
	move.w	ARG1+WVAL(a6),d0
	swap.w	d0
	move.b	ARG2+BVAL(a6),d0
	lsl.w	#8,d0
	move.b	ARG3+BVAL(a6),d0
	jsr	hsvtorgb
	andi.l	#$0000ffff,d0
	lea.l	retval(pc),a0
	move.l	d0,LVAL(a0)	*�߂�l
	moveq.l	#0,d0
	unlk	a6
	rts
*
x_rgbtohsv:
	link	a6,#0
	move.w	ARG1+WVAL(a6),d0
	movea.l	ARG2+PVAL(a6),a0

	cmpi.w	#3-1,ALEN(a0)	*�o�b�t�@�͂R�o�C�g�ȏ�K�v
	bcs	error3		*
	jsr	rgbtohsv
	lea.l	ADAT+3(a0),a0
	move.b	d0,-(a0)	*v
	lsr.w	#8,d0
	move.b	d0,-(a0)	*s
	swap.w	d0
	move.b	d0,-(a0)	*h
	bra	okretn
*
exec_6:
	link	a6,#0
exec6:	move.w	ARG6+WVAL(a6),-(sp)
	bra	exec5
*
exec_5:
	link	a6,#0
exec5:	move.w	ARG5+WVAL(a6),-(sp)
	bra	exec4
*
exec_4:
	link	a6,#0
exec4:	move.w	ARG4+WVAL(a6),-(sp)
	move.w	ARG3+WVAL(a6),-(sp)
	move.w	ARG2+WVAL(a6),-(sp)
	move.w	ARG1+WVAL(a6),-(sp)

	moveq.l	#-1,d1		*�O���t�B�b�N��ʂ�
	IOCS	_APAGE		*
	tst.b	d0		*�@����������Ă��邩�H
	bmi	error1

	moveq.l	#-1,d1		*��ʃ��[�h���擾
	IOCS	_CRTMOD		*(d0 = 12�`15...65536�F���[�h)
	cmpi.b	#12,d0		*
	bcs	error2		*
	cmpi.b	#15+1,d0	*
	bcc	error2		*

exec:	pea.l	(sp)		*�����󂯓n��

do:	suba.l	a1,a1		*�X�[�p�[�o�C�U���[�h��
	IOCS	_B_SUPER	*

	jsr	(a5)		*���s���[�`���{��
				*d0.l�͕ۑ������O��
	tst.l	d0
	bmi	done		*�ŏ�����X�[�p�[�o�C�U���[�h������

	movea.l	d0,a1		*���[�U�[���[�h�֕��A
	IOCS	_B_SUPER	*

okretn:	moveq.l	#0,d0		*����I��

done:	lea.l	retval(pc),a0	*
	move.l	d0,LVAL(a0)	*�߂�l

	unlk	a6
dummy:	rts
*
error1:	lea.l	errms1(pc),a1	*��ʂ�����������Ă��Ȃ�
	bra	error
error2:	lea.l	errms2(pc),a1	*65536�F���[�h�ł͂Ȃ�
	bra	error
error3:	lea.l	errms3(pc),a1	*�z��̑傫��������Ȃ�
error:	moveq.l	#1,d0
	bra	done
*
failsafe:
	DOS	_EXIT
*
retval:	.dc.w	0		*�߂�l�i�[�p
	.dc.l	0,0		*
*
errms1:	.dc.b	'��ʂ�����������Ă��܂���',0
errms2:	.dc.b	'���̊֐���65536�F���[�h�ł̂ݓ��삵�܂�',0
errms3:	.dc.b	'�z��̑傫�����s�\���ł�',0
	.even
*
	.bss
	.even
*
temp:	.ds.b	12*1024+100	*ggradfill, gradreplace�̃��[�N
*
	.end	failsafe
