   10 float x0 = 0, y0 = 0
   20 float x1 = 5, y1 = 3
   30 float m, e
   40 int x, y, dx, i
   50 /*
   60 dx = x1-x0
   70 m = (y1-y0)/(x1-x0)
   80 e = -0.5#
   90 x = x0 : y = y0
  100 for i = 0 to dx
  110     print x, y
  120     x = x + 1
  130     e = e + m
  140     if (e >= 0) then {
  150         y = y + 1
  160         e = e - 1
  170     }
  180 next
