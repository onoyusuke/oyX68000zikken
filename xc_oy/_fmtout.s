*************************************************************************
*_fmtout：指定関数へ編集出力						*
*	int		_fmtout(func,stream,format,arg);		*
*	int		(*func)();					*
*	FILE		*stream;					*
*	const char	*format;					*
*	va_list		arg;						*
*************************************************************************
* Copyright 1990 SHARP/Hudson		(1990/05/05)			*

*****************************************
*	コントロール・フラグ		*
*****************************************

leftadj	equ	31			. 左詰めフラグ
signflg	equ	30			. 符号付きフラグ
precflg	equ	29			. 小数部有りフラグ
longflg	equ	28			. ｌｏｎｇ ｉｎｔｅｇｅｒフラグ
large	equ	27			. 大文字フラグ
zeropad	equ	26			. ゼロ・パディングフラグ
endflg	equ	25			. 終了フラグ
aster	equ	24			. ＊指定
sharp	equ	23			. ＃指定
spacef	equ	22			. space指定
shrtflg	equ	21			. ｓｈｏｒｔ ｉｎｔｅｇｅｒフラグ

*****************************************
*	コントロール・コード		*
*****************************************

CR	equ	$0d			. 復帰コード
LF	equ	$0a			. 改行コード

	xdef	__fmtout

	xref	_ecvt
	xref	_fcvt

	include	stdio.mac
	include	fefunc.h

*****************************************
*	スタック・エリア		*
*****************************************

	.offset	0
tbuff	ds.b	620			. 作業バッファ
savreg	ds.l	9			. レジスタ・セーブ領域
rtnadr	ds.l	1			. 復帰アドレス
outent	ds.l	1			. 出力プログラムエントリ
device	ds.l	1			. 出力先指定
format	ds.l	1			. 出力フォーマット位置
argtop	ds.l	1			. 出力引数先頭位置セット

	.text
__fmtout:
	movem.l	d3-d7/a3-a6,-(sp)	. 作業レジスタ・セーブ
	lea	-620(sp),sp		. 作業バッファ確保
	movea.l	outent(sp),a6		. ａ６＝出力プログラムエントリ
	move.l	device(sp),d6		. ｄ６＝出力先指定
	movea.l	format(sp),a4		. ａ４＝出力フォーマット位置
	movea.l	argtop(sp),a5		. ａ５＝出力引数先頭位置セット
	clr.l	d7			. ｄ７＝出力文字数累計

_fmtout_loop:
	clr.l	d4			. ｄ４＝フラグ領域初期化
	clr.l	d5			. ｄ５＝要求出力文字数クリア
	lea	8(sp),a3		. ａ３＝作業バッファ
	bsr	_edtout			. 編集処理
	btst.l	#endflg,d4		. 終了？
	beq	_fmtout_loop
*					. 出力無し
_fmtout_end:
	lea	620(sp),sp		. 作業バッファ返却
	move.l	d7,d0			. リターン値 ＝ 出力文字数累計
	movem.l	(sp)+,d3-d7/a3-a6	. 作業レジスタ・リカバリ
	rts				. 呼び出し元へ復帰

*****************************************
*	編集処理			*
*****************************************

_edtout:
	move.b	(a4)+,d0		. １文字取り出し
	bne	_edtout_nex
	bset.l	#endflg,d4		. 編集終了フラグオン
	bra	_edtout_ext		. 編集終了

_edtout_nex:
	movea.l	a4,a2			. ａ２＝ａ４ 一時退避
	cmpi.b	#'%',d0			. 変換指定？
	bne	_not_cnv		. 無変換
	bsr	_convx			. 変換処理
	bra	_edtout_ext

_not_cnv:
	bsr	_nconvx			. 無変換処理
_edtout_ext:
	rts

*****************************************
*	変換処理			*
*****************************************

_convx:
	move.b	(a4)+,d0		. １文字ＧＥＴ
	bne	_parameter_get
	bset.l	#endflg,d4		. 終了フラグ・オン
	rts

*****************************************
*	変換パラメータＧＥＴ		*
*****************************************

