@echo off

set rootdir=%cd%
echo %rootdir%
cd /d "%rootdir%\zx_setup"
del /F /S /Q *
xcopy /E /Y F:\project\��������������ϵͳ\�������ȫ�������߳���\* .
del .project
del /F /S /Q %rootdir%\zx_setup.tar
F:\applications\7-zip\7z a %rootdir%\zx_setup.tar %rootdir%\zx_setup
copy �������ȫ���̸�����Ŀ--�����ĵ�.docx "%rootdir%\�������ȫ���̸�����Ŀ--�����ĵ�.docx"
pause

del "%rootdir%\rpt.war"
cd /d F:\project\��������������ϵͳ\rpt_haerbin\WebRpt
del rpt.war
jar -cvf rpt.war *.*
copy rpt.war "%rootdir%\rpt.war"
del rpt.war

pause