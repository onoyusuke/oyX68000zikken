echo off

:LOOP
askyn
if errorlevel 512 goto BREAK
if errorlevel 1 goto NO

:YES
echo 終了コードは0です
goto LOOP

:NO
echo 終了コードは1（以上）です
goto LOOP

:BREAK
echo BREAKしました
