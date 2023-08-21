#!/bin/sh

# ��ʼ������
source qyzx_param.sh

usage() {
  echo "Function: ��ʼ����ҵ��������Դ "
  echo "Usage: qyzx_init_data.sh [-a] [-r] [-n flow1,flow2...] "
  echo "Option:"
  echo "    -a  [Ĭ��ִ��]"
  echo "    -r  [��������Դ: ��������,������Ϣͳ��,�ֲ���Ϣͳ��]"
  echo "    -n  [ִ��ָ������������(���ȼ�û�� [-a]ѡ�� ��): ���1,���2,���3...] "
  for i in "${!qyzx_crd[@]}"; do
    echo "       $i - ${qyzx_src_note[$i]} [${qyzx_src[$i]}]"
  done
  echo " "
  echo "    ʾ��: ��ʼ�� �ͻ��ǼǱ�,�����Ϣ��,��Ʊ��"
  echo "    ����: qyzx_init_data.sh -n 0,10,17 -r "
}

if [ "$#" == "0" ]; then
  usage
  exit 51
fi
while getopts "arn:" op_name; do
  case $op_name in
  a)
    # ִ����������
    QYZX_ALL_TASK=1
    ;;
  n)
    # ִ��ָ������
    QYZX_FLOWS="$OPTARG"
    _str_split $QYZX_FLOWS ","
    ;;
  r)
    # ��������Դ
    QYZX_RERUN_DATA=1
    ;;
  ?)
    usage 
    exit 51
  esac
done 

if [ "$QYZX_ALL_TASK" != "1" -a "${#str_array[@]}" != "0" ]; then 
  echo "����˳��: "
  for i in "${!str_array[@]}"; do
    echo "    $i - ${qyzx_src_note[$i]} [${qyzx_src[$i]}]"
  done
else 
  QYZX_FLOWS="ALL FLOW"
  for i in "${!qyzx_crd[@]}"; do
    str_array[$i]=${qyzx_crd[$i]}
  done
fi

# ��ʼ��ָ����
function _init_table() {
  TABLE_NAME=$1
  TABLE_NAME_QYZX="${TABLE_NAME}_QYZX"
  echo "��ʼ����: ${TABLE_NAME_QYZX}"
#return 0
#  ermsg=`db2 -x "ALTER TABLE ${TABLE_NAME_QYZX} ACTIVATE NOT LOGGED INITIALLY WITH EMPTY TABLE"`
  ermsg=`db2 -x "load from /dev/null of del replace into ${TABLE_NAME_QYZX} "`
  rs=$?
  if [ $rs -ne 0 -a $rs -ne 2 ]; then
    echo "��������: [����ֵ=$rs, $ermsg]"
    echo "��������: [��ձ�${TABLE_NAME_QYZX}ʱ,��������!]"
    db2 +o connect reset 
    exit 52
  fi
  ermsg=`db2 -x "INSERT INTO ${TABLE_NAME_QYZX} SELECT * FROM ${TABLE_NAME}"`
  rs=$?
  if [ $rs -ne 0 -a $rs -ne 2 -a $rs -ne 1 ]; then
    echo "��������: [����ֵ=$rs, $ermsg]"
    echo "��������: [INSERT INTO ${TABLE_NAME_QYZX} SELECT * FROM ${TABLE_NAME}]"
    db2 +o connect reset 
    exit 53
  fi
  return 0
}

# ����:��ʼ������Դ
function _init_data() {
  echo "���ڳ�ʼ������Դ..."
  # ȡ�����ݲֿ⵱ǰ�Ŵ�ϵͳ���ݵ���Ϣ
  udsf_task_info=`db2 -x "SELECT RTRIM(CHAR(MAX(task_flag)))||'_'||RTRIM(CHAR(MAX(task_etl_date))) FROM SYS_TASK_RUN_INFO WHERE TASK_GROUP='LNA_I2O' "`
  udsf_task_flag=`echo ${udsf_task_info} | awk -F"_" '{print $1}'`
  if [ "${udsf_task_flag}" == "1" ]; then
    echo "���ݲֿ����Ŵ�ϵͳ�����д���(��task_flag=1�ı�)."
    return 57
  fi
  # ���ݲֿ���Ŵ����ݵ�����
  udsf_workdate=`echo ${udsf_task_info} | awk -F"_" '{print $2}'`
  # ȡ�õ�ǰ��ҵ��������Դ����������
  qyzx_workdate=`db2 -x "SELECT COALESCE(qyzx_workdate, '') FROM QYZX_DATA_INFO where TASK_CURR_FLOW = '999' ORDER BY TASK_ID DESC FETCH FIRST 1 ROWS ONLY WITH UR "`
  echo "���ݲֿ⵱ǰ���ڡ�$udsf_workdate�� ����Դ��ǰ���ڡ�$qyzx_workdate�� "
  if [[ "$udsf_workdate" =~ "^[0-9]{4}-[0-9]{2}-[0-9]{2}$" ]]; then
    if [[ "$qyzx_workdate" =~ "^[0-9]{4}-[0-9]{2}-[0-9]{2}$" ]]; then
      if [[ ! $udsf_workdate > $qyzx_workdate ]]; then
        echo "��ʼ������Դʧ��,ԭ��: ���ݲֿ����� ${udsf_workdate} ������� ����Դ���� ${qyzx_workdate}"
        return 54
      fi
    fi
  else
    echo "��ʼ������Դʧ��,ԭ��: ���ݲֿ⵱ǰ�������ڲ��Ϸ�! [workdate=$udsf_workdate]"
    return 55
  fi

  # ���� ����Դ ��Ϣ
  _ddl_cmd "INSERT INTO QYZX_DATA_INFO (UDSF_WORKDATE, QYZX_WORKDATE, TASK_FLOW) VALUES ('$udsf_workdate', '$udsf_workdate', '$QYZX_FLOWS')"
  QYZX_TASK_ID=`db2 -x "SELECT task_id FROM QYZX_DATA_INFO ORDER BY TASK_ID DESC FETCH FIRST 1 ROWS ONLY WITH UR "`
  if [ "$QYZX_TASK_ID" == "" ]; then
    echo "��ʼ������Դʧ��,ԭ��:��ѯ����Դ��Ϣ��(QYZX_DATA_INFO)�е��������Ϊ��"
    return 56
  fi
  
  # ��ʼ��
  for i in "${!str_array[@]}"; do
    _ddl_cmd "UPDATE QYZX_DATA_INFO SET TASK_CURR_FLOW = '$i' WHERE task_id = $QYZX_TASK_ID "
    _init_table "${qyzx_crd[$i]}"
  done
  
  # ����ִ����ϱ�ʶ  
  _ddl_cmd "UPDATE QYZX_DATA_INFO SET TASK_CURR_FLOW = '999' WHERE task_id = $QYZX_TASK_ID "
  echo "����Դ��ʼ�����."
  
  # ������ҵ������ʷ����
  #SAVE_DIR=`echo ${udsf_workdate} | awk -F"-" '{print $1$2$3}'`
  #echo "������ҵ���ű��ͱ����ݵ�Ŀ¼: /home/udsf/shell/qyzx/r_file/${SAVE_DIR}"
  #/home/udsf/shell/qyzx/r_file/qyzx_save_ECC_R.sh -d "${SAVE_DIR}"
  #echo "������ʷ�������!"
  return 0
}


_open_db
_init_data
exitFlag=$?
db2 +o connect reset

exit $exitFlag
