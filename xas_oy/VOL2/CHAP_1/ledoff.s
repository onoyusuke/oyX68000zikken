*	�S�Ă�LED�L�[��OFF�ɂ���

	.include	iocscall.mac
	.include	doscall.mac
*
ent:
	moveq.l	#0,d2		*0...OFF/1...ON
	moveq.l	#7-1,d1		*LED�L�[�ԍ������[�v�J�E���^
loop:	IOCS	_LEDMOD		*�ݒ�
	dbra	d1,loop		*�J��Ԃ�

	DOS	_EXIT		*�I��

	.end	ent
