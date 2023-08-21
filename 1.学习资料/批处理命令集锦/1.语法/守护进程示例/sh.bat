@echo off

title shouhu 

:RESTART   

cd /d C:\Documents and Settings\lzj\桌面\新建文件夹

echo %date%_%time% >> sh.log  

cscript 


goto RESTART  