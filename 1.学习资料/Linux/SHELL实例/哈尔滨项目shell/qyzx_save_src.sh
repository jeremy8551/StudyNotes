#!/bin/sh

# 初始化参数
source qyzx_param.sh

# 用法
usage() {
  echo "Usage: qyzx_save_src.sh [-a]  [-n 任务序列]"
  echo "    -a [卸载所有数据]  "
  echo "    -n [装载任务号] [flow1,flow2...] 选项:"
  for i in "${!qyzx_src[@]}"; do
    echo "      $i - ${qyzx_src_note[$i]} (${qyzx_src[$i]})"
  done
  echo " "
}

# 判断参数是否为空
if [ "$#" == "0" ]; then
  usage
  exit 100
fi
while getopts "an:" name; do
  case $name in
  a)
    EXECUTE_ALL=1
    ;;
  n)
    _str_split "$OPTARG" ","
    ;;
  ?)
    usage 
    exit 100
  esac
done

# 设置调度顺序
if [ "$EXECUTE_ALL" == "1" -o ${#str_array[@]} == 0 ]; then
  echo "____卸载数据源所有信息"
  for i in "${!qyzx_src[@]}"; do
    str_array[$i]=${qyzx_src[$i]}
  done
else
  echo "____调度顺序: "
  for i in "${!str_array[@]}"; do
    echo "    $i - ${qyzx_src_note[$i]} ${qyzx_src[$i]}"
  done
fi

# 数据库连接
_open_db

# 获取数据源当前数据的日期
DATA_DATE=`db2 -x "select coalesce(QYZX_WORKDATE, '') from QYZX_DATA_INFO order by TASK_ID desc fetch first 1 rows only"`
if [[ ! "$DATA_DATE" =~ "^[0-9]{4}-[0-9]{2}-[0-9]{2}$" ]]; then
  echo "____获取当前数据源数据的日期发生错误,【$DATA_DATE】"
  db2 +o connect reset 
  exit 101
fi

# 创建数据源文本目录
DATA_DATE_DIR=`echo ${DATA_DATE} | awk -F"-" '{print $1$2$3}'`
DATA_DATE_DIR=${qyzx_o_dir}/${DATA_DATE_DIR}
if [ ! -d ${DATA_DATE_DIR} ]; then
  mkdir ${DATA_DATE_DIR}
  if [ $? -ne 0 ]; then
    echo "____建立目录【${DATA_DATE_DIR}】失败,返回代码=$?"
    db2 +o connect reset 
    exit 102
  fi
fi 

# 设置卸数sql语句
for i in "${!qyzx_src[@]}"; do 
  qyzx_src_export_sql[$i]="select * from ${qyzx_src[$i]} with ur"
done

# 执行卸数
for i in "${!str_array[@]}"; do
  echo "____正在卸载: $i - ${qyzx_src_note[$i]} ${qyzx_src[$i]}"
  export_file_tmp="${DATA_DATE_DIR}/${qyzx_src[$i]}.del"
  export_sql_tmp="${qyzx_src_export_sql[$i]}"
  btime=`date +%s`
  ermsg=`db2 "export to ${export_file_tmp} of del ${export_sql_tmp}"`
  if [ $? -ne 0 -a $? -ne 2 ]; then
    echo "____export命令发生错误: [$ermsg]"
    db2 +o connect reset 
    exit 103
  fi
  etime=`date +%s`
  utime=$((etime-btime))
  echo "____执行完毕, 用时=$((utime/60))分$((utime%60))秒"
done

# 设置卸载数据源完成标志
if [ "$EXECUTE_ALL" == "1" ]; then
  msg=`db2 "update QYZX_DATA_INFO set EXPORT_FLAG = '999', EXPORT_DIR='${DATA_DATE_DIR}' where TASK_ID = (select max(TASK_ID) from QYZX_DATA_INFO)"`
  if [ $? -ne 0 -a $? -ne 2 ]; then
    echo "____设置:卸载数据源文本完成标志错误,返回值:【$?】错误信息:【$msg】"
    db2 +o connect reset 
    exit 104
  fi
fi

db2 +o connect reset 
exit 0


