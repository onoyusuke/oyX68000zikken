*	パターンを回転/拡大/縮小してプットする

	.include	gconst.h
	.include	gmacro.h
*
	.xdef	grput
	.xref	gramadr
	.xref	ucliprect
	.xref	sintable
*
	.offset	0	*grputの引数構造
*
X0:	.ds.w	1	*描画先座標
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
DEG:	.ds.w	1	*回転角度（°）
PAT:	.ds.l	1	*パターンアドレス（※）
XL:	.ds.w	1	*パターンの横の長さ-1（※）
YL:	.ds.w	1	*パターンの縦の長さ-1（※）
TEMP:	.ds.l	1	*作業用メモリへのポインタ
*
*(※)	　　┌　XL　┐
*	┌─┬───┬─┐
*	│　│　　　│　│
*	├─┼───┼─┤┐　　　　　　　　
*	│　│＼　　│　│
*	│　│　pat │　│YL　　　
*	├─┼───┼─┤┘　　　　　　　　
*	│　│　　　│　│　　　
*	└─┴───┴─┘
*
	.text
	.even
*
grput:
ARGPTR	=	4+8*4+7*4
	movem.l	d0-d7/a0-a6,-(sp)

	movea.l	ARGPTR(sp),a6	*a6 = 引数列

	bsr	rotate		*回転の計算をする

	movea.l	TEMP(a6),a5
	movea.l	a5,a4
	movem.w	d0-d1/d4-d5,-(sp)
	bsr	line_comp	*水平１ライン分の
				*　点の拾い方を決める

	lea.l	ucliprect,a0	*左右端の
	move.w	X0(a6),d1	*　クリッピングをする
	move.w	X1(a6),d2	*
	bsr	clip		*
	bmi	done2		*

	movea.l	a5,a2
	bsr	expand_comp	*水平１ライン分の
				*　拡大/縮小を考慮した
				*　点の拾い方を決める

	movea.l	a5,a4
	movem.w	(sp)+,d0-d3
	bsr	line_comp	*垂直１ライン分の
				*　点の拾い方を決める

	lea.l	ucliprect+2,a0	*上下端の
	move.w	Y0(a6),d1	*　クリッピングをする
	move.w	Y1(a6),d2	*
	bsr	clip		*
	bmi	done		*

	movea.l	a5,a3
	bsr	expand_comp	*垂直１ライン分の
				*　拡大/縮小を考慮した
				*　点の拾い方を決める

	move.w	(a2)+,d0	*(d0,d1) = 描画開始位置
	move.w	(a3)+,d1	*
	jsr	gramadr		*a0 = そのG-RAM上アドレス

	move.w	(a2)+,d7	*d7 = 描画範囲横方向の長さ-1
	move.w	(a3)+,d5	*d5 = 描画範囲縦方向の長さ-1

	move.w	d7,d0		*d0 =
	addq.w	#1,d0		*　ライン右端と
	add.w	d0,d0		*　次のライン左端との
	neg.w	d0		*　G-RAM上のアドレスの差
	addi.w	#GNBYTE,d0	*

yloop:	movea.l	a1,a4		*a4 = 参照するパターン上位置
	movea.l	a2,a5		*a5 = １ライン分の参照位置の
				*　移動量のテーブル
	move.w	d7,d6
xloop:	move.w	(a4),(a0)+	*１点描画する
	adda.w	(a5)+,a4	*参照位置を移動する
	dbra	d6,xloop	*横幅分繰り返す

	adda.w	(a3)+,a1	*参照位置を縦に移動する
	adda.w	d0,a0		*a0 = 次のライン左端
	dbra	d5,yloop	*高さ分繰り返す

done:	movem.l	(sp)+,d0-d7/a0-a6
	rts
done2:	addq.l	#8,sp
	bra	done

*
*	sin(DEG)をテーブルから引いてくるマクロ
*
ISIN	macro	TABLE,DEG
	local	skip1,skip2,skip3

	ext.l	DEG		*sin(-θ) = -sin(θ)
	bpl	skip1		*
	neg.w	DEG		*

skip1:	subi.w	#90,DEG		*sin(180ﾟ-θ) = sin(θ)
	bcs	skip2		*
	neg.w	DEG		*
skip2:	addi.w	#90,DEG		*0≦deg≦90ﾟ

	add.w	DEG,DEG
	move.w	0(TABLE,DEG),DEG

	tst.l	DEG		*sin(-θ) = -sin(θ)
	bpl	skip3		*
	neg.w	DEG		*
skip3:
	.endm

