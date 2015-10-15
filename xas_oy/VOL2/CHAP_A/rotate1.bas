   10 int x,y
   20 float c,s
   30 /*
   40 screen 0,3,1,1
   50 fill(0,0,99,99,rgb(8,8,8))
   60 for i=0 to 31
   70   fill(i,i,63-i,63-i,hsv(i*6,31,31))
   80 next
   90 /*
  100 c=cos(-30*pi()/180)
  110 s=sin(-30*pi()/180)
  120 /*
  130 for y=0 to 63
  140   for x=0 to 63
  150     x0=c*(x-32)-s*(y-32)+32
  160     y0=s*(x-32)+c*(y-32)+32
  170     pset(x0+128-32,y0+128-32,point(x,y))
  180   next
  190 next
