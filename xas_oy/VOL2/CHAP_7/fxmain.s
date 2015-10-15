*	エフェクト系サブルーチン群のメインルーチン

	.include	doscall.mac
	.include	iocscall.mac
*
	.xref	gnegate
*
NARG	equ	4	*引数の個数
*
FPACK	macro	callno
	.dc.w	callno
	endm
*
__STOL	equ	$fe10	*10進文字列→数値変換
__STOH	equ	$fe12	*16進文字列→数値変換
__RAND	equ	$fe0e	*乱数（0～32767）
*
CR	equ	13
LF	equ	10
TAB	equ	9
SPACE	equ	32
*
STDERR	equ	2
*
	.text
	.even
*
ent:
	lea.l	inisp,sp

	bsr	getarg		*引数を取得する

	moveq.l	#-1,d1		*画面は初期化されているか？
	IOCS	_APAGE		*
	tst.b	d0		*
	bmi	error		*未初期化だった

	clr.l	-(sp)		*スーパーバイザモードへ移行する
	DOS	_SUPER		*

	pea.l	argbuf		*サブルーチンを呼び出す
	jsr	gnegate		*
*	addq.l	#4,sp		*

	DOS	_EXIT

*
*	NARG個の数値をバッファにセットする
*
getarg:
	tst.b	(a2)+		*空文字列なら
	beq	noarg		*　デフォルト値を採用

	movea.l	a2,a0		*a0 = コマンドライン
	lea.l	argbuf,a1	*a1 = 引数格納バッファ
	moveq.l #NARG-1,d1	*d1 = ループカウンタ
getpr0:	bsr	skipsp		*先行する空白を飛ばす
	move.b	(a0)+,d0	*文字列終端？
	beq	usage		*　そうなら引数が足りない
	cmpi.b	#'#',d0		*
	beq	codarg		*
	cmpi.b	#'?',d0		*
	beq	colarg		*
	cmpi.b	#'$',d0		*
	beq	hexarg		*
	subq.l	#1,a0		*
decarg:	FPACK	__STOL		*10進
	bra	argchk		*
colarg:	FPACK	__RAND		*0～65534の乱数
	add.w	d0,d0		*
	bra	argset		*
codarg:	FPACK	__RAND		*0～511の乱数
	lsr.w	#6,d0		*
	bra	argset		*
hexarg:	FPACK	__STOH		*16進
argchk:	bcs	usage		*うまく変換できなかった
argset:	move.w	d0,(a1)+	*引数を格納
	dbra	d1,getpr0	*必要なだけ繰り返す
noarg:	rts
*
skpsp0:	addq.l	#1,a0
skipsp:	cmpi.b	#SPACE,(a0)
	beq	skpsp0
	cmpi.b	#TAB,(a0)
	beq	skpsp0
	rts
*
usage:	lea.l	usgmes,a0
	bra	error0
*
error:	lea.l	errmes,a0
error0:	move.w	#STDERR,-(sp)	*標準エラー出力へ
	pea.l	(a0)		*　メッセージを出力する
	DOS	_FPUTS		*
	addq.l	#6,sp		*
	move.w	#1,-(sp)	*終了コード１を持って
	DOS	_EXIT2		*　エラー終了
*
	.data
	.even
*
argbuf:	.dc.w	0,0,511,511	*デフォルト引数
*
usgmes:	.dc.b	'機　能：画像の色を反転する',CR,LF
	.dc.b	'使用法：GNEGATE [x0 y0 x1 y1]',CR,LF,0
errmes: .dc.b	'グラフィック画面が初期化されていません',CR,LF,0
*
	.stack
	.even
*
mystack:
	.ds.l	4096		*スタック領域
inisp:

	.end	ent
