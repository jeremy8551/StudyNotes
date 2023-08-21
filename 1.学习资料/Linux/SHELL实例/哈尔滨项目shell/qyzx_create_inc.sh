#!/bin/sh

# ��ʼ������
source qyzx_param.sh

# ��ʼ������
_init_ecc

# �÷�
usage() {
  echo "Function: �����������ݵ���ҵ���Žӿڱ�"
  echo "Usage: qyzx_create_inc.sh [-a] [-d ��������] [-c �����Ա�����] [-n flow1,flow2...] "
  echo "Option:"
  echo "    -a  [Ĭ��ִ��,��������ѡ��]"
  echo "    -d  [������������yyyyMMdd]"
  echo "    -c  [�����Ա�����yyyyMMdd]"
  echo "    -n  [ִ��ָ������������(���ȼ�û�� [-a]ѡ�� ��): ���1,���2,���3...] "
  for i in "${!qyzx_ecc_id[@]}"; do
  echo "        $i - ${qyzx_ecc_name[$i]} ${qyzx_ecc_id[$i]}"
  done
  echo " "
  echo "    ʾ��: ����20090801��20090831֮��� 1-����˻�����Ϣ,12-���չ����Ϣ"
  echo "    ����: ./qyzx_create_inc.sh -d 20090831 -c 20090801 -n 1,12 "
}

# ��ʼ������
function _init_some_param() {
  # �Զ���ִ��
  if [ "$QYZX_ALL_TASK" != "1" ]; then
    if [ "$QYZX_COM_DATE" == "" -o "$QYZX_INC_DATE" == "" -o "$QYZX_FLOWS" == "" ]; then
      echo "��������"
      exit 90
    fi
    
    # ����ִ��˳��
    echo "����˳��: "
    for i in "${!str_array[@]}"; do
      echo "    $i - ${qyzx_ecc_id[$i]} "
    done
  else 
  # Ĭ��ִ��
    # �����ݿ�����
    _open_db
    
    # ����ִ��˳��    
    QYZX_FLOWS="ALL FLOW"
    for i in "${!qyzx_ecc_id[@]}"; do
      str_array[$i]=${qyzx_ecc_id[$i]}
    done
    
    # ��ǰ�м�����ݵ���Ϣ        
    str_tmp=`db2 -x "SELECT RTRIM(CHAR(task_id))||'_'||CHAR(qyzx_date)||'_'||RTRIM(fin_flag)||'_'||CHAR(compare_date) FROM QYZX_TASK ORDER BY task_id DESC FETCH FIRST 1 ROWS ONLY "`
    if [ $? -ne 0 -o "$str_tmp" == "" ]; then
      echo "��������ģ����Ϣ����,������Ϣ��$str_tmp��"
      db2 +o connect reset
      exit 92
    fi
    
    # �м��ǰ�����    
    QYZX_TASK_ID=`echo ${str_tmp} | awk -F"_" '{print $1}'`
    
    # ��������
    QYZX_TASK_DATE=`echo ${str_tmp} | awk -F"_" '{print $2}'`
    
    # �м�����ݵ���ɱ�־   
    QYZX_TASK_FLAG=`echo ${str_tmp} | awk -F"_" '{print $3}'`
    
    # �Ա��������ڡ������ϴ��ϱ����������ڡ�  
    QYZX_COM_DATE=`echo ${str_tmp} | awk -F"_" '{print $4}'`
    if [[ ! "$QYZX_COM_DATE" =~ "^[0-9]{4}-[0-9]{2}-[0-9]{2}$" ]]; then
      echo "�������ڸ�ʽ����,�������ڡ�$QYZX_COM_DATE��"
      db2 +o connect reset
      exit 91
    fi
    
    # ��ʽ������ yyyyMMdd
    QYZX_INC_DATE=`echo ${QYZX_TASK_DATE} | awk -F"-" '{print $1$2$3}'`
    QYZX_COM_DATE=`echo ${QYZX_COM_DATE} | awk -F"-" '{print $1$2$3}'`
    
    # �ر����ݿ�����
    db2 +o connect reset 
  fi
  
  # �������ڵ�ǰһ��
  inc_y=`expr substr "$QYZX_INC_DATE" 1 4`
  inc_m=`expr substr "$QYZX_INC_DATE" 5 2`
  inc_d=`expr substr "$QYZX_INC_DATE" 7 2`
  QYZX_INC_LAST_DATE=`date -d "${inc_y}-${inc_m}-${inc_d} yesterday" +%F`
  QYZX_INC_LAST_DATE=`echo ${QYZX_INC_LAST_DATE} | awk -F"-" '{print $1$2$3}'`
  return 0
}

