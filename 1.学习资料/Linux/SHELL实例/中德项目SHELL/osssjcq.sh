#! /usr/bin/ksh

# 数据平台: 1104 抽取程序

exec_sql1() 
{
dbaccess `sed -n '1'p $HOME/sjpt/bin/db.ini`<< !
$@;
!
    if [ $? -ne 0 ]
    then
        echo "$@执行失败"
        exit 1
    fi
}

echo " "
echo " "
echo "*************************************************"
echo 开始采集 1104业务数据, `date +%Y-%m-%d_%T` 

# 进入数据存放目录
_FILEDIR=$HOME/sjpt/data
cd $_FILEDIR
if [ $? -ne 0 ];
then
    echo "进入目录${_FILEDIR}失败!"
    exit -1;
fi


#echo G01附录7的贷款分类
#exec_sql1 "unload to OSS_CORE_G0107_DKFL.del delimiter ',' select b.jgm, b.jjh, a.caltype1, b.ffje from entcustinf a right join fjjfh b on a.custno = b.khdh  "

echo 活期分户
exec_sql1 "unload to S_CORE_FHQFH.del delimiter ',' select jgm,zh,zhkz,czh,sjyye,czye,tcje,tdxj,bsxj,tzed,
                nsbh,zhmm,zjlb,zjh,bz,to_char(decode(jyrq,0,null,date(jyrq)),'%Y-%m-%d'),to_char(decode(qxr,0,null,date(qxr)),'%Y-%m-%d'),to_char(decode(sjyrq,0,null,date(sjyrq)),'%Y-%m-%d'),
                to_char(decode(bdhrq,0,null,date(bdhrq)),'%Y-%m-%d'),to_char(decode(dqrq,0,null,date(dqrq)),'%Y-%m-%d'),njnd,js,tzjs,ll,tzll,
                sjyjs,jxbh,czcdlx,czcdh,dyyh,dyhh,wdzxs,llfdb,cbdac from fhqfh "

echo 整整定期分户
exec_sql1 "unload to S_CORE_FZZFH.del delimiter ',' select jgm,zh,zhkz,czh,zhmm,zjlb,zjh,bz,to_char(decode(ykhrq,0,null,date(ykhrq)),'%Y-%m-%d'),
                to_char(decode(jyrq,0,null,date(jyrq)),'%Y-%m-%d'),to_char(decode(qxr,0,null,date(qxr)),'%Y-%m-%d'),to_char(decode(sjyrq,0,null,date(sjyrq)),'%Y-%m-%d'),
                to_char(decode(dqrq,0,null,date(dqrq)),'%Y-%m-%d'),ll,cq,zqcs,zdzccs,jxbh,czcdlx,czcdh,dyyh,dyhh,wdzxs,llfdb,cbdac from fzzfh  "

echo 定活两便分户
exec_sql1 "unload to S_CORE_FDHLBFH.del delimiter ',' select jgm,zh,zhkz,czh,zhmm,zjlb,zjh,bz,
                to_char(decode(jyrq,0,null,date(jyrq)),'%Y-%m-%d'),to_char(decode(qxr,0,null,date(qxr)),'%Y-%m-%d'),jxbh,czcdlx,czcdh,dyyh,dyhh,wdzxs,llfdb,cbdac from fdhlbfh "

echo 通知（个人/单位）
exec_sql1 "unload to S_CORE_FTZCKFH.del delimiter ',' select jgm,zh,zhkz,czh,zhmm,zjlb,zjh,bz,
                to_char(decode(jyrq,0,null,date(jyrq)),'%Y-%m-%d'),to_char(decode(qxr,0,null,date(qxr)),'%Y-%m-%d'),to_char(decode(sjyrq,0,null,date(sjyrq)),'%Y-%m-%d'),ll,cq,
                zqcs,jxbh,czcdlx,czcdh,dyyh,dyhh,wdzxs,llfdb,cbdac from ftzckfh "

echo 零存整取/教育储蓄
exec_sql1 "unload to S_CORE_FLCZQFH.del delimiter ',' select jgm,zh,zhkz,czh,sjyye,czye,tcje,tdxj,bsxj,
                zhmm,zqzq,lfzje,zqcs,zjlb,zjh,bz,to_char(decode(jyrq,0,null,date(jyrq)),'%Y-%m-%d'),to_char(decode(qxr,0,null,date(qxr)),'%Y-%m-%d'),
                to_char(decode(sjyrq,0,null,date(sjyrq)),'%Y-%m-%d'),to_char(decode(dqrq,0,null,date(dqrq)),'%Y-%m-%d'),cq,ll,js,
                bnsjs,sjyjs,jxbh,czcdlx,czcdh,dyyh,dyhh,wdzxs,llfdb,cbdac from flczqfh "

