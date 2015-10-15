*	AS.Xのエラーメッセージを横取りして
*		エラーファイルを作成する
*
	.include	doscall.mac
	.include	const.h
	.include	files.h
*
	.xref	memoff
	.xref	child
*
STRMAX	equ	256		*文字列の最大長
BUFSIZ	equ	300		*１行バッファの大きさ
*
	.text
	.even
*
ent:
	lea.l	mysp(pc),sp	*spの初期化

	bsr	memoff		*余分なメモリを開放する

	bsr	chkarg		*コマンドラインの解析

	pea.l	break(pc)	*中断時の戻りアドレスを
	move.w	#_CTRLVC,-(sp)	*　セット
	DOS	_INTVCS		*
	move.w	#_ERRJVC,(sp)	*
	DOS	_INTVCS		*
	addq.l	#6,sp		*

	bsr	do		*メイン処理

	DOS	_WAIT		*AS.Xの終了コードを得て
	move.w	d0,-(sp)	*　それをそのまま持って
	DOS	_EXIT2		*　終了する

*
*	メイン処理
*
do:
	bsr	set_vector	*DOSコールのベクタを書き換える

	lea.l	cmdlin(pc),a0	*子プロセスを起動するために
	lea.l	prog(pc),a1	*　コマンドラインを作成する
	bsr	strcpy		*
	movea.l	a2,a1		*
	bsr	strcpy		*

	pea.l	cmdlin(pc)	*子プロセス起動
	bsr	child		*
	addq.l	#4,sp		*
	tst.l	d0		*
	bmi	error1		*負ならエラー

	bsr	reset_vector	*ベクタを元に戻す

	rts

*
*	DOSコールwriteが発動されるとここに来る
*
	.offset	0
*
FNO:	.ds.w	1	*ファイルハンドル
DATPTR:	.ds.l	1	*出力データへのポインタ
DATLEN:	.ds.l	1	*出力データのバイト数
*
	.text
*
write:
	cmpi.w	#STDOUT,FNO(a6)	*出力先は標準出力か？
	bne	write0		*そうでなければ
				*　オリジナルの処理ルーチンへ

	movem.l	d1-d2/a0-a3,-(sp)	*｛

	movea.l	bufptr(pc),a0	*a0=バッファ内の次の位置
	movea.l	DATPTR(a6),a1	*a1=出力データ
	move.l	DATLEN(a6),d1	*d1=出力データのバイト数
	lea.l	buff+BUFSIZ-1(pc),a2
				*a2=バッファの上限
				*（終端コードの分を考慮）
wrt0:	move.b	(a1)+,d0	*１バイト取り出し
	move.b	d0,(a0)+	*　バッファに転送する
	cmpi.b	#LF,d0		*１行分溜まったか？
	beq	wrt1		*　そうなら１行出力
	cmpa.l	a2,a0		*バッファの上限に達したか
	bcs	wrt2		*　そうでないならスキップ
wrt1:	bsr	putline		*１行出力する
wrt2:	subq.l	#1,d1		*データのカウンタを１減らし
	bne	wrt0		*　<>0なら繰り返す

	move.l	a0,bufptr	*ポインタ更新

	movem.l	(sp)+,d1-d2/a0-a3	*｝
	*
write0:	jmp	0		*オリジナルのwriteへ
write_org	equ	write0+2

*
*	１行分の処理
*
putline:
	move.w	efno(pc),d2	*d2=エラーファイルのファイルハンドル
	bne	putln0		*d2<>0ならファイルはオープン済み

	move.w	#ARCHIVE,-(sp)	*エラーファイルを新規作成
	pea.l	efname(pc)	*
	DOS	_CREATE		*
	addq.l	#6,sp		*
	move.w	d0,d2		*
	bmi	putln3		*エラーでなければ
	move.w	d2,efno		*　ファイルハンドルをワークへ

