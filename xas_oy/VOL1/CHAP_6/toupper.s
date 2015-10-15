*半角英小文字→英大文字変換サブルーチン

toupper:
	cmpi.b	#'a',d0		*英小文字か？
	bcs	toupr0		*
	cmpi.b	#'z'+1,d0	*
	bcc	toupr0		*
	subi.b	#$20,d0		*小文字なら大文字に変換
toupr0:	rts			*サブルーチンからリターン
