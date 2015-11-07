 10 /* *FNCファイルの関数を調べる
 20 /*
 30 str fname,fun: int tokenptr=0,ch,fp,fn,i
 40 input "ファイル名";fname
 50 fp = fopen(fname, "r")
 60 fseek(fp, &H40+&H20, 0)
 70 for i=0 to 3
 80	tokenptr = tokenptr*256 + fgetc(fp)
 90 next
 100 fseek(fp, &H40+tokenptr, 0)
 110 fn=0: i=0
 120 while not feof(fp)
 130	ch = fgetc(fp)
 140	if ch=0 then {
 150		fun[i]=0: i=0
 160		if fun<>"" then {
 170			fn=fn+1: print fn;tab(8);fun
 180		}
 190	continue /* 0が続いてfun[0]=0となっているとき(fun="")。ここはbreakすべきでは？
 200	} else if isalnum(ch) or (ch='_') then {
 210		fun[i]=ch: i=i+1
 220	} else break
 230 endwhile
 240 fclose(fp)
 
