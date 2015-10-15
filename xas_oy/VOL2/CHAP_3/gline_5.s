*	線分描画（整数化ダブルステップBresenham）

	.include	gconst.h
*
	.xdef	gline
	.xref	gclipline
	.xref	gbase
*
	.offset	0	*glineの引数構造
*
X0:	.ds.w	1	*始点座標
Y0:	.ds.w	1	*
X1:	.ds.w	1	*終点座標
Y1:	.ds.w	1	*
COL:	.ds.w	1	*描画色
*
	.text
	.even
*
gline:
ARGPTR	=	4+8*4+6*4
	movem.l	d0-d7/a0-a5,-(sp)

	movea.l	ARGPTR(sp),a5	*a5 = 引数列
	movem.w	(a5)+,d0-d3	*d0～d3に座標を取り出す

	jsr	gclipline	*クリッピングする
	bne	done		*Z=0なら完全不可視

	cmp.w	d2,d0		*x0≦x1を保証する
	ble	gline0		*
	exg.l	d0,d2		*
	exg.l	d1,d3		*

gline0:	move.w	d1,d6		*始点/終点のG-RAMアドレスを求める
	move.w	d3,d7		*
	ext.l	d6		*
	ext.l	d7		*
				*
	moveq.l	#GSFTCTR,d4	*
	asl.l	d4,d6		*
	asl.l	d4,d7		*
	add.w	d0,d6		*
	add.w	d0,d6		*
	add.w	d2,d7		*
	add.w	d2,d7		*
				*
	movea.l	gbase,a0	*
	movea.l	a0,a2		*
	add.l	d6,a0		*a0 = 始点のG-RAMアドレス
	add.l	d7,a2		*a2 = 終点のG-RAMアドレス

	move.w	#GNBYTE,d5	*d5 = 横1ライン分のバイト数
	sub.w	d1,d3		*d3 = y1-y0
	beq	hor_line	*y0＝y1なら水平線
	bpl	gline1
	neg.w	d3
	neg.w	d5
gline1:	sub.w	d0,d2		*d2 = x1-x0 ( >=0 )
	beq	ver_line	*x0＝x1なら垂直線
*この時点で
*	d2 = dx = abs(x1-x0) ( > 0 )
*	d3 = dy = abs(y1-y0) ( > 0 )
*	d5 = sy = sgn(y1-y0) ( -1 or 1 )
*	（ただしd5はGNBYTE倍済み）

	move.w	(a5),d0		*d0.l = 描画色
	move.w	d0,d7		*
	swap.w	d0		*
	move.w	d7,d0		*

	cmp.w	d3,d2		*dy＞dxならば
	bcs	yline		*　yについてループ
	beq	xyline		*dy＝dxならば45度の線

			*dx≧dyのとき
xline:	addq.l	#2,a2		*プリデクリメントする分補正

	move.w	d2,d1		*d1 = dx
	neg.w	d1		*d1 = e = -dx
	move.w	d2,d6		*d6 = dx
	add.w	d2,d2		*d2 = 2*dx
	add.w	d3,d3		*d3 = 2*dy
	move.w	d3,d4		*d4 = 2*dy
	add.w	d3,d3		*d3 = 4*dy

	addq.w	#1,d6		*d6 = 線分のピクセル数
	moveq.l	#3,d7		*
	and.w	d6,d7		*d7 = 線分のピクセル数 mod ４
	lsr.w	#2,d6		*ループカウンタを1/4
	subq.w	#1,d6		*dbraの動作を考慮
	bmi	xlineq		*最初から４ピクセル未満だった

	cmp.w	d2,d3		*if ( 4*dy < 2*dx ) {
	bcc	xline3

			*dy/dx＜1/2のとき
xline0:	add.w	d3,d1		*  e += 4*dy
	bpl	xline1		*  if ( e < 0 ) {

*	●●○

	move.l	d0,(a0)+	*    pset(x++,y), pset(x++,y)
	move.l	d0,-(a2)	*    pset(x'--,y'), pset(x'--,y')

	dbra	d6,xline0
	bra	xlineq

xline1:	cmp.w	d4,d1		*  } else if ( e < 2*dy ) {
	bge	xline2

*	　　○
*	●●

	move.l	d0,(a0)+	*    pset(x++,y), pset(x++,y)
	move.l	d0,-(a2)	*    pset(x'--,y'), pset(x'--,y')
	adda.w	d5,a0		*    y += sy
	suba.w	d5,a2		*    y'-= sy
				*
	sub.w	d2,d1		*    e -= 2*dx

	dbra	d6,xline0
	bra	xlineq

				*  } else {
*	　●○
*	●

xline2:	move.w	d0,(a0)+	*    pset(x++,y)
	move.w	d0,-(a2)	*    pset(--x',y')
	adda.w	d5,a0		*    y += sy
	suba.w	d5,a2		*    y'-= sy
	move.w	d0,(a0)+	*    pset(x++,y)
	move.w	d0,-(a2)	*    pset(--x',y')
				*
	sub.w	d2,d1		*    e -= 2*dx
				*  }
	dbra	d6,xline0
	bra	xlineq

				*} else {

			*1/2≦dy/dx≦1のとき
xline3:	sub.w	d2,d3		*  d3 = 4*dy-2*dx
	sub.w	d2,d4		*  d4 = 2*dy-2*dx

xline4:	add.w	d3,d1		*  e += 4*dy-2*dx
	bmi	xline5		*  if ( e >= 0 ) {

*	　　○
*	　●
*	●

	move.w	d0,(a0)+	*    pset(x++,y)
	move.w	d0,-(a2)	*    pset(--x',y')
	adda.w	d5,a0		*    y += sy
	suba.w	d5,a2		*    y'-= sy
	move.w	d0,(a0)+	*    pset(x++,y)
	move.w	d0,-(a2)	*    pset(--x',y')
	adda.w	d5,a0		*    y += sy
	suba.w	d5,a2		*    y'-= sy
				*
	sub.w	d2,d1		*    e -= 2*dx

	dbra	d6,xline4
	bra	xlineq2

xline5:	cmp.w	d4,d1		*  } else if ( e < 2*dy-2*dx ) {
	bge	xline6

*	　　○
*	●●

	move.l	d0,(a0)+	*    pset(x++,y), pset(x++,y)
	move.l	d0,-(a2)	*    pset(x'--,y'), pset(x'--,y')
	adda.w	d5,a0		*    y += sy
	suba.w	d5,a2		*    y'-= sy

	dbra	d6,xline4
	bra	xlineq2

*	　●○
*	●
				*  } else {
xline6:	move.w	d0,(a0)+	*    pset(x++,y)
	move.w	d0,-(a2)	*    pset(--x',y')
	adda.w	d5,a0		*    y += sy
	suba.w	d5,a2		*    y'-= sy
	move.w	d0,(a0)+	*    pset(x++,y)
	move.w	d0,-(a2)	*    pset(--x',y')

	dbra	d6,xline4	*  }
*	bra	xlineq		*}

