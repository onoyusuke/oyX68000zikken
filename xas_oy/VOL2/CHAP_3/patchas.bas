   10 /* as.x v2.00 ÇÃdcbèCê≥
   20 dim char q(33)
   30 int fp
   40 fp=fopen("as.x","rw")
   50 fseek(fp,&H54B2,0)
   60 fread(q,34,fp)
   70 q(1)=&H87
   80 q(33)=&H7
   90 fseek(fp,&H54B2,0)
  100 fwrite(q,34,fp)
  110 fclose(fp)
