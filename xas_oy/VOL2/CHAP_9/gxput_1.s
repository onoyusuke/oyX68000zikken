*	グラフィックパターンを拡大/縮小してプットする（第１版）

	.include	gconst.h
	.include	gmacro.h
*
	.xdef	gxput
	.xref	gramadr
*
	.offset	0	*gxputの引数構造
*
X0:	.ds.w	1	*描画先座標
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
PAT:	.ds.l	1	*パターンアドレス
XL:	.ds.w	1	*パターン横長さ-1
YL:	.ds.w	1	*パターン縦長さ-1
*
	.text
	.even
*
gxput:
ARGPTR	=	4+8*4+7*4
	movem.l	d0-d7/a0-a6,-(sp)

	movea.l	ARGPTR(sp),a6	*a6 = 引数列

	movem.w	(a6)+,d0-d3	*d0〜d3 = 描画範囲の座標
	MINMAX	d0,d2		*x0≦x1を保証する
	MINMAX	d1,d3		*y0≦y1を保証する

	movea.l	(a6)+,a1	*a1 = パターン先頭アドレス
	movem.w	(a6)+,a2-a3	*a2 = パターン横ピクセル数-1
				*a3 = パターン縦ピクセル数-1

	sub.w	d0,d2		*d2 = 描画範囲の横ピクセル数-1
	sub.w	d1,d3		*d3 = 描画範囲の縦ピクセル数-1

	jsr	gramadr		*a0 = 描画先左上G-RAMアドレス

	lea.l	1(a2),a4	*a4 = パターン１ライン分ピクセル数
	adda.l	a4,a4		*a4 = パターン１ライン分バイト数

	move.w	d2,d0		*
	neg.w	d0		*d0 = xについての誤差項初期値
	bne	fix0		*描画先幅が１ピクセルしかない場合の
	move.w	d0,a2		*　つじつま合わせ
fix0:	move.w	d2,d4		*d4 = xループカウンタ初期値
	add.w	d2,d2		*d2 = xについての誤差項補正値
	add.w	a2,a2		*a2 = xについての誤差項増分

	move.w	d3,d1		*
	neg.w	d1		*d1 = yについての誤差項初期値
	bne	fix1		*描画先高が１ピクセルしかない場合の
	move.w	d1,a3		*　つじつま合わせ
fix1:	move.w	d3,d5		*d5 = yループカウンタ初期値
	add.w	d3,d3		*d3 = yについての誤差項補正値
	add.w	a3,a3		*a3 = yについての誤差項増分

yloop:	movea.l	a0,a5		*a5 = 描画先
	movea.l	a1,a6		*a6 = 参照元

	move.w	d0,d6		*d6 = x誤差項
	move.w	d4,d7		*d7 = xループカウンタ
xloop:	move.w	(a6),(a5)+	*１ピクセル書き込む
	add.w	a2,d6		*xについての誤差を累積させる
	ble	xnext		*
xinclp:	addq.l	#2,a6		*参照元x座標を進める
	sub.w	d2,d6		*x誤差項を補正する
	bgt	xinclp		*誤差項が0以下になるまで繰り返す
xnext:	dbra	d7,xloop	*横幅分繰り返す

	add.w	a3,d1		*yについての誤差を累積させる
	ble	ynext		*
yinclp:	adda.l	a4,a1		*参照元y座標を進める
	sub.w	d3,d1		*y誤差項を補正する
	bgt	yinclp		*誤差項が0以下になるまで繰り返す

ynext:	lea.l	GNBYTE(a0),a0	*描画先y座標を進める
	dbra	d5,yloop	*高さ分繰り返す

done:	movem.l	(sp)+,d0-d7/a0-a6
	rts

	.end
