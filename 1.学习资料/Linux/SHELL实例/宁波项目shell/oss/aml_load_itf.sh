#!/bin/sh
# ��    �ܣ���ϴǮǰ̨ϵͳ -> ϵͳ�������� -> ִ�нӿڳ��򣬵������SHELL ����ITF�µ�����
# �� �� �ˣ����Ⱦ�
# ����ʱ�䣺2011-03-18
# ������˾�����������׳ϿƼ����޹�˾

func_usage()
{
    echo "  aml_load_itf.sh �ı�����Ŀ¼                "
    echo "  �˳�״̬:                                   "
    echo "      =0 ִ�гɹ�                             "
    echo "      >0 ��������!                            "
    exit 99
}

func_excsql() 
{
dbaccess $1 << !
$2;
!
if [ $? -ne 0 ]; then
    echo "�������� $1, ִ��SQL: $2 ��������!"
    exit 1
fi
}


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
fi


# �ӿ��ı�����Ŀ¼
filedirdate=$1
if [ "$filedirdate" == "" ]; then
    func_usage
fi
if [ ! -d $filedirdate ]; then
    func_usage
fi


# ��ȡ��ϴǮ���ݿ���˻���Ϣ
idsCfg=`sh $RPT_BIN/getIDScfg.sh -n report`
if [ $? -ne 0 ]; then
    echo ��ȡ��ϴǮ���ݿ��˻���Ϣ����!
    exit 2
fi


echo " "
echo " "
echo "========== ��ʼ���ֳ���ܱ��ͽӿ��ı�����" `date +%Y-%m-%d_%T` 


# ���������
func_excsql "${idsCfg}" "delete from AML_ITF_TRANS   "
func_excsql "${idsCfg}" "delete from AML_ITF_ACCT    "
func_excsql "${idsCfg}" "delete from AML_ITF_CSTM    "
func_excsql "${idsCfg}" "delete from DMD_BANK_INFO   "


# ���ط�ϴǮ�ӿ�����
func_excsql "${idsCfg}" "load from ${filedirdate}/aml_itf_trans_m.txt   insert into AML_ITF_TRANS   "
func_excsql "${idsCfg}" "load from ${filedirdate}/aml_itf_acct_m.txt    insert into AML_ITF_ACCT    "
func_excsql "${idsCfg}" "load from ${filedirdate}/aml_itf_cstm_m.txt    insert into AML_ITF_CSTM    "
func_excsql "${idsCfg}" "load from ${filedirdate}/dmd_bank_info_m.txt   insert into DMD_BANK_INFO    "

echo "========== ��ʼ��ϴǮ�ӿ��ı��������!" `date +%Y-%m-%d_%T`
echo " "
echo " "

exit 0
