*	glineのテスト用プログラム

	.include	doscall.mac
	.include	iocscall.mac
*
	.xref	gline
*	.xref	setcliprect
*
CR	equ	13
LF	equ	10
*
FPACK	macro	callno
	.dc.w	callno
	endm
*
__RAND		equ	$fe0e	*乱数（0～32767）
__IUSING	equ	$fe18	*整数→文字列変換
				*（桁数指定つき）
*
	.text
	.even
*
ent:
	lea.l	inisp,sp

	move.l	#$0010_0005,-(sp)
				*512x512,65536色に
	DOS	_CONCTRL	*　初期化

	clr.l	-(sp)		*スーパーバイザモードへ移行
	DOS	_SUPER		*

*	pea.l	window		*クリッピング
*	jsr	setcliprect	*　ウィンドウを
*	addq.l	#4,sp		*　設定する

	lea.l	argbuf,a1	*a1 = 引数受け渡し領域

	IOCS	_ONTIME		*開始時の時刻を得る
	move.l	d0,-(sp)	*

	move.w	#50000-1,d7	*50000本のランダムな線分を描く
loop:	bsr	setarg		*
	pea.l	(a1)		*
	jsr	gline		*
	addq.l	#4,sp		*
*IOCS	_LINE			*
	dbra	d7,loop		*

	IOCS	_ONTIME		*終了時の時刻を得る
	sub.l	(sp)+,d0	*d0 = ループの実行時間
	bpl	tskip2		*
	addi.l	#24*3600*100,d0	*

tskip2:	lea.l	temp,a0		*時間を
	moveq.l	#7,d1		*　10進７桁右詰めで
	FPACK	__IUSING	*　文字列に変換する

	bsr	conv		*1/100秒単位から秒単位へ
	pea.l	temp		*描画に要した
	DOS	_PRINT		*　時間を表示する
	pea.l	secmes		*
	DOS	_PRINT		*

	DOS	_EXIT

*
*	ランダムに始点/終点を決める
*
setarg:
	movea.l	a1,a0
	move.w	#4-1,d6
arglp:	FPACK	__RAND
	lsr.w	#6,d0	*0≦d0≦511
*lsr.w	#5,d0		*0≦d0≦1023
*subi.w	#256,d0		*-256≦d0≦767
	move.w	d0,(a0)+
	dbra	d6,arglp
	rts

*
*	1/100秒単位から１秒単位へ変換する（文字列レベル）
*
conv:
	lea.l	temp+7,a1
	lea.l	temp+8,a2
	moveq.l	#$20,d1
	moveq.l	#'0',d2
	clr.b	(a2)
	move.b	-(a1),-(a2)
	move.b	-(a1),d0
	cmp.b	d1,d0
	bne	skip1
	move.b	d2,d0
skip1:	move.b	d0,-(a2)
	move.b	#'.',-(a2)
	move.b	-(a2),d0
	cmp.b	d1,d0
	bne	skip2
	move.b	d2,(a2)
skip2:	rts
*
	.data
	.even
*
window:	.dc.w	128,128,511-128,511-128
argbuf:	.dc.w	0,0,0,0,63	*引数列
	.dc.w	$ffff		*ラインスタイル（IOCS用）
secmes:	.dc.b	' sec.',CR,LF,0
*
	.bss
	.even
*
temp:	.ds.b	10	*数値→文字列変換用
*
	.stack
	.even
*
	.ds.l	4096
inisp:
	.end	ent
