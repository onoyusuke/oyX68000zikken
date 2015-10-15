*	256色モード用簡易簡易お絵書きツール

	.include	doscall.mac
	.include	iocscall.mac
*
CFKEYMOD	equ	14	*CONCTRLモード番号
CSCREEN		equ	16	*
CCURON		equ	17	*
CCUROFF		equ	18	*
*
HIDEFKEY	equ	3	*ファンクションキー行非表示
DOS_GM3		equ	4	*画面モード512x512,256色
*
DISABLESKEY	equ	0	*ソフトウェアキーボード禁止
ENABLESKEY	equ	-1	*ソフトウェアキーボード許可
*
GVRAMUSEMD	equ	0	*TGUSEMDの検査/設定対象はG-VRAM
CHECKUSEMD	equ	-1	*検査
USING		equ	2	*使用中
BROKEN		equ	3	*使用後
*
WINH		equ	272	*メニューウィンドウ幅
WINV		equ	104	*メニューウィンドウ高さ
*
USERPAGE	equ	1	*描画を行う画面
BIT_USERPAGE	equ	%0010	*
MENUPAGE	equ	0	*メニューを表示する画面
BIT_MENUPAGE	equ	%0001	*
*
				*メニュー表示
SHOWMENU	equ	BIT_USERPAGE|BIT_MENUPAGE
				*メニュー非表示
HIDEMENU	equ	BIT_USERPAGE
*
GAIJITOP	equ	$eb9f	*全角外字の先頭文字コード
FONT16		equ	$0008	*8x16,16x16
*
PATMAX		equ	8	*ペンパターンの最大数

*
*	グラフィック描画IOCSデータ受け渡し領域の構造
*
	.offset 0
*
X0:	.ds.w	1	*POINT	*FILL	*BOX
Y0:	.ds.w	1	*	*	*
RETCOL:			*	*	*
X1:	.ds.w	1	*	*	*
POINTBUFSIZ:		*	*	*
Y1:	.ds.w	1		*	*
COL:	.ds.w	1		*	*
FILLBUFSIZ:			*	*
LS:	.ds.w	1			*
BOXBUFSIZ:				*

*
*	フォント読み込み領域の構造
*
	.offset 0
*
XLEN:	.ds.w	1
YLEN:	.ds.w	1
FPAT:	.ds.w	16	*16x16
FNTBUFSIZ:
*
	.text
	.even
*
ent:
	lea.l	inisp(pc),sp		*spを初期化する

	moveq.l	#GVRAMUSEMD,d1		*グラフィック画面は
	moveq.l	#CHECKUSEMD,d2		*　使用可能か？
	IOCS	_TGUSEMD		*
	cmpi.b	#BROKEN,d0		*誰かが使いっぱなし？
	beq	gramok			*　そうなら使える
	tst.b	d0			*誰も使っていない？
	bne	quit			*　誰かが使っていた

gramok:	moveq.l	#USING,d2		*グラフィック画面の使用を宣言する
	IOCS	_TGUSEMD		*

	bsr	init			*画面などの初期化

	pea.l	break(pc)		*中断時の戻りアドレスを設定
	move.w	#_CTRLVC,-(sp)		*
	DOS	_INTVCS			*
	move.w	#_ERRJVC,(sp)		*
	DOS	_INTVCS			*
	addq.l	#6,sp			*

	bsr	setupmenu		*メニューウィンドウの初期化
	bsr	main			*メイン処理

break:	bsr	windup			*後始末

	move.w	#-1,-(sp)		*キーバッファクリア
	DOS	_KFLUSH			*
	addq.l	#2,sp			*

quit:	DOS	_EXIT			*終了

*
*	メイン処理
*
main:
	IOCS	_MS_GETDT		*ボタンの状態を取得
	tst.b	d0			*右ボタンが押されている？
	bne	rdown
	tst.w	d0			*左ボタンが押されている？
	bpl	main
