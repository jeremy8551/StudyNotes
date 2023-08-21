#!/bin/sh

fileData=$1
check_proc="PROC_QYZX_CHECKDATA"

# �÷�
function usage() {
  echo "Function: qyzx_check.sh -d [��������yyyyMMdd] "
  echo "Usage: ��ȡָ�����ڵ���ҵ�������˺˶����� "
  echo "Option: -d ��������,��ʽ: yyyyMMdd"
  echo " "
}

# ����UDSF���ݿ�
function _open_db() {
  db2 +o connect to $db2_connect_str
  return_val=$?
  if [ $return_val -ne 0 ]; then
    echo "����UDSF���ݿ�ʧ��, ����ֵ: $return_val"
    echo "ʹ��Ĭ������"
    db2 +o connect to udsfdb user udsfadm using udsfadm
    return_val=$?
    if [ $return_val -ne 0 ]; then
      echo "����ʧ��, ����ֵ: $return_val �˳�.."
      exit 120
    fi
  fi
}

# �� yyyy-MM-dd ת�� yyyyMMdd
DATA_DATE=`echo ${fileData} | awk -F"-" '{print $1$2$3}'`


#�ָ�����Դ 
cd /home/udsf/shell/qyzx
qyzx_open_src.sh -d $DATA_DATE

# ����UDSF���ݿ�
_open_db

# ����洢����
function _rebind_proc() {
  proc_name_tmp=$check_proc
  echo ____���ڱ���...
  proc_id_tmp=`db2 -x "SELECT RTRIM(routineschema)||'.'||'P'||SUBSTR(CHAR(lib_id+10000000),2) FROM SYSCAT.routines WHERE routinename='$proc_name_tmp' with ur "`
  if [ "$proc_id_tmp" == "" ]; then
    echo "____�������: �Ҳ����洢���̡�$proc_name_tmp��"
#    db2 +o connect reset 
    exit 78
  fi
  ermsg=`db2 -x "rebind package $proc_id_tmp resolve any "`
  rs=$?
  if [ $rs -ne 0 -a $rs -ne 2 ]; then
    echo "���� $proc_id_tmp ��������: $ermsg"
#    db2 +o connect reset 
    exit 75
  fi
  return 0
}

# ���ô洢����
function _progress() {
  echo ____����ִ��...
  btime=`date +%s`
  produce_tmp=$check_proc
  returnmsg=`db2 "call ${produce_tmp}('$fileData',?)"`
  if [ $? -ne 0 ]; then
    echo "____���д洢����${produce_tmp}ʧ��!"
    echo "____������Ϣ: ${returnmsg}"
#    db2 +o connect reset
    exit 76 
  fi
  returnvalue=`echo ${returnmsg} | awk -F" " '{print $13}'`
  if [ $returnvalue -ne 0 ]; then
    errmsg=`db2 -x "select (char(d.err_dt)||' '||char(d.err_time)||' '||d.err_message) as msg from (select c.* from (select a.* , rank() over(partition by name order by err_dt desc) as num from udsf_sys_err_log a where name='${produce_tmp}') c where c.num=1) d order by d.err_time desc fetch first 1 rows only with ur"`
    echo "____������Ϣ: ${errmsg}"
#    db2 +o connect reset
    exit 77
  fi
  etime=`date +%s`
  utime=$((etime-btime))
  echo "____ִ�����, ��ʱ=$((utime/60))��$((utime%60))��"
  return 0
}

_rebind_proc
_progress

#����
cd /home/udsf/shell/qyzx/check
db2 "export to ${fileData}_checkdata.txt of del modified by nochardel decplusblank select rtrim(CARDCODE),rtrim(INSTITUTEID),rtrim(cstname),rtrim(CONTRACTNUM),CONTRSUM,LOANBALANCE,rtrim(DUEBILLNUM),rtrim(BLNUM),BLSUM,BLBALANCE,rtrim(TXNUM),TXSUM,TXBALANCE,rtrim(MYRZXYNUM),MYRZSUM,MYRZBALANCE,rtrim(MYRZYWNUM),rtrim(XYZNUM),XYZSUM,XYZBALANCE,rtrim(BHNUM),BHSUM,BHBALANCE,rtrim(YCNUM),YCSUM,YCBALANCE,rtrim(GKSXNUM),GKSXSUM,rtrim(BZNUM),BZSUM,BZBALANCE,rtrim(DYNUM),DYSUM,DYBALANCE,rtrim(ZYNUM),ZYSUM,ZYBALANCE,rtrim(DKNUM),DKSUM,DKBALANCE,BNQXBALANCE,BWQXBALANCE,rtrim(jgdm),enddate from QYZX_checkdata where flag = '0' "

#�Ͽ����ݿ������
db2 +o connect reset

exit 0