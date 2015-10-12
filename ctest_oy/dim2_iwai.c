/*
 いーかげんな2次元グラフィックス
 */

#include <basic0.h>
#include <graph.h>
#include <math.h>

main()
{
	double t,c,s;
	int x1,x2,y1,y2;
	double xw1,xw2,yw1,yw2;
	double bx,by;
	int ai,bi,ci,di;

	screen(1,3,1,1);

	x1 = 0;
	x2 = 0;
	y1 = 30;
	y2 = 60;

	bx = 50;
	by = 50;
	t = 0.0;


	for(ai=0;ai<=1;ai++)
		for(bi=0;bi<=31;bi++)
			for(ci=0;ci<=31;ci++)
				for(di=0;di<=191;di++)
				{
					c = cos(t);
					s = sin(t);

					xw1 = c*x1-s*y1;
					yw1 = s*x1+c*y1;

					xw2 = c*x2-s*y2;
					yw2 = s*x2+c*y2;

					xw1 += bx;
					xw2 += bx;
					yw1 += by;
					yw2 += by;

					line((int)xw1, (int)yw1, (int)xw2, (int)yw2, hsv(di, 31-ci, 31-bi)+1-ai, 0xffff);

					bx += 0.2;
					by += 0.2;
					t += 0.02;
					if(kbhit() || (xw1>550)){
						width(96);
						exit();
					}
				}
	width(96);
}

