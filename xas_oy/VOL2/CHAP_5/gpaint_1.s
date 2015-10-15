*	�V�[�h�t�B���ɂ��̈�̓h��ׂ��i��P�Łj

	.include	gconst.h
	.include	gmacro.h
	.include	rect.h
*
	.xdef	gpaint
	.xref	gramadr
	.xref	cliprect
*
	.offset	0	*gpaint�̈����\��
*
X0:	.ds.w	1	*�����V�[�h���W
Y0:	.ds.w	1	*
COL:	.ds.w	1	*�`��F
TEMP:	.ds.l	1	*��Ɨp�̈�擪
TEMPED:	.ds.l	1	*��Ɨp�̈斖��+1
*
	.offset	-8	*�X�^�b�N�t���[��
WORKSIZ:
BUFTOP:	.ds.l	1
BUFEND:	.ds.l	1
_a6:	.ds.l	1
_pc:	.ds.l	1
ARGPTR:	.ds.l	1
*
	.offset	0	*�V�[�h���
*
ADR:	.ds.l	1
X:	.ds.w	1
Y:	.ds.w	1
SEEDSIZ:
*
	.text
	.even
*
gpaint:
	link	a6,#WORKSIZ
	movem.l	d0-d7/a0-a5,-(sp)

	lea.l	cliprect,a5	*a5=�N���b�s���O�̈�
	movea.l	ARGPTR(a6),a1	*a1=������

	movem.w	X0(a1),d0-d1	*(d0,d1)=�����V�[�h
	cmp.w	MINX(a5),d0	*�����V�[�h��
	blt	done		*�@�E�B���h�E�O�Ȃ�
	cmp.w	MINY(a5),d1	*�@���������ɖ߂�
	blt	done		*
	cmp.w	MAXX(a5),d0	*
	bgt	done		*
	cmp.w	MAXY(a5),d1	*
	bgt	done		*

	jsr	gramadr		*a0=�����V�[�hG-RAM�A�h���X

	move.w	(a0),d6		*d6=�̈�F

	move.w	COL(a1),d7	*d7=�`��F
	cmp.w	d6,d7		*�`��F�Ɨ̈�F���������Ȃ�
	beq	done		*�@���������ɖ߂�

	movea.l	TEMP(a1),a3	*a3=�L���[���̓ǂݏo���ʒu
	movea.l	a3,a4		*a4=�L���[���̏������݈ʒu
				*�i�Ƃ��Ƀo�b�t�@�擪�ɏ������j

	move.l	TEMPED(a1),d3	*d3=�o�b�t�@����+1
	sub.l	a3,d3		*�o�b�t�@�擪�������Ȃ��
	bcs	done		*�@���������ɖ߂�
	andi.l	#$ffff_fff0,d3	*d3=�o�b�t�@�T�C�Y�i16�̔{���j
	beq	done		*�o�b�t�@�T�C�Y���O�Ȃ��
				*�@���������ɖ߂�
	add.l	a3,d3		*d3=�o�b�t�@����+1

	move.l	a3,BUFTOP(a6)	*�o�b�t�@�擪�Ɩ�����
	move.l	d3,BUFEND(a6)	*�@���[�N�Ɋi�[���Ă���

	bra	do		*���C�������J�n

loop:	movea.l	(a3)+,a0	*�L���[����V�[�h��
	move.w	(a3)+,d0	*�@���o��
	move.w	(a3)+,d1	*

do:
*	d0	�V�[�hx���W
*	d1	�V�[�hy���W
*	d6	�̈�F
*	d7	�`��F
*	a0	�V�[�hG-RAM�A�h���X
*	a3	�L���[���̂��̓ǂݏo���ʒu
*	a4	�L���[���̂��̏������݈ʒu
*	a5	�N���b�s���O�̈�

	movea.l	a0,a1		*a0=a1=�V�[�h��G-RAM�A�h���X
	move.w	d0,d2		*d0=d2=�V�[�h��x���W

	cmp.w	(a1)+,d6	*���łɏ����ς݂̃V�[�h�Ȃ��
	bne	next		*�@�̂Ă�

			*�E�����̋��E��T��
rchk:	move.w	MAXX(a5),d3	*d3=�E�B���h�E�E�[x���W
				*d2=x1
rloop:	cmp.w	d3,d2		*�E�B���h�E�E�[�ɒB������
	bge	lchk		*�@���̒��O�̓_���E�̋��E
	addq.w	#1,d2		*x1++
	cmp.w	(a1)+,d6	*(x1,y)���̈�F�̂�����
	beq	rloop		*�@�J��Ԃ�

	subq.w	#1,d2		*d2=x1

			*�������̋��E��T��
lchk:	move.w	MINX(a5),d3	*d3=�E�B���h�E���[x���W
				*d0=x0
lloop:	cmp.w	d3,d0		*�E�B���h�E�E�[�ɒB������
	ble	filspn		*�@���̒��O�̓_�����̋��E
	subq.w	#1,d0		*x0--
	cmp.w	-(a0),d6	*(x0,y)���̈�F�̂�����
	beq	lloop		*�@�J��Ԃ�

	addq.w	#1,d0		*d0=x0
	addq.l	#2,a0		*a0=(x0,y)��G-RAM�A�h���X

filspn:	sub.w	d0,d2		*d2=�����̃s�N�Z����-1
	movea.l	a0,a2		*a0=a2=�������[G-RAM�A�h���X

	move.w	d2,d3		*����(x0,y)-(x1,y)��`��
floop:	move.w	d7,(a0)+	*
	dbra	d3,floop	*

	move.w	d0,d4		*d0=d4=x0�i�������[x���W�j
	subq.w	#1,d4		*d4=x0-1

			*�^��̃X�L�������C���𑖍�����
uchk:	subq.w	#1,d1		*y--
	cmp.w	MINY(a5),d1	*�E�B���h�E�̏�[���z���Ă�����
	blt	dchk		*�@�����̕K�v�͂Ȃ�
	lea.l	-GNBYTE(a2),a0	*a0=�������郉�C�����[
	bsr	seapix		*��������

			*�^���̃X�L�������C���𑖍�����
dchk:	addq.w	#1+1,d1		*y++
	cmp.w	MAXY(a5),d1	*�E�B���h�E�̉��[���z���Ă�����
	bgt	next		*�@�����̕K�v�͂Ȃ�
	lea.l	GNBYTE(a2),a0	*a0=�������郉�C�����[
	bsr	seapix		*��������

next:	cmpa.l	BUFEND(a6),a3	*�L���[�̓ǂݏo���ʒu��
	bcs	next0		*�@�o�b�t�@�����ɒB���Ă�����
	movea.l	BUFTOP(a6),a3	*�@�擪���w���悤�C������

next0:	cmpa.l	a3,a4		*�L���[����ɂȂ�܂�
	bne	loop		*�@�J��Ԃ�

done:	movem.l	(sp)+,d0-d7/a0-a5
	unlk	a6
	rts

*
*	�㉺�̃��C������V�[�h�̌���T���L���[�ɒǉ�����
*
seapix:
	move.w	d4,d0		*d0=�����J�nx���W-1
	move.w	d2,d3		*d3=�����̃s�N�Z����-1
sloop1:	addq.w	#1,d0		*��̈�F�������΂�
	cmp.w	(a0)+,d6	*
	dbeq	d3,sloop1	*
	beq	spix0		*�̈�F����������
	rts			*�̈�F�͌�����Ȃ�����

sloop2:	addq.w	#1,d0		*�̈�F�������΂�
	cmp.w	(a0)+,d6	*
spix0:	dbne	d3,sloop2	*
	beq	spix1		*
	subq.l	#2,a0		*�|�C���^��x���W��
	subq.w	#1,d0		*�@�i�݉߂��Ă���

spix1:	subq.l	#2,a0		*a0=�̈�F�����̉E�[
	move.l	a0,(a4)+	*�������V�[�h����
	move.w	d0,(a4)+	*�@�o�b�t�@�ɓo�^����
	move.w	d1,(a4)+	*
	addq.l	#2,a0		*���̑����ɔ�����

	cmpa.l	a3,a4		*�L���[����t�ɂȂ�����
	beq	drop		*�@���ܓo�^�����V�[�h���̂Ă�

	cmpa.l	BUFEND(a6),a4	*�L���[�̏������݈ʒu��
	bcs	snext		*�@�o�b�t�@�����ɒB������
	movea.l	BUFTOP(a6),a4	*�@�擪���w���悤�C������

snext:	tst.w	d3		*�����͈͂̉E�[�ɒB����܂�
	bpl	sloop1		*�@�J��Ԃ�

sdone:	rts

drop:	subq.l	#SEEDSIZ,a4	*���ܓo�^�����V�[�h���̂Ă�
	rts

	.end
