*	X-BASIC用エフェクト系グラフィック関数

	.include	doscall.mac
	.include	iocscall.mac
	.include	fdef.h
	.include	gmacro.h
*
*int_val	equ	$0002	*int型の引数
*ary1_c		equ	$0034	*char型１次元配列
*ary1_fic	equ	$0037	*数値型１次元配列
*int_ret	equ	$8001	*int型の戻り値
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
	.offset	0	*スタックフレーム
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
	.offset	0	*引数バッファ
*
TYPE:	.ds.w	1	*型
FVAL:	.ds.l	1	*実数
PVAL:			*ポインタ（配列, 文字列）
LVAL:	.ds.w	1	*32ビット数
WVAL:	.ds.b	1	*16ビット数
BVAL:	.ds.b	1	*８ビット数
*
	.offset	0	*X-BASICの配列
*
ADUMMY:	.ds.l	1
ADIM:	.ds.w	1	*次元数-1
ASIZ:	.ds.w	1	*１要素のバイト数
ALEN:	.ds.w	1	*要素数-1
ADAT:			*データ本体
*
	.text
	.even
*
information_table:
	.dc.l	dummy		*X-BASIC起動時
	.dc.l	dummy		*run
	.dc.l	dummy		*end
	.dc.l	dummy		*system,exit
	.dc.l	dummy		*BREAK,^C
	.dc.l	dummy		*^D
	.dc.l	dummy		*予備
	.dc.l	dummy		*予備
	.dc.l	token_table
	.dc.l	param_table
	.dc.l	exec_table
	.dc.l	0,0,0,0,0	*予備
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
	.dc.b	0		*テーブル終端
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
par_9:	.dc.w	int_val		*引数はint９個
par_8:	.dc.w	int_val		*引数はint８個
par_7:	.dc.w	int_val		*引数はint７個
par_6:	.dc.w	int_val		*引数はint６個
par_5:	.dc.w	int_val		*引数はint５個
par_4:	.dc.w	int_val		*引数はint４個
par_3:	.dc.w	int_val		*引数はint３個
par_2:	.dc.w	int_val		*引数はint２個
par_1:	.dc.w	int_val		*引数はint１個
par_0:	.dc.w	int_ret		*戻り値はint
*
par_1a:	.dc.w	int_val		*引数はint１個
	.dc.w	ary1_c		*引数はchar配列
	.dc.w	int_ret		*戻り値はint
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
*	引数がint４個の関数
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
*	引数がint５個の関数
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
*	引数がint６個の関数
*
x_gdither:
	lea.l	gdither,a5
	bra	exec_6
x_gmonotone2_hsv:
	lea.l	gmonotone2_hsv,a5
	bra	exec_6
*
*	グラデーション関係
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
*	パレット関係
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
*	色コード関係
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
	move.l	d0,LVAL(a0)	*戻り値
	moveq.l	#0,d0
	unlk	a6
	rts
*
x_rgbtohsv:
	link	a6,#0
	move.w	ARG1+WVAL(a6),d0
	movea.l	ARG2+PVAL(a6),a0

	cmpi.w	#3-1,ALEN(a0)	*バッファは３バイト以上必要
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

	moveq.l	#-1,d1		*グラフィック画面は
	IOCS	_APAGE		*
	tst.b	d0		*　初期化されているか？
	bmi	error1

	moveq.l	#-1,d1		*画面モードを取得
	IOCS	_CRTMOD		*(d0 = 12～15...65536色モード)
	cmpi.b	#12,d0		*
	bcs	error2		*
	cmpi.b	#15+1,d0	*
	bcc	error2		*

exec:	pea.l	(sp)		*引数受け渡し

do:	suba.l	a1,a1		*スーパーバイザモードへ
	IOCS	_B_SUPER	*

	jsr	(a5)		*実行ルーチン本体
				*d0.lは保存される前提
	tst.l	d0
	bmi	done		*最初からスーパーバイザモードだった

	movea.l	d0,a1		*ユーザーモードへ復帰
	IOCS	_B_SUPER	*

okretn:	moveq.l	#0,d0		*正常終了

done:	lea.l	retval(pc),a0	*
	move.l	d0,LVAL(a0)	*戻り値

	unlk	a6
dummy:	rts
*
error1:	lea.l	errms1(pc),a1	*画面が初期化されていない
	bra	error
error2:	lea.l	errms2(pc),a1	*65536色モードではない
	bra	error
error3:	lea.l	errms3(pc),a1	*配列の大きさが足りない
error:	moveq.l	#1,d0
	bra	done
*
failsafe:
	DOS	_EXIT
*
retval:	.dc.w	0		*戻り値格納用
	.dc.l	0,0		*
*
errms1:	.dc.b	'画面が初期化されていません',0
errms2:	.dc.b	'この関数は65536色モードでのみ動作します',0
errms3:	.dc.b	'配列の大きさが不十分です',0
	.even
*
	.bss
	.even
*
temp:	.ds.b	12*1024+100	*ggradfill, gradreplaceのワーク
*
	.end	failsafe
