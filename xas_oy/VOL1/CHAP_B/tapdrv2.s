*	TAPドライバ（バッファサイズ可変版）

	.include	doscall.mac
	.include	const.h
	.include	driver.h
*
	.text
	.even
*
*	デバイスヘッダ
*
device_header:
	.dc.l	-1
	.dc.w	CHAR_DEVICE+DISABLE_IOCTRL+COOKED_MODE
	.dc.l	strategy_entry
	.dc.l	interrupt_entry
	.dc.b	'TAP     '
*		 12345678
*
request_header:			*リクエストヘッダ待避領域
	.dc.l	0

*
*	ストラテジルーチン
*
strategy_entry:
	move.l	a5,request_header	*リクエストヘッダへのポインタを
					*　待避して
	rts				*速やかに戻る

*
*	割り込みルーチン
*
interrupt_entry:
	movem.l	d0-d2/a0-a1/a4-a5,-(sp)	*レジスタ待避

	movea.l	request_header,a5	*a5=リクエストヘッダ

	moveq.l	#0,d0			*d0.l=コマンドコード
	move.b	CMD_CODE(a5),d0		*
	add.w	d0,d0			*2倍する
	add.w	d0,d0			*2倍の2倍で4倍
	lea.l	jump_table,a4		*a4=ジャンプテーブル先頭
	adda.l	d0,a4			*a4=コマンド処理ルーチンへの
					*　ポインタへのポインタ
	movea.l	(a4),a4			*a4=コマンド処理ルーチンへの
					*　ポインタ
	jsr	(a4)			*a4の指すアドレスを
					*　サブルーチンコール

	move.b	d0,ERR_LOW(a5)		*終了ステータスをセット
	lsr.w	#8,d0			*
	move.b	d0,ERR_HIGH(a5)		*

	movem.l	(sp)+,d0-d2/a0-a1/a4-a5	*レジスタ復帰
	rts				*Humanへ戻る

*
*	コマンド処理ジャンプテーブル
*
jump_table:
	.dc.l	init		*0	初期化
	.dc.l	notcmd		*1	（無効）
	.dc.l	notcmd		*2	（無効）
	.dc.l	ioctrl_in	*3	IOCTRLによる入力
	.dc.l	input		*4	入力
	.dc.l	sense		*5	１バイト先読み入力
	.dc.l	inpstat		*6	入力ステータスをチェック
	.dc.l	flush		*7	入力バッファをクリア
	.dc.l	output		*8	出力（VERIFY OFF）
	.dc.l	voutput		*9	出力（VERIFY ON）
	.dc.l	outstat		*10	出力ステータスをチェック
	.dc.l	notcmd		*11	（無効）
	.dc.l	ioctrl_out	*12	IOCTRLによる出力

*
*	各コマンドの処理
*

*
*	無効（コマンドコード1,2,11）
*	IOCTRLによる入力（コマンドコード3）
*	IOCTRLによる出力（コマンドコード12）
*
notcmd:
ioctrl_in:
ioctrl_out:
	move.w	#ILLEGAL_CMD,d0		*エラーコードを持って
	rts				*　戻る

*
*	入力（コマンドコード4）
*
input:
	move.l	DMA_LEN(a5),d2		*入力要求が０バイトであれば
	beq	done			*　何もせずに戻る
				*そうでなければ
	movea.l	readptr,a0		*a0=読み出し位置
	movea.l	DMA_ADR(a5),a4		*a4=データ読み込み領域
					*d2.l=入力要求バイト数

inp0:	cmpa.l	writeptr,a0		*データがもうなければ
	beq	empty			*　ループを抜ける
	move.b	(a0)+,(a4)+		*1バイト転送
	cmpa.l	buffend,a0		*ポインタがバッファ最後を
	bcs	inp1			*　越えたら
	lea.l	bufftop,a0		*　先頭を指すように修正する
inp1:	subq.l	#1,d2			*ループカウンタd2.lが0になるまで
	bne	inp0			*　繰り返す

	move.l	a0,readptr		*読み出し用ポインタ更新

done:	moveq.l	#0,d0			*正常終了
	rts

empty:	move.b	#EOF,(a4)		*バッファが空の場合は
					*　EOFを返す
	bra	done			*正常終了

*
*	VERIFY OFF時の出力（コマンドコード8）
*	VERIFY ON時の出力（コマンドコード9）
output:
voutput:
	move.l	DMA_LEN(a5),d2		*入力要求が０バイトであれば
	beq	done			*　何もせずに戻る
				*そうでなければ
	movea.l	writeptr,a0		*a0=次に書き込む位置
	movea.l	readptr,a1		*a1=次に読み出す位置
	movea.l	DMA_ADR(a5),a4		*a4=出力データ
					*d2.l=出力要求バイト数

	moveq.l	#0,d1			*作業用レジスタをクリア

out0:	move.b	(a4)+,d1		*１バイト取り出す
	move.b	d1,(a0)+		*バッファに追加

	cmpi.b	#EOF,d1			*EOFコードは画面クリアの
					*　コントロールコードなので
	beq	out1			*　表示はしない

	move.l	d1,-(sp)		*１バイト画面に出力
	DOS	_CONCTRL		*
	addq.l	#4,sp			*

out1:	cmpa.l	buffend,a0		*ポインタがバッファ最後を
	bcs	out2			*　越えたら
	lea.l	bufftop,a0		*　先頭を指すように修正する

