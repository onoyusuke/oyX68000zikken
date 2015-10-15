*	�F����

DERGB_BREAK_HIGHWORD	=	1
	.include	gconst.h
	.include	gmacro.h
*
	.xdef	gaccent
	.xref	gramadr
	.xref	gcliprect
*
	.offset	0	*gaccent�̈����\��
*
X0:	.ds.w	1	*��`���W
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
A:	.ds.w	1	*�������i��l64�j
*
	.offset	-RGBGRAD*2*2	*�X�^�b�N�t���[��
*
WORKTOP:
ATBL:	.ds.w	RGBGRAD	*0�`31��a�{�����e�[�u��
BTBL:	.ds.w	RGBGRAD	*0�`31��b=(a-1)/2�{�����e�[�u��
_a6:	.ds.l	1	*�}0
_pc:	.ds.l	1
ARGPTR:	.ds.l	1
*
	.text
	.even
*
gaccent:
	link	a6,#WORKTOP
	movem.l	d0-d7/a0-a2,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = ������
	movem.w	(a1)+,d0-d3	*d0�`d3�ɍ��W�����o��

	jsr	gcliprect	*�N���b�s���O����
	bne	done		*Z=0�Ȃ�`��̕K�v�Ȃ�

	jsr	gramadr		*G-RAM��̃A�h���X�𓾂�

	sub.w	d0,d2		*d2 = ���s�N�Z����-1
	sub.w	d1,d3		*d3 = �c�s�N�Z����-1

	move.w	(a1),d7		*d7 = a  �i������64�{�j
	move.w	d7,d6		*d6 = a-1�i������64�{�j
	subi.w	#64,d6		*

BOFST	=	BTBL-ATBL	*�Q�̃e�[�u���̃A�h���X�̍�

	lea.l	ATBL(a6),a1	*0�`31�̒l��a�{, (a-1)/2�{�����
	moveq.l	#0,d0		*�@�����ɂȂ邩�v�Z����
	moveq.l	#0,d1		*�@�e�[�u���ɂ��Ă���
	moveq.l	#32-1,d4	*
loop0:	move.w	d1,d5		*
	lsr.w	#1,d5		*
	move.w	d5,BOFST(a1)	*
	move.w	d0,(a1)+	*
	add.w	d7,d0		*
	add.w	d6,d1		*
	dbra	d4,loop0	*

	lea.l	GNBYTE-2.w,a2	*a2=���C���Ԃ̃A�h���X�̍�
	suba.w	d2,a2		*�i�E�[���牺�̃��C���̍��[�܂Łj
	suba.w	d2,a2		*

	lea.l	ATBL(a6),a1
loop1:	move.w	d2,d4		*d4=���s�N�Z����-1
	swap.w	d2
loop2:	move.w	(a0),d7		*�J���[�R�[�h�����o��
	_DERGB	d5,d6,d7	*RGB�ɕ�������
	add.w	d5,d5		*
	add.w	d6,d6		*
	add.w	d7,d7		*
	move.w	(a1,d5.w),d0		*d0 = Ab
	move.w	(a1,d6.w),d1		*d1 = Ar
	move.w	(a1,d7.w),d2		*d2 = Ag
	move.w	BOFST(a1,d5.w),d5	*d5 = Bb
	move.w	BOFST(a1,d6.w),d6	*d6 = Br
	move.w	BOFST(a1,d7.w),d7	*d7 = Bg

	sub.w	d6,d0		*d0 = b' = Ab-Br-Bg
	sub.w	d7,d0		*
	sub.w	d7,d1		*d1 = r' = Ar-Bg-Bb
	sub.w	d5,d1		*
	sub.w	d5,d2		*d2 = g' = Ag-Bb-Br
	sub.w	d6,d2		*

	asr.w	#6,d0		*1/64�ɂ���
	asr.w	#6,d1		*
	asr.w	#6,d2		*

	moveq.l	#0,d7		*�ŏ��P�x�ȏ��ۏ�
	MAX	d7,d0		*
	MAX	d7,d1		*
	MAX	d7,d2		*

	moveq.l	#RGBMAX,d7	*�ő�P�x�ȏ��ۏ�
	MIN	d7,d0		*
	MIN	d7,d1		*
	MIN	d7,d2		*

	_RGB	d0,d1,d2	*�J���[�R�[�h�ɍč\������
	move.w	d2,(a0)+	*�@�_��ł�

	dbra	d4,loop2	*�������J��Ԃ�

	swap.w	d2
	adda.l	a2,a0		*�������̃��C����
	dbra	d3,loop1	*�������J��Ԃ�

done:	movem.l	(sp)+,d0-d7/a0-a2
	unlk	a6
	rts

	.end
