*	円を描く

	.include	gconst.h
*
	.xdef	gcircle
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
	.offset	0	*gcircleの引数構造
*
X0:	.ds.w	1	*中心座標
Y0:	.ds.w	1	*
R:	.ds.w	1	*半径
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
	.text
	.even
*
gcircle:
ARGPTR	=	8
	link	a6,#-LRECT
	movem.l	d0-d7/a0-a5,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = 引数列

	movem.w	(a1),d0-d2/d7	*(d0,d1) = (x0,y0) = 中心座標
				*d2 = R = 半径
				*d7 = 描画色

	tst.w	d2		*R≦0ならば
	bmi	done		*　エラー終了

	lea.l	-LRECT(a6),a4	*(x0,y0)が原点になるよう
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

	move.l	d2,d0		*a2 = (0,R)のG-RAMアドレス
	moveq.l	#GSFTCTR,d6	*
	lsl.l	d6,d0		*
	lea.l	0(a0,d0.l),a2	*
	neg.l	d0		*a3 = (0,-R)のG-RAMアドレス
	lea.l	0(a0,d0.l),a3	*

	move.l	d2,d0		*(d0,d1) = (x,y) = (R,0)
	moveq.l	#0,d1		*

	add.w	d2,d2		*d2 = 2R
	adda.l	d2,a0		*a0 = a1 = (x,y)のG-RAMアドレス
	movea.l	a0,a1		*

	move.l	d2,d4		*d4 = -2R+1 = F-2
	neg.l	d4		*
	addq.l	#1,d4		*

	add.l	d2,d2		*d2 = 4x = 4R
	moveq.l	#2,d3		*d3 = 4y+2 = 2

	move.l	d2,d5		*d5 = -4R = (x,y)と(-x,y)との
	neg.l	d5		*	アドレスの差
	moveq.l	#0,d6		*d6 =   0 = (y,x)と(-y,x)との
				*	アドレスの差
loop:
P0	reg	(a0)		*    -x -y  y  x
P1	reg	(a1)		*-x	P7  P3
P2	reg	(a2)		*-y  P5	       P1
P3	reg	(a3)		*
P4	reg	0(a0,d5.l)	*
P5	reg	0(a1,d5.l)	* y  P4	       P0
P6	reg	0(a2,d6.l)	* x	P6  P2
P7	reg	0(a3,d6.l)	*

	PSET	d0,d1,d7,P0	*P0(x,y)
	PSET	d1,d0,d7,P2	*P2(y,x)
	neg.l	d1
	PSET	d0,d1,d7,P1	*P1(x,-y)
	PSET	d1,d0,d7,P6	*P3(-y,x)
	neg.l	d0
	PSET	d0,d1,d7,P5	*P5(-x,-y)
	PSET	d1,d0,d7,P7	*P7(-y,-x)
	neg.l	d1
	PSET	d0,d1,d7,P4	*P4(-x,y)
	PSET	d1,d0,d7,P3	*P6(y,-x)
	neg.l	d0

	add.l	d3,d4		*F += 4y+2
	bmi	vmove		*F＜0ならば垂直移動

dmove:			*斜め移動
	subq.w	#1,d0		*x--
	subq.l	#4,d2		*4x
	sub.l	d2,d4		*F -= 4x

	subq.l	#2,a0		*P0を左へ移動
	subq.l	#2,a1		*P1を左へ移動
	lea.l	-GNBYTE(a2),a2	*P2を上へ移動
	lea.l	GNBYTE(a3),a3	*P3を下へ移動
	addq.l	#4,d5		*P4をP0に近付ける

vmove:			*垂直移動
	addq.w	#1,d1		*y++
	addq.l	#4,d3		*4y+2

	lea.l	GNBYTE(a0),a0	*P0を下へ移動
	lea.l	-GNBYTE(a1),a1	*P1を上へ移動
	addq.l	#2,a2		*P2を右へ移動
	addq.l	#2,a3		*P3を右へ移動
	subq.l	#4,d6		*P6をP2から遠ざける

	cmp.w	d1,d0		*x≧yのあいだ
	bge	loop		*　繰り返す

done:	movem.l	(sp)+,d0-d7/a0-a5
	unlk	a6
	rts

	.end

修正履歴

94-11-29版
非数値シンボルをequで定義していたのをregに変更
