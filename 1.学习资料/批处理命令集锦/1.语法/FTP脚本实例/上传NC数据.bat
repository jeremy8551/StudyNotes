@echo off&setlocal enabledelayedexpansion

rem echo %cd%

rem ��ȡ�����ı���Ŀ¼
dir /b /o:n /a:d|findstr "^[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]">dirlst.tmp
for /f %%c in (dirlst.tmp) do (
set dir_name=%%c
)
del dirlst.tmp
echo ____����Ŀ¼: %cd%\!dir_name!

rem ��������׼����ɱ�־
cd /d %cd%\!dir_name!
echo "" > SUCCESS

rem ����FTP�ű�
echo user ncxt ncmm      > upload.bat
echo ascii              >> upload.bat
echo prompt             >> upload.bat
echo mkdir !dir_name!   >> upload.bat
echo cd !dir_name!      >> upload.bat
echo delete SUCCESS     >> upload.bat
echo mput *.csv         >> upload.bat
echo put SUCCESS        >> upload.bat
echo close              >> upload.bat
echo bye                >> upload.bat

echo ____��ʼ��������!

ftp -n -v -s:upload.bat 192.168.203.153 >> ftp.log

echo ____���ݴ������!


pause



