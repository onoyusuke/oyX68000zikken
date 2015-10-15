	.include	doscall.mac
*
	.xdef	command		*外部定義
	.xref	child		*外部参照
*
	.text
	.even
*
*command(cmd)
*機能：	command.xをチャイルドプロセスとして起動する
*	d0.lにEXECの終了コードを持って戻る
*	d0.lが負の場合はエラー
*レジスタ破壊：d0.l,ccr
*
*	ex)
*		pea.l	cmd
*		bsr	command
*		addq.l	#4,sp
*		tst.l	d0
*		bmi	error
*		     ：
*	cmd:	.dc.b	'dir | more',0
*
temp	=	-256
str	=	8
*
command:
	link	a6,#-256
	movem.l	a0-a1,-(sp)

	lea.l	temp(a6),a0	*一時領域に
	lea.l	comstr,a1	*  'command 'の文字列を
	move.w	#255-1,d0	*　コピーする
com0:	move.b	(a1)+,(a0)+	*
	dbeq	d0,com0		*

	subq.l	#1,a0		*a0は行き過ぎている

	movea.l	str(a6),a1	*与えられた文字列を
com1:	move.b	(a1)+,(a0)+	*　それに連結する
	dbeq	d0,com1		*（合計で255バイトまで）

	clr.b	(a0)		*念のための終端コード

	pea.l	temp(a6)	*"command "+strを
	bsr	child		*　実行する
	addq.l	#4,sp		*

	movem.l	(sp)+,a0-a1
	unlk	a6
	rts
*
	.data
	.even
*
comstr:	.dc.b	'command ',0

	.end
