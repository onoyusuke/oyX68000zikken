	.include        doscall.mac
*
	.xdef   memoff          *�O����`
*
	.text
	.even
*
*memoff()
*�@�\�F �v���O�����{�̈ȍ~�̗]���ȃ��������������
*	���ӁF�v���O�����N������Aa0,a1���j�󂳂��O��
*	      �Ăяo������
*���W�X�^�j��Fa0.l,a1.l,d0.l,ccr
*
memoff:
	lea.l	16(a0),a0	*a0 = �������Ǘ��|�C���^�̒���
				*a1 =�@�v���O�����{�̂̒���
	suba.l	a0,a1		*a1 - a0 = �v���O�����ɕK�v��
				*	�@ �������T�C�Y
	move.l	a1,-(sp)	*�������u���b�N�̐V�T�C�Y
	move.l	a0,-(sp)	*�������u���b�N�̐擪�A�h���X
	DOS	_SETBLOCK	*�������u���b�N�T�C�Y�ύX
	addq.l	#8,sp		*�X�^�b�N�␳

	rts

        .end
