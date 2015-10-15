*	全てのLEDキーをOFFにする

	.include	iocscall.mac
	.include	doscall.mac
*
ent:
	moveq.l	#0,d2		*0...OFF/1...ON
	moveq.l	#7-1,d1		*LEDキー番号兼ループカウンタ
loop:	IOCS	_LEDMOD		*設定
	dbra	d1,loop		*繰り返す

	DOS	_EXIT		*終了

	.end	ent
