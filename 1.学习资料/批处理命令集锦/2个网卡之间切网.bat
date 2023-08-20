Echo off

rem ============ DNS ===============

set eth="本地连接"

rem 设置主DNS
set dns1=202.97.224.68

rem 设置辅DNS
set dns2=202.97.224.68

rem ================================

rem ==========内网地址=============

rem 内网IP地址
set in_ip=168.1.1.214

rem 内网子网掩码
set in_netmasks=255.255.0.0

rem 内网默认网关
set in_gw=168.1.1.1

rem ================================


rem ==========外网地址==============

rem 外网IP地址
set out_ip=177.17.18.190

rem 外网子网掩码
set out_netmasks=255.255.255.0

rem 外网默认网关
set out_gw=177.17.18.1

rem ================================


rem 获取本机IP(局域网)及MAC地址
setlocal enabledelayedexpansion

set "Space=        "
set "PH_addr=%Space%Physical Address"  %'/*-----物理地址-------*/%
set "IP_addr=%Space%IP Address" %'/*------IP地址(局域网)--------*/%

for /f "tokens=1,* delims=." %%i in ('ipconfig /all') do (
   for %%a in (PH_addr IP_addr) do (
	if "%%i"=="!%%a!" set %%a=%%j
   )
)


rem 设置DNS	echo !IP_addr!
netsh interface ip set dns "!eth!" static !dns1!
netsh interface ip add dns "!eth!" !dns2!


if "%IP_addr%"==" . . . . . . . . . . . : !in_ip!" goto q

devcon enable *DEV_170C* 
devcon disable *DEV_4222* 
echo ******************************
echo *      成功切换到内网！       *
echo ******************************
goto e

:q
devcon disable *DEV_170C* 
devcon enable *DEV_4222* 
echo ******************************
echo *      成功切换到外网！       *
echo ******************************

:e


rem ipconfig /all
pause




