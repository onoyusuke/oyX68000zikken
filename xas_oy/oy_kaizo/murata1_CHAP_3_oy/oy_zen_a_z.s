*	�S�p��'A'�`'Z'��\������

_EXIT		equ	$ff00
_PUTCHAR	equ	$ff02

	.text
	.even
*
start:
	move.w	#$0060,d1	*�V�t�gJIS�R�[�h'�`'�̉��ʃo�C�g

loop:	move.w	#$0082,-(sp)	*��ʃo�C�g��
	.dc.w	_PUTCHAR	*�@�o��
	move.w	d1,(sp)		*���ʃo�C�g��
	.dc.w	_PUTCHAR	*�@�o��
	add.l	#2,sp		*�X�^�b�N�|�C���^�␳

	add.b	#1,d1		*���̕���
	cmp.b	#$63,d1		*�Ō�܂ŕ\���������H
	bne	loop		*�����łȂ���ΌJ��Ԃ�

	bsr	crlf		*���s

	.dc.w	_EXIT		*�I��
*
crlf:
	move.w	#$0d,-(sp)	*CR�R�[�h��
	.dc.w	_PUTCHAR	*�@�o��
	move.w	#$0a,(sp)	*LF�R�[�h��
	.dc.w	_PUTCHAR	*�@�o��
	add.l	#2,sp		*�X�^�b�N�␳
	rts			*���^�[��
*
	.end
