   10 int fp, i, s
   20 /*
   30 fp = fopen("sintable.s","c")
   40 d = 0
   50 for i = 0 to 90
   60     s = int(sin(pi()*i/180)*16384+0.5#)
   70     fwrites(itoa(s)+chr$(13)+chr$(10), fp)
   80 next
   90 fclose(fp)
