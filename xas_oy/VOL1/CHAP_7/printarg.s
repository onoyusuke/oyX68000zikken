*	コマンドライン引数の渡されかたを確認する

	.include	doscall.mac
	.include	const.h		*前章で用意した定数定義ファイル
*
	.text
	.even
*
ent:
	lea.l	mysp,sp		*spの初期化

	move.w	#'[',-(sp)	*[を表示
	DOS	_PUTCHAR	*
	addq.l	#2,sp		*

	pea.l	1(a2)		*a2+1からの
	DOS	_PRINT		*　コマンドライン文字列を
	addq.l	#4,sp		*　表示

	pea.l	endmes		*]を表示して改行する
	DOS	_PRINT		*
	addq.l	#4,sp		*

	DOS	_EXIT		*終了
*
	.data
	.even
*
endmes:	.dc.b	']',CR,LF,0
*
	.stack
	.even
*
mystack:
	.ds.l	256		*スタック領域
mysp:
	.end
