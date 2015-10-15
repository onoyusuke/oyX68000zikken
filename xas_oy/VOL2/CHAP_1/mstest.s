*	マウスの使用例

	.include	iocscall.mac
	.include	doscall.mac
*
CR	equ	13
LF	equ	10
*
ent:
	lea.l	inisp(pc),sp

	lea.l	menu(pc),a1	*メニューを描く
	IOCS	_B_PRINT	*

	IOCS	_MS_INIT	*マウス初期化
	IOCS	_MS_CURON	*マウスカーソル表示
	moveq.l	#0,d1		*ソフトウェアキーボード
	IOCS	_SKEY_MOD	*　表示禁止

loop:	IOCS	_MS_GETDT	*ボタンの状態を得る
	tst.w	d0		*左ボタンは押されているか？
	bpl	loop		*　押されていなかった

			*左ボタンが押された
	IOCS	_MS_CURGT	*マウスカーソル座標を得る
	move.w	d0,d1		*d1.w = Y座標
	swap.w	d0		*d0.w = X座標

	cmpi.w	#32,d0		*X座標のチェック
	bcc	loop		*　範囲外
	cmpi.w	#16,d1		*Y座標のチェック
	bcc	loop		*　範囲外

			*終了メニュー上だった
	IOCS	_MS_INIT	*マウス再初期化
	moveq.l	#-1,d1		*ソフトウェアキーボード
	IOCS	_SKEY_MOD	*　表示許可

	DOS	_EXIT		*終了
*
	.data
	.even
*
menu:	.dc.b	26,'終了',CR,LF,0
*
	.stack
	.even
*
mystack:
	.ds.l	256
inisp:
	.end	ent
