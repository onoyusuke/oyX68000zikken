*	矩形領域のクリッピング

*.include	gconst.h
	.include	gmacro.h
	.include	rect.h
*
	.xdef	gcliprect
	.xref	cliprect
*
	.text
	.even
*
*	(d0.w,d1.w)-(d2.w,d3.w)を
*	cliprectで指定された矩形領域でクリッピングする
*
gcliprect:
	move.l	a0,-(sp)
	lea.l	cliprect,a0

	MINMAX	d0,d2		*d0≦d2を保証する
	MINMAX	d1,d3		*d1≦d3を保証する

	cmp.w	MAXX(a0),d0	*d0＞MAXX？
	bgt	outofscrn	*　そうなら画面外
	cmp.w	MAXY(a0),d1	*d1＞MAXY？
	bgt	outofscrn	*　そうなら画面外

	cmp.w	MINX(a0),d2	*d2＜MINX？
	blt	outofscrn	*　そうなら画面外
	cmp.w	MINY(a0),d3	*d3＜MINY？
	blt	outofscrn	*　そうなら画面外

	cmp.w	MINX(a0),d0	*d0＜MINX？
	bge	skip1		*
	move.w	MINX(a0),d0	*　そうなら修正

skip1:	cmp.w	MINY(a0),d1	*d1＜MINY？
	bge	skip2		*
	move.w	MINY(a0),d1	*　そうなら修正

skip2:	cmp.w	MAXX(a0),d2	*d2＞MAXX？
	ble	skip3		*
	move.w	MAXX(a0),d2	*　そうなら修正

skip3:	cmp.w	MAXY(a0),d3	*d3＞MAXY？
	ble	skip4		*
	move.w	MAXY(a0),d3	*　そうなら修正

skip4:	cmp.w	d0,d0		*N=0
done:	movea.l	(sp)+,a0
	rts
*
outofscrn:
	moveq.l	#-1,d0		*N=1
	bra	done

	.end

修正履歴

92-01-01版
GCONST.Hを取り込んでいたが不要だったので, 該当.includeを削除