xlineq2:
	add.w	d2,d4		*d4 = 2*dy
xlineq:	add.w	d7,d7		*４ピクセル未満の端数分を描画
	move.w	xtbl(pc,d7),d7	*
	jmp	xtbl(pc,d7)	*
xtbl:
x	=	xtbl
	.dc.w	done-x
	.dc.w	xleft1-x
	.dc.w	xleft2-x
	.dc.w	xleft3-x

xleft1:	move.w	d0,(a0)		*残り１ピクセル
	bra	done

xleft2:	move.w	d0,(a0)		*残り２ピクセル
	move.w	d0,-(a2)
	bra	done

xleft3:	move.w	d0,(a0)+	*残り３ピクセル
	move.w	d0,-(a2)
	add.w	d4,d1
	bmi	xleft4
	adda.w	d5,a0
xleft4:	move.w	d0,(a0)
	bra	done
*
			*dx＜dyのとき
yline:	movea.w	d5,a3		*a3 = y変化時のG-RAMアドレス増分
	addq.l	#2,a3		*a3 = x, y変化時のG-RAMアドレス増分

	move.w	d3,d1
	neg.w	d1
	move.w	d3,d6
	add.w	d3,d3
	add.w	d2,d2
	move.w	d2,d4
	add.w	d2,d2

	addq.w	#1,d6
	moveq.l	#3,d7
	and.w	d6,d7
	lsr.w	#2,d6
	subq.w	#1,d6
	bmi	ylineq

	cmp.w	d3,d2
	bcc	yline3

yline0:	add.w	d2,d1
	bpl	yline1

*	○
*	●
*	●

	move.w	d0,(a0)
	move.w	d0,(a2)
	adda.w	d5,a0
	suba.w	d5,a2
	move.w	d0,(a0)
	move.w	d0,(a2)
	adda.w	d5,a0
	suba.w	d5,a2

	dbra	d6,yline0
	bra	ylineq

yline1:	cmp.w	d4,d1
	bge	yline2

*	　○
*	●
*	●

	move.w	d0,(a0)
	move.w	d0,(a2)
	adda.w	d5,a0
	suba.w	d5,a2
	move.w	d0,(a0)
	move.w	d0,(a2)
	adda.w	a3,a0
	suba.w	a3,a2

	sub.w	d3,d1

	dbra	d6,yline0
	bra	ylineq

*	　○
*	　●
*	●

yline2:	move.w	d0,(a0)
	move.w	d0,(a2)
	adda.w	a3,a0
	suba.w	a3,a2
	move.w	d0,(a0)
	move.w	d0,(a2)
	adda.w	d5,a0
	suba.w	d5,a2

	sub.w	d3,d1

	dbra	d6,yline0
	bra	ylineq

			*1/2≦dx/dy≦1のとき
yline3:	sub.w	d3,d2
	sub.w	d3,d4

yline4:	add.w	d2,d1
	bmi	yline5

