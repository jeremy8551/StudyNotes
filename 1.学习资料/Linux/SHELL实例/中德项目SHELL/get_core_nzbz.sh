#! /usr/bin/ksh

# �ű����ܣ��жϺ��ĵ�ǰ�Ƿ���ת, ���� 0-��ת 1-����ת

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

_FILEDIR=$HOME/sjpt/data
cd $_FILEDIR
if [ $? -ne 0 ];
then
    echo "����Ŀ¼${_FILEDIR}ʧ��!" ;
    exit 1;
fi

_temp_file=$HOME/sjpt/data/NZBZ.tmp

exec_sql1 "unload to $_temp_file delimiter ',' select kzz[2] from cxtzt  " >> /dev/null 2>&1

_RQ=`cat $_temp_file`
_RQ=`expr substr $_RQ 1 1`
rm -f $_temp_file

# exit 1

# ��� cxtzt���е�kzz[2]����N����ʾ��ת
if [ "$_RQ" == "N" ]; then 
    exit 0
fi

exit 1
