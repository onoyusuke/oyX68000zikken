	10 /* �t�@�C���̓��e��\��
	20 /*
	30 int ch,fp
	40 str fname
	50 input "�t�@�C����"; fname
	60 fp = fopen(fname, "r")
	70 while not feof(fp)
	80	ch=fgetc(fp)
	90	print chr$(ch);
	100 endwhile
	110 fclose(fp)