_parameter_get:
	cmpi.b	#'-',d0			. 左詰め編集？
	bne	no_left
	bset.l	#leftadj,d4		. 左詰めフラグ・オン
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
	moveq.l	#-1,d3			. ｄ３＝ＰＲＥＣＩＳＮ／ＷＩＤＴＨ
	cmpi.b	#'0',d0			. ＺＥＲＯ詰め編集？
	bne	check_aster
	bset.l	#zeropad,d4		. '０' パディングフラグ・オン
	bra	width_set		. skip_sign

check_aster:
	cmpi.b	#'*',d0			. ＊指定
	bne	width_set
	move.l	(a5)+,d1
	bpl	_width_plus
	neg.l	d1
	bset.l	#leftadj,d4
_width_plus:
	move.w	d1,d3			. ＷＩＤＴＨ再設定
	move.b	(a4)+,d0		. １文字ＧＥＴ
	beq	_nconvx_0
	bra	prechk

*****************************************
*	ＷＩＤＴＨ獲得			*
*****************************************

width_set:
	cmp.b	#'0',d0
	bcs	prechk
	cmp.b	#'9',d0
	bhi	prechk
	bsr	_atoix
	bmi	_nconvx_0
	move.w	d0,d3			. ｄ０＝ＷＩＤＴＨ

*****************************************
*	ＰＲＥＣＩＳＮ獲得		*
*****************************************

	swap	d0

prechk:
	cmpi.b	#'.',d0			. 小数点？
	bne	_long_direc
	bset.l	#precflg,d4		. 小数点フラグオン
	move.b	(a4)+,d0
	beq	_nconvx_0

	cmpi.b	#'*',d0			. ＊指定
	bne	prechk2
	move.l	(a5)+,d1
	bpl	_prec_plus
	neg.l	d1
	bset.l	#leftadj,d4
_prec_plus:
	swap	d3
	move.w	d1,d3			. ＰＲＥＣＩＳＮ再設定
	swap	d3			. ｄ３＝ＰＲＥＣＩＳＮ／ＷＩＤＴＨ
	move.b	(a4)+,d0		. １文字ＧＥＴ
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
	swap	d3			. ｄ３＝ＰＲＥＣＩＳＮ／ＷＩＤＴＨ
	swap	d0			. ｄ０＝次文字

*****************************************
*	ｌｏｎｇ ｉｎｔｅｇｅｒ 検査	*
*****************************************

_long_direc:
	cmpi.b	#'l',d0			. ｌｏｒＬ指定？
	beq	_long_set
	cmpi.b	#'L',d0
	beq	_long_set
	cmpi.b	#'h',d0			. ｈｏｒＨ指定？
	beq	_short_set
	cmpi.b	#'H',d0
	bne	_large_chk

_short_set:
	bset.l	#shrtflg,d4		. ｓｈｏｒｔフラグセット
	bra	_long_short

_long_set:
	bset.l	#longflg,d4		. ｌｏｎｇフラグセット
_long_short:
	move.b	(a4)+,d0		. １文字ＧＥＴ
	beq	_nconvx_0

*****************************************
*	大文字検査			*
*****************************************

_large_chk:
	cmpi.b	#'A',d0
	bcs	_nconvx_0		. 無変換処理
	cmpi.b	#'Z',d0
	bhi	_comand_chk
	bset.l	#large,d4		. 大文字フラグセット

*****************************************
*	大文字から小文字へ変換		*
*****************************************

	add.b	#'a'-'A',d0		. 小文字へ変換
	bra	_conv_chk

*****************************************
*	変換コマンド検査		*
*****************************************

_comand_chk:
	cmpi.b	#'a',d0
	bcs	_nconvx_0		. 無変換処理
	cmpi.b	#'z',d0
	bhi	_nconvx_0		. 無変換処理
