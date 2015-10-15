*	gfillの動作試験用プログラム

	.include	doscall.mac
*
	.xref	gfill
*
CSCREEN		equ	16
DOS_GL3		equ	5
*
	.text
	.even
*
ent:
	lea.l	inisp,sp	*spを初期化する

	move.w	#DOS_GL3,-(sp)	*画面を512x512,65536色に
	move.w	#CSCREEN,-(sp)	*　初期化
	DOS	_CONCTRL	*
	addq.l	#4,sp		*

	clr.l	-(sp)		*スーパーバイザモードへ
	DOS	_SUPER		*　移行
	move.l	d0,(sp)		*現在のsspを待避

	pea.l	arg		*引数列
	bsr	gfill		*描画
	addq.l	#4,sp		*

	DOS	_SUPER		*
	addq.l	#4,sp		*ユーザーモードへ復帰

	DOS	_EXIT		*終了
*
	.data
	.even
*
arg:	.dc.w	100,100,200,200,12345
*
	.stack
	.even
*
	.ds.l	4096
inisp:
	.end	ent
