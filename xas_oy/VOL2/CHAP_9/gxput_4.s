*	グラフィックパターンを拡大/縮小してプットする（最終版）

	.include	gconst.h
	.include	gmacro.h
*
	.xdef	gxput
	.xref	gramadr
	.xref	cliprect
	.xref	ucliprect
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
TEMP:	.ds.l	1	*テーブル用
*
	.text
	.even
*
gxput:
ARGPTR	=	4+8*4+7*4
	movem.l	d0-d7/a0-a6,-(sp)

	movea.l	ARGPTR(sp),a6	*a6 = 引数列

	movem.w	(a6)+,d0-d3	*描画範囲の座標を取り出す
	MINMAX	d0,d2		*x0≦x1を保証する
	MINMAX	d1,d3		*y0≦y1を保証する

	movea.l	(a6)+,a1	*a1 = パターン先頭アドレス
	movem.w	(a6)+,a2-a3	*a2 = パターン横ピクセル数-1
				*a3 = パターン縦ピクセル数-1
	movea.l	(a6),a6		*a6 = テーブル用ワーク

	lea.l	cliprect,a0	*a0 = クリッピング範囲
	cmp.w	(a0)+,d2	*x1＜minxならウィンドウ外
	blt	done
	cmp.w	(a0)+,d3	*y1＜minyならウィンドウ外
	blt	done
	cmp.w	(a0)+,d0	*x0＞maxxならウィンドウ外
	bgt	done
	cmp.w	(a0)+,d1	*y0＞maxyならウィンドウ外
	bgt	done

	lea.l	ucliprect,a0	*a0 = クリッピング範囲（ゲタ履き）
	move.w	#$8000,d5	*x0,y0,x1,y1に8000Hのゲタを履かせる
	add.w	d5,d0		*
	add.w	d5,d1		*
	add.w	d5,d2		*
	add.w	d5,d3		*

	move.w	a2,d4		*d4 = パターン横ピクセル数-1
	move.w	a3,d5		*d5 = パターン縦ピクセル数-1
	move.w	d2,a4		*d2をa4に待避
	move.w	d3,a5		*d3をa5に待避

minxclip:		*MINXでクリッピングする
	move.w	(a0)+,d6	*d6 = minx
	cmp.w	d6,d0		*x0＞minxなら
	bcc	minyclip	*　クリッピング不要

	cmp.w	d6,d2
	bne	minx0

	move.w	d2,d0
	move.w	d4,d3
	bra	minx3

minx0:	moveq.l	#0,d3
minxlp:	move.w	d0,d7
	add.w	d2,d7
	roxr.w	#1,d7
	cmp.w	d6,d7
	beq	minx2
	bcs	minx1

	move.w	d7,d2
	add.w	d3,d4
	roxr.w	#1,d4
	bra	minxlp

minx1:	move.w	d7,d0
	add.w	d4,d3
	roxr.w	#1,d3
	bra	minxlp

minx2:	move.w	d7,d0		*d0 = x0 = minx
	add.w	d4,d3
	roxr.w	#1,d3		*d3 = パターンが左端にはみ出る分
minx3:	move.w	a2,d4		*d4 = パターン横ピクセル数-1
	sub.w	d3,a2		*はみ出た分パターンの横幅を詰める
	add.w	d3,d3		*
	adda.w	d3,a1		*はみ出た分パターンを切り捨てる
	move.w	a4,d2		*d2を復帰
	move.w	a5,d3		*d3を復帰

minyclip:		*MINYでクリッピングする
	addq.w	#1,d4		*d4 = パターン１ライン分のピクセル数
	add.w	d4,d4		*d4 = パターン１ライン分のバイト数

	move.w	(a0)+,d6
	cmp.w	d6,d1
	bcc	maxxclip

	cmp.w	d6,d3
	bne	miny0

	move.w	d3,d1
	move.w	d5,d2
	bra	miny3

miny0:	moveq.l	#0,d2
minylp:	move.w	d1,d7
	add.w	d3,d7
	roxr.w	#1,d7
	cmp.w	d6,d7
	beq	miny2
	bcs	miny1

	move.w	d7,d3
	add.w	d2,d5
	roxr.w	#1,d5
	bra	minylp

