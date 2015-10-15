   10 func test(x0,y0,x1,y1,x2,y2,x3,y3)
   20     int x,y,xx,yy,c
   30     for y=y0 to y1
   40         yy=(y-y0)*(y3-y2)/(y1-y0)+y2
   50         for x=x0 to x1
   60             xx=(x-x0)*(x3-x2)/(x1-x0)+x2
   70             c=point(x,y)
   80             pset(xx,yy,c)
   90         next
  100     next
  110 endfunc
