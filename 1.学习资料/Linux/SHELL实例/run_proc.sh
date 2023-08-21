#!/bin/sh
#功    能：调db2存储过程
#参    数：-n 存储过程名字
#开发时间：2009-02-11
#  开发人：李洪涛
#所属公司：宇信易诚
usage()
{
    echo "run_proc.sh -n 存储过程名字 [-d] "
}
#参数检查和赋值
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
#链接数据库
db2 +o connect to $db2_connect_str
if [ $? -ne 0 ]
then
 echo 链接数据库失败！
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
 echo 运行存储过程${proc_name}失败！
 echo 存储过程返回消息:$return_msg
 exit 300
fi
echo 存储过程返回消息:$return_msg
return_val=`echo $return_msg | awk -F" " '{print $13}'`
db2 +o connect reset
echo 返回值=${return_val}
exit $return_val