*
*	点(X,Y)を回転するマクロ
*
ROTP	macro	X,Y
	local	skip1,skip2

	move.w	X,d6
	move.w	Y,d7

	muls.w	d5,X		*x･cos(θ)
	muls.w	d5,Y		*y･cos(θ)
	muls.w	d4,d6		*x･sin(θ)
	muls.w	d4,d7		*y･sin(θ)

	sub.l	d7,X		*x･cos(θ)-y･sin(θ)
	bpl	skip1
	addi.l	#$3fff,X
skip1:	asl.l	#2,X
	swap.w	X

	add.l	d6,Y		*x･sin(θ)+y･cos(θ)
	bpl	skip2
	addi.l	#$3fff,Y
skip2:	asl.l	#2,Y
	swap.w	Y

	add.w	a2,X
	add.w	a3,Y

	add.w	X,X		*x座標を2/3にする
	add.w	X,X		*
	addq.w	#3,X		*
	ext.l	X		*
	divs.w	#6,X		*

	.endm

*
*	パターンの角３点を回転する
*
rotate:
	move.w	DEG(a6),d4	*d4 = 角度

	move.w	#360,d6		*角度を
	move.w	#180,d7		*　-180ﾟ～179ﾟに
	add.w	d7,d4		*　正規化する
	bpl	norm2		*
norm1:	add.w	d6,d4		*
	bmi	norm1		*
norm2:	cmp.w	d6,d4		*
	bcs	norm3		*
	sub.w	d6,d4		*
	bra	norm2		*
norm3:	sub.w	d7,d4		*

	moveq.l	#90,d5		*cosθ = sin(90ﾟ-θ)
	sub.w	d4,d5		*
	cmp.w	d7,d5		*
	ble	rot		*
	sub.w	d6,d5		*

rot:	lea.l	sintable,a0
	ISIN	a0,d4		*d4 = sin(θ)
	ISIN	a0,d5		*d5 = cos(θ)

	movem.w	XL(a6),d0-d1	*d0,d1 = パターンの縦横の大きさ

	move.w	d0,a5

	add.w	d0,d0		*x方向の長さを1.5倍する
	add.w	a5,d0		*
	lsr.w	#1,d0		*

	move.w	d0,d2
	move.w	d1,d3

	lsr.w	#1,d0		*(d0,d1) = 回転の中心
	lsr.w	#1,d1		*

	move.w	d0,a2		*(a2,a3) = 回転の中心
	move.w	d1,a3		*

	sub.w	d0,d2		*(d0,d1) = パターン中心を
	neg.w	d0		*　原点とする左上隅の座標
	neg.w	d1		*(d2,d1) = パターン中心を
				*　原点とする右上隅の座標

	move.w	d1,a4
	ROTP	d0,d1		*左上の点を回転する

	exg.l	d1,a4		*(d2,d1) = パターン中心を
				*　原点とする右上隅の座標
	ROTP	d2,d1		*右上の点を回転する

	move.w	a5,d4		*左下の点を回転する
	sub.w	d2,d4		*
	move.w	d3,d5		*
	sub.w	d1,d5		*

	move.w	d1,d3
	move.w	a4,d1

*	左上	(d0,d1)
*	右上	(d2,d3)
*	左下	(d4,d5)

	movea.l	PAT(a6),a1	*(d0,d1)に対応する
	adda.w	d0,a1		*　パターン上の位置を
	adda.w	d0,a1		*　求める
	move.w	a5,d6		*
	addq.w	#1,d6		*
	add.w	d6,d6		*
	add.w	d6,d6		*
	muls.w	d1,d6		*
	adda.l	d6,a1		*
	rts

*
*	パターン上の線分(d0,d1)-(d2,d3)に沿って
*	ポインタを移動する相対アドレスの表を作成する
*
line_comp:
	sub.w	d0,d2
	move.w	d2,d4
	ABS	d2
	SGN	d4

	sub.w	d1,d3
	move.w	d3,d5
	ABS	d3
	SGN	d5

	add.w	d4,d4
	move.w	XL(a6),d0
	addq.w	#1,d0
	add.w	d0,d0
	add.w	d0,d0
	muls.w	d0,d5

	cmp.w	d3,d2
	bcs	yline

xline:	move.w	d2,d0	*傾きが緩やかな線分の場合

	move.w	d2,d1		*Bresenhamのアルゴリズムに
	neg.w	d1		*　必要なパラメータの計算
	move.w	d2,d6		*
	add.w	d2,d2		*
	add.w	d3,d3		*

xline0:	move.w	d4,d7		*アドレスの相対的な移動量を
	add.w	d3,d1		*
	bmi	xline1		*
	add.w	d5,d7		*
	sub.w	d2,d1		*
xline1:	move.w	d7,(a5)+	*　テーブルに登録していく
	dbra	d6,xline0
	rts

