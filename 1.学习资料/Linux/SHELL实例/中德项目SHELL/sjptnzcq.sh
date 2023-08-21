#! /usr/bin/ksh

# 数据平台年转采集脚本

exec_sql1() 
{
dbaccess `sed -n '1'p $HOME/sjpt/bin/db.ini`<< !
$@;
!
    if [ $? -ne 0 ]
    then
        echo "$@执行失败"
        exit 1
    fi
}

echo " "
echo " "
echo "*************************************************"
echo 数据平台年转处理, `date +%Y-%m-%d_%T` 

# 进入数据存放目录
_FILEDIR=$HOME/sjpt/data
cd $_FILEDIR
if [ $? -ne 0 ];
then
    echo "进入目录${_FILEDIR}失败!" ;
    exit -1;
fi

echo begin_time: `date +%Y-%m-%d_%H:%M:%S` 

echo 抽取当日明细表数据 fdrmx
exec_sql1 "unload to S_CORE_QYZX_FLSMXZ1231.del delimiter ',' select kmh,dfkmh,hbh,khdh,
          zzh,zhkh,xh,hszh,dljg,jgm,xtrq,to_char(decode(jyrq,0,null,date(jyrq)),'%Y-%m-%d'),zxlsh,
          gylsh,jym,jyje,ye,js,pzbz,tdbz,zy,sqm,pzzl,pzhm,jdbz,pj,
          gy1,gy2,dyzzh,dyzhkh,dyxh,dfhszh,jysj,cngy,bz 
          from fdrmx 
          where hszh LIKE 'HT%' 
            and jdbz = '2' "


echo 卸数完毕, 当前时间: `date +%Y-%m-%d_%T` 
echo "  "