_conv_chk:
	cmpi.b	#'b',d0
	bcs	_nconvx_0		. 無変換処理
	cmpi.b	#'c',d0
	bcs	_fmtout_bin		. ２進数表示 (b/B)
	cmpi.b	#'d',d0
	bcs	_fmtout_char		. １文字表示 (c/C)
	cmpi.b	#'e',d0
	bcs	_fmtout_dec		. 符号付き１０進整数表示 (d/D)
	cmpi.b	#'h',d0
	bcs	_fmtout_float		. 浮動小数点表示 (e/E f/F g/G)
	cmpi.b	#'i',d0
	beq	_fmtout_dec		. 符号付き１０進整数表示 (i/I)
	cmpi.b	#'n',d0
	beq	_fmtout_chrlen		. 出力文字数の通知（変換処理ではない）
	cmpi.b	#'o',d0
	beq	_fmtout_oct		. ８進数表示 (o/O)
	cmpi.b	#'p',d0
	beq	_fmtout_ptr		. ポインタの１６進数表示
	cmpi.b	#'s',d0
	beq	_fmtout_string		. 文字列表示 (s/S)
	cmpi.b	#'u',d0
	beq	_fmtout_dec		. 符号無し１０進整数表示 (u/U)
	cmpi.b	#'x',d0
	beq	_fmtout_hex		. １６進数表示 (x/X)
	bra	_nconvx_0		. 無変換処理

*****************************************
*	出力文字数の通知(n/N)		*
*****************************************

_fmtout_chrlen:
	move.l	(a5)+,a0
	move.l	d7,(a0)			. 出力文字数累計
	rts

*****************************************
*	浮動小数点(f/F e/E g/G)		*
*****************************************

_fmtout_float:
	clr.l	d2
	move.b	d0,d2
	move.l	(a5)+,d0		. ｄ０＝浮動小数点上位ワード
	move.l	(a5)+,d1		. ｄ１＝浮動小数点下位ワード
	cmpi.b	#'g',d2			. (g/G) 変換？
	beq	_fmtout_float_g
	cmpi.b	#'f',d2			. (f/F) 変換？
	beq	_fmtout_float_f
*					. (e/E) 変換
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
	lea	1(a3),a0		. ａ０＝作業領域アドレス
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

*					. (f/F) 変換
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
	jsr	_fcvt			. Ｆ 変換 ＣＡＬＬ
	lea	20(sp),sp
	movem.l	(sp)+,d1-d2		. d1=decpt,d2=sign
	move.l	d0,a0			. d0=ascii data
	bsr	fcnv_st
	bra	_fmtout_float_leng

*					. (g/G) 変換
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
	jsr	_fcvt			. Ｆ 変換 ＣＡＬＬ
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
	btst.l	#sharp,d4		. #なら(0)の省略はなし
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
	btst.l	#sharp,d4		. #でないならなら(.)もカット
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
	jsr	_ecvt			. Ｅ 変換 ＣＡＬＬ
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
	btst.l	#large,d4		. 大文字フラグセット
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
	btst.l	#sharp,d4		. #なら(.)をセット
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
	btst.l	#sharp,d4		. #なら(.)をセット
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
	movea.l	a0,a1			. ａ１＝データ・トップ アドレス
d_strlen:
	tst.b	(a1)+			. ヌル検査
	bne	d_strlen
	move.l	a1,d5			. 要求出力文字数＝ａ１ － ａ０ － １
	sub.l	a0,d5
	subq.l	#1,d5			. ｄ５＝要求出力文字数
	bra	_fmtout_directive

*****************************************
*	１文字 (c/C)			*
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
	lea	3(a5),a0		. データアドレス
	tst.l	(a5)+
	moveq.l	#1,d5			. １バイト指定
	bra	_fmtout_directive

*****************************************
*	文字列 (s/S)			*
*****************************************

_fmtout_string:
	move.l	(a5)+,d0		. データアドレス
	bmi	eofmsp
	bne	_strlck
	move.l	#nullms,d0
	bra	_strlck
eofmsp:
	move.l	#eofms,d0

*****************************************
*	データ長獲得			*
*****************************************

_strlck:
	move.l	d0,a0
	movea.l	a0,a1			. ａ１ ＝ データ・トップ アドレス
