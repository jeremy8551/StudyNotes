#!/bin/sh

# ��ʼ������
source qyzx_param.sh

# ��ʼ����־
_mk_log

echo "************************************************************************" >> $qyzx_log
echo "*                 �����Žӿڡ���ʼִ����ҵ���Žӿڳ���                 *" >> $qyzx_log
echo "************************************************************************" >> $qyzx_log
echo "***ϵͳ����ʱ��: `date +%F_%T`" >> $qyzx_log

# ������������ģ��
remsg=`qyzx_task_run.sh -a >> $qyzx_log`
task_res=$?
if [ $task_res -ne 0 ]; then
  echo "��������ģ�ͷ�������,����ֵ��$task_res��" >> $qyzx_log
  _open_db
  msg=`db2 "update QYZX_TASK set ERROR_FLAG = '$task_res' where TASK_ID = (select max(TASK_ID) from QYZX_TASK) "`
  db2 +o connect reset
  echo "***ִ�н���ʱ��: `date +%F_%T`" >> $qyzx_log
  exit $task_res
fi

# ��������ģ��
remsg=`qyzx_export_middle.sh -a >> $qyzx_log`
task_res=$?
if [ $task_res -ne 0 ]; then
  echo "��������ģ�ͷ�������,����ֵ��$task_res��,������Ϣ��$remsg��" >> $qyzx_log
  _open_db
  msg=`db2 "update QYZX_TASK set ERROR_FLAG = '$task_res' where TASK_ID = (select max(TASK_ID) from QYZX_TASK) "`
  db2 +o connect reset
  echo "***ִ�н���ʱ��: `date +%F_%T`" >> $qyzx_log
  exit $task_res
fi

# ��������
remsg=`qyzx_create_inc.sh -a >> $qyzx_log`
task_res=$?
if [ $task_res -ne 0 ]; then
  echo "�����������ӿڱ��з�������,����ֵ��$task_res��,������Ϣ��$remsg��" >> $qyzx_log
  _open_db
  msg=`db2 "update QYZX_TASK set ERROR_FLAG = '$task_res' where TASK_ID = (select max(TASK_ID) from QYZX_TASK) "`
  db2 +o connect reset
  echo "***ִ�н���ʱ��: `date +%F_%T`" >> $qyzx_log
  exit $task_res
fi

echo "***ִ�н���ʱ��: `date +%F_%T`" >> $qyzx_log
exit 0
