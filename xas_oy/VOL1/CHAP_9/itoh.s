	.xdef	itoh		*�O����`
*
	.text
	.even
*
*itoh(value,buff)
*�@�\�F	32�r�b�g������16�i�W���̕�����ɕϊ�����
*���W�X�^�j��Fccr
*
*	ex)
*		pea.l	buff
*		move.l	#$12345678,-(sp)
*		bsr	itoh
*		addq.l	#8,sp
*		     �F
*	buff:	.ds.b	8+1
*
*
value	=	8
buff	=	12
*
itoh:
	link	a6,#0
	movem.l	d0-d2/a0,-(sp)

	move.l	value(a6),d0	*�l
	movea.l	buff(a6),a0	*������i�[�A�h���X

	moveq.l	#8-1,d2		*�ȉ����W��J��Ԃ�

itoh0:	rol.l	#4,d0		*d0.l�����ɂS�r�b�g��]����
	move.b	d0,d1		*d0�̉��ʃo�C�g��d1�Ɏ��o��
	andi.b	#$0f,d1		*�@���ʂS�r�b�g���c���ă}�X�N����
	addi.b	#'0',d1		*�����Ő��l����16�i��\��������
	cmpi.b	#'9'+1,d1	*�@�ϊ�����
	bcs	itoh1		*�@0�`9�̏ꍇ��'0'�𑫂���������
	addq.b	#'A'-'0'-10,d1	*  A�`F�̏ꍇ�͂���ɕ␳���K�v

itoh1:	move.b	d1,(a0)+	*�ϊ��������������܂�

	dbra	d2,itoh0	*�J��Ԃ�

	clr.b	(a0)		*������I�[�R�[�h����������

	movem.l	(sp)+,d0-d2/a0
	unlk	a6
	rts
