*	�X�L�����R���o�[�W�����ɂ�鑽�p�`�̓h��ׂ�

	.include	gconst.h
	.include	gmacro.h
	.include	rect.h
	.include	edge.h
*
	.xdef	gfillpoly
	.xref	ghline
	.xref	gramadr
	.xref	cliprect
*
	.offset	0	*gfillpoly�̈����\��
*
EDGES:	.ds.l	1	*�Ӄ��X�g�擪�A�h���X
EDGEED:	.ds.l	1	*�Ӄ��X�g�ŏI�A�h���X
EDGARY:	.ds.l	1	*EDGBUF�̃|�C���^�z��p���[�N
COL:	.ds.l	1	*�`��F
*
	.text
	.even
*
gfillpoly:
ARGPTR	=	4
	movem.l	d0-d7/a0-a6,-(sp)
SAVREGS =	8+7
ARGPTR	=	ARGPTR+SAVREGS*4
	movea.l	ARGPTR(sp),a0	*a0 = ������
	bsr	init		*����������
	bra	lpent

*	d0.l	�`��F�p���b�g�R�[�h�i���/���ʃ��[�h�Ƃ��j
*	d1�`d4	��Ɨp
*	d5.l	ghline
*	d6.w	�c��EDGBUF��
*	d7.w	���ڂ��Ă���X�L�������C����y���W
*
*	a0�`a2	��Ɨp
*	a3	������EDGBUF�̃|�C���^�z��擪
*	a4	������EDGBUF�̃|�C���^�z�񖖔�
*		�i��������EDGBUF�̃|�C���^�z��擪�j
*	a5	������EDGBUF�̃|�C���^�z�񖖔�
*	a6	���ڂ��Ă���X�L�������C���̍��[�A�h���X

mainloop:
	cmpa.l	a4,a3		*��������EDGBUF��
	beq	nomore		*�@�����Ȃ���΃X�L�b�v
	bsr	activate	*�A�N�e�B�u�ɂ��ׂ�EDGBUF��T��

nomore:	cmpa.l	a5,a4		*��������EDGBUF��
	beq	nextln		*�@�Ȃ���΃X�L�b�v

	bsr	sortlist	*��_��x���W�Ń\�[�g����
	bsr	drawline	*�P���C���`�悷��
	bsr	calcnextx	*���̌�_�����߂�

nextln:	lea.l	GNBYTE(a6),a6	*a6 = ���̃��C���̍��[�A�h���X
	addq.w	#1,d7		*d7 = ���̃��C����y���W

lpent:	tst.w	d6		*EDGBUF���c���Ă��邠����
	bne	mainloop	*�@�J��Ԃ�

	movem.l	(sp)+,d0-d7/a0-a6
	rts

*
*	������EDGBUF�Q�̒�����
*	���ڂ��Ă���X�L�������C����Ɏn�_��������̂�T��,
*	�����, ������EDGBUF�̃|�C���^�z��Ɉړ�����
*
activate:
	movea.l	a3,a1		*a1 = ������EDGBUF�̃|�C���^�z��
actvlp:	movea.l	(a1)+,a0	*a0 = EDGBUF�ւ̃|�C���^
	cmp.w	Y0(a0),d7	*�n�_��y���W = ���݂�y���W�H
	bne	actvnx		*�@�łȂ����, �܂�

			*EDGBUF���A�N�e�B�u�ɂ���
	move.w	X0(a0),(a0)	*�ŏ��̌�_��x���W�i= x0�j��ݒ�
	move.l	DY0(a0),DY(a0)	*���[�v�J�E���^�ƌ덷����������

	move.l	-(a4),-(a1)	*������EDGBUF�̃|�C���^�z�񂩂�폜
	move.l	a0,(a4)		*������EDGBUF�̃|�C���^�z��ɒǉ�

actvnx:	cmpa.l	a4,a1		*���ׂĂ̖�����EDGBUF�ɂ���
	bcs	actvlp		*�@�J��Ԃ�
	rts

*
*	��_��x���W�̏���������
*	��������EDGBUF�̃|�C���^�z����\�[�g����
*
sortlist:
	move.l	a5,d2		*a5��Ҕ�

	subq.l	#4,a5		*�P���}���@�Ń\�[�g����
	bra	sortnx		*
srtlp2:	move.l	a1,-8(a2)	*
srtlp1:	movea.l	(a2)+,a1	*
	cmp.w	(a1),d1		*
	bgt	srtlp2		*
	move.l	a0,-8(a2)	*
sortnx:	movea.l	a5,a2		*
	movea.l	-(a5),a0	*
	move.w	(a0),d1		*
	cmpa.l	a4,a5		*
	bcc	srtlp1		*

	movea.l	d2,a5		*a5�𕜋A
	rts

*
*	�P���C�����`�悷��
*
drawline:
	movea.l	a4,a1		*a1 = ��������EDGBUF�̃|�C���^�z��擪
	movea.l	d5,a2		*

	move.w	cliprect+MINX,d3	*d3 = MINX
	move.w	cliprect+MAXX,d4	*d4 = MAXX

drawlp:	movea.l	(a1)+,a0	*a0 = EDGBUF�ւ̃|�C���^
	move.w	(a0),d1		*d1 = �`�����������̎n�_x���W
	cmp.w	d4,d1		*�n�_��MAXX�Ȃ��
	bgt	drawq		*�@�����͉�ʂ̉E�O������`�抮��

	movea.l	(a1)+,a0	*
	move.w	(a0),d2		*d2 = �`�����������̏I�_x���W
	cmp.w	d3,d2		*�I�_��MINX�Ȃ��
	blt	drawlp		*�@�����͉�ʂ̍��O

	MAX	d3,d1		*�n�_����ʍ��[�ŃN���b�v
	MIN	d4,d2		*�I�_����ʉE�[�ŃN���b�v
	sub.w	d1,d2		*d2 = �`�����������̒���-1

	add.w	d1,d1		*
	lea.l	0(a6,d1.w),a0	*a0 = �`�������̍��[�A�h���X
	addq.w	#1,d2		*d2 = �`�������̒���
	bclr.l	#0,d2		*��H
	beq	notodd		*
	move.w	d0,(a0)+	*�@��s�N�Z���̕�
notodd:	neg.w	d2		*

	jsr	0(a2,d2.w)	*���������`��

	cmpa.l	a5,a1
	bcs	drawlp

drawq:	rts

*
*	���̃X�L�������C��������
*	��_��x���W�����߂�
*
calcnextx:
	movea.l	a4,a1		*a1 = ������EDGBUF�̃|�C���^�z��擪
calclp:	movea.l	(a1)+,a0	*a0 = EDGBUF�ւ̃|�C���^
	subq.w	#1,DY(a0)	*�J�E���^�����炷
	beq	deactivate	*�@0�ɂȂ�����z�񂩂�폜����
				*�@�i�Ō�̂P�_�͏������Ȃ��j
	move.w	E(a0),d1	*d1 = e
	add.w	DEX(a0),d1	*e += 2*dx
	bmi	calskp		*e��0�Ȃ�x���W�͍���̂܂�

	move.w	SX(a0),d4	*sgn(x1-x0) = 0�Ȃ�
	beq	calcnx		*�@x���W�͕s��
	movem.w	(a0),d2-d3	*d2 = x, d3 = 2*dy
inclp:	add.w	d4,d2		*x += sgn(x1-x0)
	sub.w	d3,d1		*e -= 2*dy
	bpl	inclp		*e��0�̂������J��Ԃ�

	move.w	d2,(a0)		*���߂�x���W
calskp:	move.w	d1,E(a0)	*e���X�V

calcnx:	cmpa.l	a5,a1		*���ׂĂ̏�����EDGBUF�ɂ���
	bcs	calclp		*�@�J��Ԃ�
	rts
*
deactivate:
	move.l	-(a5),-(a1)	*�p���݂�EDGBUF���폜����
	move.l	4(a5),(a5)	*���̕��Ԑl���l�߂�
	subq.w	#1,d6		*�c��EDGBUF�������炷
	bra	calcnx

*
*	������
*
*	�E���ׂĂ�EDGBUF�𖢏���EDGBUF�̃|�C���^�z��ɂ܂Ƃ߂�
*	�E������EDGBUF�̃|�C���^�z�����ɂ���
*	�E�ŏ��ɒ��ڂ���X�L�������C����y���W�ƍ��[�A�h���X�����߂�
*	�EEDGBUF�̐��𐔂���
*	�E�`��F�����W�X�^�ɐݒ肷��
*
init:
	movem.l	(a0)+,a1-a3	*a1 = EDGBUF�z��̐擪
				*a2 = EDGBUF�z��̖���
	movea.l	a3,a4		*a3 = a4
				*   = ������EDGBUF�̃|�C���^�z��擪
	moveq.l	#-1,d1		*d1 = ���̍ŏ�y���W
	moveq.l	#0,d6		*d6 = EDGBUF�̃J�E���^
	move.w	(a0)+,d7	*d7 = �`��F
	bra	ilpent

initlp:	move.l	a1,(a4)+	*���ɖ�����EDGBUF�̃|�C���^�z��ɒǉ�
	move.w	Y0(a1),d0	*�n�_��y���W��
	cmp.w	d1,d0		*�@���̍ŏ�y���W��菬�������
	bcc	notmin		*
	move.w	d0,d1		*�@���̍ŏ�y���W���X�V����

notmin:	addq.w	#1,d6		*EDGBUF�̐��𐔂��グ��
	lea.l	EDGBUFSIZ(a1),a1	*a1 = ����EDGBUF
ilpent:	cmpa.l	a2,a1		*���ׂĂ�EDGBUF�ɂ���
	bcs	initlp		*�@�J��Ԃ�

				*d1 = �ŏ���y���W
				*d6 = EDGBUF�̌�
				*a4 = ������EDGBUF�̃|�C���^�z�񖖔�
				*   = ������EDGBUF�̃|�C���^�z��擪
	movea.l	a4,a5		*a5 = ������EDGBUF�̃|�C���^�z�񖖔�
				*�ia4 = a5�������j

	move.l	#dmydat,(a5)	*�Ԑl��u��

	moveq.l	#0,d0		*x = 0
	jsr	gramadr		*
	movea.l	a0,a6		*a6 = �ŏ��ɏ�������
				*     �X�L�������C���̍��[�A�h���X
	move.l	#ghline,d5	*d5 = ���������`�惋�[�`����A�h���X

	move.w	d7,d0		*d0 = �`��F
	swap.w	d0		*
	move.w	d7,d0		*

	move.w	d1,d7		*d7 = �ŏ��ɏ�������
				*     �X�L�������C����y���W
	rts
*
dmydat:	.dc.w	32767		*�Ԑl�Ƃ��Ďg���_�~�[�f�[�^
				*�iX�̃t�B�[���h�����Ȃ�EDGBUF�j

	.end

�C������

92-01-01��
�A�h���X���W�X�^�ɉ��Z����萔��d5���W�X�^�𖳑ʌ������Ă����̂������悭�C��
