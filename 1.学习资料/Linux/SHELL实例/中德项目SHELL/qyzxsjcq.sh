#! /usr/bin/ksh

# 企业征信数据采集脚本


exec_sql1() 
{
dbaccess `sed -n '1'p $HOME/sjpt/bin/db.ini`<< !
$@;
!
       if [ $? -ne 0 ]
       then
            echo "$@执行失败"
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
            echo "$@执行失败"
            exit 3
       fi
}


echo " "
echo " "
echo "*************************************************"
echo 采集 企业征信数据, `date +%Y-%m-%d_%T` 

# 进入数据存放目录
_FILEDIR=$HOME/sjpt/data
cd $_FILEDIR
if [ $? -ne 0 ];
then
    echo "进入目录${_FILEDIR}失败!" ;
    exit -1;
fi

echo begin_time: `date +%Y-%m-%d_%H:%M:%S` 


echo 抽取 客户信息基表 CUSTINFO
exec_sql1 "unload to S_CORE_QYZX_CUSTINFO.del delimiter ',' select pk1,reader,writer,custno,
           custname,custshortform,enname,country,relation,certtype,
           certno,telnum,postcode,netaddr,email,faxnum,acctopenor,acctno,
           to_char(decode(createdate,0,null,date(createdate)),'%Y-%m-%d'),openactor,openorg,assactor,to_char(decode(abolishdate,0,null,date(abolishdate)),'%Y-%m-%d'),closeactor,custmgr,
           orgofcustm,distno,vocationcode,address,servtype,creditlvl,to_char(decode(crdassdate,0,null,date(crdassdate)),'%Y-%m-%d'),
           custtype,to_char(decode(clsdate,0,null,date(clsdate)),'%Y-%m-%d'),control,custterm,dkjsh,regionalism,memo from CUSTINFO " 



echo 抽取 单位客户信息表 entcustinf
exec_sql1 "unload to S_CORE_QYZX_ENTCUSTINF.del delimiter ',' select custno,untcha,loancardid,
           loanadmaud,ficpsn,ficpsnidty,ficpsnid,yearsoftrade,marrystatus,edulvl,
           inhaitancystatus,ficpsnaddr,spousename,spouseprofes,spouseunit,
           spouseyealypay,familialmainasset,familialmaindebt,regtype,licence,
           to_char(decode(regdate,0,null,date(regdate)),'%Y-%m-%d'),to_char(decode(licencevaldate,0,null,date(licencevaldate)),'%Y-%m-%d'),licenceadm,licencead2,
           regcurrent,regcapital,licenseregaddr,untmanagei,taxcode,taxorgan,cuntaxid,
           regtaxid,fxlicenceid,chargedepart,ecotype,managerange,concurrentlyrange,
           manageitem,mainprod,mainvictualer,mainclient,offarea,offbelong,totalemployee,
           manager,organcode,to_char(decode(untcreatedate,0,null,date(untcreatedate)),'%Y-%m-%d'),unttype,caltype1,caltype2,
           caltype3,caltype4,untsize,organaddr,tel,untemail,cwblxfs,jckflag,ssgsflag,
           stockcode,stocktradesite,jtflag,sjgsmc,sjgsdkkh,sjgsdm,opnadmid,supopnadmid,
           supficpsn,supcerttype,supcertno,sjjbkhhmc from entcustinf " 



echo 抽取 借据分户 FJJFH
exec_sql1 "unload to S_CORE_QYZX_FJJFH.del delimiter ',' select jgm,jjh,hbh,kmh,khdh,dkzh,zhkz,sxzh,
           xh,dbzh,dbxh,yslxlj,yjlxlj,hbyjlx,sslxlj,hbsslx,bnqx,bwqx,ysfl,ssfl,ffje,
           bnbj,bwbj,hth,xebl,to_char(decode(ffrq,0,null,date(ffrq)),'%Y-%m-%d') ,jqrq,jyrq,qxr,to_char(decode(dqrq,0,null,date(dqrq)),'%Y-%m-%d'),
           yzdq,zzqxrq,ll,llfdbl,yqll,yqllfdbl,fxll,js,yqjs,qxzl,lxtzje,lxtzrq,jztqje,
           jztqrq,ffgy,jqgy,bz,cbdac from FJJFH " 


