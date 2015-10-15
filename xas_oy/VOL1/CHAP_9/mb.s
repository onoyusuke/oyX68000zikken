*	メモリ上の全メモリブロックの位置を表示する
*
*	作成法：as mb
*		as itoh
*		lk mb itoh
*
	.include	doscall.mac
	.include	const.h
*
	.xref	itoh		*外部参照
*
*	メモリ管理ポインタの構造
*
PREVMEM		equ	0
OWNERPROC	equ	4
MBEND		equ	8
NEXTMEM		equ	12
*
	.text
	.even
*
ent:
	lea.l	mysp,sp		*spの初期化

 	clr.l	-(sp)		*スーパーバイザモードに
	DOS	_SUPER		*　切り替える
				*d0 = ssp
	move.l	d0,(sp)		*sspを待避

loop1:	move.l	PREVMEM(a0),d0	*d0 = 直前のメモリ管理ポインタ
	beq	loop2		*0なら先頭
	movea.l	d0,a0		*a0 = 直前のメモリ管理ポインタ
	bra	loop1		*先頭に達するまで繰り返す

loop2:	pea.l	buff		*メモリ管理ポインタの
	move.l	a0,-(sp)	*　先頭アドレスを
	bsr	itoh		*　16進文字列変換して
	addq.l	#8,sp		*　buff以降にセットする

	move.b	#'-',buff+8	*つなぎの'-'を書き込む

	pea.l	buff+9		*メモリブロックの
	move.l	MBEND(a0),d0	*　最終アドレスを
	subq.l	#1,d0		*　16進文字列に変換して
	move.l	d0,-(sp)	*　buff+9以降にセットする
	bsr	itoh		*
	addq.l	#8,sp		*

	pea.l	buff		*XXXXXXXX-XXXXXXXXまでを
	DOS	_PRINT		*　まとめて表示する
	addq.l	#4,sp		*

	pea.l	crlfms		*改行する
	DOS	_PRINT		*
	addq.l	#4,sp		*

	move.l	NEXTMEM(a0),d0	*d0 = つぎのメモリ管理ポインタ
	movea.l	d0,a0		*←注意：フラグは変化しない
	bne	loop2		*d0が０でなければ繰り返す

	DOS	_SUPER		*ユーザーモードに
	addq.l	#4,sp		*　戻す

	DOS	_EXIT		*終了
*
	.data
	.even
*		 01234567890123456
buff:	.dc.b	'12345678-12345678',0	*表示用文字列格納領域
crlfms:	.dc.b	CR,LF,0			*改行コード
*
	.stack
	.even
*
mystack:			*スタック領域
	.ds.l	1024		*
mysp:
	.end	ent		*実行開始アドレスはent
