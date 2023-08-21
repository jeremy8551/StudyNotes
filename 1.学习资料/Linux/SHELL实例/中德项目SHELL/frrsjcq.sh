#! /usr/bin/ksh

# 数据平台: 金融统计报表 抽取程序

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
echo 开始采集 金融统计报表 业务数据, `date +%Y-%m-%d_%T` 

# 进入数据存放目录
_FILEDIR=$HOME/sjpt/data
cd $_FILEDIR
if [ $? -ne 0 ];
then
    echo "进入目录${_FILEDIR}失败!"
    exit -1;
fi


#对公客户信息卸数语句
exec_sql1 "unload to S_CORE_FRR_ENTCUSTINF.del delimiter ',' SELECT custno,ecotype,caltype1,untsize,untcha
           FROM entcustinf"
           
           
#借据分户卸数语句
exec_sql1 "unload to S_CORE_FRR_FJJFH.del delimiter ',' SELECT jjh,khdh,jgm,hbh,zhkz,ffje,bnbj,bwbj,to_char(decode(ffrq,0,null,date(ffrq)),'%Y-%m-%d')
           FROM fjjfh where zhkz[7] <> '2'"
           
#一般贷款借据信息卸数语句
exec_sql1 "unload to S_CORE_FRR_CRDT_CZ_DK.del delimiter ',' SELECT jjh,khdh,dbfs
           FROM crdt_cz_dk  where ywpz <> '010003'"
           
           


echo 卸数完毕, 当前时间: `date +%Y-%m-%d_%T` 



