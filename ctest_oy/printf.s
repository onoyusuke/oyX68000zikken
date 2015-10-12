* c�̃��C�u�����ƃ����N����K�v������̂ŁAcc�ŃR���p�C�����Arename printf.x printf.fnc �Ɩ��O��ς���B

* X-BASIC�̊O���֐��Ƃ���printf�����(�R���\�[����p)
* ���ۂ́Ac�̊֐����Ăяo���B���̂��߂̂��V���Ă��s���v���O�����B
* BASIC����ϐ����󂯎��B�������A�X�^�b�N�ɐςށB�t�H�[�}�b�g�Ɋւ��Ă̓G�X�P�[�v������𐮗����A�������ɏ������݁A����ւ̃|�C���^��ςށB���̂����ŁAC�̊֐����Ăяo���B



CR EQU $0D
LF EQU $0A
*
	.TEXT
	dc.l	X_INZ
	dc.l	X_RUN
	dc.l	X_END
	dc.l	X_SYSTEM
	dc.l	X_BRK
	dc.l	X_CTRL_D
	dc.l	X_RETADRS
	dc.l	X_RETADRS
	dc.l	PTR_TOKEN
	dc.l	PTR_PARAM
	dc.l	PTR_EXEC
	dc.l	0,0,0,0,0  * �Ō��20�o�C�g��0.

* Function Name Table
PTR_TOKEN
	DC.B	'printf',0
	DC.B	0

	.EVEN
* Function Parameteres Table
PTR_PARAM
	dc.l	COM_PARAM

str_val		equ	$0008
any_aryl_omt	equ	$00bf  * $00bf=0000000010111111 (10111111�̈Ӗ��͏�ʃr�b�g����A1=�ȗ��\. 01=1�����z��. 1=�|�C���^. 1111=�S�Ă̌^)
int_ret		equ	$8001

COM_PARAM
	dc.w	str_val
	dc.w	any_aryl_omt,any_aryl_omt
	dc.w	any_aryl_omt,any_aryl_omt
	dc.w	any_aryl_omt,any_aryl_omt
	dc.w	any_aryl_omt,any_aryl_omt
	dc.w	any_aryl_omt
	dc.w	int_ret

* Fuction Address Table
PTR_EXEC
	dc.l	b_cprintf
X_INZ:
X_RUN:
X_END:
X_SYSTEM:
X_BRK:
X_CTRL_D:
X_RETADRS:
	rts
*
	.TEXT
b_cprintf
*
	move.l	sp,OLD_SP	* save stack
	moveq.l #10-1-1,D7	* ���[�v�̉�. 10�̈����̂����ŏ��̈����͏����w��̕�����. 
	lea	96(sp),a1	* a1=type of last param. (4+2)+(2+4+4)�~9��96.
*
LOOP1	tst.w	(a1)		* check type
	bpl	LOOP2		* $ffff == omit parapeter�łȂ��̂Ȃ�loop2��
	lea	-10(a1),a1	* a1=a1-10. ��O�̃p�����[�^
	dbra	d7,LOOP1
	bra 	DO_IT * format�����Ȃ��ꍇ�̏����B���ꂪ�Ȃ��Ǝ���LOOP2��ERROR�ɔ��ł��܂��B
* 
LOOP2	move.w	(a1),d0		* get type.
	ext.l	d0		* sign extend �����g��
	bmi	ERROR		* if d0==$ffff(�����ȗ�) then error. 
*loop1����bpl LOOP2�Ŕ��ł���ꍇ�ɂ́A�ϐ��̔������Ȃ��Ƃ��������Ŕ��ł���̂ň���������Ȃ��B(s,,k)�̂悤�Ȕ���������ꍇ�ɂ́Ak�Ɋւ��ď�������lea -10(a1),a1���Ă�����ł���̂ň���������B
	beq	DO_FLOW		* if d0==0 then float�^. 64�r�b�g.
	subq.l	#2,d0
	bmi	DO_INT		* d0==1 int�^. ���̂܂�32�r�b�g
	beq	DO_CHR		* d0==2 char�^. �����g������32�r�b�g�ɕϊ�
DO_STR				* d0==3 str�^
	move.l	6(a1),a2	* �l(�z��ւ̃|�C���^)�̎��o��. ���ʂ�4�o�C�g�Ȃ̂�6=2+4������΂�.
	pea	10(a2)		* push pointer. 1�����z��̃f�[�^����10�o�C�g�߂���n�܂�. ������Ȃ̂Ń|�C���^���f�[�^�Ƃ��ē����Ă���.
	lea	-10(a1),a1	* a1=a1-10. ��O�̃p�����[�^
	dbra	d7,LOOP2
	bra	DO_IT
*
DO_CHR
	move.l	6(a1),a2
	move.b	10(a2),d0	* get val. 1�����z��̃f�[�^����10�o�C�g�߂���n�܂�.
*
	ext.w	d0		* sign extend
	ext.l	d0		* sign extend. 2�i�K�̕����g����4�o�C�g�ɂ���.
*
	move.l	d0,-(sp)	* push val.
	lea	-10(a1),a1	* a1=a1-10. ��O�̃p�����[�^
	dbra	d7,LOOP2
	bra	DO_IT
DO_INT
	move.l	6(a1),a2
	move.l	10(a2),-(sp)	* �����g���͂��Ȃ���long�^�Ƃ��Ă�����push
	lea	-10(a1),a1	* a1=a1-10. ��O�̃p�����[�^
	dbra	d7,LOOP2
	bra	DO_IT
DO_FLOW
	move.l	6(a1),a2
	movem.l	10(a2),d0/d1	* 64�r�b�g�����擾. 
	movem.l d0/d1,-(sp)	* 64�r�b�g�������̂܂�push.
	lea	-10(a1),a1	* a1=a1-10. ��O�̃p�����[�^
	dbra	d7,LOOP2
*
DO_IT				* �擪�̈���(format��\��str)�̏���
	move.l	6(a1),a1	* ����܂łƓ��l6(a1)��ǂݍ��ނ��A�����a1�ɑ��. �ȉ��Aa1��format���Ăяo�����߂̃|�C���^�Ƃ��Ďg��.
	lea	FSTR,a2		* ���`����format��FSTR�ɂ����Ă����B�ȉ��Aa2�����̗̈�ւ̃|�C���^�Ƃ��Ďg���B
	moveq.l	#'\',d6		* \�����o���邽�߂�d6��p����B 
FCONVL
	move.b	(a1)+,d0	* format����ǂݍ���
	cmp.b	d6,d0		* slash(\)���H
	beq	SLASH		* slash�Ȃ炻��Ƃ��ď���.
	move.b	d0,(a2)+	* slash�łȂ��̂Ȃ��FSTR�ɂ��̂܂܏�������
	bne	FCONVL		* format�ɕ����񂪎c���Ă���̂Ȃ炻�������
	bra	GO_PRINTF	* �S�ď��������̂Ȃ�΁Aprintf���Ăяo��
*
SLASH	move.b	(a1)+,d0
	cmp.b	#'n',d0		* '\n'?
	beq	DO_N		* then do_n
	moveq.l	#$09,d1		* '\t'�̂Ƃ��̂��߂ɁB
	cmp.b	#'t',d0		* '\t'?
	beq	SEND		
	cmp.b	#'7',d0
	bgt	SEND0
	cmp.b	#'0',d0
	blt	SEND0		* 0-7��������ȉ�. ����ȊO��send0�ցB
*octal number
	moveq.l	#0,d1		* ���ʂ����郌�W�X�^d1�̏�����
	moveq.l	#3-1,d2		* �J�E���^�[�B�ő�łR��������A�ő�łQ��V�t�g�B
OCTLOOP
	sub.b	#'0',d0		* d0�ɓǂݍ��񂾐����̃A�X�L�[�R�[�h�𐔒l�ɕϊ�
	asl.b	#3,d1		* d1��8�{����
	add.b	d0,d1
	move.b	(a1)+,d0
	cmp.b	#'7',d0
	bgt	OCTEND
	cmp.b	#'0',d0
	blt	OCTEND		* 0-7�������猅�����`�F�b�N. 0-7�ȊO�Ȃ�send0�ւ���3�������ł̏I���B
	dbra	d2,OCTLOOP	* 0-7�ł��������R���𒴂��Ă�����A����octend�ɂ��������܂��B
OCTEND				* 3���ɂ����������߂ɏI������.
	move.b	d1,(a2)+	* ���ʂ�FSTR�ɏ�������.
	subq.l	#1,a1		* �I�������̔���̂��߂�move.b (a1)+,d0�łP�]���Ɏ擾�����̂ł��̕���߂�
	bra	FCONVL
SEND0	move.b	d0,(a2)+	
	bra	FCONVL
SEND	move.b	d1,(a2)+	* '\t'�̂Ƃ���p��
	bra	FCONVL
DO_N	move.b	#CR,(a2)+
	move.b	#LF,(a2)+
	bra	FCONVL

GO_PRINTF
	pea	FSTR
	jsr	_cprintf	* C�֐����Ă�
	move.l	OLD_SP,sp
	move.l	d0,INT_DATA	* �߂�l
	lea	RET_DATA,a0
	clr.l	d0		* �G���[����
	rts
*
ERROR	
	move.l	OLD_SP,sp
	moveq.l #1,d0
	lea	MES0,a1
	rts
*
OLD_SP	ds.l	1
*
RET_DATA
	ds.w	1
	ds.l	1
INT_DATA
	ds.l	1

MES0:	dc.b	'�p�����[�^�̕��тɔ����Ă��镔��������܂�',0
*
FSTR	ds.b	256
*
	.END
