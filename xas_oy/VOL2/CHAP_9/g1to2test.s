*	g1to2, gshrinkの動作試験用プログラム

	.include	doscall.mac
*
	.xref	g1to2
	.xref	gshrink
*
	.text
	.even
*
ent:
	lea.l	inisp,sp

	clr.l	-(sp)		*スーパーバイザモードへ
	DOS	_SUPER		*

	pea.l	arg		*gshrinkで3/4に縮小
	jsr	gshrink		*
	addq.l	#4,sp		*

	pea.l	arg1		*g1to2でさらに1/2に縮小
	jsr	g1to2		*
	addq.l	#4,sp		*

	DOS	_EXIT
*
	.data
	.even
*
arg:				*gshrinkの引数
	.dc.w	0,0,511,511	*3/4
	.dc.w	383,383		*
	.dc.l	temp
*
arg1:				*g1to2の引数
	.dc.w	0,0,511,511
*
	.bss
	.even
*
temp:	.ds.w	1024*3		*gshrinkのワーク
*
	.stack
	.even
*
	.ds.l	4096
inisp:
	.end	ent
