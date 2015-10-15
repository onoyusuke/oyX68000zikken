*	YかNのキー入力に対して
*		Y ･･･ 0
*		N ･･･ 1
*			の終了コードを返す

_EXIT		equ	$ff00
_GETC		equ	$ff08
_EXIT2		equ	$ff4c

	.text
	.even
*
start:
loop:	.dc.w	_GETC		*1文字入力
	and.w	#%1101_1111,d0	*英小文字→大文字変換
	cmp.b	#'Y',d0		*'Y'か？
	beq	yes		*そうならyesの処理へ
	cmp.b	#'N',d0		*'N'か？
	bne	loop		*どちらでもなければやり直し
*
no:	move.w	#1,-(sp)	*終了コード1を返す
	.dc.w	_EXIT2
*
yes:	.dc.w	_EXIT		*終了コード0を返す
*
	.end