*
ldown:				*左ボタンが押された
	IOCS	_MS_CURGT		*マウスカーソル位置を取得
	move.w	d0,d1			*d1.w = y
	clr.w	d0
	swap.w	d0			*d0.w = x
	tst.b	menuflag		*ウィンドウは表示中か？
	beq	pset

	move.w	winx(pc),d2		*d2.w = ウィンドウ表示位置x
	move.w	winy(pc),d3		*d3.w = ウィンドウ表示位置y

	cmp.w	d2,d0			*ウィンドウ上かどうかチェック
	bcs	pset			*
	cmp.w	d3,d1			*
	bcs	pset			*
	addi.w	#WINH,d2		*
	addi.w	#WINV,d3		*
	cmp.w	d2,d0			*
	bcc	pset			*
	cmp.w	d3,d1			*
	bcc	pset			*

				*ウィンドウ内でクリックされた
	sub.w	winx(pc),d0		*d0.w = ローカルx座標
	sub.w	winy(pc),d1		*d1.w = ローカルy座標
	move.w	d0,pntbuf+X0		*x,yそれぞれを待避しておく
	move.w	d1,pntbuf+Y0		*

	subq.w	#8,d0
	bcs	drag			*ウィンドウの左余白
	subq.w	#8,d1
	bcs	drag			*ウィンドウの上余白
	cmp.w	#256,d0
	bcc	drag			*ウィンドウの右余白
	cmp.w	#16,d1
	bcc	ldown1
				*上段のメニュー内
	cmp.w	#224,d0
	bcs	ldown0
done:				*終了ボックス内
	rts				*メインループを抜ける

ldown0:	subi.w	#32,d0
	bcs	drag			*ペンメニューより左
	divu.w	#24,d0
	swap.w	d0
	cmpi.w	#16,d0
	bcc	drag			*ペンパターンの隙間の余白
	swap.w	d0
*
selpen:				*ペンメニュー内
	move.w	d0,d2			*d2.w = ペン番号
	addi.w	#GAIJITOP,d0		*新パターンを設定
	move.w	d0,curpat		*

	moveq.l	#MENUPAGE,d1		*メニュー用ページに
	IOCS	_APAGE			*　切り換える

	lea.l	curpen(pc),a1		*以前の枠を消す
	move.w	#255,COL(a1)		*
	IOCS	_BOX			*

	mulu.w	#24,d2			*新たに枠を描く
	addi.w	#38,d2			*
	move.w	d2,X0(a1)		*
	addi.w	#19,d2			*
	move.w	d2,X1(a1)		*
	move.w	#1,COL(a1)		*
	IOCS	_BOX			*

	bsr	lwait			*左ボタンが離されるのを待つ

	bra	ldown2			*描画用ページに戻す

ldown1:	subi.w	#24,d1
	bcs	drag			*ペンメニューと
					*　色メニューの隙間の余白
	cmpi.w	#64,d1
	bcc	drag			*ウィンドウの下余白
*
selcol:				*色メニュー内
	moveq.l	#MENUPAGE,d1		*メニュー用ページに
	IOCS	_APAGE			*　切り換える

scloop:	lea.l	pntbuf(pc),a1		*マウスカーソル位置から
	IOCS	_POINT			*　色を拾う
	move.w	RETCOL(a1),d0		*
	move.w	d0,curcol		*カレントカラーにセット

	lea.l	coldat(pc),a1		*カレントカラーで
	move.w	d0,COL(a1)		*　メニュー左上の枠を
	IOCS	_FILL			*　塗り潰す

	IOCS	_MS_GETDT		*左ボタンが押されているあいだ
	tst.w	d0			*　繰り返す
	bpl	ldown2			*
					*
	IOCS	_MS_CURGT		*
	sub.w	winy(pc),d0		*
	move.w	d0,pntbuf+Y0		*
	swap.w	d0			*
	sub.w	winx(pc),d0		*
	move.w	d0,pntbuf+X0		*
					*
	bra	scloop			*

ldown2:	moveq.l	#USERPAGE,d1		*描画用ページに戻す
	IOCS	_APAGE			*

	bra	main			*メインループへ
*
drag:				*ウィンドウの外枠でクリックされた
	bsr	lwait			*左ボタンが離されるのを待つ
	bra	menuon			*ウィンドウを描き直す
