   10 /* PCM�f�[�^�t�@�C���̏k��
   20 /*
   30 int fpi,fpo,sec,num
   40 dim char a(65535)
   50 str fnamei,fnameo
   60 input "���̓t�@�C����"; fnamei
   70 input "�o�̓t�@�C����"; fnameo
   80 input "�b��"; sec
   90 num=7800*sec        /* �T���v�����O15.6KHz��
  100 if num>65535 then num=65535
  110 fpi=fopen(fnamei,"r")
  120 fpo=fopen(fnamei,"o")
  130 fread(a,65536,fpi)
  140 fwrite(a,num,fpo)
  150 fcloseall()
