   10 /* macinto-c_pro68k
   20 /* var
   30         char Dump(65535),A1
   40         int Num,Pointer=-8,Size,Data,Sum,Vsum(7)
   50         int Work(7),X,V,F,M,CrcOn=1
   60         str Hex,EditFile,Mode="r",Ascii,B1,Hyoji
   70 /* begin
   80 cls
   90 print "New File ( y or n )":B1=inkey$
  100 if strlwr(B1)="y" then Mode="c"
  110 input "Edit file := ";EditFile
  120 Num=fopen(EditFile, Mode)
  130 Size = fseek(Num, 0, 2)
  140 fseek(Num,0,0)
  150 if not Size=0 then{
  160 fread(Dump,Size,Num)}
  170 fcloseall()
  180 /*
  190 print EditFile,Size;"Byte"
  200 locate 0,11
  210 repeat 
  220         repeat
  230                 Out()
  240         until Pointer > (Size)*abs(M)
