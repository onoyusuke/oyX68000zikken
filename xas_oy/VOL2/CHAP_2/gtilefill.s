*	矩形の塗り潰し（２色タイリング対応版）

	.include	gconst.h
*
	.xdef	gtilefill
	.xref	gramadr
	.xref	gcliprect
*
*	128ピクセル書き込むマクロ
*
H128	macro
	movem.l	d0/d4-d7/a3-a5,-(a1)
	movem.l	d0/d4-d7/a3-a5,-(a1)
	movem.l	d0/d4-d7/a3-a5,-(a1)
	movem.l	d0/d4-d7/a3-a5,-(a1)
	movem.l	d0/d4-d7/a3-a5,-(a1)
	movem.l	d0/d4-d7/a3-a5,-(a1)
	movem.l	d0/d4-d7/a3-a5,-(a1)
	movem.l	d0/d4-d7/a3-a5,-(a1)
	.endm
*
	.offset	0	*gtilefillの引数構造
*
X0:	.ds.w	1	*描画先座標
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
COL1:	.ds.w	1	*描画色1
COL2:	.ds.w	1	*描画色2
*
	.text
	.even
*
gtilefill:
ARGPTR	=	8
	link	a6,#0
	movem.l	d0-d7/a0-a5,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = 引数列
	movem.w	(a1),d0-d3	*d0〜d3に座標を取り出す

	jsr	gcliprect	*クリッピングする
	bmi	done		*N=1なら描画の必要なし

	jsr	gramadr		*左上のG-RAM上のアドレスを得る

	sub.w	d0,d2		*d2 = 横ピクセル数-1
	sub.w	d1,d3		*d3 = 縦ピクセル数-1
	addq.w	#1,d2		*d2 = 横ピクセル数

	eor.w	d0,d1		*
	eor.w	d2,d1		*
	move.l	COL1(a1),d0	*d0 = 描画色
	btst.l	#0,d1		*(0,0)にCOL1がくるよう
	beq	skip		*　必要ならCOL1とCOL2を交換する
	swap.w	d0		*COL1 ←→ COL2

skip:	adda.w	d2,a0		*
	adda.w	d2,a0		*a0 = (x1+1,y0)のG-RAMアドレス

	moveq.l	#16-1,d1	*
	and.w	d2,d1		*d1 = 横ピクセル数 % 16
	sub.w	d1,d2		*d2 = (横ピクセル数 / 16) * 16

	lsr.w	#2,d2		*d2 = (横ピクセル数 / 16) * 4
	lea.l	hline0(pc),a2	*
	suba.w	d2,a2		*a2 = (横ピクセル数/16)*16ピクセル分の
				*　水平線分描画ルーチン

loop1:	movea.l	a0,a1
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5
	jmp	(a2)		*１ライン描画

.ifdef	_1024
	H128	*1024
	H128	* :
	H128	* :
	H128	* :
.endif
	H128	*512
	H128	*384
	H128	*256
	H128	*128

hline0:	move.w	d1,d2		*16ピクセルに満たない
	bra	next2		*　端数を描画
loop2:	move.w	d0,-(a1)	*
	swap.w	d0		*COL1 ←→ COL2
next2:	dbra	d2,loop2	*
	move.l	d7,d0		*

next1:	swap.w	d0		*COL1 ←→ COL2
	lea.l	GNBYTE(a0),a0	*すぐ下のラインへ
	dbra	d3,loop1	*高さ分繰り返す

done:	movem.l	(sp)+,d0-d7/a0-a5
	unlk	a6
	rts

	.end