miny1:	move.w	d7,d1
	add.w	d5,d2
	roxr.w	#1,d2
	bra	minylp

miny2:	move.w	d7,d1
	add.w	d5,d2
	roxr.w	#1,d2
miny3:	sub.w	d2,a3
	mulu.w	d4,d2
	adda.l	d2,a1
	move.w	a4,d2
	move.w	a5,d3

maxxclip:		*MAXXでクリッピングする
	move.w	d4,d6		*d6 = パターン１ライン分バイト数

	move.w	(a0)+,d4	*d4 = maxx
	sub.w	d2,d4		*d4 = maxx-x1
	bmi	maxyclip	*
	moveq.l	#0,d4		*右端にははみ出ていなかった

maxyclip:
	move.w	(a0)+,d5	*d5 = maxy
	sub.w	d3,d5		*d5 = maxy-y1
	bmi	clipped
	moveq.l	#0,d5		*下端にははみ出ていなかった

clipped:
	sub.w	d0,d2		*d2 = 描画範囲の横ピクセル数-1
	sub.w	d1,d3		*d3 = 描画範囲の縦ピクセル数-1

	move.w	#$8000,d7	*ゲタを脱がせる
	sub.w	d7,d0		*
	sub.w	d7,d1		*

	jsr	gramadr		*a0 = 描画先左上G-RAMアドレス

	move.w	d2,d0		*
	neg.w	d0		*d0 = xについての誤差項初期値
	bne	fix0		*描画先幅が１ピクセルしかない場合の
	move.w	d0,a2		*　つじつま合わせ
fix0:	add.w	d2,d4		*d4 = xループカウンタ初期値
	add.w	d2,d2		*d2 = xについての誤差項増分
	add.w	a2,a2		*a2 = xについての誤差項補正値

	movea.l	a6,a4		*a4 = ルーチン作成先先頭アドレス
	move.w	d4,d7		*d7 = xループカウンタ
iloop:	moveq.l	#0,d1		*d1 = x方向のアドレス増分(０に初期化)
	add.w	a2,d0		*xについての誤差を累積させる
	ble	inext		*
iinclp:	addq.w	#2,d1		*アドレスの増分を累積する
	sub.w	d2,d0		*x誤差項を補正する
	bgt	iinclp		*誤差項が0以下になるまで繰り返す
inext:	move.l	pset(pc),(a4)+	*move,leaの２命令を書き込む
	move.w	d1,(a4)+	*アドレスの増分を書き込む
	dbra	d7,iloop	*横幅分繰り返す

	move.w	term(pc),-4(a4)	*rts命令を書き込む
	FLUSH_CACHE

	move.w	d3,d1		*
	neg.w	d1		*d1 = yについての誤差項初期値
	bne	fix1		*描画先高が１ピクセルしかない場合の
	move.w	d1,a3		*　つじつま合わせ
fix1:	add.w	d3,d5		*d5 = yループカウンタ初期値
	add.w	d3,d3		*d3 = yについての誤差項増分
	add.w	a3,a3		*a3 = yについての誤差項補正値

yloop:	movea.l	a0,a5		*a5 = 描画先
	movea.l	a1,a4		*a4 = 参照元

	jsr	(a6)		*１ライン描画する

	add.w	a3,d1		*yについての誤差を累積させる
	ble	ynext		*
yinclp:	adda.w	d6,a1		*参照元y座標を進める
	sub.w	d3,d1		*y誤差項を補正する
	bgt	yinclp		*誤差項が0以下になるまで繰り返す

ynext:	lea.l	GNBYTE(a0),a0	*描画先y座標を進める
	dbra	d5,yloop	*高さ分繰り返す

done:	movem.l	(sp)+,d0-d7/a0-a6
term:	rts

pset:	move.w	(a4),(a5)+	*１ピクセル書き込む命令
	lea.l	0.w(a4),a4	*参照位置を移動する命令

	.end
