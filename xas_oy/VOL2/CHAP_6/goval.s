*	楕円を描く

	.include	gconst.h
*
	.xdef	goval
	.xref	gramadr
	.xref	cliprect
*
PSET	macro	X,Y,COL,ADR	*クリッピングしつつ
	local	skip		*　点を打つマクロ
	movea.l	a4,a5		*
	cmp.l	(a5)+,X		*
	blt	skip		*
	cmp.l	(a5)+,Y		*
	blt	skip		*
	cmp.l	(a5)+,X		*
	bgt	skip		*
	cmp.l	(a5)+,Y		*
	bgt	skip		*
	move.w	COL,ADR		*
skip:				*
	.endm			*
*
	.offset	0	*govalの引数構造
*
X0:	.ds.w	1	*中心座標
Y0:	.ds.w	1	*
XR:	.ds.w	1	*水平方向半径
YR:	.ds.w	1	*垂直方向半径
COL:	.ds.w	1	*描画色
*
	.offset	0	*クリッピング領域
*
LMINX:	.ds.l	1
LMINY:	.ds.l	1
LMAXX:	.ds.l	1
LMAXY:	.ds.l	1
LRECT:
*
	.offset	-56	*ワーク
*
WORKTOP:
X1:	.ds.w	1	*第１八分円x座標
Y1:	.ds.w	1	*第１八分円y座標
X2:	.ds.w	1	*第２八分円x座標
Y2:	.ds.w	1	*第２八分円y座標
EX1:	.ds.l	1	*x縮小誤差項1
EY1:	.ds.l	1	*y縮小誤差項1
EX2:	.ds.l	1	*x縮小誤差項2
EY2:	.ds.l	1	*y縮小誤差項2
EXDX:	.ds.l	1	*x縮小誤差項補正値
EXDY:	.ds.l	1	*x縮小誤差項増分
EYDX:	.ds.l	1	*y縮小誤差項補正値
EYDY:	.ds.l	1	*y縮小誤差項増分
CRECT:	.ds.b	LRECT	*シフトしたウィンドウ
*
	.text
	.even
*
goval:
ARGPTR	=	8
	link	a6,#WORKTOP
	movem.l	d0-d7/a0-a5,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = 引数列

	movem.w	(a1),d0-d3/d7	*(d0,d1) = (x0,y0) = 中心座標
				*d2 = XR = 水平方向半径
				*d3 = YR = 垂直方向半径
				*d7 = 描画色

	tst.w	d2		*XR＜0ならば
	bmi	done		*　エラー終了
	tst.w	d3		*YR＜0ならば
	bmi	done		*　エラー終了

	lea.l	CRECT(a6),a4	*(x0,y0)が原点になるよう
	lea.l	cliprect,a5	*　クリッピング領域を
				*　平行移動する
	moveq.l	#2-1,d6		*
rloop:	moveq.l	#0,d5		*
	move.w	(a5)+,d5	*
	sub.l	d0,d5		*
	move.l	d5,(a4)+	*
				*
	moveq.l	#0,d5		*
	move.w	(a5)+,d5	*
	sub.l	d1,d5		*
	move.l	d5,(a4)+	*
				*
	dbra	d6,rloop	*
				*
	lea.l	-LRECT(a4),a4	*a4 = シフト後のクリッピング領域

	jsr	gramadr		*a0 = (x0,y0)のG-RAMアドレス

*********以下　座標値はすべて(-x0,-y0)のゲタ履き表現*********

	move.l	d3,d0		*a2 = (0,YR)のG-RAMアドレス
	moveq.l	#GSFTCTR,d6	*
	lsl.l	d6,d0		*
	lea.l	0(a0,d0.l),a2	*
	neg.l	d0		*a3 = (0,-YR)のG-RAMアドレス
	lea.l	0(a0,d0.l),a3	*

	move.l	d3,X2(a6)	*(x2,y2) = (0,YR)
	swap.w	d2
	move.l	d2,X1(a6)	*(x1,y1) = (XR,0)
	swap.w	d2

	move.l	d2,d0		*x縮小誤差項の
	neg.l	d0		*　仮初期化
	move.l	d0,EX1(a6)	*

	move.l	d3,d0		*y縮小誤差項の
	neg.l	d0		*　仮初期化
	move.l	d0,EY1(a6)	*

	add.w	d2,d2		*d2 = 2XR
	add.w	d3,d3		*d3 = 2YR
	subq.l	#2,d2		*d2 = 2(XR-1)
	subq.l	#2,d3		*d3 = 2(YR-1)
	move.l	d3,EXDX(a6)	*x縮小誤差項補正値
	move.l	d2,EXDY(a6)	*x縮小誤差項増分
	move.l	d2,EYDX(a6)	*y縮小誤差項補正値
	move.l	d3,EYDY(a6)	*y縮小誤差項増分
	addq.l	#2,d2		*d2 = 2XR
	addq.l	#2,d3		*d3 = 2XR

	adda.l	d2,a0		*a0 = a1 = (x1,y1)のG-RAMアドレス
	movea.l	a0,a1		*

	move.l	d2,d5		*d5 = 2XR
	add.l	d5,d5		*d5 = -4XR = (x1,y1)と(-x1,y1)との
	neg.l	d5		*	アドレスの差
	moveq.l	#0,d6		*d6 =    0 =(x2,y2)と(-x2,y2)との
				*	アドレスの差

	cmp.w	d3,d2		*2XRと2YRの大きい方を
	bcc	init1		*　d2に残す
	move.w	d3,d2		*d2 = max(2XR,2YR) = 2R

