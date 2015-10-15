*	�����`��i65536�{�������_�u���X�e�b�vBresenham,
*			�Z�����{�P�s�N�Z�������j
	.include	gconst.h
*
	.xdef	gline
	.xref	gclipline
	.xref	gbase
*
	.offset	0	*gline�̈����\��
*
X0:	.ds.w	1	*�n�_���W
Y0:	.ds.w	1	*
X1:	.ds.w	1	*�I�_���W
Y1:	.ds.w	1	*
COL:	.ds.w	1	*�`��F
*
	.text
	.even
*
gline:
ARGPTR	=	4+8*4+6*4
	movem.l	d0-d7/a0-a5,-(sp)

	movea.l	ARGPTR(sp),a5	*a5 = ������
	movem.w	(a5)+,d0-d3	*d0�`d3�ɍ��W�����o��

	jsr	gclipline	*�N���b�s���O����
	bne	done		*Z=0�Ȃ犮�S�s��

 	cmp.w	d2,d0		*x0��x1��ۏ؂���
	ble	gline0		*
	exg.l	d0,d2		*
	exg.l	d1,d3		*

gline0:	move.w	d1,d6		*�n�_/�I�_��G-RAM�A�h���X�����߂�
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
	add.l	d6,a0		*a0 = �n�_��G-RAM�A�h���X
	add.l	d7,a2		*a2 = �I�_��G-RAM�A�h���X

	move.w	#GNBYTE,d5	*d5 = ��1���C�����̃o�C�g��
	sub.w	d1,d3		*d3 = y1-y0
	beq	hor_line	*y0��y1�Ȃ琅����
	bpl	gline1
	neg.w	d3
	neg.w	d5
gline1:	sub.w	d0,d2		*d2 = x1-x0 ( >=0 )
	beq	ver_line	*x0��x1�Ȃ琂����
*���̎��_��
*	d2 = dx = abs(x1-x0) ( > 0 )
*	d3 = dy = abs(y1-y0) ( > 0 )
*	d5 = sy = sgn(y1-y0) ( -1 or 1 )
*	�i������d5��GNBYTE�{�ς݁j

	move.w	(a5),d0		*d0 = �`��F
	move.w	d0,d7		*
	swap.w	d0		*
	move.w	d7,d0		*

	cmp.w	d3,d2		*dy��dx�Ȃ��
	bcs	yline		*�@y�ɂ��ă��[�v
	beq	xyline		*dy��dx�Ȃ��45�x�̐�

			*dx��dy�̂Ƃ�
xline:	addq.l	#2,a2		*�v���f�N�������g���镪�␳

	move.w	#$8000,d1	*d1 = e = -65536 * 1/2

	move.w	d3,d7		*
	lsl.w	#2,d7		*d7 = dy*4
	cmp.w	d2,d7		*
	bcc	xline0		*dy/dx >= 1/4

			*dx/dy��1/4�̂Ƃ�
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

	addq.w	#1,d2		*d7 = �S�s�N�Z�������̒[��
	moveq.l	#3,d7		*
	and.w	d2,d7		*
	lsr.w	#2,d2		*���[�v�J�E���^��1/4
	subq.w	#1,d2		*
	bmi	xlineq		*

	add.w	d3,d3		*d3 = 2 * 65536 * dy/dx
	bcs	xline4

			*dy/dx��1/2�̂Ƃ�
xline1:	add.w	d3,d1
	bcs	xline2

*	������

	move.l	d0,(a0)+
	move.l	d0,-(a2)

	dbra	d2,xline1

	bra	xlineq

xline2:	cmp.w	d4,d1
	bcc	xline3

*	�@�@��
*	����

	move.l	d0,(a0)+
	move.l	d0,-(a2)
	adda.w	d5,a0
	suba.w	d5,a2

	dbra	d2,xline1
	bra	xlineq

*	�@����
*	��

xline3:	move.w	d0,(a0)+
	move.w	d0,-(a2)
	adda.w	d5,a0
	suba.w	d5,a2
	move.w	d0,(a0)+
	move.w	d0,-(a2)

	dbra	d2,xline1
	bra	xlineq

			*1/2��dy/dx��1�̂Ƃ�
xline4:	add.w	d3,d1
	bcc	xline5

*	�@�@��
*	�@��
*	��

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

*	�@�@��
*	����

	move.l	d0,(a0)+
	move.l	d0,-(a2)
	adda.w	d5,a0
	suba.w	d5,a2

	dbra	d2,xline4
	bra	xlineq

*	�@����
*	��
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
			*dx��dy�̂Ƃ�
yline:	move.w	d5,d6		*d6 = y�ω�����G-RAM�A�h���X����
	addq.w	#2,d6		*d6 = x, y�ω�����G-RAM�A�h���X����

	move.w	#$8000,d1	*d1 = -65536 * 1/2

	move.w	d2,d7
	lsl.w	#2,d7
	cmp.w	d3,d7
	bcc	yline0

			*dy/dx��1/4�̂Ƃ�
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

			*dx/dy��1/2�̂Ƃ�
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

*	��
*	��
*	��

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

*	�@��
*	��
*	��

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

*	�@��
*	�@��
*	��

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

			*1/2��dx/dy��1�̂Ƃ�
yline4:	add.w	d2,d1
	bcc	yline5

*	�@�@��
*	�@��
*	��

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

*	�@��
*	��
*	��

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

*	�@��
*	�@��
*	��

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
hor_line:		*��������
	sub.w	d0,d2		*d2 = dx = x1-x0
	move.w	(a5),d1		*d0.l = �`��F�i���/���ʂƂ��j
	move.w	d1,d0		*
	swap.w	d0		*
	move.w	d1,d0		*
	addq.w	#1,d2		*d2 = dx+1 = �s�N�Z����
	bclr.l	#0,d2		*
	beq	hskip		*
	move.w	d0,(a0)+	*��s�N�Z���̕�
hskip:	lea.l	ghline,a1
	suba.w	d2,a1
	jsr	(a1)
hline:	bra	done

xyline:			*45�x�̐���
	move.w	(a5),d0		*d0 = color
	addq.w	#1,d3		*d3 = dy+1
	moveq.l	#8-1,d4		*
	and.w	d3,d4		*d4 = �W�s�N�Z�������̒[��
	lsr.w	#3,d3		*d3 = (dy+1)/8
	lsl.w	#2,d4		*move��adda�łS�o�C�g
	neg.w	d4		*
	jmp	xynext(pc,d4)	*���[�v�̓r���ɔ�э���

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
xynext:	dbra	d3,xyloop	*(dy+1)/8��J��Ԃ�
	bra	done

ver_line:		*��������
	tst.w	d5		*d5 = sy
	bpl	vskip		*a0 <= a2��
	movea.l	a2,a0		*�@�ۏ؂���
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
