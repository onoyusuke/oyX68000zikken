*	矩形領域を縦横1/2に縮小する

DERGB_BREAK_HIGHWORD	=	1
	.include	gconst.h
	.include	gmacro.h
*
	.xdef	g1to2
	.xref	gramadr
	.xref	gcliprect
*
	.offset	0	*g1to2の引数構造
*
X0:	.ds.w	1
Y0:	.ds.w	1
X1:	.ds.w	1
Y1:	.ds.w	1
*
	.text
	.even
*
g1to2:
SAVREGS	reg	d0-d7/a0-a4
SAVSIZ	set	(8+5)*4
ARGPTR	set	4+SAVSIZ
	movem.l	SAVREGS,-(sp)

	movea.l	ARGPTR(sp),a1	*a1 = 引数列
	movem.w	(a1),d0-d3	*d0～d3=座標

	jsr	gcliprect	*クリッピングする
	bne	done		*Z=0なら描画の必要なし

	jsr	gramadr		*G-RAM上のアドレスを得る

	sub.w	d0,d2		*d2=横ピクセル数-1
	sub.w	d1,d3		*d3=縦ピクセル数-1

	addq.w	#1,d2		*横ピクセル数を半減
	lsr.w	#1,d2		*
	subq.w	#1,d2		*
	bmi	done		*

	addq.w	#1,d3		*縦ピクセル数を半減
	lsr.w	#1,d3		*
	subq.w	#1,d3		*
	bmi	done		*

	move.w	d2,a4		*a4=横ピクセル数-1

	movea.l	a0,a2
loop1:	movea.l	a0,a1		*a1=参照元ライン左端
	movea.l	a2,a3		*a3=描画先ライン左端
.ifdef	DITHERING
	swap.w	d3
	move.w	a2,d3
	andi.w	#2,d3
.endif

	move.w	a4,d1		*d1=横ピクセル数-1
loop2:	move.w	(a1)+,d4	*(x,y)の色を
	_DERGB	d0,d2,d4	*　rgbに分解

	move.w	(a1)+,d7	*(x+1,y)の色を
	_DERGB	d5,d6,d7	*　rgbに分解して
	add.w	d5,d0		*　加算
	add.w	d6,d2		*
	add.w	d7,d4		*

	move.w	GNBYTE-4(a1),d7	*(x,y+1)の色を
	_DERGB	d5,d6,d7	*　rgbに分解して
	add.w	d5,d0		*　加算
	add.w	d6,d2		*
	add.w	d7,d4		*

	move.w	GNBYTE-2(a1),d7	*(x+1,y+1)の色を
	_DERGB	d5,d6,d7	*　rgbに分解して
	add.w	d5,d0		*　加算
	add.w	d6,d2		*
	add.w	d7,d4		*

.ifdef	DITHERING
	add.w	d3,d0
	add.w	d3,d2
	add.w	d3,d4
.else
	addq.w	#4/2,d0
	addq.w	#4/2,d2
	addq.w	#4/2,d4
.endif
	lsr.w	#2,d0		*b/4
	lsr.w	#2,d2		*r/4
	lsr.w	#2,d4		*g/4

	_RGB	d0,d2,d4	*カラーコードに再構成して
	move.w	d4,(a3)+	*　書き込む

.ifdef	DITHERING
	eori.w	#3,d3
.endif
	dbra	d1,loop2	*横幅分繰り返す

	lea.l	GNBYTE*2(a0),a0	*参照元は２ライン下へ
	lea.l	GNBYTE(a2),a2	*描画先は１ライン下へ

.ifdef	DITHERING
	swap.w	d3
.endif
	dbra	d3,loop1	*高さ分繰り返す

done:	movem.l	(sp)+,SAVREGS
	rts

	.end
