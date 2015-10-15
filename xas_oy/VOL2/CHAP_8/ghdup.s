*	パターンの連続水平複写

	.include	gconst.h
*
	.xdef	ghdup
	.xref	gramadr
	.xref	gcliprect
	.xref	gcopyline_L
*
	.offset	0	*ghdupの引数構造
*
X0:	.ds.w	1	*矩形領域
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
DX:	.ds.w	1	*複写する元パターンの幅
*
	.text
	.even
*
ghdup:
ARGPTR	=	8
	link	a6,#0
	movem.l	d0-d4/a0-a3,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = 引数列
	movem.w	(a1),d0-d4	*d0～d3に座標
				*　d4に複写するライン数を取り出す

	jsr	gcliprect	*クリッピングする
	bmi	done		*N=1なら描画の必要なし

	jsr	gramadr		*左上のG-RAM上のアドレスを得る

	sub.w	d0,d2		*d2 = 横ピクセル数-1
	sub.w	d4,d2		*それが複写幅より小さければ
	bmi	done		*　なにもしなくていい
	sub.w	d1,d3		*d3 = 縦ピクセル数-1

	movea.l	a0,a1		*a1 = 転送元
	add.w	d4,d4		*
	adda.w	d4,a0		*a0 = 転送先
*
*

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

loop:	jsr	(a3)		*１ライン描画
	jmp	(a2)		*
odd:	move.w	(a1),(a0)	*奇数ピクセルの場合
next:	adda.w	d1,a0		*すぐ下のラインへ
	adda.w	d1,a1		*すぐ下のラインへ
	dbra	d3,loop		*高さ分繰り返す

done:	movem.l	(sp)+,d0-d4/a0-a3
	unlk	a6
	rts

	.end
