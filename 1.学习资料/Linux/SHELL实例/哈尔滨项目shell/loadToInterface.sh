#!/bin/sh

filepath=$1
dbname=$2
dbuser=$3
dbpw=$4
count=0
upload_log="${filepath}/upload.log"
running_log="${filepath}/running.log"
#echo "$filepath , $dbname , $dbuser $dbpw" > $upload_log

echo "" > $running_log
if [ -f $upload_log ]; then
  rm $upload_log
fi

ecc_table[1]="ECC_BORROWERS"
ecc_table[2]="ECC_FINANCECONTACTS"
ecc_table[3]="ECC_STOCKS"
ecc_table[4]="ECC_REGCAPITALS"
ecc_table[5]="ECC_BINVCAPITALS"
ecc_table[6]="ECC_INVCAPITALS"
ecc_table[7]="ECC_GRPCORPS"
ecc_table[8]="ECC_SUPERMANS"
ecc_table[9]="ECC_FAMILYMEMBERS"
ecc_table[10]="ECC_LAWINFORMATION"
ecc_table[11]="ECC_EVENTINFORMATION"
ecc_table[12]="ECC_BILLEXPS"
ecc_table[13]="ECC_LOANBILLS"
ecc_table[14]="ECC_LOANCONTRACTS"
ecc_table[15]="ECC_LOANMONEYS"
ecc_table[16]="ECC_LOANRETURNS"
ecc_table[17]="ECC_BAOLIS"
ecc_table[18]="ECC_BILLDISCOUNTS"
ecc_table[19]="ECC_FINANCEBUSINESS"
ecc_table[20]="ECC_FINANCEEXPS"
ecc_table[21]="ECC_FINANCEMONEYS"
ecc_table[22]="ECC_FINANCEPROTOS"
ecc_table[23]="ECC_FINANCERETURNS"
ecc_table[24]="ECC_CREDITBUSINESS"
ecc_table[25]="ECC_BAOHANS"
ecc_table[26]="ECC_BANKACCEPTS"
ecc_table[27]="ECC_OPENAWARDTRUSTS"
ecc_table[28]="ECC_ENSURECONTRACTS"
ecc_table[29]="ECC_IMPAWNCONTRACT"
ecc_table[30]="ECC_PLEDGECONTRACTS"
ecc_table[31]="ECC_DKMESSAGES"
ecc_table[32]="ECC_DKRETURNS"
ecc_table[33]="ECC_LACKOFINTERESTS"

# 加载某个文本
function _propress() {
  ((count=count+1))
  tableName=$1
  echo "____正在装载表: ${tableName}_I 的增量数据!" >> $running_log
  # tmsg=`db2 "ALTER TABLE ${tableName}_I ACTIVATE NOT LOGGED INITIALLY WITH EMPTY TABLE"`
  tmsg=`db2 "load from /dev/null of del replace into ${tableName}_I "`
  rs=$?
  if [ $rs -ne 0 -a $rs -ne 2 ]; then
    echo "load from /dev/null of del replace into ${tableName}_I 发生错误" >> $running_log
    echo "清空 ${tableName}_I 发生错误: $tmsg, 错误代码: $rs" > $upload_log
    db2 +o connect reset 
    exit 1
  fi
  
  incFile="${inc_dir}/INC_QYZX_${tableName}.del"
  if [ ! -f ${incFile} ]; then
    echo "增量文件${incFile}不存在!" >> $running_log
    return 0
  fi
  
  tmsg=`db2 import from ${incFile} of del insert into ${tableName}_I`
  rs=$?
  if [ $rs -ne 0 -a $rs -ne 2 -a $rs -ne 1 ]; then
    db2 +o connect reset 
    echo "加载增量文本 ${incFile} 发生错误: $tmsg, 错误代码: $rs " > $upload_log
    exit 2
  fi
}

# 执行命令
function _ddl_cmd() {
  tmp_str=$1
  echo "执行$tmp_str" >> $running_log
  ermsg=`db2 -x "${tmp_str}"`
  rs=$?
  if [ $rs -ne 0 -a $rs -ne 2 -a $rs -ne 1 ]; then
    db2 +o connect reset 
    echo "错误命令: ${tmp_str}, 错误信息: ${ermsg}, 错误码: ${rs}" > $upload_log
    exit 7
  fi
  return 0
}

# 编译存储过程
function _rebind_proc() {
  proc_name_tmp=$1
  echo ____正在编译...
  proc_id_tmp=`db2 -x "SELECT RTRIM(routineschema)||'.'||'P'||SUBSTR(CHAR(lib_id+10000000),2) FROM SYSCAT.routines WHERE routinename='$proc_name_tmp' with ur "`
  if [ "$proc_id_tmp" == "" ]; then
    echo "____编译错误: 找不到存储过程【$proc_name_tmp】" > $upload_log
    db2 +o connect reset 
    exit 78
  fi
  ermsg=`db2 -x "rebind package $proc_id_tmp resolve any "`
  rs=$?
  if [ $rs -ne 0 -a $rs -ne 2 ]; then
    echo "编译 $proc_id_tmp 发生错误: $ermsg" > $upload_log
    db2 +o connect reset 
    exit 75
  fi
  return 0
}

