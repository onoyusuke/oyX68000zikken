*	��������̑S�������u���b�N�̈ʒu��\������
*
*	�쐬�@�Fas mb
*		as itoh
*		lk mb itoh
*
	.include	doscall.mac
	.include	const.h
*
	.xref	itoh		*�O���Q��
*
*	�������Ǘ��|�C���^�̍\��
*
PREVMEM		equ	0
OWNERPROC	equ	4
MBEND		equ	8
NEXTMEM		equ	12
*
	.text
	.even
*
ent:
	lea.l	mysp,sp		*sp�̏�����

 	clr.l	-(sp)		*�X�[�p�[�o�C�U���[�h��
	DOS	_SUPER		*�@�؂�ւ���
				*d0 = ssp
	move.l	d0,(sp)		*ssp��Ҕ�

loop1:	move.l	PREVMEM(a0),d0	*d0 = ���O�̃������Ǘ��|�C���^
	beq	loop2		*0�Ȃ�擪
	movea.l	d0,a0		*a0 = ���O�̃������Ǘ��|�C���^
	bra	loop1		*�擪�ɒB����܂ŌJ��Ԃ�

loop2:	pea.l	buff		*�������Ǘ��|�C���^��
	move.l	a0,-(sp)	*�@�擪�A�h���X��
	bsr	itoh		*�@16�i������ϊ�����
	addq.l	#8,sp		*�@buff�ȍ~�ɃZ�b�g����

	move.b	#'-',buff+8	*�Ȃ���'-'����������

	pea.l	buff+9		*�������u���b�N��
	move.l	MBEND(a0),d0	*�@�ŏI�A�h���X��
	subq.l	#1,d0		*�@16�i������ɕϊ�����
	move.l	d0,-(sp)	*�@buff+9�ȍ~�ɃZ�b�g����
	bsr	itoh		*
	addq.l	#8,sp		*

	pea.l	buff		*XXXXXXXX-XXXXXXXX�܂ł�
	DOS	_PRINT		*�@�܂Ƃ߂ĕ\������
	addq.l	#4,sp		*

	pea.l	crlfms		*���s����
	DOS	_PRINT		*
	addq.l	#4,sp		*

	move.l	NEXTMEM(a0),d0	*d0 = ���̃������Ǘ��|�C���^
	movea.l	d0,a0		*�����ӁF�t���O�͕ω����Ȃ�
	bne	loop2		*d0���O�łȂ���ΌJ��Ԃ�

	DOS	_SUPER		*���[�U�[���[�h��
	addq.l	#4,sp		*�@�߂�

	DOS	_EXIT		*�I��
*
	.data
	.even
*		 01234567890123456
buff:	.dc.b	'12345678-12345678',0	*�\���p������i�[�̈�
crlfms:	.dc.b	CR,LF,0			*���s�R�[�h
*
	.stack
	.even
*
mystack:			*�X�^�b�N�̈�
	.ds.l	1024		*
mysp:
	.end	ent		*���s�J�n�A�h���X��ent
