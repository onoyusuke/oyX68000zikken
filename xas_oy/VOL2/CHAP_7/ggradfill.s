*	グラデーションによる矩形の塗り潰し

	.include	gconst.h
	.include	gmacro.h
*
	.xdef	ggradfill
	.xref	gramadr
	.xref	gcliprect

*
*	誤差の累積を考慮して色を決定するマクロ（１色分）
*
PROC1	macro	COL
	move.w	COL,d1		*d1 = 現在の8192階調の色
	add.w	(a4)+,d1	*　＋周囲からの誤差
	ror.w	#8,d1		*d1.b = 32階調の色
	or.b	d1,d0		*カラーコードに構成していく
	clr.b	d1		*d1.w = 8192階調から32階調に
	rol.w	#8,d1		*　落とすときの切り捨て分
	move.w	#8-1,d2
	and.w	d1,d2		*d2 = 誤差 mod 8
	lsr.w	#3,d1		*d1 = 誤差/8
	add.w	d1,d2		*
	add.w	d2,(a5)+	*真下に誤差の1/8+端数
	move.w	d1,6-2(a5)	*右下に誤差の1/8
	add.w	d1,d1		*
	add.w	d1,-6-2(a5)	*左下に誤差の2/8
	add.w	d1,d1		*
	add.w	d1,6-2(a4)	*右に誤差の4/8
	.endm

*
*	Bresenhamのアルゴリズムによりつぎの色を求めるマクロ
*
PROC2	macro	COL,P
	local	loop,skip
	lea.l	P(a6),a0	*a0 = パラメータ列（PARBUF）
	move.w	(a0),d0		*d0 = 誤差項
	add.w	D(a0),d0	*誤差項に増分を加える
	ble	skip		*
	move.w	S(a0),d1	*d1 = 色の増加方向
	move.w	HC(a6),d2	*d2 = 誤差項の補正値
loop:	add.w	d1,COL		*色を更新する
	sub.w	d2,d0		*誤差項を補正する
	bgt	loop		*誤差項が０以下になるまで繰り返す
skip:	move.w	d0,(a0)		*誤差項を更新する
	.endm
*
	.offset	0	*ggradfillの引数構造
*
X0:	.ds.w	1	*描画先座標
Y0:	.ds.w	1	*
X1:	.ds.w	1	*
Y1:	.ds.w	1	*
*COL:	.ds.w	1	*置換対象の色
COL1:	.ds.w	1	*左上隅の色
COL2:	.ds.w	1	*左下隅の色
COL3:	.ds.w	1	*右上隅の色
COL4:	.ds.w	1	*右下隅の色
BUFF:	.ds.l	1	*作業用メモリ（最大12Ｋバイト強）
*
	.offset	0	*２色のrgb展開結果
*
BB0:	.ds.b	1	*色１(３)
RR0:	.ds.b	1	*
GG0:	.ds.b	1	*
BB1:	.ds.b	1	*色２(４)
RR1:	.ds.b	1	*
GG1:	.ds.b	1	*
RGB2BUF:
*
	.offset	0	*水平方向補間時のBresenhamパラメータ
*
E:	.ds.w	1	*誤差項
D:	.ds.w	1	*増分
S:	.ds.w	1	*符号
PARBUF:
*
	.offset	-RGB2BUF*2-2*4-PARBUF*3-2*2
			*スタックフレーム
*
WORKTOP:
C12:	.ds.b	RGB2BUF	*色1, 2のrgb分解結果
C34:	.ds.b	RGB2BUF	*色3, 4のrgb分解結果
HE:	.ds.w	1	*水平方向補間時の誤差項初期値
HC:	.ds.w	1	*水平方向補間時の誤差項補正値
VE:	.ds.w	1	*垂直方向補間時の誤差項初期値
VC:	.ds.w	1	*垂直方向補間時の誤差項初期値
BBUF:	.ds.b	PARBUF	*青水平方向補間用Bresenhamパラメータ
RBUF:	.ds.b	PARBUF	*赤水平方向補間用Bresenhamパラメータ
GBUF:	.ds.b	PARBUF	*緑水平方向補間用Bresenhamパラメータ
ROFS:	.ds.w	1	*赤の垂直方向補間データへのオフセット
GOFS:	.ds.w	1	*赤の垂直方向補間データへのオフセット
_A6:	.ds.l	1	*±0
_PC:	.ds.l	1
ARGPTR:	.ds.l	1	*引数列
*
	.text
	.even
*
ggradfill:
	link	a6,#WORKTOP
	movem.l	d0-d7/a0-a5,-(sp)

	movea.l	ARGPTR(a6),a1	*a1 = 引数列
	movem.w	(a1)+,d0-d3	*d0～d3に座標を取り出す

	jsr	gcliprect	*クリッピングする
	bmi	done		*N=1なら描画の必要なし

	jsr	gramadr		*左上のG-RAM上のアドレスを得る

	sub.w	d0,d2		*d2 = 横ピクセル数-1
	sub.w	d1,d3		*d3 = 縦ピクセル数-1

*	swap.w	d3		*d3 = 置換対象の色
*	move.w	(a1)+,d3	*
*	swap.w	d3		*

	lea.l	C12(a6),a3	*４色をrgbに分解しておく
	moveq.l	#4-1,d7		*
