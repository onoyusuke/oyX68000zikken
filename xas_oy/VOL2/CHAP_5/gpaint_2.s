*	シードフィルによる領域の塗り潰し（高速化版）

	.include	gconst.h
	.include	gmacro.h
	.include	rect.h
*
	.xdef	gpaint
	.xref	ghline
	.xref	gramadr
	.xref	cliprect
*
	.offset	0	*gpaintの引数構造
*
X0:	.ds.w	1	*初期シード座標
Y0:	.ds.w	1	*
COL:	.ds.w	1	*描画色
TEMP:	.ds.l	1	*作業用領域先頭
TEMPED:	.ds.l	1	*作業用領域末尾+1
*
	.offset	-14	*スタックフレーム
WORKSIZ:
LXSAV:	.ds.w	1	*処理中シードのLX
RXSAV:	.ds.w	1	*　　　　　　　RX
MY:	.ds.w	1	*　　　　　　　PREVY
BUFTOP:	.ds.l	1	*リングバッファ先頭
BUFEND:	.ds.l	1	*リングバッファ末尾+1
_a6:	.ds.l	1
_pc:	.ds.l	1
ARGPTR:	.ds.l	1
*
	.offset	0	*シード候補
*
LADR:	.ds.l	1	*左端G-RAMアドレス
LX:	.ds.w	1	*左端x座標
Y:	.ds.w	1	*y座標
RADR:	.ds.l	1	*右端G-RAMアドレス
RX:	.ds.w	1	*右端x座標
PREVY:	.ds.w	1	*親のy座標
SEEDSIZ:
*
	.text
	.even
*
gpaint:
	link	a6,#WORKSIZ
	movem.l	d0-d7/a0-a5,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = 引数列
	movem.w	X0(a1),d0-d1	*(d0,d1) = 初期シード

	lea.l	cliprect,a5	*a5 = クリッピング領域
	cmp.w	(a5)+,d0	*初期シードが
	blt	done		*　ウィンドウ外なら
	cmp.w	(a5)+,d1	*　何もせずに戻る
	blt	done		*
	cmp.w	(a5)+,d0	*
	bgt	done		*
	cmp.w	(a5)+,d1	*
	bgt	done		*
	subq.l	#RECT,a5	*a5 = クリッピング領域

	jsr	gramadr		*a0 = 初期シードG-RAMアドレス

	move.w	(a0),d6		*d6 = 領域色

	move.w	COL(a1),d7	*d7 = 描画色
	cmp.w	d6,d7		*描画色と領域色が等しいなら
	beq	done		*　何もせずに戻る
	swap.w	d7		*
	move.w	COL(a1),d7	*

	movea.l	TEMP(a1),a3	*a3 = キュー内の読み出し位置
	movea.l	a3,a4		*a4 = キュー内の書き込み位置
				*（ともにバッファ先頭に初期化）

	move.l	TEMPED(a1),d3	*d3 = バッファ末尾+1
	sub.l	a3,d3		*バッファ先頭＜末尾ならば
	bcs	done		*　何もせずに戻る
	andi.l	#$ffff_fff0,d3	*d3 = バッファサイズ（16の倍数）
	beq	done		*バッファサイズが０ならば
				*　何もせずに戻る
	add.l	a3,d3		*d3 = バッファ末尾+1

	move.l	a3,BUFTOP(a6)	*バッファ先頭と末尾を
	move.l	d3,BUFEND(a6)	*　ワークに格納しておく

	movea.l	a0,a1		*初期シードでは
	move.w	d0,d2		*　LXとRXは一致している

	move.w	d1,MY(a6)	*初期シードには親はいない

	bra	do

loop:	movea.l	(a3)+,a0	*a0 = LADR
	move.w	(a3)+,d0	*d0 = LX
	move.w	(a3)+,d1	*d1 = Y
	movea.l	(a3)+,a1	*a1 = RADR
	move.w	(a3)+,d2	*d2 = RX
	move.w	(a3)+,MY(a6)	*PREVYをワークにセーブ

do:
*	d0	左側シードx座標
*	d1	左側シードy座標
*	d2	右側シードx座標
*	d6	領域色（この色の点を塗り潰す）
*	d7	描画色
*	a0	左側シードG-RAMアドレス
*	a1	右側シードG-RAMアドレス
*	a3	キュー内のつぎの読み出し位置
*	a4	キュー内のつぎの書き込み位置
*	a5	クリッピング領域

	cmp.w	(a1)+,d6	*すでに処理済みのシードならば
	bne	next		*　捨てる

	move.w	d0,LXSAV(a6)	*LX,RXをワークにセーブ
	move.w	d2,RXSAV(a6)	*

	movea.l	a0,a2		*a0 = a2 = シード右端のG-RAMアドレス

			*右方向の境界を探す
rchk:	move.w	MAXX(a5),d3	*
	sub.w	d2,d3		*d3 = 走査する最大ピクセル数
	subq.w	#1,d3		*d3 = 0ならば
	bmi	lchk		*　走査は不要
rloop:	cmp.w	(a1)+,d6	*
	dbne	d3,rloop	*
	beq	lchk		*
	subq.l	#2,a1		*

			*左方向の境界を探す
lchk:	move.w	MINX(a5),d3
	sub.w	d0,d3		*d3 = -走査する最大ピクセル数
	neg.w	d3		*d3 = 走査する最大ピクセル数
	subq.w	#1,d3		*d3 = 0ならば
	bmi	filspn		*　走査は不要
lloop:	cmp.w	-(a0),d6	*
	dbne	d3,lloop	*
	beq	filspn		*
	addq.l	#2,a0		*

