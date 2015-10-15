*	線分描画（65536倍整数化Bresenham）

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

	move.w	#$8000,d1	*d1 = e = -65536 * 1/2

	cmp.w	d3,d2		*dy＞dxならば
	bcs	yline		*　yについてループ
	beq	xyline		*dy＝dxならば45度の線

			*dx≧dyのとき
xline:	swap.w	d3		*
	clr.w	d3		*d3 = 65536*dy
	divu.w	d2,d3		*d3 = 65536*dy/dx
	subq.w	#1,d2		*dbraの動作を計算に入れて
	lsr.w	#1,d2		*　ループカウンタを半減
	scs.b	d4		*奇数ピクセルのとき非0
	addq.l	#2,a2		*プリデクリメントする分補正
				*do {
xline0:	move.w	d0,(a0)+	*  pset(x++,y)
	move.w	d0,-(a2)	*  pset(--x',y')
	add.w	d3,d1		*  e += 2*dy
	bcc	xline1		*  if (e >= 0) {
	adda.w	d5,a0		*    y += sy
	suba.w	d5,a2		*    y'-= sy
				*  }
xline1:	dbra	d2,xline0	*} while (--n >= 0)

	tst.b	d4		*奇数ピクセル？
	beq	done		*　そうじゃない
	bra	odd		*中央のピクセルを点灯

			*dx＜dyのとき
yline:	swap.w	d2		*
	clr.w	d2		*d2 = 65536*dx
	divu.w	d3,d2		*d2 = 65536*dx/dy
	subq.w	#1,d3		*dbraの動作を計算に入れて
	lsr.w	#1,d3		*　ループカウンタを半減
	scs.b	d4		*奇数ピクセルのとき非0
	move.w	d5,d6		*d6 = d5 + 2
	addq.w	#2,d6		*
				*do {
yline0:	add.w	d2,d1		*  e += 2*dx
	bcs	yline1		*  if (e < 0) {
	move.w	d0,(a0)		*    pset(x,y)
	adda.w	d5,a0		*    y += sy
	move.w	d0,(a2)		*    pset(x',y')
	suba.w	d5,a2		*    y'-= sy
				*  }
	dbra	d3,yline0
	bra	done0
				*  else {
yline1:	move.w	d0,(a0)		*    pset(x++,y)
	adda.w	d6,a0		*    y += sy
	move.w	d0,(a2)		*    pset(x',y')
	suba.w	d6,a2		*    x'--, y'-= sy
				*  }
	dbra	d3,yline0	*} while (--n >= 0)

done0:	tst.b	d4		*奇数ピクセル？
	beq	done		*　そうじゃない
odd:	move.w	d0,(a0)		*中央のピクセルを点灯

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
