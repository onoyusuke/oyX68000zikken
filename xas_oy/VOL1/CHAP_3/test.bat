echo off

:LOOP
askyn
if errorlevel 512 goto BREAK
if errorlevel 1 goto NO

:YES
echo �I���R�[�h��0�ł�
goto LOOP

:NO
echo �I���R�[�h��1�i�ȏ�j�ł�
goto LOOP

:BREAK
echo BREAK���܂���
