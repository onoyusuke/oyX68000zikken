*���p�p���������p�啶���ϊ��T�u���[�`��

toupper:
	cmpi.b	#'a',d0		*�p���������H
	bcs	toupr0		*
	cmpi.b	#'z'+1,d0	*
	bcc	toupr0		*
	subi.b	#$20,d0		*�������Ȃ�啶���ɕϊ�
toupr0:	rts			*�T�u���[�`�����烊�^�[��
