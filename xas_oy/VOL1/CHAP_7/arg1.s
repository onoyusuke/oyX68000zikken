*	コマンドライン引数解析
*	引数としてファイル名を１個必要とする場合

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
*	メイン処理（今は与えられた引数を表示するだけ）
*
do:
	pea.l	arg		*引数を表示する
	DOS	_PRINT		*
	addq.l	#4,sp		*
	bsr	crlf		*改行する
	rts

*
*	改行する
*
crlf:
	pea.l	crlfms
	DOS	_PRINT
	addq.l	#4,sp
	rts

*
*	コマンドラインの解析
*
chkarg:
	addq.l	#1,a2		*a2=コマンドライン文字列先頭
	bsr	skipsp		*スペースをスキップする
	tst.b	(a2)		*引数があるか？
	beq	usage		*　ないなら引数が足らない

	cmpi.b	#'/',(a2)	*引数の先頭が
	beq	usage		*　'/'か
	cmpi.b	#'-',(a2)	*　'-'であれば
	beq	usage		*　きっとヘルプが見たいのだろう

	lea.l	arg,a0		*a0=引数切り出し領域
	bsr	getarg		*引数１つをa0以降に取り出す

	bsr	skipsp		*さらにスペースをスキップ
	tst.b	(a2)		*引数があるか？
	bne	usage		*　あるなら引数が多い

	pea.l	nambuf		*DOSコールを使って
	move.l	a0,-(sp)	*　ファイル名を
	DOS	_NAMECK		*　展開してみる
	addq.l	#8,sp		*
	tst.l	d0		*d0が０でなければ
	bne	usage		*　ファイル名の指定に誤りがある

	rts

*
*	a2の指す位置から引数１つ分を
*	a0の指す領域へコピーする
*
getarg:
	move.l	a0,-(sp)	*｛レジスタ待避
gtarg0:	tst.b	(a2)		*1)文字列の終端コードか
	beq	gtarg1		*
	cmpi.b	#SPACE,(a2)	*2)スペースか
	beq	gtarg1		*
	cmpi.b	#TAB,(a2)	*3)タブか
	beq	gtarg1		*
	cmpi.b	#'-',(a2)	*4)ハイフンか
	beq	gtarg1		*
	cmpi.b	#'/',(a2)	*5)スラッシュ
	beq	gtarg1		*
	move.b	(a2)+,(a0)+	*　が現れるまで転送を
	bra	gtarg0		*　繰り返す
gtarg1:	clr.b	(a0)		*文字列終端コードを書き込む
	movea.l	(sp)+,a0	*｝レジスタ復帰
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
usgmes:	.dc.b	'機　能：指定ファイルを××します',CR,LF
	.dc.b	'使用法：ARG1 ファイル名'
crlfms:	.dc.b	CR,LF,0

*
*	ワークエリア
*
	.bss
	.even
*
arg:	.ds.b	256		*引数切り出し用バッファ
nambuf:	.ds.b	91		*ファイル名展開用バッファ
*
	.stack
	.even
*
mystack:
	.ds.l	256		*スタック領域
mysp:
	.end
