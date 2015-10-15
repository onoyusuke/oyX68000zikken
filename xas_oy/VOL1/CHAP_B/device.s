*	デバイスドライバの組み込み状況を表示する
*
	.include	doscall.mac
	.include	const.h
	.include	driver.h
*
	.xref	itoh
*
PUTC	macro	chr		*１文字出力マクロ
	move.w	chr,-(sp)
	DOS	_PUTCHAR
	addq.l	#2,sp
	endm
*
PUTSP	macro			*スペース１個出力マクロ
	PUTC	#SPACE
	endm
*
PUTS	macro	strptr		*文字列出力マクロ
	pea.l	strptr
	DOS	_PRINT
	addq.l	#4,sp
	endm
*
NEWLIN	macro			*改行マクロ
	PUTS	crlfms
	endm
*
SELMES	macro	bit,str1,str2	*属性ビットに応じて
	local	skip,done	*　２種類の文字列の
	btst.l	#bit,d7		*　どちらかを表示するマクロ
	beq	skip
	PUTS	str1
	bra	done
skip:	PUTS	str2
done:
	endm
*
	.text
	.even
*
ent:
	lea.l	mysp,sp		*spの初期化

	clr.l	-(sp)		*スーパーバイザモードへ移行
	DOS	_SUPER		*
	move.l	d0,(sp)		*ssp待避

	bsr	chkarg		*コマンドラインの解析

	bsr	do		*メイン処理

	DOS	_SUPER		*ユーザーモードへ復帰
	addq.l	#4,sp		*

	DOS	_EXIT		*正常終了

*
*	メイン処理
*
do:
	bsr	seanul		*デバイスドライバリンクの
				*　先頭を探す
	tst.l	d1		*もし見つけられなければ
	bmi	error		*　エラー

	PUTS	title		*見出し表示

loop:	movea.l	d1,a0		*a0=デバイスドライバ先頭
	move.w	DEVATR(a0),d7	*d7.w=デバイス属性

	bsr	prtadr		*先頭アドレスを表示する
	bsr	prtnam		*デバイス名を表示する
	bsr	prtatr		*デバイス属性を表示する
	SELMES	IOCTRL_BIT,okmes,notmes
				*IOCTRL可/不可を表示する
	NEWLIN			*改行する

	move.l	DEVLNK(a0),d1	*d1=次のデバイスドライバ先頭
	cmpi.l	#-1,d1		*d1=-1であれば終了
	bne	loop		*そうでなければ繰り返す

	rts			*処理完了
*
HUMANST	equ	$6800		*Human68k先頭アドレス
NULATR	equ	$8024		*NULデバイスのデバイス属性
*
seanul:
	lea.l	nulnam,a0	*a0=検索デバイス名
	move.w	(a0)+,d0	*d0='NU'
	move.l	(a0)+,d1	*d1='L   '
	move.w	(a0)+,d2	*d2='  '

	lea.l	HUMANST,a0	*a0=Human先頭アドレス

seanl0:	cmp.w	(a0)+,d0	*先頭２文字を比較
	bne	seanl0		*一致するまで繰り返す
				*（デバイスヘッダは必ず
				*　偶数番地から始まる）
	cmp.l	(a0),d1		*真ん中４文字を比較
	bne	seanl0		*一致しなければやり直し

	cmp.w	4(a0),d2	*後半２文字を比較
	bne	seanl0		*一致しなければやり直し

	cmpa.l	nulnam+2,a0	*本当にNULデバイスかどうかの
	beq	notfound	*　チェック１

	cmp.w	#NULATR,DEVATR-DEVNAM-2(a0)	*チェック２
	bne	seanl0				*

	lea.l	DEVLNK-DEVNAM-2(a0),a0	*a0=デバイスドライバ先頭
	move.l	a0,d1			*d1=同上
	rts
notfound:
	moveq.l	#-1,d1		*NULデバイスが見つからなかった！？
	rts

*
*	デバイスドライバの先頭アドレスを表示する
*
prtadr:
	pea.l	temp		*アドレスを16進８桁に変換する
	move.l	a0,-(sp)	*
	bsr	itoh		*
	addq.l	#8,sp		*

	PUTS	temp+2		*下６桁のみを表示する

	PUTSP			*スペース出力
	rts

