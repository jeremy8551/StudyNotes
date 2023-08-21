#!/bin/sh

# ��ʼ������
source qyzx_param.sh

# �÷�
usage() {
  echo "Usage: qyzx_save_src.sh [-a]  [-n ��������]"
  echo "    -a [ж����������]  "
  echo "    -n [װ�������] [flow1,flow2...] ѡ��:"
  for i in "${!qyzx_src[@]}"; do
    echo "      $i - ${qyzx_src_note[$i]} (${qyzx_src[$i]})"
  done
  echo " "
}

# �жϲ����Ƿ�Ϊ��
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

# ���õ���˳��
if [ "$EXECUTE_ALL" == "1" -o ${#str_array[@]} == 0 ]; then
  echo "____ж������Դ������Ϣ"
  for i in "${!qyzx_src[@]}"; do
    str_array[$i]=${qyzx_src[$i]}
  done
else
  echo "____����˳��: "
  for i in "${!str_array[@]}"; do
    echo "    $i - ${qyzx_src_note[$i]} ${qyzx_src[$i]}"
  done
fi

# ���ݿ�����
_open_db

# ��ȡ����Դ��ǰ���ݵ�����
DATA_DATE=`db2 -x "select coalesce(QYZX_WORKDATE, '') from QYZX_DATA_INFO order by TASK_ID desc fetch first 1 rows only"`
if [[ ! "$DATA_DATE" =~ "^[0-9]{4}-[0-9]{2}-[0-9]{2}$" ]]; then
  echo "____��ȡ��ǰ����Դ���ݵ����ڷ�������,��$DATA_DATE��"
  db2 +o connect reset 
  exit 101
fi

# ��������Դ�ı�Ŀ¼
DATA_DATE_DIR=`echo ${DATA_DATE} | awk -F"-" '{print $1$2$3}'`
DATA_DATE_DIR=${qyzx_o_dir}/${DATA_DATE_DIR}
if [ ! -d ${DATA_DATE_DIR} ]; then
  mkdir ${DATA_DATE_DIR}
  if [ $? -ne 0 ]; then
    echo "____����Ŀ¼��${DATA_DATE_DIR}��ʧ��,���ش���=$?"
    db2 +o connect reset 
    exit 102
  fi
fi 

# ����ж��sql���
for i in "${!qyzx_src[@]}"; do 
  qyzx_src_export_sql[$i]="select * from ${qyzx_src[$i]} with ur"
done

# ִ��ж��
for i in "${!str_array[@]}"; do
  echo "____����ж��: $i - ${qyzx_src_note[$i]} ${qyzx_src[$i]}"
  export_file_tmp="${DATA_DATE_DIR}/${qyzx_src[$i]}.del"
  export_sql_tmp="${qyzx_src_export_sql[$i]}"
  btime=`date +%s`
  ermsg=`db2 "export to ${export_file_tmp} of del ${export_sql_tmp}"`
  if [ $? -ne 0 -a $? -ne 2 ]; then
    echo "____export���������: [$ermsg]"
    db2 +o connect reset 
    exit 103
  fi
  etime=`date +%s`
  utime=$((etime-btime))
  echo "____ִ�����, ��ʱ=$((utime/60))��$((utime%60))��"
done

# ����ж������Դ��ɱ�־
if [ "$EXECUTE_ALL" == "1" ]; then
  msg=`db2 "update QYZX_DATA_INFO set EXPORT_FLAG = '999', EXPORT_DIR='${DATA_DATE_DIR}' where TASK_ID = (select max(TASK_ID) from QYZX_DATA_INFO)"`
  if [ $? -ne 0 -a $? -ne 2 ]; then
    echo "____����:ж������Դ�ı���ɱ�־����,����ֵ:��$?��������Ϣ:��$msg��"
    db2 +o connect reset 
    exit 104
  fi
fi

db2 +o connect reset 
exit 0


