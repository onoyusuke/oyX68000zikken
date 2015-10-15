*	円・楕円を塗り潰して描く

	.include	gconst.h
*
	.xdef	gfillcircle
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
	.offset	0	*gfillcircleの引数構造
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
gfillcircle:
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

init2:	tst.w	d2		*XR = YR = 0ならば
	bne	do		*

	movem.w	X1(a6),d0-d1	*　(x0,y0)に点を打って終了
	PSET	d0,d1,d7,(a0)	*
	bra	done

do:	move.l	d2,d4		*d4 = -2R+1 = F-2
	neg.l	d4		*
	addq.l	#1,d4		*

	add.l	d2,d2		*d2 = 4x = 4R
	moveq.l	#0,d3		*d3 = 4y = 0

	move.l	EX1(a6),EX2(a6)	*x縮小誤差項2を初期化
	move.l	EY1(a6),EY2(a6)	*y縮小誤差項2を初期化

	move.w	d7,d0		*d7 = 描画色（上位/下位ワードとも）
	swap.w	d7		*
	move.w	d0,d7		*

	.xref	ghline
	lea.l	ghline,a5	*a5 = 水平線分描画ルーチン

loop:
*P0	reg	(a0)		*    -x1-x2  x2 x1
*P1	reg	(a1)		*-y2	 P7  P3
*P2	reg	(a2)		*-y1  P5	P1
*P3	reg	(a3)		*
*P4	reg	0(a0,d5.l)	*
*P5	reg	0(a1,d5.l)	* y1  P4	P0
*P6	reg	0(a2,d6.l)	* y2	 P6  P2
*P7	reg	0(a3,d6.l)	*

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

ycalc1:	move.l	EYDY(a6),d0	*縮小を考慮して
	add.l	d0,EY2(a6)	*　y2を更新する
	bmi	yskip1		*

	movem.w	X2(a6),d0-d1	*P2-P6, P3-P7を描く
	exg.l	d5,d6		*
	exg.l	a0,a2		*
	exg.l	a1,a3		*
	bsr	drawlines	*
	exg.l	d5,d6		*
	exg.l	a0,a2		*
	exg.l	a1,a3		*

	subq.w	#1,Y2(a6)	*y2--
	lea.l	-GNBYTE(a2),a2	*P2を上へ移動
	lea.l	GNBYTE(a3),a3	*P3を下へ移動
				*
	move.l	EYDX(a6),d0	*
	sub.l	d0,EY2(a6)	*
				*
yskip1:
vmove:			*垂直移動
	addq.l	#4,d3		*4y

ycalc2:	move.l	EYDY(a6),d0	*縮小を考慮して
	add.l	d0,EY1(a6)	*　y1を更新する
	bmi	yskip2		*

	movem.w	X1(a6),d0-d1	*P0-P4, P1-P5を描く
	bsr	drawlines	*

	addq.w	#1,Y1(a6)	*y1++
	lea.l	GNBYTE(a0),a0	*P0を下へ移動
	lea.l	-GNBYTE(a1),a1	*P1を上へ移動
				*
	move.l	EYDX(a6),d0	*
	sub.l	d0,EY1(a6)	*
				*
yskip2:
xcalc2:	move.l	EX2(a6),d0	*縮小を考慮して
	add.l	EXDY(a6),d0	*　x2を更新する
	bmi	xskip2		*

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

	movem.w	X1(a6),d0-d1	*描画のタイミングがずれた分
	bsr	drawlines	*

done:	movem.l	(sp)+,d0-d7/a0-a5
	unlk	a6
	rts

*
*	P0-P4とP1-P5, あるいは, P2-P6とP3-P7の２本の線分を描く
*
drawlines:
	movem.l	d2/a0,-(sp)

	lea.l	0(a0,d5.l),a0	*P0-P4（またはP2-P6）を描く
	movem.l	d0-d1,-(sp)	*
	bsr	drawline	*
	movem.l	(sp)+,d0-d1	*

	neg.l	d1		*P1-P5（またはP3-P7）を描く
	lea.l	0(a1,d5.l),a0	*
	bsr	drawline	*

	movem.l	(sp)+,d2/a0
	rts

*
*	水平線分を１本描く
*
drawline:
	cmp.l	CRECT+LMINY(a6),d1	*完全にウィンドウ外の場合を弾く
	blt	skip			*
	cmp.l	CRECT+LMAXY(a6),d1	*
	bgt	skip			*
	cmp.l	CRECT+LMINX(a6),d0	*
	blt	skip			*

	move.l	d0,d1		*d1 = 描く線分の右端x座標
	neg.l	d0		*d0 = 描く線分の左端x座標

	cmp.l	CRECT+LMAXX(a6),d0	*完全にウィンドウ外の場合を弾く
	bgt	skip			*

	move.l	CRECT+LMINX(a6),d2	*ウィンドウ左端でクリップ
	cmp.l	d2,d0			*
	bge	minskp			*
	sub.l	d2,d0			*
	suba.l	d0,a0			*←切り取った分だけ
	suba.l	d0,a0			*　G-RAMアドレスも更新する
	move.l	d2,d0			*

minskp:	move.l	CRECT+LMAXX(a6),d2	*ウィンドウ右端でクリップ
	cmp.l	d2,d1			*
	ble	maxskp			*
	move.l	d2,d1			*

maxskp:	sub.l	d0,d1		*d1 = 描く線分の長さ-1
	addq.w	#1,d1		*d1 = 描く線分の長さ
	bclr.l	#0,d1		*奇数？
	beq	notodd		*
	move.w	d7,(a0)+	*　奇数ピクセルの分
notodd:	neg.w	d1		*

	move.l	d7,d0
	jsr	0(a5,d1.w)	*水平線分描画

skip:	rts

	.end
