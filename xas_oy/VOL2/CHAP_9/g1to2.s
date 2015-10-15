*	��`�̈���c��1/2�ɏk������

DERGB_BREAK_HIGHWORD	=	1
	.include	gconst.h
	.include	gmacro.h
*
	.xdef	g1to2
	.xref	gramadr
	.xref	gcliprect
*
	.offset	0	*g1to2�̈����\��
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

	movea.l	ARGPTR(sp),a1	*a1 = ������
	movem.w	(a1),d0-d3	*d0�`d3=���W

	jsr	gcliprect	*�N���b�s���O����
	bne	done		*Z=0�Ȃ�`��̕K�v�Ȃ�

	jsr	gramadr		*G-RAM��̃A�h���X�𓾂�

	sub.w	d0,d2		*d2=���s�N�Z����-1
	sub.w	d1,d3		*d3=�c�s�N�Z����-1

	addq.w	#1,d2		*���s�N�Z�����𔼌�
	lsr.w	#1,d2		*
	subq.w	#1,d2		*
	bmi	done		*

	addq.w	#1,d3		*�c�s�N�Z�����𔼌�
	lsr.w	#1,d3		*
	subq.w	#1,d3		*
	bmi	done		*

	move.w	d2,a4		*a4=���s�N�Z����-1

	movea.l	a0,a2
loop1:	movea.l	a0,a1		*a1=�Q�ƌ����C�����[
	movea.l	a2,a3		*a3=�`��惉�C�����[
.ifdef	DITHERING
	swap.w	d3
	move.w	a2,d3
	andi.w	#2,d3
.endif

	move.w	a4,d1		*d1=���s�N�Z����-1
loop2:	move.w	(a1)+,d4	*(x,y)�̐F��
	_DERGB	d0,d2,d4	*�@rgb�ɕ���

	move.w	(a1)+,d7	*(x+1,y)�̐F��
	_DERGB	d5,d6,d7	*�@rgb�ɕ�������
	add.w	d5,d0		*�@���Z
	add.w	d6,d2		*
	add.w	d7,d4		*

	move.w	GNBYTE-4(a1),d7	*(x,y+1)�̐F��
	_DERGB	d5,d6,d7	*�@rgb�ɕ�������
	add.w	d5,d0		*�@���Z
	add.w	d6,d2		*
	add.w	d7,d4		*

	move.w	GNBYTE-2(a1),d7	*(x+1,y+1)�̐F��
	_DERGB	d5,d6,d7	*�@rgb�ɕ�������
	add.w	d5,d0		*�@���Z
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

	_RGB	d0,d2,d4	*�J���[�R�[�h�ɍč\������
	move.w	d4,(a3)+	*�@��������

.ifdef	DITHERING
	eori.w	#3,d3
.endif
	dbra	d1,loop2	*�������J��Ԃ�

	lea.l	GNBYTE*2(a0),a0	*�Q�ƌ��͂Q���C������
	lea.l	GNBYTE(a2),a2	*�`���͂P���C������

.ifdef	DITHERING
	swap.w	d3
.endif
	dbra	d3,loop1	*�������J��Ԃ�

done:	movem.l	(sp)+,SAVREGS
	rts

	.end
