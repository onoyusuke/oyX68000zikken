/*	�t�@�C�����R�s�[
/*
int ch, fpi, fpo
str fnamei, fnameo
input "���̓t�@�C����"; fnamei
input "�o�̓t�@�C����"; fmaneo
fpi = fopen(fnamei, "r")
fpo = fopen(fnameo, "c")
wihle not feof(fpi)
	ch = fgetc(fpi)
	fputc(ch, fpo)
endwhile
fclose(fpi)
fclose(fpo)
