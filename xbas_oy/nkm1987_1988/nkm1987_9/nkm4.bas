   10 /*	�t�@�C�����R�s�[
   20 /*
   30 int ch, fpi, fpo
   40 str fnamei, fnameo
   50 input "���̓t�@�C����"; fnamei
   60 input "�o�̓t�@�C����"; fmaneo
   70 fpi = fopen(fnamei, "r")
   80 fpo = fopen(fnameo, "c")
   90 wihle not feof(fpi)
  100         ch = fgetc(fpi)
  110         fputc(ch, fpo)
  120 endwhile
  130 fclose(fpi)
  140 fclose(fpo)