*
pset:				*ウィンドウ外でクリックされた
	lea.l	setdat(pc),a1		*マウスカーソルの位置に
	subq.w	#8,d0			*　パターンを描く
	move.w	d0,X0(a1)		*
	subq.w	#8,d1			*
	move.w	d1,Y0(a1)		*
	IOCS	_SYMBOL			*

	bra	main			*メインループへ
*
rdown:				*右ボタンが押された
	move.l	#(WINH/2)<<16,ofst	*表示位置オフセット
	tst.b	menuflag		*メニューは表示中か？
	beq	menuon
*
menuoff:			*メニューウィンドウを消す
	sf.b	menuflag		*フラグを寝かせる
	moveq.l	#HIDEMENU,d1		*メニューページ非表示
	IOCS	_VPAGE			*

	bsr	rwait			*右ボタンが離されるのを待つ

	bra	main			*メインループへ
*
menuon:				*メニューウィンドウを出す
	st.b	menuflag		*フラグを立てる
	IOCS	_MS_CURGT		*マウスカーソル位置を取得
	move.w	d0,d1			*d1.w = y
	swap.w	d0			*d0.w = x

	sub.w	ofst+X0(pc),d0		*ウィンドウが
	bcc	mon0			*　画面からはみ出さないよう
	clr.w	d0			*　調整する
mon0:	sub.w	ofst+Y0(pc),d1		*
	bcc	mon1			*
	clr.w	d1			*
mon1:	cmp.w	#512-WINH,d0		*
	bcs	mon2			*
	move.w	#512-WINH,d0		*
mon2:	cmp.w	#512-WINV,d1		*
	bcs	mon3			*
	move.w	#512-WINV,d1		*

mon3:	move.w	d0,winx			*表示位置を格納
	move.w	d1,winy			*

	moveq.l	#0,d2			*ウィンドウを目的の位置へ
	sub.w	d0,d2			*　移動する
	andi.w	#511,d2			*
	moveq.l	#0,d3			*
	sub.w	d1,d3			*
	andi.w	#511,d3			*
	moveq.l	#BIT_MENUPAGE,d1	*
	IOCS	_HOME			*

	moveq.l	#SHOWMENU,d1		*メニューページ表示
	IOCS	_VPAGE			*

	bsr	rwait			*右ボタンが離されるのを待つ

	bra	main			*メインループへ

*
rwait:				*右ボタンが離されるのを待つ
	IOCS	_MS_GETDT
	tst.b	d0
	bne	rwait
	rts
*
lwait:				*左ボタンが離されるのを待つ
	IOCS	_MS_GETDT
	tst.w	d0
	bmi	lwait
	rts

*
*	初期化
*
init:
	link	a6,#0
				*画面
	move.w	#DOS_GM3,-(sp)		*画面を512x512,256色に
	move.w	#CSCREEN,-(sp)		*　初期化
	DOS	_CONCTRL		*
	move.w	d0,scrnmsav		*現在の画面モードを待避

	move.w	#HIDEFKEY,-(sp)		*ファンクションキー行を
	move.w	#CFKEYMOD,-(sp)		*　非表示に設定
	DOS	_CONCTRL		*
	move.w	d0,fkeymsav		*現在のファンクションキー行
					*　モードを待避

	move.w	#CCUROFF,-(sp)		*カーソル非表示モード
	DOS	_CONCTRL		*

				*外字
	bsr	savfont			*待避
	bsr	deffont			*定義

				*マウス
	IOCS	_MS_INIT		*マウス初期化
	IOCS	_MS_CURON		*マウスカーソル表示
	moveq.l	#DISABLESKEY,d1		*ソフトウェアキーボードの
	IOCS	_SKEY_MOD		*　使用を禁止

	unlk	a6
	rts