_strlen:
	tst.b	(a1)+			. ヌル検査
	bne	_strlen
	move.l	a1,d5			. 要求出力文字数 ＝ ａ１ － ａ０ － １
	sub.l	a0,d5
	subq.l	#1,d5			. ｄ５ ＝ 要求出力文字数
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
*	１０進数変換処理 (d/D i/D)	*
*****************************************

*****************************************
*	正数・負数 検査			*
*****************************************

_fmtout_dec:
	move.l	a3,-(sp)
	lea	-34(sp),sp
	move.l	sp,a0
	move.l	(a5)+,d1		. ｄ１＝ａｒｇｍｅｎｔ
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
	cmpi.b	#'u',d0			. 符号チェック
	beq	_fmt_dec_set
	tst.l	d1
	bmi	_fmt_dec_mi
	btst.l	#signflg,d4		. '＋' 符号指定
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
	neg.l	d1			. 正数変換
_fmt_dec_set2:
	addq.l	#1,d5
_fmt_dec_set:
	tst.l	d1
	beq	_fmtout_dec_zero

*****************************************
*	ゼロ・サプレス			*
*****************************************

	lea	table,a1
_fmtout_unsgn_loop0:
	move.l	(a1)+,d0		. ｄ０＝減数
	cmp.l	d0,d1			. ｄ０：ｄ１
	bcs	_fmtout_unsgn_loop0

*****************************************
*	１０進数へ変換			*
*****************************************

_fmtout_unsgn_loop1:
	moveq.l	#'0'-1,d2
_fmtout_unsgn_loop2:
	addq.b	#1,d2
	sub.l	d0,d1			. d1 = d1 - d0
	bcc	_fmtout_unsgn_loop2	. 繰り返し
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
*	ゼロ セット			*
*****************************************

_fmtout_dec_zero:
	move.b	#'0',(a0)+		. ゼロセット
	bra	_fmt_dec_end

*****************************************
*	２進数表示エントリ (b/B)	*
*****************************************

_fmtout_bin:
	move.l	#$00010001,d1		. コントロール・レジスタ セット
	bra	_cnv17f

*****************************************
*	８進数表示エントリ (o/O)	*
*****************************************

_fmtout_oct:
	move.l	#$00030007,d1		. コントロール・レジスタ セット
	bra	_cnv17f

*****************************************
*	ポインタ表示エントリ (p/P)	*
*****************************************

_fmtout_ptr:
	move.l	#$0008000a,d3		. %#10.8lx または %#10.8lX
	and.l	#$08000000,d4
	or.l	#$b4800000,d4

*****************************************
*	１６進数表示エントリ (x/X)	*
*****************************************

_fmtout_hex:
	move.l	#$0004000f,d1		. コントロール・レジスタ セット

*****************************************
*	２・８・１６進数変換処理	*
*****************************************

_cnv17f:
	movem.l	a3,-(sp)
	clr.l	d5

*****************************************
*	進数記述処理			*
*****************************************

	bclr.l	#sharp,d4		. #
	beq	_fmt_xob
	move.b	#'0',(a3)+
	addq.w	#1,d5
	cmpi.w	#1,d1
	bne	_cnv17f_sharp_1
	move.b	#'b',(a3)+		. ２進数
	bra	_cnv17f_sharp_2

_cnv17f_sharp_1:
	cmpi.w	#$f,d1
	bne	_fmt_xob
	move.b	#'x',(a3)+		. １６進数
_cnv17f_sharp_2:
	addq.w	#1,d5
	btst.l	#large,d4		. 大文字指定？
	beq	_fmt_xob
	sub.b	#'a'-'A',-1(a3)		. 大文字へ変換
_fmt_xob:
	move.l	sp,a0
	lea	-34(sp),sp
	move.l	(a5)+,d0		. ｄ０＝ａｒｇｍｅｎｔ ｇｅｔ
	btst.l	#shrtflg,d4
	beq	_hex_no_short
	and.l	#$0000ffff,d0
_hex_no_short:
	clr.b	-(a0)
	move.l	d0,d2			. ｄ２＝編集値

	movem.l	d5,-(sp)
	clr.l	d5

*****************************************
*	０ から ９ を アスキーに	*
*****************************************

