#! /usr/bin/ksh

# FTP���Ƚű�

# ������־
_SJPT_LOG=$HOME/sjpt/log/`date +%Y%m%d`
if [ ! -d $_SJPT_LOG ]; then 
    mkdir $_SJPT_LOG  
fi

echo FTP������ƽ̨, ʱ��: `date +%Y-%m-%d_%T`                                         >> $HOME/sjpt/log/sjptsjcq.log
/$HOME/sjpt/bin/sjptftp.sh >> ${_SJPT_LOG}/sjptftp.log 2>&1
if [ $? -ne 0 ]; then 
    echo FTP������ƽ̨ʱ��������, �ű�: sjptftp.sh, ��־: ${_SJPT_LOG}/sjptftp.log    >> $HOME/sjpt/log/sjptsjcq.log
    exit 1
fi

exit 0


