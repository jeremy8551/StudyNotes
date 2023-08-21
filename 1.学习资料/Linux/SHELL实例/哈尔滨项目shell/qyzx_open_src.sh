#!/bin/sh

# 初始化参数
source qyzx_param.sh

# 用法
function usage() {
  echo "Usage: grzx_open_src.sh [-d 数据日期] [-n 装数任务号(为空表示装载全部文本)]"
  echo "用途: 装载指定日期的个人征信数据"
  echo " -d 数据日期,格式: yyyyMMdd"
  echo " -n 选项:"
  for i in "${!qyzx_src[@]}"; do
    echo "    $i - ${qyzx_src_note[$i]} ${qyzx_src[$i]}"
  done
  echo " "
  echo "命令: grzx_open_src.sh -d 20090831 -n 0,1 "
}

# 装数
function _load_file() {
  load_file_tmp=$1
  load_table=$2
  if [ ! -f $load_file_tmp ]; then
    echo "____找不到文件: $load_file_tmp"
    db2 +o connect reset 
    exit 112
  fi
  btime=`date +%s`
  ermsg=`db2 "LOAD CLIENT FROM ${load_file_tmp} OF DEL REPLACE INTO ${load_table} ALLOW NO ACCESS "`
  rs=$?
  if [ $rs -ne 0 -a $rs -ne 2 ]; then
    echo "____发生错误: [$ermsg]"
    db2 +o connect reset 
    exit 113
  fi
  etime=`date +%s`
  utime=$((etime-btime))
  echo "____执行完毕, 用时=$((utime/60))分$((utime%60))秒"
  return 0
}

# 判断参数是否为空
if [ "$#" == "0" ]; then
  usage
  exit 110
fi
while getopts "d:n:" name; do
  case $name in
  d)
    DATA_DATE=$OPTARG
    if [[ ! "$DATA_DATE" =~ "^[0-9]{4}[0-9]{2}[0-9]{2}$" ]]; then
      usage
      exit 110
    fi
    ;;
  n)
    TASK_FLOWS=$OPTARG
    _str_split "$TASK_FLOWS" ","
    ;;
  ?)
    usage 
    exit 110
  esac
done

# 初始化参数
if [ "$DATA_DATE" == "" ]; then
  echo "-d 必选参数不能为空"
  usage
  exit 110
fi

# 设置数据文本所在目录
DATA_DIR="${qyzx_o_dir}/${DATA_DATE}"
if [ ! -d $DATA_DIR ]; then
  echo "____找不到目录: $DATA_DIR"
  exit 111
fi

# 设置调度
if [ "${TASK_FLOWS}" == "" ]; then
  TASK_FLOWS="ALL FLOW"
  echo "____装载日期=【$DATA_DATE】的数据,文本目录=【$DATA_DIR】"
  for i in "${!qyzx_src[@]}"; do
    str_array[$i]=${qyzx_src[$i]}
  done
else
  echo "____调度顺序: "
  for i in "${!str_array[@]}"; do
    echo "    $i - ${qyzx_src_note[$i]} ${qyzx_src[$i]} "
  done
fi

# 打开数据库连接
_open_db

# 新建任务
qyzx_y=`expr substr "$DATA_DATE" 1 4`
qyzx_m=`expr substr "$DATA_DATE" 5 2`
qyzx_d=`expr substr "$DATA_DATE" 7 2`
qyzx_workdate="${qyzx_y}-${qyzx_m}-${qyzx_d}"
_ddl_cmd "INSERT INTO QYZX_DATA_INFO (UDSF_WORKDATE, QYZX_WORKDATE, TASK_FLOW, EXPORT_FLAG, EXPORT_DIR) VALUES ('$qyzx_workdate', '$qyzx_workdate', '$TASK_FLOWS', '999', '$DATA_DIR')"

# 装载数据
for i in "${!str_array[@]}"; do
  echo "____正在装载: $i ${qyzx_src_note[$i]} (${qyzx_src[$i]})"
  _ddl_cmd "UPDATE QYZX_DATA_INFO SET TASK_CURR_FLOW = '$i' WHERE task_id = (select max(task_id) from QYZX_DATA_INFO) "
  _load_file "${DATA_DIR}/${qyzx_src[$i]}.del" "${qyzx_src[$i]}"
done

# 设置执行完毕标识
_ddl_cmd "UPDATE QYZX_DATA_INFO SET TASK_CURR_FLOW = '999' WHERE task_id = (select max(task_id) from QYZX_DATA_INFO) "
echo "数据源初始化完毕."

db2 +o connect reset 
exit 0
