*	�p���b�g���x���ŐF���]����

	.include	doscall.mac
	.include	gconst.h
*
	.xdef	gnegatepalet
*
	.text
	.even
*
gnegatepalet:
	movem.l	d0/a0,-(sp)

	lea.l	GPALET,a0	*�p���b�g���W�X�^
	moveq.l	#512/4-1,d0	*�@512�o�C�g���S�o�C�g�P�ʂ�
loop:	not.l	(a0)+		*�@�r�b�g���]����
	dbra	d0,loop		*

	movem.l	(sp)+,d0/a0
	rts

	.end
