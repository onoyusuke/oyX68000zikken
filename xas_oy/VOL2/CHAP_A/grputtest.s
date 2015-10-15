*	grputの動作試験用プログラム

	.include	doscall.mac
	.include	iocscall.mac
*
	.xref	grput
*	.xref	setcliprect
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

	moveq.l	#1,d1		*d1 = 角度増分

	lea.l	arg,a1		*a1 = 引数受け渡し領域
loop:	pea.l	(a1)		*描画
	jsr	grput		*
	addq.l	#4,sp		*

	add.w	d1,8(a1)	*角度を増減する

	DOS	_KEYSNS		*キーが押されるまで
	tst.l	d0		*　繰り返す
	beq	loop		*

	neg.w	d1		*回転方向反転

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
arg:				*grputの引数
*	.dc.w	96,96,159,159	*縮小
	.dc.w	64,64,191,191	*等倍
*	.dc.w	32,32,223,223	*拡大
	.dc.w	0
	.dc.l	pat+(HSIZE*4)*(VSIZE/2)+(HSIZE/2)*2
	.dc.w	HSIZE-1,VSIZE-1
	.dc.l	temp
*
arg0:				*IOCS GETGRMの引数
	.dc.w	256-HSIZE,256-VSIZE
	.dc.w	255+HSIZE,255+VSIZE
	.dc.l	pat
	.dc.l	pate
*
window:	.dc.w	80,80,175,175
*
	.bss
	.even
*
pat:	.ds.w	HSIZE*VSIZE*4	*描画パターン
pate:
temp:	.ds.w	512*4		*grputのワーク
*
	.stack
	.even
*
	.ds.l	4096
inisp:
	.end	ent
