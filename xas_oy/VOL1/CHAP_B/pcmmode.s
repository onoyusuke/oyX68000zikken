*	IOCTRLによる出力を利用して
*	ADPCMドライバのサンプリング周波数を設定する
*
	.include	doscall.mac
	.include	const.h
*
	.text
	.even
*
ent:
	lea.l	mysp,sp		*spの初期化

	bsr	chksw		*コマンドラインの解析

	bsr	do		*メイン処理

	DOS	_EXIT		*正常終了

*
*	メイン処理
*
do:
	move.w	#RWOPEN,-(sp)	*'PCM'を読み書き両用モードで
	pea.l	pcmnam		*オープンしてみる
	DOS	_OPEN		*
	addq.l	#6,sp		*

	move.w	d0,d1		*d1=ファイルハンドル
	bmi	error1		*負であればオープンできなかった
				*（PCMドライバが組み込まれていない）

	move.w	d1,-(sp)	*オープンしたファイルハンドルの
	clr.w	-(sp)		*　装置情報を取得する
	DOS	_IOCTRL		*
	addq.l	#4,sp		*

	tst.b	d0		*装置情報の第７ビットが０ならば
	bpl	error1		*　デバイスではない
				*　（PCMドライバが存在せず、
				*　　偶然同名のファイルがあった）

	add.w	d0,d0		*装置情報の第14ビットが０ならば
	bpl	error2		*　IOCTRLが許可されていない

	move.l	#2,-(sp)	*出力データは２バイト
	pea.l	mode		*出力データアドレス
	move.w	d1,-(sp)	*ファイルハンドル
	move.w	#3,-(sp)	*出力モード
	DOS	_IOCTRL		*
	lea.l	12(sp),sp	*

	tst.l	d0		*戻り値が負ならエラー
	bmi	error2		*

	move.w	d1,-(sp)	*ファイルハンドルをクローズ
	DOS	_CLOSE		*
	addq.l	#2,sp		*

	rts			*処理完了

*
*	オプションスイッチの解析
*
chksw:
	tst.b	(a2)+		*コマンドライン引数はあるか？
	beq	usage		*　なければエラー
				*a2=コマンドライン文字列先頭
chksw0:	bsr	skipsp		*先頭のスペースを飛ばす
	cmpi.b	#'/',(a2)	*先頭が'/'か'-'でなければエラー
	beq	chksw1		*
	cmpi.b	#'-',(a2)	*
	bne	usage		*
chksw1:	addq.l	#1,a2		*
	move.b	(a2)+,d0	*スイッチを取り出す

	subi.b	#'0',d0		*文字→数値変換
	bcs	usage		*
	cmpi.b	#4+1,d0		*上限のチェック
	bcc	usage		*

	move.b	d0,mode		*ワークに格納する

	bsr	skipsp		*スペースを飛ばす
	tst.b	(a2)		*まだ文字列があれば
	bne	usage		*　引数が多過ぎる

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
*	エラー終了/使用法の表示
*
usage:
	lea.l	usgmes,a0	*使用法メッセージ
	bra	errout
*
error1:	lea.l	errms1,a0	*PCMドライバがない
	bra	errout
error2:	lea.l	errms2,a0	*IOCTRLを受け付けない
	*
errout:	move.w	#STDERR,-(sp)	*標準エラー出力へ
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
pcmnam:	.dc.b	'PCM',0		*出力先デバイス名
mode:	.dc.b	$00,$03		*出力データ
*
usgmes:	.dc.b	'機　能：PCMドライバのサンプリング周波数を'
	.dc.b		'設定します',CR,LF
	.dc.b	'使用法：PCMMODE［スイッチ］',CR,LF
	.dc.b	TAB,'/0	3.9kHz',CR,LF
	.dc.b	TAB,'/1	5.2kHz',CR,LF
	.dc.b	TAB,'/2	7.8kHz',CR,LF
	.dc.b	TAB,'/3	10.4kHz',CR,LF
	.dc.b	TAB,'/4	15.6kHz（標準状態）',CR,LF
	.dc.b	0
*
errms1:	.dc.b	'PCMMODE：PCMドライバが組み込まれていません',CR,LF,0
errms2:	.dc.b	'PCMMODE：うまく設定できませんでした',CR,LF,0
*
	.stack
	.even
*
mystack:
	.ds.l	256		*スタック領域
mysp:
	.end
