*	英小文字→英大文字変換フィルタ　最終版

	.include	doscall.mac
	.include	const.h
*
	.text
	.even
*
BUFFSIZE	equ	1024	*バッファの大きさ
*
ent:
	lea.l	mysp,sp		*spの初期化

	bsr	init		*入出力関係の初期化

	bsr	do		*フィルタ本体

	bsr	puteof		*ファイルエンドコードを出力

	bsr	flushbuff	*書き出しバッファを吐き出す
	tst.l	d0		*
	bmi	werror		*

	bsr	nl		*改行する（標準エラー出力）

	DOS	_ALLCLOSE	*全ファイルクローズ

	DOS	_EXIT		*終了

*
*	小文字→大文字変換メインループ
*
do:
loop:	bsr	getchar		*１バイト読み込む
	tst.l	d0		*エラーか？
	bmi	rerror		*そうならエラー終了

	cmpi.b	#EOF,d0		*ファイルエンドコードか？
	beq	done		*そうなら終了

	cmpi.b	#$80,d0		*80Hより小さければ
	bcs	hankaku		*	ASCIIコード
	cmpi.b	#$a0,d0		*80H以上A0H未満なら
	bcs	zenkaku		*	シフトJISの１バイト目
	cmpi.b	#$e0,d0		*A0H以上E0H未満なら
	bcs	hankaku		*	ASCIIカタカナ
				*E0H以上なら
				*	シフトJISの１バイト目

zenkaku:		*全角文字の処理
	bsr	putchar		*１バイト書き出す
	tst.l	d0		*
	bmi	werror		*

	bsr	getchar		*もう１バイト読み込む
	tst.l	d0		*
	bmi	rerror		*

	bsr	putchar		*そのまま出力する
	tst.l	d0		*
	bmi	werror		*

	bra	loop		*繰り返す

hankaku:		*半角文字の処理
	bsr	toupper		*小文字→大文字変換

	bsr	putchar		*１バイト書き出す
	tst.l	d0		*
	bmi	werror		*

	bra	loop		*繰り返す

done:	rts		*変換終了

*
*	英小文字→英大文字変換
*
toupper:
	cmpi.b	#'a',d0		*英小文字か？
	bcs	toupr0		*
	cmpi.b	#'z'+1,d0	*
	bcc	toupr0		*
	subi.b	#$20,d0		*小文字なら大文字に変換
toupr0:	rts			*サブルーチンからリターン

*
*	ファイルエンドコードの出力（ファイルに対してのみ）
*
puteof:
	tst.b	devflg		*出力先が
	bmi	pteof0		*　ファイルのときのみ
	moveq.l	#EOF,d0		*　EOFコードを
	bsr	putchar		*　出力する
	tst.l	d0		*
	bmi	werror		*
pteof0:	rts

*
*	１バイト入力する
*
getchar:
	move.l	a0,-(sp)	*｛レジスタを待避

	tst.l	rctr		*バッファにデータはあるか？
	bne	getc0		*あればそこから取り出す

	bsr	fillbuff	*バッファを満たす

	tst.l	d0		*d0<0...エラー, d0 = 0...EOF
	bmi	getc1		*エラーが発生した
	beq	eof		*ファイルが終わった

getc0:	movea.l	rptr,a0		*ポインタを取り出す
	moveq.l	#0,d0		*上位バイトを０にしておく
	move.b	(a0)+,d0	*バッファから１バイト取り出す
	move.l	a0,rptr		*ポインタを更新する
	subq.l	#1,rctr		*カウンタを更新する
	bra	getc1
*
eof:	moveq.l	#EOF,d0		*EOFコードを持って帰る

getc1:	movea.l	(sp)+,a0	*｝レジスタを復帰
	rts

*
*	入力バッファを満たす
*
fillbuff:
	move.l	#BUFFSIZE,-(sp)	*バッファにデータを読み込む
	pea.l	rbuff		*
	move.w	rfno,-(sp)	*
	DOS	_READ		*
	lea.l	10(sp),sp	*

	move.l	#rbuff,rptr	*ポインタを再初期化
	move.l	d0,rctr		*カウンタを再初期化
	rts

