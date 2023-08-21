#! /usr/bin/ksh

# 脚本功能：判断核心当前是否年转, 返回 0-年转 1-非年转

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

_FILEDIR=$HOME/sjpt/data
cd $_FILEDIR
if [ $? -ne 0 ];
then
    echo "进入目录${_FILEDIR}失败!" ;
    exit 1;
fi

_temp_file=$HOME/sjpt/data/NZBZ.tmp

exec_sql1 "unload to $_temp_file delimiter ',' select kzz[2] from cxtzt  " >> /dev/null 2>&1

_RQ=`cat $_temp_file`
_RQ=`expr substr $_RQ 1 1`
rm -f $_temp_file

# exit 1

# 如果 cxtzt表中的kzz[2]等于N，表示年转
if [ "$_RQ" == "N" ]; then 
    exit 0
fi

exit 1
