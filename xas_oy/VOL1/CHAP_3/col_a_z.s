*	�S�p��'A'�`'Z'��F�i�����̑����j��ς��Ȃ���\������

_EXIT		equ	$ff00
_PUTCHAR	equ	$ff02
_CONCTRL	equ	$ff23

	.text
	.even
*
start:
	move.w	#$0060,d1	*�V�t�gJIS�R�[�h'�`'�̉��ʃo�C�g
	move.w	#1,d2		*��������=1�i�m�[�}���j

loop:	move.w	d2,-(sp)	*d2=��������
	move.w	#2,-(sp)	*conctrl���[�h2
	.dc.w	_CONCTRL	*���ɕ\�����镶���̑�����ݒ�
	add.l	#4,sp		*�X�^�b�N�|�C���^�␳

	move.w	#$0082,-(sp)	*��ʃo�C�g��
	.dc.w	_PUTCHAR	*�@�o��
	move.w	d1,(sp)		*���ʃo�C�g��
	.dc.w	_PUTCHAR	*�@�o��
	add.l	#2,sp		*�X�^�b�N�|�C���^�␳

	add.b	#1,d2		*���̕��������i�ςȕ\���H�j
	and.b	#$0f,d2		*d2=d2%16

	add.b	#1,d1		*���̕���
	cmp.b	#$7a,d1		*�Ō�܂ŕ\���������H
	bne	loop		*�����łȂ���ΌJ��Ԃ�

	.dc.w	_EXIT		*�I��
*
	.end
