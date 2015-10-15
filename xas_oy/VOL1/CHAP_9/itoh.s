	.xdef	itoh		*外部定義
*
	.text
	.even
*
*itoh(value,buff)
*機能：	32ビット整数を16進８桁の文字列に変換する
*レジスタ破壊：ccr
*
*	ex)
*		pea.l	buff
*		move.l	#$12345678,-(sp)
*		bsr	itoh
*		addq.l	#8,sp
*		     ：
*	buff:	.ds.b	8+1
*
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
