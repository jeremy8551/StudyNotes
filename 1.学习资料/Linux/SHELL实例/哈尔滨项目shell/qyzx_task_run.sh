#!/bin/sh

# ��ʼ������
source qyzx_param.sh

# �÷�
function usage() {
  echo "Function: ������������ģ�͵��м���� "
  echo "Usage: qyzx_task_run.sh [-a] [-n flow1,flow2...] "
  echo "Option:"
  echo "    -a  [Ĭ��ִ�����й���]"
  echo "    -n  [ִ��ָ������������(���ȼ�û�� [-a]ѡ�� ��): ���1,���2,���3...] "
  for i in "${!proc_id[@]}"; do
    echo "       $i - ${proc_id[$i]} [${proc_name[$i]}]"
  done
  echo " "
  echo " ʾ��: ���� 0-����˸ſ���Ϣ,11-����ҵ����"
  echo " ����: qyzx_task_run.sh -n 0,11 "
}

# ����洢����
function _rebind_proc() {
  proc_name_tmp=$1
  echo ____���ڱ���...
  proc_id_tmp=`db2 -x "SELECT RTRIM(routineschema)||'.'||'P'||SUBSTR(CHAR(lib_id+10000000),2) FROM SYSCAT.routines WHERE routinename='$proc_name_tmp' with ur "`
  if [ "$proc_id_tmp" == "" ]; then
    echo "____�������: �Ҳ����洢���̡�$proc_name_tmp��"
    db2 +o connect reset 
    exit 78
  fi
  ermsg=`db2 -x "rebind package $proc_id_tmp resolve any "`
  rs=$?
  if [ $rs -ne 0 -a $rs -ne 2 ]; then
    echo "���� $proc_id_tmp ��������: $ermsg"
    db2 +o connect reset 
    exit 75
  fi
  return 0
}

# ���ô洢����
function _progress() {
  echo ____����ִ��...
  btime=`date +%s`
  produce_tmp=$1
  returnmsg=`db2 "call ${produce_tmp}(?)"`
  if [ $? -ne 0 ]; then
    echo "____���д洢����${produce_tmp}ʧ��!"
    echo "____������Ϣ: ${returnmsg}"
    db2 +o connect reset
    exit 76 
  fi
  returnvalue=`echo ${returnmsg} | awk -F" " '{print $13}'`
  if [ $returnvalue -ne 0 ]; then
    errmsg=`db2 -x "select (char(d.err_dt)||' '||char(d.err_time)||' '||d.err_message) as msg from (select c.* from (select a.* , rank() over(partition by name order by err_dt desc) as num from udsf_sys_err_log a where name='${produce_tmp}') c where c.num=1) d order by d.err_time desc fetch first 1 rows only with ur"`
    echo "____������Ϣ: ${errmsg}"
    db2 +o connect reset
    exit 77
  fi
  etime=`date +%s`
  utime=$((etime-btime))
  echo "____ִ�����, ��ʱ=$((utime/60))��$((utime%60))��"
  return 0
}

# ִ�����д洢����
function _execute_all() {
  # �����
  qyzx_task_id=$1
  for i in "${!str_array[@]}"; do
    echo "��${proc_name[$i]} - ${proc_id[$i]}��"
    _ddl_cmd "UPDATE QYZX_TASK set FIN_FLAG = '$i' where task_id = ${qyzx_task_id} "
    _rebind_proc "${proc_id[$i]}"
    _progress "${proc_id[$i]}"
    _ddl_cmd "UPDATE qyzx_task SET leave_flow = REPLACE(leave_flow, ',${i},', ',') WHERE task_id = ${qyzx_task_id} "
  done
}

# �������ִ����ҵ���Žӿڳ���,���˳�
function _is_running() {
  ps_msg=`ps -C qyzx_task_run.sh -o pid= --sort=lstart`
  ps_count=`echo "${ps_msg}" | wc -l`
  if [ $ps_count -gt 1 ]; then
    curr_pid=`echo "${ps_msg}" | sed -n 1p`
    echo "��������: qyzx_task_run.sh ����ִ��, pid : ${curr_pid}"
    exit 70
  fi
}

# ����ѡ��
if [ "$#" == "0" ]; then
  usage
  exit 70