init0:	move.l	d6,EY1(a6)	*縦長楕円だから
	move.l	d6,EYDX(a6)	*　yは縮小しない
	move.l	d6,EYDY(a6)	*
	bra	init2

init1:	move.l	d6,EX1(a6)	*横長楕円だから
	move.l	d6,EXDX(a6)	*　xは縮小しない
	move.l	d6,EXDY(a6)	*

init2:	move.l	d2,d4		*d4 = -2R+1 = F-2
	neg.l	d4		*
	addq.l	#1,d4		*

	add.l	d2,d2		*d2 = 4x = 4R
	moveq.l	#0,d3		*d3 = 4y = 0

	move.l	EX1(a6),EX2(a6)	*x縮小誤差項2を初期化
	move.l	EY1(a6),EY2(a6)	*y縮小誤差項2を初期化

loop:
P0	reg	(a0)		*    -x1-x2  x2 x1
P1	reg	(a1)		*-y2	 P7  P3
P2	reg	(a2)		*-y1  P5	P1
P3	reg	(a3)		*
P4	reg	0(a0,d5.l)	*
P5	reg	0(a1,d5.l)	* y1  P4	P0
P6	reg	0(a2,d6.l)	* y2	 P6  P2
P7	reg	0(a3,d6.l)	*

	movem.w	X1(a6),d0-d1
	PSET	d0,d1,d7,P0	*P0(x1,y1)
	neg.l	d1
	PSET	d0,d1,d7,P1	*P1(x1,-y1)
	neg.l	d0
	PSET	d0,d1,d7,P5	*P5(-x1,-y1)
	neg.l	d1
	PSET	d0,d1,d7,P4	*P4(-x1,y1)

	movem.w	X2(a6),d0-d1
	PSET	d0,d1,d7,P2	*P2(x2,y2)
	neg.l	d1
	PSET	d0,d1,d7,P3	*P3(x2,-y2)
	neg.l	d0
	PSET	d0,d1,d7,P7	*P7(-x2,-y2)
	neg.l	d1
	PSET	d0,d1,d7,P6	*P6(-x2,y2)

	add.l	d3,d4		*F+=4y+2
	addq.l	#2,d4		*
	bmi	vmove		*F＜0ならば垂直移動

dmove:			*斜め移動
	subq.l	#4,d2		*4x
	sub.l	d2,d4		*F -= 4x

xcalc1:	move.l	EX1(a6),d0	*縮小を考慮して
	add.l	EXDY(a6),d0	*　x1を更新する
	bmi	xskip1		*
				*
	subq.w	#1,X1(a6)	*x1--
	subq.l	#2,a0		*P0を左へ移動
	subq.l	#2,a1		*P1を左へ移動
	addq.l	#4,d5		*P4をP0に近付ける
				*
	sub.l	EXDX(a6),d0	*
				*
xskip1:	move.l	d0,EX1(a6)	*

ycalc1:	move.l	EY2(a6),d0	*縮小を考慮して
	add.l	EYDY(a6),d0	*　y2を更新する
	bmi	yskip1		*
				*
	subq.w	#1,Y2(a6)	*y2--
	lea.l	-GNBYTE(a2),a2	*P2を上へ移動
	lea.l	GNBYTE(a3),a3	*P3を下へ移動
				*
	sub.l	EYDX(a6),d0	*
				*
yskip1:	move.l	d0,EY2(a6)	*

vmove:			*垂直移動
	addq.l	#4,d3		*4y

ycalc2:	move.l	EY1(a6),d0	*縮小を考慮して
	add.l	EYDY(a6),d0	*　y1を更新する
	bmi	yskip2		*
				*
	addq.w	#1,Y1(a6)	*y1++
	lea.l	GNBYTE(a0),a0	*P0を下へ移動
	lea.l	-GNBYTE(a1),a1	*P1を上へ移動
				*
	sub.l	EYDX(a6),d0	*
				*
yskip2:	move.l	d0,EY1(a6)	*

xcalc2:	move.l	EX2(a6),d0	*縮小を考慮して
	add.l	EXDY(a6),d0	*　x2を更新する
	bmi	xskip2		*
				*
	addq.w	#1,X2(a6)	*x2++
	addq.l	#2,a2		*P2を右へ移動
	addq.l	#2,a3		*P3を右へ移動
	subq.l	#4,d6		*P6をP2から遠ざける
				*
	sub.l	EXDX(a6),d0	*
				*
xskip2:	move.l	d0,EX2(a6)	*

	cmp.l	d3,d2		*4x≧4yのあいだ
	bge	loop		*　繰り返す

done:	movem.l	(sp)+,d0-d7/a0-a5
	unlk	a6
	rts

	.end
