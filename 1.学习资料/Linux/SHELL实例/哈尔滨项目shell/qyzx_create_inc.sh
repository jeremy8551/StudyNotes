#!/bin/sh

# 初始化参数
source qyzx_param.sh

# 初始化参数
_init_ecc

# 用法
usage() {
  echo "Function: 生成增量数据到企业征信接口表"
  echo "Usage: qyzx_create_inc.sh [-a] [-d 增量日期] [-c 增量对比日期] [-n flow1,flow2...] "
  echo "Option:"
  echo "    -a  [默认执行,忽略其他选项]"
  echo "    -d  [剥离增量日期yyyyMMdd]"
  echo "    -c  [增量对比日期yyyyMMdd]"
  echo "    -n  [执行指定的任务序列(优先级没有 [-a]选项 高): 编号1,编号2,编号3...] "
  for i in "${!qyzx_ecc_id[@]}"; do
  echo "        $i - ${qyzx_ecc_name[$i]} ${qyzx_ecc_id[$i]}"
  done
  echo " "
  echo "    示例: 剥离20090801到20090831之间的 1-借款人基本信息,12-借据展期信息"
  echo "    命令: ./qyzx_create_inc.sh -d 20090831 -c 20090801 -n 1,12 "
}

# 初始化参数
function _init_some_param() {
  # 自定义执行
  if [ "$QYZX_ALL_TASK" != "1" ]; then
    if [ "$QYZX_COM_DATE" == "" -o "$QYZX_INC_DATE" == "" -o "$QYZX_FLOWS" == "" ]; then
      echo "参数错误"
      exit 90
    fi
    
    # 设置执行顺序
    echo "调度顺序: "
    for i in "${!str_array[@]}"; do
      echo "    $i - ${qyzx_ecc_id[$i]} "
    done
  else 
  # 默认执行
    # 打开数据库连接
    _open_db
    
    # 设置执行顺序    
    QYZX_FLOWS="ALL FLOW"
    for i in "${!qyzx_ecc_id[@]}"; do
      str_array[$i]=${qyzx_ecc_id[$i]}
    done
    
    # 当前中间表数据的信息        
    str_tmp=`db2 -x "SELECT RTRIM(CHAR(task_id))||'_'||CHAR(qyzx_date)||'_'||RTRIM(fin_flag)||'_'||CHAR(compare_date) FROM QYZX_TASK ORDER BY task_id DESC FETCH FIRST 1 ROWS ONLY "`
    if [ $? -ne 0 -o "$str_tmp" == "" ]; then
      echo "加载数据模型信息错误,错误信息【$str_tmp】"
      db2 +o connect reset
      exit 92
    fi
    
    # 中间表当前任务号    
    QYZX_TASK_ID=`echo ${str_tmp} | awk -F"_" '{print $1}'`
    
    # 增量日期
    QYZX_TASK_DATE=`echo ${str_tmp} | awk -F"_" '{print $2}'`
    
    # 中间表数据的完成标志   
    QYZX_TASK_FLAG=`echo ${str_tmp} | awk -F"_" '{print $3}'`
    
    # 对比增量日期【征信上次上报增量的日期】  
    QYZX_COM_DATE=`echo ${str_tmp} | awk -F"_" '{print $4}'`
    if [[ ! "$QYZX_COM_DATE" =~ "^[0-9]{4}-[0-9]{2}-[0-9]{2}$" ]]; then
      echo "增量日期格式错误,增量日期【$QYZX_COM_DATE】"
      db2 +o connect reset
      exit 91
    fi
    
    # 格式化日期 yyyyMMdd
    QYZX_INC_DATE=`echo ${QYZX_TASK_DATE} | awk -F"-" '{print $1$2$3}'`
    QYZX_COM_DATE=`echo ${QYZX_COM_DATE} | awk -F"-" '{print $1$2$3}'`
    
    # 关闭数据库连接
    db2 +o connect reset 
  fi
  
  # 增量日期的前一天
  inc_y=`expr substr "$QYZX_INC_DATE" 1 4`
  inc_m=`expr substr "$QYZX_INC_DATE" 5 2`
  inc_d=`expr substr "$QYZX_INC_DATE" 7 2`
  QYZX_INC_LAST_DATE=`date -d "${inc_y}-${inc_m}-${inc_d} yesterday" +%F`
  QYZX_INC_LAST_DATE=`echo ${QYZX_INC_LAST_DATE} | awk -F"-" '{print $1$2$3}'`
  return 0
}

