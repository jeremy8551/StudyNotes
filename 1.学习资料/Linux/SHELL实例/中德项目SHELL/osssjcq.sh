#! /usr/bin/ksh

# ����ƽ̨: 1104 ��ȡ����

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
echo ��ʼ�ɼ� 1104ҵ������, `date +%Y-%m-%d_%T` 

# �������ݴ��Ŀ¼
_FILEDIR=$HOME/sjpt/data
cd $_FILEDIR
if [ $? -ne 0 ];
then
    echo "����Ŀ¼${_FILEDIR}ʧ��!"
    exit -1;
fi


#echo G01��¼7�Ĵ������
#exec_sql1 "unload to OSS_CORE_G0107_DKFL.del delimiter ',' select b.jgm, b.jjh, a.caltype1, b.ffje from entcustinf a right join fjjfh b on a.custno = b.khdh  "

echo ���ڷֻ�
exec_sql1 "unload to S_CORE_FHQFH.del delimiter ',' select jgm,zh,zhkz,czh,sjyye,czye,tcje,tdxj,bsxj,tzed,
                nsbh,zhmm,zjlb,zjh,bz,to_char(decode(jyrq,0,null,date(jyrq)),'%Y-%m-%d'),to_char(decode(qxr,0,null,date(qxr)),'%Y-%m-%d'),to_char(decode(sjyrq,0,null,date(sjyrq)),'%Y-%m-%d'),
                to_char(decode(bdhrq,0,null,date(bdhrq)),'%Y-%m-%d'),to_char(decode(dqrq,0,null,date(dqrq)),'%Y-%m-%d'),njnd,js,tzjs,ll,tzll,
                sjyjs,jxbh,czcdlx,czcdh,dyyh,dyhh,wdzxs,llfdb,cbdac from fhqfh "

echo �������ڷֻ�
exec_sql1 "unload to S_CORE_FZZFH.del delimiter ',' select jgm,zh,zhkz,czh,zhmm,zjlb,zjh,bz,to_char(decode(ykhrq,0,null,date(ykhrq)),'%Y-%m-%d'),
                to_char(decode(jyrq,0,null,date(jyrq)),'%Y-%m-%d'),to_char(decode(qxr,0,null,date(qxr)),'%Y-%m-%d'),to_char(decode(sjyrq,0,null,date(sjyrq)),'%Y-%m-%d'),
                to_char(decode(dqrq,0,null,date(dqrq)),'%Y-%m-%d'),ll,cq,zqcs,zdzccs,jxbh,czcdlx,czcdh,dyyh,dyhh,wdzxs,llfdb,cbdac from fzzfh  "

echo ��������ֻ�
exec_sql1 "unload to S_CORE_FDHLBFH.del delimiter ',' select jgm,zh,zhkz,czh,zhmm,zjlb,zjh,bz,
                to_char(decode(jyrq,0,null,date(jyrq)),'%Y-%m-%d'),to_char(decode(qxr,0,null,date(qxr)),'%Y-%m-%d'),jxbh,czcdlx,czcdh,dyyh,dyhh,wdzxs,llfdb,cbdac from fdhlbfh "

echo ֪ͨ������/��λ��
exec_sql1 "unload to S_CORE_FTZCKFH.del delimiter ',' select jgm,zh,zhkz,czh,zhmm,zjlb,zjh,bz,
                to_char(decode(jyrq,0,null,date(jyrq)),'%Y-%m-%d'),to_char(decode(qxr,0,null,date(qxr)),'%Y-%m-%d'),to_char(decode(sjyrq,0,null,date(sjyrq)),'%Y-%m-%d'),ll,cq,
                zqcs,jxbh,czcdlx,czcdh,dyyh,dyhh,wdzxs,llfdb,cbdac from ftzckfh "

echo �����ȡ/��������
exec_sql1 "unload to S_CORE_FLCZQFH.del delimiter ',' select jgm,zh,zhkz,czh,sjyye,czye,tcje,tdxj,bsxj,
                zhmm,zqzq,lfzje,zqcs,zjlb,zjh,bz,to_char(decode(jyrq,0,null,date(jyrq)),'%Y-%m-%d'),to_char(decode(qxr,0,null,date(qxr)),'%Y-%m-%d'),
                to_char(decode(sjyrq,0,null,date(sjyrq)),'%Y-%m-%d'),to_char(decode(dqrq,0,null,date(dqrq)),'%Y-%m-%d'),cq,ll,js,
                bnsjs,sjyjs,jxbh,czcdlx,czcdh,dyyh,dyhh,wdzxs,llfdb,cbdac from flczqfh "

