   10 int x0,y0,r,x,y,f
   20 screen 2,0,1,1
   30 /*
   40 x0=384:y0=256:r=200
   50 circle(x0,y0,r,3)
   60 x=r:y=0
   70 f=-2*r+3
   80 while x>=y
   90     pset(x0+x,y0+y,15)
  100     pset(x0-x,y0+y,15)
  110     pset(x0+x,y0-y,15)
  120     pset(x0-x,y0-y,15)
  130     pset(x0+y,y0+x,15)
  140     pset(x0-y,y0+x,15)
  150     pset(x0+y,y0-x,15)
  160     pset(x0-y,y0-x,15)
  170     if f>=0 then {
  180         x=x-1
  190         f=f-4*x
  200     }
  210     y=y+1
  220     f=f+4*y+2
  230 endwhile
