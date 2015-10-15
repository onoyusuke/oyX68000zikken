*	チャイルドプロセスを単に起動してみる
*
*	作成法：as chldtest
*		lk chldtest child memoff
*
	.include	doscall.mac
	.include	const.h
*
	.xref	child		*外部参照
	.xref	memoff		*
*
	.text
	.even
*
ent:
	lea.l	mysp,sp		*spの初期化

	bsr	memoff		*余分なメモリを開放する

	pea.l	cmd		*チャイルドプロセス起動
	bsr	child		*
	addq.l	#4,sp		*
	tst.l	d0		*エラー？
	bmi	error		*　そうならエラー終了

	DOS	_EXIT		*終了
*
error:				*エラー終了
	pea	errmes
	DOS	_PRINT
	addq.l	#4,sp

	move.w	#1,-(sp)
	DOS	_EXIT2
*
	.data
	.even
*
cmd:	.dc.b	'attrib *.*',0		*起動コマンド
errmes:	.dc.b	'コマンドが起動できません',0
*
	.stack
	.even
*
mystack:			*スタック領域
	.ds.l	1024
mysp:

	.end	ent		*実行開始アドレスはent