# 调用存储过程
function _progress() {
  echo ____正在执行...
  btime=`date +%s`
  produce_tmp=$1
  returnmsg=`db2 "call ${produce_tmp}(?)"`
  if [ $? -ne 0 ]; then
    echo "____运行存储过程${produce_tmp}失败, 返回消息: ${returnmsg}" > $upload_log
    db2 +o connect reset
    exit 76 
  fi
  returnvalue=`echo ${returnmsg} | awk -F" " '{print $13}'`
  if [ $returnvalue -ne 0 ]; then
    errmsg=`db2 -x "select (char(d.err_dt)||' '||char(d.err_time)||' '||d.err_message) as msg from (select c.* from (select a.* , rank() over(partition by name order by err_dt desc) as num from udsf_sys_err_log a where name='${produce_tmp}') c where c.num=1) d order by d.err_time desc fetch first 1 rows only with ur"`
    echo "____错误信息: ${errmsg}" > $upload_log
    db2 +o connect reset
    exit 77
  fi
  etime=`date +%s`
  utime=$((etime-btime))
  echo "____执行完毕, 用时=$((utime/60))分$((utime%60))秒"
  return 0
}

# 连接数据
db2 +o connect to ${dbname} user ${dbuser} using ${dbpw}
rs=$?
if [ $rs -ne 0 ]; then
  echo "连接数据库错误,命令: db2 connect to ${dbname} user ${dbuser} using ${dbpw}, 错误代码: $rs" > ${upload_log}
  exit 4
fi

# 获取当前增量数据的日期
QYZX_DATE=`db2 -x "SELECT RTRIM(char(QYZX_DATE)) FROM qyzx_task ORDER BY task_id DESC FETCH FIRST 1 ROWS ONLY "`
if [[ ! "$QYZX_DATE" =~ "^[0-9]{4}-[0-9]{2}-[0-9]{2}$" ]]; then
  db2 +o connect reset 
  echo "查询任务号错误,任务号='${QYZX_DATE}'" > ${upload_log}
  exit 3
fi

# 已经导入编辑表的最大数据日期
maxywdate=`db2 -x "select max(ywdate) from eccd_finish"`
if [[ ! "$maxywdate" =~ "^[0-9]{4}-[0-9]{2}-[0-9]{2}$" ]]; then
  db2 +o connect reset 
  echo "查询任务号错误,任务号='$maxywdate'" > ${upload_log}
  exit 8
fi

if [ "$QYZX_DATE" == "$maxywdate" ]; then
  db2 +o connect reset 
  echo "导入数据错误: 已经导入过日期 = $QYZX_DATE 的数据!" > ${upload_log}
  exit 10
fi

if [[ "$QYZX_DATE" < "$maxywdate" ]]; then
  db2 +o connect reset 
  echo "导入数据错误: $QYZX_DATE 小于 $maxywdate !" > ${upload_log}
  exit 11
fi


# 取得增量文本目录
date_temp=`echo ${QYZX_DATE} | awk -F"-" '{print $1$2$3}'`
inc_dir="${filepath}/${date_temp}"


# 加载所有增量文本到接口表
for i in "${!ecc_table[@]}"; do
  _propress "${ecc_table[$i]}"
done


# 执行存储过程
echo "调用PROC_QYZX_BATCH_UPDATE 补全业务主表信息" >> $running_log
_rebind_proc "PROC_QYZX_BATCH_UPDATE" >> $running_log
_progress "PROC_QYZX_BATCH_UPDATE" >> $running_log


# 更新所有接口表的业务日期(ywdate)
for j in "${!ecc_table[@]}"; do
  echo "____正在设置 ${ecc_table[$j]}_I 数据日期(ywdate)" >> $running_log
  _ddl_cmd "update ${ecc_table[$j]}_I set ywdate='${QYZX_DATE}' "
done
_ddl_cmd "update ECC_BAOHANS_I set balance_date = '${QYZX_DATE}'";
_ddl_cmd "update ECC_CREDITBUSINESS_I set balance_report_date = '${QYZX_DATE}'";
_ddl_cmd "update ECC_DKMESSAGES_I set balance_date = '${QYZX_DATE}'";


# 通知前端程序 接口表的数据日期
_ddl_cmd "INSERT INTO eccd_finish (ywdate, orgcode, finishcode) SELECT '${QYZX_DATE}', RTRIM(bank_org_id), '04' FROM dmd_bank_info"
_ddl_cmd "delete from eccd_finish where orgcode in ('0009','0010','1009','1010','7500','7501','8700','8701')"


# 重组索引
_ddl_cmd "reorg indexes all for table ECC_ENSURECONTRACTS_R ALLOW READ ACCESS"
_ddl_cmd "reorg indexes all for table ECC_IMPAWNCONTRACT_R ALLOW READ ACCESS"
_ddl_cmd "reorg indexes all for table ECC_PLEDGECONTRACTS_R ALLOW READ ACCESS"
_ddl_cmd "reorg indexes all for table ECC_BANKACCEPTS_R ALLOW READ ACCESS"


# 关闭数据库连接
db2 +o connect reset >> $running_log
echo 0 > $upload_log

echo "执行结束********************************************************"  >>$running_log
exit 0
