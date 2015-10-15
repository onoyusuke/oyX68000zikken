*	パターンを任意四角形にはめ込んでプットする（第１版）

	.include	gconst.h
	.include	gmacro.h
*
	.xdef	gtput
	.xref	gramadr
	.xref	cliprect
*
PSET	macro	X,Y,COL,ADR	*クリッピングしつつ
	local	skip		*　点を打つマクロ
	lea.l	cliprect,a5	*
	cmp.w	(a5)+,X		*
	blt	skip		*
	cmp.w	(a5)+,Y		*
	blt	skip		*
	cmp.w	(a5)+,X		*
	bgt	skip		*
	cmp.w	(a5)+,Y		*
	bgt	skip		*
	move.w	COL,ADR		*
skip:				*
	.endm			*

*
	.offset	0	*gtputの引数構造
*
X0:	.ds.w	1	*描画先座標	A
Y0:	.ds.w	1	*
X1:	.ds.w	1	*		B
Y1:	.ds.w	1	*
X2:	.ds.w	1	*		C
Y2:	.ds.w	1	*
X3:	.ds.w	1	*		D
Y3:	.ds.w	1	*
PAT:	.ds.l	1	*パターンアドレス
XL:	.ds.w	1	*パターンの横の長さ-1
YL:	.ds.w	1	*パターンの縦の長さ-1
*
	.offset	0	*線分発生用ワーク
*
X:	.ds.w	1	*x座標
Y:	.ds.w	1	*y座標
DX:	.ds.w	1	*y更新時にeから引く定数
DY:	.ds.w	1	*x更新時にeに加える定数
SX:	.ds.w	1	*x増加方向
SY:	.ds.w	1	*y増加方向
E:	.ds.w	1	*誤差項e
LEN:	.ds.w	1	*線分のピクセル数-1
SDX:	.ds.w	1	*速度調節用e補正値
SDY:	.ds.w	1	*速度調節用e増分
EDG:
*
	.offset	-EDG*2-2*4	*スタックフレーム
*
WORKTOP:
ST:	.ds.b	EDG	*始点関連ワーク
ED:	.ds.b	EDG	*終点関連ワーク
PHE:	.ds.w	1	*水平スケーリング用e初期値
PHDY:	.ds.w	1	*水平スケーリング用e増分
PVDX:	.ds.w	1	*垂直スケーリング用e補正値
PVDY:	.ds.w	1	*垂直スケーリング用e増分
_A6:	.ds.l	1	*0
_SP:	.ds.l	1	*4
ARGPTR:	.ds.l	1	*8
*
	.text
	.even
*
gtput:
	link	a6,#WORKTOP
	movem.l	d0-d7/a0-a5,-(sp)

	movea.l	ARGPTR(a6),a5	*a5=引数列

	movem.w	X0(a5),d0-d3	*ABを発生するための
	lea.l	ST(a6),a0	*（＝始点の経路を決めるための）
	bsr	init		*　誤差項周りの初期化
	movea.l	a1,a3		*a3=始点を移動するサブルーチン

	movem.w	X3(a5),d0-d1	*DCを発生するための
	movem.w	X2(a5),d2-d3	*（＝終点の経路を決めるための）
	lea.l	ED(a6),a0	*　誤差項周りの初期化
	bsr	init		*
	movea.l	a1,a4		*a4=終点を移動するサブルーチン

	move.w	ST+LEN(a6),d7	*d7=ABの長さ-1
	move.w	ED+LEN(a6),d0	*d0=DCの長さ-1
	lea.l	xline-xlinex(a3),a3
				*ABの方が長いと仮定し
				*　仮に始点の速度調節を殺す

	cmp.w	d0,d7		*ABとDCの長さが等しければ
	beq	equskp		*　始点,終点ともに速度調節不要
	bcc	maxskp		*ABの方が長ければ
				*　始点については速度調節不要
				*DCの方が長ければ
				*　終点については速度調節不要
	move.w	d0,d7		*d7=DCの長さ-1
	lea.l	xlinex-xline(a3),a3	*始点の速度調節を復活する

equskp:	lea.l	xline-xlinex(a4),a4	*終点の速度調節を殺す

maxskp:	move.w	d7,d5		*d7=d5=ABとDCの長さの長い方
	neg.w	d5		*d5=始点（または終点）の
				*　移動速度調節用e

	move.w	d7,d0		*
	add.w	d0,d0		*
	move.w	d0,ST+SDX(a6)	*始点移動速度調節用e補正値
	move.w	d0,ED+SDX(a6)	*終点移動速度調節用e補正値
	move.w	d0,PVDX(a6)	*パターンを垂直になぞる速度の
				*　調節用e補正値

	move.w	YL(a5),d0	*d0=パターン高-1
	move.w	d0,d6		*d6=パターンを垂直になぞる速度の
	neg.w	d6		*　調節用e
	tst.w	d7		*
	bne	fix0		*描画先高が１ピクセルしかない場合の
	move.w	d7,d0		*　つじつま合わせ
