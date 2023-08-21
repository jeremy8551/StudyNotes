#! /usr/bin/ksh

# 数据平台 数据采集调度脚本


# 备份日志
_SJPT_LOG=$HOME/sjpt/log/`date +%Y%m%d`
if [ ! -d $_SJPT_LOG ]; then 
    mkdir $_SJPT_LOG  
fi


echo " "
echo "*************************************************" 
echo 开始采集核心业务数据,时间: `date +%Y-%m-%d_%T`

# 进入数据存放目录
_FILEDIR=$HOME/sjpt/data
if [ ! -d $_FILEDIR ]; then
    mkdir $_FILEDIR
fi
cd $_FILEDIR
if [ $? -ne 0 ];
then
    echo "进入目录${_FILEDIR}失败!" ;
    exit -1;
fi
rm -f *

echo 数据日期: `/$HOME/sjpt/bin/get_core_ywdate.sh`

echo 采集 核心公共数据,时间: `date +%Y-%m-%d_%T`
/$HOME/sjpt/bin/coresjcq.sh >> ${_SJPT_LOG}/coresjcq.log 2>&1
if [ $? -ne 0 ]; then 
    echo 采集 核心公共信息 发生错误, 脚本: coresjcq.sh, 日志: ${_SJPT_LOG}/coresjcq.log  
    exit 1
fi


echo 采集 非现场监管数据,时间: `date +%Y-%m-%d_%T`
/$HOME/sjpt/bin/osssjcq.sh  >> ${_SJPT_LOG}/osssjcq.log 2>&1
if [ $? -ne 0 ]; then 
    echo 采集 1104信息 发生错误, 脚本: osssjcq.sh, 日志: ${_SJPT_LOG}/osssjcq.log
    exit 2
fi


echo 采集 反洗钱数据,时间: `date +%Y-%m-%d_%T`
/$HOME/sjpt/bin/amlsjcq.sh  >> ${_SJPT_LOG}/amlsjcq.log 2>&1
if [ $? -ne 0 ]; then 
    echo 采集 反洗钱信息 发生错误, 脚本: amlsjcq.sh, 日志: ${_SJPT_LOG}/amlsjcq.log
    exit 3
fi


echo 采集 企业征信数据,时间: `date +%Y-%m-%d_%T`
/$HOME/sjpt/bin/qyzxsjcq.sh >> ${_SJPT_LOG}/qyzxsjcq.log 2>&1
if [ $? -ne 0 ]; then 
    echo 采集 企业征信信息 发生错误, 脚本: qyzxsjcq.sh, 日志: ${_SJPT_LOG}/qyzxsjcq.log
    exit 4
fi


echo 采集 金融统计数据,时间: `date +%Y-%m-%d_%T`
/$HOME/sjpt/bin/frrsjcq.sh >> ${_SJPT_LOG}/frrsjcq.log 2>&1
if [ $? -ne 0 ]; then 
    echo 采集 金融统计信息 发生错误, 脚本: frrsjcq.sh, 日志: ${_SJPT_LOG}/frrsjcq.log
    exit 5
fi

# 
# echo ftp 核心数据,时间: `date +%Y-%m-%d_%T`
# /$HOME/sjpt/bin/ftp_file.sh >> ${_SJPT_LOG}/ftp_file.log 2>&1
# if [ $? -ne 0 ]; then 
#     echo ftp 核心数据发生错误, 脚本: ftp_file.sh, 日志: ${_SJPT_LOG}/ftp_file.log
#     exit 6
# fi
# 

echo 采集完毕, 时间: `date +%Y-%m-%d_%T`                 
exit 0