*
*	メニューの初期化
*	（あらかじめ全部描いておく)
*
setupmenu:
	moveq.l	#MENUPAGE,d1		*メニュー用ページに
	IOCS	_APAGE			*　切り換える

	moveq.l	#HIDEMENU,d1		*メニュー用ページ非表示
	IOCS	_VPAGE			*

	lea.l	fildat(pc),a1		*ウィンドウ枠を塗り潰す
	IOCS	_FILL			*

	lea.l	boxes(pc),a1		*BOXを必要なだけ描く
boxlp:	tst.w	(a1)			*
	bmi	boxed			*
	IOCS	_BOX			*
	lea.l	BOXBUFSIZ(a1),a1	*
	bra	boxlp			*

boxed:	lea.l	mendat(pc),a1		*ペンパターンメニューを
	IOCS	_SYMBOL			*　描く

	bsr	makecoltbl		*カラーテーブル

	moveq.l	#USERPAGE,d1		*描画用ページに切り換える
	IOCS	_APAGE			*

	sf.b	menuflag		*フラグを寝かせる

	rts

*
*	256色の色テーブルを描く
*
makecoltbl:
	link	a6,#-FILLBUFSIZ

	lea.l	-FILLBUFSIZ(a6),a1	*a1 = FILL用引数領域

	moveq.l	#0,d1			*d1 = 色

	move.w	#32,Y0(a1)		*最初は(8,32)-(8+7,32+7)から
	move.w	#32+7,Y1(a1)		*

	moveq.l	#8-1,d6			*縦に８個
clp0:	move.w	#8,X0(a1)
	move.w	#8+7,X1(a1)

	moveq.l	#32-1,d7		*横に32個
clp1:	move.w	d1,COL(a1)		*四角を描く
	IOCS	_FILL			*

	addq.w	#8,X0(a1)		*右に８ピクセル移動
	addq.w	#8,X1(a1)		*
	addq.w	#1,d1			*次の色
	dbra	d7,clp1			*横１列分繰り返す

	addq.w	#8,Y0(a1)		*下に８ピクセル移動
	addq.w	#8,Y1(a1)		*
	dbra	d6,clp0			*繰り返す

	unlk	a6
	rts

*
*	後始末
*
windup:
	link	a6,#0

	move.w	scrnmsav(pc),-(sp)	*画面モードを戻す
	move.w	#CSCREEN,-(sp)		*
	DOS	_CONCTRL		*

	move.w	fkeymsav(pc),-(sp)	*ファンクションキー行の
	move.w	#CFKEYMOD,-(sp)		*　モードを戻す
	DOS	_CONCTRL		*

	move.w	#CCURON,-(sp)		*カーソル表示モード
	DOS	_CONCTRL		*

	bsr	rstfont			*外字フォント復帰

	IOCS	_MS_INIT		*マウス初期化
	moveq.l	#ENABLESKEY,d1		*ソフトウェアキーボードの
	IOCS	_SKEY_MOD		*　使用を許可

	moveq.l	#GVRAMUSEMD,d1		*G-VRAM内容は破壊した
	moveq.l	#BROKEN,d2		*
	IOCS	_TGUSEMD		*

	unlk	a6
	rts

*
*	外字の先頭８文字のフォントパターンを待避する
*
savfont:
	lea.l	fontbuf(pc),a1
	move.l	#FONT16<<16|GAIJITOP,d1
	moveq.l	#PATMAX-1,d2
savlp:	IOCS	_FNTGET
	addq.w	#1,d1
	lea.l	FNTBUFSIZ(a1),a1
	dbra	d2,savlp
	rts

*
*	外字の先頭８文字にフォントパターンを設定する
*
deffont:
	lea.l	fontdat+FPAT(pc),a1
defnt0:	move.l	#FONT16<<16|GAIJITOP,d1
	moveq.l	#PATMAX-1,d2
deflp:	IOCS	_DEFCHR
	addq.w	#1,d1
	lea.l	FNTBUFSIZ(a1),a1
	dbra	d2,deflp
	rts

*
*	savfontで待避したフォントパターンを復帰する
*
rstfont:
	lea.l	fontbuf+FPAT(pc),a1
	bra	defnt0

*
*	データ＆ワーク
*
	.data
	.even
