*	点を打つテストプログラム

	.include	doscall.mac
	.include	iocscall.mac
*
	.xref	gramadr
*
CSCREEN		equ	16
DOS_GL3		equ	5
*
	.text
	.even
*
ent:
	lea.l	inisp(pc),sp	*spを初期化する

	move.w	#DOS_GL3,-(sp)	*画面を512x512,65536色に
	move.w	#CSCREEN,-(sp)	*　初期化
	DOS	_CONCTRL	*
	addq.l	#4,sp		*

	clr.l	-(sp)		*スーパーバイザモードへ
	DOS	_SUPER		*　移行
	move.l	d0,(sp)		*現在のsspを待避

	move.w	#256,d0		*x = 256
	move.w	#256,d1		*y = 256
	jsr	gramadr		*G-RAM上のアドレスを得る
	move.w	#65535,(a0)	*点を打つ

	DOS	_SUPER		*
	addq.l	#4,sp		*ユーザーモードへ復帰

	DOS	_EXIT		*終了
*
	.stack
	.even
*
	.ds.l	4096
inisp:
	.end	ent
