#!/bin/sh
#��    �ܣ���db2�洢����
#��    ����-n �洢��������
#����ʱ�䣺2009-02-11
#  �����ˣ������
#������˾�������׳�
usage()
{
    echo "run_proc.sh -n �洢�������� [-d] "
}
#�������͸�ֵ
para_count=0
proc_name=null
proc_date=null
proc_date_flag=0
while getopts "n:d" name;
do
case $name in
n)
   ((para_count=para_count+1))
   proc_name=$OPTARG
   ;;
d)
   proc_date_flag=1
   proc_date=`get_work_date.sh -s UDSF_WORK_DATE -f yyyy-mm-dd`
   ;;
?) 
   usage $progname
   exit 199
esac
done
if [ $para_count -ne 1 ]
then
   usage $progname
   exit 199
fi
#�������ݿ�
db2 +o connect to $db2_connect_str
if [ $? -ne 0 ]
then
 echo �������ݿ�ʧ�ܣ�
 exit 255
fi
return_val=0
if [ $proc_date_flag -eq 1 ]
then
echo db2 "call ${proc_name}('${proc_date}',?)"
return_msg=`db2 "call ${proc_name}('${proc_date}',?)"`
else
return_msg=`db2 "call ${proc_name}(?)"`
fi
if [ $? -ne 0 ]
then
 echo ���д洢����${proc_name}ʧ�ܣ�
 echo �洢���̷�����Ϣ:$return_msg
 exit 300
fi
echo �洢���̷�����Ϣ:$return_msg
return_val=`echo $return_msg | awk -F" " '{print $13}'`
db2 +o connect reset
echo ����ֵ=${return_val}
exit $return_val
