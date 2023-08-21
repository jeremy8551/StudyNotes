#!/bin/sh

# ��ʼ������
source qyzx_param.sh

# ��ʼ���м���ж������
_init_ecc

# �÷�
function usage() {
  echo "Function: ����ҵ�����м���������ж�س��ı�(Ϊ��������������׼��)"
  echo "Usage: qyzx_export_middle.sh [-a] [-n ��������] [-p Ŀ¼] "
  echo "    -a [Ĭ��ִ��]"
  echo "    -p [�ı��洢Ŀ¼]"
  echo "    -n [��������, �������ֵ��Ĭ��ж��ȫ���ı�] ѡ��:"
  for i in "${!qyzx_ecc_id[@]}"; do
  echo "       $i - ${qyzx_ecc_id[$i]} "
  done
  echo " "
  echo "ʾ��: ֻ��ж��: 0-QYZX_ECC_BORROWERS �� 1-QYZX_ECC_GRPCORPS ������"
  echo "����: qyzx_export_middle.sh -n 1,7 "
}

# ִ������
function _export_file() {
  export_file=$1
  export_sql=$2
  btime=`date +%s`
  ermsg=`db2 "export to $export_file of del $export_sql"`
  rs=$?
  if [ $rs -ne 0 -a $rs -ne 2 ]; then
    echo "____��������: [$ermsg]"
    echo "____�������: [$rs]"
    echo "____��������: [export to $export_file of del $export_sql]"
    exit_rs=85
    return 85
  fi
  etime=`date +%s`
  utime=$((etime-btime))
  echo "____ִ�����, ��ʱ=$((utime/60))��$((utime%60))��"
  return 0
}

# ���õ����ı���Ϣ
function _set_export_info() {
  sql_tmp=$1
  ermsg=`db2 -x "$sql_tmp"`
  rs=$?
  if [ $rs -ne 0 -a $rs -ne 2 ]; then
    echo "��������: [$ermsg]"
    echo "��������: [$sql_tmp]"
    db2 +o connect reset 
    exit 89
  fi
  return 0
}

# ��ʼ��һЩ����
function _init_some_param() {
  # ��ѯ��ǰ�м�����ݵ���Ϣ
  select_str=`db2 -x "SELECT RTRIM(CHAR(task_id))||'_'||CHAR(qyzx_date)||'_'||RTRIM(fin_flag)||'_'||RTRIM(error_flag) FROM qyzx_task ORDER BY task_id DESC FETCH FIRST 1 ROWS ONLY "`
  if [ $? -ne 0 -o "$select_str" == "" ]; then
    echo "�����м���Ϣ����"
    db2 +o connect reset 
    exit 81
  fi
  qyzx_task_id=`echo ${select_str} | awk -F"_" '{print $1}'`
  qyzx_task_data=`echo ${select_str} | awk -F"_" '{print $2}'`
  qyzx_task_fin_flag=`echo ${select_str} | awk -F"_" '{print $3}'`
  qyzx_task_error_flag=`echo ${select_str} | awk -F"_" '{print $4}'`
  if [ "$qyzx_task_fin_flag" != "99" ]; then
    if [ "$qyzx_task_error_flag" != "000" ]; then
      echo "�����м������ʱ�������󡾴�����=$qyzx_task_error_flag��,���ȰѴ���������ж��"
      db2 +o connect reset 
      exit 82
    fi
    echo "���������м������,��Ȼ���ִ��!"
    db2 +o connect reset 
    exit 83
  fi
  echo "�м��ǰ���ݵ���Ϣ:����š�$qyzx_task_id���������ڡ�$qyzx_task_data��"

  # ������������
  QYZX_DATE=`echo ${qyzx_task_data} | awk -F"-" '{print $1$2$3}'`
  if [[ ! "$QYZX_DATE" =~ "^[0-9]{4}[0-9]{2}[0-9]{2}$" ]]; then 
    echo "�м��ǰ�������ڵĸ�ʽ����,������:$QYZX_DATE��"
    db2 +o connect reset 
    exit 84
  fi
  
  # ������������  
  if [ "$QYZX_ALL" != "1" -a "${#str_array[@]}" != "0" ]; then 
    echo "����˳��: "
    for i in "${!str_array[@]}"; do
      echo "    $i - ${qyzx_ecc_id[$i]} "
    done
  else 
    QYZX_FLOWS="ALL FLOW"
    for i in "${!qyzx_ecc_id[@]}"; do
      str_array[$i]=${qyzx_ecc_id[$i]}
    done
  fi
  
  # ���ô洢�ı���Ŀ¼
  if [ "$qyzx_curr_m_dir" == "" ]; then
    qyzx_curr_m_dir="${qyzx_m_dir}/${QYZX_DATE}"
  fi
  _mk_dir "$qyzx_curr_m_dir"
  
  # ��ʼ������ֵ
  exit_rs=0
}

# ����ѡ��
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

# ����UDSF���ݿ�
_open_db

# ��ʼ������
_init_some_param

# ������������
_set_export_info "update QYZX_TASK set EXPORT_FLOWS='${QYZX_FLOWS}', EXPORT_ERROR='' where TASK_ID = $qyzx_task_id "

# ж��
for i in "${!str_array[@]}"; do
  echo "____����ж��: $i - ${qyzx_ecc_id[$i]}"
  _export_file "${qyzx_curr_m_dir}/${qyzx_ecc_id[$i]}.del" "${qyzx_ecc_sql[$i]}"
  if [ $? -ne 0 ]; then
    _set_export_info "update QYZX_TASK set EXPORT_ERROR = RTRIM(EXPORT_ERROR)||',${i}' where TASK_ID = $qyzx_task_id "
  fi
done

db2 +o connect reset 
exit $exit_rs