*	　　○
*	　●
*	●

	move.w	d0,(a0)
	move.w	d0,(a2)
	adda.w	a3,a0
	suba.w	a3,a2
	move.w	d0,(a0)
	move.w	d0,(a2)
	adda.w	a3,a0
	suba.w	a3,a2

	sub.w	d3,d1

	dbra	d6,yline4
	bra	ylineq2

yline5:	cmp.w	d4,d1
	bge	yline6

*	　○
*	●
*	●

	move.w	d0,(a0)
	move.w	d0,(a2)
	adda.w	d5,a0
	suba.w	d5,a2
	move.w	d0,(a0)
	move.w	d0,(a2)
	adda.w	a3,a0
	suba.w	a3,a2

	dbra	d6,yline4
	bra	ylineq2

*	　○
*	　●
*	●

yline6:	move.w	d0,(a0)
	move.w	d0,(a2)
	adda.w	a3,a0
	suba.w	a3,a2
	move.w	d0,(a0)
	move.w	d0,(a2)
	adda.w	d5,a0
	suba.w	d5,a2

	dbra	d6,yline4

ylineq2:
	add.w	d3,d4
ylineq:	add.w	d7,d7
	move.w	ytbl(pc,d7),d7
	jmp	ytbl(pc,d7)
ytbl:
y	=	ytbl
	.dc.w	done-y
	.dc.w	yleft1-y
	.dc.w	yleft2-y
	.dc.w	yleft3-y

yleft1:	move.w	d0,(a0)
	bra	done

yleft2:	move.w	d0,(a0)
	move.w	d0,(a2)
	bra	done

yleft3:	move.w	d0,(a0)
	move.w	d0,(a2)
	add.w	d4,d1
	bmi	yleft4
	move.w	d0,0(a0,a3)
	bra	done
yleft4:	move.w	d0,0(a0,d5)
	bra	done

done:	movem.l	(sp)+,d0-d7/a0-a5
	rts
*
	.xref	ghline
	.xref	gvline
*
hor_line:		*水平線分
	sub.w	d0,d2		*d2 = dx = x1-x0
	move.w	(a5),d1		*d0.l = 描画色（上位/下位とも）
	move.w	d1,d0		*
	swap.w	d0		*
	move.w	d1,d0		*
	addq.w	#1,d2		*d2 = dx+1 = ピクセル数
	bclr.l	#0,d2		*
	beq	hskip		*
	move.w	d0,(a0)+	*奇数ピクセルの分
hskip:	lea.l	ghline,a1
	suba.w	d2,a1
	jsr	(a1)
hline:	bra	done

xyline:			*45度の線分
	move.w	(a5),d0		*d0 = color
	addq.w	#1,d3		*d3 = dy+1
	moveq.l	#8-1,d4		*
	and.w	d3,d4		*d4 = ８ピクセル未満の端数
	lsr.w	#3,d3		*d3 = (dy+1)/8
	lsl.w	#2,d4		*moveとaddaで４バイト
	neg.w	d4		*
	jmp	xynext(pc,d4)	*ループの途中に飛び込む

xyloop:	move.w	d0,(a0)+	*pset(x++,y)
	adda.w	d5,a0		*y += sy
	move.w	d0,(a0)+	*pset(x++,y)
	adda.w	d5,a0		*y += sy
	move.w	d0,(a0)+	*pset(x++,y)
	adda.w	d5,a0		*y += sy
	move.w	d0,(a0)+	*pset(x++,y)
	adda.w	d5,a0		*y += sy
	move.w	d0,(a0)+	*pset(x++,y)
	adda.w	d5,a0		*y += sy
	move.w	d0,(a0)+	*pset(x++,y)
	adda.w	d5,a0		*y += sy
	move.w	d0,(a0)+	*pset(x++,y)
	adda.w	d5,a0		*y += sy
	move.w	d0,(a0)+	*pset(x++,y)
	adda.w	d5,a0		*y += sy
xynext:	dbra	d3,xyloop	*(dy+1)/8回繰り返す
	bra	done

ver_line:		*垂直線分
	tst.w	d5		*d5 = sy
	bpl	vskip		*a0 <= a2を
	movea.l	a2,a0		*　保証する
vskip:	move.l	#$0000_8000,d5	*long!
.ifdef	_1024	
	moveq.l	#16-1,d1	*d1 = dy%16
	and.w	d3,d1		*
	lsr.w	#4,d3		*d3 = dy/16
.else
	moveq.l	#32-1,d1	*d1 = dy%32
	and.w	d3,d1		*
	lsr.w	#5,d3		*d3 = dy/32
.endif
	move.w	d1,d2
	moveq.l	#GSFTCTR,d0
	lsl.w	d0,d2
	adda.w	d2,a0
	move.w	(a5),d0		*d0 = color
	addq.w	#1,d1
	lsl.w	#2,d1
	lea.l	gvline,a1
	suba.w	d1,a1
	jsr	(a1)
	bra	done

	.end
