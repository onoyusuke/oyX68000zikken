* cのライブラリとリンクする必要があるので、ccでコンパイルし、rename printf.x printf.fnc と名前を変える。

* X-BASICの外部関数としてprintfを作る(コンソール専用)
* 実際は、cの関数を呼び出す。そのためのお膳立てを行うプログラム。
* BASICから変数を受け取る。それらを、スタックに積む。フォーマットに関してはエスケープ文字列を整理しつつ、メモリに書き込み、それへのポインタを積む。そのうえで、Cの関数を呼び出す。



CR EQU $0D
LF EQU $0A
*
	.TEXT
	dc.l	X_INZ
	dc.l	X_RUN
	dc.l	X_END
	dc.l	X_SYSTEM
	dc.l	X_BRK
	dc.l	X_CTRL_D
	dc.l	X_RETADRS
	dc.l	X_RETADRS
	dc.l	PTR_TOKEN
	dc.l	PTR_PARAM
	dc.l	PTR_EXEC
	dc.l	0,0,0,0,0  * 最後の20バイトは0.

* Function Name Table
PTR_TOKEN
	DC.B	'printf',0
	DC.B	0

	.EVEN
* Function Parameteres Table
PTR_PARAM
	dc.l	COM_PARAM

str_val		equ	$0008
any_aryl_omt	equ	$00bf  * $00bf=0000000010111111 (10111111の意味は上位ビットから、1=省略可能. 01=1次元配列. 1=ポインタ. 1111=全ての型)
int_ret		equ	$8001

COM_PARAM
	dc.w	str_val
	dc.w	any_aryl_omt,any_aryl_omt
	dc.w	any_aryl_omt,any_aryl_omt
	dc.w	any_aryl_omt,any_aryl_omt
	dc.w	any_aryl_omt,any_aryl_omt
	dc.w	any_aryl_omt
	dc.w	int_ret

* Fuction Address Table
PTR_EXEC
	dc.l	b_cprintf
X_INZ:
X_RUN:
X_END:
X_SYSTEM:
X_BRK:
X_CTRL_D:
X_RETADRS:
	rts
*
	.TEXT
b_cprintf
*
	move.l	sp,OLD_SP	* save stack
	moveq.l #10-1-1,D7	* ループの回数. 10個の引数のうち最初の引数は書式指定の文字列. 
	lea	96(sp),a1	* a1=type of last param. (4+2)+(2+4+4)×9で96.
*
LOOP1	tst.w	(a1)		* check type
	bpl	LOOP2		* $ffff == omit parapeterでないのならloop2へ
	lea	-10(a1),a1	* a1=a1-10. 一つ前のパラメータ
	dbra	d7,LOOP1
	bra 	DO_IT * formatしかない場合の処理。これがないと次のLOOP2でERRORに飛んでしまう。
* 
LOOP2	move.w	(a1),d0		* get type.
	ext.l	d0		* sign extend 符号拡張
	bmi	ERROR		* if d0==$ffff(引数省略) then error. 
*loop1からbpl LOOP2で飛んでくる場合には、変数の抜けがないという条件で飛んでくるので引っかからない。(s,,k)のような抜けがある場合には、kに関して処理してlea -10(a1),a1してから飛んでくるので引っかかる。
	beq	DO_FLOW		* if d0==0 then float型. 64ビット.
	subq.l	#2,d0
	bmi	DO_INT		* d0==1 int型. そのまま32ビット
	beq	DO_CHR		* d0==2 char型. 符号拡張して32ビットに変換
DO_STR				* d0==3 str型
	move.l	6(a1),a2	* 値(配列へのポインタ)の取り出し. 下位の4バイトなので6=2+4だけ飛ばす.
	pea	10(a2)		* push pointer. 1次元配列のデータ部は10バイトめから始まる. 文字列なのでポインタがデータとして入っている.
	lea	-10(a1),a1	* a1=a1-10. 一つ前のパラメータ
	dbra	d7,LOOP2
	bra	DO_IT
*
DO_CHR
	move.l	6(a1),a2
	move.b	10(a2),d0	* get val. 1次元配列のデータ部は10バイトめから始まる.
*
	ext.w	d0		* sign extend
	ext.l	d0		* sign extend. 2段階の符号拡張で4バイトにする.
