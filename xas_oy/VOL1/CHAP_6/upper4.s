*	英小文字→英大文字変換フィルタ　第４版

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
	move.w	#STDIN,-(sp)	*
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
	move.w	#STDOUT,-(sp)	*
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

	move.w	#STDOUT,-(sp)	*標準出力の装置情報を取り出す
	clr.w	-(sp)		*
	DOS	_IOCTRL		*
	addq.l	#4,sp		*

	move.b	d0,devflg	*devflgの第７ビットが１であれば
				*　キャラクタデバイス
	rts

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

*
*	ワークエリア
*
	.bss
	.even
*
rptr:	.ds.l	1		*読み込みポインタ（getcharで使用）
rctr:	.ds.l	1		*読み込みカウンタ（getcharで使用）
wptr:	.ds.l	1		*書き出しポインタ（putcharで使用）
wctr:	.ds.l	1		*書き出しカウンタ（putcharで使用）
*
devflg:	.ds.b	1		*出力先フラグ（putchar,puteofで使用）
				*	bit7=0...ファイル
				*	    =1...キャラクタデバイス
*
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