echo ������ȡ/�汾ȡϢ
exec_sql1 "unload to S_CORE_FZCLQFH.del delimiter ',' select jgm,zh,zhkz,czh,sjyye,czye,tcje,tdxj,bsxj,zhmm,zqzq,lfzje,zqcs,
                zjlb,zjh,bz,to_char(decode(jyrq,0,null,date(jyrq)),'%Y-%m-%d'),to_char(decode(qxr,0,null,date(qxr)),'%Y-%m-%d'),to_char(decode(sjyrq,0,null,date(sjyrq)),'%Y-%m-%d'),
                to_char(decode(dqrq,0,null,date(dqrq)),'%Y-%m-%d'),cq,ll,js,bnsjs,sjyjs,
                jxbh,czcdlx,czcdh,dyyh,dyhh,wdzxs,llfdb,cbdac from fzclqfh "

echo ��λЭ����
exec_sql1 "unload to S_CORE_FXYCKFH.del delimiter ',' select jgm,zh,dfzh,to_char(decode(xyksrq,0,null,date(xyksrq)),'%Y-%m-%d'),to_char(decode(xydqrq,0,null,date(xydqrq)),'%Y-%m-%d'),xyje,
                zhkz,czh,zhmm,zjlb,zjh,bz,to_char(decode(jyrq,0,null,date(jyrq)),'%Y-%m-%d'),to_char(decode(qxr,0,null,date(qxr)),'%Y-%m-%d'),to_char(decode(sjyrq,0,null,date(sjyrq)),'%Y-%m-%d'),js,
                xyjs,ll,xyll,sjyjs,sjyxyjs,jxbh,llfdb,cbdac from fxyckfh "

echo �ڲ���
exec_sql1 "unload to S_CORE_FNBZFH.del delimiter ',' select jgm,zh,zhkz,czh,cwdh,zjlb,zjh,bz,
                to_char(decode(jyrq,0,null,date(jyrq)),'%Y-%m-%d'),to_char(decode(qxr,0,null,date(qxr)),'%Y-%m-%d'),to_char(decode(dqrq,0,null,date(dqrq)),'%Y-%m-%d'),to_char(decode(sjyrq,0,null,date(sjyrq)),'%Y-%m-%d'),
                tzed,ll1,ll2,ll3,js1,js2,js3,sjyjs,jxbh,llfdb,cbdac from fnbzfh "

# NC����Ļ������չ�ϵ
echo ��������Ϣ��
exec_sql1 "unload to S_CORE_JGMXXB.del delimiter ',' select hxjgm,ncjgm,czy,jgjc,pzlb,pzjsh,to_char(decode(pzrq,0,null,date(pzrq)),'%Y-%m-%d') ,bz from jgmxxb "

echo ���ʱ�
exec_sql1 "unload to S_CORE_SLLB.del delimiter ',' select CZH,HBH,CQ,to_char(decode(SXRQ,0,null,date(SXRQ)),'%Y-%m-%d'),NLL,BZ from SLLB "

echo ��Ŀ�ֵ�
exec_sql1 "unload to S_CORE_SKMZD.del delimiter ',' select KMXH,KMH,KMM,ZL,YEF,KMBZ,DYCDZH,CDZH,HZKMH,CBBZ from SKMZD "

echo ����Ǽǲ�
exec_sql1 "unload to S_CORE_DJTDJB.del delimiter ',' select JGM,KMH,HBH,HSZH,to_char(decode(JTRQ,0,null,date(JTRQ)),'%Y-%m-%d'),JTJE from DJTDJB "

#echo ��Ŀ���˱�
#exec_sql1 "unload to S_CORE_ZKMZZ.del delimiter ',' SELECT jgm,hbh,kmh,jye,dye,jjs,djs,rcjjs,rcdjs,
#           rcjye,rcdye,rjfse,rdfse,rjbs,rdbs,rkhs,rxhs,ycjjs,ycdjs,ycjye,ycdye,yjfse,ydfse,yjbs,ydbs,
#           ykhs,yxhs,jcjjs,jcdjs,jcjye,jcdye,jjfse,jdfse,jjbs,jdbs,jkhs,jxhs,ncjjs,ncdjs,ncjye,ncdye,
#           njfse,ndfse,njbs,ndbs,nkhs,nxhs,ljkhs,ljxhs,yef,fsrq,yf,nf from ZKMZZ "

#echo ��Ŀ�ֵ�
#exec_sql1 "unload to S_CORE_SKMZD.del delimiter ',' SELECT kmxh,kmh,kmm,zl,yef,kmbz,dycdzh,cdzh,hzkmh,cbbz from SKMZD "



echo ж�����, ��ǰʱ��: `date +%Y-%m-%d_%T` 
