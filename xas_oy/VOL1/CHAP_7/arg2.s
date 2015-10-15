*	コマンドライン引数解析
*	引数としてファイル名を２個必要とし
*	/A,/B２つのスイッチを持つ場合

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

	lea.l	arg1,a0		*a0=引数切り出し領域

	moveq.l	#2-1,d2		*以下を２回繰り返す

ckarg0:	bsr	nextarg		*スペースをスキップし
				*　スイッチがあれば処理する
	tst.b	(a2)		*引数があるか？
	beq	usage		*　ないなら引数が足らない

	bsr	getarg		*引数１つをa0以降に取り出す

	pea.l	nambuf		*DOSコールを使って
	move.l	a0,-(sp)	*　ファイル名を
	DOS	_NAMECK		*　展開してみる
	addq.l	#8,sp		*
	tst.l	d0		*d0が０でなければ
	bne	usage		*　ファイル名の指定に誤りがある

	lea.l	256(a0),a0	*a0 = a0+256

	dbra	d2,ckarg0	*d2.wが-1になるまで繰り返す

	bsr	nextarg		*さらにスペースを飛ばす
	tst.b	(a2)		*引数があるか？
	bne	usage		*　あるなら引数が多い

	rts

*
*	スペースを飛ばしつぎの引数先頭までポインタを進める
*	スイッチがあれば処理してしまう
*
nextarg:
	bsr	skipsp		*スペースをスキップ

	cmpi.b	#'/',(a2)	*引数の先頭が
	beq	nxarg0		*　/,-であれば
	cmpi.b	#'-',(a2)	*　スイッチ
	beq	nxarg0		*

	rts			*スイッチはもうない
*
nxarg0:	addq.l	#1,a2		*'/'や'-'の分ポインタを進める
	move.b	(a2)+,d0	*１文字取り出す
	bsr	toupper		*大文字に変換しておく
	cmpi.b	#'A',d0		*Aスイッチ？
	beq	asw		*　そうなら分岐
	cmpi.b	#'B',d0		*Bスイッチ？
	beq	bsw		*　そうなら分岐
	bra	usage		*無効なスイッチが指定された
*
asw:	tst.b	Aflg		*Aスイッチの二重指定？
	bne	usage		*　そうならエラー
	move.b	#$ff,Aflg	*AスイッチON
	bra	nextarg		*つぎのスイッチがあるかもしれない
*
bsw:	tst.b	Bflg		*Aスイッチの場合と
	bne	usage		*　やっていることは同じ
	move.b	#$ff,Bflg	*
	bra	nextarg		*

*
*	英小文字→英大文字変換
*
toupper:
	cmpi.b	#'a',d0		*英小文字か？
	bcs	toupr0		*
	cmpi.b	#'z'+1,d0	*
	bcc	toupr0		*
	subi.b	#$20,d0		*小文字なら大文字に変換
toupr0:	rts

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
*	データ
*
	.data
	.even
*
Aflg:	.dc.b	0	*/Aスイッチon/offフラグ（=0...off,<>0...on）
Bflg:	.dc.b	0	*/Bスイッチon/offフラグ（=0...off,<>0...on）
*
usgmes:	.dc.b	'機　能：入力ファイルを××して'
	.dc.b			'出力ファイルに書き出します',CR,LF
	.dc.b	'使用法：ARG2 入力ファイル　出力ファイル',CR,LF
	.dc.b	'	/A	○○を無視します',CR,LF
	.dc.b	'	/B	△△を□□と見なします'
crlfms:	.dc.b	CR,LF,0

*
*	ワークエリア
*
	.bss
	.even
*
arg1:	.ds.b	256		*引数切り出し用バッファ１
arg2:	.ds.b	256		*引数切り出し用バッファ２
nambuf:	.ds.b	91		*ファイル名展開用バッファ
*
	.stack
	.even
*
mystack:
	.ds.l	256		*スタック領域
mysp:
	.end