putln0:	clr.b	(a0)		*文字列の終端コードを書き込む
	lea.l	buff(pc),a0	*a0=出力するデータ先頭

	lea.l	errstr(pc),a3	*エラーメッセージか？
	bsr	strcmp		*
	beq	putln1		*　そうなら細工してから出力

	lea.l	wrnstr(pc),a3	*警告メッセージか？
	bsr	strcmp		*
	bne	putln2		*　そうでなければ生のまま出力

			*エラー/警告メッセージだった場合
putln1:	move.w	d2,-(sp)	*ソースファイル名を
	pea.l	fname(pc)	*　エラーファイルへ書き出す
	DOS	_FPUTS		*
	addq.l	#6,sp		*
		*a0はエラーメッセージ中の行番号を指している

putln2:	move.w	d2,-(sp)	*残りのメッセージを
	move.l	a0,-(sp)	*　エラーファイルへ書き出す
	DOS	_FPUTS		*
	addq.l	#6,sp		*

putln3:	lea.l	buff(pc),a0	*ポインタ初期化
	rts

*
*	a0の指す文字列先頭がa3の指す文字列と
*		一致するかどうか調べる
*	一致した場合	Z=1,a0=一致した部分の直後
*	不一致の場合	Z=0,a0は保存される
*
strcmp:
	move.l	a0,-(sp)	*a0=被比較文字列先頭
				*a3=比較部分文字列先頭
strcp0:	tst.b	(a3)		*比較文字列がもうなければ
	beq	strcp1		*　一致した
				*そうでなければ
	cmpm.b	(a0)+,(a3)+	*　比較してみて
	beq	strcp0		*　一致している間は繰り返す
				*不一致が検出されたら
	movea.l	(sp)+,a0	*被比較文字列を復帰して
	rts			*　戻る
strcp1:	addq.l	#4,sp		*待避してあったa0はもういらない
	rts			*一致した

*
*	DOS $ff40 writeのベクタを書き換える
*
set_vector:
	pea.l	write(pc)	*置き換える処理ルーチン先頭
	move.w	#_WRITE,-(sp)	*
	DOS	_INTVCS		*
	move.l	d0,write_org	*元のベクタを待避
	st.b	hooked		*ベクタを書き換えた印を立てる
	addq.l	#6,sp
	rts

*
*	DOS $ff40 writeのベクタを元に戻す
*
reset_vector:
	tst.b	hooked		*ベクタを書き換えていないなら
	beq	rvec0		*　何もしない

	move.l	write_org(pc),-(sp)	*WRITEの元のアドレス
	move.w	#_WRITE,-(sp)		*
	DOS	_INTVCS			*
	addq.l	#6,sp			*

	clr.b	hooked		*フラグをクリア

rvec0:	rts

*
*	コマンドラインの解析
*
chkarg:
	addq.l	#1,a2		*a2=コマンドライン文字列先頭
	move.l	a2,-(sp)	*あとで使うから保存しておく

	bsr	fstarg		*空白とスイッチをスキップする
	lea.l	temp(pc),a0	*最初のスイッチではない単語を
	bsr	getarg		*　ソースファイル名と見なし
				*　temp以下に取り出す

	movea.l	(sp)+,a2	*a2=AS.Xへ渡す引数

*fname以下にフルパスのソースファイル名＋TABの文字列を作成する
	lea.l	fname(pc),a0	*a0=ファイル名格納領域
	tst.b	(a2)
	beq	ckarg1
	pea.l	nambuf(pc)	*ファイル名を展開してみる
	pea.l	temp(pc)	*
	DOS	_NAMECK		*
	addq.l	#8,sp		*
	tst.l	d0		*
	bne	error2		*負ならエラー
	lea.l	nambuf(pc),a1	
	bsr	strcpy		*ドライブ名＋パスに
	lea.l	nambuf+NAME(pc),a1
	bsr	strcpy		*　ファイル名を加える
	lea.l	nambuf+EXT(pc),a1
	tst.b	(a1)		*拡張子は省略されているか？
	bne	ckarg0		*あればよし
	lea.l	sext(pc),a1	*なければ'.S'を補う