*
*	１バイト出力する
*
putchar:
	move.l	a0,-(sp)	*｛レジスタを待避

	andi.l	#$0000_00ff,d0	*上位ビットをマスクする

	movea.l	wptr,a0		*ポインタを取り出す
	move.b	d0,(a0)+	*バッファに１バイト追加する
	move.l	a0,wptr		*ポインタを更新する
	addq.l	#1,wctr		*カウンタを更新する

	cmpi.l	#BUFFSIZE,wctr	*バッファが一杯になったか？
	bcc	putc0		*そうならバッファ内容を吐き出す

	tst.b	devflg		*出力先はキャラクタデバイスか？
	bpl	putc1		*そうでなければリターン
	cmpi.b	#LF,d0		*出力データはLFコードか
	bne	putc1		*そうでなければリターン

	move.w	#-1,-(sp)	*キーバッファを空にする
	DOS	_KFLUSH		*
	addq.l	#2,sp		*

putc0:	bsr	flushbuff	*バッファ内容を吐き出す

putc1:	movea.l	(sp)+,a0	*｝レジスタを復帰
	rts

*
*	書き出しバッファ内容を吐き出す
*
flushbuff:
	tst.l	wctr		*バッファが空であれば
	beq	flush0		*　なにもしない

	move.l	wctr,-(sp)	*バッファ内容を書き出す
	pea.l	wbuff		*
	move.w	wfno,-(sp)	*
	DOS	_WRITE		*
	lea.l	10(sp),sp	*
	tst.l	d0		*エラー？
	bmi	flush0		*　エラーコードを持って帰る
				*d0.l = 実際に書き出したバイト数
	sub.l	wctr,d0		*d0.l=wctr ... d0.l = 0　非エラー
				*d0.l<wctr ... d0.l < 0　エラー

	move.l	#wbuff,wptr	*ポインタを再初期化
	clr.l	wctr		*カウンタを再初期化

flush0:	rts

*
*	入出力初期化
*
init:
	move.l	#rbuff,rptr	*読み込みバッファへのポインタ
	move.l	#wbuff,wptr	*書き出しバッファへのポインタ
	clr.l	rctr		*読み込み用カウンタ
	clr.l	wctr		*書き出し用カウンタ

	addq.l	#1,a2		*a2=コマンドライン
	bsr	ropen		*rfno=入力先のファイルハンドル
	bsr	wopen		*wfno=出力先のファイルハンドル

	bsr	nextarg		*つぎの引数が
	tst.b	(a2)		*　あるか？
	bne	usage		*引数が多過ぎる

	rts

*
*	入力先ファイルハンドルを得る
*
ropen:
	bsr	nextarg		*つぎの引数の先頭アドレスを得る
	tst.b	(a2)		*文字列はまだあるか？
	beq	ropen0		*なければファイル名指定なし

*ファイル名の指定があった場合
	bsr	getarg		*ファイル名をtempに抜き出す

	move.w	#ROPEN,-(sp)	*指定されたファイルを
	pea.l	temp		*　リードオープンする
	DOS	_OPEN		*
	addq.l	#6,sp		*
	bra	ropen1

*ファイル名の指定がなかった場合
ropen0:	move.w	#STDIN,-(sp)	*標準入力のファイルハンドルを
	DOS	_DUP		*　複製する
	addq.l	#2,sp		*

*d0には
*　ファイル名の指定があったときはオープンしたファイルハンドルが
*　指定がなかったときは標準入力を複製したファイルハンドルが入っている
ropen1:	tst.l	d0		*エラー？
	bmi	rerror		*　そうならエラー終了

	move.w	d0,rfno		*入力先ファイルハンドルをしまう

	move.w	#STDIN,-(sp)	*標準入力をクローズして
	DOS	_CLOSE		*　キーボード(CON)に割り当てを戻す
	addq.l	#2,sp		*
	tst.l	d0		*エラー？
	bmi	rerror		*　そうならエラー終了

	rts

*
*	出力先ファイルハンドルを得る
*
wopen:
	move.w	#STDOUT,wfno	*仮に標準出力のハンドルをセットしておく

	bsr	nextarg		*つぎの引数の先頭アドレスを得る
	tst.b	(a2)		*文字列はまだあるか？
	beq	wopen1		*なければファイル名指定なし

*ファイル名の指定があった場合
	bsr	getarg		*ファイル名をtempに抜き出す

	move.w	#ARCHIVE,-(sp)	*指定されたファイルを
	pea.l	temp		*　新規作成する
	DOS	_CREATE		*
	addq.l	#6,sp		*
	tst.l	d0		*エラー？
	bpl	wopen0		*　エラーがなければオープン完了

	move.w	#WOPEN,-(sp)	*createでエラーが発生したときは
	pea.l	temp		*　openを使って
	DOS	_OPEN		*　もう一度ライトオープンしてみる
	addq.l	#6,sp		*
	tst.l	d0		*エラー？
	bmi	werror		*　そうなら今度こそエラー終了

