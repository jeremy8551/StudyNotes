@echo off&setlocal enabledelayedexpansion

rem echo %cd%

rem 获取传送文本的目录
dir /b /o:n /a:d|findstr "^[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]">dirlst.tmp
for /f %%c in (dirlst.tmp) do (
set dir_name=%%c
)
del dirlst.tmp
echo ____数据目录: %cd%\!dir_name!

rem 生成数据准备完成标志
cd /d %cd%\!dir_name!
echo "" > SUCCESS

rem 生成FTP脚本
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

echo ____开始传送数据!

ftp -n -v -s:upload.bat 192.168.203.153 >> ftp.log

echo ____数据传送完毕!


pause



