*	rgb(0,0,0)～rgb(31,31,31)の色テーブル（Ｃ用微修正版）

	.xdef	grayscale
	.xdef	_grayscale
*
	.data
	.even
*
grayscale:
_grayscale:
	.dc.w	$0000,$0842,$1084,$18c6
	.dc.w	$2108,$294a,$318c,$39ce
	.dc.w	$4210,$4a52,$5294,$5ad6
	.dc.w	$6318,$6b5a,$739c,$7bde
	.dc.w	$8420,$8c62,$94a4,$9ce6
	.dc.w	$a528,$ad6a,$b5ac,$bdee
	.dc.w	$c630,$ce72,$d6b4,$def6
	.dc.w	$e738,$ef7a,$f7bc,$fffe

	.end
