#!/bin/sh
# ��    �ܣ��Ӻ���ϵͳж�������ı�������ű��ǵ��̵߳ģ�
# �� �� �ˣ����Ⱦ�
# ����ʱ�䣺2011-03-29
# ������˾�����������׳ϿƼ����޹�˾

# �ж��Ƿ��ظ�ִ�ж��
ps -ef|grep "sh $0"|while read line 
do 
    # ���̺�
    kpid=`echo $line|awk -F" " 'NR==1,NR==1 {print $2}'`
    # �����̺�
    kppid=`echo $line|awk -F" " 'NR==1,NR==1 {print $3}'`
    
    if [ "$kpid" != "$$" -a "$kppid" != "$$" ]; then 
        echo $line
        echo ����ͬʱ�ظ�ִ�ж��!
        exit 0
    fi
done


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
# ����ϵͳ����JAR��
RPT_JARS=
for i in "$RPT_LIB"/*.jar; do
  RPT_JARS="$RPT_JARS":"$i"
done
export RPT_JARS
fi


# ��ʼж��
java -cp $RPT_JARS \
	 -Dfile.encoding=GBK adaptor.Main \
     -adaper adaptor.impl.EasycoreAdaptor \
     -sysTag EASYCORE \
     -jdbc $RPT_CONF/rptdb_jdbc.properties \
     -export $RPT_CONF/easycore/export.xml \
     -fileDir $RPT_FILE/EASYCORE \
     -auto 
     
if [ $? -ne 0 ]; then
    echo ж�����ݷ�������!
    exit 1
fi


exit 0

