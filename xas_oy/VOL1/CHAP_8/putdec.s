	.include	const.h
	.include	doscall.mac
*
	.text
	.even
*
*	16ビット無符号整数を10進左詰めで表示する
*
*		+----------------+
*	(a6)	|      旧a6      |	<-sp
*		+････････････････+
*		|                |
*		+----------------+
*	4(a6)	|リターンアドレス|
*		+････････････････+
*		|                |
*		+----------------+
*	8(a6)	|   表示する値   |
*		+----------------+
*
value	=	8
*
putdec:
	link	a6,#0		*スタックフレーム形成

	move.w	#STDOUT,-(sp)
	move.w	value(a6),-(sp)
	bsr	fputdec
	addq.l	#4,sp

	unlk	a6
	rts

*
*	16ビット無符号整数を10進左詰めでファイルに出力する
*	d0.lにDOSコールfputsの終了コードを持って戻る
*
*		+----------------+
*	-6(a6)	|                |	<-sp
*		+････････････････+
*		|                |
*		+････････････････+
*		|                |
*		+----------------+
*	(a6)	|      旧a6      |
*		+････････････････+
*		|                |
*		+----------------+
*	4(a6)	|リターンアドレス|
*		+････････････････+
*		|                |
*		+----------------+
*	8(a6)	|   表示する値   |
*		+----------------+
*	10(a6)	|ファイルハンドル|
*		+----------------+
*
buffsiz	=	6
temp	=	-buffsiz
value	=	8
fno	=	10
*
fputdec:
	link	a6,#-buffsiz	*スタックフレーム形成
				*＋ローカルエリア確保

	pea.l	temp(a6)	*数値→文字列変換
	move.w	value(a6),-(sp)	*
	bsr	utoa		*
	addq.l	#6,sp		*

	move.w	fno(a6),-(sp)	*変換後の文字列を出力
	pea.l	temp(a6)	*
	DOS	_FPUTS		*
	addq.l	#6,sp		*

	unlk	a6		*スタックフレーム解放
	rts

*
*	16ビット無符号整数を文字列に変換する
*
*		+----------------+
*	(a6)	|      旧a6      |	<-sp
*		+････････････････+
*		|                |
*		+----------------+
*	4(a6)	|リターンアドレス|
*		+････････････････+
*		|                |
*		+----------------+
*	8(a6)	|      値        |
*		+----------------+
*	10(a6)	| 文字列格納領域 |
*		+････････････････+
*		|   へのポインタ |
*		+----------------+
*
value	=	8
buff	=	10
*
utoa:
	link	a6,#0		*スタックフレーム形成
	movem.l	d0/a0-a1,-(sp)	*｛レジスタ待避

	moveq.l	#0,d0		*d0.l=表示する数
	move.w	value(a6),d0	*
	movea.l	buff(a6),a1	*a1=文字列格納領域先頭
	lea.l	5(a1),a0	*a0=文字列格納領域最終
	clr.b	(a0)		*終端コード書き込み

utoa0:	divu.w	#10,d0		*d0.lを10で割る
	swap.w	d0		*上位ワードと下位ワードを交換
	addi.w	#'0',d0		*0〜9 → '0'〜'9'
	move.b	d0,-(a0)	*1桁格納
	clr.w	d0		*次の除算に備える
	swap.w	d0		*上位ワードと下位ワードを交換
	bne	utoa0

utoa1:	move.b	(a0)+,(a1)+	*左詰めにする
	bne	utoa1		*

	movem.l	(sp)+,d0/a0-a1	*｝レジスタ復帰
	unlk	a6		*スタックフレーム解放
	rts

	.end
