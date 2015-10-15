*	標準エラー出力をリダイレクトする
*
*	作成法：as rderr
*		lk rderr child memoff
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

	bsr	chkarg		*コマンドラインの解析

	bsr	do		*メイン処理

	DOS	_EXIT		*終了

*
*	メイン処理
*
do:
	bsr	err_redirect	*標準エラー出力を
				*　リダイレクト
	move.l	a2,-(sp)	*チャイルドプロセス起動
	bsr	child		*
	addq.l	#4,sp		*

	move.l	d0,-(sp)	*EXECのエラーコードを退避

	move.w	#STDERR,-(sp)	*標準エラー出力をクローズ
	DOS	_CLOSE		*（割り当てはconに戻る）
	addq.l	#2,sp		*

	move.l	(sp)+,d0	*d0.l=EXECの終了コード
	bmi	error2		*負ならエラー

	rts

*
*	標準エラー出力をfilnamにリダイレクトする
*
err_redirect:
wopen:
	move.w	#ARCHIVE,-(sp)	*指定されたファイルを
	pea.l	filnam		*　新規作成する
	DOS	_CREATE		*
	addq.l	#6,sp		*
	tst.l	d0		*エラー？
	bpl	wopen0		*　エラーがなければオープン完了

	move.w	#WOPEN,-(sp)	*createでエラーが発生したときは
	pea.l	filnam		*　openを使って
	DOS	_OPEN		*　もう一度ライトオープンしてみる
	addq.l	#6,sp		*
	tst.l	d0		*エラー？
	bmi	error1		*　そうなら今度こそエラー終了

wopen0:	move.w	d0,d1		*d1.w=出力先ファイルハンドル

	move.w	#STDERR,-(sp)	*オープンしたファイルハンドルを
	move.w	d1,-(sp)	*　標準エラー出力に
	DOS	_DUP2		*　強制コピー
	addq.l	#4,sp		*
	tst.l	d0		*エラー？
	bmi	error1		*　そうならエラー終了

	move.w	d1,-(sp)	*いまオープンしたファイルハンドルは
	DOS	_CLOSE		*　もういらないから
	addq.l	#2,sp		*　クローズしてしまう

	rts

*
*	コマンドラインの解析
*
chkarg:
	addq.l	#1,a2		*a2=コマンドライン文字列先頭

	bsr	nextarg		*スペースをスキップする
	tst.b	(a2)		*コマンドライン引数があるか？
	beq	usage		*　ないなら引数が足らない
	lea.l	filnam,a0	*a0=ファイル名切り出し領域
	bsr	getarg		*引数１つをa0以降に取り出す

	lea.l	-100(sp),sp	*100バイトのローカルエリアに
	move.l	sp,-(sp)	*　DOSコールを使って
	move.l	a0,-(sp)	*　ファイル名を
	DOS	_NAMECK		*　展開してみる
	lea.l	100+8(sp),sp	*
	tst.l	d0		*d0が０でなければ
	bne	usage		*　ファイル名の指定に誤りがある

	bsr	nextarg		*さらにスペースを飛ばす
	tst.b	(a2)		*まだあるか？
	beq	usage		*　実行すべきコマンドがない

	rts

*
*	スペースを飛ばしつぎの引数先頭までポインタを進める
*
nextarg:
	bsr	skipsp		*スペースをスキップ

	cmpi.b	#'/',(a2)	*引数の先頭が
	beq	usage		*　/,-であれば
	cmpi.b	#'-',(a2)	*　使用法を表示
	beq	usage		*

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

	DOS	_EXIT

*
*	使用法の表示＆終了・エラー終了
*
usage:
	lea	usgmes,a0
	bra	err0
*
error1:
	lea	errms1,a0	*ファイルオープン時エラー
	bra	err0

error2:
	lea	errms2,a0	*チャイルドプロセス生成時エラー
*	bra	err0
	*
err0:	move.w	#STDERR,-(sp)	*標準エラー出力へ
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
usgmes:	.dc.b	'機　能：標準エラー出力をファイルに切り替えてから',CR,LF
	.dc.b	TAB,'指定のコマンドを実行します',CR,LF
	.dc.b	'使用法：RDERR　切り替え先ファイル　実行コマンド'
crlfms:	.dc.b	CR,LF,0
errms1:	.dc.b	'RDERR: ファイルが作成できませんでした',CR,LF,0
errms2:	.dc.b	'RDERR: コマンドが起動できませんでした',CR,LF,0

*
*	ワークエリア
*
	.bss
	.even
*
wfno:	.ds.w	1		*リダイレクト先ファイルハンドル
filnam:	.ds.b	256		*ファイル名切り出し用バッファ
*
	.stack
	.even
*
mystack:			*スタック領域
	.ds.l	1024		*
mysp:

	.end	ent		*実行開始アドレスはent
