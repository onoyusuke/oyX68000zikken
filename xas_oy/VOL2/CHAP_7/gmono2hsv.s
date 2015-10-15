*	�P�F���i�C�ӐF��, YIQ��Y���P�x�Ɏg���Łj

DERGB_BREAK_HIGHWORD	=	1
	.include	gconst.h
	.include	gmacro.h
*
	.xdef	gmonotone2_hsv
	.xref	hsvtorgb
	.xref	gramadr
	.xref	gcliprect
*
	.offset	0	*gmonotone2_hsv�̈����\��
*
X0:	.ds.w	1	*��`���W
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
H:	.ds.w	1	*�F��
S:	.ds.w	1	*�O�a�x
*
	.text
	.even
*
gmonotone2_hsv:
ARGPTR	=	8
TBLSIZ	=	RGBGRAD*2
	link	a6,#-TBLSIZ
	movem.l	d0-d6/a0-a3,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = ������
	movem.w	(a1)+,d0-d3	*d0�`d3�ɍ��W�����o��

	jsr	gcliprect	*�N���b�s���O����
	bne	done		*Z=0�Ȃ�`��̕K�v�Ȃ�

	jsr	gramadr		*G-RAM��̃A�h���X�𓾂�

	sub.w	d0,d2		*d2 = ���s�N�Z����-1
	sub.w	d1,d3		*d3 = �c�s�N�Z����-1

	move.l	(a1),d1		*hsv(H,S,0)�`hsv(H,S,31)��
	lea.l	-TBLSIZ(a6),a1	*�@�F�e�[�u��������Ă���
	lsl.w	#8,d1		*
	moveq.l	#RGBGRAD-1,d4	*
loop0:	move.l	d1,d0		*
	jsr	hsvtorgb	*
	move.w	d0,(a1)+	*
	addq.b	#1,d1		*
	dbra	d4,loop0	*

	lea.l	GNBYTE-2.w,a3	*a3 = ���C���Ԃ̃A�h���X�̍�
	suba.w	d2,a3		*�i�E�[���牺�̃��C���̍��[�܂Łj
	suba.w	d2,a3		*

	lea.l	-TBLSIZ(a6),a1
	RGBtoYx_INIT	a2
loop1:	move.w	d2,d1		*d1 = ���s�N�Z����-1
loop2:	move.w	(a0),d6		*�F�R�[�h�����o��
	_DERGB	d4,d5,d6	*RGB�ɕ�������
	RGBtoYx	d4,d5,d6,d0	*Y��d0�ɋ���
				*
	add.w	d0,d0		*hsv(H,S,d0)�̐F��
	move.w	(a1,d0.w),(a0)+	*�@�_��ł�
	dbra	d1,loop2	*�������J��Ԃ�

	adda.l	a3,a0		*�������̃��C����
	dbra	d3,loop1	*�������J��Ԃ�

done:	movem.l	(sp)+,d0-d6/a0-a3
	unlk	a6
	rts

	.end
