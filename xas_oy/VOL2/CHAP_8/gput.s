*	G-RAMへグラフィックパターンを書き込む

	.include	gconst.h
	.include	gmacro.h
*
	.xdef	gput
	.xref	gramadr
	.xref	gcliprect
	.xref	gcopyline_L
*
	.offset	0	*gputの引数構造
*
X0:	.ds.w	1	*描画先座標
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
PAT:	.ds.l	1	*パターン
*
	.text
	.even
*
gput:
ARGPTR	=	8
	link	a6,#0
	movem.l	d0-d7/a0-a3,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = 引数列
	movem.w	(a1),d0-d3	*d0～d3に座標を取り出す

	jsr	gcliprect	*クリッピングする
	bmi	done		*N=1なら描画の必要なし

	jsr	gramadr		*左上のG-RAM上のアドレスを得る

	sub.w	d0,d2		*d2 = 横ピクセル数-1
	sub.w	d1,d3		*d3 = 縦ピクセル数-1

	movem.w	(a1),d4-d7	*d4～d7にも座標を取り出す
	MINMAX	d4,d6		*d4≦d6を保証
	MINMAX	d5,d7		*d5≦d7を保証

	sub.w	d4,d0		*d0 = 切り取られた左端ピクセル数
	sub.w	d5,d1		*d1 = 切り取られた上端ピクセル数

	sub.w	d4,d6		*d6 = 元のパターンの横ピクセル数-1
	addq.w	#1,d6		*d6 = 元のパターンの横ピクセル数

	movea.l	PAT(a1),a1	*a1 = パターンデータ
	add.w	d0,d0		*クリッピングした分だけ
	adda.w	d0,a1		*
	add.w	d1,d1		*
	mulu.w	d6,d1		*
	adda.l	d1,a1		*　パターンデータを飛ばす

	addq.w	#1,d2		*d2 = 横ピクセル数
	sub.w	d2,d6		*d6 = スキップするピクセル数
	add.w	d6,d6		*d6 = スキップするバイト数

	lea.l	next(pc),a2	*
	bclr.l	#0,d2		*横ピクセル数は奇数か？
	beq	skip		*
	lea.l	odd(pc),a2	*奇数ピクセルのとき

skip:	lea.l	gcopyline_L,a3	*a3 = １ライン分の転送ルーチン
	suba.w	d2,a3		*

	move.w	#GNBYTE,d1	*d1 = ライン間のアドレスの差
	add.w	d2,d2		*
	sub.w	d2,d1		*

loop:	jsr	(a3)		*１ライン転送
	jmp	(a2)		*
odd:	move.w	(a1)+,(a0)	*奇数ピクセルの場合
next:	adda.w	d1,a0		*すぐ下のラインへ
	adda.w	d6,a1		*クリッピングした分
				*　パターンを飛ばす
	dbra	d3,loop		*高さ分繰り返す

done:	movem.l	(sp)+,d0-d7/a0-a3
	unlk	a6
	rts

	.end
