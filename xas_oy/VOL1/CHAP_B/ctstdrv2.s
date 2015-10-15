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

	bsr	test
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
*	試験用ルーチン
*
test:
	move.l	d1,-(sp)

	bsr	showcmd			*コマンドの種類を表示
	bsr	showlen			*入出力系コマンドであれば
					*　データ長を表示
	move.l	(sp)+,d1
	rts

*
*	コマンドの種類を表示する
*
showcmd:
	moveq.l	#0,d0			*コマンドの種類を表す文字列の
	move.b	CMD_CODE(a5),d0		*　先頭アドレスをa4に得る
	add.w	d0,d0			*
	add.w	d0,d0			*
	lea.l	cmd_table,a4		*
	add.l	d0,a4			*
	movea.l	(a4),a4			*

	move.l	a4,-(sp)		*コマンドの種類を表示する
	move.w	#1,-(sp)		*
	DOS	_CONCTRL		*

	move.l	#crlfms,2(sp)		*改行する
	DOS	_CONCTRL		*
	addq.l	#6,sp			*
	rts

*
*	メッセージへのポインタのテーブル
*
cmd_table:
	.dc.l	mes00,mes01,mes02,mes03
	.dc.l	mes04,mes05,mes06,mes07
	.dc.l	mes08,mes09,mes10,mes11
	.dc.l	mes12

*
*	入出力系コマンドであればデータ長を16進表示する
*
showlen:
	moveq.l	#0,d0			*d0.l=コマンド番号
	move.b	CMD_CODE(a5),d0		*
	move.l	#%00010011_00011000,d1	*入出力系コマンドかどうかを
	btst.l	d0,d1			*　調べる
	beq	slen0			*そうでなければ何もしない

	pea.l	temp			*データ長を16進8桁に変換する
	move.l	DMA_LEN(a5),-(sp)	*
	bsr	itoh			*
	addq.l	#8,sp			*
	pea.l	temp			*表示する
	move.w	#1,-(sp)		*
	DOS	_CONCTRL		*

	move.l	#crlfms,2(sp)		*改行する
	DOS	_CONCTRL		*
	addq.l	#6,sp			*
slen0:	rts

*
*	数値→16進文字列変換
*
value	=	8
buff	=	12
*
itoh:
	link	a6,#0
	movem.l	d0-d2/a0,-(sp)

	move.l	value(a6),d0	*値
	movea.l	buff(a6),a0	*文字列格納アドレス

	moveq.l	#8-1,d2		*以下を８回繰り返す

itoh0:	rol.l	#4,d0		*d0.lを左に４ビット回転する
	move.b	d0,d1		*d0の下位バイトをd1に取り出し
	andi.b	#$0f,d1		*　下位４ビットを残してマスクする
	addi.b	#'0',d1		*ここで数値から16進を表す文字へ
	cmpi.b	#'9'+1,d1	*　変換する
	bcs	itoh1		*　0～9の場合は'0'を足すだけだが
	addq.b	#'A'-'0'-10,d1	*  A～Fの場合はさらに補正が必要

itoh1:	move.b	d1,(a0)+	*変換した文字をしまう

	dbra	d2,itoh0	*繰り返す

	clr.b	(a0)		*文字列終端コードを書き込む

	movem.l	(sp)+,d0-d2/a0
	unlk	a6
	rts

*
*	コマンドの種類表示用文字列
*
mes00:	.dc.b	'初期化',0
mes01:	.dc.b	'コマンド１（無効）',0
mes02:	.dc.b	'コマンド２（無効）',0
mes03:	.dc.b	'IOCTRLによる入力',0
mes04:	.dc.b	'入力',0
mes05:	.dc.b	'先読み入力',0
mes06:	.dc.b	'入力ステータスをチェック',0
mes07:	.dc.b	'入力バッファをクリア',0
mes08:	.dc.b	'出力（VERIFY OFF）',0
mes09:	.dc.b	'出力（VERIFY ON）',0
mes10:	.dc.b	'出力ステータスをチェック',0
mes11:	.dc.b	'コマンド11（無効）',0
mes12:	.dc.b	'IOCTRLによる出力',0
*
crlfms:	.dc.b	CR,LF,0			*改行用文字列
*
temp:	.ds.b	8+1			*16進変換用バッファ
*
	.even
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
