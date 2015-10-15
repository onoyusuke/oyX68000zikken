*	クリッピングウィンドウの設定

	.include	iocscall.mac
	.include	gconst.h
*
	.xdef	setcliprect
	.xdef	cliprect
	.xdef	ucliprect
*
	.text
	.even
*
setcliprect:
ARGPTR	=	8
	link	a6,#0
	movem.l	d1-d4,-(sp)

	movea.l	ARGPTR(a6),a1	*a1=引数
	movem.w	(a1),d1-d4	*d1～d4に座標を取り出し
	IOCS	_WINDOW		*　IOCSに伝える
	tst.l	d0		*エラーなら
	bmi	retn		*　抜ける

	movem.w	d1-d4,cliprect	*クリッピングウィンドウの
				*　座標を覚えておく
	move.w	#$8000,d0	*$8000のゲタを履かせて
	add.w	d0,d1		*
	add.w	d0,d2		*
	add.w	d0,d3		*
	add.w	d0,d4		*
	movem.w	d1-d4,ucliprect	*　別に覚えておく

	moveq.l	#0,d0		*正常終了
retn:	movem.l	(sp)+,d1-d4
	unlk	a6
	rts
*
cliprect:
	.dc.w	0		*クリッピング領域
	.dc.w	0		*
	.dc.w	GNPIXEL-1	*
	.dc.w	GNPIXEL-1	*
ucliprect:
	.dc.w	$8000		*クリッピング領域
	.dc.w	$8000		*（$8000のゲタ履き）
	.dc.w	$8000+GNPIXEL-1	*
	.dc.w	$8000+GNPIXEL-1	*

	.end
