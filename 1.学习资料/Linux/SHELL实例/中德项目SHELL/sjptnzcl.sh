#! /usr/bin/ksh

# ����ƽ̨��ת���� �ű�

# ������־
_SJPT_LOG=$HOME/sjpt/log/`date +%Y%m%d`
if [ ! -d $_SJPT_LOG ]; then 
    mkdir $_SJPT_LOG  
fi

echo ��ת����,ʱ��: `date +%Y-%m-%d_%T`                                         >> $HOME/sjpt/log/sjptsjcq.log
/$HOME/sjpt/bin/sjptnzcq.sh >> ${_SJPT_LOG}/sjptnzcq.log 2>&1
if [ $? -ne 0 ]; then 
    echo ��ת���� ��������, �ű�: sjptnzcq.sh, ��־: ${_SJPT_LOG}/sjptnzcq.log  >> $HOME/sjpt/log/sjptsjcq.log
    exit 1
fi

exit 0


