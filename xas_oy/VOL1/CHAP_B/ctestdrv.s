*	実験用デバイスドライバ

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
	.dc.b	'CHRTEST '
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
	movem.l	d0/a4-a5,-(sp)		*レジスタ待避

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

	movem.l	(sp)+,d0/a4-a5		*レジスタ復帰
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
	tst.l	DMA_LEN(a5)		*入力要求が０バイトであれば
	beq	done			*　何もせずに戻る
				*そうでなければ
	movea.l	DMA_ADR(a5),a4		*a4=データ読み込み領域
	move.b	#EOF,(a4)		*入力データをセット

done:	moveq.l	#0,d0			*正常終了
	rts

*
*	１バイト先読み入力（コマンドコード5）
*
sense:
	move.b	#EOF,SNS_DATA(a5)	*先読みデータをセット
	bra	done			*正常終了

*
inpstat:		*入力ステータスチェック（コマンドコード6）
flush:			*入力バッファクリア（コマンドコード7）
output:			*VERIFY OFF時の出力（コマンドコード8）
voutput:		*VERIFY ON時の出力（コマンドコード9）
outstat:		*出力ステータスチェック（コマンドコード10）
	bra	done			*正常終了
*
*	↑ここまでがメモリに居坐るデバイスドライバ本体

*
*	初期化（コマンドコード0）
*
init:
	pea.l	title			*タイトルを表示
	DOS	_PRINT			*
	addq.l	#4,sp			*

	move.l	#init,DEV_END_ADR(a5)	*デバイスドライバ本体の
					*　最終アドレスをセット

	bra	done			*正常終了
*
	.data
	.even
*
title:					*タイトルメッセージ
	.dc.b	CR,LF
	.dc.b	'実験用キャラクタデバイス',CR,LF
	.dc.b	'CHRTESTの名前で入出力試験が行えます',CR,LF
	.dc.b	0

	.end
