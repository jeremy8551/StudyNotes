#!/bin/sh

# ��ʼ������
source qyzx_param.sh

# �÷�
function usage() {
  echo "Usage: grzx_open_src.sh [-d ��������] [-n װ�������(Ϊ�ձ�ʾװ��ȫ���ı�)]"
  echo "��;: װ��ָ�����ڵĸ�����������"
  echo " -d ��������,��ʽ: yyyyMMdd"
  echo " -n ѡ��:"
  for i in "${!qyzx_src[@]}"; do
    echo "    $i - ${qyzx_src_note[$i]} ${qyzx_src[$i]}"
  done
  echo " "
  echo "����: grzx_open_src.sh -d 20090831 -n 0,1 "
}

# װ��
function _load_file() {
  load_file_tmp=$1
  load_table=$2
  if [ ! -f $load_file_tmp ]; then
    echo "____�Ҳ����ļ�: $load_file_tmp"
    db2 +o connect reset 
    exit 112
  fi
  btime=`date +%s`
  ermsg=`db2 "LOAD CLIENT FROM ${load_file_tmp} OF DEL REPLACE INTO ${load_table} ALLOW NO ACCESS "`
  rs=$?
  if [ $rs -ne 0 -a $rs -ne 2 ]; then
    echo "____��������: [$ermsg]"
    db2 +o connect reset 
    exit 113
  fi
  etime=`date +%s`
  utime=$((etime-btime))
  echo "____ִ�����, ��ʱ=$((utime/60))��$((utime%60))��"
  return 0
}

# �жϲ����Ƿ�Ϊ��
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

# ��ʼ������
if [ "$DATA_DATE" == "" ]; then
  echo "-d ��ѡ��������Ϊ��"
  usage
  exit 110
fi

# ���������ı�����Ŀ¼
DATA_DIR="${qyzx_o_dir}/${DATA_DATE}"
if [ ! -d $DATA_DIR ]; then
  echo "____�Ҳ���Ŀ¼: $DATA_DIR"
  exit 111
fi

# ���õ���
if [ "${TASK_FLOWS}" == "" ]; then
  TASK_FLOWS="ALL FLOW"
  echo "____װ������=��$DATA_DATE��������,�ı�Ŀ¼=��$DATA_DIR��"
  for i in "${!qyzx_src[@]}"; do
    str_array[$i]=${qyzx_src[$i]}
  done
else
  echo "____����˳��: "
  for i in "${!str_array[@]}"; do
    echo "    $i - ${qyzx_src_note[$i]} ${qyzx_src[$i]} "
  done
fi

# �����ݿ�����
_open_db

# �½�����
qyzx_y=`expr substr "$DATA_DATE" 1 4`
qyzx_m=`expr substr "$DATA_DATE" 5 2`
qyzx_d=`expr substr "$DATA_DATE" 7 2`
qyzx_workdate="${qyzx_y}-${qyzx_m}-${qyzx_d}"
_ddl_cmd "INSERT INTO QYZX_DATA_INFO (UDSF_WORKDATE, QYZX_WORKDATE, TASK_FLOW, EXPORT_FLAG, EXPORT_DIR) VALUES ('$qyzx_workdate', '$qyzx_workdate', '$TASK_FLOWS', '999', '$DATA_DIR')"

# װ������
for i in "${!str_array[@]}"; do
  echo "____����װ��: $i ${qyzx_src_note[$i]} (${qyzx_src[$i]})"
  _ddl_cmd "UPDATE QYZX_DATA_INFO SET TASK_CURR_FLOW = '$i' WHERE task_id = (select max(task_id) from QYZX_DATA_INFO) "
  _load_file "${DATA_DIR}/${qyzx_src[$i]}.del" "${qyzx_src[$i]}"
done

# ����ִ����ϱ�ʶ
_ddl_cmd "UPDATE QYZX_DATA_INFO SET TASK_CURR_FLOW = '999' WHERE task_id = (select max(task_id) from QYZX_DATA_INFO) "
echo "����Դ��ʼ�����."

db2 +o connect reset 
exit 0
