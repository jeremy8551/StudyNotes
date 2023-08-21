#! /usr/bin/ksh

# 数据平台年转处理 脚本

# 备份日志
_SJPT_LOG=$HOME/sjpt/log/`date +%Y%m%d`
if [ ! -d $_SJPT_LOG ]; then 
    mkdir $_SJPT_LOG  
fi

echo 年转处理,时间: `date +%Y-%m-%d_%T`                                         >> $HOME/sjpt/log/sjptsjcq.log
/$HOME/sjpt/bin/sjptnzcq.sh >> ${_SJPT_LOG}/sjptnzcq.log 2>&1
if [ $? -ne 0 ]; then 
    echo 年转处理 发生错误, 脚本: sjptnzcq.sh, 日志: ${_SJPT_LOG}/sjptnzcq.log  >> $HOME/sjpt/log/sjptsjcq.log
    exit 1
fi

exit 0


