#!/bin/sh

# 初始化参数
source qyzx_param.sh

# 用法
function usage() {
  echo "Function: 生成征信数据模型到中间表中 "
  echo "Usage: qyzx_task_run.sh [-a] [-n flow1,flow2...] "
  echo "Option:"
  echo "    -a  [默认执行所有功能]"
  echo "    -n  [执行指定的任务序列(优先级没有 [-a]选项 高): 编号1,编号2,编号3...] "
  for i in "${!proc_id[@]}"; do
    echo "       $i - ${proc_id[$i]} [${proc_name[$i]}]"
  done
  echo " "
  echo " 示例: 生成 0-借款人概况信息,11-贷款业务信"
  echo " 命令: qyzx_task_run.sh -n 0,11 "
}

# 编译存储过程
function _rebind_proc() {
  proc_name_tmp=$1
  echo ____正在编译...
  proc_id_tmp=`db2 -x "SELECT RTRIM(routineschema)||'.'||'P'||SUBSTR(CHAR(lib_id+10000000),2) FROM SYSCAT.routines WHERE routinename='$proc_name_tmp' with ur "`
  if [ "$proc_id_tmp" == "" ]; then
    echo "____编译错误: 找不到存储过程【$proc_name_tmp】"
    db2 +o connect reset 
    exit 78
  fi
  ermsg=`db2 -x "rebind package $proc_id_tmp resolve any "`
  rs=$?
  if [ $rs -ne 0 -a $rs -ne 2 ]; then
    echo "编译 $proc_id_tmp 发生错误: $ermsg"
    db2 +o connect reset 
    exit 75
  fi
  return 0
}

# 调用存储过程
function _progress() {
  echo ____正在执行...
  btime=`date +%s`
  produce_tmp=$1
  returnmsg=`db2 "call ${produce_tmp}(?)"`
  if [ $? -ne 0 ]; then
    echo "____运行存储过程${produce_tmp}失败!"
    echo "____返回消息: ${returnmsg}"
    db2 +o connect reset
    exit 76 
  fi
  returnvalue=`echo ${returnmsg} | awk -F" " '{print $13}'`
  if [ $returnvalue -ne 0 ]; then
    errmsg=`db2 -x "select (char(d.err_dt)||' '||char(d.err_time)||' '||d.err_message) as msg from (select c.* from (select a.* , rank() over(partition by name order by err_dt desc) as num from udsf_sys_err_log a where name='${produce_tmp}') c where c.num=1) d order by d.err_time desc fetch first 1 rows only with ur"`
    echo "____错误信息: ${errmsg}"
    db2 +o connect reset
    exit 77
  fi
  etime=`date +%s`
  utime=$((etime-btime))
  echo "____执行完毕, 用时=$((utime/60))分$((utime%60))秒"
  return 0
}

# 执行所有存储过程
function _execute_all() {
  # 任务号
  qyzx_task_id=$1
  for i in "${!str_array[@]}"; do
    echo "【${proc_name[$i]} - ${proc_id[$i]}】"
    _ddl_cmd "UPDATE QYZX_TASK set FIN_FLAG = '$i' where task_id = ${qyzx_task_id} "
    _rebind_proc "${proc_id[$i]}"
    _progress "${proc_id[$i]}"
    _ddl_cmd "UPDATE qyzx_task SET leave_flow = REPLACE(leave_flow, ',${i},', ',') WHERE task_id = ${qyzx_task_id} "
  done
}

# 如果正在执行企业征信接口程序,则退出
function _is_running() {
  ps_msg=`ps -C qyzx_task_run.sh -o pid= --sort=lstart`
  ps_count=`echo "${ps_msg}" | wc -l`
  if [ $ps_count -gt 1 ]; then
    curr_pid=`echo "${ps_msg}" | sed -n 1p`
    echo "发生错误: qyzx_task_run.sh 正在执行, pid : ${curr_pid}"
    exit 70
  fi
}

# 解析选项
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
  echo "调度顺序: "
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

# 如果当前正在执行 qyzx_task_run.sh 则退出
_is_running

# 打开数据库连接
_open_db

# 获取数据源当前信息
select_str=`db2 -x "SELECT RTRIM(CHAR(TASK_ID))||'_'||QYZX_WORKDATE||'_'||UDSF_WORKDATE||'_'||TASK_CURR_FLOW||'_'||ERROR_FLAG FROM qyzx_data_info ORDER BY TASK_ID DESC FETCH FIRST 1 ROWS ONLY"`
if [ $? -ne 0 ]; then
  echo "获取数据源当前信息失败, 返回值【$?】错误信息【$select_str】"
  db2 +o connect reset 
  exit 71
fi
data_task_id=`echo ${select_str} | awk -F"_" '{print $1}'`
qyzx_workdate=`echo ${select_str} | awk -F"_" '{print $2}'`
udsf_workdate=`echo ${select_str} | awk -F"_" '{print $3}'`
task_curr_flow=`echo ${select_str} | awk -F"_" '{print $4}'`
task_err_code=`echo ${select_str} | awk -F"_" '{print $5}'`

# 判断当前数据源是否正确
if [ "$task_err_code" != "000" ]; then
  echo "不能执行,数据源中有错误,错误代码=【$task_err_code】"
  db2 +o connect reset 
  exit 73
fi

# 判断数据源是否初始化完毕
if [ "$task_curr_flow" != "999" ]; then
  echo "数据源还没有初始化完毕,请过一段时间执行"
  db2 +o connect reset 
  exit 72
fi

# 取得上一次报送的数据日期
last_report_date=`db2 -x "SELECT COALESCE(MAX(ywdate), '') FROM eccd_finish"`
if [[ ! "$last_report_date" =~ "^[0-9]{4}-[0-9]{2}-[0-9]{2}$" ]]; then
  echo "查询上次上报的数据日期错误,错误信息【$last_report_date】"
  exit 79 
fi

# 执行接口任务
if [ "$QYZX_ALL" == "1" -o "${#str_array[@]}" == "${#proc_id[@]}" ]; then 
  _ddl_cmd "INSERT INTO QYZX_TASK (DATA_INFO_TASK_ID,QYZX_DATE,UDSF_WORKDATE,COMPARE_DATE,TASK_FLOW,LEAVE_FLOW,TASK_MSG) VALUES ($data_task_id,'$qyzx_workdate','$udsf_workdate','$last_report_date','$TASK_FLOWS','$TASK_FLOWS','') "
fi

# 获取当前任务号
task_id=`db2 -x "SELECT COALESCE(task_id, -1) FROM qyzx_task ORDER BY task_id DESC FETCH FIRST 1 ROWS ONLY "`
if [ "$task_id" == "" -o "$task_id" == "-1" ]; then
  echo "查询任务号错误"
  db2 +o connect reset 
  exit 74
fi

# 执行任务序列
_execute_all "$task_id"

# 判断当前任务是否完成,如果完成则设置 完成标志='99'
_ddl_cmd "UPDATE qyzx_task SET over_time = current_timestamp, fin_flag = CASE WHEN leave_flow IS NULL OR RTRIM(leave_flow) = ',' THEN '99' ELSE fin_flag END WHERE task_id = $task_id "

db2 +o connect reset 
exit 0
