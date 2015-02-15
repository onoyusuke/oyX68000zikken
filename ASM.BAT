echo off

:LOOP
as %1
if errorlevel 1 goto ERROR

lk %1
if errorlevel 1 goto ERROR

del %1.o/y
goto END

:ERROR
echo ERROR!

:END
