	.include        doscall.mac
*
	.xdef   memoff          *外部定義
*
	.text
	.even
*
*memoff()
*機能： プログラム本体以降の余分なメモリを解放する
*	注意：プログラム起動直後、a0,a1が破壊される前に
*	      呼び出すこと
*レジスタ破壊：a0.l,a1.l,d0.l,ccr
*
memoff:
	lea.l	16(a0),a0	*a0 = メモリ管理ポインタの直後
				*a1 =　プログラム本体の直後
	suba.l	a0,a1		*a1 - a0 = プログラムに必要な
				*	　 メモリサイズ
	move.l	a1,-(sp)	*メモリブロックの新サイズ
	move.l	a0,-(sp)	*メモリブロックの先頭アドレス
	DOS	_SETBLOCK	*メモリブロックサイズ変更
	addq.l	#8,sp		*スタック補正

	rts

        .end
