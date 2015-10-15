*	DOSコールfiles,nfilesのサンプル

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
*	メイン処理
*
do:
	bsr	chkname		*ファイル名に対する前処理

	move.w	#ARCHIVE,-(sp)	*最初のファイルを検索する
	pea.l	arg		*
	pea.l	filbuf		*
	DOS	_FILES		*
	lea.l	10(sp),sp	*

loop:	tst.l	d0		*ファイルは見つかったか？
	bmi	done		*　見つからなければ処理完了

	bsr	setpath		*得られたファイル名を
				*　フルパスに再構成する

	bsr	doit		*ファイル１個分を処理する

	pea.l	filbuf		*つぎのファイルを検索する
	DOS	_NFILES		*
	addq.l	#4,sp		*

	bra	loop		*繰り返す

done:	rts

*
*	ファイル１個分を処理する（ファイル名を表示するだけ）
*
doit:
	pea.l	arg		*setpathで構成された
	DOS	_PRINT		*　フルパスのファイル名を
	addq.l	#4,sp		*　表示する

	pea.l	crlfms		*改行する
	DOS	_PRINT		*
	addq.l	#4,sp		*

	rts

*
*	files実行に先立ってファイル名に前処理を加える
*
chkname:
	pea.l	nambuf		*ファイル名を展開する
	pea.l	arg		*
	DOS	_NAMECK		*
	addq.l	#8,sp		*

	tst.l	d0		*d0＜０なら
	bmi	usage		*　ファイル名の指定に誤りがある

	beq	nowild		*d0＝０ならワイルドカード指定なし

	cmpi.w	#$00ff,d0	*d0≠FFHなら
	bne	wild		*　ワイルドカード指定あり

noname:			*ファイル名が指定されていない場合
	lea.l	arg,a0		*バッファargに
	lea.l	nambuf,a1	*　nameckで展開したパス名＋'*.*'
	bsr	strcpy		*　を再構成する
	lea.l	kome0,a1	*
	bsr	strcpy		*

wild:			*ワイルドカードが指定された場合
				*何もしなくてよい
cknam0:	rts

nowild:			*ワイルドカードが指定されていない場合
	move.w	#SUBDIR,-(sp)	*サブディレクトリであると仮定して
	pea.l	arg		*　検索してみる
	pea.l	filbuf		*
	DOS	_FILES		*
	lea.l	10(sp),sp	*
	
	tst.l	d0		*見つかったか？
	bmi	cknam0		*　見つからなければファイルだろう

	lea.l	arg,a0		*バッファargに
	lea.l	komekome,a1	*　もとのファイル名＋'\*.*'
	bsr	strcat		*　を再構成する

	bra	chkname		*nameckでファイル名を展開するために
				*　サブルーチン先頭に戻る

*
*	files,nfilesで見付けたファイル名をフルパスに構成し直し
*		arg以降に格納する
*
setpath:
	lea.l	arg,a0		*a0=コピー先
	lea.l	nambuf,a1	*a1=nameckで展開したパス名
	bsr	strcpy		*コピーする
	lea.l	filbuf+30,a1	*a1=files,nfilesで見付けたファイル名
	bsr	strcpy		*連結する
	rts

*
*	コマンドラインの解析
*
chkarg:
	addq.l	#1,a2		*a2=コマンドライン文字列先頭
	bsr	skipsp		*スペースをスキップする
*	tst.b	(a2)		*引数があるか？
*	beq	usage		*　ないなら引数が足らない
			*好みによってこの２行を復活させよう

	cmpi.b	#'/',(a2)	*引数の先頭が
	beq	usage		*　'/'か
	cmpi.b	#'-',(a2)	*　'-'であれば
	beq	usage		*　きっとヘルプが見たいのだろう

	lea.l	arg,a0		*a0=引数切り出し領域
	bsr	getarg		*引数１つをa0以降に取り出す

	bsr	skipsp		*さらにスペースをスキップ
	tst.b	(a2)		*引数があるか？
	bne	usage		*　あるなら引数が多い

	rts

*
*	a2の指す位置から引数１つ分をa0の指す領域へコピーする
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
*	文字列の連結および複写
*	リターン時a0は文字列末の00Hを指す
*
strcat:
	tst.b	(a0)+		*(a0)は0か？
	bne	strcat		*そうでなければ繰り返す
	subq.l	#1,a0		*行きすぎたから１つ戻る
strcpy:
	move.b	(a1)+,(a0)+	*１文字ずつ
	bne	strcpy		*終了コードまでを転送する
	subq.l	#1,a0		*a0は進み過ぎている
				*a0は文字列末の00Hを指す
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
usgmes:	.dc.b	'機　能：指定ファイル名をフルパスで表示します',CR,LF
	.dc.b	TAB,'ファイル名にはワイルドカードが使用できます',CR,LF
	.dc.b	'使用法：FILELIST［ファイル名］'
crlfms:	.dc.b	CR,LF,0

komekome:
	.dc.b	'\'
kome0:	.dc.b	'*.*',0

*
*	ワークエリア
*
	.bss
	.even
*
arg:	.ds.b	256		*引数切り出し用バッファ
			*filesで使うバッファは偶数アドレスに置く
filbuf:	.ds.b	53		*ファイル情報格納用バッファ
			*nameckで使うバッファは奇数アドレスでもよい
nambuf:	.ds.b	91		*ファイル名展開用バッファ
*
	.stack
	.even
*
mystack:
	.ds.l	256		*スタック領域
mysp:
	.end
