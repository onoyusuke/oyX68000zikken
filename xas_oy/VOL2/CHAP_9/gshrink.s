*	グラフィック画像を縮小する

	.include	gconst.h
	.include	gmacro.h
*
	.xdef	gshrink
	.xref	gramadr
	.xref	gcliprect
*
FPACK	macro	callno
	.dc.w	callno
	.endm

__UDIV	equ	$fe05
*
GCM	macro	M,N	*最大公約数を求めるマクロ
	local	loop
	move.w	N,d0
loop:	moveq.l	#0,N
	move.w	d0,N
	divu.w	M,N
	move.w	M,d0
	swap.w	N
	move.w	N,M
	bne	loop
	.endm
*
	.offset	0	*gshrinkの引数構造
*
X0:	.ds.w	1	*描画先座標
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
XL:	.ds.w	1	*縮小後の横ピクセル数-1
YL:	.ds.w	1	*縮小後の縦ピクセル数-1
TEMP:	.ds.l	1	*作業用ワーク（最大６Ｋバイト）
*
	.offset	-42
*
WORK:
EX:	.ds.l	1
DEX:	.ds.l	1
CEX:	.ds.l	1
EY:	.ds.l	1
DEY:	.ds.l	1
CEY:	.ds.l	1
XSTEP:	.ds.w	1
YSTEP:	.ds.w	1
DENOM:	.ds.l	1
DXL:	.ds.w	1
SXL:	.ds.w	1
PATSIZ:	.ds.w	1
BUFF:	.ds.l	1
_a6:	.ds.l	1	*±0
_a7:	.ds.l	1
ARGPTR:	.ds.l	1
*
	.text
	.even
*
gshrink:
	link	a6,#WORK
	movem.l	d0-d7/a0-a5,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = 引数列

	movem.w	(a1)+,d0-d3/a2-a3
				*d0～d3=描画範囲の座標
				*a2=縮小後横ピクセル数-1
				*a3=縮小後縦ピクセル数-1
	movea.l	(a1),a4		*a4=１ラインバッファ
	move.l	a4,BUFF(a6)	*

	jsr	gcliprect	*クリッピングする
	bne	done		*Z=0なら描画の必要なし

	jsr	gramadr		*a0=描画先左上G-RAMアドレス
	movea.l	a0,a1

	sub.w	d0,d2		*d2=描画範囲の横ピクセル数-1
	beq	done
	sub.w	d1,d3		*d3=描画範囲の縦ピクセル数-1
	beq	done

	cmp.w	a2,d2		*拡大はできない
	bcs	done		*
	cmp.w	a3,d3		*
	bcs	done		*

	move.w	a2,d7		*
	addq.w	#1,d7		*
	add.w	d7,d7		*
	move.w	d7,PATSIZ(a6)	*パターン１ラインのバイト数

	move.w	d2,SXL(a6)	*縮小元横幅-1
	move.w	a2,DXL(a6)	*xループカウンタ初期値
	move.w	a3,d7		*d7=yループカウンタ初期値

	swap.w	d7		*d7の下位ワードを待避
	move.w	d2,d6
	move.w	d3,d7
	addq.w	#1,a2		*a2=パターン
	addq.w	#1,a3

	addq.w	#1,d2		*x方向縮小率を約分する
	move.w	d2,d1		*
	move.w	a2,d4		*
	GCM	d1,d4		*
	divu.w	d0,d2		*分子
	move.l	a2,d4		*
	divu.w	d0,d4		*分母

	addq.w	#1,d3		*y方向縮小率を約分する
	move.w	d3,d1		*
	move.w	a3,d5		*
	GCM	d1,d5		*
	divu.w	d0,d3		*分子
	move.l	a3,d5		*
	divu.w	d0,d5		*分母

	move.w	d2,d0		*
	mulu.w	d3,d0		*
	move.l	d0,DENOM(a6)	*平均するサブピクセル数

	move.w	d2,d4
	subq.w	#1,d2		*平均するサブピクセルの
	move.w	d2,XSTEP(a6)	*　横方向の数-1
	move.w	d3,d5
	subq.w	#1,d3		*平均するサブピクセルの
	move.w	d3,YSTEP(a6)	*　縦方向の数-1

	move.w	a2,d0		*xに関するパラメータ計算
	mulu.w	d4,d0		*←疑似拡大
	subq.l	#1,d0		*
	neg.l	d0		*
	move.l	d0,EX(a6)	*
	neg.l	d0		*
	add.l	d0,d0		*
	move.l	d0,CEX(a6)	*
	move.w	d6,d2		*
	add.l	d2,d2		*
	move.l	d2,DEX(a6)	*

	move.w	a3,d0		*yに関するパラメータ計算
	mulu.w	d5,d0		*←疑似拡大
	subq.l	#1,d0		*
	neg.l	d0		*
	move.l	d0,EY(a6)	*
	neg.l	d0		*
	add.l	d0,d0		*
	move.l	d0,CEY(a6)	*
	move.w	d7,d3		*
	add.l	d3,d3		*
	move.l	d3,DEY(a6)	*debug 94-06-28

	bsr	dergb		*最初のラインをrgbに分解
	movea.l	a5,a2		*a2=rgbごとの累算用バッファ

	move.l	EY(a6),d5
	swap.w	d7		*d7を復帰

