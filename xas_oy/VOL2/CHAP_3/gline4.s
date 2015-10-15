*	線分描画（４連結）

	.include	gconst.h
	.include	gmacro.h
*
	.xdef	gline4
	.xref	gramadr
	.xref	gclipline
*
	.offset	0	*gline4の引数構造
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
gline4:
ARGPTR	=	4+8*4+6*4
	movem.l	d0-d7/a0-a5,-(sp)

	movea.l	ARGPTR(sp),a5	*a5 = 引数列
	movem.w	(a5)+,d0-d3	*d0～d3に座標を取り出す

	jsr	gclipline	*クリッピングする
	bne	done		*Z=0なら完全にウィンドウ外

	jsr	gramadr		*a0 = 始点のG-RAMアドレス

	sub.w	d0,d2		*d2 = x1-x0
	move.w	d2,d4		*d4 = d2
	ABS	d2		*d2 = dx = abs(x1-x0)
	SGN	d4		*d4 = sx = sgn(x1-x0)

	sub.w	d1,d3		*d3 = y1-y0
	move.w	d3,d5		*d5 = d3
	ABS	d3		*d3 = dy = abs(y1-y0)
	SGN	d5		*d5 = sy = sgn(y1-y0)

	add.w	d4,d4		*d4 = sx*2
	moveq.l	#GSFTCTR,d0	*d5 = sy*1024
	asl.w	d0,d5		*  (or sy*2048)

	move.w	(a5),d0		*d0 = 描画色

	move.w	d2,d6		*d6 = dx
	add.w	d3,d6		*d6 = dx+dy
				*   = ループカウンタ

	cmp.w	d3,d2		*dy＞dxならば
	bcs	yline		*　yについてループ

			*dx≧dyのとき
xline:	move.w	d2,d1		*d1 = e = -dx
	neg.w	d1		*
	add.w	d2,d2		*d2 = 2*dx
	add.w	d3,d3		*d3 = 2*dy
	add.w	d3,d2		*d2 = 2*dx+2*dy
	sub.w	d4,d5		*d5 = yを更新したときの
				*　G-RAMアドレス変化量
				*（xを先に更新した分の補正を含む）
				*do {
xline0:	move.w	d0,(a0)		*  pset(x, y)
	adda.w	d4,a0		*  x += sx
	add.w	d3,d1		*  e += 2*dy
	bmi	xline1		*  if (e >=  0) {
	adda.w	d5,a0		*     y += sy, x -= sx
	sub.w	d2,d1		*     e -= 2*dx+2*dy
				*  }
xline1:	dbra	d6,xline0	*} while (--n >= 0)
	bra	done

			*dx＜dyのとき
yline:	move.w	d3,d1
	neg.w	d1
	add.w	d2,d2
	add.w	d3,d3
	add.w	d2,d3
	sub.w	d5,d4

yline0:	move.w	d0,(a0)
	adda.w	d5,a0
	add.w	d2,d1
	bmi	yline1
	adda.w	d4,a0
	sub.w	d3,d1

yline1:	dbra	d6,yline0
done:	movem.l	(sp)+,d0-d7/a0-a5
	unlk	a6
	rts

	.end
