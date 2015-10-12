/*
 0ŽŸŒ³
 */

#include <basic0.h>
#include <graph.h>


void	screen(int, int, int, int);
void	width(int);
void	pset(int, int, int);
int	hsv(int, int, int);

main()
{
	int x,y;
	int ai,bi,ci,di;
	int color;

	screen(0,3,1,1);

	x = 128;
	y = 128;

	for(ai=0;ai<=1;ai++)
		for(bi=0;bi<=31;bi++)
			for(ci=0;ci<=31;ci++)
				for(di=0;di<=191;di++)
				{
					color = hsv(di, 31-ci, 31-bi)+1-ai;
					pset(x,y,color);
					if(kbhit()){
						width(96);
						exit();
					}
				}
	width(96);
}