*
	move.l	d0,-(sp)	* push val.
	lea	-10(a1),a1	* a1=a1-10. 一つ前のパラメータ
	dbra	d7,LOOP2
	bra	DO_IT
DO_INT
	move.l	6(a1),a2
	move.l	10(a2),-(sp)	* 符号拡張はしないでlong型としてすぐにpush
	lea	-10(a1),a1	* a1=a1-10. 一つ前のパラメータ
	dbra	d7,LOOP2
	bra	DO_IT
DO_FLOW
	move.l	6(a1),a2
	movem.l	10(a2),d0/d1	* 64ビット分を取得. 
	movem.l d0/d1,-(sp)	* 64ビット分をそのままpush.
	lea	-10(a1),a1	* a1=a1-10. 一つ前のパラメータ
	dbra	d7,LOOP2
*
DO_IT				* 先頭の引数(formatを表すstr)の処理
	move.l	6(a1),a1	* これまでと同様6(a1)を読み込むが、それをa1に代入. 以下、a1をformatを呼び出すためのポインタとして使う.
	lea	FSTR,a2		* 整形したformatはFSTRにおいていく。以下、a2をその領域へのポインタとして使う。
	moveq.l	#'\',d6		* \を検出するためにd6を用いる。 
FCONVL
	move.b	(a1)+,d0	* formatから読み込み
	cmp.b	d6,d0		* slash(\)か？
	beq	SLASH		* slashならそれとして処理.
	move.b	d0,(a2)+	* slashでないのならばFSTRにそのまま書き込み
	bne	FCONVL		* formatに文字列が残っているのならそれを処理
	bra	GO_PRINTF	* 全て処理したのならば、printfを呼び出す
*
SLASH	move.b	(a1)+,d0
	cmp.b	#'n',d0		* '\n'?
	beq	DO_N		* then do_n
	moveq.l	#$09,d1		* '\t'のときのために。
	cmp.b	#'t',d0		* '\t'?
	beq	SEND		
	cmp.b	#'7',d0
	bgt	SEND0
	cmp.b	#'0',d0
	blt	SEND0		* 0-7だったら以下. それ以外はsend0へ。
*octal number
	moveq.l	#0,d1		* 結果を入れるレジスタd1の初期化
	moveq.l	#3-1,d2		* カウンター。最大で３桁だから、最大で２回シフト。
OCTLOOP
	sub.b	#'0',d0		* d0に読み込んだ数字のアスキーコードを数値に変換
	asl.b	#3,d1		* d1を8倍する
	add.b	d0,d1
	move.b	(a1)+,d0
	cmp.b	#'7',d0
	bgt	OCTEND
	cmp.b	#'0',d0
	blt	OCTEND		* 0-7だったら桁数をチェック. 0-7以外ならsend0へいき3桁未満での終了。
	dbra	d2,OCTLOOP	* 0-7でも桁数が３桁を超えていたら、次のoctendにいきおしまい。
OCTEND				* 3桁にいたったために終了する.
	move.b	d1,(a2)+	* 結果をFSTRに書き込み.
	subq.l	#1,a1		* 終了条件の判定のためにmove.b (a1)+,d0で１つ余分に取得したのでその分を戻す
	bra	FCONVL
SEND0	move.b	d0,(a2)+	
	bra	FCONVL
SEND	move.b	d1,(a2)+	* '\t'のとき専用か
	bra	FCONVL
DO_N	move.b	#CR,(a2)+
	move.b	#LF,(a2)+
	bra	FCONVL

GO_PRINTF
	pea	FSTR
	jsr	_cprintf	* C関数を呼ぶ
	move.l	OLD_SP,sp
	move.l	d0,INT_DATA	* 戻り値
	lea	RET_DATA,a0
	clr.l	d0		* エラー無し
	rts
*
ERROR	
	move.l	OLD_SP,sp
	moveq.l #1,d0
	lea	MES0,a1
	rts
*
OLD_SP	ds.l	1
*
RET_DATA
	ds.w	1
	ds.l	1
INT_DATA
	ds.l	1

MES0:	dc.b	'パラメータの並びに抜けている部分があります',0
*
FSTR	ds.b	256
*
	.END
