echo off
dir %1/w
echo �ȏ�̃t�@�C�����������܂�
echo ��낵���ł��� [Y/N]
askyn
if errorlevel 1 goto END
del %1/y
:END