*
fontdat:
	.dc.w	16,16			*eb9f
	.dc.w	%0000000000000000	*0
	.dc.w	%0000000000000000
	.dc.w	%0000000000000000
	.dc.w	%0011111110111111
	.dc.w	%0010000001010001
	.dc.w	%0001000001010010
	.dc.w	%0001000000101100
	.dc.w	%0000100000101000
	.dc.w	%0000100000010000
	.dc.w	%0000010000010000
	.dc.w	%0000010000001000
	.dc.w	%0000101000001000
	.dc.w	%0001101000000100
	.dc.w	%0010010100000100
	.dc.w	%0100010100000010
	.dc.w	%0111111011111110

	.dc.w	16,16			*eba0
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0080,$0000,$0000,$0000,$0000,$0000,$0000,$0000

	.dc.w	16,16			*eba1
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0180
	.dc.w	$0180,$0000,$0000,$0000,$0000,$0000,$0000,$0000

	.dc.w	16,16			*eba2
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$01c0
	.dc.w	$01c0,$01c0,$0000,$0000,$0000,$0000,$0000,$0000

	.dc.w	16,16			*eba3
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0410,$0220,$0140
	.dc.w	$0080,$0140,$0220,$0410,$0000,$0000,$0000,$0000

	.dc.w	16,16			*eba4
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0c00,$0600,$0300
	.dc.w	$0180,$00c0,$0060,$0030,$0000,$0000,$0000,$0000

	.dc.w	16,16			*eba5
	.dc.w	$0000,$03e0,$07f0,$0ff8,$1ffc,$3ffe,$7fff,$7fff
	.dc.w	$7fff,$7fff,$7fff,$3ffe,$1ffc,$0ff8,$07f0,$03e0

	.dc.w	16,16			*eba6
	.dc.w	$0000,$7fff,$7fff,$7fff,$7fff,$7fff,$7fff,$7fff
	.dc.w	$7fff,$7fff,$7fff,$7fff,$7fff,$7fff,$7fff,$7fff

fildat:	.dc.w	0,0			*ウィンドウ枠塗り潰し用
	.dc.w	WINH-1,WINV-1
	.dc.w	255

boxes:					*ウィンドウ内枠描画用
box1:	.dc.w	2,2,WINH-2-1,WINV-2-1,1,$ffff
box2:	.dc.w	6,6,33,25,1,$ffff
curpen:
box3:	.dc.w	38,6,57,25,1,$ffff	*カレントペンを示す枠
box4:	.dc.w	230,6,265,25,1,$ffff
box5:	.dc.w	6,30,265,97,1,$ffff
	.dc.w	-1

mendat:	.dc.w	40,8			*メニュー表示用
	.dc.l	patstr
	.dc.b	1,1
	.dc.w	1
	.dc.b	1,0

coldat:	.dc.w	8,8,31,23,255		*カレントカラー表示用

setdat:	.dc.w	0,0			*点描画用
	.dc.l	curpat
	.dc.b	1,1
curcol:	.dc.w	255
	.dc.b	1,0

curpat:	.dc.b	$eb,$9f,0		*カレントペンパターン

patstr:	.dc.b	$eb,$9f,$20,$eb,$a0,$20	*メニュー文字列
	.dc.b	$eb,$a1,$20,$eb,$a2,$20
	.dc.b	$eb,$a3,$20,$eb,$a4,$20
	.dc.b	$eb,$a5,$20,$eb,$a6,$20
	.dc.b	'終了',0
*
	.bss
	.even
*
fontbuf:	.ds.b	FNTBUFSIZ*8	*フォント待避領域
ofst:
pntbuf:		.ds.b	POINTBUFSIZ	*IOCS POINT用
winx:		.ds.w	1		*メニューウィンドウ表示位置
winy:		.ds.w	1		*
scrnmsav:	.ds.w	1		*画面モード待避用
fkeymsav:	.ds.w	1		*ファンクションキー行モード待避用
menuflag:	.ds.b	1		*メニュー表示/非表示フラグ
*
	.stack
	.even
*
	.ds.l	1024		*スタック領域
inisp:
	.end	ent
