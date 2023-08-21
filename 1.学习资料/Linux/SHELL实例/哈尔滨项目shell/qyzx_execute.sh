#!/bin/sh

# 初始化参数
source qyzx_param.sh

# 初始化日志
_mk_log

echo "************************************************************************" >> $qyzx_log
echo "*                 【征信接口】开始执行企业征信接口程序                 *" >> $qyzx_log
echo "************************************************************************" >> $qyzx_log
echo "***系统启动时间: `date +%F_%T`" >> $qyzx_log

# 生成征信数据模型
remsg=`qyzx_task_run.sh -a >> $qyzx_log`
task_res=$?
if [ $task_res -ne 0 ]; then
  echo "生成数据模型发生错误,返回值【$task_res】" >> $qyzx_log
  _open_db
  msg=`db2 "update QYZX_TASK set ERROR_FLAG = '$task_res' where TASK_ID = (select max(TASK_ID) from QYZX_TASK) "`
  db2 +o connect reset
  echo "***执行结束时间: `date +%F_%T`" >> $qyzx_log
  exit $task_res
fi

# 导出数据模型
remsg=`qyzx_export_middle.sh -a >> $qyzx_log`
task_res=$?
if [ $task_res -ne 0 ]; then
  echo "导出数据模型发生错误,返回值【$task_res】,错误信息【$remsg】" >> $qyzx_log
  _open_db
  msg=`db2 "update QYZX_TASK set ERROR_FLAG = '$task_res' where TASK_ID = (select max(TASK_ID) from QYZX_TASK) "`
  db2 +o connect reset
  echo "***执行结束时间: `date +%F_%T`" >> $qyzx_log
  exit $task_res
fi

# 剥离增量
remsg=`qyzx_create_inc.sh -a >> $qyzx_log`
task_res=$?
if [ $task_res -ne 0 ]; then
  echo "剥离增量到接口表中发生错误,返回值【$task_res】,错误信息【$remsg】" >> $qyzx_log
  _open_db
  msg=`db2 "update QYZX_TASK set ERROR_FLAG = '$task_res' where TASK_ID = (select max(TASK_ID) from QYZX_TASK) "`
  db2 +o connect reset
  echo "***执行结束时间: `date +%F_%T`" >> $qyzx_log
  exit $task_res
fi

echo "***执行结束时间: `date +%F_%T`" >> $qyzx_log
exit 0
