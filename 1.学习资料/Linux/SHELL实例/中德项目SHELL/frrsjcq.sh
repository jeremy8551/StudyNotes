#! /usr/bin/ksh

# ����ƽ̨: ����ͳ�Ʊ��� ��ȡ����

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

echo " "
echo " "
echo "*************************************************"
echo ��ʼ�ɼ� ����ͳ�Ʊ��� ҵ������, `date +%Y-%m-%d_%T` 

# �������ݴ��Ŀ¼
_FILEDIR=$HOME/sjpt/data
cd $_FILEDIR
if [ $? -ne 0 ];
then
    echo "����Ŀ¼${_FILEDIR}ʧ��!"
    exit -1;
fi


#�Թ��ͻ���Ϣж�����
exec_sql1 "unload to S_CORE_FRR_ENTCUSTINF.del delimiter ',' SELECT custno,ecotype,caltype1,untsize,untcha
           FROM entcustinf"
           
           
#��ݷֻ�ж�����
exec_sql1 "unload to S_CORE_FRR_FJJFH.del delimiter ',' SELECT jjh,khdh,jgm,hbh,zhkz,ffje,bnbj,bwbj,to_char(decode(ffrq,0,null,date(ffrq)),'%Y-%m-%d')
           FROM fjjfh where zhkz[7] <> '2'"
           
#һ���������Ϣж�����
exec_sql1 "unload to S_CORE_FRR_CRDT_CZ_DK.del delimiter ',' SELECT jjh,khdh,dbfs
           FROM crdt_cz_dk  where ywpz <> '010003'"
           
           


echo ж�����, ��ǰʱ��: `date +%Y-%m-%d_%T` 