# 剥离增量数据
function _incr_data() {
  # 增量日期 
  inc_date=$1
  # 增量日期的前一天
  inc_last_date=$2
  # 对比数据日期  
  compare_date=$3
  # 返回值  
  ret_result=0
  
  # 检查配置文件
  if [ ! -f "$qyzx_incr_cfg" ]; then
    echo "找不到配置文件【$qyzx_incr_cfg】"
    exit 93
  fi
  
  # 检查增量目录
  inc_dir=${qyzx_m_dir}/${inc_date}
  if [ ! -d $inc_dir ]; then
    echo "找不到增量数据的目录:$inc_dir"
    exit 94
  else 
    # 删除已经存在的增量文本
    for i in "${!str_array[@]}"; do
      if [ -f "${inc_dir}/INC_${qyzx_ecc_id[$i]}.del" ]; then
        echo "删除文件: ${inc_dir}/INC_${qyzx_ecc_id[$i]}.del"
        rm ${inc_dir}/INC_${qyzx_ecc_id[$i]}.del
      fi
    done
  fi
  
  # 对比文本所在目录
  compare_dir=${qyzx_m_dir}/${compare_date}
  if [ ! -d $compare_dir ]; then 
    echo "找不到对比文本的目录:$compare_dir"
    exit 95
  fi
  
  dir_change_log=${qyzx_m_dir}/dir_change_log.log 
  echo 执行时间:`date +%F_%T` >> $dir_change_log
  
  # 更改目录:把【对比文件目录名】改成【增量日期的前一天的目录名】
  if [ "$compare_date" != "$inc_last_date" ]; then
    if [ -d ${qyzx_m_dir}/$inc_last_date ]; then
      mv ${qyzx_m_dir}/${inc_last_date} ${qyzx_m_dir}/${inc_last_date}_temp 
      echo "mv ${qyzx_m_dir}/${inc_last_date} ${qyzx_m_dir}/${inc_last_date}_temp 返回值【$?】" #>> $dir_change_log
    fi
    mv ${compare_dir} ${qyzx_m_dir}/${inc_last_date} 
    echo "mv ${compare_dir} ${qyzx_m_dir}/${inc_last_date} 返回值【$?】" #>> $dir_change_log
  fi
  
  # 剥离增量
  
  echo "____剥离增量数据, 命令: incrMainXml ${inc_date} ${qyzx_incr_cfg}"
  btime=`date +%s`
  #替换2个日期的文件，将2个连续逗号(,,)为逗号+双引号+双引号+逗号(,"",)，否则无法进行增量剥离
  `qyzx_replace.sh -d ${inc_last_date}`
  `qyzx_replace.sh -d ${inc_date}`
  incrMainXml "${inc_date}" "${qyzx_incr_cfg}"
  rs=$?
  if [ $rs -ne 0 ]; then
    echo "____剥离增量发生错误,返回值【$rs】日志【$HOME/log/`date +%Y%m%d`/incrMain.log】"
    ret_result=96
  fi
  #替换2个日期的文件，将逗号+双引号+双引号+逗号(,"",)替换2个连续逗号(,,)否则无法装入数据库
  `qyzx_replace_re.sh -d ${inc_date}`
  etime=`date +%s`
  utime=$((etime-btime))
  echo "____执行完毕, 用时=$((utime/60))分$((utime%60))秒"
  
  # 撤销对目录的更改
  if [ "$compare_date" != "$inc_last_date" ]; then
    mv ${qyzx_m_dir}/${inc_last_date} ${compare_dir} 
    echo "mv ${qyzx_m_dir}/${inc_last_date} ${compare_dir} 返回值【$?】" #>> $dir_change_log
    if [ -d ${qyzx_m_dir}/${inc_last_date}_temp ]; then
      mv ${qyzx_m_dir}/${inc_last_date}_temp ${qyzx_m_dir}/${inc_last_date}
      echo "mv ${qyzx_m_dir}/${inc_last_date}_temp ${qyzx_m_dir}/${inc_last_date} 返回值【$?】" #>> $dir_change_log
    fi
  fi
  
  return ${ret_result}
}

