   10 int x0 = 0, y0 = 0
   20 int x1 = 5, y1 = 3
   30 int e, x, y
   40 int dx, dy, sx, sy, i
   50 /*
   60 screen 0,0,1,1
   70 dx = abs(x1-x0): dy = abs(y1-y0)
   80 sx = sgn(x1-x0): sy = sgn(y1-y0)
   90 x  = x0        : y  = y0
  100 if (dx >= dy) then {
  110     e = 2*dy - dx
  120     for i = 0 to dx + dy
  130         pset(x, y, 15)
  140         if (e >= 0) then {
  150             y = y + sy
  160             e = e - 2*dx
  170         } else {
  180             x = x + sx
  190             e = e + 2*dy
  200         }
  210     next
  220 } else {
  230     e = 2*dx - dy
  240     for i = 0 to dx + dy
  250         pset(x, y, 15)
  260         if (e >= 0) then {
  270             x = x + sx
  280             e = e - 2*dy
  290         } else {
  300             y = y + sy
  310             e = e + 2*dx
  320         }
  330     next
  340 }
