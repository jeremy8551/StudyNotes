#! /usr/bin/ksh

# ����ƽ̨ ���ݲɼ����Ƚű�


# ������־
_SJPT_LOG=$HOME/sjpt/log/`date +%Y%m%d`
if [ ! -d $_SJPT_LOG ]; then 
    mkdir $_SJPT_LOG  
fi


echo " "
echo "*************************************************" 
echo ��ʼ�ɼ�����ҵ������,ʱ��: `date +%Y-%m-%d_%T`

# �������ݴ��Ŀ¼
_FILEDIR=$HOME/sjpt/data
if [ ! -d $_FILEDIR ]; then
    mkdir $_FILEDIR
fi
cd $_FILEDIR
if [ $? -ne 0 ];
then
    echo "����Ŀ¼${_FILEDIR}ʧ��!" ;
    exit -1;
fi
rm -f *

echo ��������: `/$HOME/sjpt/bin/get_core_ywdate.sh`

echo �ɼ� ���Ĺ�������,ʱ��: `date +%Y-%m-%d_%T`
/$HOME/sjpt/bin/coresjcq.sh >> ${_SJPT_LOG}/coresjcq.log 2>&1
if [ $? -ne 0 ]; then 
    echo �ɼ� ���Ĺ�����Ϣ ��������, �ű�: coresjcq.sh, ��־: ${_SJPT_LOG}/coresjcq.log  
    exit 1
fi


echo �ɼ� ���ֳ��������,ʱ��: `date +%Y-%m-%d_%T`
/$HOME/sjpt/bin/osssjcq.sh  >> ${_SJPT_LOG}/osssjcq.log 2>&1
if [ $? -ne 0 ]; then 
    echo �ɼ� 1104��Ϣ ��������, �ű�: osssjcq.sh, ��־: ${_SJPT_LOG}/osssjcq.log
    exit 2
fi


echo �ɼ� ��ϴǮ����,ʱ��: `date +%Y-%m-%d_%T`
/$HOME/sjpt/bin/amlsjcq.sh  >> ${_SJPT_LOG}/amlsjcq.log 2>&1
if [ $? -ne 0 ]; then 
    echo �ɼ� ��ϴǮ��Ϣ ��������, �ű�: amlsjcq.sh, ��־: ${_SJPT_LOG}/amlsjcq.log
    exit 3
fi


echo �ɼ� ��ҵ��������,ʱ��: `date +%Y-%m-%d_%T`
/$HOME/sjpt/bin/qyzxsjcq.sh >> ${_SJPT_LOG}/qyzxsjcq.log 2>&1
if [ $? -ne 0 ]; then 
    echo �ɼ� ��ҵ������Ϣ ��������, �ű�: qyzxsjcq.sh, ��־: ${_SJPT_LOG}/qyzxsjcq.log
    exit 4
fi


echo �ɼ� ����ͳ������,ʱ��: `date +%Y-%m-%d_%T`
/$HOME/sjpt/bin/frrsjcq.sh >> ${_SJPT_LOG}/frrsjcq.log 2>&1
if [ $? -ne 0 ]; then 
    echo �ɼ� ����ͳ����Ϣ ��������, �ű�: frrsjcq.sh, ��־: ${_SJPT_LOG}/frrsjcq.log
    exit 5
fi

# 
# echo ftp ��������,ʱ��: `date +%Y-%m-%d_%T`
# /$HOME/sjpt/bin/ftp_file.sh >> ${_SJPT_LOG}/ftp_file.log 2>&1
# if [ $? -ne 0 ]; then 
#     echo ftp �������ݷ�������, �ű�: ftp_file.sh, ��־: ${_SJPT_LOG}/ftp_file.log
#     exit 6
# fi
# 

echo �ɼ����, ʱ��: `date +%Y-%m-%d_%T`                 
exit 0





