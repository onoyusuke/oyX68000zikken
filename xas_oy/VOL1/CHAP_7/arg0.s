*	コマンドライン引数解析
*	引数を必要としない場合

	.include	doscall.mac
	.include	const.h
*
	.text
	.even
*
ent:
	lea.l	mysp,sp		*spの初期化

	bsr	chkarg		*コマンドラインの解析

	bsr	do		*メイン処理

	DOS	_EXIT		*正常終了

*
*	メイン処理（今は何もしない）
*
do:
	rts

*
*	コマンドラインの解析
*
chkarg:
	addq.l	#1,a2		*a2=コマンドライン文字列先頭
	bsr	skipsp		*スペースをスキップする
	tst.b	(a2)		*余計な引数があるか？
	bne	usage		*　そうなら使用法を表示
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
*	使用法の表示＆終了
*
usage:
	move.w	#STDERR,-(sp)	*標準エラー出力へ
	pea.l	usgmes		*　ヘルプメッセージを
	DOS	_FPUTS		*　出力する
	addq.l	#6,sp		*スタック補正

	move.w	#1,-(sp)	*終了コード１を持って
	DOS	_EXIT2		*　エラー終了

*
*	メッセージデータ
*
	.data
	.even
*
usgmes:	.dc.b	'機　能：○○を××します',CR,LF
	.dc.b	'使用法：ARG0',CR,LF
	.dc.b	0
*
	.stack
	.even
*
mystack:
	.ds.l	256		*スタック領域
mysp:
	.end
