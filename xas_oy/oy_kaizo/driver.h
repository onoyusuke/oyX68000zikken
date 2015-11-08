*	�f�o�C�X�h���C�o�쐬�p�萔��`
*		driver.h
*

*
*	�f�o�C�X�w�b�_���I�t�Z�b�g
*
	.offset	0
*
DEVLNK:	.ds.l	1	*�����N�|�C���^
DEVATR:	.ds.w	1	*�f�o�C�X����
DEVSTR:	.ds.l	1	*�X�g���e�W���[�`���G���g��
DEVINT:	.ds.l	1	*���荞�݃��[�`���G���g��
DEVNAM:	.ds.b	8	*�f�o�C�X��
*
	.text
*
*	�f�o�C�X����
*			 54321098 76543210
CHAR_DEVICE	equ	%10000000_00000000
BLOCK_DEVICE	equ	%00000000_00000000
ENABLE_IOCTRL	equ	%01000000_00000000
DISABLE_IOCTRL	equ	%00000000_00000000
RAW_MODE	equ	%00000000_00100000
COOKED_MODE	equ	%00000000_00000000
CLOCK_DEVICE	equ	%00000000_00001000
NUL_DEVICE	equ	%00000000_00000100
STDOUT_DEVICE	equ	%00000000_00000010
STDIN_DEVICE	equ	%00000000_00000001
*
ISCHRDEV_BIT	equ	15
IOCTRL_BIT	equ	14
ISRAW_BIT	equ	5
ISCLOCK_BIT	equ	3
ISNUL_BIT	equ	2
ISSTDOUT_BIT	equ	1
ISSTDIN_BIT	equ	0

*
*	�G���[�R�[�h
*
_ABORT		equ	$1000
_RETRY		equ	$2000
_IGNORE		equ	$4000
*
ILLEGAL_CMD	equ	$0003.or._ABORT.or._IGNORE

*
*	���N�G�X�g�w�b�_���I�t�Z�b�g
*
CMD_CODE	equ	2
ERR_LOW		equ	3
ERR_HIGH	equ	4
*
*init
DEV_END_ADR	equ	14
PAR_PTR		equ	18
*
*sns
SNS_DATA	equ	13
*
*i/o
DMA_ADR		equ	14
DMA_LEN		equ	18
