   10 str ss
   20 int hsvbuf(2)
   30 int h,s,v,c0,c1,c2
   40 screen 1,3,1,1
   50 ss=time$
   60 ss=right$(ss,2)+mid$(ss,4,2)+left$(ss,2)
   70 randomize(atoi(ss) mod 32768)
   80 while ( 1 )
   90     h=192*rnd()
  100     s=31*rnd()
  110     v=31*rnd()
  120     c0=hsv(h,s,v)
  130     c1=hsvtorgb(h,s,v)
  140     rgbtohsv(c1)
  150     c2=hsvtorgb(hsvbuf(0),hsvbuf(1),hsvbuf(2))
  160     fill(  0,50,140,199,c0)
  170     fill(150,50,290,199,c1)
  180     fill(300,50,440,199,c2)
  190     ss=inkey$
  200 endwhile
  210 end
  220 /*
  230 func hsvtorgb(h,s,v)
  240     int c,i,v1,v2,v3,t
  250     /*
  260     if s=0 then {
  270         c = rgb(v,v,v)
  280     } else {
  290         i=h/32            /*
  300         t=h mod 32
  310         v1=(v*(31*32-s*32)    +31*16)/(31*32)
  320         v2=(v*(31*32-s*t)     +31*16)/(31*32)
  330         v3=(v*(31*32-s*(32-t))+31*16)/(31*32)
  340         switch ( i )
  350             case 0: c=rgb(v ,v3,v1): break
  360             case 1: c=rgb(v2,v ,v1): break
  370             case 2: c=rgb(v1,v ,v3): break
  380             case 3: c=rgb(v1,v2,v ): break
  390             case 4: c=rgb(v3,v1,v ): break
  400             case 5: c=rgb(v ,v1,v2): break
  410        endswitch
  420    }
  430    return ( c )
  440 }
  450 /*
  460 func rgbtohsv(c)
  470     int h,s,v,r,g,b,t,f
  480 /*
  490     b = (c/2) and 31
  500     r = (c/32/2) and 31
  510     g = (c/32/32/2) and 31
  520     v = b                 :f = 0
  530     if (r > v) then v = r :f = 1
  540     if (g > v) then v = g :f = 2
  550     t = b
  560     if (r < t) then t = r
  570     if (g < t) then t = g
  580     if (v = 0) then {
  590         s = 0
  600     } else {
  610         s = (v-t)*31/v
  620     }
  630     if (s = 0) then {
  640         h = -1
  650     } else {
  660         t = v-t
  670         bb = v-b
  680         rr = v-r
  690         gg = v-g
  700         switch ( f )
  710             case 0: h = (32*(gg-rr))/t+4*32: break
  720             case 1: h = (32*(bb-gg))/t+0*32: break
  730             case 2: h = (32*(rr-bb))/t+2*32: break
  740         endswitch
  760         if (h < 0) then h = h + 192
  770     }
  780     hsvbuf(0) = h
  790     hsvbuf(1) = s
  800     hsvbuf(2) = v
  810 endfunc
