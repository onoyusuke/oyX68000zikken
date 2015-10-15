#include	<stdio.h>
#include	<ctype.h>

int main()
{
	int c;

	while ( EOF != ( c = getchar() ) )
		putchar( toupper( c ) );

	return 0;
}
