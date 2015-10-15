*	ファイルコピーサンプル　その２

	.include	doscall.mac
*
	.text
	.even
*
ent:
	lea.l	mysp,sp		*spの初期化

	clr.w	-(sp)		*入力先ファイルを
	pea.l	sour		*　読み込み用にオープン
	DOS	_OPEN		*
	addq.l	#6,sp		*

	tst.l	d0		*エラー？
	bmi	error		*　そうならエラー終了

	move.w	d0,d1		*d1.w=入力先ファイルハンドル

	move.w	#$0020,-(sp)	*出力先ファイルを新規作成
	pea.l	dest		*
	DOS	_CREATE		*
	addq.l	#6,sp		*

	tst.l	d0		*エラー？
	bmi	error		*　そうならエラー終了

	move.w	d0,d2		*d2.w=出力先ファイルハンドル

loop:
	move.l	#1024,-(sp)	*1024バイト読み込む
	pea.l	buffer		*
	move.w	d1,-(sp)	*　
	DOS	_READ		*
	lea.l	10(sp),sp	*

	tst.l	d0		*d0.lが
	bmi	error		*　負ならエラー
	beq	done		*　０ならファイルの終わり
				*　それ以外なら読み込んだバイト数
	move.l	d0,d3		*d3.l = 読み込んだバイト数


	move.l	d3,-(sp)	*読み込んだ分だけ書き出す
	pea.l	buffer		*
	move.w	d2,-(sp)	*
	DOS	_WRITE		*
	lea.l	10(sp),sp	*

	tst.l	d0		*エラー？
	bmi	error		*　そうならエラー終了
				*d0.l = 実際に書き出したバイト数
	cmp.l	d3,d0		*実際に指定しただけ書き出せたか？
	bcs	error		*　足りなければエラー

	bra	loop		*繰り返す

done:	DOS	_ALLCLOSE	*ファイルを閉じる
	DOS	_EXIT		*終了

*
error:			*エラー処理
	pea.l	errmes		*エラーメッセージを表示
	DOS	_PRINT		*
	addq.l	#4,sp		*

	move.w	#1,-(sp)	*終了コード１を持って
	DOS	_EXIT2		*　終了

*
sour:	.dc.b	'FILE1',0	*転送元ファイル名
dest:	.dc.b	'FILE2',0	*転送先ファイル名
errmes:	.dc.b	'エラーです'	*エラーメッセージ
	.dc.b	$0d,$0a,0	*
*
buffer:	.ds.b	1024		*読み込み用バッファ1024バイト分
*
	.stack
	.even
*
mystack:
	.ds.l	256		*スタック領域
mysp:
	.end
