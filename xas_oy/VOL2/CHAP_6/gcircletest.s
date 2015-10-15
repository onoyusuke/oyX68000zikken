*	gcircleのテスト用プログラム

	.include	doscall.mac
	.include	iocscall.mac
*
	.xref	gcircle
*	.xref	goval
*	.xref	gfillcircle
*	.xref	setcliprect
*
FPACK	macro	callno
	.dc.w	callno
	.endm
*
__RAND		equ	$fe0e
*
	.text
	.even
*
ent:
	lea.l	inisp,sp

	clr.l	-(sp)		*スーパーバイザモードへ
	DOS	_SUPER		*

				*512x512,65536
	move.l	#$0010_0005,-(sp)
	DOS	_CONCTRL	*画面初期化

*	pea	window		*クリッピングウィンドウの設定
*	jsr	setcliprect	*
*	addq.l	#4,sp		*

	lea.l	arg,a1		*a1 = 引数受け渡し領域
loop:	movea.l	a1,a0		*引数をセット
	FPACK	__RAND		*　中心x
	lsr.w	#6,d0		*
	move.w	d0,(a0)+	*
				*
	FPACK	__RAND		*　中心y
	lsr.w	#6,d0		*
	move.w	d0,(a0)+	*
				*
	FPACK	__RAND		*　半径（x方向半径）
	lsr.w	#7,d0		*
	move.w	d0,(a0)+	*
				*
*	FPACK	__RAND		*　y方向半径
*	lsr.w	#7,d0		*
*	move.w	d0,(a0)+	*
				*
	FPACK	__RAND		*　描画色
	move.w	d0,(a0)+	*

	pea.l	(a1)		*描画
	jsr	gcircle		*
*	jsr	goval		*
*	jsr	gfillcircle	*
	addq.l	#4,sp		*

	DOS	_KEYSNS		*キーが押されるまで
	tst.l	d0		*　繰り返す
	beq	loop		*

	DOS	_INKEY		*スペースが押されたら
	cmpi.b	#$20,d0		*　一時停止する
	bne	done		*
pause:	DOS	_INKEY		*
	cmpi.b	#$20,d0		*
	beq	loop		*

done:	move.w	#-1,-(sp)	*キーを読み捨てる
	DOS	_KFLUSH		*

	move.l	#$0010_0000,-(sp)	*width 96
	DOS	_CONCTRL	*画面再初期化
	DOS	_EXIT
*
	.data
	.even
*
arg:				*gcircle, govalの引数
	.dc.w	0,0,0,0,0
*
window:				*クリッピングウィンドウ
	.dc.w	32,32,255-32,255-32
*
	.stack
	.even
*
	.ds.l	4096
inisp:
	.end	ent
