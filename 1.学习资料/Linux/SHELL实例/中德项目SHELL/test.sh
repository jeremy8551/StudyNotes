#! /usr/bin/ksh


exec_sql1() 
{
dbaccess `sed -n '1'p $HOME/sjpt/bin/db.ini`<< !
$@;
!
       if [ $? -ne 0 ]
       then
            echo "$@ִ��ʧ��"
            exit 2
       fi
}

exec_sql() 
{
dbaccess `sed -n '2'p $HOME/sjpt/bin/db.ini`<< !
$@;
!
       if [ $? -ne 0 ]
       then
            echo "$@ִ��ʧ��"
            exit 3
       fi
}

# �������ݴ��Ŀ¼
_FILEDIR=$HOME/sjpt/data
cd $_FILEDIR
if [ $? -ne 0 ];
then
    echo "����Ŀ¼${_FILEDIR}ʧ��!" ;
    exit -1;
fi

# exec_sql1 "unload to S_CORE_DDKJTDJB.del delimiter ',' select JGM,HBH,JJH,QS,
#             to_char(decode(JTRQ,0,null,date()),'%Y-%m-%d')
#             ,YSLX,YSWSLX,CSLX,DCBYJSLX,DCBYSWSLX,DCBCSLX,YJSLXZH,YSWSLXZH,CSLXZH,KMH
#            from DDKJTDJB "
# 

# exec_sql1 "unload to cxtzt.del delimiter ',' select kzz[2] from cxtzt  "

if [ 1 -ne 0 -a 12 -eq 12 -a 31 -eq 31 ]; then 
    echo yes
else 
    echo no
fi