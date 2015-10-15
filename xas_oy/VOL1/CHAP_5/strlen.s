*	文字列の長さを数え表示する

	.include	doscall.mac
*
	.text
	.even
*
ent:
	lea.l	mysp,sp		*spの初期化

	lea.l	str1,a0		*文字列へのポインタ
	bsr	strlen		*文字列の長さを数える

	bsr	prtdec		*結果を10進表示
				*改行はしていない
	DOS	_EXIT		*終了
*
*文字列の長さを数えるサブルーチン
strlen:
	moveq.l	#-1,d0		*カウンタの初期化
strlen0:
	addq.w	#1,d0		*カウント
	tst.b	(a0)+		*終了コードか？
	bne	strlen0		*そうでなければ繰り返す
	rts
*
*D0.Wを10進左詰めで表示するサブルーチン
prtdec:
	movem.l	d0/a0,-(sp)	*d0,a0をスタックに待避

	andi.l	#$0000ffff,d0	*上位ワードをクリア
	lea.l	bufend,a0	*ポインタ初期化
prtdec0:
	divu.w	#10,d0		*d0.lを10で割る
				*	上位ワード = 余り
				*	下位ワード = 商
	swap.w	d0		*上位ワードと下位ワードを交換
				*	上位ワード = 商
				*	下位ワード = 余り
	addi.w	#'0',d0		*0～9 → '0'～'9'
	move.b	d0,-(a0)	*1桁格納
	clr.w	d0		*次の除算に備える
				*	上位ワード = さっきの商
				*	下位ワード = 0
	swap.w	d0		*上位ワードと下位ワードを交換
				*	上位ワード = 0
				*	下位ワード = さっきの商
	bne	prtdec0

	move.l	a0,-(sp)
	DOS	_PRINT
	addq.l	#4,sp

	movem.l	(sp)+,d0/a0
	rts
*
str1:	.dc.b	'1234567890ABCDEFGHIJK',0	*テスト文字列
*
buff:	.ds.b	5		*10進文字列格納領域
bufend:	.dc.b	0		*文字列の終了コード
*
	.stack
	.even
*
mystack:
	.ds.l	256		*スタック領域
mysp:
	.end
