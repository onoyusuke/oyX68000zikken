*	32�K�����m�N����

DERGB_BREAK_HIGHWORD	=	1
	.include	gconst.h
	.include	gmacro.h
*
	.xdef	gmonotone
	.xref	gramadr
	.xref	gcliprect
	.xref	grayscale
*
	.offset	0	*gmonotone�̈����\��
*
X0:	.ds.w	1	*��`���W
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
*
	.text
	.even
*
gmonotone:
ARGPTR	=	8
	link	a6,#0
	movem.l	d0-d6/a0-a3,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = ������
	movem.w	(a1),d0-d3	*d0�`d3�ɍ��W�����o��

	jsr	gcliprect	*�N���b�s���O����
	bne	done		*Z=0�Ȃ�`��̕K�v�Ȃ�

	jsr	gramadr		*G-RAM��̃A�h���X�𓾂�

	sub.w	d0,d2		*d2 = ���s�N�Z����-1
	sub.w	d1,d3		*d3 = �c�s�N�Z����-1

	lea.l	GNBYTE-2.w,a3	*a3 = ���C���Ԃ̃A�h���X�̍�
	suba.w	d2,a3		*�i�E�[���牺�̃��C���̍��[�܂Łj
	suba.w	d2,a3		*

	lea.l	grayscale,a1
	RGBtoYx_INIT	a2
loop1:	move.w	d2,d1		*d1 = ���s�N�Z����-1
loop2:	move.w	(a0),d6		*�F�R�[�h�����o��
	_DERGB	d4,d5,d6	*RGB�ɕ�������
	MAX	d5,d4		*R,G,B�̍ő�l��
	MAX	d6,d4		*�@d4�ɋ���
	add.w	d4,d4		*hsv(H,S,d4)�̐F��
	move.w	(a1,d4.w),(a0)+	*�@�_��ł�
	dbra	d1,loop2	*�������J��Ԃ�

	adda.l	a3,a0		*�������̃��C����
	dbra	d3,loop1	*�������J��Ԃ�

done:	movem.l	(sp)+,d0-d6/a0-a3
	unlk	a6
	rts

	.end