# 
echo 抽取 一般贷款借据信息 CRDT_CZ_DK
exec_sql1 "unload to S_CORE_QYZX_CRDT_CZ_DK.del delimiter ',' select SERNO,JJH,JGM,HTH,ZHDK,KHDH,KHMC,KHLX,DKZL,DKYT,
            YWPZ,HBH,YWPZ_XF,DKJE,DKXEBL,LLTZFS,JXFS,JZLL,LLFDB,DKLL,YQLLFDB,YQLL,DKQX,DKYS,DKTS,CZMSBL,
            CZBZBL,XMMC,WTZFSKZH,WTZFZHXH,WTZFZHHM,HKFS,DBFS,JSZH,JSZHXH,JSZHHM,DBRZH,DBRZHXH,DKZH,KMH,QDRQ,ZDRQ,JBRQ,
            DJRQ,JKQS,HKZQ,DKTX,DKLB,DKXS,SXFZFFS,JKRSXFFL,ZSXF,ZT,DJR
            from CRDT_CZ_DK " 



echo 抽取 货币信息表 SHBXX
exec_sql1 "unload to S_CORE_QYZX_SHBXX.del delimiter ',' select 
           qbs,hbh,njxrs,ywjx,ywmc,hbfh,zwmc,zwjx,gjdm,gjywmc,gjzwmc,clbz,zddfdw,hdqbje,qb1je,qb2je,qb3je,qb4je,qb5je,qb6je,
           qb7je,qb8je,qb9je,qb10je,qb11je,qb12je,qb13je,qb14je,qb15je,qb16je,qb17je,qb18je,qb19je,qb20je 
           from SHBXX " 



echo 抽取 贷款展期出帐申请 CRDT_CZ_DKZQ
exec_sql1 "unload to S_CORE_QYZX_CRDT_CZ_DKZQ.del delimiter ',' select zqhth,jjh,yhth,khdh,khmc,
           ydkzh,zqdkzh,hbh,yjkje,dkye,ykmh,zqkmh,yyqll,yzcll,
           to_char(decode(YQDRQ,0,null,date(YQDRQ)),'%Y-%m-%d'),to_char(decode(YZDRQ,0,null,date(YZDRQ)),'%Y-%m-%d'),zqje,to_char(decode(ZQDQR,0,null,date(ZQDQR)),'%Y-%m-%d'),
           zqllfdb,zqyqllfdb,zqzt,jgm,jyrq,djrq,czy,bz from CRDT_CZ_DKZQ " 



echo 抽取 贷款利息明细 FDKLXMX
exec_sql1 "unload to S_CORE_QYZX_FDKLXMX.del delimiter ',' select JGM,HBH,KMH,JJH,QS,KHDH,HM,JS,LL,LX,YSLX,QXR,ZXR,JXR,FLRQ,DYCS,SXH,RZBZ,JYRQ,JYGY,BCJE,GYLSH,BZ from FDKLXMX " 



echo 抽取 内部汇票登记薄 DNBHPDJB INNER JOIN FFHZ
exec_sql1 "unload to S_CORE_QYZX_HPXX.del delimiter ',' SELECT A.jgm,A.sqshm,A.hphm,B.khdh,
           A.sqrmc, A.hbh, A.cpje, to_char(decode(A.tsfkrq,0,null,date(A.tsfkrq)),'%Y-%m-%d'), A.dfbz,A.dflrgyh,A.dflrgylsh
           FROM DNBHPDJB A INNER JOIN FFHZ B ON A.sqrzh = B.zh" 



echo 抽取 贴现登记薄 DTXDJB
exec_sql1 "unload to S_CORE_QYZX_DTXDJB.del delimiter ',' SELECT JGM,JJH,HTH,DQZT,HPHM,PJZL 
           ,to_char(decode(QFRQ,0,null,date(QFRQ)),'%Y-%m-%d'), to_char(decode(DQRQ,0,null,date(DQRQ)),'%Y-%m-%d')
           ,PMJE,LL,LX,SQKHH,SQRM,SQHH,SQHM,CPRM,CDHH 
           ,CDHM,CDHHB,HY,LZHTH,LZJJH,LZLL,LZLX,ZCHTH,ZCJJH,ZCLL,ZCLX,PLZS,FXFS,JSZH,SQLX,MFZH
           ,MFLX,DKZH,BWZH,ZTXFS,HGRQ,RQ,GYH,GYLSH,LZRQ,LZGYH,LZGYLSH,GHRQ,GHGYH,GHGYLSH from DTXDJB " 

echo 抽取 贷款计提登记簿 DDKJTDJB
exec_sql1 "unload to S_CORE_DDKJTDJB.del delimiter ',' select JGM,HBH,JJH,QS,
            to_char(decode(JTRQ,0,null,date(JTRQ)),'%Y-%m-%d')
            ,YSLX,YSWSLX,CSLX,DCBYJSLX,DCBYSWSLX,DCBCSLX,YJSLXZH,YSWSLXZH,CSLXZH,KMH
           from DDKJTDJB "


