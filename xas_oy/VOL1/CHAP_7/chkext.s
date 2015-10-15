	.text
	.even
*
*	拡張子が省略されていたら
*	適当な拡張子を補う
*
chkext:
	tst.b	nambuf+86	*拡張子はあるか
	bne	chkex0		*　あるなら何もしない

	lea.l	arg,a0		*用意してある拡張子を
	lea.l	dext,a1		*　連結する
	bsr	strcat		*

chkex0:	rts

*
*	文字列を連結する
*	a0=被連結文字列,a1=連結文字列
*
strcat:
	tst.b	(a0)+		*(a0)は0か？
	bne	strcat		*そうでなければ繰り返す
	subq.l	#1,a0		*行きすぎたから１つ戻る
strcpy:
	move.b	(a1)+,(a0)+	*1文字転送
	bne	strcpy		*終了コードまで繰り返す
	rts
*
	.data
	.even
*
dext:	.dc.b	'.$$$',0	*補う拡張子