# 加载增量数据的文本到接口表中
function _load_inc_txt() {
  # 增量文本目录
  inc_dir=$1
  # 增量日期 
  inc_tmp_date=$2
  # yyyyMMdd 转成 yyyy-MM-dd
  inc_y=`expr substr "$inc_tmp_date" 1 4`
  inc_m=`expr substr "$inc_tmp_date" 5 2`
  inc_d=`expr substr "$inc_tmp_date" 7 2`
  inc_tmp_date="${inc_y}-${inc_m}-${inc_d}"
  
  # 打开数据库连接
  _open_db
  for i in "${!str_array[@]}"; do 
    # 增量文件
    inc_file_tmp=${inc_dir}/INC_${qyzx_ecc_id[$i]}.del
    # 接口表
    ecc_i_tmp=`echo "${qyzx_ecc_id[$i]}" | sed "s/QYZX_\(.*\)/\1_I/g"`
    if [ -f $inc_file_tmp ]; then
      echo "____加载增量文件【${inc_file_tmp}】到表【${ecc_i_tmp}】"
      
      # 清空表
      remsg=`db2 "ALTER TABLE ${ecc_i_tmp} ACTIVATE NOT LOGGED INITIALLY WITH EMPTY TABLE"`
      rs=$?
      if [ $rs -ne 0 -a $rs -ne 2 ]; then
        echo "____清空表${ecc_i_tmp}发生错误,返回码【$rs】错误信息【$remsg】"
        exit 99
      fi
      
      # 加载数据
      ermsg=`db2 "LOAD CLIENT FROM ${inc_file_tmp} OF DEL INSERT INTO ${ecc_i_tmp} ALLOW NO ACCESS "`
      rs=$?
      if [ $rs -ne 0 -a $rs -ne 2 ]; then
        echo "____发生错误: 【$ermsg】"
        db2 +o connect reset 
        exit 97
      fi
      
      # 设置业务日期
      ermsg=`db2 "update ${ecc_i_tmp} set ywdate = '${inc_tmp_date}' "`
      rs=$?
      if [ $rs -ne 0 -a $rs -ne 1 -a $rs -ne 2 ]; then
        echo "____更新增量日期发生错误,返回码【$rs】错误信息【$remsg】"
        exit 98
      fi
    else
      echo "____失败：找不到增量文件【$inc_file_tmp】"
    fi
  done
  db2 +o connect reset 
  return 0
}

# 判断参数是否为空
if [ "$#" == "0" ]; then
  usage
  exit 90
fi
while getopts "ad:c:n:" op_name; do
  case $op_name in
  a)
    # 默认执行
    QYZX_ALL_TASK=1
    ;;
  n)
    # 执行指定任务
    QYZX_FLOWS="$OPTARG"
    _str_split $QYZX_FLOWS ","
    ;;
  d)
    # 增量日期
    QYZX_INC_DATE="$OPTARG"
    if [[ ! "$QYZX_INC_DATE" =~ "^[0-9]{4}[0-9]{2}[0-9]{2}$" ]]; then
      usage
      exit 90
    fi
    ;;
  c) 
    # 对比数据日期  
    QYZX_COM_DATE="$OPTARG"
    if [[ ! "$QYZX_COM_DATE" =~ "^[0-9]{4}[0-9]{2}[0-9]{2}$" ]]; then
      usage
      exit 90
    fi
    ;;
  ?)
    usage 
    exit 90
  esac
done 


# 初始化参数
_init_some_param

# 剥离增量
_incr_data "$QYZX_INC_DATE" "$QYZX_INC_LAST_DATE" "$QYZX_COM_DATE"
exit_rs=$?
if [ $exit_rs -eq 0 ]; then
  # 把借据还款明细 改成增量文件, 因为本身就是增量数据
  if [ -f "${qyzx_m_dir}/${QYZX_INC_DATE}/QYZX_ECC_LOANRETURNS.del" ]; then
    cp "${qyzx_m_dir}/${QYZX_INC_DATE}/QYZX_ECC_LOANRETURNS.del" "${qyzx_m_dir}/${QYZX_INC_DATE}/INC_QYZX_ECC_LOANRETURNS.del"
  else 
    echo "找不到增量文件: ${qyzx_m_dir}/${QYZX_INC_DATE}/QYZX_ECC_LOANRETURNS.del"
  fi
  
  # 把融资还款明细 改成增量文件, 因为本身就是增量数据
  if [ -f "${qyzx_m_dir}/${QYZX_INC_DATE}/QYZX_ECC_FINANCERETURNS.del" ]; then
    cp "${qyzx_m_dir}/${QYZX_INC_DATE}/QYZX_ECC_FINANCERETURNS.del" "${qyzx_m_dir}/${QYZX_INC_DATE}/INC_QYZX_ECC_FINANCERETURNS.del"
  else 
    echo "找不到增量文件: ${qyzx_m_dir}/${QYZX_INC_DATE}/QYZX_ECC_FINANCERETURNS.del"
  fi
  
  # 加载增量数据
#  _load_inc_txt "${qyzx_m_dir}/$QYZX_INC_DATE" "$QYZX_INC_DATE"
#  exit_rs=$?
fi


exit $exit_rs
