#!/bin/sh
#��    �ܣ�ɾ�����ݲֿ�����������м�������
#��    ������
#����ʱ�䣺2009-6-25
#  �����ˣ����Ⱦ�
#������˾�������׳�

# ��¼ִ��λ��
count=0


# ����UDSF���ݿ�
db2 +o connect to $db2_connect_str
return_val=$?
if [ $return_val -ne 0 ]; then
   echo "����UDSF���ݿ�ʧ��"
   exit $return_val
fi


_propress()
{
((count=count+1))
echo "the proess $1 is running!" 
result=`db2 "load from /dev/null of del replace into $1"`
if [ result -ne 0 -a result -ne 2 ]; then
echo "deal with the proess called $1 is wrong and return code is $?"
db2 +o connect reset
exit $count
fi
}


# ���˿ͻ����ϱ�
_propress 'grzx_pcc_customer' 

# �������Ͻӿڱ�
_propress 'grzx_pcc_loan' 

# ����̨�ʽӿڱ�
_propress 'grzx_pcc_loan_fact' 

# ������ӿڱ�
_propress 'grzx_pcc_loan_grnt' 
 
# �������ϸ
_propress 'grzx_pcc_loan_repay' 


echo "ok, all process execute successfully! "
db2 +o connect reset 
exit 0
