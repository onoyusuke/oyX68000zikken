*	'A'�`'Z'��\������v���O����

_EXIT		equ	$ff00	*DOS�R�[��exit�̃V���{����`
_PUTCHAR	equ	$ff02	*DOS�R�[��putchar�̃V���{����`

	.text
	.even
*
start:
	move.w	#'A',d1		*�\�����n�߂镶���R�[�h��d1��

loop:	move.w	d1,-(sp)	*�X�^�b�N�ɕ����R�[�h��ς�
	.dc.w	_PUTCHAR	*DOS�R�[��putchar���Ăяo��
	add.l	#2,sp		*�X�^�b�N�|�C���^��␳����

	add.w	#1,d1		*d1=���ɕ\�����镶���R�[�h
	cmp.w	#'Z'+1,d1	*d1��'Z'+1�Ɠ��������H
				*�i'Z'�����������H�j
	bne	loop		*�����łȂ���Ώ������J��Ԃ�

	bsr	crlf		*���s�T�u���[�`�����Ăяo��

	.dc.w	_EXIT		*���s�I��

*	���s�����T�u���[�`��
*
crlf:
	move.w	#$0d,-(sp)	*CR�R�[�h��
	.dc.w	_PUTCHAR	*�@�o��
	add.l	#2,sp		*�X�^�b�N�␳

	move.w	#$0a,-(sp)	*LF�R�[�h��
	.dc.w	_PUTCHAR	*�@�o��
	add.l	#2,sp		*�X�^�b�N�␳

	rts			*���C�����[�`���֖߂�
*
	.end
