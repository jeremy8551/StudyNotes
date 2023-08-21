#!/bin/sh
# 功    能：初始化接口程序
# 开 发 人：吕钊军
# 开发时间：2011-03-18
# 所属公司：北京宇信易诚科技有限公司



# 判断环境变量是否存在
if [ "$RPT_HOME" == "" ]; then 
# 根目录
export RPT_HOME=$HOME/rptsys
# 可执行程序目录
export RPT_BIN=$RPT_HOME/bin
# 文本存放目录
export RPT_FILE=$RPT_HOME/file
# 源程序存放目录
export RPT_SRC=$RPT_HOME/src
# 临时文件存放目录
export RPT_TEMP=$RPT_HOME/temp
# 日志存放目录
export RPT_LOGS=$RPT_HOME/logs
# 配置文件存放目录
export RPT_CONF=$RPT_HOME/conf
# jar包目录
export RPT_LIB=$RPT_HOME/lib
# java class文件存放目录
export RPT_CLASSES=$RPT_HOME/classes
# 报送系统所有JAR包
RPT_JARS=
for i in "$RPT_LIB"/*.jar; do
  RPT_JARS="$RPT_JARS":"$i"
done
export RPT_JARS
fi


# 杀掉所有已经执行的相同daemon.sh脚本
ps -ef|grep daemon.sh|grep "\-c"|grep "\-s"|while read line 
do 
    kpid=`echo $line|awk -F" " 'NR==1,NR==1 {print $2}'`
    if [ "$kpid" != "$$" ]; then 
        echo "关闭守护进程 $kpid"
        kill -9 $kpid
    fi
done 


# 在核心系统数据库中执行SQL
CORESQL="java -cp $RPT_JARS -Dfile.encoding=GBK com.yc.etl.sql.ExeSql -j $RPT_CONF/jdbc_core.properties "
# 在报送系统数据库中执行SQL
RPTSQL="java  -cp $RPT_JARS -Dfile.encoding=GBK com.yc.etl.sql.ExeSql -j $RPT_CONF/jdbc_report.properties "


# 设置核心日结标志
# $CORESQL -s "update  cxtzt set yyjd = 10  "


# 设置文本贮存区状态
$RPTSQL -s "delete from rpt_sysfile "
$RPTSQL -s "insert into rpt_sysfile (sys_flag,flr_flag,sys_date,over_time,file_path) values ('easycore', 'SDM', '1999-01-01', '', '') "
$RPTSQL -s "insert into rpt_sysfile (sys_flag,flr_flag,sys_date,over_time,file_path) values ('aml',      'ITF', '1999-01-01', '', '') "


# 删除贮存区所有文本
cd $RPT_FILE
rm -rf *


# 清除所有日志
cd $RPT_LOGS
rm -rf *

exit 0