ckarg0:	bsr	strcpy		*拡張子を加える

	move.b	#TAB,(a0)+	*ついでにTABを付け加えておく

ckarg1:	clr.b	(a0)		*終端コード

	rts

*
*	コマンドライン中の
*	　スイッチではない最初の単語位置を得る(a2)
*
fstarg:
	bsr	skipsp		*スペースをスキップ

	cmpi.b	#'/',(a2)	*引数の先頭が
	beq	farg0		*　/,-であれば
	cmpi.b	#'-',(a2)	*
	bne	farg1		*
farg0:	bsr	skipsw		*スイッチ１個をスキップ
	bra	fstarg		*スイッチがなくなるまで繰り返す

farg1:	rts

*
*	スイッチ１個をスキップする
*
skipsw:
	addq.l	#1,a2		*'/'や'-'の分を進めて
	lea.l	temp(pc),a0	*　temp以下に
*	bra	getarg		*　転送する
				*（転送した文字列は使わない）

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
skipsp:			*サブルーチンはここから始まる
	cmpi.b	#SPACE,(a2)	*スペースか？
	beq	skpsp0		*　そうなら飛ばす
	cmpi.b	#TAB,(a2)	*TABか？
	beq	skpsp0		*　そうなら飛ばす
	rts

*
*	文字列の複写
*	リターン時a0は文字列末の00Hを指す
*
strcpy:
	move.b	(a1)+,(a0)+	*１文字ずつ
	bne	strcpy		*終了コードまでを転送する
	subq.l	#1,a0		*a0は進み過ぎている
				*a0は文字列末の00Hを指す
	rts

*
*	中断/エラー終了
*
*
break:	lea.l	brkmes(pc),a0	*^Cなどによる中断
	bra	errout
error1:	lea.l	errms1(pc),a0	*AS.Xが起動できない
	bra	errout
error2:	lea.l	errms2(pc),a0	*不正なファイル名
	*
errout:	bsr	reset_vector	*ベクタを元に戻す

	move.w	#STDERR,-(sp)	*標準エラー出力へ
	move.l	a0,-(sp)	*　メッセージを
	DOS	_FPUTS		*　出力する
	addq.l	#6,sp		*

	move.w	#1,-(sp)	*終了コード１を持って
	DOS	_EXIT2		*　エラー終了

*
*	データ＆ワーク
*
	.data
	.even
*
bufptr:	.dc.l	buff		*バッファ内の次の書き込み位置
efno:	.dc.w	0		*エラーファイルのファイルハンドル
				*=0ならばオープンされていない
hooked:	.dc.b	0		*ベクタ書き換え済みかどうかのフラグ
prog:	.dc.b	'AS.X ',0	*子プロセスとして起動するプログラム名
*
errms1:	.dc.b	'ASX：AS.Xが起動できませんでした',CR,LF,0
errms2:	.dc.b	'ASX：ソースファイル名の指定に誤りがあります',CR,LF,0
brkmes:	.dc.b	'ASX：中断しました',CR,LF,0
crlfms:	.dc.b	CR,LF,0
*
errstr:	.dc.b	'line ',0		*AS.Xのエラーメッセージ冒頭
wrnstr:	.dc.b	'Warning: Line ',0	*AS.Xの警告メッセージ冒頭
efname:	.dc.b	'AS.ERR',0		*エラーファイル名
sext:	.dc.b	'.S',0			*ソースファイルの拡張子
*
	.bss
	.even
*
cmdlin:	.ds.b	STRMAX		*コマンドライン作成用
fname:	.ds.b	STRMAX		*アセンブルするファイル名（フルパス）
temp:				*コマンドライン引数１個分のバッファ
				*　（ダミー）
buff:	.ds.b	BUFSIZ		*AS.Xのメッセージを１行溜め込むバッファ
nambuf:	.ds.b	NAMBUFSIZ	*nameck用バッファ
*
	.stack
	.even
*
mystack:
	.ds.l	1024		*スタック領域
mysp:
	.end
