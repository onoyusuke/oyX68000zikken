*	gfillpolyの動作試験用プログラム

	.include	doscall.mac
	.include	edge.h
*
NMAXPOINT	equ	7	*頂点の最大数（2～32767）
NMAXEDGE	equ	NMAXPOINT*2+1	*辺の最大数
*
	.xref	gfillpoly
	.xref	gclippoly
	.xref	genedgelist
	.xref	setcliprect
*
FPACK	macro	callno
	.dc.w	callno
	.endm
*
__RAND		equ	$fe0e
*
	.offset	0
*
EDGES:	.ds.l	1	*辺リスト先頭アドレス
EDGEED:	.ds.l	1	*辺リスト最終アドレス
EDGARY:	.ds.l	1	*EDGBUFのポインタ配列用ワーク
COL:	.ds.l	1	*描画色
*
	.text
	.even
*
ent:
	lea.l	inisp,sp

	move.l	#$0010_0005,-(sp)	*512x512,65536
	DOS	_CONCTRL	*画面初期化

	clr.l	-(sp)		*スーパーバイザモードへ
	DOS	_SUPER		*

*	pea.l	window		*クリッピングウィンドウの設定
*	jsr	setcliprect	*
*	addq.l	#4,sp		*

	lea.l	arg,a1		*a1 = 引数受け渡し領域
loop:	bsr	setarg		*引数をセット

	pea.l	edges
	pea.l	pnts2
	pea.l	pnts
	jsr	gclippoly	*クリッピングして
	addq.l	#4,sp
	jsr	genedgelist	*辺リストを作成し
	addq.l	#8,sp
	move.l	a0,EDGEED(a1)	*辺リスト最終アドレス

	pea.l	(a1)		*描画
	jsr	gfillpoly	*
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
setarg:
	lea.l	pnts,a0
	move.w	#NMAXPOINT,(a0)+
	move.w	#NMAXPOINT*2-1,d1
arglp:	FPACK	__RAND
	lsr.w	#7,d0		*0≦d0≦255
	addi.w	#128,d0		*128≦d0≦383
*	lsr.w	#6,d0		*0≦d0≦511
	move.w	d0,(a0)+
	dbra	d1,arglp

	FPACK	__RAND
	move.w	d0,COL(a1)
	rts
*
	.data
	.even
*
arg:	.dc.l	edges		*gfillpolyへの引数
	.dc.l	edges		*
	.dc.l	edgary		*
	.dc.w	0		*描画色
*
window:	.dc.w	64,64,511-64,511-64
*
	.bss
	.even
*
pnts:	.ds.w	1		*クリッピング前の頂点
	.ds.l	NMAXPOINT
pnts2:	.ds.w	1		*クリッピング後の頂点
	.ds.l	NMAXEDGE	*
edges:	.ds.b	NMAXEDGE*EDGBUFSIZ	*EDGBUFの配列
edgary:	.ds.l	NMAXEDGE+1	*EDGBUFのポインタ配列
				*（番人の分を含む）
*
	.stack
	.even
*
	.ds.l	2048
inisp:
	.end	ent