iloop:	move.w	(a1)+,d0	*
	DERGB	d0,d4,d5,d6	*
	move.b	d4,(a3)+	*
	move.b	d5,(a3)+	*
	move.b	d6,(a3)+	*
	dbra	d7,iloop	*

	move.w	d2,d4		*水平/垂直の色補間用の
	move.w	d2,d5		*　誤差項/補正値を求める
	move.w	d3,d6		*
	move.w	d3,d7		*
	neg.w	d4		*
	add.w	d5,d5		*
	neg.w	d6		*
	add.w	d7,d7		*
	move.w	d4,HE(a6)	*
	move.w	d5,HC(a6)	*
	move.w	d6,VE(a6)	*
	move.w	d7,VC(a6)	*

	addq.w	#2,d7		*d7 = 垂直補間したテーブル１色分サイズ
	move.w	d7,ROFS(a6)	*青のテーブルと赤のテーブルの差
	add.w	d7,d7		*
	move.w	d7,GOFS(a6)	*青のテーブルと緑のテーブルの差

	movea.l	(a1),a1		*a1 = 作業用領域

	lea.l	C12(a6),a4	*COL1～COL2を補間
	movea.l	a1,a2		*
	bsr	genvtbl		*

	lea.l	C34(a6),a4	*COL3～COL4を補間
	movea.l	a1,a3		*
	bsr	genvtbl		*

	lea.l	6(a1),a4	*a4 = 誤差格納用バッファ１

	moveq.l	#0,d0		*誤差格納用バッファをクリア
	move.w	d2,d4		*
	addq.w	#2,d4		*
cloop:	move.l	d0,(a1)+	*
	move.w	d0,(a1)+	*
	dbra	d4,cloop	*

	movea.l	a1,a5		*a5 = 誤差格納用バッファ２
loop1:	moveq.l	#0,d0		*誤差格納用バッファの先頭をクリア
	move.l	d0,(a5)		*
	move.w	d0,4(a5)	*

	move.w	HE(a6),d1	*d1 = 水平方向色補間時の誤差項初期値

	move.w	GOFS(a6),d0	*
	move.w	0(a2,d0),d4	*d4 = g0
	move.w	0(a3,d0),d5	*d5 = g1
	lea.l	GBUF(a6),a1	*
	bsr	hinit		*
	move.w	d4,d7		*d7 = g0

	move.w	ROFS(a6),d0	*
	move.w	0(a2,d0),d4	*d4 = r0
	move.w	0(a3,d0),d5	*d5 = r1
	lea.l	RBUF(a6),a1	*
	bsr	hinit		*
	move.w	d4,d6		*d6 = r0

	move.w	(a2)+,d4	*d4 = b0
	move.w	(a3)+,d5	*d5 = b1
	lea.l	BBUF(a6),a1	*
	bsr	hinit		*
	move.w	d4,d5		*d5 = b0

	movea.l	a0,a1		*a1 = 描画先ライン左端

	move.w	d2,d4		*d4 = 矩形の幅-1 = ループカウンタ
	swap.w	d1
	swap.w	d2
*	swap.w	d3
	movem.l	a0/a4-a5,-(sp)
loop2:	moveq.l	#0,d0		*誤差の累積を考慮して描画色を決める
	PROC1	d7		*g
	lsl.w	#5,d0		*
	PROC1	d6		*r
	lsl.w	#5,d0		*
	PROC1	d5		*b
	add.w	d0,d0		*

*	cmp.w	(a1),d3		*置換対象色？
*	beq	skip		*
*	move.w	(a1),d0		*ダミー
skip:	move.w	d0,(a1)+	*１ピクセル描画

	PROC2	d5,BBUF		*色を更新する
	PROC2	d6,RBUF		*
	PROC2	d7,GBUF		*

	dbra	d4,loop2	*横幅分繰り返す
	movem.l	(sp)+,a0/a4-a5
	swap.w	d1
	swap.w	d2
*	swap.w	d3

	exg.l	a4,a5		*誤差格納用バッファを交換する
	lea.l	GNBYTE(a0),a0	*つぎのラインへ
	dbra	d3,loop1	*高さ分繰り返す

done:	movem.l	(sp)+,d0-d7/a0-a5
	unlk	a6
	rts

*
*	垂直方向に色を補間してテーブルを作成する
*
genvtbl:
	move.b	BB0(a4),d0	*青成分を補間
	move.b	BB1(a4),d1	*
	bsr	gsub		*

	move.b	RR0(a4),d0	*赤成分を補間
	move.b	RR1(a4),d1	*
	bsr	gsub		*

	move.b	GG0(a4),d0	*緑成分を補間
	move.b	GG1(a4),d1	*
*	bsr	gsub		*
*
gsub:	lsl.w	#8,d0		*精度確保のため256倍スケーリング
	lsl.w	#8,d1		*（32階調→8192階調）

	sub.w	d0,d1		*Bresenhamのアルゴリズムのための初期化
	move.w	d1,d4		*
	ABS	d1		*
	SGN	d4		*
	add.w	d1,d1		*
	move.w	VE(a6),d5	*
	move.w	VC(a6),d6	*
	bne	fix0		*矩形の高さが１ピクセルしかなかった場合の
	moveq.l	#0,d1		*　つじつま合わせ

fix0:	move.w	d3,d7		*d7 = 矩形の高さ-1 = ループカウンタ
gloop1:	move.w	d0,(a1)+	*Bresenhamのアルゴリズムで色を補間する
	add.w	d1,d5		*
	ble	gskip		*
gloop2:	add.w	d4,d0		*
	sub.w	d6,d5		*
	bgt	gloop2		*
gskip:	dbra	d7,gloop1	*
	rts

*
*	水平方向の色補間のための初期化
*
hinit:	sub.w	d4,d5
	move.w	d5,d0
	ABS	d5
	SGN	d0
	add.w	d5,d5
	move.w	d1,(a1)+	*誤差項初期値
	bne	fix1
	moveq.l	#0,d5
fix1:	move.w	d5,(a1)+	*誤差項増分
	move.w	d0,(a1)+	*符号
	rts

	.end
