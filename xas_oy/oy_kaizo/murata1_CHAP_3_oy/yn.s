*	�L�[���͂ɉ�����Y��N��\������

_EXIT		equ	$ff00
_PUTCHAR	equ	$ff02
_GETC		equ	$ff08

	.text
	.even
*
start:
loop:	.dc.w	_GETC		*1��������
	cmp.b	#'Y',d0		*'Y'���H
	beq	yes		*�����Ȃ�'Y'�̕\��������
	cmp.b	#'N',d0		*'N'���H
	beq	no		*�����Ȃ�'N'�̕\��������
	bra	loop		*�ǂ���ł��Ȃ���΂�蒼��
*
yes:	move.w	#'Y',-(sp)	*'Y'��\��
	.dc.w	_PUTCHAR
	add.l	#2,sp
	.dc.w	_EXIT		*�I��
*
no:	move.w	#'N',-(sp)	*'N'��\��
	.dc.w	_PUTCHAR
	add.l	#2,sp
	.dc.w	_EXIT		*�I��
*
	.end
