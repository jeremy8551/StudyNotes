#! /usr/bin/ksh


exec_sql1() 
{
dbaccess `sed -n '1'p $HOME/sjpt/bin/db.ini`<< !
$@;
!
    if [ $? -ne 0 ]
    then
        echo "$@ִ��ʧ��"
        exit 1
    fi
}

_temp_file=$HOME/sjpt/data/YWDATE.tmp

exec_sql1 "unload to $_temp_file delimiter ',' select to_char(date(lstopenday),'%Y%m%d') from sys " >> /dev/null 2>&1

_RQ=`cat $_temp_file`
_RQ=`expr substr $_RQ 1 8`
rm -f $_temp_file

# ���غ�����������
echo $_RQ

exit 0
