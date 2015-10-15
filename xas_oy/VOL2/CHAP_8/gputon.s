*	G-RAMへグラフィックパターンを書き込む（重ね合わせ）

	.include	gconst.h
	.include	gmacro.h
*
	.xdef	gputon
	.xref	gramadr
	.xref	gcliprect
*
	.offset	0	*gputonの引数構造
*
X0:	.ds.w	1	*描画先座標
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
PAT:	.ds.l	1	*パターン
COL:	.ds.w	1	*透明色
*
	.text
	.even
*
gputon:
ARGPTR	=	8
	link	a6,#0
	movem.l	d0-d7/a0-a1,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = 引数列
	movem.w	(a1),d0-d3	*d0～d3に座標を取り出す

	jsr	gcliprect	*クリッピングする
	bmi	done		*N=1なら描画の必要なし

	jsr	gramadr		*左上のG-RAM上のアドレスを得る

	sub.w	d0,d2		*d2 = 横ピクセル数-1
	sub.w	d1,d3		*d3 = 縦ピクセル数-1

	movem.w	(a1),d4-d7	*d4～d7にも座標を取り出す
	MINMAX	d4,d6		*d4≦d6を保証
	MINMAX	d5,d7		*d5≦d7を保証

	sub.w	d4,d0		*d0 = 切り取られた左端ピクセル数
	sub.w	d5,d1		*d1 = 切り取られた上端ピクセル数

	sub.w	d4,d6		*d6 = 元のパターンの横ピクセル数-1
	addq.w	#1,d6		*d6 = 元のパターンの横ピクセル数

	move.w	COL(a1),d5	*d5 = 透明色
	movea.l	PAT(a1),a1	*a1 = パターン先頭アドレス
	add.w	d0,d0		*クリッピングした分だけ
	adda.w	d0,a1		*
	add.w	d1,d1		*
	mulu.w	d6,d1		*
	adda.l	d1,a1		*　パターンを飛ばす

	sub.w	d2,d6		*
	subq.w	#1,d6		*
	add.w	d6,d6		*d6 = スキップするバイト数

	move.w	#GNBYTE-2,d1	*d1 = ライン間のアドレスの差
	sub.w	d2,d1		*
	sub.w	d2,d1		*

loop1:	move.w	d2,d4		*d4 = 横ピクセル数-1
loop2:	move.w	(a1)+,d0	*パターンを１ピクセル取り出す
	cmp.w	d0,d5		*透明色？
	bne	skip		*　そうでなければ
	move.w	(a0),d0		*ダミー

skip:	move.w	d0,(a0)+	*１ピクセル書き込む
	dbra	d4,loop2	*横幅分繰り返す

	adda.w	d1,a0		*すぐ下のラインへ
	adda.w	d6,a1		*クリッピングした分
				*　パターンを飛ばす
	dbra	d3,loop1	*高さ分繰り返す

done:	movem.l	(sp)+,d0-d7/a0-a1
	unlk	a6
	rts

	.end
