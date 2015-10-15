   10 float x0 = 0, y0 = 0
   20 float x1 = 5, y1 = 3
   30 float m
   40 int x, y, dx, sx, i
   50 /*
   60 dx = abs(x1-x0)
   70 sx = sgn(x1-x0)
   80 m = (y1-y0)/dx
   90 x = x0
  100 for i = 0 to dx
  110     y = int(m * i + y0 + 0.5#)
  120     print x, y
  130     x = x + sx
  140 next
