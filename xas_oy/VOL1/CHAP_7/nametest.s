*	DOS�R�[��nameck�̓�����m�F����v���O����

	.include	doscall.mac
	.include	const.h
*
	.text
	.even
*
ent:
	lea.l	mysp,sp		*sp�̏�����

	pea.l	namebuf		*�^����ꂽ�R�}���h���C��������
	pea.l	1(a2)		*�@�t�@�C�����ƌ��Ȃ�
	DOS	_NAMECK		*�@nameck�œW�J����
	addq.l	#8,sp		*

	lea.l	hexbuf,a0	*d0.l��16�i�W���ɕϊ���
	bsr	itoh		*�@a0�̎w���̈�֊i�[���Ă���

	lea.l	prttbl,a0	*a0=�e�[�u���̐擪�A�h���X

	moveq.l	#4-1,d1		*�ȉ����S��J��Ԃ�

loop:	move.l	(a0)+,-(sp)	*���o��������\��
	DOS	_PRINT		*
	addq.l	#4,sp		*

	move.l	(a0)+,-(sp)	*�Ή�������e��\��
	DOS	_PRINT		*
	addq.l	#4,sp		*

	pea.l	crlfms		*���s����
	DOS	_PRINT		*
	addq.l	#4,sp		*

	dbra	d1,loop		*d1.w��-1�ɂȂ�܂ŌJ��Ԃ�

	DOS	_EXIT		*����I��

*
*	d0.l��16�i�W����\��������֕ϊ���(a0)�ȍ~�Ɋi�[����
*		���W�X�^�݂͂�ȕۑ�����
*
itoh:
	movem.l	d0-d2/a0,-(sp)	*�o���W�X�^�Ҕ�

	moveq.l	#8-1,d2		*�ȉ����W��J��Ԃ�

itoh0:	rol.l	#4,d0		*d0.l�����ɂS�r�b�g��]����
				*�S�r�b�g��16�i�P�����I
				*���Ƃ���
				*  $1234ABCD�@���@$234ABCD1
	move.b	d0,d1		*d0�̉��ʃo�C�g��d1�Ɏ��o��
	andi.b	#$0f,d1		*�@���ʂS�r�b�g���c���ă}�X�N����
				*d1�ɂ�d0.l��16�i�ŕ\�����Ƃ���
				*�@�ŏ�ʌ��������Ă���
	addi.b	#'0',d1		*�����Ő��l����16�i��\��������
	cmpi.b	#'9'+1,d1	*�@�ϊ�����
	bcs	itoh1		*�@0�`9�̏ꍇ��'0'�𑫂���������
	addq.b	#'A'-'0'-10,d1	*  A�`F�̏ꍇ�͂���ɕ␳���K�v

itoh1:	move.b	d1,(a0)+	*�ϊ��������������܂�

	dbra	d2,itoh0	*d2.w��-1�ɂȂ�܂ŌJ��Ԃ�

	clr.b	(a0)		*������I�[�R�[�h����������

	movem.l	(sp)+,d0-d2/a0	*�p���W�X�^���A
	rts

*
*	�f�[�^
*
	.data
	.even
*
prttbl:	.dc.l	mes1,hexbuf	*���o���Ƃ��̓��e��
	.dc.l	mes2,drive	*�@�Ή����������e�[�u���i�\�j
	.dc.l	mes3,name	*�@���o���̃A�h���X�Ɠ��e�̃A�h���X��
	.dc.l	mes4,ext	*�@�P�g�ɂȂ��Ă���
*
mes1:	.dc.b	'NAMACK�̖߂�l(d0.l)�F',0
mes2:	.dc.b	'              �p�X���F',0
mes3:	.dc.b	'          �t�@�C�����F',0
mes4:	.dc.b	'              �g���q�F',0
crlfms:	.dc.b	CR,LF,0

*
*	���[�N
*
	.bss
	.even
*
namebuf:			*nameck��
drive:	.ds.b	2		*�@�t�@�C�������W�J�����
path:	.ds.b	65		*�@�̈�
name:	.ds.b	19		*
ext:	.ds.b	5		*�v91�o�C�g
*
hexbuf:	.ds.b	8+1		*itoh��16�i��������i�[����̈�
*
	.stack
	.even
*
mystack:
	.ds.l	256		*�X�^�b�N�̈�
mysp:
	.end