# ������������
function _incr_data() {
  # �������� 
  inc_date=$1
  # �������ڵ�ǰһ��
  inc_last_date=$2
  # �Ա���������  
  compare_date=$3
  # ����ֵ  
  ret_result=0
  
  # ��������ļ�
  if [ ! -f "$qyzx_incr_cfg" ]; then
    echo "�Ҳ��������ļ���$qyzx_incr_cfg��"
    exit 93
  fi
  
  # �������Ŀ¼
  inc_dir=${qyzx_m_dir}/${inc_date}
  if [ ! -d $inc_dir ]; then
    echo "�Ҳ����������ݵ�Ŀ¼:$inc_dir"
    exit 94
  else 
    # ɾ���Ѿ����ڵ������ı�
    for i in "${!str_array[@]}"; do
      if [ -f "${inc_dir}/INC_${qyzx_ecc_id[$i]}.del" ]; then
        echo "ɾ���ļ�: ${inc_dir}/INC_${qyzx_ecc_id[$i]}.del"
        rm ${inc_dir}/INC_${qyzx_ecc_id[$i]}.del
      fi
    done
  fi
  
  # �Ա��ı�����Ŀ¼
  compare_dir=${qyzx_m_dir}/${compare_date}
  if [ ! -d $compare_dir ]; then 
    echo "�Ҳ����Ա��ı���Ŀ¼:$compare_dir"
    exit 95
  fi
  
  dir_change_log=${qyzx_m_dir}/dir_change_log.log 
  echo ִ��ʱ��:`date +%F_%T` >> $dir_change_log
  
  # ����Ŀ¼:�ѡ��Ա��ļ�Ŀ¼�����ĳɡ��������ڵ�ǰһ���Ŀ¼����
  if [ "$compare_date" != "$inc_last_date" ]; then
    if [ -d ${qyzx_m_dir}/$inc_last_date ]; then
      mv ${qyzx_m_dir}/${inc_last_date} ${qyzx_m_dir}/${inc_last_date}_temp 
      echo "mv ${qyzx_m_dir}/${inc_last_date} ${qyzx_m_dir}/${inc_last_date}_temp ����ֵ��$?��" #>> $dir_change_log
    fi
    mv ${compare_dir} ${qyzx_m_dir}/${inc_last_date} 
    echo "mv ${compare_dir} ${qyzx_m_dir}/${inc_last_date} ����ֵ��$?��" #>> $dir_change_log
  fi
  
  # ��������
  
  echo "____������������, ����: incrMainXml ${inc_date} ${qyzx_incr_cfg}"
  btime=`date +%s`
  #�滻2�����ڵ��ļ�����2����������(,,)Ϊ����+˫����+˫����+����(,"",)�������޷�������������
  `qyzx_replace.sh -d ${inc_last_date}`
  `qyzx_replace.sh -d ${inc_date}`
  incrMainXml "${inc_date}" "${qyzx_incr_cfg}"
  rs=$?
  if [ $rs -ne 0 ]; then
    echo "____����������������,����ֵ��$rs����־��$HOME/log/`date +%Y%m%d`/incrMain.log��"
    ret_result=96
  fi
  #�滻2�����ڵ��ļ���������+˫����+˫����+����(,"",)�滻2����������(,,)�����޷�װ�����ݿ�
  `qyzx_replace_re.sh -d ${inc_date}`
  etime=`date +%s`
  utime=$((etime-btime))
  echo "____ִ�����, ��ʱ=$((utime/60))��$((utime%60))��"
  
  # ������Ŀ¼�ĸ���
  if [ "$compare_date" != "$inc_last_date" ]; then
    mv ${qyzx_m_dir}/${inc_last_date} ${compare_dir} 
    echo "mv ${qyzx_m_dir}/${inc_last_date} ${compare_dir} ����ֵ��$?��" #>> $dir_change_log
    if [ -d ${qyzx_m_dir}/${inc_last_date}_temp ]; then
      mv ${qyzx_m_dir}/${inc_last_date}_temp ${qyzx_m_dir}/${inc_last_date}
      echo "mv ${qyzx_m_dir}/${inc_last_date}_temp ${qyzx_m_dir}/${inc_last_date} ����ֵ��$?��" #>> $dir_change_log
    fi
  fi
  
  return ${ret_result}
}

