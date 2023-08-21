#!/bin/sh

fileData=$1
check_proc="PROC_QYZX_CHECKDATA"

# 用法
function usage() {
  echo "Function: qyzx_check.sh -d [数据日期yyyyMMdd] "
  echo "Usage: 抽取指定日期的企业征信两端核对数据 "
  echo "Option: -d 数据日期,格式: yyyyMMdd"
  echo " "
}

# 链接UDSF数据库
function _open_db() {
  db2 +o connect to $db2_connect_str
  return_val=$?
  if [ $return_val -ne 0 ]; then
    echo "链接UDSF数据库失败, 返回值: $return_val"
    echo "使用默认连接"
    db2 +o connect to udsfdb user udsfadm using udsfadm
    return_val=$?
    if [ $return_val -ne 0 ]; then
      echo "连接失败, 返回值: $return_val 退出.."
      exit 120
    fi
  fi
}

# 把 yyyy-MM-dd 转成 yyyyMMdd
DATA_DATE=`echo ${fileData} | awk -F"-" '{print $1$2$3}'`


#恢复数据源 
cd /home/udsf/shell/qyzx
qyzx_open_src.sh -d $DATA_DATE

# 链接UDSF数据库
_open_db

# 编译存储过程
function _rebind_proc() {
  proc_name_tmp=$check_proc
  echo ____正在编译...
  proc_id_tmp=`db2 -x "SELECT RTRIM(routineschema)||'.'||'P'||SUBSTR(CHAR(lib_id+10000000),2) FROM SYSCAT.routines WHERE routinename='$proc_name_tmp' with ur "`
  if [ "$proc_id_tmp" == "" ]; then
    echo "____编译错误: 找不到存储过程【$proc_name_tmp】"
#    db2 +o connect reset 
    exit 78
  fi
  ermsg=`db2 -x "rebind package $proc_id_tmp resolve any "`
  rs=$?
  if [ $rs -ne 0 -a $rs -ne 2 ]; then
    echo "编译 $proc_id_tmp 发生错误: $ermsg"
#    db2 +o connect reset 
    exit 75
  fi
  return 0
}

# 调用存储过程
function _progress() {
  echo ____正在执行...
  btime=`date +%s`
  produce_tmp=$check_proc
  returnmsg=`db2 "call ${produce_tmp}('$fileData',?)"`
  if [ $? -ne 0 ]; then
    echo "____运行存储过程${produce_tmp}失败!"
    echo "____返回消息: ${returnmsg}"
#    db2 +o connect reset
    exit 76 
  fi
  returnvalue=`echo ${returnmsg} | awk -F" " '{print $13}'`
  if [ $returnvalue -ne 0 ]; then
    errmsg=`db2 -x "select (char(d.err_dt)||' '||char(d.err_time)||' '||d.err_message) as msg from (select c.* from (select a.* , rank() over(partition by name order by err_dt desc) as num from udsf_sys_err_log a where name='${produce_tmp}') c where c.num=1) d order by d.err_time desc fetch first 1 rows only with ur"`
    echo "____错误信息: ${errmsg}"
#    db2 +o connect reset
    exit 77
  fi
  etime=`date +%s`
  utime=$((etime-btime))
  echo "____执行完毕, 用时=$((utime/60))分$((utime%60))秒"
  return 0
}

_rebind_proc
_progress

#导出
cd /home/udsf/shell/qyzx/check
db2 "export to ${fileData}_checkdata.txt of del modified by nochardel decplusblank select rtrim(CARDCODE),rtrim(INSTITUTEID),rtrim(cstname),rtrim(CONTRACTNUM),CONTRSUM,LOANBALANCE,rtrim(DUEBILLNUM),rtrim(BLNUM),BLSUM,BLBALANCE,rtrim(TXNUM),TXSUM,TXBALANCE,rtrim(MYRZXYNUM),MYRZSUM,MYRZBALANCE,rtrim(MYRZYWNUM),rtrim(XYZNUM),XYZSUM,XYZBALANCE,rtrim(BHNUM),BHSUM,BHBALANCE,rtrim(YCNUM),YCSUM,YCBALANCE,rtrim(GKSXNUM),GKSXSUM,rtrim(BZNUM),BZSUM,BZBALANCE,rtrim(DYNUM),DYSUM,DYBALANCE,rtrim(ZYNUM),ZYSUM,ZYBALANCE,rtrim(DKNUM),DKSUM,DKBALANCE,BNQXBALANCE,BWQXBALANCE,rtrim(jgdm),enddate from QYZX_checkdata where flag = '0' "

#断开数据库的连接
db2 +o connect reset

exit 0