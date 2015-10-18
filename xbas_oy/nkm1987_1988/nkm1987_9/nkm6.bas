   10 /* ファイルに行番号をつける
   20 /*
   30 str lin[256], fname1, fname2: int lno=10
   40 input "入力ファイル名";fname1
   50 input "出力ファイル名";fname2
   60 fp1 = fopen(fname1,"r")
   70 fp2 = fopen(fname2,"c")
   80 while 1
   90         freads(lin,fp1)
  100         if feof(fp1) then break
  110         fwrites(gln(5,lno)+" "+lin+chr$(13)+chr$(10),fp2)
  120         lno=lno+10
  130 endwhile
  140 fputc(&H1A,fp2)
  150 fclose(fp1)
  160 fclose(fp2)
  170 end
  180 /* 行番号を作る
  190 /*
  200 func str gln(k,lno)
  210 if k=1 then return(chr$(('0')+(lno mod 10)))
  220 return(gln(k-1,lno/10)+chr$('0'+(lno mod 10)))
  230 endfunc
