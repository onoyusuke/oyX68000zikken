*	画像を重ね合わせてロードする

	.include	doscall.mac
	.include	iocscall.mac
	.include	gconst.h
*
	.xref	gputon
*
CR	equ	13
LF	equ	10
*
ROPEN	equ	0
STDERR	equ	2
*
MAXMEM	equ	GNBYTE*GNPIXEL
MINMEM	equ	GNBYTE
*
	.offset	0	*gputonの引数構造
*
X0:	.ds.w	1	*矩形領域
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
PAT:	.ds.l	1	*パターン
COL:	.ds.l	1	*透明色
*
	.text
	.even
*
ent:
	lea.l	inisp(pc),sp

	tst.b	(a2)+		*コマンド行引数はあるか？
	beq	usage		*　なければ使用法を表示して終了

	lea.l	16(a0),a0	*プログラムの後ろの余分なメモリを切り放す
	suba.l	a0,a1		*
	movem.l	a0-a1,-(sp)	*
	DOS	_SETBLOCK	*
	addq.l	#8,sp		*

	moveq.l	#-1,d1		*グラフィック画面は初期化されているか？
	IOCS	_APAGE		*
	tst.b	d0		*
	bmi	ninit		*未初期化ならエラー終了

	clr.l	-(sp)		*スーパーバイザモードへ移行
	DOS	_SUPER		*

	move.l	#MAXMEM,d1	*ファイル読み込み用のメモリを確保する
	move.w	#GNPIXEL,d2	*
	moveq.l	#1,d3		*
	move.l	#MINMEM,d4	*
memlp:	move.l	d1,-(sp)	*
	DOS	_MALLOC		*
	addq.l	#4,sp		*
	tst.l	d0		*
	bpl	memok		*
	lsr.l	#1,d1		*
	lsr.w	#1,d2		*
	add.w	d3,d3		*
	cmp.l	d4,d1		*
	bcc	memlp		*
	bra	nomem		*メモリ不足だった
*
memok:	movea.l	d0,a0
	move.w	d2,d4
	subq.w	#1,d2
	subq.w	#1,d3

*	a0 = ファイル読み込み用バッファ
*	a2 = ファイル名
*	d1 = 一度に処理するバイト数
*	d2 = 一度に処理するライン数－１
*	d3 = 分割回数－１（＝ループカウンタ）
*	d4 = 一度に処理するライン数

	lea.l	argbuf(pc),a1	*gputonへの引数の初期化
	clr.l	X0(a1)
	move.w	#GNPIXEL-1,X1(a1)
	move.w	d2,Y1(a1)
	move.l	a0,PAT(a1)
*
	move.w	#ROPEN,-(sp)	*ファイルオープン
	pea.l	(a2)		*
	DOS	_OPEN		*
	addq.l	#6,sp		*
	move.w	d0,d2		*d2 = ファイルハンドル
	bmi	nfound		*
*
	pea.l	2.w		*ファイル先頭の２バイトを読み込み
	pea.l	COL(a1)		*　透明色とする
	move.w	d2,-(sp)	*
	DOS	_READ		*
	lea.l	10(sp),sp	*
	subq.l	#2,d0		*
	bne	rerror		*
*
	move.w	d0,-(sp)	*ファイルを巻き戻す
	move.l	d0,-(sp)	*
	move.w	d2,-(sp)	*
	DOS	_SEEK		*
	addq.l	#8,sp		*
*
putlp:	move.l	d1,-(sp)	*ファイルから読み込む
	pea.l	(a0)		*
	move.w	d2,-(sp)	*
	DOS	_READ		*
	lea.l	10(sp),sp	*
	tst.l	d0		*
	bmi	rerror		*

	pea.l	(a1)		*描画
	jsr	gputon		*
	addq.l	#4,sp		*

	add.w	d4,Y0(a1)	*つぎの描画位置
	add.w	d4,Y1(a1)	*

	dbra	d3,putlp	*繰り返す

	DOS	_EXIT
*
usage:	lea.l	usgmes(pc),a0
	bra	error
ninit:	lea.l	errms1(pc),a0
	bra	error
nomem:	lea.l	errms2(pc),a0
	bra	error
nfound:	lea.l	errms3(pc),a0
	bra	error
rerror:	lea.l	errms4(pc),a0
	*
error:	move.w	#STDERR,-(sp)
	pea.l	(a0)
	DOS	_FPUTS

	move.w	#1,-(sp)
	DOS	_EXIT2
*
	.data
	.even
*
usgmes:	.dc.b	'機　能：GL3ファイルを重ね合わせロードする',CR,LF
	.dc.b	'使用法：GLOADON　ファイル名',CR,LF,0
errms1:	.dc.b	'GLOADON：G-RAMが初期化されていません',CR,LF,0
errms2:	.dc.b	'GLOADON：メモリ不足です',CR,LF,0
errms3:	.dc.b	'GLOADON：指定のファイルが見つかりません',CR,LF,0
errms4:	.dc.b	'GLOADON：ファイルがうまく読み込めません',CR,LF,0
*
	.bss
	.even
*
argbuf:	.ds.w	4	*矩形領域
	.ds.l	1	*パターン
	.ds.w	1	*透明色
*
	.stack
	.even
*
	.ds.l	4096
inisp:

	.end	ent
