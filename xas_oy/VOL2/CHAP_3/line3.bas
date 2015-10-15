   10 int x0 = 0, y0 = 0
   20 int x1 = 5, y1 = 3
   30 int e, x, y
   40 int dx, dy, sx, sy, i
   50 /*
   60 dx = abs(x1-x0): dy = abs(y1-y0)
   70 sx = sgn(x1-x0): sy = sgn(y1-y0)
   80 x  = x0        : y  = y0
   90 if (dx >= dy) then {
  100     e = -dx
  110     for i = 0 to dx
  120         print x, y
  130         x = x + sx
  140         e = e + 2*dy
  150         if (e >= 0) then {
  160             y = y + sy
  170             e = e - 2*dx
  180         }
  190     next
  200 } else {
  210     e = -dy
  220     for i = 0 to dy
  230         print x, y
  240         y = y + sy
  250         e = e + 2*dx
  260         if (e >= 0) then {
  270             x = x + sx
  280             e = e - 2*dy
  290         }
  300     next
  310 }
