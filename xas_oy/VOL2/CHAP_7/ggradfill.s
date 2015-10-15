*	�O���f�[�V�����ɂ���`�̓h��ׂ�

	.include	gconst.h
	.include	gmacro.h
*
	.xdef	ggradfill
	.xref	gramadr
	.xref	gcliprect

*
*	�덷�̗ݐς��l�����ĐF�����肷��}�N���i�P�F���j
*
PROC1	macro	COL
	move.w	COL,d1		*d1 = ���݂�8192�K���̐F
	add.w	(a4)+,d1	*�@�{���͂���̌덷
	ror.w	#8,d1		*d1.b = 32�K���̐F
	or.b	d1,d0		*�J���[�R�[�h�ɍ\�����Ă���
	clr.b	d1		*d1.w = 8192�K������32�K����
	rol.w	#8,d1		*�@���Ƃ��Ƃ��̐؂�̂ĕ�
	move.w	#8-1,d2
	and.w	d1,d2		*d2 = �덷 mod 8
	lsr.w	#3,d1		*d1 = �덷/8
	add.w	d1,d2		*
	add.w	d2,(a5)+	*�^���Ɍ덷��1/8+�[��
	move.w	d1,6-2(a5)	*�E���Ɍ덷��1/8
	add.w	d1,d1		*
	add.w	d1,-6-2(a5)	*�����Ɍ덷��2/8
	add.w	d1,d1		*
	add.w	d1,6-2(a4)	*�E�Ɍ덷��4/8
	.endm

*
*	Bresenham�̃A���S���Y���ɂ����̐F�����߂�}�N��
*
PROC2	macro	COL,P
	local	loop,skip
	lea.l	P(a6),a0	*a0 = �p�����[�^��iPARBUF�j
	move.w	(a0),d0		*d0 = �덷��
	add.w	D(a0),d0	*�덷���ɑ�����������
	ble	skip		*
	move.w	S(a0),d1	*d1 = �F�̑�������
	move.w	HC(a6),d2	*d2 = �덷���̕␳�l
loop:	add.w	d1,COL		*�F���X�V����
	sub.w	d2,d0		*�덷����␳����
	bgt	loop		*�덷�����O�ȉ��ɂȂ�܂ŌJ��Ԃ�
skip:	move.w	d0,(a0)		*�덷�����X�V����
	.endm
*
	.offset	0	*ggradfill�̈����\��
*
X0:	.ds.w	1	*�`�����W
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
*COL:	.ds.w	1	*�u���Ώۂ̐F
COL1:	.ds.w	1	*������̐F
COL2:	.ds.w	1	*�������̐F
COL3:	.ds.w	1	*�E����̐F
COL4:	.ds.w	1	*�E�����̐F
BUFF:	.ds.l	1	*��Ɨp�������i�ő�12�j�o�C�g���j
*
	.offset	0	*�Q�F��rgb�W�J����
*
BB0:	.ds.b	1	*�F�P(�R)
RR0:	.ds.b	1	*
GG0:	.ds.b	1	*
BB1:	.ds.b	1	*�F�Q(�S)
RR1:	.ds.b	1	*
GG1:	.ds.b	1	*
RGB2BUF:
*
	.offset	0	*����������Ԏ���Bresenham�p�����[�^
*
E:	.ds.w	1	*�덷��
D:	.ds.w	1	*����
S:	.ds.w	1	*����
PARBUF:
*
	.offset	-RGB2BUF*2-2*4-PARBUF*3-2*2
			*�X�^�b�N�t���[��
*
WORKTOP:
C12:	.ds.b	RGB2BUF	*�F1, 2��rgb��������
C34:	.ds.b	RGB2BUF	*�F3, 4��rgb��������
HE:	.ds.w	1	*����������Ԏ��̌덷�������l
HC:	.ds.w	1	*����������Ԏ��̌덷���␳�l
VE:	.ds.w	1	*����������Ԏ��̌덷�������l
VC:	.ds.w	1	*����������Ԏ��̌덷�������l
BBUF:	.ds.b	PARBUF	*����������ԗpBresenham�p�����[�^
RBUF:	.ds.b	PARBUF	*�Ԑ���������ԗpBresenham�p�����[�^
GBUF:	.ds.b	PARBUF	*�ΐ���������ԗpBresenham�p�����[�^
ROFS:	.ds.w	1	*�Ԃ̐���������ԃf�[�^�ւ̃I�t�Z�b�g
GOFS:	.ds.w	1	*�Ԃ̐���������ԃf�[�^�ւ̃I�t�Z�b�g
_A6:	.ds.l	1	*�}0
_PC:	.ds.l	1
ARGPTR:	.ds.l	1	*������
*
	.text
	.even
*
ggradfill:
	link	a6,#WORKTOP
	movem.l	d0-d7/a0-a5,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = ������
	movem.w	(a1)+,d0-d3	*d0�`d3�ɍ��W�����o��

	jsr	gcliprect	*�N���b�s���O����
	bmi	done		*N=1�Ȃ�`��̕K�v�Ȃ�

	jsr	gramadr		*�����G-RAM��̃A�h���X�𓾂�

	sub.w	d0,d2		*d2 = ���s�N�Z����-1
	sub.w	d1,d3		*d3 = �c�s�N�Z����-1

*	swap.w	d3		*d3 = �u���Ώۂ̐F
*	move.w	(a1)+,d3	*
*	swap.w	d3		*

	lea.l	C12(a6),a3	*�S�F��rgb�ɕ������Ă���
	moveq.l	#4-1,d7		*
iloop:	move.w	(a1)+,d0	*
	DERGB	d0,d4,d5,d6	*
	move.b	d4,(a3)+	*
	move.b	d5,(a3)+	*
	move.b	d6,(a3)+	*
	dbra	d7,iloop	*

	move.w	d2,d4		*����/�����̐F��ԗp��
	move.w	d2,d5		*�@�덷��/�␳�l�����߂�
	move.w	d3,d6		*
	move.w	d3,d7		*
	neg.w	d4		*
	add.w	d5,d5		*
	neg.w	d6		*
	add.w	d7,d7		*
	move.w	d4,HE(a6)	*
	move.w	d5,HC(a6)	*
	move.w	d6,VE(a6)	*
	move.w	d7,VC(a6)	*

	addq.w	#2,d7		*d7 = ������Ԃ����e�[�u���P�F���T�C�Y
	move.w	d7,ROFS(a6)	*�̃e�[�u���ƐԂ̃e�[�u���̍�
	add.w	d7,d7		*
	move.w	d7,GOFS(a6)	*�̃e�[�u���Ɨ΂̃e�[�u���̍�

	movea.l	(a1),a1		*a1 = ��Ɨp�̈�

	lea.l	C12(a6),a4	*COL1�`COL2����
	movea.l	a1,a2		*
	bsr	genvtbl		*

	lea.l	C34(a6),a4	*COL3�`COL4����
	movea.l	a1,a3		*
	bsr	genvtbl		*

	lea.l	6(a1),a4	*a4 = �덷�i�[�p�o�b�t�@�P

	moveq.l	#0,d0		*�덷�i�[�p�o�b�t�@���N���A
	move.w	d2,d4		*
	addq.w	#2,d4		*
cloop:	move.l	d0,(a1)+	*
	move.w	d0,(a1)+	*
	dbra	d4,cloop	*

	movea.l	a1,a5		*a5 = �덷�i�[�p�o�b�t�@�Q
loop1:	moveq.l	#0,d0		*�덷�i�[�p�o�b�t�@�̐擪���N���A
	move.l	d0,(a5)		*
	move.w	d0,4(a5)	*

	move.w	HE(a6),d1	*d1 = ���������F��Ԏ��̌덷�������l

	move.w	GOFS(a6),d0	*
	move.w	0(a2,d0),d4	*d4 = g0
	move.w	0(a3,d0),d5	*d5 = g1
	lea.l	GBUF(a6),a1	*
	bsr	hinit		*
	move.w	d4,d7		*d7 = g0

	move.w	ROFS(a6),d0	*
	move.w	0(a2,d0),d4	*d4 = r0
	move.w	0(a3,d0),d5	*d5 = r1
	lea.l	RBUF(a6),a1	*
	bsr	hinit		*
	move.w	d4,d6		*d6 = r0

	move.w	(a2)+,d4	*d4 = b0
	move.w	(a3)+,d5	*d5 = b1
	lea.l	BBUF(a6),a1	*
	bsr	hinit		*
	move.w	d4,d5		*d5 = b0

	movea.l	a0,a1		*a1 = �`��惉�C�����[

	move.w	d2,d4		*d4 = ��`�̕�-1 = ���[�v�J�E���^
	swap.w	d1
	swap.w	d2
*	swap.w	d3
	movem.l	a0/a4-a5,-(sp)
loop2:	moveq.l	#0,d0		*�덷�̗ݐς��l�����ĕ`��F�����߂�
	PROC1	d7		*g
	lsl.w	#5,d0		*
	PROC1	d6		*r
	lsl.w	#5,d0		*
	PROC1	d5		*b
	add.w	d0,d0		*

*	cmp.w	(a1),d3		*�u���ΏېF�H
*	beq	skip		*
*	move.w	(a1),d0		*�_�~�[
skip:	move.w	d0,(a1)+	*�P�s�N�Z���`��

	PROC2	d5,BBUF		*�F���X�V����
	PROC2	d6,RBUF		*
	PROC2	d7,GBUF		*

	dbra	d4,loop2	*�������J��Ԃ�
	movem.l	(sp)+,a0/a4-a5
	swap.w	d1
	swap.w	d2
*	swap.w	d3

	exg.l	a4,a5		*�덷�i�[�p�o�b�t�@����������
	lea.l	GNBYTE(a0),a0	*���̃��C����
	dbra	d3,loop1	*�������J��Ԃ�

done:	movem.l	(sp)+,d0-d7/a0-a5
	unlk	a6
	rts

*
*	���������ɐF���Ԃ��ăe�[�u�����쐬����
*
genvtbl:
	move.b	BB0(a4),d0	*��������
	move.b	BB1(a4),d1	*
	bsr	gsub		*

	move.b	RR0(a4),d0	*�Ԑ�������
	move.b	RR1(a4),d1	*
	bsr	gsub		*

	move.b	GG0(a4),d0	*�ΐ�������
	move.b	GG1(a4),d1	*
*	bsr	gsub		*
*
gsub:	lsl.w	#8,d0		*���x�m�ۂ̂���256�{�X�P�[�����O
	lsl.w	#8,d1		*�i32�K����8192�K���j

	sub.w	d0,d1		*Bresenham�̃A���S���Y���̂��߂̏�����
	move.w	d1,d4		*
	ABS	d1		*
	SGN	d4		*
	add.w	d1,d1		*
	move.w	VE(a6),d5	*
	move.w	VC(a6),d6	*
	bne	fix0		*��`�̍������P�s�N�Z�������Ȃ������ꍇ��
	moveq.l	#0,d1		*�@���܍��킹

fix0:	move.w	d3,d7		*d7 = ��`�̍���-1 = ���[�v�J�E���^
gloop1:	move.w	d0,(a1)+	*Bresenham�̃A���S���Y���ŐF���Ԃ���
	add.w	d1,d5		*
	ble	gskip		*
gloop2:	add.w	d4,d0		*
	sub.w	d6,d5		*
	bgt	gloop2		*
gskip:	dbra	d7,gloop1	*
	rts

*
*	���������̐F��Ԃ̂��߂̏�����
*
hinit:	sub.w	d4,d5
	move.w	d5,d0
	ABS	d5
	SGN	d0
	add.w	d5,d5
	move.w	d1,(a1)+	*�덷�������l
	bne	fix1
	moveq.l	#0,d5
fix1:	move.w	d5,(a1)+	*�덷������
	move.w	d0,(a1)+	*����
	rts

	.end