_cnv17f_loop:
	addq.l	#1,d5
	and.b	d1,d2			. マスク ｄ１＝＄０１、＄０７、＄０ｆ
	cmpi.b	#9,d2
	bgt	_cnv17f_alpha		. d2 > 9
	add.b	#'0',d2			. ascii numeric
	bra	_cnv17f_set

*****************************************
*    １０ から １５ を アスキーに       *
*****************************************

_cnv17f_alpha:
	add.b	#'A'-10,d2		. LARGE 'A' - 'F'
	btst.l	#large,d4		. LARGE or SMALL
	bne	_cnv17f_set
	add.b	#'a'-'A',d2		. SMALL 'A' - 'F'

*****************************************
*	次の桁の取り出し		*
*****************************************

_cnv17f_set:
	move.b	d2,-(a0)		. １文字セット
	swap	d1			. ｄ１＝１、３、４
	lsr.l	d1,d0			. d0 = d0 / 2,8,16
	swap	d1
	move.l	d0,d2			. ｄ２ ＝ 編集値
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
*	編集データ出力			*
*****************************************

*****************************************
*	パディング文字選択		*
*****************************************

_fmtout_directive:
	cmp.w	d3,d5
	bcs	_fmtout_width_exist
	move.w	d5,d3
_fmtout_width_exist:
	btst.l	#leftadj,d4		. 左詰め？
	bne	_fmtout_directive1
	btst.l	#zeropad,d4		. ゼロ・パディング？
	beq	_fmtout_directve_padspc
	lea	zero,a1			. ａ１＝文字 '０' アドレス
	move.b	(a0),d0
	cmp.b	#'0',d0			. 0x1af 0b101 0123
	beq	_fmtout_directve_hex
	cmp.b	#' ',d0			. space
	beq	_fmtout_directve_sign
	cmpi.b	#'+',d0			. '＋' 符号付き
	beq	_fmtout_directve_sign
	cmpi.b	#'-',d0			. '－' 符号付き
	bne	_fmtout_directve_next

*****************************************
*	符号の出力			*
*****************************************

_fmtout_directve_sign:
	bsr	output_device		. d3 = 残りバイト数
	tst.b	(a0)+			. １文字分更新
	subq.w	#1,d5			. 要求文字数－１
	bra	_fmtout_directve_next

_fmtout_directve_hex:
	move.b	1(a0),d0
	or.b	#$20,d0
	cmp.b	#'b',d0
	beq	_fmtout_directve_bin
	cmp.b	#'x',d0
	bne	_fmtout_directve_next
_fmtout_directve_bin:
	bsr	output_device		. d3 = 残りバイト数
	tst.b	(a0)+			. １文字分更新
	subq.w	#1,d5			. 要求文字数－１
	bsr	output_device		. d3 = 残りバイト数
	tst.b	(a0)+			. １文字分更新
	subq.w	#1,d5			. 要求文字数－１
	bra	_fmtout_directve_next

_fmtout_directve_padspc:
	lea	space,a1		. ａ１＝文字 '　' アドレス

*****************************************
*	左パディング処理		*
*****************************************

_fmtout_directve_next:
	cmp.w	d3,d5			. ｗｉｄｔｈ：ｌｅｎｇｔｈ
	bcc	_fmtout_directive1	. ｗｉｄｔｈ ＜＝ ｌｅｎｇｔｈ
_fmtout_padchar_left:
	exg.l 	a1,a0  			. パッディング文字アドレス
_fmtout_padchar_left_1:
	bsr	output_device		. 文字列出力
	cmp.w	d3,d5			. ｗｉｄｔｈ：ｌｅｎｇｔｈ
	bcs	_fmtout_padchar_left_1	. ｗｉｄｔｈ ＞ｌｅｎｇｔｈ
	exg.l	a1,a0

*****************************************
*	指定データの出力		*
*****************************************

_fmtout_directive1:
	tst.w	d5
	beq	_fmtout_padchar_right
	bsr	output_device		. 文字列出力
	tst.b	(a0)+
	tst.w	d3			. d3 = 残りバイト数
	ble	_fmtout_directive_ext
	subq.w	#1,d5			. 要求文字数－１
	bne	_fmtout_directive1

