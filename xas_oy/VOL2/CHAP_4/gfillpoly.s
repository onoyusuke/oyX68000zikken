*	スキャンコンバージョンによる多角形の塗り潰し

	.include	gconst.h
	.include	gmacro.h
	.include	rect.h
	.include	edge.h
*
	.xdef	gfillpoly
	.xref	ghline
	.xref	gramadr
	.xref	cliprect
*
	.offset	0	*gfillpolyの引数構造
*
EDGES:	.ds.l	1	*辺リスト先頭アドレス
EDGEED:	.ds.l	1	*辺リスト最終アドレス
EDGARY:	.ds.l	1	*EDGBUFのポインタ配列用ワーク
COL:	.ds.l	1	*描画色
*
	.text
	.even
*
gfillpoly:
ARGPTR	=	4
	movem.l	d0-d7/a0-a6,-(sp)
SAVREGS =	8+7
ARGPTR	=	ARGPTR+SAVREGS*4
	movea.l	ARGPTR(sp),a0	*a0 = 引数列
	bsr	init		*初期化する
	bra	lpent

*	d0.l	描画色パレットコード（上位/下位ワードとも）
*	d1～d4	作業用
*	d5.l	ghline
*	d6.w	残りEDGBUF数
*	d7.w	注目しているスキャンラインのy座標
*
*	a0～a2	作業用
*	a3	未処理EDGBUFのポインタ配列先頭
*	a4	未処理EDGBUFのポインタ配列末尾
*		（＝処理中EDGBUFのポインタ配列先頭）
*	a5	処理中EDGBUFのポインタ配列末尾
*	a6	注目しているスキャンラインの左端アドレス

mainloop:
	cmpa.l	a4,a3		*未処理のEDGBUFが
	beq	nomore		*　もうなければスキップ
	bsr	activate	*アクティブにすべきEDGBUFを探す

nomore:	cmpa.l	a5,a4		*処理中のEDGBUFが
	beq	nextln		*　なければスキップ

	bsr	sortlist	*交点のx座標でソートする
	bsr	drawline	*１ライン描画する
	bsr	calcnextx	*つぎの交点を求める

nextln:	lea.l	GNBYTE(a6),a6	*a6 = つぎのラインの左端アドレス
	addq.w	#1,d7		*d7 = つぎのラインのy座標

lpent:	tst.w	d6		*EDGBUFが残っているあいだ
	bne	mainloop	*　繰り返す

	movem.l	(sp)+,d0-d7/a0-a6
	rts

*
*	未処理EDGBUF群の中から
*	注目しているスキャンライン上に始点があるものを探し,
*	あれば, 処理中EDGBUFのポインタ配列に移動する
*
activate:
	movea.l	a3,a1		*a1 = 未処理EDGBUFのポインタ配列
actvlp:	movea.l	(a1)+,a0	*a0 = EDGBUFへのポインタ
	cmp.w	Y0(a0),d7	*始点のy座標 = 現在のy座標？
	bne	actvnx		*　でなければ, まだ

			*EDGBUFをアクティブにする
	move.w	X0(a0),(a0)	*最初の交点のx座標（= x0）を設定
	move.l	DY0(a0),DY(a0)	*ループカウンタと誤差項を初期化

	move.l	-(a4),-(a1)	*未処理EDGBUFのポインタ配列から削除
	move.l	a0,(a4)		*処理中EDGBUFのポインタ配列に追加

actvnx:	cmpa.l	a4,a1		*すべての未処理EDGBUFについて
	bcs	actvlp		*　繰り返す
	rts

*
*	交点のx座標の小さい順に
*	処理中のEDGBUFのポインタ配列をソートする
*
sortlist:
	move.l	a5,d2		*a5を待避

	subq.l	#4,a5		*単純挿入法でソートする
	bra	sortnx		*
srtlp2:	move.l	a1,-8(a2)	*
srtlp1:	movea.l	(a2)+,a1	*
	cmp.w	(a1),d1		*
	bgt	srtlp2		*
	move.l	a0,-8(a2)	*
sortnx:	movea.l	a5,a2		*
	movea.l	-(a5),a0	*
	move.w	(a0),d1		*
	cmpa.l	a4,a5		*
	bcc	srtlp1		*

	movea.l	d2,a5		*a5を復帰
	rts

*
*	１ライン分描画する
*
drawline:
	movea.l	a4,a1		*a1 = 処理中のEDGBUFのポインタ配列先頭
	movea.l	d5,a2		*

	move.w	cliprect+MINX,d3	*d3 = MINX
	move.w	cliprect+MAXX,d4	*d4 = MAXX

