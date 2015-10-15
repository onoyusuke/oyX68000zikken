echo off
dir %1/w
echo ˆÈã‚Ìƒtƒ@ƒCƒ‹‚ğÁ‹‚µ‚Ü‚·
echo ‚æ‚ë‚µ‚¢‚Å‚·‚© [Y/N]
askyn
if errorlevel 1 goto END
del %1/y
:END