wopen0:	move.w	d0,wfno		*出力先ファイルハンドルをしまう

*ファイル名の指定がなかった場合は直接ここにくる（wfno = STDIN）
*ファイル名の指定があった場合はwfnoに出力先ハンドルが入っている
wopen1:	move.w	wfno,-(sp)	*出力先の装置情報を取り出す
	clr.w	-(sp)		*
	DOS	_IOCTRL		*
	addq.l	#4,sp		*

	move.b	d0,devflg	*devflgの第７ビットが１であれば
				*　キャラクタデバイス
	rts

*
*	つぎの引数先頭までポインタを進める
*
nextarg:
	bsr	skipsp		*スペースをスキップ

	cmpi.b	#'/',(a2)	*引数の先頭が
	beq	usage		*　/,-,?であれば
	cmpi.b	#'-',(a2)	*　使用法を表示して終了する
	beq	usage		*
	cmpi.b	#'?',(a2)	*
	beq	usage		*

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
*	引数１つ分を一時バッファにコピーする
*
getarg:
	lea.l	temp,a0		*a0=転送先
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
	rts

*
*	使用法の表示・終了
*
usage:
	lea.l	usgmes,a0	*使用法
	bra	error

*
*	カーソルが画面の左端になければ改行する
*
nl:
	move.w	#-1,-(sp)	*カーソル座標を取り出す
	move.w	#-1,-(sp)	*
	move.w	#3,-(sp)	*
	DOS	_CONCTRL	*
	addq.l	#6,sp		*
				*d0.l = xxxx_yyyy
	swap.w	d0		*d0.l = yyyy_xxxx
	tst.w	d0		*x座標は０か？
	beq	nl0		*　０ならなにもしない

ltnl:	move.l	a0,-(sp)	*｛
	lea.l	crlfms,a0	*改行する
	bsr	puterr		*
	movea.l	(sp)+,a0	*｝

nl0:	rts

*
*	メッセージ表示（標準エラー出力へ）
*
puterr:	move.w	#STDERR,-(sp)	*標準エラー出力へ
	move.l	a0,-(sp)	*　文字列を
	DOS	_FPUTS		*　出力する
	addq.l	#6,sp		*スタック補正
	rts

*
*	エラー終了
*
rerror:	lea.l	rerrms,a0	*読み込み時エラー
	bra	error
werror:	lea.l	werrms,a0	*書き出し時エラー
	*
error:	bsr	puterr		*メッセージを表示

	move.w	#1,-(sp)	*終了コード１を持って
	DOS	_EXIT2		*　エラー終了

*
*	メッセージデータ
*
	.data
	.even
*
rerrms:	.dc.b	CR,LF,'UPPER：うまく読み込めませんでした',CR,LF,0
werrms:	.dc.b	CR,LF,'UPPER：うまく書き出せませんでした',CR,LF,0
crlfms:	.dc.b	CR,LF,0
usgmes:	.dc.b	'使用法：UPPER［入力ファイル［出力ファイル］］',CR,LF
	.dc.b	'	半角英小文字を大文字に変換します',CR,LF
	.dc.b	'	出力ファイルが省略された場合は'
	.dc.b	'標準出力へ出力します',CR,LF
	.dc.b	'	入力ファイルも省略された場合は'
	.dc.b	'標準入力から入力します',CR,LF
	.dc.b	0

*
*	ワークエリア
*
	.bss
	.even
*
rptr:	.ds.l	1		*読み込みポインタ（getcharで使用）
rctr:	.ds.l	1		*読み込みカウンタ（getcharで使用）
rfno:	.ds.w	1		*入力ファイルハンドル（getcharで使用）
wptr:	.ds.l	1		*書き出しポインタ（putcharで使用）
wctr:	.ds.l	1		*書き出しカウンタ（putcharで使用）
wfno:	.ds.w	1		*出力ファイルハンドル（putcharで使用）
*
devflg:	.ds.b	1		*出力先フラグ（putchar,puteofで使用）
				*	bit7=0...ファイル
				*	    =1...キャラクタデバイス
*
temp:				*一時バッファ（実体はrbuff）
rbuff:	.ds.b	BUFFSIZE	*読み込みバッファ（getcharで使用）
wbuff:	.ds.b	BUFFSIZE	*書き出しバッファ（putcharで使用）
*
	.stack
	.even
*
mystack:
	.ds.l	256		*スタック領域
mysp:
	.end
