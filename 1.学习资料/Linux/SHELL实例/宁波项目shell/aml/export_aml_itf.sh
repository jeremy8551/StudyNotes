#!/bin/sh
# ��    �ܣ�����ҵ��ϵͳ�������ɷ�ϴǮ�ӿ��ı�
#           1. ���ݺ����������ڡ���ϴǮ�ӿ��ı��������� �Ƚ��ж��Ƿ����� ��ϴǮ�ӿ������ı�
#           2. ����ָ�����ڵĺ�������
#           3. ִ�� aml_itf_batchsql.xml �е�SQL��䣬�ӹ����ɽӿ�����
#           4. �Ѿ����ӹ��Ľӿ�����ж�ص� �ļ�������
#           5. �ѽӿ������ı���״̬���µ� �ı�������״̬��rpt_sysfile��
#           6. ����ӿ����ݱ���ɹ�, �����ı�Ŀ¼�����һ��SUCCESS�ļ���ǰ̨ϵͳ��������ı��жϡ��ӿ������ı����Ƿ�׼����ϣ�
# �� �� �ˣ����Ⱦ�
# ����ʱ�䣺2011-03-18
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



# ���ɷ�ϴǮ�ӿ������ļ�
java -cp $RPT_JARS \
     -Dfile.encoding=GBK itf.AmlItfAdaptor \
     -systag AML \
     -jdbc $RPT_CONF/rptdb_jdbc.properties \
     -load $RPT_CONF/aml/load.xml \
     -batch $RPT_CONF/aml/batchSql.xml \
     -export $RPT_CONF/aml/export.xml \
     -depend EASYCORE,EASYHIS \
     -req 0 \
     
if [ $? -ne 0 ]; then
    exit 1
fi


exit 0
