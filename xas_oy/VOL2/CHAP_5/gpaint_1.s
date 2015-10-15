*	シードフィルによる領域の塗り潰し（第１版）

	.include	gconst.h
	.include	gmacro.h
	.include	rect.h
*
	.xdef	gpaint
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
	.offset	-8	*スタックフレーム
WORKSIZ:
BUFTOP:	.ds.l	1
BUFEND:	.ds.l	1
_a6:	.ds.l	1
_pc:	.ds.l	1
ARGPTR:	.ds.l	1
*
	.offset	0	*シード候補
*
ADR:	.ds.l	1
X:	.ds.w	1
Y:	.ds.w	1
SEEDSIZ:
*
	.text
	.even
*
gpaint:
	link	a6,#WORKSIZ
	movem.l	d0-d7/a0-a5,-(sp)

	lea.l	cliprect,a5	*a5=クリッピング領域
	movea.l	ARGPTR(a6),a1	*a1=引数列

	movem.w	X0(a1),d0-d1	*(d0,d1)=初期シード
	cmp.w	MINX(a5),d0	*初期シードが
	blt	done		*　ウィンドウ外なら
	cmp.w	MINY(a5),d1	*　何もせずに戻る
	blt	done		*
	cmp.w	MAXX(a5),d0	*
	bgt	done		*
	cmp.w	MAXY(a5),d1	*
	bgt	done		*

	jsr	gramadr		*a0=初期シードG-RAMアドレス

	move.w	(a0),d6		*d6=領域色

	move.w	COL(a1),d7	*d7=描画色
	cmp.w	d6,d7		*描画色と領域色が等しいなら
	beq	done		*　何もせずに戻る

	movea.l	TEMP(a1),a3	*a3=キュー内の読み出し位置
	movea.l	a3,a4		*a4=キュー内の書き込み位置
				*（ともにバッファ先頭に初期化）

	move.l	TEMPED(a1),d3	*d3=バッファ末尾+1
	sub.l	a3,d3		*バッファ先頭＜末尾ならば
	bcs	done		*　何もせずに戻る
	andi.l	#$ffff_fff0,d3	*d3=バッファサイズ（16の倍数）
	beq	done		*バッファサイズが０ならば
				*　何もせずに戻る
	add.l	a3,d3		*d3=バッファ末尾+1

	move.l	a3,BUFTOP(a6)	*バッファ先頭と末尾を
	move.l	d3,BUFEND(a6)	*　ワークに格納しておく

	bra	do		*メイン処理開始

loop:	movea.l	(a3)+,a0	*キューからシードを
	move.w	(a3)+,d0	*　取り出す
	move.w	(a3)+,d1	*

do:
*	d0	シードx座標
*	d1	シードy座標
*	d6	領域色
*	d7	描画色
*	a0	シードG-RAMアドレス
*	a3	キュー内のつぎの読み出し位置
*	a4	キュー内のつぎの書き込み位置
*	a5	クリッピング領域

	movea.l	a0,a1		*a0=a1=シードのG-RAMアドレス
	move.w	d0,d2		*d0=d2=シードのx座標

	cmp.w	(a1)+,d6	*すでに処理済みのシードならば
	bne	next		*　捨てる

			*右方向の境界を探す
rchk:	move.w	MAXX(a5),d3	*d3=ウィンドウ右端x座標
				*d2=x1
rloop:	cmp.w	d3,d2		*ウィンドウ右端に達したら
	bge	lchk		*　その直前の点が右の境界
	addq.w	#1,d2		*x1++
	cmp.w	(a1)+,d6	*(x1,y)が領域色のあいだ
	beq	rloop		*　繰り返す

	subq.w	#1,d2		*d2=x1

			*左方向の境界を探す
lchk:	move.w	MINX(a5),d3	*d3=ウィンドウ左端x座標
				*d0=x0
lloop:	cmp.w	d3,d0		*ウィンドウ右端に達したら
	ble	filspn		*　その直前の点が左の境界
	subq.w	#1,d0		*x0--
	cmp.w	-(a0),d6	*(x0,y)が領域色のあいだ
	beq	lloop		*　繰り返す

	addq.w	#1,d0		*d0=x0
	addq.l	#2,a0		*a0=(x0,y)のG-RAMアドレス

filspn:	sub.w	d0,d2		*d2=線分のピクセル数-1
	movea.l	a0,a2		*a0=a2=線分左端G-RAMアドレス

	move.w	d2,d3		*線分(x0,y)-(x1,y)を描く
floop:	move.w	d7,(a0)+	*
	dbra	d3,floop	*

	move.w	d0,d4		*d0=d4=x0（線分左端x座標）
	subq.w	#1,d4		*d4=x0-1

			*真上のスキャンラインを走査する
uchk:	subq.w	#1,d1		*y--
	cmp.w	MINY(a5),d1	*ウィンドウの上端を越えていたら
	blt	dchk		*　走査の必要はない
	lea.l	-GNBYTE(a2),a0	*a0=走査するライン左端
	bsr	seapix		*走査する

			*真下のスキャンラインを走査する
dchk:	addq.w	#1+1,d1		*y++
	cmp.w	MAXY(a5),d1	*ウィンドウの下端を越えていたら
	bgt	next		*　走査の必要はない
	lea.l	GNBYTE(a2),a0	*a0=走査するライン左端
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
	move.w	d4,d0		*d0=走査開始x座標-1
	move.w	d2,d3		*d3=線分のピクセル数-1
sloop1:	addq.w	#1,d0		*非領域色部分を飛ばす
	cmp.w	(a0)+,d6	*
	dbeq	d3,sloop1	*
	beq	spix0		*領域色が見つかった
	rts			*領域色は見つからなかった

sloop2:	addq.w	#1,d0		*領域色部分を飛ばす
	cmp.w	(a0)+,d6	*
spix0:	dbne	d3,sloop2	*
	beq	spix1		*
	subq.l	#2,a0		*ポインタとx座標は
	subq.w	#1,d0		*　進み過ぎている

spix1:	subq.l	#2,a0		*a0=領域色部分の右端
	move.l	a0,(a4)+	*見つけたシード候補を
	move.w	d0,(a4)+	*　バッファに登録する
	move.w	d1,(a4)+	*
	addq.l	#2,a0		*つぎの走査に備える

	cmpa.l	a3,a4		*キューが一杯になったら
	beq	drop		*　いま登録したシードを捨てる

	cmpa.l	BUFEND(a6),a4	*キューの書き込み位置が
	bcs	snext		*　バッファ末尾に達したら
	movea.l	BUFTOP(a6),a4	*　先頭を指すよう修正する

snext:	tst.w	d3		*走査範囲の右端に達するまで
	bpl	sloop1		*　繰り返す

sdone:	rts

drop:	subq.l	#SEEDSIZ,a4	*いま登録したシードを捨てる
	rts

	.end