yloop:	move.l	a0,-(sp)

	moveq.l	#0,d0		*rgbごとの累算用バッファを
	movea.l	a2,a5		*　0で初期化
	move.w	DXL(a6),d4	*
clrlp:	move.l	d0,(a5)+	*
	move.l	d0,(a5)+	*
	move.l	d0,(a5)+	*
	dbra	d4,clrlp	*

	move.w	YSTEP(a6),d6
yloop2:	movea.l	a2,a4
	movea.l	BUFF(a6),a5

	swap.w	d6
	swap.w	d7
	movem.l	d5/a1-a3,-(sp)

	movem.w	(a5)+,a0-a2	*a0～a2=参照する点のbrg

	move.l	DEX(a6),d3
	move.l	CEX(a6),a3
	move.w	XSTEP(a6),d5

	move.l	EX(a6),d4
	move.w	DXL(a6),d7
xloop:	moveq.l	#0,d0		*B
	moveq.l	#0,d1		*R
	moveq.l	#0,d2		*G
	move.w	d5,d6
xloop2:	add.l	a0,d0		*B
	add.l	a1,d1		*R
	add.l	a2,d2		*G

	add.l	d3,d4		*EX += DEX
	bmi	xnext2
	sub.l	a3,d4		*EX -= CEX
	movem.w	(a5)+,a0-a2	*参照元x座標を進める
xnext2:	dbra	d6,xloop2

xnext:	add.l	d0,(a4)+	*R
	add.l	d1,(a4)+	*G
	add.l	d2,(a4)+	*B
	dbra	d7,xloop

	movem.l	(sp)+,d5/a1-a3
	swap.w	d7
	swap.w	d6

	add.l	DEY(a6),d5	*EY += DEY
	bmi	ynext2
	sub.l	CEY(a6),d5	*EY -= CEY
	lea.l	GNBYTE(a1),a1	*参照元y座標を進める

	move.w	d6,d0		*処理完了寸前であれば
	or.w	d7,d0		*　この下のラインを
	beq	ynext		*　rgbに分解する必要はない

	bsr	dergb		*１ライン分rgbに分解する

ynext2:	dbra	d6,yloop2

ynext:	movea.l	(sp)+,a0

	movea.l	a0,a3
	movea.l	a2,a5
	move.l	DENOM(a6),d1	*d1=平均の分母

	move.w	DXL(a6),d6
drawlp:	move.l	(a5)+,d0
	FPACK	__UDIV
	move.w	d0,d2		*B
	move.l	(a5)+,d0
	FPACK	__UDIV
	move.w	d0,d3		*R
	move.l	(a5)+,d0
	FPACK	__UDIV		*G
	move.w	d0,d4
	RGB	d2,d3,d4,d0	*カラーコードに構成して
	move.w	d0,(a3)+	*　書き込む
	dbra	d6,drawlp	*横幅分繰り返す

	lea.l	GNBYTE(a0),a0	*描画先y座標を進める
	dbra	d7,yloop	*高さ分繰り返す

done:	movem.l	(sp)+,d0-d7/a0-a5
	unlk	a6
	rts

*
*	１ライン分rgbに分解して
*	バッファに展開する
dergb:
	movea.l	a1,a3
	movea.l	BUFF(a6),a5
	move.w	SXL(a6),d4
dergb0:	move.w	(a3)+,d0
	DERGB	d0,d1,d2,d3
	movem.w	d1-d3,(a5)
	addq.l	#6,a5
	dbra	d4,dergb0
	rts

	.end

修正履歴

94-07-01版
DEYがDEXと無条件に等しくなってしまうのを修正
