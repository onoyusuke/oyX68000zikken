*	DOSコールnameckの動作を確認するプログラム

	.include	doscall.mac
	.include	const.h
*
	.text
	.even
*
ent:
	lea.l	mysp,sp		*spの初期化

	pea.l	namebuf		*与えられたコマンドライン引数を
	pea.l	1(a2)		*　ファイル名と見なし
	DOS	_NAMECK		*　nameckで展開する
	addq.l	#8,sp		*

	lea.l	hexbuf,a0	*d0.lを16進８桁に変換し
	bsr	itoh		*　a0の指す領域へ格納しておく

	lea.l	prttbl,a0	*a0=テーブルの先頭アドレス

	moveq.l	#4-1,d1		*以下を４回繰り返す

loop:	move.l	(a0)+,-(sp)	*見出し部分を表示
	DOS	_PRINT		*
	addq.l	#4,sp		*

	move.l	(a0)+,-(sp)	*対応する内容を表示
	DOS	_PRINT		*
	addq.l	#4,sp		*

	pea.l	crlfms		*改行する
	DOS	_PRINT		*
	addq.l	#4,sp		*

	dbra	d1,loop		*d1.wが-1になるまで繰り返す

	DOS	_EXIT		*正常終了

*
*	d0.lを16進８桁を表す文字列へ変換し(a0)以降に格納する
*		レジスタはみんな保存する
*
itoh:
	movem.l	d0-d2/a0,-(sp)	*｛レジスタ待避

	moveq.l	#8-1,d2		*以下を８回繰り返す

itoh0:	rol.l	#4,d0		*d0.lを左に４ビット回転する
				*４ビットは16進１桁分！
				*たとえば
				*  $1234ABCD　→　$234ABCD1
	move.b	d0,d1		*d0の下位バイトをd1に取り出し
	andi.b	#$0f,d1		*　下位４ビットを残してマスクする
				*d1にはd0.lを16進で表したときの
				*　最上位桁が入っている
	addi.b	#'0',d1		*ここで数値から16進を表す文字へ
	cmpi.b	#'9'+1,d1	*　変換する
	bcs	itoh1		*　0～9の場合は'0'を足すだけだが
	addq.b	#'A'-'0'-10,d1	*  A～Fの場合はさらに補正が必要

itoh1:	move.b	d1,(a0)+	*変換した文字をしまう

	dbra	d2,itoh0	*d2.wが-1になるまで繰り返す

	clr.b	(a0)		*文字列終端コードを書き込む

	movem.l	(sp)+,d0-d2/a0	*｝レジスタ復帰
	rts

*
*	データ
*
	.data
	.even
*
prttbl:	.dc.l	mes1,hexbuf	*見出しとその内容の
	.dc.l	mes2,drive	*　対応を示したテーブル（表）
	.dc.l	mes3,name	*　見出しのアドレスと内容のアドレスが
	.dc.l	mes4,ext	*　１組になっている
*
mes1:	.dc.b	'NAMACKの戻り値(d0.l)：',0
mes2:	.dc.b	'              パス名：',0
mes3:	.dc.b	'          ファイル名：',0
mes4:	.dc.b	'              拡張子：',0
crlfms:	.dc.b	CR,LF,0

*
*	ワーク
*
	.bss
	.even
*
namebuf:			*nameckで
drive:	.ds.b	2		*　ファイル名が展開される
path:	.ds.b	65		*　領域
name:	.ds.b	19		*
ext:	.ds.b	5		*計91バイト
*
hexbuf:	.ds.b	8+1		*itohで16進文字列を格納する領域
*
	.stack
	.even
*
mystack:
	.ds.l	256		*スタック領域
mysp:
	.end
