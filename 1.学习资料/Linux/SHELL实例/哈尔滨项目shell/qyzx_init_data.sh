#!/bin/sh

# 初始化参数
source qyzx_param.sh

usage() {
  echo "Function: 初始化企业征信数据源 "
  echo "Usage: qyzx_init_data.sh [-a] [-r] [-n flow1,flow2...] "
  echo "Option:"
  echo "    -a  [默认执行]"
  echo "    -r  [重组数据源: 重组索引,基本信息统计,分布信息统计]"
  echo "    -n  [执行指定的任务序列(优先级没有 [-a]选项 高): 编号1,编号2,编号3...] "
  for i in "${!qyzx_crd[@]}"; do
    echo "       $i - ${qyzx_src_note[$i]} [${qyzx_src[$i]}]"
  done
  echo " "
  echo "    示例: 初始化 客户登记表,借据信息表,汇票表"
  echo "    命令: qyzx_init_data.sh -n 0,10,17 -r "
}

if [ "$#" == "0" ]; then
  usage
  exit 51
fi
while getopts "arn:" op_name; do
  case $op_name in
  a)
    # 执行所有任务
    QYZX_ALL_TASK=1
    ;;
  n)
    # 执行指定任务
    QYZX_FLOWS="$OPTARG"
    _str_split $QYZX_FLOWS ","
    ;;
  r)
    # 重组数据源
    QYZX_RERUN_DATA=1
    ;;
  ?)
    usage 
    exit 51
  esac
done 

if [ "$QYZX_ALL_TASK" != "1" -a "${#str_array[@]}" != "0" ]; then 
  echo "调度顺序: "
  for i in "${!str_array[@]}"; do
    echo "    $i - ${qyzx_src_note[$i]} [${qyzx_src[$i]}]"
  done
else 
  QYZX_FLOWS="ALL FLOW"
  for i in "${!qyzx_crd[@]}"; do
    str_array[$i]=${qyzx_crd[$i]}
  done
fi

# 初始化指定表
function _init_table() {
  TABLE_NAME=$1
  TABLE_NAME_QYZX="${TABLE_NAME}_QYZX"
  echo "初始化表: ${TABLE_NAME_QYZX}"
#return 0
#  ermsg=`db2 -x "ALTER TABLE ${TABLE_NAME_QYZX} ACTIVATE NOT LOGGED INITIALLY WITH EMPTY TABLE"`
  ermsg=`db2 -x "load from /dev/null of del replace into ${TABLE_NAME_QYZX} "`
  rs=$?
  if [ $rs -ne 0 -a $rs -ne 2 ]; then
    echo "发生错误: [返回值=$rs, $ermsg]"
    echo "错误命令: [清空表${TABLE_NAME_QYZX}时,发生错误!]"
    db2 +o connect reset 
    exit 52
  fi
  ermsg=`db2 -x "INSERT INTO ${TABLE_NAME_QYZX} SELECT * FROM ${TABLE_NAME}"`
  rs=$?
  if [ $rs -ne 0 -a $rs -ne 2 -a $rs -ne 1 ]; then
    echo "发生错误: [返回值=$rs, $ermsg]"
    echo "错误命令: [INSERT INTO ${TABLE_NAME_QYZX} SELECT * FROM ${TABLE_NAME}]"
    db2 +o connect reset 
    exit 53
  fi
  return 0
}

# 功能:初始化数据源
function _init_data() {
  echo "正在初始化数据源..."
  # 取得数据仓库当前信贷系统数据的信息
  udsf_task_info=`db2 -x "SELECT RTRIM(CHAR(MAX(task_flag)))||'_'||RTRIM(CHAR(MAX(task_etl_date))) FROM SYS_TASK_RUN_INFO WHERE TASK_GROUP='LNA_I2O' "`
  udsf_task_flag=`echo ${udsf_task_info} | awk -F"_" '{print $1}'`
  if [ "${udsf_task_flag}" == "1" ]; then
    echo "数据仓库中信贷系统数据有错误(有task_flag=1的表)."
    return 57
  fi
  # 数据仓库的信贷数据的日期
  udsf_workdate=`echo ${udsf_task_info} | awk -F"_" '{print $2}'`
  # 取得当前企业征信数据源的数据日期
  qyzx_workdate=`db2 -x "SELECT COALESCE(qyzx_workdate, '') FROM QYZX_DATA_INFO where TASK_CURR_FLOW = '999' ORDER BY TASK_ID DESC FETCH FIRST 1 ROWS ONLY WITH UR "`
  echo "数据仓库当前日期【$udsf_workdate】 数据源当前日期【$qyzx_workdate】 "
  if [[ "$udsf_workdate" =~ "^[0-9]{4}-[0-9]{2}-[0-9]{2}$" ]]; then
    if [[ "$qyzx_workdate" =~ "^[0-9]{4}-[0-9]{2}-[0-9]{2}$" ]]; then
      if [[ ! $udsf_workdate > $qyzx_workdate ]]; then
        echo "初始化数据源失败,原因: 数据仓库日期 ${udsf_workdate} 必须大于 数据源日期 ${qyzx_workdate}"
        return 54
      fi
    fi
  else
    echo "初始化数据源失败,原因: 数据仓库当前数据日期不合法! [workdate=$udsf_workdate]"
    return 55
  fi

  # 创建 数据源 信息
  _ddl_cmd "INSERT INTO QYZX_DATA_INFO (UDSF_WORKDATE, QYZX_WORKDATE, TASK_FLOW) VALUES ('$udsf_workdate', '$udsf_workdate', '$QYZX_FLOWS')"
  QYZX_TASK_ID=`db2 -x "SELECT task_id FROM QYZX_DATA_INFO ORDER BY TASK_ID DESC FETCH FIRST 1 ROWS ONLY WITH UR "`
  if [ "$QYZX_TASK_ID" == "" ]; then
    echo "初始化数据源失败,原因:查询数据源信息表(QYZX_DATA_INFO)中的任务序号为空"
    return 56
  fi
  
  # 初始化
  for i in "${!str_array[@]}"; do
    _ddl_cmd "UPDATE QYZX_DATA_INFO SET TASK_CURR_FLOW = '$i' WHERE task_id = $QYZX_TASK_ID "
    _init_table "${qyzx_crd[$i]}"
  done
  
  # 设置执行完毕标识  
  _ddl_cmd "UPDATE QYZX_DATA_INFO SET TASK_CURR_FLOW = '999' WHERE task_id = $QYZX_TASK_ID "
  echo "数据源初始化完毕."
  
  # 备份企业征信历史数据
  #SAVE_DIR=`echo ${udsf_workdate} | awk -F"-" '{print $1$2$3}'`
  #echo "备份企业征信报送表数据到目录: /home/udsf/shell/qyzx/r_file/${SAVE_DIR}"
  #/home/udsf/shell/qyzx/r_file/qyzx_save_ECC_R.sh -d "${SAVE_DIR}"
  #echo "备份历史数据完成!"
  return 0
}


_open_db
_init_data
exitFlag=$?
db2 +o connect reset

exit $exitFlag
