   10 func test(x0,y0,x1,y1,x2,y2,x3,y3)
   20     int x,y,xx,yy,c
   30     for yy=y2 to y3
   40         y=(yy-y2)*(y1-y0)/(y3-y2)+y0
   50         for xx=x2 to x3
   60             x=(xx-x2)*(x1-x0)/(x3-x2)+x0
   70             c=point(x,y)
   80             pset(xx,yy,c)
   90         next
  100     next
  110 endfunc
