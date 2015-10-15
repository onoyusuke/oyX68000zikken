	.include	doscall.mac
*
	.xdef	child		*外部定義
*
*	EXECモード
*
LOADEXEC	equ	0
PATHCHK		equ	2
*
	.text
	.even
*
*child(cmd)
*機能：	与えられたコマンドラインに従って
*	プログラムをチャイルドプロセスとして起動する
*	d0.lにEXECの終了コードを持って戻る
*	d0.lが負の場合はエラー
*レジスタ破壊：d0.l,ccr
*
*	ex)
*		pea.l	cmd
*		bsr	child
*		addq.l	#4,sp
*		tst.l	d0
*		bmi	error
*		     ：
*	cmd:	.dc.b	'command /cdir',0
*
nambuf	=	-512
cmdlin	=	-256
str	=	8
*
child:
	link	a6,#-512	*512バイトのローカルエリア
	movem.l	d1-d7/a0-a6,-(sp)

	movea.l	str(a6),a1	*与えられた文字列を
	lea.l	nambuf(a6),a0	*　ローカルエリアに
	move.w	#255-1,d0	*　最大255バイト
chld0:	move.b	(a1)+,(a0)+	*　コピーしておく
	dbeq	d0,chld0	*∵上書きされるから
	clr.b	(a0)		*念のための終端コード

	clr.l	-(sp)		*自分の環境
	pea.l	cmdlin(a6)	*パラメータ部格納領域
	pea.l	nambuf(a6)	*コマンドライン兼
				*　フルパス名格納領域
	move.w	#PATHCHK,-(sp)	*PATH検索
	DOS	_EXEC		*
	tst.l	d0		*d0.lが負なら
	bmi	chld1		*　エラー

	move.w	#LOADEXEC,(sp)	*ロード＆実行
	DOS	_EXEC		*
chld1:	lea	14(sp),sp	*スタック補正 4*3+2バイト

	movem.l	(sp)+,d1-d7/a0-a6
	unlk	a6
	rts

	.end
