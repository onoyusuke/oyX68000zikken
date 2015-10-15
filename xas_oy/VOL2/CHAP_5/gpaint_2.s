*	�V�[�h�t�B���ɂ��̈�̓h��ׂ��i�������Łj

	.include	gconst.h
	.include	gmacro.h
	.include	rect.h
*
	.xdef	gpaint
	.xref	ghline
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
	.offset	-14	*�X�^�b�N�t���[��
WORKSIZ:
LXSAV:	.ds.w	1	*�������V�[�h��LX
RXSAV:	.ds.w	1	*�@�@�@�@�@�@�@RX
MY:	.ds.w	1	*�@�@�@�@�@�@�@PREVY
BUFTOP:	.ds.l	1	*�����O�o�b�t�@�擪
BUFEND:	.ds.l	1	*�����O�o�b�t�@����+1
_a6:	.ds.l	1
_pc:	.ds.l	1
ARGPTR:	.ds.l	1
*
	.offset	0	*�V�[�h���
*
LADR:	.ds.l	1	*���[G-RAM�A�h���X
LX:	.ds.w	1	*���[x���W
Y:	.ds.w	1	*y���W
RADR:	.ds.l	1	*�E�[G-RAM�A�h���X
RX:	.ds.w	1	*�E�[x���W
PREVY:	.ds.w	1	*�e��y���W
SEEDSIZ:
*
	.text
	.even
*
gpaint:
	link	a6,#WORKSIZ
	movem.l	d0-d7/a0-a5,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = ������
	movem.w	X0(a1),d0-d1	*(d0,d1) = �����V�[�h

	lea.l	cliprect,a5	*a5 = �N���b�s���O�̈�
	cmp.w	(a5)+,d0	*�����V�[�h��
	blt	done		*�@�E�B���h�E�O�Ȃ�
	cmp.w	(a5)+,d1	*�@���������ɖ߂�
	blt	done		*
	cmp.w	(a5)+,d0	*
	bgt	done		*
	cmp.w	(a5)+,d1	*
	bgt	done		*
	subq.l	#RECT,a5	*a5 = �N���b�s���O�̈�

	jsr	gramadr		*a0 = �����V�[�hG-RAM�A�h���X

	move.w	(a0),d6		*d6 = �̈�F

	move.w	COL(a1),d7	*d7 = �`��F
	cmp.w	d6,d7		*�`��F�Ɨ̈�F���������Ȃ�
	beq	done		*�@���������ɖ߂�
	swap.w	d7		*
	move.w	COL(a1),d7	*

	movea.l	TEMP(a1),a3	*a3 = �L���[���̓ǂݏo���ʒu
	movea.l	a3,a4		*a4 = �L���[���̏������݈ʒu
				*�i�Ƃ��Ƀo�b�t�@�擪�ɏ������j

	move.l	TEMPED(a1),d3	*d3 = �o�b�t�@����+1
	sub.l	a3,d3		*�o�b�t�@�擪�������Ȃ��
	bcs	done		*�@���������ɖ߂�
	andi.l	#$ffff_fff0,d3	*d3 = �o�b�t�@�T�C�Y�i16�̔{���j
	beq	done		*�o�b�t�@�T�C�Y���O�Ȃ��
				*�@���������ɖ߂�
	add.l	a3,d3		*d3 = �o�b�t�@����+1

	move.l	a3,BUFTOP(a6)	*�o�b�t�@�擪�Ɩ�����
	move.l	d3,BUFEND(a6)	*�@���[�N�Ɋi�[���Ă���

	movea.l	a0,a1		*�����V�[�h�ł�
	move.w	d0,d2		*�@LX��RX�͈�v���Ă���

	move.w	d1,MY(a6)	*�����V�[�h�ɂ͐e�͂��Ȃ�

	bra	do

loop:	movea.l	(a3)+,a0	*a0 = LADR
	move.w	(a3)+,d0	*d0 = LX
	move.w	(a3)+,d1	*d1 = Y
	movea.l	(a3)+,a1	*a1 = RADR
	move.w	(a3)+,d2	*d2 = RX
	move.w	(a3)+,MY(a6)	*PREVY�����[�N�ɃZ�[�u

do:
*	d0	�����V�[�hx���W
*	d1	�����V�[�hy���W
*	d2	�E���V�[�hx���W
*	d6	�̈�F�i���̐F�̓_��h��ׂ��j
*	d7	�`��F
*	a0	�����V�[�hG-RAM�A�h���X
*	a1	�E���V�[�hG-RAM�A�h���X
*	a3	�L���[���̂��̓ǂݏo���ʒu
*	a4	�L���[���̂��̏������݈ʒu
*	a5	�N���b�s���O�̈�

	cmp.w	(a1)+,d6	*���łɏ����ς݂̃V�[�h�Ȃ��
	bne	next		*�@�̂Ă�

	move.w	d0,LXSAV(a6)	*LX,RX�����[�N�ɃZ�[�u
	move.w	d2,RXSAV(a6)	*

	movea.l	a0,a2		*a0 = a2 = �V�[�h�E�[��G-RAM�A�h���X

			*�E�����̋��E��T��
rchk:	move.w	MAXX(a5),d3	*
	sub.w	d2,d3		*d3 = ��������ő�s�N�Z����
	subq.w	#1,d3		*d3 = 0�Ȃ��
	bmi	lchk		*�@�����͕s�v
rloop:	cmp.w	(a1)+,d6	*
	dbne	d3,rloop	*
	beq	lchk		*
	subq.l	#2,a1		*

			*�������̋��E��T��
lchk:	move.w	MINX(a5),d3
	sub.w	d0,d3		*d3 = -��������ő�s�N�Z����
	neg.w	d3		*d3 = ��������ő�s�N�Z����
	subq.w	#1,d3		*d3 = 0�Ȃ��
	bmi	filspn		*�@�����͕s�v
lloop:	cmp.w	-(a0),d6	*
	dbne	d3,lloop	*
	beq	filspn		*
	addq.l	#2,a0		*

filspn:	move.l	a2,d3		*d3 = �����J�n�O�̈ʒu
	sub.l	a0,d3		*d3 = ���֑��������o�C�g��
	lsr.w	#1,d3		*d3 = ���֑��������s�N�Z����
	sub.w	d3,d0		*d0 = �������[x���W

	move.l	a1,d2		*d2 = �����I����̉E�[�ʒu
	sub.l	a0,d2		*d2 = ���[����E�[�̃o�C�g��
	lsr.w	#1,d2		*d2 = �����̃s�N�Z����
	subq.w	#1,d2		*d2 = �����̃s�N�Z����-1

	movea.l	a0,a2		*a0 = a2 = �������[G-RAM�A�h���X

	move.w	d2,d3		*d3 = �`�������̒���-1
	addq.w	#1,d3		*d3 = �`�������̒���
	bclr.l	#0,d3		*��H
	beq	notodd		*
	move.w	d7,(a0)+	*�@��s�N�Z���̕�
notodd:	neg.w	d3		*

	lea.l	ghline,a1	*���������`��
	exg.l	d0,d7		*
	jsr	0(a1,d3.w)	*
	exg.l	d0,d7		*

			*�^��̃X�L�������C���𑖍�����
uchk:	add.w	d0,d2		*d2 = �����E�[x���W
	move.w	d1,d4		*d4 = y

	subq.w	#1,d1		*y--
	cmp.w	MINY(a5),d1	*�E�B���h�E�̏�[���z���Ă�����
	blt	dchk		*�@�����̕K�v�͂Ȃ�
	lea.l	-GNBYTE(a2),a0	*a0 = �������郉�C�����[
	bsr	seapix		*��������

			*�^���̃X�L�������C���𑖍�����
dchk:	addq.w	#1+1,d1		*y++
	cmp.w	MAXY(a5),d1	*�E�B���h�E�̉��[���z���Ă�����
	bgt	next		*�@�����̕K�v�͂Ȃ�
	lea.l	GNBYTE(a2),a0	*a0 = �������郉�C�����[
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
	movea.l	a0,a1		*a0 = a1 = �����J�n�ʒu
	suba.w	d0,a1		*
	suba.w	d0,a1		*a1 = �����J�n���C����
				*�@�����I�ȍ��[�ix=0�j�̃A�h���X

	cmp.w	MY(a6),d1	*�������郉�C���͐e���C���H
	bne	spix1		*�@�Ⴄ�̂Ȃ�΂ӂ��ɑ�������

	move.w	LXSAV(a6),d3	*d3 = �����͈͂̂���
	sub.w	d0,d3		*�@�e���C�����[����̂͂ݏo����
	ble	spix0		*�͂ݏo���͂Ȃ�����
	subq.w	#1,d3		*d3 = ���[�v�J�E���^

	move.l	a0,-(sp)	*�����͈͂̂���
	bsr	spix2		*�@�e���C�����[���
	movea.l	(sp)+,a0	*�@���̕����𑖍�

spix0:	move.w	d2,d3		*d3 = �����͈͂̂���
	move.w	RXSAV(a6),d5	*�@�e���C���E�[�����
	sub.w	d5,d3		*�@�͂ݏo����
	ble	sdone		*�͂ݏo���͂Ȃ�����
	subq.w	#1,d3		*d3 = ���[�v�J�E���^

	add.w	d5,d5		*a0 = �����J�n�ʒu
	lea.l	2(a1,d5),a0	*

	bra	spix2		*�����͈͂̂���
				*�@�e���C���E�[���
				*�@�E�̕����𑖍�

spix1:	move.w	d2,d3		*
	sub.w	d0,d3		*d3 = �����͈͂̃s�N�Z����-1
spix2:
sloop1:	cmp.w	(a0)+,d6	*��̈�F�������΂�
	dbeq	d3,sloop1	*
	bne	sdone		*

	move.l	a0,d5
	subq.l	#2,d5		*d5 = �̈�F�������[�A�h���X

	move.l	d5,(a4)+	*LADR
	sub.l	a1,d5		*
	lsr.w	#1,d5		*
	move.w	d5,(a4)+	*LX
	move.w	d1,(a4)+	*Y

	subq.w	#1,d3		*
	bmi	bound		*�����͈͉E�[�ɒB����

sloop2:	cmp.w	(a0)+,d6	*�̈�F�������΂�
	dbne	d3,sloop2	*
	beq	bound		*
	subq.l	#2,a0		*

bound:	move.l	a0,d5
	subq.l	#2,d5		*d5 = �̈�F�����E�[�A�h���X

	move.l	d5,(a4)+	*RADR
	sub.l	a1,d5		*
	lsr.w	#1,d5		*
	move.w	d5,(a4)+	*RX
	move.w	d4,(a4)+	*PREVY

	cmpa.l	a3,a4		*�L���[����t�ɂȂ�����
	beq	drop		*�@���ܓo�^�����V�[�h���̂Ă�

	cmpa.l	BUFEND(a6),a4	*�L���[�̏������݈ʒu��
	bcs	snext		*�@�o�b�t�@�����ɒB������
	movea.l	BUFTOP(a6),a4	*�@�擪���w���悤�C������

snext:	tst.w	d3		*�����͈͂̉E�[�ɒB����܂�
	bpl	sloop1		*�@�J��Ԃ�

sdone:	rts

drop:	lea.l	-SEEDSIZ(a4),a4	*���ܓo�^�����V�[�h���̂Ă�
	rts

	.end
