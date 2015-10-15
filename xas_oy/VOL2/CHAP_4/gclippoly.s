*	多角形をcliprectで指定された矩形領域でクリッピングする（Ｃ用微修正版）

	.include	rect.h
*
	.xdef	gclippoly
	.xdef	_gclippoly
	.xref	cliprect
*
	.text
	.even
*
gclippoly:
_gclippoly:
POINTS	=	8
POINTS2 =	12
	link	a6,#0
	movem.l	d0-d7/a0-a5,-(sp)

	movem.l	POINTS(a6),a1-a2
				*a1 = クリッピング前の点
				*a2 = クリッピング後の点
	lea.l	cliprect,a0	*a0 = クリッピングウィンドウ

	clr.w	(a2)+		*仮に頂点の数を0にしておく

	move.w	(a1)+,d7	*d7 = 点の数
	beq	retn		*点が与えられていない
	subq.w	#1,d7		*
	bne	do		*

			*１点しか与えられていない場合
	movem.w	(a1),d0-d1
	cmp.w	MINY(a0),d1	*y＜MINY なら
	blt	done		*　不可視
	cmp.w	MAXY(a0),d1	*y＞MAXY なら
	bgt	done		*　不可視
	move.w	d0,(a2)+	*(x,y)を登録する
	move.w	d1,(a2)+	*
	bra	done		*　クリッピング完了

			*２点以上与えられていた場合
do:	moveq.l	#0,d0
	move.w	d7,d0
	lsl.l	#2,d0

	movem.w	0(a1,d0.l),d2-d3
				*(d2,d3) = 最後の点
				*	 = 最初の点にとっては
				*	   直前の点
	movea.w	#$8000,a5	*a5 = ゲタ
	bra	lpent
			*クリッピングする点を(x,y)
			*直前の点を(x0,y0)とおく
loop:	movem.w	(a1)+,d2-d3	*(d2,d3) = (x0,y0)
lpent:	movem.w	(a1),d0-d1	*(d0,d1) = (x,y)
	moveq.l	#0,d4		*d4 = 直前の点が可視かどうかのフラグ
				*　　（仮に可視と考える）

cminy:	move.w	MINY(a0),d5	*d5 = MINY
	cmp.w	d5,d1		*y＜MINYなら
	blt	cminy0		*　(x,y)をMINYでクリップ

	cmp.w	d5,d3		*y >= MINY かつ y0 >= MINY なら
	bge	cmaxy		*　MINYでのクリッピングは不要

			*(x,y)は可視で(x0,y0)は不可視
	exg.l	d0,d2		*(x0,y0)をMINYでクリップ
	exg.l	d1,d3		*
	bsr	minyclip	*
	exg.l	d0,d2		*
	exg.l	d1,d3		*
	moveq.l	#-1,d4		*(x0,y0)をクリッピングした
	bra	cmaxy

cminy0:	cmp.w	d5,d3		*y＜MINY かつ y0＜MINY なら
	blt	next		*　辺は完全不可視

			*(x,y)は不可視で(x0,y0)は可視
	bsr	minyclip	*(x,y)をMINYでクリップ

cmaxy:	move.w	MAXY(a0),d5	*d5 = MAXY
	addq.w	#1,d5		*d5 = MAXY+1 = MAXY'
				*（gfillpolyの手抜き対応）
	cmp.w	d5,d1		*y＞MAXY'なら
	bgt	cmaxy0		*　(x,y)をMAXY'でクリップ

	cmp.w	d5,d3		*y≦MAXY' かつ y0≦MAXY'なら
	ble	setp		*　MAXY'でクリッピングは不要

			*(x,y)は可視で(x0,y0)は不可視
	exg.l	d0,d2		*(x0,y0)をMAXY'でクリップ
	exg.l	d1,d3		*
	bsr	maxyclip	*
	exg.l	d0,d2		*
	exg.l	d1,d3		*
	moveq.l	#-1,d4		*(x0,y0)をクリッピングした
	bra	setp0

cmaxy0:	cmp.w	d5,d3		*y＞MAXY' かつ y0＞MAXY'なら
	bgt	next		*　辺は完全不可視

			*(x,y)は不可視で(x0,y0)は可視
	bsr	maxyclip	*(x,y)をMINYでクリップ

