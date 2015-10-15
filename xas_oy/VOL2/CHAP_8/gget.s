*	G-RAMからグラフィックパターンを取り込む

	.include	gconst.h
*
	.xdef	gget
	.xref	gramadr
	.xref	gcliprect
	.xref	gcopyline_L
*
	.offset	0	*ggetの引数構造
*
X0:	.ds.w	1	*取り込む矩形座標
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
BUF:	.ds.l	1	*パターン取り込み用バッファ
*
	.text
	.even
*
gget:
ARGPTR	=	8
	link	a6,#0
	movem.l	d0-d3/a0-a3,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = 引数列
	movem.w	(a1),d0-d3	*d0～d3に座標を取り出す

	jsr	gcliprect	*クリッピングする
	bmi	done		*N=1なら転送の必要なし

	jsr	gramadr		*左上のG-RAM上のアドレスを得る

	sub.w	d0,d2		*d2 = 横ピクセル数-1
	sub.w	d1,d3		*d3 = 縦ピクセル数-1

	movea.l	BUF(a1),a1	*a1 = 転送先
	exg.l	a0,a1		*a0 = 転送先
				*a1 = G-RAMアドレス

	addq.w	#1,d2		*d2 = 横ピクセル数
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
odd:	move.w	(a1),(a0)+	*奇数ピクセルの場合
next:	adda.w	d1,a1		*すぐ下のラインへ
	dbra	d3,loop		*高さ分繰り返す

done:	movem.l	(sp)+,d0-d3/a0-a3
	unlk	a6
	rts

	.end
