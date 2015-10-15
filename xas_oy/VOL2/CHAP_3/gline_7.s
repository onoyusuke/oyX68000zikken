*	線分描画（65536倍整数化ダブルステップBresenham,
*			短線分＋１ピクセル方式）
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

	move.w	(a5),d0		*d0 = 描画色
	move.w	d0,d7		*
	swap.w	d0		*
	move.w	d7,d0		*

	cmp.w	d3,d2		*dy＞dxならば
	bcs	yline		*　yについてループ
	beq	xyline		*dy＝dxならば45度の線

			*dx≧dyのとき
xline:	addq.l	#2,a2		*プリデクリメントする分補正

	move.w	#$8000,d1	*d1 = e = -65536 * 1/2

	move.w	d3,d7		*
	lsl.w	#2,d7		*d7 = dy*4
	cmp.w	d2,d7		*
	bcc	xline0		*dy/dx >= 1/4

			*dx/dy＜1/4のとき
	addq.w	#1,d2
	addq.w	#1,d3
	ext.l	d2
	divu.w	d3,d2
	move.w	d2,d7
	move.w	#$20c0,d6	*move.l	d0,(a0)+
	lea.l	xxlin0(pc),a1
	bclr.l	#0,d7
	beq	notodd
	move.w	#$30c0,d6	*move.w	d0,(a0)+
	addq.w	#2,d7
notodd:	neg.w	d7
	adda.w	d7,a1
	move.w	d6,(a1)
	addi.w	#xxlin0-xxlin2-2,d7
	move.w	d7,xxlin2+2
	clr.w	d2
	divu.w	d3,d2
	subq.w	#1,d3
	jmp	(a1)

	.dcb.w	GNPIXEL/4,$20c0	*move.l d0,(a0)+
xxlin0:	add.w	d2,d1
	bcc	xxlin1
	move.w	d0,(a0)+
xxlin1:	adda.w	d5,a0
xxlin2:	dbra	d3,xxlin0

	move.w	#$20c0,(a1)	*move.l	d0,(a0)+
	bra	done

xline0:	swap.w	d3		*
	clr.w	d3		*
	divu.w	d2,d3		*d3 = 65536 * dy/dx
	move.w	d3,d4		*d4 = 65536 * dy/dx

	addq.w	#1,d2		*d7 = ４ピクセル未満の端数
	moveq.l	#3,d7		*
	and.w	d2,d7		*
	lsr.w	#2,d2		*ループカウンタを1/4
	subq.w	#1,d2		*
	bmi	xlineq		*

	add.w	d3,d3		*d3 = 2 * 65536 * dy/dx
	bcs	xline4

			*dy/dx＜1/2のとき
xline1:	add.w	d3,d1
	bcs	xline2

*	●●○

	move.l	d0,(a0)+
	move.l	d0,-(a2)

	dbra	d2,xline1

	bra	xlineq

xline2:	cmp.w	d4,d1
	bcc	xline3

*	　　○
*	●●

	move.l	d0,(a0)+
	move.l	d0,-(a2)
	adda.w	d5,a0
	suba.w	d5,a2

	dbra	d2,xline1
	bra	xlineq

*	　●○
*	●

xline3:	move.w	d0,(a0)+
	move.w	d0,-(a2)
	adda.w	d5,a0
	suba.w	d5,a2
	move.w	d0,(a0)+
	move.w	d0,-(a2)

	dbra	d2,xline1
	bra	xlineq

			*1/2≦dy/dx≦1のとき
xline4:	add.w	d3,d1
	bcc	xline5

*	　　○
*	　●
*	●

	move.w	d0,(a0)+
	move.w	d0,-(a2)
	adda.w	d5,a0
	suba.w	d5,a2
	move.w	d0,(a0)+
	move.w	d0,-(a2)
	adda.w	d5,a0
	suba.w	d5,a2

	dbra	d2,xline4
	bra	xlineq

xline5:	cmp.w	d4,d1
	bcc	xline6

*	　　○
*	●●

	move.l	d0,(a0)+
	move.l	d0,-(a2)
	adda.w	d5,a0
	suba.w	d5,a2

	dbra	d2,xline4
	bra	xlineq

*	　●○
*	●
xline6:	move.w	d0,(a0)+
	move.w	d0,-(a2)
	adda.w	d5,a0
	suba.w	d5,a2
	move.w	d0,(a0)+
	move.w	d0,-(a2)

	dbra	d2,xline4
*	bra	xlineq
*