setp:	tst.w	d4		*(x0,y0)をクリッピングしたのなら
	beq	setp1		*
setp0:	move.w	d2,(a2)+	*　クリッピングした(x0,y0)も
	move.w	d3,(a2)+	*　登録する
setp1:	move.w	d0,(a2)+	*クリッピングした(x,y)を登録する
	move.w	d1,(a2)+	*

next:	dbra	d7,loop		*すべての点について繰り返す

	movea.l	POINTS2(a6),a1	*最初の点を
	move.w	2(a1),(a2)+	*　バッファ最後に書き込み
	move.w	4(a1),(a2)+	*　図形を閉じる

done:	movea.l	POINTS2(a6),a1	*クリッピング後の
	addq.l	#2,a1		*
	suba.l	a1,a2		*
	move.l	a2,d0		*
	lsr.l	#2,d0		*　点の数を数える

	swap.w	d0		*点の数が65536以上なら
	tst.w	d0		*
	beq	setn		*
	moveq.l	#0,d0		*　誤動作防止に0にしてしまう

setn:	swap.w	d0		*
	move.w	d0,-(a1)	*点の数を記録する

retn:	movem.l	(sp)+,d0-d7/a0-a5
	unlk	a6
	rts
*
maxyclip:		*MAXY'でクリッピングする
	cmp.w	d5,d3		*反対側の端点がMAXY'上なら
	beq	just		*　その点が求める点

	move.w	d2,a3		*反対側の端点の
	move.w	d3,a4		*　座標を保存
	add.w	a5,d0		*両端点とMAXY'に
	add.w	a5,d1		*　8000hのゲタを覆かせて
	add.w	a5,d2		*　無符号化する
	add.w	a5,d3		*
	add.w	a5,d5		*

			*クリッピングする点を(x1,y1)
			*反対側の点を(x2,y2)
			*両者の中点を(mx,my)とおく
maxylp:	move.w	d1,d6		*
	add.w	d3,d6		*
	roxr.w	#1,d6		*d6 = my = 中点のy座標
	cmp.w	d5,d6		*my = MAXY'なら
	beq	yclipq		*　クリッピング完了
	bcs	maxy0
			*y1 ＜ my ＜ MAXY' ＜ y2
	move.w	d6,d1		*y1 = my
	add.w	d2,d0		*
	roxr.w	#1,d0		*x1 = mx
	bra	maxylp		*　と更新して繰り返す

			*y1 ＜ MAXY' ＜ my ＜ y2
maxy0:	move.w	d6,d3		*y2 = my
	add.w	d0,d2		*
	roxr.w	#1,d2		*x1 = mx
	bra	maxylp		*　と更新して繰り返す
*
minyclip:		*MINYでクリッピングする
	cmp.w	d5,d3
	beq	just

	move.w	d2,a3
	move.w	d3,a4
	add.w	a5,d0
	add.w	a5,d1
	add.w	a5,d2
	add.w	a5,d3
	add.w	a5,d5

minylp:	move.w	d1,d6
	add.w	d3,d6
	roxr.w	#1,d6
	cmp.w	d5,d6
	beq	yclipq
	bcc	miny0

	move.w	d6,d1
	add.w	d2,d0
	roxr.w	#1,d0
	bra	minylp

miny0:	move.w	d6,d3
	add.w	d0,d2
	roxr.w	#1,d2
	bra	minylp

yclipq:	move.w	d6,d1		*d1 = 求めたy座標
	add.w	d2,d0		*
	roxr.w	#1,d0		*d0 = それに対応したx座標

	sub.w	a5,d0		*ゲタを脱がせる
	sub.w	a5,d1		*
	move.w	a3,d2		*反対側の点の
	move.w	a4,d3		*　座標を復帰
	rts
*
just:	move.w	d2,d0		*反対側の点が
	move.w	d3,d1		*　ちょうど求める点
	rts

	.end

修正履歴

92-01-01版
点の数が0～1のとき動作に不備があったのを修正

93-09-01版
GCLIB.Aのフルセット化に伴い，Ｃ用の外部定義を追加
