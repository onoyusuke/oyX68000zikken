   10 int x,y,rx=3,ry=2
   20 float c,s
   30 /*
   40 screen 0,3,1,1
   50 fill(0,0,99,99,rgb(8,8,8))
   60 for i=0 to 31
   70   fill(i,i,63-i,63-i,hsv(i*6,31,31))
   80 next
   90 /*
  100 c=cos(30*pi()/180)
  110 s=sin(30*pi()/180)
  120 /*
  130 for y=0 to 63
  140   for x=0 to 63
  150     x0=ry*(rx*c*(x-32)/ry-s*(y-32))/rx+32
  160     y0=rx*s*(x-32)/ry+c*(y-32)+32
  170     pset(x+128-32,y+128-32,point(x0,y0))
  180   next
  190 next