out2:	cmpa.l	a1,a0			*書き込み位置が読みだし位置に
	bne	out3			*　追いついてしまった場合は
	addq.l	#1,a1			*　読みだし位置を強制的にずらす

	cmpa.l	buffend,a1		*その結果読み出し位置が
	bcs	out3			*　バッファ最後を越えたら
	lea.l	bufftop,a1		*　先頭を指すように修正する

out3:	subq.l	#1,d2			*ループカウンタd2.lが0になるまで
	bne	out0			*　繰り返す

	move.l	a0,writeptr		*書き込み用ポインタ更新
	move.l	a1,readptr		*読み出し用ポインタ更新

	bra	done			*正常終了

*
*	１バイト先読み入力（コマンドコード5）
*
sense:
	moveq.l	#EOF,d0			*仮にEOFコードを入れておく
	movea.l	readptr,a0		*読み出しポインタと
	cmpa.l	writeptr,a0		*　書き込みポインタが
	beq	sense0			*　等しければバッファは空
	move.b	(a0),d0			*そうでなければ何かあるから
					*　ポインタは固定のまま取り出す
sense0:	move.b	d0,SNS_DATA(a5)		*先読みデータをセット
	bra	done			*正常終了

*
*	入力バッファクリア（コマンドコード7）
flush:
	move.l	writeptr,readptr	*書き込み位置と
					*　読み出し位置を一致させる
	bra	done			*正常終了

*
inpstat:		*入力ステータスチェック（コマンドコード6）
outstat:		*出力ステータスチェック（コマンドコード10）
	bra	done			*正常終了（常に入出力可）
*
readptr:
	.dc.l	bufftop			*次に読み出す位置を指すポインタ
writeptr:
	.dc.l	bufftop			*次に書き込む位置を指すポインタ
buffend:
	.dc.l	0			*バッファ最終アドレス+1
*
*	↓以下をバッファとして使用
bufftop:

	.xref	putdec			*外部参照
*
*	初期化部（コマンドコード0）
*
init:

	pea.l	title			*タイトルを表示
	DOS	_PRINT			*
	addq.l	#4,sp			*

	bsr	getbufsiz		*バッファサイズ取得

	move.w	d0,-(sp)		*(sp)=バッファサイズ（単位K）

	lea.l	bufftop,a4		*a4=バッファ先頭
	moveq.l	#10,d1			*1024倍
	lsl.l	d1,d0			*
					*d0.l=バッファサイズ
	add.l	d0,a4			*a4=バッファ最終+1
	move.l	a4,buffend		*
	move.l	a4,DEV_END_ADR(a5)	*デバイスドライバで使用する
					*　メモリの最終アドレスをセット

	bsr	putdec			*バッファサイズを表示
	addq.l	#2,sp			*

	pea.l	mes2			*初期化完了メッセージを表示
	DOS	_PRINT			*
	addq.l	#4,sp			*

	bra	done			*正常終了

*
*	CONFIG.SYSで指定されたバッファサイズを取得する
*
getbufsiz:
	movea.l	PAR_PTR(a5),a4		*a4=パラメータ先頭

*	'TAPDRV.SYS',0,'#/B64',0,0
*	 ^a4

skip:	tst.b	(a4)+			*ファイル名を飛ばす
	bne	skip			*

*	'TAPDRV.SYS',0,'#/B64',0,0
*			^a4

	tst.b	(a4)			*パラメータがなければ
	beq	default			*　デフォルト値を使う

	cmpi.b	#'#',(a4)+		*'#/B'の並びを順にチェック
	bne	inierr			*
	cmpi.b	#'/',(a4)+		*
	bne	inierr			*
	move.b	(a4)+,d0		*
	andi.b	#%1101_1111,d0		*大文字化
	cmpi.b	#'B',d0			*
	bne	inierr			*

*	'TAPDRV.SYS',0,'#/B64',0,0
*			   ^a4

	bsr	atoi			*文字列→数値変換
	tst.w	d0			*0なら
	beq	inierr			*　正しくない
	cmpi.l	#1024+1,d0		*上限のチェック
	bcc	inierr			*

	rts			*d0.w=バッファサイズ（単位K）
*
inierr:
	pea.l	mes1			*エラーメッセージを表示
	DOS	_PRINT			*
	addq.l	#4,sp			*
*	bra	default
default:
	moveq.l	#16,d0			*仮に16Kバイト確保
	rts

*
*	文字列→数値変換
*
atoi:
	moveq.l	#0,d0			*結果を入れるd0.lをクリア
	moveq.l	#0,d1			*
atoi0:	move.b	(a4)+,d1		*１文字取り出す
	subi.b	#'0',d1			*文字→数値変換
	bcs	atoi1			*
	cmpi.b	#'9'+1,d1		*
	bcc	atoi1			*
	mulu.w	#10,d0			*10倍して
	add.w	d1,d0			*　１桁追加
	bra	atoi0			*繰り返す
atoi1:	rts

*
ent:					*安全のため
	DOS	_EXIT
*
	.data
	.even
*
title:					*タイトルメッセージ
	.dc.b	CR,LF,'TAP DRIVER for X68000',CR,LF,0
mes1:	.dc.b	'パラメータの指定に誤りがあります',CR,LF
	.dc.b	'バッファサイズは以下の形式で指定します',CR,LF
	.dc.b	TAB,'DEVICE = TAPDRV.SYS #/Bn',CR,LF
	.dc.b	TAB,'（nは1Kバイト単位）',CR,LF
	.dc.b	'仮に',0
mes2:	.dc.b	'Kバイトのバッファを確保しました',CR,LF
	.dc.b	'TAPのデバイス名で入出力が行えます',CR,LF,0
*
	.end	ent
