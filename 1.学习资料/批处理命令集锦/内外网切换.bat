Echo off

rem ============ DNS ===============

set eth="��������"

rem ������DNS
set dns1=202.97.224.68

rem ���ø�DNS
set dns2=202.97.224.68

rem ================================

rem ==========������ַ=============

rem ����IP��ַ
set in_ip=200.198.1.190

rem ������������
set in_netmasks=255.255.255.0

rem ����Ĭ������
set in_gw=200.198.1.254

rem ================================


rem ==========������ַ==============

rem ����IP��ַ
set out_ip=177.17.18.190

rem ������������
set out_netmasks=255.255.255.0

rem ����Ĭ������
set out_gw=177.17.18.1

rem ================================


rem ��ȡ����IP(������)��MAC��ַ
setlocal enabledelayedexpansion

set "Space=        "
set "PH_addr=%Space%Physical Address"  %'/*-----�����ַ-------*/%
set "IP_addr=%Space%IP Address" %'/*------IP��ַ(������)--------*/%

for /f "tokens=1,* delims=." %%i in ('ipconfig /all') do (
   for %%a in (PH_addr IP_addr) do (
	if "%%i"=="!%%a!" set %%a=%%j
   )
)


rem ����DNS	echo !IP_addr!
netsh interface ip set dns "!eth!" static !dns1!
netsh interface ip add dns "!eth!" !dns2!


if "%IP_addr%"==" . . . . . . . . . . . : !in_ip!" goto q


netsh interface ip set address "!eth!" static !in_ip! !in_netmasks! !in_gw! default
echo ******************************
echo *      �ɹ��л���������       *
echo ******************************
goto e

:q
netsh interface ip set address "!eth!" static !out_ip! !out_netmasks! !out_gw! default  
echo ******************************
echo *      �ɹ��л���������       *
echo ******************************

:e


rem ipconfig /all
pause




