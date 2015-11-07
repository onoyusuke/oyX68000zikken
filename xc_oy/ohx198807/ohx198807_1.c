main()
{
		register int i;
		register int j;

		for(i=0;i<100;i++) j=i+10;
		do j=i+10; while(--j);
		do j=i+10; while(j--);
		while(--i) j=i+j;
		while(i--) j=i+j;
}

/*
 * NO_APP
RUNS_HUMAN_VERSION	equ	3
	.cpu 68000
	.include doscall.equ
* X68 GCC Develop
	.even
	.text
	.even
	.xref __main
	.xdef _main
_main:
	link a6,#0
	moveq.l #0,d0
?2:
	moveq.l #99,d2
	cmp.l d0,d2
	jblt ?3
	moveq.l #10,d1
	add.l d0,d1
?4:
	addq.l #1,d0
	jbra ?2
?3:
	nop
?5:
	moveq.l #10,d1
	add.l d0,d1
?7:
	subq.l #1,d1
	tst.l d1
	jbeq ?6
	jbra ?5
?6:
	nop
?8:
	moveq.l #10,d1
	add.l d0,d1
?10:
	subq.l #1,d1
	moveq.l #-1,d2
	cmp.l d1,d2
	jbeq ?9
	jbra ?8
?9:
	nop
?11:
	subq.l #1,d0
	tst.l d0
	jbeq ?12
	add.l d0,d1
	jbra ?11
?12:
	nop
?13:
	subq.l #1,d0
	moveq.l #-1,d2
	cmp.l d0,d2
	jbeq ?14
	add.l d0,d1
	jbra ?13
?14:
?1:
	unlk a6
	rts
	.even
	.end
*/