*
*	デバイス名を表示する
*
prtnam:
	lea.l	DEVNAM(a0),a1	*a1=デバイス名先頭
	moveq.l	#0,d1		*上位バイトをクリアしておく
	moveq.l	#8-1,d2		*デバイス名は８文字

prtnm0:	move.b	(a1)+,d1	*１文字取り出し
	cmpi.b	#SPACE,d1	*コントロールコードか？
	bcc	prtnm1		*そうでなければそのまま表示
	moveq.l	#'.',d1		*'.'に変換する
prtnm1:	PUTC	d1		*１文字出力
	dbra	d2,prtnm0	*繰り返す
	rts

*
*	デバイス属性を表示する
*
prtatr:
	btst.l	#ISCHRDEV_BIT,d7
	beq	prtat2

	PUTS	chrmes		*以下キャラクタデバイス用

	SELMES	ISRAW_BIT,rawmes,cokmes

	move.w	d7,d1

	lea.l	atrdat,a1
	moveq.l	#0,d2
	moveq.l	#4-1,d3
prtat0:	move.b	(a1)+,d2
	lsr.w	#1,d1
	bcs	prtat1
	moveq.l	#'-',d2
prtat1:	PUTC	d2
	dbra	d3,prtat0
	rts

prtat2:	PUTS	blkmes		*ブロックデバイスのとき
	rts

*
*	コマンドラインの解析
*
chkarg:
	addq.l	#1,a2		*a2=コマンドライン文字列先頭
	bsr	skipsp		*先頭のスペースを飛ばす
	tst.b	(a2)
	bne	usage
	rts

*
*	コマンドライン先頭のスペースをスキップする
*
skpsp0:	addq.l	#1,a2		*ポインタを進め
				*繰り返す
skipsp:				*サブルーチンはここから始まる
	cmpi.b	#SPACE,(a2)	*スペースか？
	beq	skpsp0		*　そうなら飛ばす
	cmpi.b	#TAB,(a2)	*TABか？
	beq	skpsp0		*　そうなら飛ばす
	rts

*
*	エラー終了/使用法の表示
*
usage:
	lea.l	usgmes,a0	*使用法メッセージ
	bra	errout
*
error:	lea.l	errmes,a0	*NULドライバがない
	*
errout:	move.w	#STDERR,-(sp)	*標準エラー出力へ
	move.l	a0,-(sp)	*　メッセージを
	DOS	_FPUTS		*　出力する
	addq.l	#6,sp		*

	move.w	#1,-(sp)	*終了コード１を持って
	DOS	_EXIT2		*　エラー終了

*
*	データ
*
	.data
	.even
*
*		 12345678
nulnam:	.dc.b	'NUL     '	*検索デバイス名
*
title:	.dc.b	' 開始  デバイス名       属性        IOCTRL',CR,LF
	.dc.b	'------ ---------- ----------------- ------',CR,LF,0
*		 12345678901234567890
chrmes:	.dc.b	'   CHR ',0
blkmes:	.dc.b	'   BLOCK            ',0
rawmes:	.dc.b	'(RAW)    ',0
cokmes:	.dc.b	'(COOKED) ',0
okmes:	.dc.b	'   可',0
notmes:	.dc.b	'  不可',0
*		 123456789
*
atrdat:	.dc.b	'IONC'		*属性表示用データ
*
usgmes:	.dc.b	'機　能：デバイスドライバの組み込み状況を'
	.dc.b		'表示します',CR,LF
	.dc.b	'使用法：DEVICE',CR,LF,0
*
errmes:	.dc.b	'DEVICE：ありえないことですが…',CR,LF
	.dc.b	'        NULデバイスが見つかりません'
crlfms:	.dc.b	CR,LF,0
*
	.bss
	.even
*
temp:	.ds.b	8+1		*16進変換用ワーク
*
	.stack
	.even
*
mystack:
	.ds.l	256		*スタック領域
mysp:
	.end
