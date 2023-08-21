#!/bin/sh
# ��    �ܣ���������ϵͳ��̨����
# �� �� �ˣ����Ⱦ�
# ����ʱ�䣺2011-03-18
# ������˾�����������׳ϿƼ����޹�˾

echo " "
echo `date +%Y-%m-%d_%T` ��ʼ���������� ..

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


echo RPT_HOME = $RPT_HOME
echo RPT_BIN = $RPT_BIN
echo RPT_FILE = $RPT_FILE
echo RPT_SRC = $RPT_SRC
echo RPT_TEMP = $RPT_TEMP
echo RPT_LOGS = $RPT_LOGS
echo RPT_CONF = $RPT_CONF
echo RPT_LIB = $RPT_LIB


# ����ļ��в����ڣ����½�
if [ ! -d $RPT_HOME ]; then
mkdir $RPT_HOME
mkdir $RPT_BIN
mkdir $RPT_FILE
mkdir $RPT_SRC
mkdir $RPT_TEMP
mkdir $RPT_LOGS
mkdir $RPT_CONF
mkdir $RPT_LIB
exit 0
fi


# ��ӡJVM�����뻷������
java -cp $RPT_LIB/etl.jar com.yc.tls.JvmConfig

###############################################################################

# �����ִ���ļ�Ŀ¼
cd $RPT_BIN


# �����ػ�������־
daemon_log=$RPT_LOGS/daemon_`date +%Y-%m-%d`.log


echo `date +%Y-%m-%d_%T` �����������ݴ��������ػ����� ..
nohup sh daemon.sh -s 600 -c $RPT_BIN/backup.sh -l "${RPT_LOGS}/backup"   -x -k  >> ${daemon_log} 2>&1 & 
if [ $? -ne 0 ]; then
    echo �������ݴ��������ػ�����ʧ��!
    exit 3
fi


echo `date +%Y-%m-%d_%T` ������������EASYCOREж���ػ����� ..
nohup sh daemon.sh -s 1200 -c $RPT_BIN/easycore/export_easycore.sh -l "${RPT_LOGS}/export_easycore" -x -k    >> ${daemon_log} 2>&1 & 
if [ $? -ne 0 ]; then
    echo ��������EASYCOREж���ػ�����ʧ�ܣ�
    exit 1
fi


echo `date +%Y-%m-%d_%T` ������������EASYHISж���ػ����� ..
nohup sh daemon.sh -s 6 -c $RPT_BIN/easycore/export_easyhis.sh -l "${RPT_LOGS}/export_easyhis" -x -k    >> ${daemon_log} 2>&1 & 
if [ $? -ne 0 ]; then
    echo ��������EASYHISж���ػ�����ʧ�ܣ�
    exit 1
fi


echo `date +%Y-%m-%d_%T` ����������ϴǮ�ӿ��ػ����� ..
nohup sh daemon.sh -s 6 -c $RPT_BIN/aml/export_aml_itf.sh -l "${RPT_LOGS}/export_aml_itf"   -x -k    >> ${daemon_log} 2>&1 & 
if [ $? -ne 0 ]; then
    echo ������ϴǮ�ӿ��ػ�����ʧ�ܣ�
    exit 2
fi

echo `date +%Y-%m-%d_%T` �����������ֳ���ܱ��ͽӿ��ػ����� ..
nohup sh daemon.sh -s 6 -c $RPT_BIN/oss/export_oss_itf.sh -l "${RPT_LOGS}/export_oss_itf"   -x -k    >> ${daemon_log} 2>&1 & 
if [ $? -ne 0 ]; then
    echo ������ϴǮ�ӿ��ػ�����ʧ�ܣ�
    exit 4
fi


echo `date +%Y-%m-%d_%T` ����ϵͳ��̨���������ɹ���

exit 0