# �����������ݵ��ı����ӿڱ���
function _load_inc_txt() {
  # �����ı�Ŀ¼
  inc_dir=$1
  # �������� 
  inc_tmp_date=$2
  # yyyyMMdd ת�� yyyy-MM-dd
  inc_y=`expr substr "$inc_tmp_date" 1 4`
  inc_m=`expr substr "$inc_tmp_date" 5 2`
  inc_d=`expr substr "$inc_tmp_date" 7 2`
  inc_tmp_date="${inc_y}-${inc_m}-${inc_d}"
  
  # �����ݿ�����
  _open_db
  for i in "${!str_array[@]}"; do 
    # �����ļ�
    inc_file_tmp=${inc_dir}/INC_${qyzx_ecc_id[$i]}.del
    # �ӿڱ�
    ecc_i_tmp=`echo "${qyzx_ecc_id[$i]}" | sed "s/QYZX_\(.*\)/\1_I/g"`
    if [ -f $inc_file_tmp ]; then
      echo "____���������ļ���${inc_file_tmp}������${ecc_i_tmp}��"
      
      # ��ձ�
      remsg=`db2 "ALTER TABLE ${ecc_i_tmp} ACTIVATE NOT LOGGED INITIALLY WITH EMPTY TABLE"`
      rs=$?
      if [ $rs -ne 0 -a $rs -ne 2 ]; then
        echo "____��ձ�${ecc_i_tmp}��������,�����롾$rs��������Ϣ��$remsg��"
        exit 99
      fi
      
      # ��������
      ermsg=`db2 "LOAD CLIENT FROM ${inc_file_tmp} OF DEL INSERT INTO ${ecc_i_tmp} ALLOW NO ACCESS "`
      rs=$?
      if [ $rs -ne 0 -a $rs -ne 2 ]; then
        echo "____��������: ��$ermsg��"
        db2 +o connect reset 
        exit 97
      fi
      
      # ����ҵ������
      ermsg=`db2 "update ${ecc_i_tmp} set ywdate = '${inc_tmp_date}' "`
      rs=$?
      if [ $rs -ne 0 -a $rs -ne 1 -a $rs -ne 2 ]; then
        echo "____�����������ڷ�������,�����롾$rs��������Ϣ��$remsg��"
        exit 98
      fi
    else
      echo "____ʧ�ܣ��Ҳ��������ļ���$inc_file_tmp��"
    fi
  done
  db2 +o connect reset 
  return 0
}

# �жϲ����Ƿ�Ϊ��
if [ "$#" == "0" ]; then
  usage
  exit 90
fi
while getopts "ad:c:n:" op_name; do
  case $op_name in
  a)
    # Ĭ��ִ��
    QYZX_ALL_TASK=1
    ;;
  n)
    # ִ��ָ������
    QYZX_FLOWS="$OPTARG"
    _str_split $QYZX_FLOWS ","
    ;;
  d)
    # ��������
    QYZX_INC_DATE="$OPTARG"
    if [[ ! "$QYZX_INC_DATE" =~ "^[0-9]{4}[0-9]{2}[0-9]{2}$" ]]; then
      usage
      exit 90
    fi
    ;;
  c) 
    # �Ա���������  
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


# ��ʼ������
_init_some_param

# ��������
_incr_data "$QYZX_INC_DATE" "$QYZX_INC_LAST_DATE" "$QYZX_COM_DATE"
exit_rs=$?
if [ $exit_rs -eq 0 ]; then
  # �ѽ�ݻ�����ϸ �ĳ������ļ�, ��Ϊ���������������
  if [ -f "${qyzx_m_dir}/${QYZX_INC_DATE}/QYZX_ECC_LOANRETURNS.del" ]; then
    cp "${qyzx_m_dir}/${QYZX_INC_DATE}/QYZX_ECC_LOANRETURNS.del" "${qyzx_m_dir}/${QYZX_INC_DATE}/INC_QYZX_ECC_LOANRETURNS.del"
  else 
    echo "�Ҳ��������ļ�: ${qyzx_m_dir}/${QYZX_INC_DATE}/QYZX_ECC_LOANRETURNS.del"
  fi
  
  # �����ʻ�����ϸ �ĳ������ļ�, ��Ϊ���������������
  if [ -f "${qyzx_m_dir}/${QYZX_INC_DATE}/QYZX_ECC_FINANCERETURNS.del" ]; then
    cp "${qyzx_m_dir}/${QYZX_INC_DATE}/QYZX_ECC_FINANCERETURNS.del" "${qyzx_m_dir}/${QYZX_INC_DATE}/INC_QYZX_ECC_FINANCERETURNS.del"
  else 
    echo "�Ҳ��������ļ�: ${qyzx_m_dir}/${QYZX_INC_DATE}/QYZX_ECC_FINANCERETURNS.del"
  fi
  
  # ������������
#  _load_inc_txt "${qyzx_m_dir}/$QYZX_INC_DATE" "$QYZX_INC_DATE"
#  exit_rs=$?
fi


exit $exit_rs
