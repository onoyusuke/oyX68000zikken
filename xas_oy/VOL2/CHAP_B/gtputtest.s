*	gtputの動作試験用プログラム

	.include	doscall.mac
	.include	iocscall.mac
*
	.xref	gtput
*	.xref	setcliprect
*
FPACK	macro	callno
	.dc.w	callno
	.endm
*
__RAND	equ	$fe0e
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

				*512x512,65536
	move.l	#$0010_0005,-(sp)
	DOS	_CONCTRL	*画面初期化

*	pea	window		*クリッピングウィンドウの設定
*	jsr	setcliprect	*
*	addq.l	#4,sp		*

	lea.l	arg,a1		*a1 = 引数受け渡し領域
loop:	pea.l	(a1)		*描画
	bsr	gtput		*
	addq.l	#4,sp		*

	movea.l	a1,a0		*引数をセット
	moveq.l	#8-1,d1		*４点分の座標
loop2:	FPACK	__RAND		*
	lsr.w	#6,d0		*0≦d0≦511
*	lsr.w	#5,d0		*0≦d0≦1023
*	subi.w	#256,d0		*-256≦d0≦767
	move.w	d0,(a0)+	*
	dbra	d1,loop2	*

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
arg:				*gtputの引数
	.dc.w	50,0,0,480,511,350,400,50
	.dc.l	pat
	.dc.w	HSIZE-1,VSIZE-1
*
arg0:				*IOCS GETGRMの引数
	.dc.w	256-HSIZE/2,256-VSIZE/2
	.dc.w	255+HSIZE/2,255+VSIZE/2
	.dc.l	pat
	.dc.l	pate
*
window:	.dc.w	64,64,511-64,511-64
*
	.bss
	.even
*
pat:	.ds.w	HSIZE*VSIZE	*描画パターン
pate:
*
	.stack
	.even
*
	.ds.l	4096
inisp:

	.end	ent
