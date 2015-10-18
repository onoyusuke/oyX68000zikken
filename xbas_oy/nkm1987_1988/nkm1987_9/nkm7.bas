   10 /* PCMデータファイルの縮小
   20 /*
   30 int fpi,fpo,sec,num
   40 dim char a(65535)
   50 str fnamei,fnameo
   60 input "入力ファイル名"; fnamei
   70 input "出力ファイル名"; fnameo
   80 input "秒数"; sec
   90 num=7800*sec        /* サンプリング15.6KHz時
  100 if num>65535 then num=65535
  110 fpi=fopen(fnamei,"r")
  120 fpo=fopen(fnamei,"o")
  130 fread(a,65536,fpi)
  140 fwrite(a,num,fpo)
  150 fcloseall()
