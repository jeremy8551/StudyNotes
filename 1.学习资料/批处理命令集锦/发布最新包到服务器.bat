@echo off

set rootdir=%cd%
echo %rootdir%
cd /d "%rootdir%"

rem 打包最新工程
mkdir WebRpt
cd /d "%rootdir%\WebRpt"
del /F /S /Q *
xcopy /E /Y F:\project\哈尔滨银行征信系统\rpt_haerbin\WebRpt\* .
del /F /S /Q %rootdir%\WebRpt.tar
F:\applications\7-zip\7z a %rootdir%\WebRpt.tar %rootdir%\WebRpt


rem ftp命令上传包
echo user udsf udsf> %rootdir%\ftp.txt
echo binary>> %rootdir%\ftp.txt
echo cd /home/udsf/shell/lvzhaojun >> %rootdir%\ftp.txt
echo put %rootdir%\WebRpt.tar >> %rootdir%\ftp.txt
echo bye >> %rootdir%\ftp.txt
ftp -n -v -s:%rootdir%\ftp.txt 130.1.9.131


rem 解压包重启Tomcat
echo cd /home/udsf/shell/lvzhaojun > %rootdir%\ssh.txt
echo rm -rf WebRpt >> %rootdir%\ssh.txt
echo tar -xvf WebRpt.tar >> %rootdir%\ssh.txt
echo cd /home/udsf/shell/lvzhaojun/Tomcat-5.0/bin >> %rootdir%\ssh.txt
echo chmod +x *.sh >> %rootdir%\ssh.txt
echo sh shutdown.sh >> %rootdir%\ssh.txt
echo sh startup.sh >> %rootdir%\ssh.txt
echo exit >> %rootdir%\ssh.txt
putty -l udsf -pw udsf 130.1.9.131 -m %rootdir%\ssh.txt

pause 