fi
while getopts "an:" name; do
  case $name in
  a)
    QYZX_ALL=1
    ;;
  n)
    TASK_FLOWS=$OPTARG
    _str_split "$TASK_FLOWS" ","
    ;;
  ?)
    usage 
    exit 70
  esac
done
if [ "$QYZX_ALL" != "1" -a "${#str_array[@]}" != "0" ]; then 
  echo "����˳��: "
  for i in "${!str_array[@]}"; do
  echo "    $i - ${proc_name[$i]} [${proc_id[$i]}]"
  done
else 
  for i in "${!proc_id[@]}"; do
    str_array[$i]=${proc_id[$i]}
    TASK_FLOWS="${TASK_FLOWS},${i}"
  done
  TASK_FLOWS="${TASK_FLOWS},"
fi

# �����ǰ����ִ�� qyzx_task_run.sh ���˳�
_is_running

# �����ݿ�����
_open_db

# ��ȡ����Դ��ǰ��Ϣ
select_str=`db2 -x "SELECT RTRIM(CHAR(TASK_ID))||'_'||QYZX_WORKDATE||'_'||UDSF_WORKDATE||'_'||TASK_CURR_FLOW||'_'||ERROR_FLAG FROM qyzx_data_info ORDER BY TASK_ID DESC FETCH FIRST 1 ROWS ONLY"`
if [ $? -ne 0 ]; then
  echo "��ȡ����Դ��ǰ��Ϣʧ��, ����ֵ��$?��������Ϣ��$select_str��"
  db2 +o connect reset 
  exit 71
fi
data_task_id=`echo ${select_str} | awk -F"_" '{print $1}'`
qyzx_workdate=`echo ${select_str} | awk -F"_" '{print $2}'`
udsf_workdate=`echo ${select_str} | awk -F"_" '{print $3}'`
task_curr_flow=`echo ${select_str} | awk -F"_" '{print $4}'`
task_err_code=`echo ${select_str} | awk -F"_" '{print $5}'`

# �жϵ�ǰ����Դ�Ƿ���ȷ
if [ "$task_err_code" != "000" ]; then
  echo "����ִ��,����Դ���д���,�������=��$task_err_code��"
  db2 +o connect reset 
  exit 73
fi

# �ж�����Դ�Ƿ��ʼ�����
if [ "$task_curr_flow" != "999" ]; then
  echo "����Դ��û�г�ʼ�����,���һ��ʱ��ִ��"
  db2 +o connect reset 
  exit 72
fi

# ȡ����һ�α��͵���������
last_report_date=`db2 -x "SELECT COALESCE(MAX(ywdate), '') FROM eccd_finish"`
if [[ ! "$last_report_date" =~ "^[0-9]{4}-[0-9]{2}-[0-9]{2}$" ]]; then
  echo "��ѯ�ϴ��ϱ����������ڴ���,������Ϣ��$last_report_date��"
  exit 79 
fi

# ִ�нӿ�����
if [ "$QYZX_ALL" == "1" -o "${#str_array[@]}" == "${#proc_id[@]}" ]; then 
  _ddl_cmd "INSERT INTO QYZX_TASK (DATA_INFO_TASK_ID,QYZX_DATE,UDSF_WORKDATE,COMPARE_DATE,TASK_FLOW,LEAVE_FLOW,TASK_MSG) VALUES ($data_task_id,'$qyzx_workdate','$udsf_workdate','$last_report_date','$TASK_FLOWS','$TASK_FLOWS','') "
fi

# ��ȡ��ǰ�����
task_id=`db2 -x "SELECT COALESCE(task_id, -1) FROM qyzx_task ORDER BY task_id DESC FETCH FIRST 1 ROWS ONLY "`
if [ "$task_id" == "" -o "$task_id" == "-1" ]; then
  echo "��ѯ����Ŵ���"
  db2 +o connect reset 
  exit 74
fi

# ִ����������
_execute_all "$task_id"

# �жϵ�ǰ�����Ƿ����,������������ ��ɱ�־='99'
_ddl_cmd "UPDATE qyzx_task SET over_time = current_timestamp, fin_flag = CASE WHEN leave_flow IS NULL OR RTRIM(leave_flow) = ',' THEN '99' ELSE fin_flag END WHERE task_id = $task_id "

db2 +o connect reset 
exit 0
