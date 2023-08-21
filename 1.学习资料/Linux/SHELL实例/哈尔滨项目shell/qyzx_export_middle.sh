#!/bin/sh

# 初始化参数
source qyzx_param.sh

# 初始化中间表的卸数参数
_init_ecc

# 用法
function usage() {
  echo "Function: 把企业征信中间表里的数据卸载成文本(为剥离增量数据做准备)"
  echo "Usage: qyzx_export_middle.sh [-a] [-n 任务序列] [-p 目录] "
  echo "    -a [默认执行]"
  echo "    -p [文本存储目录]"
  echo "    -n [任务序列, 如果不赋值则默认卸载全部文本] 选项:"
  for i in "${!qyzx_ecc_id[@]}"; do
  echo "       $i - ${qyzx_ecc_id[$i]} "
  done
  echo " "
  echo "示例: 只想卸载: 0-QYZX_ECC_BORROWERS 和 1-QYZX_ECC_GRPCORPS 的数据"
  echo "命令: qyzx_export_middle.sh -n 1,7 "
}

# 执行命令
function _export_file() {
  export_file=$1
  export_sql=$2
  btime=`date +%s`
  ermsg=`db2 "export to $export_file of del $export_sql"`
  rs=$?
  if [ $rs -ne 0 -a $rs -ne 2 ]; then
    echo "____发生错误: [$ermsg]"
    echo "____错误代码: [$rs]"
    echo "____错误命令: [export to $export_file of del $export_sql]"
    exit_rs=85
    return 85
  fi
  etime=`date +%s`
  utime=$((etime-btime))
  echo "____执行完毕, 用时=$((utime/60))分$((utime%60))秒"
  return 0
}

# 设置导出文本信息
function _set_export_info() {
  sql_tmp=$1
  ermsg=`db2 -x "$sql_tmp"`
  rs=$?
  if [ $rs -ne 0 -a $rs -ne 2 ]; then
    echo "发生错误: [$ermsg]"
    echo "错误命令: [$sql_tmp]"
    db2 +o connect reset 
    exit 89
  fi
  return 0
}

# 初始化一些参数
function _init_some_param() {
  # 查询当前中间表数据的信息
  select_str=`db2 -x "SELECT RTRIM(CHAR(task_id))||'_'||CHAR(qyzx_date)||'_'||RTRIM(fin_flag)||'_'||RTRIM(error_flag) FROM qyzx_task ORDER BY task_id DESC FETCH FIRST 1 ROWS ONLY "`
  if [ $? -ne 0 -o "$select_str" == "" ]; then
    echo "加载中间信息错误"
    db2 +o connect reset 
    exit 81
  fi
  qyzx_task_id=`echo ${select_str} | awk -F"_" '{print $1}'`
  qyzx_task_data=`echo ${select_str} | awk -F"_" '{print $2}'`
  qyzx_task_fin_flag=`echo ${select_str} | awk -F"_" '{print $3}'`
  qyzx_task_error_flag=`echo ${select_str} | awk -F"_" '{print $4}'`
  if [ "$qyzx_task_fin_flag" != "99" ]; then
    if [ "$qyzx_task_error_flag" != "000" ]; then
      echo "生成中间表数据时发生错误【错误码=$qyzx_task_error_flag】,请先把错误处理完再卸数"
      db2 +o connect reset 
      exit 82
    fi
    echo "正在生成中间表数据,请等会再执行!"
    db2 +o connect reset 
    exit 83
  fi
  echo "中间表当前数据的信息:任务号【$qyzx_task_id】数据日期【$qyzx_task_data】"

  # 设置数据日期
  QYZX_DATE=`echo ${qyzx_task_data} | awk -F"-" '{print $1$2$3}'`
  if [[ ! "$QYZX_DATE" =~ "^[0-9]{4}[0-9]{2}[0-9]{2}$" ]]; then 
    echo "中间表当前数据日期的格式错误,【日期:$QYZX_DATE】"
    db2 +o connect reset 
    exit 84
  fi
  
  # 设置任务序列  
  if [ "$QYZX_ALL" != "1" -a "${#str_array[@]}" != "0" ]; then 
    echo "调度顺序: "
    for i in "${!str_array[@]}"; do
      echo "    $i - ${qyzx_ecc_id[$i]} "
    done
  else 
    QYZX_FLOWS="ALL FLOW"
    for i in "${!qyzx_ecc_id[@]}"; do
      str_array[$i]=${qyzx_ecc_id[$i]}
    done
  fi
  
  # 设置存储文本的目录
  if [ "$qyzx_curr_m_dir" == "" ]; then
    qyzx_curr_m_dir="${qyzx_m_dir}/${QYZX_DATE}"
  fi
  _mk_dir "$qyzx_curr_m_dir"
  
  # 初始化返回值
  exit_rs=0
}

# 解析选项
if [ "$#" == "0" ]; then
  usage
  exit 80
fi
while getopts "ap:n:" name; do
  case $name in
  a)
    QYZX_ALL=1
    ;;
  p)
    qyzx_curr_m_dir=$OPTARG
    ;;
  n)
    QYZX_FLOWS=$OPTARG
    _str_split "$QYZX_FLOWS" ","
    ;;
  ?)
    usage 
    exit 80
  esac
done

# 链接UDSF数据库
_open_db

# 初始化参数
_init_some_param

# 设置任务序列
_set_export_info "update QYZX_TASK set EXPORT_FLOWS='${QYZX_FLOWS}', EXPORT_ERROR='' where TASK_ID = $qyzx_task_id "

# 卸数
for i in "${!str_array[@]}"; do
  echo "____正在卸载: $i - ${qyzx_ecc_id[$i]}"
  _export_file "${qyzx_curr_m_dir}/${qyzx_ecc_id[$i]}.del" "${qyzx_ecc_sql[$i]}"
  if [ $? -ne 0 ]; then
    _set_export_info "update QYZX_TASK set EXPORT_ERROR = RTRIM(EXPORT_ERROR)||',${i}' where TASK_ID = $qyzx_task_id "
  fi
done

db2 +o connect reset 
exit $exit_rs
