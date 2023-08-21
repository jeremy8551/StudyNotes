@echo off

set rootdir=%cd%
echo %rootdir%
cd /d "%rootdir%\zx_setup"
del /F /S /Q *
xcopy /E /Y F:\project\哈尔滨银行征信系统\征信配合全流程上线程序\* .
del .project
del /F /S /Q %rootdir%\zx_setup.tar
F:\applications\7-zip\7z a %rootdir%\zx_setup.tar %rootdir%\zx_setup
copy 征信配合全流程改造项目--上线文档.docx "%rootdir%\征信配合全流程改造项目--上线文档.docx"
pause

del "%rootdir%\rpt.war"
cd /d F:\project\哈尔滨银行征信系统\rpt_haerbin\WebRpt
del rpt.war
jar -cvf rpt.war *.*
copy rpt.war "%rootdir%\rpt.war"
del rpt.war

pause