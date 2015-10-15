*	線分描画（ラインスタイル対応）

	.include	gconst.h
	.include	gmacro.h
*
	.xdef	gline_ls
	.xref	gclipline
	.xref	gramadr
*
	.offset	0	*gline_lsの引数構造
*
X0:	.ds.w	1	*始点座標
Y0:	.ds.w	1	*
X1:	.ds.w	1	*終点座標
Y1:	.ds.w	1	*
COL:	.ds.w	1	*描画色
BITPAT:	.ds.w	1	*ラインスタイル
*
	.text
	.even
*
gline_ls:
ARGPTR	=	4+8*4+6*4
	movem.l	d0-d7/a0-a5,-(sp)

	movea.l	ARGPTR(sp),a5	*a5 = 引数列

	movem.w	(a5),d0-d3	*d0～d3に座標を取り出す

	jsr	gclipline	*クリッピングする
	bne	done		*Z=0なら描画の必要なし

	move.w	BITPAT(a5),d7	*d7 = ラインスタイル
	beq	done

	jsr	gramadr		*始点のG-RAM上アドレスを得る

	sub.w	d0,d2		*d2 = x1-x0
	move.w	d2,d4		*d4 = d2
	ABS	d2		*d2 = dx = abs(x1-x0)
	SGN	d4		*d4 = sx = sgn(x1-x0)

	sub.w	d1,d3		*d3 = y1-y0
	move.w	d3,d5		*d5 = d3
	ABS	d3		*d3 = dy = abs(y1-y0)
	SGN	d5		*d5 = sy = sgn(y1-y0)

	add.w	d4,d4		*d4 = sx*2
	moveq.l	#GSFTCTR,d0	*
	asl.w	d0,d5		*d5 = sy*1024 (or 2048)

	move.w	COL(a5),d0	*d0 = 描画色

	cmp.w	d3,d2		*dy＞dxならば
	bcs	yline		*　yについてループ

			*dx≧dyのとき
xline:	move.w	d2,d1		*d1 = d2
	neg.w	d1		*d1 = e = -dx
	move.w	d2,d6		*d6 = n = dx
	add.w	d2,d2		*d2 = dx*2
	add.w	d3,d3		*d3 = dy*2
				*do {
xline0:	rol.w	#1,d7		*
	bcc	xskip		*
	move.w	d0,(a0)		*  pset(x,y)
xskip:	adda.w	d4,a0		*  x += sx
	add.w	d3,d1		*  e += 2*dy
	bmi	xline1		*  if (e >= 0) {
	adda.w	d5,a0		*    y += sy
	sub.w	d2,d1		*    e -= 2*dx
				*  }
xline1:	dbra	d6,xline0	*} while (--n >= 0)
	bra	done
			*dx＜dyのとき
yline:	move.w	d3,d1		*d1 = d3
	neg.w	d1		*d1 = e = -dy
	move.w	d3,d6		*d6 = n = dy
	add.w	d2,d2		*d2 = dx*2
	add.w	d3,d3		*d3 = dy*2
				*do {
yline0:	rol.w	#1,d7		*
	bcc	yskip		*
	move.w	d0,(a0)		*  pset(x,y)
yskip:	adda.w	d5,a0		*  y += sy
	add.w	d2,d1		*  e += 2*dx
	bmi	yline1		*  if (e >= 0) {
	adda.w	d4,a0		*    x += sx
	sub.w	d3,d1		*    e -= 2*dy
				*  }
yline1:	dbra	d6,yline0	*} while (--n >= 0)
done:	movem.l	(sp)+,d0-d7/a0-a5
	rts

	.end
