*	gxputの動作試験用プログラム

	.include	doscall.mac
	.include	iocscall.mac
*
	.xref	gxput
*	.xref	gxputon
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

	lea.l	arg0,a1		*画面からパターンを取り込む
	IOCS	_GETGRM		*

*	pea	window		*クリッピングウィンドウの設定
*	jsr	setcliprect	*
*	addq.l	#4,sp		*

	moveq.l	#14,d1		*256x256,65536
	IOCS	_CRTMOD		*画面初期化
	IOCS	_G_CLR_ON	*

	lea.l	arg,a1		*a1 = 引数受け渡し領域
loop:	movea.l	a1,a0		*乱数で描画範囲を決める
	moveq.l	#4-1,d1		*
loop2:	FPACK	__RAND		*
	lsr.w	#7,d0		*0≦d0≦255
	move.w	d0,(a0)+	*
	dbra	d1,loop2	*

	pea.l	(a1)		*描画
	jsr	gxput		*
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
HSIZE	equ	128
VSIZE	equ	128
*
arg:				*gxputの引数
	.dc.w	0,0,511,511
	.dc.l	pat
	.dc.w	HSIZE-1,VSIZE-1
	.dc.l	temp
*
arg0:				*IOCS GETGRMの引数
	.dc.w	256-HSIZE/2,256-VSIZE/2
	.dc.w	255+HSIZE/2,255+VSIZE/2
	.dc.l	pat
	.dc.l	pate
*
window:				*クリッピングウィンドウ
	.dc.w	32,32,255-32,255-32
*
	.bss
	.even
*
pat:	.ds.w	HSIZE*VSIZE	*描画パターン
pate:
temp:	.ds.w	512*3		*gxputのワーク
*
	.stack
	.even
*
	.ds.l	4096
inisp:
	.end	ent
