echo off
dir %1/w
echo 以上のファイルを消去します
echo よろしいですか [Y/N]
askyn
if errorlevel 1 goto END
del %1/y
:END
