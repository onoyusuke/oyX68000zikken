/*	ファイルをコピー
/*
int ch, fpi, fpo
str fnamei, fnameo
input "入力ファイル名"; fnamei
input "出力ファイル名"; fmaneo
fpi = fopen(fnamei, "r")
fpo = fopen(fnameo, "c")
wihle not feof(fpi)
	ch = fgetc(fpi)
	fputc(ch, fpo)
endwhile
fclose(fpi)
fclose(fpo)
