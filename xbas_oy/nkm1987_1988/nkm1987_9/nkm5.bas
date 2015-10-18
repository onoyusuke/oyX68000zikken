   10 /* ダンププログラム
   20 /*
   30 int fp, ch, cnt=0: str fname, a=""
   40 input "ファイル名"; fname
   50 fp = fopen(fname,"r")
   60 while not feof(fp)
   70         ch = fgetc(fp)
   80         if isprint(ch) then a=a+chr$(ch) else a=a+"."
   90         print hex2(ch)+" ";: cnt=cnt+1
  100         if cnt=16 then {
  110                 print " /"+a: cnt=0: a=""
  120         }
  130 endwhile
  140 fclose(fp)
  150 if cnt<>16 then {
  160         repeat
  170                 print "   ";: cnt=cnt+1
  180         until cnt=16
  190         print " /"+a
  200 }
  210 end
  220 /*
  230 func str hex2(ch)
  240         int high, low
  250         high = (ch shr 4) and &HF
  260         low = ch and &HF
  270         return(hex$(high)+hex$(low))
  280 endfunc