echo 获取核心系统翻牌之前的日期
_RQ=`$HOME/sjpt/bin/get_core_ywdate.sh`


# 登陆数据平台服务器, 获取企业征信当前数据日期(为了最有效率的从 核心历史交易明细中卸数)
ftp -n -v <<!
open `sed -n '1'p $HOME/sjpt/bin/ftp.ini`
user `sed -n '2'p $HOME/sjpt/bin/ftp.ini`
bin
cd ../QYZX
get YWDATE.log
bye
!
_rest=$?
if [ $_rest -ne 0 ]; then
    echo 传输文本发生错误, 返回码: $_rest
    exit 9
fi


# 企业征信前台系统 当前数据日期
cur_ywdate=`cat YWDATE.log`
# 备份
# echo $cur_ywdate > YWDATE.log.del
cur_length=`expr length "${cur_ywdate}"`
if [ ${cur_length} -lt 8 ]; then 
    cur_year=2010
    cur_month=01
    cur_day=01
else 
    cur_year=`expr substr "${cur_ywdate}" 1 4`
    cur_month=`expr substr "${cur_ywdate}" 5 2`
    cur_day=`expr substr "${cur_ywdate}" 7 2`
fi
cur_ywdate="${cur_year}/${cur_month}/${cur_day}"


# 把 日期格式yyyy/dd/mm 转成 int型
exec_sql1 "unload to YWDATE.tmp delimiter ',' select first 1 cast(date('${cur_ywdate}') as int)  from sys "
inc_ywdate=`cat YWDATE.tmp | sed "s/\,//g"`
rm -f YWDATE.tmp


# exec_sql "unload to count.del delimiter ',' select count(hszh) from flsmxz2010 "


# 写一个空文件, 接口程序将用这个文件清空表 S_CORE_FLSMXZ
echo "" > S_CORE_QYZX_FLSMXZ.del


echo 抽取 easyhis库中的 ${cur_year}年的历史交易明细, 增量日期: ${cur_ywdate}, 转成int: ${inc_ywdate}
exec_sql "unload to S_CORE_QYZX_FLSMXZ${cur_year}.del delimiter ',' select kmh,dfkmh,hbh,khdh,
          zzh,zhkh,xh,hszh,dljg,jgm,xtrq,to_char(decode(jyrq,0,null,date(jyrq)),'%Y-%m-%d'),zxlsh,
          gylsh,jym,jyje,ye,js,pzbz,tdbz,zy,sqm,pzzl,pzhm,jdbz,pj,
          gy1,gy2,dyzzh,dyzhkh,dyxh,dfhszh,jysj,cngy,bz 
          from flsmxz${cur_year} 
          where hszh LIKE 'HT%' 
            and jyrq > ${inc_ywdate}  
            and jdbz = '2' "


# 设置最小年份
_LF=$cur_year

# 设置最大年份
#_NF=`date +%Y`
_NF=`expr substr $_RQ 1 4`

# 防止死循环
_bk=1

cur_year=`expr $cur_year + 1`
while [ $_bk -lt 100 -a $cur_year -gt $_LF -a $cur_year -le $_NF ]; do
    
    echo 抽取 easyhis库中的 ${cur_year}年的历史交易明细
    
    exec_sql "unload to S_CORE_QYZX_FLSMXZ${cur_year}.del delimiter ',' select kmh,dfkmh,hbh,khdh,
          zzh,zhkh,xh,hszh,dljg,jgm,xtrq,to_char(decode(jyrq,0,null,date(jyrq)),'%Y-%m-%d'),zxlsh,
          gylsh,jym,jyje,ye,js,pzbz,tdbz,zy,sqm,pzzl,pzhm,jdbz,pj,
          gy1,gy2,dyzzh,dyzhkh,dyxh,dfhszh,jysj,cngy,bz 
          from flsmxz${cur_year} 
          where hszh LIKE 'HT%' 
            and jdbz = '2' "
    
    _bk=`expr $_bk + 1`
    cur_year=`expr $cur_year + 1`
    #((_bk=_bk+1))
    #((cur_year=cur_year+1))
done


echo 卸数完毕, 当前时间: `date +%Y-%m-%d_%T` 
echo 当前参数: cur_ywdate=${cur_ywdate} _LF=${_LF} _NF=${_NF}  
echo "  "


