*	矩形領域の複写

	.include	gconst.h
	.include	gmacro.h
*
	.xdef	gcopy
	.xref	gramadr
	.xref	gcliprect
	.xref	gcopyline_L
	.xref	gcopyline_R
*
	.offset	0	*gcopyの引数構造
*
X0:	.ds.w	1	*転送元座標
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
X2:	.ds.w	1	*転送先左上隅座標
Y2:	.ds.w	1	*
*
	.text
	.even
*
gcopy:
ARGPTR	=	8
	link	a6,#0
	movem.l	d0-d7/a0-a3,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = 引数列
	movem.w	(a1),d0-d3	*d0～d3に座標を取り出す

	jsr	gcliprect	*転送元領域をクリッピングする
	bmi	done		*N=1なら転送の必要なし

	jsr	gramadr		*左上のG-RAM上のアドレスを得る

	sub.w	d0,d2		*d2 = 横ピクセル数-1
	sub.w	d1,d3		*d3 = 縦ピクセル数-1

	movem.w	(a1)+,d4-d7	*(x0,y0)-(x1,y1)
	MINMAX	d4,d6		*d4≦d6を保証
	MINMAX	d5,d7		*d5≦d7を保証

				*転送元領域をクリッピングしたときに
	sub.w	d4,d0		*　d0 = 切り取られた左端ピクセル数
	sub.w	d5,d1		*　d1 = 切り取られた上端ピクセル数

	movem.w	(a1)+,d4-d5	*(x2,y2)
	add.w	d0,d4		*切り取られた分だけx2,y2もずらす
	add.w	d1,d5		*
	move.w	d4,d0		*x2'
	move.w	d5,d1		*y2'
	add.w	d4,d2		*x3'
	add.w	d5,d3		*y3'

	sub.w	d2,d6		*d6 = x1'-x3' = x0'-x2'
	sub.w	d3,d7		*d7 = y1'-y3' = y0'-y2'

	jsr	gcliprect	*転送先領域をクリッピングする
	bmi	done		*N=1なら転送の必要なし

	movea.l	a0,a1		*a1 = 転送元アドレス
	jsr	gramadr		*a0 = 転送先アドレス

	sub.w	d0,d2		*d2 = 最終的な転送領域の横ピクセル数-1
	sub.w	d1,d3		*d3 = 最終的な転送領域の縦ピクセル数-1

				*転送先領域をクリッピングしたときに
	sub.w	d4,d0		*　d0 = 切り取られた左端ピクセル数
	sub.w	d5,d1		*　d1 = 切り取られた上端ピクセル数

	add.w	d0,d0		*d0,d1の分だけ
	adda.w	d0,a1		*　転送元アドレスもずらす
	ext.l	d1		*
	moveq.l	#GSFTCTR,d0	*
	lsl.l	d0,d1		*
	adda.l	d1,a1		*

	addq.w	#1,d2		*d2 = 最終的な転送領域の横ピクセル数
	move.w	#GNBYTE,d1	*d1 = ライン間のアドレスの差

	tst.w	d6		*1)x0'＜x2'かつ
	bpl	nright		*
	tst.w	d7		*2)y0' = y2'ならば
	beq	right		*　真右へのコピー

nright:			*真右以外
	lea.l	next(pc),a2	*
	bclr.l	#0,d2		*横ピクセル数は奇数か？
	beq	skip		*
	lea.l	odd(pc),a2	*奇数ピクセルのとき

skip:	lea.l	gcopyline_L,a3	*正方向の転送
	suba.w	d2,a3		*

	add.w	d2,d2		*
	sub.w	d2,d1		*

	tst.w	d7		*y0'<y2'
	bge	down		*　ならば
			*下から上への転送
up:	add.w	d2,d1
	add.w	d2,d1
	neg.w	d1

	moveq.l	#0,d0		*上位ワードをクリア
	move.w	d3,d0		*d0.l = ライン数-1
	moveq.l	#GSFTCTR,d2	*1024（または2048）倍
	lsl.l	d2,d0		*
	adda.l	d0,a0		*a0 = 転送先領域の
				*　一番下のラインの左端アドレス
	adda.l	d0,a1		*a1 = 転送元領域の
				*　一番下のラインの左端アドレス
			*つじつまは合わせたから合流

down:			*上から下への転送
loop:	jsr	(a3)		*１ライン転送
	jmp	(a2)		*
odd:	move.w	(a1),(a0)	*奇数ピクセルの場合
next:	adda.w	d1,a0		*転送先をすぐ下のラインへ
	adda.w	d1,a1		*転送元をすぐ下のラインへ
	dbra	d3,loop		*高さ分繰り返す

done:	movem.l	(sp)+,d0-d7/a0-a3
	unlk	a6
	rts
*
right:			*真右へのコピーは特別扱い
	move.w	d2,d0		*d0 = 横ピクセル数
	add.w	d0,d0		*d0 = １ライン分のバイト数
	adda.w	d0,a0		*a0 = 複写先ライン右端＋２
	adda.w	d0,a1		*a1 = 複写元ライン右端＋２
	add.w	d0,d1

	lea.l	rnext(pc),a2	*
	bclr.l	#0,d2		*横ピクセル数は奇数か？
	beq	rskip		*
	lea.l	rodd(pc),a2	*奇数ピクセルのとき

rskip:	lea.l	gcopyline_R,a3	*逆方向の転送
	suba.w	d2,a3		*

rloop:	jsr	(a3)		*１ライン転送
	jmp	(a2)		*
rodd:	move.w	-(a1),-(a0)	*奇数ピクセルの場合
rnext:	adda.w	d1,a0		*転送先をすぐ下のラインへ
	adda.w	d1,a1		*転送元をすぐ下のラインへ
	dbra	d3,rloop	*高さ分繰り返す

	bra	done

	.end