xlineq:	add.w	d7,d7
	move.w	xtbl(pc,d7),d7
	jmp	xtbl(pc,d7)
xtbl:
x	=	xtbl
	.dc.w	done-x
	.dc.w	xleft1-x
	.dc.w	xleft2-x
	.dc.w	xleft3-x

xleft1:	move.w	d0,(a0)
	bra	done

xleft2:	move.w	d0,(a0)
	move.w	d0,-(a2)
	bra	done

xleft3:	move.w	d0,(a0)+
	move.w	d0,-(a2)
	add.w	d4,d1
	bcc	xleft4
	adda.w	d5,a0
xleft4:	move.w	d0,(a0)
	bra	done
*
			*dx＜dyのとき
yline:	move.w	d5,d6		*d6 = y変化時のG-RAMアドレス増分
	addq.w	#2,d6		*d6 = x, y変化時のG-RAMアドレス増分

	move.w	#$8000,d1	*d1 = -65536 * 1/2

	move.w	d2,d7
	lsl.w	#2,d7
	cmp.w	d3,d7
	bcc	yline0

			*dy/dx＜1/4のとき
	addq.w	#1,d2
	addq.w	#1,d3
	ext.l	d3
	divu.w	d2,d3
	move.w	d3,d7
	lsl.w	#2,d7
	neg.w	d7
	lea.l	yylin0(pc),a1
	adda.w	d7,a1
	addi.w	#yylin0-yylin1-2,d7
	move.w	d7,yylin1+2
	clr.w	d3
	divu.w	d2,d3
	subq.w	#1,d2
	jmp	(a1)

	.dcb.l	GNPIXEL/2,$3080_d0c5	*move.w d0,(a0) adda.w d5,a0
	move.w	d0,(a0)
	adda.w	d6,a0
yylin0:	add.w	d3,d1
	bcc	yylin1
	move.w	d0,-2(a0)
	adda.w	d5,a0
yylin1:	dbra	d2,yylin0

	bra	done

			*dx/dy＜1/2のとき
yline0:	swap.w	d2
	clr.w	d2
	divu.w	d3,d2
	move.w	d2,d4

	addq.w	#1,d3
	moveq.l	#3,d7
	and.w	d3,d7
	lsr.w	#2,d3
	subq.w	#1,d3
	bmi	ylineq

	add.w	d2,d2
	bcs	yline4

yline1:	add.w	d2,d1
	bcs	yline2

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

	dbra	d3,yline1

	bra	ylineq

yline2:	cmp.w	d4,d1
	bcc	yline3

*	　○
*	●
*	●

	move.w	d0,(a0)
	move.w	d0,(a2)
	adda.w	d5,a0
	suba.w	d5,a2
	move.w	d0,(a0)
	move.w	d0,(a2)
	adda.w	d6,a0
	suba.w	d6,a2

	dbra	d3,yline1
	bra	ylineq

*	　○
*	　●
*	●

yline3:	move.w	d0,(a0)
	move.w	d0,(a2)
	adda.w	d6,a0
	suba.w	d6,a2
	move.w	d0,(a0)
	move.w	d0,(a2)
	adda.w	d5,a0
	suba.w	d5,a2

	dbra	d3,yline1
	bra	ylineq

			*1/2≦dx/dy≦1のとき
yline4:	add.w	d2,d1
	bcc	yline5

*	　　○
*	　●
*	●

	move.w	d0,(a0)
	move.w	d0,(a2)
	adda.w	d6,a0
	suba.w	d6,a2
	move.w	d0,(a0)
	move.w	d0,(a2)
	adda.w	d6,a0
	suba.w	d6,a2

	dbra	d3,yline4
	bra	ylineq

yline5:	cmp.w	d4,d1
	bcc	yline6

*	　○
*	●
*	●

	move.w	d0,(a0)
	move.w	d0,(a2)
	adda.w	d5,a0
	suba.w	d5,a2
	move.w	d0,(a0)
	move.w	d0,(a2)
	adda.w	d6,a0
	suba.w	d6,a2

	dbra	d3,yline4
	bra	ylineq

*	　○
*	　●
*	●

yline6:	move.w	d0,(a0)
	move.w	d0,(a2)
	adda.w	d6,a0
	suba.w	d6,a2
	move.w	d0,(a0)
	move.w	d0,(a2)
	adda.w	d5,a0
	suba.w	d5,a2

	dbra	d3,yline4

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
	bcc	yleft4
	move.w	d0,0(a0,d6)
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
