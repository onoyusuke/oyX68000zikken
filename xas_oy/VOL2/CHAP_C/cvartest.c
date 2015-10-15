int a = 1;
int b;

static void foo( x, y )
int x, y;
{
    int e;
    register int f;
    static int g = 1;
    static int h;

    e = x;
    h = y;
    f = g;
}

static int c = 1;
static int d;

int main()
{
    foo( c, 50000 );

    return 0;
}
