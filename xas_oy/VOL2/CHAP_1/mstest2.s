*	�}�E�X�̎g�p��i�_�u���N���b�N�̎����j

	.include	iocscall.mac
	.include	doscall.mac
*
CR	equ	13
LF	equ	10
*
ent:
	lea.l	inisp(pc),sp

	lea.l	menu(pc),a1	*���j���[��`��
	IOCS	_B_PRINT	*

	IOCS	_MS_INIT	*�}�E�X������
	IOCS	_MS_CURON	*�}�E�X�J�[�\���\��
	moveq.l	#0,d1		*�\�t�g�E�F�A�L�[�{�[�h
	IOCS	_SKEY_MOD	*�@�\���֎~

loop:	IOCS	_MS_GETDT	*�{�^���̏�Ԃ𓾂�
	tst.w	d0		*���{�^���͉�����Ă��邩�H
	bpl	loop		*�@������Ă��Ȃ�����

			*���{�^���������ꂽ
	IOCS	_MS_CURGT	*�}�E�X�J�[�\�����W�𓾂�
	move.w	d0,d1		*d1.w = Y���W
	swap.w	d0		*d0.w = X���W

	cmpi.w	#32,d0		*X���W�̃`�F�b�N
	bcc	loop		*�@�͈͊O
	cmpi.w	#16,d1		*Y���W�̃`�F�b�N
	bcc	loop		*�@�͈͊O

			*�I�����j���[�ゾ����
	moveq.l	#0,d1		*���{�^��
	moveq.l	#80,d2		*�҂����ԁi��0.2�b�j
	IOCS	_MS_OFFTM	*�������܂ő҂�
	tst.w	d0		*�O�ȉ��Ȃ�
	ble	loop		*�@�͂���

	IOCS	_MS_ONTM	*�������܂ő҂�
	tst.w	d0		*�O�ȉ��Ȃ�
	ble	loop		*�@�͂���

			*�_�u���N���b�N���ꂽ
	IOCS	_MS_INIT	*�}�E�X�ď�����
	moveq.l	#-1,d1		*�\�t�g�E�F�A�L�[�{�[�h
	IOCS	_SKEY_MOD	*�@�\������

	DOS	_EXIT		*�I��
*
	.data
	.even
*
menu:	.dc.b	26,'�I��',CR,LF,0
*
	.stack
	.even
*
mystack:
	.ds.l	256
inisp:
	.end	ent
