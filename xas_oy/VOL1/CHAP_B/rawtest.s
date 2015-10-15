*	RAWモードとCOOKEDモードの違いを見る
*
	.include	doscall.mac
	.include	const.h
	.include	driver.h
*
	.text
	.even
*
ent:
	lea.l	mysp,sp		*spの初期化

	move.w	#WOPEN,-(sp)	*CONを書き込みモードで
	pea.l	connam		*　オープンする
	DOS	_OPEN		*
	addq.l	#6,sp		*

	move.w	d0,d1		*d1=出力先

	move.w	#COOKED_MODE,d0	*COOKEDモードにして
	bsr	setmode		*
	bsr	out		*テストデータを出力

	move.w	#RAW_MODE,d0	*RAWモードにして
	bsr	setmode		*
	bsr	out		*テストデータを出力

	move.w	d1,-(sp)	*クローズ
	DOS	_CLOSE		*
	addq.l	#2,sp		*

	DOS	_EXIT

*
*	ファイルハンドルd1.wに
*	装置情報d0.wをセットする
*
setmode:
	move.w	d0,-(sp)	*装置情報
	move.w	d1,-(sp)	*ファイルハンドル
	move.w	#1,-(sp)
	DOS	_IOCTRL
	addq.l	#6,sp
	rts

*
*	ファイルハンドルd1.wに
*	mes以下のデータを出力する
*

meslen	=	mesend-mes

out:
	move.l	#meslen,-(sp)
	pea.l	mes
	move.w	d1,-(sp)
	DOS	_WRITE
	lea.l	10(sp),sp
	rts

*
*	データ
*
	.data
	.even
*
connam:	.dc.b	'CON',0
*
mes:	.dc.b	'12345678901234567890'
	.dc.b	'12345678901234567890'
*			：
	.dc.b	'12345678901234567890'
	.dc.b	'12345678901234567890'
	.dc.b	CR,LF
mesend:
*
	.stack
	.even
*
mystack:
	.ds.l	256		*スタック領域
mysp:
	.end
