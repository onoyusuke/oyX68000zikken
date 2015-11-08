*	定数定義ファイル

*
*	コントロールコード
*
NULL		equ	0	*^@
BELL		equ	$07	*^G
BS		equ	$08	*^H
TAB		equ	$09	*^I
LF		equ	$0a	*^J
CR		equ	$0d	*^M
EOF		equ	$1a	*^Z
ESC		equ	$1b	*^[
SPACE		equ	$20	*スペース

*
*	標準ファイルハンドル
*
STDIN		equ	0	*標準入力
STDOUT		equ	1	*標準出力
STDERR		equ	2	*標準エラー出力
STDAUX		equ	3	*標準補助装置
STDPRN		equ	4	*標準プリンタ

*
*	ファイルアクセスモード
*
ROPEN		equ	0	*読み込み用
WOPEN		equ	1	*書き出し用
RWOPEN		equ	2	*読み書き両用

*
*	ファイル属性
*
ARCHIVE		equ	$20	*ふつうのファイル
SUBDIR		equ	$10	*ディレクトリ
VOLUME		equ	$08	*ボリューム名
SYSTEM		equ	$04	*システムファイル
HIDDEN		equ	$02	*不可視ファイル
READONLY	equ	$01	*読み込み専用ファイル