echo 整存零取/存本取息
exec_sql1 "unload to S_CORE_FZCLQFH.del delimiter ',' select jgm,zh,zhkz,czh,sjyye,czye,tcje,tdxj,bsxj,zhmm,zqzq,lfzje,zqcs,
                zjlb,zjh,bz,to_char(decode(jyrq,0,null,date(jyrq)),'%Y-%m-%d'),to_char(decode(qxr,0,null,date(qxr)),'%Y-%m-%d'),to_char(decode(sjyrq,0,null,date(sjyrq)),'%Y-%m-%d'),
                to_char(decode(dqrq,0,null,date(dqrq)),'%Y-%m-%d'),cq,ll,js,bnsjs,sjyjs,
                jxbh,czcdlx,czcdh,dyyh,dyhh,wdzxs,llfdb,cbdac from fzclqfh "

echo 单位协议存款
exec_sql1 "unload to S_CORE_FXYCKFH.del delimiter ',' select jgm,zh,dfzh,to_char(decode(xyksrq,0,null,date(xyksrq)),'%Y-%m-%d'),to_char(decode(xydqrq,0,null,date(xydqrq)),'%Y-%m-%d'),xyje,
                zhkz,czh,zhmm,zjlb,zjh,bz,to_char(decode(jyrq,0,null,date(jyrq)),'%Y-%m-%d'),to_char(decode(qxr,0,null,date(qxr)),'%Y-%m-%d'),to_char(decode(sjyrq,0,null,date(sjyrq)),'%Y-%m-%d'),js,
                xyjs,ll,xyll,sjyjs,sjyxyjs,jxbh,llfdb,cbdac from fxyckfh "

echo 内部帐
exec_sql1 "unload to S_CORE_FNBZFH.del delimiter ',' select jgm,zh,zhkz,czh,cwdh,zjlb,zjh,bz,
                to_char(decode(jyrq,0,null,date(jyrq)),'%Y-%m-%d'),to_char(decode(qxr,0,null,date(qxr)),'%Y-%m-%d'),to_char(decode(dqrq,0,null,date(dqrq)),'%Y-%m-%d'),to_char(decode(sjyrq,0,null,date(sjyrq)),'%Y-%m-%d'),
                tzed,ll1,ll2,ll3,js1,js2,js3,sjyjs,jxbh,llfdb,cbdac from fnbzfh "

# NC与核心机构对照关系
echo 机构码信息表
exec_sql1 "unload to S_CORE_JGMXXB.del delimiter ',' select hxjgm,ncjgm,czy,jgjc,pzlb,pzjsh,to_char(decode(pzrq,0,null,date(pzrq)),'%Y-%m-%d') ,bz from jgmxxb "

echo 利率表
exec_sql1 "unload to S_CORE_SLLB.del delimiter ',' select CZH,HBH,CQ,to_char(decode(SXRQ,0,null,date(SXRQ)),'%Y-%m-%d'),NLL,BZ from SLLB "

echo 科目字典
exec_sql1 "unload to S_CORE_SKMZD.del delimiter ',' select KMXH,KMH,KMM,ZL,YEF,KMBZ,DYCDZH,CDZH,HZKMH,CBBZ from SKMZD "

echo 计提登记簿
exec_sql1 "unload to S_CORE_DJTDJB.del delimiter ',' select JGM,KMH,HBH,HSZH,to_char(decode(JTRQ,0,null,date(JTRQ)),'%Y-%m-%d'),JTJE from DJTDJB "

#echo 科目总账表
#exec_sql1 "unload to S_CORE_ZKMZZ.del delimiter ',' SELECT jgm,hbh,kmh,jye,dye,jjs,djs,rcjjs,rcdjs,
#           rcjye,rcdye,rjfse,rdfse,rjbs,rdbs,rkhs,rxhs,ycjjs,ycdjs,ycjye,ycdye,yjfse,ydfse,yjbs,ydbs,
#           ykhs,yxhs,jcjjs,jcdjs,jcjye,jcdye,jjfse,jdfse,jjbs,jdbs,jkhs,jxhs,ncjjs,ncdjs,ncjye,ncdye,
#           njfse,ndfse,njbs,ndbs,nkhs,nxhs,ljkhs,ljxhs,yef,fsrq,yf,nf from ZKMZZ "

#echo 科目字典
#exec_sql1 "unload to S_CORE_SKMZD.del delimiter ',' SELECT kmxh,kmh,kmm,zl,yef,kmbz,dycdzh,cdzh,hzkmh,cbbz from SKMZD "



echo 卸数完毕, 当前时间: `date +%Y-%m-%d_%T` 
