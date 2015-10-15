*	G-RAMへグラフィックパターンを書き込む（半透明）

	.include	gconst.h
	.include	gmacro.h
*
	.xdef	ghalftoneput
	.xref	gramadr
	.xref	gcliprect
*
	.offset	0	*ghalftoneputの引数構造
*
X0:	.ds.w	1	*矩形領域
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
PAT:	.ds.l	1	*パターン
*COL:	.ds.w	1
*
	.text
	.even
*
ghalftoneput:
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

*move.w	COL(a1),d5	*d5 = 透明色
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

	move.w	d6,d0		*d0 = スキップするバイト数

loop1:	move.w	d2,d4		*d4 = 横ピクセル数-1
	swap.w	d0
	swap.w	d1
	swap.w	d2
	swap.w	d3
loop2:	move.w	(a1)+,d0	*パターン側から１ピクセル
	DERGB	d0,d1,d2,d3	*　RGBに分解する
	move.w	(a0),d0		*画面からも１ピクセル
	DERGB	d0,d5,d6,d7	*　RGBに分解する
	MEAN	d5,d1		*RGBごとに平均を求め
	MEAN	d6,d2		*
	MEAN	d7,d3		*
	RGB	d1,d2,d3,d0	*　カラーコードに再構成して
	move.w	d0,(a0)+	*　書き込む
	dbra	d4,loop2	*横幅分繰り返す

	swap.w	d0
	swap.w	d1
	swap.w	d2
	swap.w	d3
	adda.w	d1,a0		*つぎのラインへ
	adda.w	d0,a1		*クリッピングした分パターンを飛ばす
	dbra	d3,loop1	*ライン数分繰り返す

done:	movem.l	(sp)+,d0-d7/a0-a1
	unlk	a6
	rts

	.end

修正履歴

92-01-01版
クリッピングに正しく対応できていなかったのを修正

92-02-01版
修正を本文に反映させるために行数を調節（内容の変化なし）
