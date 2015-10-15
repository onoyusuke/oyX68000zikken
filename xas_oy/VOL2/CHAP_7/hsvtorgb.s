*	hsvからrgbへの変換

	.include	gmacro.h
*
	.xdef	hsvtorgb
*
	.text
	.even
*
*	d0.l = hhhhhhhhhhhhhhhh_000sssss_000vvvvv
*	→ d0.w = gggggrrrrrbbbbb0
*
hsvtorgb:
	movem.l	d1-d5,-(sp)

	moveq.l	#0,d2
	move.b	d0,d2		*d2 = v

	moveq.l	#0,d3
	lsr.w	#8,d0
	move.b	d0,d3		*d3 = s
	bne	sskip

			*無彩色の場合
	move.w	d2,d1		*r = g = b = v		*debug 92-02-03
	move.w	d2,d3		*
	bra	encode

			*有彩色の場合
sskip:	swap.w	d0		*d0 = h
	ext.l	d0		*hを0～191に正規化する
	divs.w	#192,d0		*
	swap.w	d0		*
	tst.w	d0		*
	bpl	hskip		*
	addi.w	#192,d0		*

hskip:	moveq.l	#31,d4
	and.w	d0,d4		*d4 = t = h%32
	mulu.w	d3,d4		*d4 = s*t
	lsl.w	#5,d3		*d3 = s*32
	move.w	d4,d5		*d5 = s*t
	sub.w	d3,d5		*d5 = -s*(32-t)
	neg.w	d4		*d4 = -s*t
	neg.w	d3		*d3 = -s*32

	move.w	#31*32,d1
	add.w	d1,d3		*d3 = 31*32-s*32
	add.w	d1,d4		*d4 = 31*32-s*t
	add.w	d1,d5		*d5 = 31*32-s*(32-t)
	mulu.w	d2,d3		*d3 = v*(31*32-s*32)
	mulu.w	d2,d4		*d4 = v*(31*32-s*t)
	mulu.w	d2,d5		*d5 = v*(31*32-s*(32-t))
	move.w	#31*16,d1
	add.w	d1,d3		*d3 = v*(31*32-s*32)+31*16
	add.w	d1,d4		*d4 = v*(31*32-s*t)+31*16
	add.w	d1,d5		*d5 = v*(31*32-s*(32-t))+31*16
	add.w	d1,d1
	divu.w	d1,d3		*d3 = (v*(31*32-s*32)+31*16)/(31*32)
	divu.w	d1,d4		*d4 = (v*(31*32-s*t)+31*16)/(31*32)
	divu.w	d1,d5		*d5 = (v*(31*32-s*(32-t))+31*16)/(31*32)

	lsr.w	#5,d0
	add.w	d0,d0
	move.w	jmptbl(pc,d0),d0
	jsr	jmptbl(pc,d0)

encode:	RGB	d1,d2,d3,d0	*RGBからカラーコードに構成する

	movem.l	(sp)+,d1-d5
	rts
*
jmptbl:
x	=	jmptbl
	.dc.w	RtoY-x
	.dc.w	YtoG-x
	.dc.w	GtoC-x
	.dc.w	CtoB-x
	.dc.w	BtoM-x
	.dc.w	MtoR-x
*
RtoY:	move.w	d3,d1		*赤～黄
	move.w	d5,d3
	rts
YtoG:	move.w	d3,d1		*黄～緑
	move.w	d2,d3
	move.w	d4,d2
	rts
GtoC:	move.w	d5,d1		*緑～シアン
	exg.l	d2,d3
	rts
CtoB:	move.w	d2,d1		*シアン～青
	move.w	d3,d2
	move.w	d4,d3
	rts
BtoM:	move.w	d2,d1		*青～マゼンタ
	move.w	d5,d2
	rts
MtoR:	move.w	d4,d1		*マゼンタ～赤
	rts

	.end

修正履歴

92-04-01版
無彩色時の結果が正しくなかったのを修正
