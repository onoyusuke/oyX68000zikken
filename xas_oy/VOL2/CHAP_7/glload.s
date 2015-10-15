*	簡易GL3ファイルローダ

	.include	doscall.mac
	.include	iocscall.mac
*
CR	equ	13
LF	equ	10
*
ROPEN	equ	0
STDERR	equ	2
*
SIZE	equ	512*1024
GRAMTOP	equ	$c00000
*
CSCREEN	equ	16
DOS_GL3	equ	5
*
CHKGRAM	equ	0
CHECK	equ	-1
BROKEN	equ	3
*
	.text
	.even
*
ent:
	lea.l	inisp(pc),sp	*spを初期化する

	moveq.l	#CHKGRAM,d1	*G-RAMは
	moveq.l	#CHECK,d2	*　使用可能か？
	IOCS	_TGUSEMD	*
	cmpi.b	#BROKEN,d0	*誰かが使いっぱなし？
	beq	gramok		*　そうなら使える
	tst.b	d0		*誰も使っていない？
	bne	rsrvd		*　誰かが使っていた

gramok:	tst.b	(a2)+		*ファイル名の指定はある？
	beq	usage		*　なかった

	move.w	#ROPEN,-(sp)	*ファイルを開く
	move.l	a2,-(sp)	*
	DOS	_OPEN		*
	addq.l	#6,sp		*
	move.w	d0,d3		*d3 = ファイルハンドル
	bmi	nfound		*

	move.w	#DOS_GL3,-(sp)	*画面を512x512,65536色に
	move.w	#CSCREEN,-(sp)	*　初期化
	DOS	_CONCTRL	*
	addq.l	#4,sp		*

	moveq.l	#CHKGRAM,d1	*G-RAM内容は
	moveq.l	#BROKEN,d2	*　私が壊しました
	IOCS	_TGUSEMD	*
*
	move.l	#SIZE,-(sp)	*ファイルからG-RAMに
	move.l	#GRAMTOP,-(sp)	*　直接読み込む
	move.w	d3,-(sp)	*
	DOS	_READ		*
	lea.l	10(sp),sp	*
	tst.l	d0		*
	bmi	reader		*

	move.w	d3,-(sp)	*ファイルを閉じる
	DOS	_CLOSE		*
	addq.l	#2,sp		*

	DOS	_EXIT		*正常終了

*
*	使用法の表示＆エラー終了
*
usage:	lea.l	usgmes(pc),a0
	bra	error
rsrvd:	lea.l	errms1(pc),a0
	bra	error
nfound:	lea.l	errms2(pc),a0
	bra	error
reader:	lea.l	errms3(pc),a0
	*
error:	move.w	#STDERR,-(sp)	*標準エラー出力へ
	move.l	a0,-(sp)	*　メッセージを
	DOS	_FPUTS		*　出力する
	addq.l	#6,sp		*
	*
	move.w	#1,-(sp)	*終了コード１を持って
	DOS	_EXIT2		*　エラー終了
*
	.data
	.even
*
usgmes:	.dc.b	'機　能：GL3ファイルをロードする',CR,LF
	.dc.b	'使用法：GLLOAD ファイル名.GL3',CR,LF,0
errms1:	.dc.b	'GLLOAD：G-RAMは他のプログラムが使用中です',CR,LF,0
errms2:	.dc.b	'GLLOAD：指定の画像ファイルが見つかりません',CR,LF,0
errms3:	.dc.b	'GLLOAD：画像ファイルが読み込めません',CR,LF,0
*
	.stack
	.even
*
	.ds.l	4096		*スタック領域
inisp:

	.end	ent
