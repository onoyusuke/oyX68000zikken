*	TAP�h���C�o�i�o�b�t�@�T�C�Y�Œ�Łj

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
	.dc.b	'TAP     '
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
	movem.l	d0-d2/a0-a1/a4-a5,-(sp)	*���W�X�^�Ҕ�

	movea.l	request_header,a5	*a5=���N�G�X�g�w�b�_

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

	movem.l	(sp)+,d0-d2/a0-a1/a4-a5	*���W�X�^���A
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
	move.l	DMA_LEN(a5),d2		*���͗v�����O�o�C�g�ł����
	beq	done			*�@���������ɖ߂�
				*�����łȂ����
	movea.l	readptr,a0		*a0=�ǂݏo���ʒu
	movea.l	DMA_ADR(a5),a4		*a4=�f�[�^�ǂݍ��ݗ̈�
					*d2.l=���͗v���o�C�g��

inp0:	cmpa.l	writeptr,a0		*�f�[�^�������Ȃ����
	beq	empty			*�@���[�v�𔲂���
	move.b	(a0)+,(a4)+		*1�o�C�g�]��
	cmpa.l	buffend,a0		*�|�C���^���o�b�t�@�Ō��
	bcs	inp1			*�@�z������
	lea.l	bufftop,a0		*�@�擪���w���悤�ɏC������
inp1:	subq.l	#1,d2			*���[�v�J�E���^d2.l��0�ɂȂ�܂�
	bne	inp0			*�@�J��Ԃ�

	move.l	a0,readptr		*�ǂݏo���p�|�C���^�X�V

done:	moveq.l	#0,d0			*����I��
	rts

empty:	move.b	#EOF,(a4)		*�o�b�t�@����̏ꍇ��
					*�@EOF��Ԃ�
	bra	done			*����I��

*
*	VERIFY OFF���̏o�́i�R�}���h�R�[�h8�j
*	VERIFY ON���̏o�́i�R�}���h�R�[�h9�j
output:
voutput:
	move.l	DMA_LEN(a5),d2		*���͗v�����O�o�C�g�ł����
	beq	done			*�@���������ɖ߂�
				*�����łȂ����
	movea.l	writeptr,a0		*a0=���ɏ������ވʒu
	movea.l	readptr,a1		*a1=���ɓǂݏo���ʒu
	movea.l	DMA_ADR(a5),a4		*a4=�o�̓f�[�^
					*d2.l=�o�͗v���o�C�g��

	moveq.l	#0,d1			*��Ɨp���W�X�^���N���A

out0:	move.b	(a4)+,d1		*�P�o�C�g���o��
	move.b	d1,(a0)+		*�o�b�t�@�ɒǉ�

	cmpi.b	#EOF,d1			*EOF�R�[�h�͉�ʃN���A��
					*�@�R���g���[���R�[�h�Ȃ̂�
	beq	out1			*�@�\���͂��Ȃ�

	move.l	d1,-(sp)		*�P�o�C�g��ʂɏo��
	DOS	_CONCTRL		*
	addq.l	#4,sp			*

out1:	cmpa.l	buffend,a0		*�|�C���^���o�b�t�@�Ō��
	bcs	out2			*�@�z������
	lea.l	bufftop,a0		*�@�擪���w���悤�ɏC������

out2:	cmpa.l	a1,a0			*�������݈ʒu���ǂ݂����ʒu��
	bne	out3			*�@�ǂ����Ă��܂����ꍇ��
	addq.l	#1,a1			*�@�ǂ݂����ʒu�������I�ɂ��炷

	cmpa.l	buffend,a1		*���̌��ʓǂݏo���ʒu��
	bcs	out3			*�@�o�b�t�@�Ō���z������
	lea.l	bufftop,a1		*�@�擪���w���悤�ɏC������

out3:	subq.l	#1,d2			*���[�v�J�E���^d2.l��0�ɂȂ�܂�
	bne	out0			*�@�J��Ԃ�

	move.l	a0,writeptr		*�������ݗp�|�C���^�X�V
	move.l	a1,readptr		*�ǂݏo���p�|�C���^�X�V

	bra	done			*����I��

*
*	�P�o�C�g��ǂݓ��́i�R�}���h�R�[�h5�j
*
sense:
	moveq.l	#EOF,d0			*����EOF�R�[�h�����Ă���
	movea.l	readptr,a0		*�ǂݏo���|�C���^��
	cmpa.l	writeptr,a0		*�@�������݃|�C���^��
	beq	sense0			*�@��������΃o�b�t�@�͋�
	move.b	(a0),d0			*�����łȂ���Ή������邩��
					*�@�|�C���^�͌Œ�̂܂܎��o��
sense0:	move.b	d0,SNS_DATA(a5)		*��ǂ݃f�[�^���Z�b�g
	bra	done			*����I��

*
*	���̓o�b�t�@�N���A�i�R�}���h�R�[�h7�j
flush:
	move.l	writeptr,readptr	*�������݈ʒu��
					*�@�ǂݏo���ʒu����v������
	bra	done			*����I��

*
inpstat:		*���̓X�e�[�^�X�`�F�b�N�i�R�}���h�R�[�h6�j
outstat:		*�o�̓X�e�[�^�X�`�F�b�N�i�R�}���h�R�[�h10�j
	bra	done			*����I���i��ɓ��o�͉j
*
readptr:
	.dc.l	bufftop			*���ɓǂݏo���ʒu���w���|�C���^
writeptr:
	.dc.l	bufftop			*���ɏ������ވʒu���w���|�C���^
buffend:
	.dc.l	0			*�o�b�t�@�ŏI�A�h���X+1
*
*	���ȉ����o�b�t�@�Ƃ��Ďg�p
bufftop:

BUFFSIZE	=	16*1024		*�o�b�t�@�̃o�C�g��

*
*	���������i�R�}���h�R�[�h0�j
*
init:
	pea.l	title			*�^�C�g����\��
	DOS	_PRINT			*
	addq.l	#4,sp			*

	lea.l	bufftop+BUFFSIZE,a4	*a4 = �o�b�t�@�ŏI�A�h���X+1
	move.l	a4,buffend		*
	move.l	a4,DEV_END_ADR(a5)	*�f�o�C�X�h���C�o�Ŏg�p����
					*�@�������̍ŏI�A�h���X���Z�b�g

	bra	done			*����I��

*
ent:				*���S�̂���
	DOS	_EXIT
*
	.data
	.even
*
title:					*�^�C�g�����b�Z�[�W
	.dc.b	CR,LF,'TAP DRIVER for X68000',CR,LF
	.dc.b	'TAP�̃f�o�C�X���œ��o�͂��s���܂�',CR,LF,0
*
	.end	ent
