*	�R�}���h���C�������̓n���ꂩ�����m�F����

	.include	doscall.mac
	.include	const.h		*�O�͂ŗp�ӂ����萔��`�t�@�C��
*
	.text
	.even
*
ent:
	lea.l	mysp,sp		*sp�̏�����

	move.w	#'[',-(sp)	*[��\��
	DOS	_PUTCHAR	*
	addq.l	#2,sp		*

	pea.l	1(a2)		*a2+1�����
	DOS	_PRINT		*�@�R�}���h���C���������
	addq.l	#4,sp		*�@�\��

	pea.l	endmes		*]��\�����ĉ��s����
	DOS	_PRINT		*
	addq.l	#4,sp		*

	DOS	_EXIT		*�I��
*
	.data
	.even
*
endmes:	.dc.b	']',CR,LF,0
*
	.stack
	.even
*
mystack:
	.ds.l	256		*�X�^�b�N�̈�
mysp:
	.end
