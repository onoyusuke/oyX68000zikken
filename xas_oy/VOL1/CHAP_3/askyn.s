*	Y��N�̃L�[���͂ɑ΂���
*		Y ��� 0
*		N ��� 1
*			�̏I���R�[�h��Ԃ�

_EXIT		equ	$ff00
_GETC		equ	$ff08
_EXIT2		equ	$ff4c

	.text
	.even
*
start:
loop:	.dc.w	_GETC		*1��������
	and.w	#%1101_1111,d0	*�p���������啶���ϊ�
	cmp.b	#'Y',d0		*'Y'���H
	beq	yes		*�����Ȃ�yes�̏�����
	cmp.b	#'N',d0		*'N'���H
	bne	loop		*�ǂ���ł��Ȃ���΂�蒼��
*
no:	move.w	#1,-(sp)	*�I���R�[�h1��Ԃ�
	.dc.w	_EXIT2
*
yes:	.dc.w	_EXIT		*�I���R�[�h0��Ԃ�
*
	.end
