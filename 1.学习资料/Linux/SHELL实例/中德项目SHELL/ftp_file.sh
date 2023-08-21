#! /usr/bin/ksh

# FTP调度脚本

# 备份日志
_SJPT_LOG=$HOME/sjpt/log/`date +%Y%m%d`
if [ ! -d $_SJPT_LOG ]; then 
    mkdir $_SJPT_LOG  
fi

echo FTP到数据平台, 时间: `date +%Y-%m-%d_%T`                                         >> $HOME/sjpt/log/sjptsjcq.log
/$HOME/sjpt/bin/sjptftp.sh >> ${_SJPT_LOG}/sjptftp.log 2>&1
if [ $? -ne 0 ]; then 
    echo FTP到数据平台时发生错误, 脚本: sjptftp.sh, 日志: ${_SJPT_LOG}/sjptftp.log    >> $HOME/sjpt/log/sjptsjcq.log
    exit 1
fi

exit 0