fix0:	add.w	d0,d0		*パターンを垂直になぞる速度の
				*　調節用e増分
	move.w	d0,PVDY(a6)	*

	movea.l	PAT(a5),a1	*a1=パターン先頭アドレス

	move.w	XL(a5),d0	*d0=パターン幅-1
	movea.w	d0,a5		*a5=パターン１ライン分バイト数
	addq.l	#1,a5		*
	adda.l	a5,a5		*

	move.w	d0,d1		*パターンを水平になぞる速度の
	add.w	d1,d1		*　調節用e増分
	move.w	d1,PHDY(a6)	*

	neg.w	d0		*パターンを水平になぞる速度の
	move.w	d0,PHE(a6)	*　調節用e

	movem.w	ED+X(a6),d2-d3	*(d2.w,d3.w)=終点座標
	move.w	ED+E(a6),d4	*d4.w=終点移動経路決定用e
	swap.w	d2		*それぞれレジスタの
	swap.w	d3		*　上位ワードに保存
	swap.w	d4		*
	move.w	ST+X(a6),d2	*(d2.w,d3.w)=始点座標
	move.w	ST+Y(a6),d3	*
	move.w	ST+E(a6),d4	*d4.w=始点移動経路決定用e

loop:
*	d2.l	始点,終点のx座標
*	d3.l	始点,終点のy座標
*	d4.l	始点,終点移動経路決定用e
*		（上位ワード：終点/下位ワード：始点）
*	d5.w	始点（または終点）移動速度調節用e
*	d6.w	パターンを垂直になぞる速度の調節用e
*	d7.w	ループカウンタ
*	a1	参照中のパターン上水平線分左端アドレス
*	a3	始点を移動するサブルーチン
*	a4	終点を移動するサブルーチン
*	a5	パターン１ラインバイト数

	move.w	d2,d0		*d0=始点のx座標
	move.w	d3,d1		*d1=始点のy座標

	swap.w	d2		*d2.w=終点のx座標
	swap.w	d3		*d3.w=終点のy座標
	swap.w	d4

	bsr	put1line	*１ライン分描画する

	lea.l	ED(a6),a0	*終点を更新する
	jsr	(a4)		*

	swap.w	d2
	swap.w	d3
	swap.w	d4

	lea.l	ST(a6),a0	*始点を更新する
	jsr	(a3)		*

	add.w	PVDY(a6),d6	*移動速度を考慮して
	ble	nextln		*　パターンの垂直方向参照位置を
				*　移動する
skppat:	adda.l	a5,a1		*
	sub.w	PVDX(a6),d6	*
	bgt	skppat		*

nextln:	dbra	d7,loop		*必要なだけ繰り返す

	movem.l	(sp)+,d0-d7/a0-a5
	unlk	a6
	rts

*
*	１ライン分描画する
*
put1line:
	movem.l	d2-d7/a1/a3-a5,-(sp)

	jsr	gramadr		*a0=始点のG-RAMアドレス

	sub.w	d0,d2		*始点と終点を結ぶ線分を
	move.w	d2,d4		*　発生するための
	ABS	d2		*　パラメータの初期化
	move.w	d2,a2		*
	add.w	a2,a2		*
	SGN	d4		*
				*
	sub.w	d1,d3		*
	move.w	d3,d5		*
	ABS	d3		*
	move.w	d3,a3		*
	add.w	a3,a3		*
	SGN	d5		*

	move.w	d5,d6		*d6=y座標を更新したときの
	moveq.l	#GSFTCTR,d7	*　G-RAMアドレスの変化量
	asl.w	d7,d6		*

	move.w	PHDY(a6),a4	*パターンを水平になぞる速度の
				*　調節用e増分

	cmp.w	d3,d2		*線分の傾きに応じて
	bcs	yput		*　処理を振り分ける

xput:			*なだらかな傾きの線分へ張り付ける場合
	move.w	d2,d7		*d7=ループカウンタ
	neg.w	d2		*d2=誤差項e
	bne	fix1		*描画先幅が１ピクセルしかない場合の
	move.w	d2,a4		*　つじつま合わせ
fix1:	move.w	PHE(a6),d3	*パターンを水平になぞる速度の
				*　調節用e

xloop:	PSET	d0,d1,(a1),(a0)	*１ピクセル描画

	add.w	a4,d3		*移動速度を考慮して
	ble	xput1		*　パターンの水平方向参照位置を
				*　更新する
