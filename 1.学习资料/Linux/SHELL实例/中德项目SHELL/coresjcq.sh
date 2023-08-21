#! /usr/bin/ksh

# ����ƽ̨ �ɼ�����ϵͳ������Ϣ�ű�

exec_sql1()
{
dbaccess `sed -n '1'p $HOME/sjpt/bin/db.ini`<< !
$@;
!
    if [ $? -ne 0 ]; then
        echo "$@ִ��ʧ��"
        exit 1
    fi
}

echo " "
echo " "
echo "*************************************************"
echo ��ʼ�ɼ�����ϵͳ������Ϣ, `date +%Y-%m-%d_%T` 

# �������ݴ��Ŀ¼
_FILEDIR=$HOME/sjpt/data
cd $_FILEDIR
if [ $? -ne 0 ];
then
    echo "����Ŀ¼${_FILEDIR}ʧ��!" 
    exit -1
fi


# ���Ļ����� ����ƽ̨������ϵ���õ�
echo ��ȡ���Ļ�����Ϣ
exec_sql1 "unload to S_CORE_ORGANINFO.del delimiter ',' select ORGANNO,SUPORGANNO,ORGANNAME,ORGANSHORTFORM,ENNAME,
               LOCATE,ORDERNO,DISTNO,LAUNCHDATE,ORGANTYPE,ORGANLEVEL,FINCODE,STATE,ORGANCHIEF,TELNUM,ADDRESS,
                  POSTCODE,MEMO,PK1 from organinfo "


echo ��ȡ������������
exec_sql1 "unload to S_CORE_SYS.del delimiter ',' SELECT pk1,cnname,version,sysdesc,property,to_char(decode(openday,0,null,date(openday)),'%Y-%m-%d'),to_char(decode(lstopenday,0,null,date(lstopenday)),'%Y-%m-%d'),pininvalid,memo,flag from sys "




echo ж�����, ��ǰʱ��: `date +%Y-%m-%d_%T` 
exit 0