filspn:	move.l	a2,d3		*d3 = 走査開始前の位置
	sub.l	a0,d3		*d3 = 左へ走査したバイト数
	lsr.w	#1,d3		*d3 = 左へ走査したピクセル数
	sub.w	d3,d0		*d0 = 線分左端x座標

	move.l	a1,d2		*d2 = 走査終了後の右端位置
	sub.l	a0,d2		*d2 = 左端から右端のバイト数
	lsr.w	#1,d2		*d2 = 線分のピクセル数
	subq.w	#1,d2		*d2 = 線分のピクセル数-1

	movea.l	a0,a2		*a0 = a2 = 線分左端G-RAMアドレス

	move.w	d2,d3		*d3 = 描く線分の長さ-1
	addq.w	#1,d3		*d3 = 描く線分の長さ
	bclr.l	#0,d3		*奇数？
	beq	notodd		*
	move.w	d7,(a0)+	*　奇数ピクセルの分
notodd:	neg.w	d3		*

	lea.l	ghline,a1	*水平線分描画
	exg.l	d0,d7		*
	jsr	0(a1,d3.w)	*
	exg.l	d0,d7		*

			*真上のスキャンラインを走査する
uchk:	add.w	d0,d2		*d2 = 線分右端x座標
	move.w	d1,d4		*d4 = y

	subq.w	#1,d1		*y--
	cmp.w	MINY(a5),d1	*ウィンドウの上端を越えていたら
	blt	dchk		*　走査の必要はない
	lea.l	-GNBYTE(a2),a0	*a0 = 走査するライン左端
	bsr	seapix		*走査する

			*真下のスキャンラインを走査する
dchk:	addq.w	#1+1,d1		*y++
	cmp.w	MAXY(a5),d1	*ウィンドウの下端を越えていたら
	bgt	next		*　走査の必要はない
	lea.l	GNBYTE(a2),a0	*a0 = 走査するライン左端
	bsr	seapix		*走査する

next:	cmpa.l	BUFEND(a6),a3	*キューの読み出し位置が
	bcs	next0		*　バッファ末尾に達していたら
	movea.l	BUFTOP(a6),a3	*　先頭を指すよう修正する

next0:	cmpa.l	a3,a4		*キューが空になるまで
	bne	loop		*　繰り返す

done:	movem.l	(sp)+,d0-d7/a0-a5
	unlk	a6
	rts

*
*	上下のラインからシードの候補を探しキューに追加する
*
seapix:
	movea.l	a0,a1		*a0 = a1 = 走査開始位置
	suba.w	d0,a1		*
	suba.w	d0,a1		*a1 = 走査開始ラインの
				*　物理的な左端（x=0）のアドレス

	cmp.w	MY(a6),d1	*走査するラインは親ライン？
	bne	spix1		*　違うのならばふつうに走査する

	move.w	LXSAV(a6),d3	*d3 = 走査範囲のうち
	sub.w	d0,d3		*　親ライン左端からのはみ出し分
	ble	spix0		*はみ出しはなかった
	subq.w	#1,d3		*d3 = ループカウンタ

	move.l	a0,-(sp)	*走査範囲のうち
	bsr	spix2		*　親ライン左端より
	movea.l	(sp)+,a0	*　左の部分を走査

spix0:	move.w	d2,d3		*d3 = 走査範囲のうち
	move.w	RXSAV(a6),d5	*　親ライン右端からの
	sub.w	d5,d3		*　はみ出し分
	ble	sdone		*はみ出しはなかった
	subq.w	#1,d3		*d3 = ループカウンタ

	add.w	d5,d5		*a0 = 走査開始位置
	lea.l	2(a1,d5),a0	*

	bra	spix2		*走査範囲のうち
				*　親ライン右端より
				*　右の部分を走査

spix1:	move.w	d2,d3		*
	sub.w	d0,d3		*d3 = 走査範囲のピクセル数-1
spix2:
sloop1:	cmp.w	(a0)+,d6	*非領域色部分を飛ばす
	dbeq	d3,sloop1	*
	bne	sdone		*

	move.l	a0,d5
	subq.l	#2,d5		*d5 = 領域色部分左端アドレス

	move.l	d5,(a4)+	*LADR
	sub.l	a1,d5		*
	lsr.w	#1,d5		*
	move.w	d5,(a4)+	*LX
	move.w	d1,(a4)+	*Y

	subq.w	#1,d3		*
	bmi	bound		*走査範囲右端に達した

sloop2:	cmp.w	(a0)+,d6	*領域色部分を飛ばす
	dbne	d3,sloop2	*
	beq	bound		*
	subq.l	#2,a0		*

bound:	move.l	a0,d5
	subq.l	#2,d5		*d5 = 領域色部分右端アドレス

	move.l	d5,(a4)+	*RADR
	sub.l	a1,d5		*
	lsr.w	#1,d5		*
	move.w	d5,(a4)+	*RX
	move.w	d4,(a4)+	*PREVY

	cmpa.l	a3,a4		*キューが一杯になったら
	beq	drop		*　いま登録したシードを捨てる

	cmpa.l	BUFEND(a6),a4	*キューの書き込み位置が
	bcs	snext		*　バッファ末尾に達したら
	movea.l	BUFTOP(a6),a4	*　先頭を指すよう修正する

snext:	tst.w	d3		*走査範囲の右端に達するまで
	bpl	sloop1		*　繰り返す

sdone:	rts

drop:	lea.l	-SEEDSIZ(a4),a4	*いま登録したシードを捨てる
	rts

	.end
