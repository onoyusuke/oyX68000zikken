*	�L�[���͂ɉ�����Y��N��\������@�Q

_EXIT		equ	$ff00
_PUTCHAR	equ	$ff02
_GETC		equ	$ff08

	.text
	.even
*
start:
loop:	.dc.w	_GETC		*1��������
	cmp.b	#'Y',d0		*'Y'���H
	beq	print		*�����Ȃ�\��������
	cmp.b	#'N',d0		*'N'���H
	bne	loop		*�����łȂ���΂�蒼��
*
print:	move.w	d0,-(sp)	*'Y'��'N'��\��
	.dc.w	_PUTCHAR
	add.l	#2,sp
	.dc.w	_EXIT		*�I��
*
	.end
