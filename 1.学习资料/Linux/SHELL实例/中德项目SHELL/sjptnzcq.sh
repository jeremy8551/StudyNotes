#! /usr/bin/ksh

# ����ƽ̨��ת�ɼ��ű�

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
echo ����ƽ̨��ת����, `date +%Y-%m-%d_%T` 

# �������ݴ��Ŀ¼
_FILEDIR=$HOME/sjpt/data
cd $_FILEDIR
if [ $? -ne 0 ];
then
    echo "����Ŀ¼${_FILEDIR}ʧ��!" ;
    exit -1;
fi

echo begin_time: `date +%Y-%m-%d_%H:%M:%S` 

echo ��ȡ������ϸ������ fdrmx
exec_sql1 "unload to S_CORE_QYZX_FLSMXZ1231.del delimiter ',' select kmh,dfkmh,hbh,khdh,
          zzh,zhkh,xh,hszh,dljg,jgm,xtrq,to_char(decode(jyrq,0,null,date(jyrq)),'%Y-%m-%d'),zxlsh,
          gylsh,jym,jyje,ye,js,pzbz,tdbz,zy,sqm,pzzl,pzhm,jdbz,pj,
          gy1,gy2,dyzzh,dyzhkh,dyxh,dfhszh,jysj,cngy,bz 
          from fdrmx 
          where hszh LIKE 'HT%' 
            and jdbz = '2' "


echo ж�����, ��ǰʱ��: `date +%Y-%m-%d_%T` 
echo "  "