*****************************************
*	右パディング処理		*
*****************************************

_fmtout_padchar_right:
	tst.w	d3			. d3 = 残りバイト数
	ble	_fmtout_directive_ext
	lea	space,a0		. ａ１ ＝ 文字 ’　’アドレス
_fmtout_padchar_right_1:
	bsr	output_device		. 文字列出力
	bne	_fmtout_padchar_right_1	. ｗｉｄｔｈ ＞ｌｅｎｇｔｈ
_fmtout_directive_ext:
	rts				. return to _edtout

*****************************************
*	指定１文字出力			*
*****************************************

*	ＣＣ＝ｄ３－ｄ０ の演算結果

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
	sub.w	d0,d3			. d3 = 残りバイト数
	rts

*****************************************
*	無変換処理			*
*****************************************

*****************************************
*	編集指定エラー時エントリ	*
*****************************************

_nconvx_0:
	clr.l	d4			. コントロール・フラグクリア
	movea.l	a2,a4			. 印字先頭アドレス復元
	move.b	(a4)+,d0		. ｄ０＝１文字目

*****************************************
*	編集指定無し時エントリ		*
*****************************************

_nconvx:
	lea	-1(a4),a0		. ａ０＝データ・バッファ先頭

*****************************************
*	文字列終了位置サーチ		*
*****************************************

_nconvx_loop:
	move.b	(a4)+,d0		. １文字 ｇｅｔ
	beq	_nconvx_output		. '￥０' 検出
	cmpi.b	#'%',d0			. '％' 検出
	bne	_nconvx_loop

*****************************************
*	文字列長セット			*
*****************************************

_nconvx_output:
	tst.b	-(a4)			. １文字バック
	move.l	a4,d5
	sub.l	a0,d5			. ｄ５ ＝ 要求出力文字数
	move.w	d5,d3			. ＷＩＤＴＨ ＝ ＬＥＮＧＴＨ
	bra	_fmtout_directive

*****************************************
*	文字列を ｓｈｏｒｔ に変換	*
*****************************************

_atoix:
	clr.l	d1			. 作業レジスタ・クリア

*****************************************
*	数字チェック			*
*****************************************

_atoix_loop:
	cmpi.b	#'0',d0
	bcs	_atoix_ext		.  d0 < '0'
	cmpi.b	#'9',d0
	bhi	_atoix_ext		.  d0 > '9'

*****************************************
*	アスキーからバイナリへ		*
*****************************************

	andi.w	#$000f,d0		. ascii ==> binary
	add.w	d1,d1			. d1 * 2
	add.w	d1,d0
	lsl.w	#2,d1			. (d1 * 2) * 4
	add.w	d0,d1			. d1 = d1 * 10 + d0
	move.b	(a4)+,d0		. 次文字 ＧＥＴ
	bne	_atoix_loop

*****************************************
*	ヌル検出			*
*****************************************

	moveq.l	#-1,d1			. Ｎ ｓｅｔ、Ｚ ｒｅｓｅｔ
	rts

*****************************************
*	変換値セット			*
*****************************************

_atoix_ext:
	swap	d0			. ｄ０（ｈｗ）＝次文字
	move.w	d1,d0			. ｄ０（ｌｗ）＝変換値
	clr.l	d1			. Ｚ ｓｅｔ、Ｎ ｒｅｓｅｔ
	rts

*****************************************
*	コンスタント・テーブル		*
*****************************************

	.even

*****************************************
*	１０進数変換用テーブル		*
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
	dc.l	0			. ｓｔｏｐ　ｃｏｄｅ

*****************************************
*	内部編集用データ		*
*****************************************

space:	dc.b	' '			. スペース・パッド用
zero:	dc.b	'0'			. ゼロ・パッド用
crtn:	dc.b	$0d			. ＣＲ
dummy:	dc.b	$00			. ダミー
nullms:	dc.b	'(NULL)',0
eofms:	dc.b	'(ERROR)',0
	.even