yline:	move.w	d3,d0	*傾きが急な線分の場合

	move.w	d3,d1		*Bresenhamのアルゴリズムに
	neg.w	d1		*　必要なパラメータの計算
	move.w	d3,d6		*
	add.w	d2,d2		*
	add.w	d3,d3		*

yline0:	move.w	d5,d7		*アドレスの相対的な移動量を
	add.w	d2,d1		*
	bmi	yline1		*
	add.w	d4,d7		*
	sub.w	d3,d1		*
yline1:	move.w	d7,(a5)+	*　テーブルに登録していく
	dbra	d6,yline0
	rts

*
*	クリッピングする
*
	.offset	0
*				MINX
Min:	.ds.w	1	*MINX	MINY
	.ds.w	1	*MINY	MAXX
Max:	.ds.w	1	*MAXX	MAXY
	.ds.w	1	*MAXY	----
*
	.offset	0
*
D0SAV:	.ds.w	1
D2SAV:	.ds.w	1
NPIX:	.ds.w	1
*
	.text
*
clip:
	MINMAX	d1,d2		*d1≦d2を保証する

	addi.w	#$8000,d1	*ゲタを履かせる
	addi.w	#$8000,d2	*
	moveq.l	#0,d3
	movem.w	d0/d2-d3,-(sp)
minclip:			*左端/上端でクリップ
	move.w	Min(a0),d6
	cmp.w	d6,d1
	bcc	maxclip		*ウィンドウ内だった

	cmp.w	d6,d2
	bcc	min0
	bne	outofscrn	*完全にウィンドウ外

	move.w	d2,d1
	bra	maxclip

min0:	moveq.l	#0,d3
minlp:	move.w	d1,d7
	add.w	d2,d7
	roxr.w	#1,d7
	cmp.w	d6,d7
	beq	min2
	bcs	min1

	move.w	d7,d2
	add.w	d3,d0
	roxr.w	#1,d0
	bra	minlp

min1:	move.w	d7,d1
	add.w	d0,d3
	roxr.w	#1,d3
	bra	minlp

min2:	move.w	d7,d1
	add.w	d3,d0
	roxr.w	#1,d0		*d0 = ウィンドウ外にはみ出す
				*　パターンのピクセル数
	sub.w	d0,NPIX(sp)

	subq.w	#1,d0
	bcs	min3
skiplp:	adda.w	(a4)+,a1	*切り捨てた分
	dbra	d0,skiplp	*　参照開始位置を
				*　ずらす
min3:	move.w	D0SAV(sp),d0
	move.w	D2SAV(sp),d2

maxclip:			*右端/下端でクリップ
	move.w	Max(a0),d6
	cmp.w	d6,d2
	bls	clipped		*ウィンドウ内だった

	cmp.w	d6,d1
	bls	max0
	bne	outofscrn	*完全にウィンドウ外

	moveq.l	#0,d0
	move.w	d1,d2
	bra	clipped

max0:	move.w	d1,d4
	moveq.l	#0,d3
maxlp:	move.w	d4,d7
	add.w	d2,d7
	roxr.w	#1,d7
	cmp.w	d6,d7
	beq	max2
	bcs	max1

	move.w	d7,d2
	add.w	d3,d0
	roxr.w	#1,d0
	bra	maxlp

max1:	move.w	d7,d4
	add.w	d0,d3
	roxr.w	#1,d3
	bra	maxlp

max2:	move.w	d7,d2
	add.w	d3,d0
	roxr.w	#1,d0

clipped:			*クリッピング完了
	subi.w	#$8000,d1	*ゲタを脱がせる
	subi.w	#$8000,d2	*

	addq.l	#4,sp
	add.w	(sp)+,d0	*d0 = パターン上の
				*　点を拾う斜め線分長
	rts			*N = 0

outofscrn:
	addq.l	#6,sp
	moveq.l	#-1,d0		*N = 1
	rts

*
*	斜めに切り出したパターンを
*	描画先の大きさに合わせて拡大/縮小するための
*	テーブルを作成する
*
expand_comp:
	move.w	d1,(a5)+	*クリッピング後の
				*　描画先左上隅x/y座標
	sub.w	d1,d2
	move.w	d2,(a5)+	*描画幅/高さ
	beq	exdone

	move.w	d2,d1		*Bresenhamのアルゴリズムに
	neg.w	d1		*　必要なパラメータの計算
	move.w	d2,d3		*
	add.w	d2,d2		*
	add.w	d0,d0		*

explp1:	moveq.l	#0,d4		*アドレスの相対的な移動量を
	add.w	d0,d1		*
	ble	expnxt		*
explp2:	add.w	(a4)+,d4	*
	sub.w	d2,d1		*
	bgt	explp2		*
expnxt:	move.w	d4,(a5)+	*　テーブルに登録していく
	dbra	d3,explp1

exdone:	rts

	.end