drawlp:	movea.l	(a1)+,a0	*a0 = EDGBUFへのポインタ
	move.w	(a0),d1		*d1 = 描く水平線分の始点x座標
	cmp.w	d4,d1		*始点＞MAXXならば
	bgt	drawq		*　線分は画面の右外だから描画完了

	movea.l	(a1)+,a0	*
	move.w	(a0),d2		*d2 = 描く水平線分の終点x座標
	cmp.w	d3,d2		*終点＜MINXならば
	blt	drawlp		*　線分は画面の左外

	MAX	d3,d1		*始点を画面左端でクリップ
	MIN	d4,d2		*終点を画面右端でクリップ
	sub.w	d1,d2		*d2 = 描く水平線分の長さ-1

	add.w	d1,d1		*
	lea.l	0(a6,d1.w),a0	*a0 = 描く線分の左端アドレス
	addq.w	#1,d2		*d2 = 描く線分の長さ
	bclr.l	#0,d2		*奇数？
	beq	notodd		*
	move.w	d0,(a0)+	*　奇数ピクセルの分
notodd:	neg.w	d2		*

	jsr	0(a2,d2.w)	*水平線分描画

	cmpa.l	a5,a1
	bcs	drawlp

drawq:	rts

*
*	つぎのスキャンラインおける
*	交点のx座標を求める
*
calcnextx:
	movea.l	a4,a1		*a1 = 処理中EDGBUFのポインタ配列先頭
calclp:	movea.l	(a1)+,a0	*a0 = EDGBUFへのポインタ
	subq.w	#1,DY(a0)	*カウンタを減らす
	beq	deactivate	*　0になったら配列から削除する
				*　（最後の１点は処理しない）
	move.w	E(a0),d1	*d1 = e
	add.w	DEX(a0),d1	*e += 2*dx
	bmi	calskp		*e＜0ならx座標は今回のまま

	move.w	SX(a0),d4	*sgn(x1-x0) = 0なら
	beq	calcnx		*　x座標は不変
	movem.w	(a0),d2-d3	*d2 = x, d3 = 2*dy
inclp:	add.w	d4,d2		*x += sgn(x1-x0)
	sub.w	d3,d1		*e -= 2*dy
	bpl	inclp		*e≧0のあいだ繰り返す

	move.w	d2,(a0)		*求めたx座標
calskp:	move.w	d1,E(a0)	*eを更新

calcnx:	cmpa.l	a5,a1		*すべての処理中EDGBUFについて
	bcs	calclp		*　繰り返す
	rts
*
deactivate:
	move.l	-(a5),-(a1)	*用ずみのEDGBUFを削除する
	move.l	4(a5),(a5)	*その分番人を詰める
	subq.w	#1,d6		*残りEDGBUF数を減らす
	bra	calcnx

*
*	初期化
*
*	・すべてのEDGBUFを未処理EDGBUFのポインタ配列にまとめる
*	・処理中EDGBUFのポインタ配列を空にする
*	・最初に注目するスキャンラインのy座標と左端アドレスを求める
*	・EDGBUFの数を数える
*	・描画色をレジスタに設定する
*
init:
	movem.l	(a0)+,a1-a3	*a1 = EDGBUF配列の先頭
				*a2 = EDGBUF配列の末尾
	movea.l	a3,a4		*a3 = a4
				*   = 未処理EDGBUFのポインタ配列先頭
	moveq.l	#-1,d1		*d1 = 仮の最小y座標
	moveq.l	#0,d6		*d6 = EDGBUFのカウンタ
	move.w	(a0)+,d7	*d7 = 描画色
	bra	ilpent

initlp:	move.l	a1,(a4)+	*順に未処理EDGBUFのポインタ配列に追加
	move.w	Y0(a1),d0	*始点のy座標が
	cmp.w	d1,d0		*　仮の最小y座標より小さければ
	bcc	notmin		*
	move.w	d0,d1		*　仮の最小y座標を更新する

notmin:	addq.w	#1,d6		*EDGBUFの数を数え上げる
	lea.l	EDGBUFSIZ(a1),a1	*a1 = つぎのEDGBUF
ilpent:	cmpa.l	a2,a1		*すべてのEDGBUFについて
	bcs	initlp		*　繰り返す

				*d1 = 最小のy座標
				*d6 = EDGBUFの個数
				*a4 = 未処理EDGBUFのポインタ配列末尾
				*   = 処理中EDGBUFのポインタ配列先頭
	movea.l	a4,a5		*a5 = 処理中EDGBUFのポインタ配列末尾
				*（a4 = a5だから空）

	move.l	#dmydat,(a5)	*番人を置く

	moveq.l	#0,d0		*x = 0
	jsr	gramadr		*
	movea.l	a0,a6		*a6 = 最初に処理する
				*     スキャンラインの左端アドレス
	move.l	#ghline,d5	*d5 = 水平線分描画ルーチン基準アドレス

	move.w	d7,d0		*d0 = 描画色
	swap.w	d0		*
	move.w	d7,d0		*

	move.w	d1,d7		*d7 = 最初に処理する
				*     スキャンラインのy座標
	rts
*
dmydat:	.dc.w	32767		*番人として使うダミーデータ
				*（XのフィールドしかないEDGBUF）

	.end

修正履歴

92-01-01版
アドレスレジスタに加算する定数でd5レジスタを無駄遣いしていたのを効率よく修正
