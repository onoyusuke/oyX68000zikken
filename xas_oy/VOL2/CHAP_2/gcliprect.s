*	��`�̈�̃N���b�s���O

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
*	(d0.w,d1.w)-(d2.w,d3.w)��
*	cliprect�Ŏw�肳�ꂽ��`�̈�ŃN���b�s���O����
*
gcliprect:
	move.l	a0,-(sp)
	lea.l	cliprect,a0

	MINMAX	d0,d2		*d0��d2��ۏ؂���
	MINMAX	d1,d3		*d1��d3��ۏ؂���

	cmp.w	MAXX(a0),d0	*d0��MAXX�H
	bgt	outofscrn	*�@�����Ȃ��ʊO
	cmp.w	MAXY(a0),d1	*d1��MAXY�H
	bgt	outofscrn	*�@�����Ȃ��ʊO

	cmp.w	MINX(a0),d2	*d2��MINX�H
	blt	outofscrn	*�@�����Ȃ��ʊO
	cmp.w	MINY(a0),d3	*d3��MINY�H
	blt	outofscrn	*�@�����Ȃ��ʊO

	cmp.w	MINX(a0),d0	*d0��MINX�H
	bge	skip1		*
	move.w	MINX(a0),d0	*�@�����Ȃ�C��

skip1:	cmp.w	MINY(a0),d1	*d1��MINY�H
	bge	skip2		*
	move.w	MINY(a0),d1	*�@�����Ȃ�C��

skip2:	cmp.w	MAXX(a0),d2	*d2��MAXX�H
	ble	skip3		*
	move.w	MAXX(a0),d2	*�@�����Ȃ�C��

skip3:	cmp.w	MAXY(a0),d3	*d3��MAXY�H
	ble	skip4		*
	move.w	MAXY(a0),d3	*�@�����Ȃ�C��

skip4:	cmp.w	d0,d0		*N=0
done:	movea.l	(sp)+,a0
	rts
*
outofscrn:
	moveq.l	#-1,d0		*N=1
	bra	done

	.end

�C������

92-01-01��
GCONST.H����荞��ł������s�v�������̂�, �Y��.include���폜
