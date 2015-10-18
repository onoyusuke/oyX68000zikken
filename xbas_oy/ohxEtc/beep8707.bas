10 char oto(65535)
20 int fno, c
30 str s
40 repeat
50	print "録音します。なにかキーを押してください"
60	s = inkey$
70	a_rec(oto, 4)
80	print"録音終了"
90	a_play(oto,4,3)
100	print "OK ?"
110	s=inkey$
120 until (s="y" or s="Y")
130 fno = fopen("beep.pcm","c")
140 c = fwrite(oto, 65535, fno)
150 fclose(fno)

