main()
{
    struct GCOPYBUF {
	short	x0, y0;
	short	x1, y1;
	short	x2, y2;
    } gcopybuf;

	:

    gcopybuf.x0 = 0;
    gcopybuf.y0 = 0;
    gcopybuf.x1 = 50;
    gcopybuf.y1 = 50;
    gcopybuf.x2 = 100;
    gcopybuf.y2 = 0;
    gcopy( &gcopybuf );

	:
}