xput0:	addq.l	#2,a1		*
	sub.w	a2,d3		*
	bgt	xput0		*

xput1:	add.w	d4,d0		*x+=sx
	adda.w	d4,a0		*
	adda.w	d4,a0		*

	add.w	a3,d2		*e+=dy
	bmi	xnext

	add.w	d5,d1		*y+=sy
	adda.w	d6,a0		*

	sub.w	a2,d2		*e-=dx

xnext:	dbra	d7,xloop

	movem.l	(sp)+,d2-d7/a1/a3-a5
	rts

yput:			*急な傾きの線分へ張り付ける場合
	move.w	d3,d2
	move.w	d2,d7
	neg.w	d2
	bne	fix2
	move.w	d2,a4
fix2:	move.w	PHE(a6),d3

yloop:	PSET	d0,d1,(a1),(a0)

	add.w	a4,d3
	ble	yput1

yput0:	sub.w	a3,d3
	addq.l	#2,a1
	bgt	yput0

yput1:	add.w	d5,d1
	adda.w	d6,a0

	add.w	a2,d2
	bmi	ynext

	add.w	d4,d0
	adda.w	d4,a0
	adda.w	d4,a0

	sub.w	a3,d2

ynext:	dbra	d7,yloop

	movem.l	(sp)+,d2-d7/a1/a3-a5
	rts

*
*	AB,DC発生のための初期化
*
init:
	sub.w	d0,d2		*d2=d4=x1-x0
	move.w	d2,d4		*
	ABS	d2		*d2=dx=abs(x1-x0)
	SGN	d4		*d4=sx=sgn(x1-x0)

	sub.w	d1,d3		*d3=d5=y1-y0
	move.w	d3,d5		*
	ABS	d3		*d3=dy=abs(y1-y0)
	SGN	d5		*d5=sy=sgn(y1-y0)

	cmp.w	d3,d2		*傾きに応じて
	bcs	yinit		*　処理を振り分ける

			*dx≧dyの場合
xinit:	move.w	d2,d6		*d6=dx
	neg.w	d6		*d6=e=-dx
	add.w	d3,d2		*d2=dx+dy
	move.w	d2,d7		*d7=dx+dy
				*　=線分のピクセル数-1
	add.w	d2,d2		*d2=2dx+2dy
				*　=y座標更新時のe補正値
	add.w	d3,d3		*d3=2dy
				*　=x座標更新時のe増分
	movem.w	d0-d7,X(a0)	*ワークに格納する

	move.w	d2,SDY(a0)	*速度調節用e増分
	lea.l	xlinex(pc),a1	*a1=傾きがなだらかな線分を
				*　１ピクセルずつ発生する
				*　サブルーチン
	rts

			*dx＜dyの場合
yinit:	move.w	d3,d6		*d6=dy
	neg.w	d6		*d6=e=-dy
	add.w	d2,d3		*d3=dx+dy
	move.w	d3,d7		*d7=dx+dy
				*  =線分のピクセル数-1
	add.w	d2,d2		*d2=2dx
				*　=x座標更新時のe増分
	add.w	d3,d3		*d3=2dx+2dy
				*　=y座標更新時のe補正値
	movem.w	d0-d7,X(a0)	*ワークに格納する

	move.w	d3,SDY(a0)	*速度調節用e増分
	lea.l	ylinex(pc),a1	*a1=傾きが急な線分を
				*　１ピクセルずつ発生する
				*　サブルーチン
	rts

*
*	移動速度を考慮して始点,終点を移動する
*	（なだらかな傾きの線分用）
*
xlinex:	add.w	SDY(a0),d5	*速度の調節
	bmi.s	xline1		*
				*
	sub.w	SDX(a0),d5	*

xline:	add.w	DY(a0),d4	*e+=2dy
	bmi	xline0

	add.w	SY(a0),d3	*y+=sy
	sub.w	DX(a0),d4	*e-=2(dx+dy)
	rts

xline0:	add.w	SX(a0),d2	*x+=sx
xline1:	rts

*
*	移動速度を考慮して始点,終点を移動する
*	（急な傾きの線分用）
*
ylinex:	add.w	SDY(a0),d5	*速度の調節
	bmi.s	yline1		*
				*
	sub.w	SDX(a0),d5	*

yline:	add.w	DX(a0),d4	*e+=2dx
	bmi	yline0

	add.w	SX(a0),d2	*x+=sx
	sub.w	DY(a0),d4	*e-=2(dx+dy)
	rts

yline0:	add.w	SY(a0),d3	*y+=sy
yline1:	rts

	.end
