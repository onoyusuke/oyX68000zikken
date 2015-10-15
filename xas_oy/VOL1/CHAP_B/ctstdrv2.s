*	�����p�f�o�C�X�h���C�o

	.include	doscall.mac
	.include	const.h
	.include	driver.h
*
	.text
	.even
*
*	�f�o�C�X�w�b�_
*
device_header:
	.dc.l	-1
	.dc.w	CHAR_DEVICE+DISABLE_IOCTRL+COOKED_MODE
	.dc.l	strategy_entry
	.dc.l	interrupt_entry
	.dc.b	'CHRTEST '
*		 12345678
*
request_header:			*���N�G�X�g�w�b�_�Ҕ�̈�
	.dc.l	0

*
*	�X�g���e�W���[�`��
*
strategy_entry:
	move.l	a5,request_header	*���N�G�X�g�w�b�_�ւ̃|�C���^��
					*�@�Ҕ�����
	rts				*���₩�ɖ߂�

*
*	���荞�݃��[�`��
*
interrupt_entry:
	movem.l	d0/a4-a5,-(sp)		*���W�X�^�Ҕ�

	movea.l	request_header,a5	*a5=���N�G�X�g�w�b�_

	bsr	test
	moveq.l	#0,d0			*d0.l=�R�}���h�R�[�h
	move.b	CMD_CODE(a5),d0		*
	add.w	d0,d0			*2�{����
	add.w	d0,d0			*2�{��2�{��4�{
	lea.l	jump_table,a4		*a4=�W�����v�e�[�u���擪
	adda.l	d0,a4			*a4=�R�}���h�������[�`���ւ�
					*�@�|�C���^�ւ̃|�C���^
	movea.l	(a4),a4			*a4=�R�}���h�������[�`���ւ�
					*�@�|�C���^
	jsr	(a4)			*a4�̎w���A�h���X��
					*�@�T�u���[�`���R�[��

	move.b	d0,ERR_LOW(a5)		*�I���X�e�[�^�X���Z�b�g
	lsr.w	#8,d0			*
	move.b	d0,ERR_HIGH(a5)		*

	movem.l	(sp)+,d0/a4-a5		*���W�X�^���A
	rts				*Human�֖߂�

*
*	�R�}���h�����W�����v�e�[�u��
*
jump_table:
	.dc.l	init		*0	������
	.dc.l	notcmd		*1	�i�����j
	.dc.l	notcmd		*2	�i�����j
	.dc.l	ioctrl_in	*3	IOCTRL�ɂ�����
	.dc.l	input		*4	����
	.dc.l	sense		*5	�P�o�C�g��ǂݓ���
	.dc.l	inpstat		*6	���̓X�e�[�^�X���`�F�b�N
	.dc.l	flush		*7	���̓o�b�t�@���N���A
	.dc.l	output		*8	�o�́iVERIFY OFF�j
	.dc.l	voutput		*9	�o�́iVERIFY ON�j
	.dc.l	outstat		*10	�o�̓X�e�[�^�X���`�F�b�N
	.dc.l	notcmd		*11	�i�����j
	.dc.l	ioctrl_out	*12	IOCTRL�ɂ��o��

*
*	�e�R�}���h�̏���
*

*
*	�����i�R�}���h�R�[�h1,2,11�j
*	IOCTRL�ɂ����́i�R�}���h�R�[�h3�j
*	IOCTRL�ɂ��o�́i�R�}���h�R�[�h12�j
*
notcmd:
ioctrl_in:
ioctrl_out:
	move.w	#ILLEGAL_CMD,d0		*�G���[�R�[�h��������
	rts				*�@�߂�

*
*	���́i�R�}���h�R�[�h4�j
*
input:
	tst.l	DMA_LEN(a5)		*���͗v�����O�o�C�g�ł����
	beq	done			*�@���������ɖ߂�
				*�����łȂ����
	movea.l	DMA_ADR(a5),a4		*a4=�f�[�^�ǂݍ��ݗ̈�
	move.b	#EOF,(a4)		*���̓f�[�^���Z�b�g

done:	moveq.l	#0,d0			*����I��
	rts

*
*	�P�o�C�g��ǂݓ��́i�R�}���h�R�[�h5�j
*
sense:
	move.b	#EOF,SNS_DATA(a5)	*��ǂ݃f�[�^���Z�b�g
	bra	done			*����I��

*
inpstat:		*���̓X�e�[�^�X�`�F�b�N�i�R�}���h�R�[�h6�j
flush:			*���̓o�b�t�@�N���A�i�R�}���h�R�[�h7�j
output:			*VERIFY OFF���̏o�́i�R�}���h�R�[�h8�j
voutput:		*VERIFY ON���̏o�́i�R�}���h�R�[�h9�j
outstat:		*�o�̓X�e�[�^�X�`�F�b�N�i�R�}���h�R�[�h10�j
	bra	done			*����I��
*
*	�����p���[�`��
*
test:
	move.l	d1,-(sp)

	bsr	showcmd			*�R�}���h�̎�ނ�\��
	bsr	showlen			*���o�͌n�R�}���h�ł����
					*�@�f�[�^����\��
	move.l	(sp)+,d1
	rts

*
*	�R�}���h�̎�ނ�\������
*
showcmd:
	moveq.l	#0,d0			*�R�}���h�̎�ނ�\���������
	move.b	CMD_CODE(a5),d0		*�@�擪�A�h���X��a4�ɓ���
	add.w	d0,d0			*
	add.w	d0,d0			*
	lea.l	cmd_table,a4		*
	add.l	d0,a4			*
	movea.l	(a4),a4			*

	move.l	a4,-(sp)		*�R�}���h�̎�ނ�\������
	move.w	#1,-(sp)		*
	DOS	_CONCTRL		*

	move.l	#crlfms,2(sp)		*���s����
	DOS	_CONCTRL		*
	addq.l	#6,sp			*
	rts

*
*	���b�Z�[�W�ւ̃|�C���^�̃e�[�u��
*
cmd_table:
	.dc.l	mes00,mes01,mes02,mes03
	.dc.l	mes04,mes05,mes06,mes07
	.dc.l	mes08,mes09,mes10,mes11
	.dc.l	mes12

*
*	���o�͌n�R�}���h�ł���΃f�[�^����16�i�\������
*
showlen:
	moveq.l	#0,d0			*d0.l=�R�}���h�ԍ�
	move.b	CMD_CODE(a5),d0		*
	move.l	#%00010011_00011000,d1	*���o�͌n�R�}���h���ǂ�����
	btst.l	d0,d1			*�@���ׂ�
	beq	slen0			*�����łȂ���Ή������Ȃ�

	pea.l	temp			*�f�[�^����16�i8���ɕϊ�����
	move.l	DMA_LEN(a5),-(sp)	*
	bsr	itoh			*
	addq.l	#8,sp			*
	pea.l	temp			*�\������
	move.w	#1,-(sp)		*
	DOS	_CONCTRL		*

	move.l	#crlfms,2(sp)		*���s����
	DOS	_CONCTRL		*
	addq.l	#6,sp			*
slen0:	rts

*
*	���l��16�i������ϊ�
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

*
*	�R�}���h�̎�ޕ\���p������
*
mes00:	.dc.b	'������',0
mes01:	.dc.b	'�R�}���h�P�i�����j',0
mes02:	.dc.b	'�R�}���h�Q�i�����j',0
mes03:	.dc.b	'IOCTRL�ɂ�����',0
mes04:	.dc.b	'����',0
mes05:	.dc.b	'��ǂݓ���',0
mes06:	.dc.b	'���̓X�e�[�^�X���`�F�b�N',0
mes07:	.dc.b	'���̓o�b�t�@���N���A',0
mes08:	.dc.b	'�o�́iVERIFY OFF�j',0
mes09:	.dc.b	'�o�́iVERIFY ON�j',0
mes10:	.dc.b	'�o�̓X�e�[�^�X���`�F�b�N',0
mes11:	.dc.b	'�R�}���h11�i�����j',0
mes12:	.dc.b	'IOCTRL�ɂ��o��',0
*
crlfms:	.dc.b	CR,LF,0			*���s�p������
*
temp:	.ds.b	8+1			*16�i�ϊ��p�o�b�t�@
*
	.even
*
*	�������܂ł��������ɋ�����f�o�C�X�h���C�o�{��

*
*	�������i�R�}���h�R�[�h0�j
*
init:
	pea.l	title			*�^�C�g����\��
	DOS	_PRINT			*
	addq.l	#4,sp			*

	move.l	#init,DEV_END_ADR(a5)	*�f�o�C�X�h���C�o�{�̂�
					*�@�ŏI�A�h���X���Z�b�g

	bra	done			*����I��
*
	.data
	.even
*
title:					*�^�C�g�����b�Z�[�W
	.dc.b	CR,LF
	.dc.b	'�����p�L�����N�^�f�o�C�X',CR,LF
	.dc.b	'CHRTEST�̖��O�œ��o�͎������s���܂�',CR,LF
	.dc.b	0

	.end
