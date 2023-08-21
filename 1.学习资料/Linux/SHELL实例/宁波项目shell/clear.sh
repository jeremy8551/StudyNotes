#!/bin/sh
# ��    �ܣ���ʼ���ӿڳ���
# �� �� �ˣ����Ⱦ�
# ����ʱ�䣺2011-03-18
# ������˾�����������׳ϿƼ����޹�˾



# �жϻ��������Ƿ����
if [ "$RPT_HOME" == "" ]; then 
# ��Ŀ¼
export RPT_HOME=$HOME/rptsys
# ��ִ�г���Ŀ¼
export RPT_BIN=$RPT_HOME/bin
# �ı����Ŀ¼
export RPT_FILE=$RPT_HOME/file
# Դ������Ŀ¼
export RPT_SRC=$RPT_HOME/src
# ��ʱ�ļ����Ŀ¼
export RPT_TEMP=$RPT_HOME/temp
# ��־���Ŀ¼
export RPT_LOGS=$RPT_HOME/logs
# �����ļ����Ŀ¼
export RPT_CONF=$RPT_HOME/conf
# jar��Ŀ¼
export RPT_LIB=$RPT_HOME/lib
# java class�ļ����Ŀ¼
export RPT_CLASSES=$RPT_HOME/classes
# ����ϵͳ����JAR��
RPT_JARS=
for i in "$RPT_LIB"/*.jar; do
  RPT_JARS="$RPT_JARS":"$i"
done
export RPT_JARS
fi


# ɱ�������Ѿ�ִ�е���ͬdaemon.sh�ű�
ps -ef|grep daemon.sh|grep "\-c"|grep "\-s"|while read line 
do 
    kpid=`echo $line|awk -F" " 'NR==1,NR==1 {print $2}'`
    if [ "$kpid" != "$$" ]; then 
        echo "�ر��ػ����� $kpid"
        kill -9 $kpid
    fi
done 


# �ں���ϵͳ���ݿ���ִ��SQL
CORESQL="java -cp $RPT_JARS -Dfile.encoding=GBK com.yc.etl.sql.ExeSql -j $RPT_CONF/jdbc_core.properties "
# �ڱ���ϵͳ���ݿ���ִ��SQL
RPTSQL="java  -cp $RPT_JARS -Dfile.encoding=GBK com.yc.etl.sql.ExeSql -j $RPT_CONF/jdbc_report.properties "


# ���ú����ս��־
# $CORESQL -s "update  cxtzt set yyjd = 10  "


# �����ı�������״̬
$RPTSQL -s "delete from rpt_sysfile "
$RPTSQL -s "insert into rpt_sysfile (sys_flag,flr_flag,sys_date,over_time,file_path) values ('easycore', 'SDM', '1999-01-01', '', '') "
$RPTSQL -s "insert into rpt_sysfile (sys_flag,flr_flag,sys_date,over_time,file_path) values ('aml',      'ITF', '1999-01-01', '', '') "


# ɾ�������������ı�
cd $RPT_FILE
rm -rf *


# ���������־
cd $RPT_LOGS
rm -rf *

exit 0
