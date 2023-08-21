#! /usr/bin/ksh

# 数据平台 采集核心系统公共信息脚本

exec_sql1()
{
dbaccess `sed -n '1'p $HOME/sjpt/bin/db.ini`<< !
$@;
!
    if [ $? -ne 0 ]; then
        echo "$@执行失败"
        exit 1
    fi
}

echo " "
echo " "
echo "*************************************************"
echo 开始采集核心系统公共信息, `date +%Y-%m-%d_%T` 

# 进入数据存放目录
_FILEDIR=$HOME/sjpt/data
cd $_FILEDIR
if [ $? -ne 0 ];
then
    echo "进入目录${_FILEDIR}失败!" 
    exit -1
fi


# 核心机构表 数据平台机构关系中用到
echo 抽取核心机构信息
exec_sql1 "unload to S_CORE_ORGANINFO.del delimiter ',' select ORGANNO,SUPORGANNO,ORGANNAME,ORGANSHORTFORM,ENNAME,
               LOCATE,ORDERNO,DISTNO,LAUNCHDATE,ORGANTYPE,ORGANLEVEL,FINCODE,STATE,ORGANCHIEF,TELNUM,ADDRESS,
                  POSTCODE,MEMO,PK1 from organinfo "


echo 抽取核心数据日期
exec_sql1 "unload to S_CORE_SYS.del delimiter ',' SELECT pk1,cnname,version,sysdesc,property,to_char(decode(openday,0,null,date(openday)),'%Y-%m-%d'),to_char(decode(lstopenday,0,null,date(lstopenday)),'%Y-%m-%d'),pininvalid,memo,flag from sys "




echo 卸数完毕, 当前时间: `date +%Y-%m-%d_%T` 
exit 0

