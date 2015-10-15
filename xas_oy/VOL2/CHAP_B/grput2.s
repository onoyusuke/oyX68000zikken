*	パターンを回転/拡大/縮小してプットする（自由変形利用版）

*	.include	gconst.h
	.include	gmacro.h
*
.ifdef	_11
	.xdef	grput2_11
.else
	.xdef	grput2
.endif
	.xref	gtput
	.xref	sintable
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

.ifndef	_11
	add.w	X,X		*x座標を2/3にする
	add.w	X,X		*
	addq.w	#3,X		*
	ext.l	X		*
	divs.w	#6,X		*
.endif
	.endm
*
	.offset	0	*grput2の引数構造
*
X0:	.ds.w	1	*描画先座標
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
DEG:	.ds.w	1	*回転角度（°）
PAT:	.ds.l	1	*パターンアドレス
XL:	.ds.w	1	*パターンの横の長さ-1
YL:	.ds.w	1	*パターンの縦の長さ-1
*
	.offset	-48	*スタックフレーム
*
WORKTOP:
ARGBUF:	.ds.b	48	*gtputへの引数
_A6:	.ds.l	1	*0
_SP:	.ds.l	1	*4
ARGPTR:	.ds.l	1	*8
*
	.text
	.even
*
.ifdef	_11
grput2_11:
.else
grput2:
.endif
	link	a6,#WORKTOP
	movem.l	d0-d7/a0-a3,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = 引数列
	move.w	DEG(a1),d4	*d4 = 角度

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

	movem.w	X0(a1),d0-d3	*d0～d3に座標を取り出す

	lea.l	ARGBUF(a6),a0	*a0 = gtputへ渡す引数列

.ifndef	_11
	move.w	d0,d6		*x0を1.5倍する
	add.w	d0,d0		*
	add.w	d6,d0		*
	asr.w	#1,d0		*

	move.w	d2,d6		*x1を1.5倍する
	add.w	d2,d2		*
	add.w	d6,d2		*
	asr.w	#1,d2		*
.endif

	move.w	d2,d6		*a2 = 回転の中心x座標
	add.w	d0,d6		*
	asr.w	#1,d6		*
	move.w	d6,a2		*

	move.w	d3,d6		*a3 = 回転の中心y座標
	add.w	d1,d6		*
	asr.w	#1,d6		*
	move.w	d6,a3		*

	sub.w	a2,d0		*(d0,d1) = パターン中心を
	sub.w	a3,d1		*　原点とする左上隅の座標
	sub.w	a2,d2		*(d2,d1) = パターン中心を
				*　原点とする右上隅の座標

	move.w	d1,d3		*d1を待避
	ROTP	d0,d1		*左上の点を回転する
	move.w	d0,(a0)+	*結果を記録
	move.w	d1,(a0)+	*

	sub.w	X0(a1),d0	*右下の点を回転する
	sub.w	Y0(a1),d1	*（簡略計算）
	sub.w	X1(a1),d0	*
	sub.w	Y1(a1),d1	*
	neg.w	d0		*
	neg.w	d1		*
	move.w	d0,4(a0)	*結果を記録
	move.w	d1,6(a0)	*

	ROTP	d2,d3		*右上の点を回転する
	move.w	d2,8(a0)	*結果を記録
	move.w	d3,10(a0)	*

	sub.w	X1(a1),d2	*左下の点を回転する
	sub.w	Y0(a1),d3	*（簡略計算）
	sub.w	X0(a1),d2	*
	sub.w	Y1(a1),d3	*
	neg.w	d2		*
	neg.w	d3		*
	move.w	d2,(a0)+	*結果を記録
	move.w	d3,(a0)+	*

	addq.l	#8,a0

	move.l	PAT(a1),(a0)+	*パターンアドレスをセット
	move.l	XL(a1),(a0)+	*パターンサイズをセット

	pea.l	ARGBUF(a6)	*自由変形ルーチンを
	jsr	gtput		*　呼び出す
	addq.l	#4,sp		*

	movem.l	(sp)+,d0-d7/a0-a3
	unlk	a6
	rts
