*	英小文字→英大文字変換フィルタ　第２版

	.include	doscall.mac
*
	.text
	.even
*
ent:
	lea.l	mysp,sp		*spの初期化

loop:	DOS	_GETC		*１文字入力

	cmpi.b	#$1a,d0		*ファイルエンドコードか？
	beq	done		*そうなら終了

	cmpi.b	#$0a,d0		*LFコードか？
	beq	loop		*そうなら無視

	cmpi.b	#$0d,d0		*CRコードか？
	beq	cr_lf		*そうならLF,CRにして出力

	cmpi.b	#$80,d0		*80Hより小さければ
	bcs	hankaku		*	ASCIIコード
	cmpi.b	#$a0,d0		*80H以上A0H未満なら
	bcs	zenkaku		*	シフトJISの１バイト目
	cmpi.b	#$e0,d0		*A0H以上E0H未満なら
	bcs	hankaku		*	ASCIIカタカナ
				*E0H以上なら
				*	シフトJISの１バイト目
*
zenkaku:
	move.w	d0,-(sp)	*シフトJISの１バイト目を
	DOS	_PUTCHAR	*	そのまま出力
	addq.l	#2,sp		*

	DOS	_GETC		*もう１バイト持ってくる
	move.w	d0,-(sp)	*シフトJISの２バイト目も
	DOS	_PUTCHAR	*	そのまま出力
	addq.l	#2,sp		*

	bra	loop		*繰り返す
*
hankaku:
	bsr	toupper		*小文字→大文字変換

	move.w	d0,-(sp)	*１文字出力
	DOS	_PUTCHAR	*
	addq.l	#2,sp		*

	bra	loop		*繰り返す
*
cr_lf:
	move.w	d0,-(sp)	*d0にはCRコードが入っている
	DOS	_PUTCHAR	*CRコードを出力
	move.w	#$0a,(sp)	*LFコードを出力
	DOS	_PUTCHAR	*
	addq.l	#2,sp		*

	bra	loop		*繰り返す
*
done:
	DOS	_EXIT		*終了
*
*英小文字→英大文字変換サブルーチン
toupper:
	cmpi.b	#'a',d0		*英小文字か？
	bcs	toupr0		*
	cmpi.b	#'z'+1,d0	*
	bcc	toupr0		*
	subi.b	#$20,d0		*小文字なら大文字に変換
toupr0:	rts			*サブルーチンからリターン
*
	.stack
	.even
*
mystack:
	.ds.l	256		*スタック領域
mysp:
	.end
