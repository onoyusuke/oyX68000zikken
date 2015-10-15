*	DOSコールによる文字列表示

	.include	doscall.mac
*
	.text
	.even
*
ent:
	lea.l	mysp,sp		*spの初期化

	move.l	#str,-(sp)	*文字列先頭アドレスをプッシュ
	DOS	_PRINT		*文字列表示
	add.l	#4,sp		*スタック補正

	DOS	_EXIT		*終了
*
str:	.dc.b	'1234ABCD'	*表示する文字列
	.dc.b	$0d,$0a,0	*
*
	.stack
	.even
*
mystack:
	.ds.l	256		*スタック領域
mysp:
	.end
