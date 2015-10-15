   10 dim char m22(1,1) = { 0, 2, 3, 1}
   20 dim char m44(3,3),m88(7,7)
   30 int i,j,fp
   40 /*
   50 /* 2x2 Å® 4x4
   60 for i=0 to 1:for j=0 to 1
   70     m44(i+0,j+0) = 4*m22(i,j)
   80     m44(i+2,j+0) = 4*m22(i,j)+2
   90     m44(i+0,j+2) = 4*m22(i,j)+3
  100     m44(i+2,j+2) = 4*m22(i,j)+1
  110 next:next
  120 /*
  130 /* 4x4 Å® 8x8
  140 for i=0 to 3:for j=0 to 3
  150     m88(i+0,j+0) = 4*m44(i,j)
  160     m88(i+4,j+0) = 4*m44(i,j)+2
  170     m88(i+0,j+4) = 4*m44(i,j)+3
  180     m88(i+4,j+4) = 4*m44(i,j)+1
  190 next:next
  200 /*
  210 fp = fopen("$","c")
  220 for i=0 to 7:for j=0 to 7
  230     fwrites(itoa(m88(i,j)-32)+",",fp)
  240 next:fwrites(chr$(13)+chr$(10),fp):next
  250 fclose(fp)
