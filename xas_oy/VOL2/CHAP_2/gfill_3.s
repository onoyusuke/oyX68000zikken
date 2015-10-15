*	矩形の塗り潰し（２ピクセル同時書き込み版）

	.include	gconst.h
*
	.xdef	gfill
	.xref	gramadr
	.xref	gcliprect
*
	.offset	0	*gfillの引数構造
*
X0:	.ds.w	1	*描画先座標
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
COL:	.ds.w	1	*描画色
*
	.text
	.even
*
gfill:
ARGPTR	=	8
	link	a6,#0
	movem.l	d0-d3/a0-a2,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = 引数列
	movem.w	(a1),d0-d3	*d0～d3に座標を取り出す

	jsr	gcliprect	*クリッピングする
	bmi	done		*N=1なら描画の必要なし

	jsr	gramadr		*左上のG-RAM上のアドレスを得る

	sub.w	d0,d2		*d2 = 横ピクセル数-1
	sub.w	d1,d3		*d3 = 縦ピクセル数-1

	move.w	COL(a1),d0	*d0 = 描画色
	swap.w	d0		*
	move.w	COL(a1),d0	*

	addq.w	#1,d2		*d2 = 横ピクセル数
	lea.l	next(pc),a2	*
	bclr.l	#0,d2		*横ピクセル数は奇数か？
	beq	skip		*
	lea.l	odd(pc),a2	*奇数ピクセルのとき

skip:	lea.l	hline0(pc),a1	*
	suba.w	d2,a1		*a1 = 横ピクセル数（偶数）の
				*　水平線分描画ルーチン先頭

	move.w	#GNBYTE,d1	*d1=ライン間のアドレスの差
	add.w	d2,d2		*
	sub.w	d2,d1		*

loop:	jmp	(a1)		*１ライン描画
hline:	.dcb.w	GNPIXEL/2,$20c0	*move.l	d0,(a0)+
hline0:	jmp	(a2)
odd:	move.w	d0,(a0)		*奇数ピクセルの場合
next:	adda.w	d1,a0		*すぐ下のラインへ
	dbra	d3,loop		*高さ分繰り返す

done:	movem.l	(sp)+,d0-d3/a0-a2
	unlk	a6
	rts

	.end
