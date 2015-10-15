int a, b, c, d;
main()
{
	scanf("%d %d", &a, &b);
	c = a * b;
	d = max2(a, b);
	printf("a=%d b=%d\n", a, b);
	printf("a*b=%d\n", c);
	printf("max2(a,b)=%d\n", d);
}

max2(x, y)
int x, y;
{
	return(((x+y)+abs(x-y))/2);
}
