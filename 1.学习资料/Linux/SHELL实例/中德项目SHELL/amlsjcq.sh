#! /usr/bin/ksh

# 数据平台 采集反洗钱数据

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
echo 开始采集反洗钱业务数据, `date +%Y-%m-%d_%T` 

# 进入数据存放目录
_FILEDIR=$HOME/sjpt/data
cd $_FILEDIR
if [ $? -ne 0 ];
then
       echo "进入目录${_FILEDIR}失败!" ;
       exit -1  ;
fi


#往来流水卸数语句
exec_sql1 "unload to S_CORE_AML_DWLLS.del delimiter ',' SELECT to_char(decode(jyrq,0,null,date(jyrq)),'%Y-%m-%d'),fqhhh,fkrzh,fkrmc,jshhh,
           skrzh,skrmc,zt,fhgylsh,jzgy,fhgy,(select lname from zfxt_zb where bnkcode = a.fqhhh) fqhmc,(select lname from zfxt_zb where bnkcode = a.jshhh) jshmc,je,jgm
           FROM DWLLS a where (ywzt = 3 or ywzt = 20) and (zt = 10 or zt = 20)"

#同城提出流水卸数语句
exec_sql1 "unload to S_CORE_AML_LDRTCLS.del delimiter ',' SELECT jym,jgm,tcdjh,gylsh,hbh,fkzh,fkzhm,skzh,skzhm,trhh,trhm,tchh,
						tchm,to_char(decode(jhrq,0,null,date(jhrq)),'%Y-%m-%d'),jdbz,fse,pzzl,pzhm,to_char(decode(pzrq,0,null,date(pzrq)),'%Y-%m-%d'),jhcc,zy,zt,hzbz,stbz,
						to_char(decode(strzrq,0,null,date(strzrq)),'%Y-%m-%d'),hkyt,gy1,gy2,gy3,dycs,dyzh,zhxh,STLSH,BZ  
           FROM ldrtcls where zt = '0' "
           
#同城提入流水卸数语句
exec_sql1 "unload to S_CORE_LTCTRLS.del delimiter ',' SELECT jgm,bddjh,to_char(decode(jhrq,0,null,date(jhrq)),'%Y-%m-%d'),jhcc,tchh,tchm,je,skrzh,skrmc,skrlx,fkrzh,
						fkrmc,fkrlx,pzlx,pzhm,lrgy,fhgy,to_char(decode(jyrq,0,null,date(jyrq)),'%Y-%m-%d'),lrlsh,fhlsh,zt,fhbz,dycs,bwzl,rzlx,tply,zrhhh,zrhhm
           FROM ltctrls where zt = '0' and fhbz = '1'"
           
#建行通存通兑卸数语句
exec_sql1 "unload to S_CORE_AML_TCTD.del delimiter ',' SELECT substr(to_char(jyrq),1,4)||'-'||substr(to_char(jyrq),5,2)||'-'||substr(to_char(jyrq),7,2),
					 DJ_GYLSH,BDLF_ZHKH,BDLF_HM,DLF_ZHKH,DLF_HM,JE,BZ,CZ_GYH,SQ_GYH,BDLF_ZJLX,BDLF_ZJHM,BDLF_PZHM,YWZT,DZZT,BZXX,xz_bz
           FROM dtctdzwmx_tjccb where ywzt = 1 and dzzt = '1'"
           
exec_sql1 "unload to S_CORE_AML_FZRMX.del delimiter ',' SELECT kmh,dfkmh,hbh,khdh,zzh,
           zhkh,xh,hszh,dljg,jgm,to_char(decode(xtrq,0,null,date(xtrq)),'%Y-%m-%d'),
           to_char(decode(jyrq,0,null,date(jyrq)),'%Y-%m-%d'),zxlsh,gylsh,jym,jyje,ye,
           js,pzbz,tdbz,zy,sqm,pzzl,pzhm,jdbz,pj,gy1,gy2,dyzzh,
           dyzhkh,dyxh,dfhszh,jysj,cngy,bz,mc zjyt 
           FROM FZRMX a,sxxbm b 
           WHERE a.zy=b.bh and b.zlbz[1]='6' and (a.dfkmh <> ' ' and (a.dfkmh not like '5710%') )"
					
exec_sql1 "unload to S_CORE_AML_FFHZ.del delimiter ',' select jgm,khdh,hbh,kmh,zh,hm,kzz,to_char(decode(khrq,0,null,date(khrq)),'%Y-%m-%d'),to_char(decode(xhrq,0,null,date(xhrq)),'%Y-%m-%d'),yef,zrye,
					ye,fkyje,cbbz,dac from ffhz"

exec_sql1 "unload to S_CORE_AML_CUSTINFO.del delimiter ',' select pk1,reader,writer,custno,custname,custshortform,enname,country,relation,
					certtype,certno,telnum,postcode,netaddr,email,faxnum,acctopenor,acctno,to_char(decode(createdate,0,null,date(createdate)),'%Y-%m-%d'),openactor,openorg,assactor
					,to_char(decode(abolishdate,0,null,date(abolishdate)),'%Y-%m-%d'),closeactor,custmgr,orgofcustm,distno,vocationcode,address,servtype,creditlvl,to_char(decode(crdassdate,0,null,date(crdassdate)),'%Y-%m-%d'),
					custtype,to_char(decode(clsdate,0,null,date(clsdate)),'%Y-%m-%d'),control,custterm,dkjsh,regionalism,memo from custinfo "


exec_sql1 "unload to S_CORE_AML_PRICUSTINF.del delimiter ',' select custno,sex,nativeplac,nation,to_char(decode(birthday,0,null,date(birthday)),'%Y-%m-%d'),organdistno,cardorgan,
					loancardid,loanadmaud,profession,duty,techtitle,responsibility,monthlypay,marrystatus,spousename,spousecerttype,
					spousecertno,spouseprofes,spouseunit,spousemonthlypay,spouseotherthing,spousetel,familialmainasset,familialmaindebt,hostholdaddr,
					homeaddress,homepostcode,hometel,officetel,mobiletel,mobiletel1,mobiletel2,familymonthlypay,graduateschool,to_char(decode(graduateyear,0,null,date(graduateyear)),'%Y-%m-%d'),
					edulvl,degree,inhaitancystatus,djkkh,worktype,unit,untcha,indepartment,unttel,untaddr,untpostcod,untcal,to_char(decode(untopenyea,0,null,date(untopenyea)),'%Y-%m-%d'),
					managecha,manageuntname,custposition,stockshare,manageuntaddr,manageuntpostcod,manageuntcha,manageuntsize,partnernumber,totalemployee,
					practicetime,managerange,concurrentlyrange,mainvictualer,mainclient,manageuntcodecer,licenceid,to_char(decode(licenceval,0,null,date(licenceval)),'%Y-%m-%d'),
					cuntaxid,regtaxid,khsflb from pricustinf "


exec_sql1 "unload to S_CORE_AML_ENTCUSTINF.del delimiter ',' select custno,untcha,loancardid,loanadmaud,ficpsn,ficpsnidty,ficpsnid,yearsoftrade,marrystatus,
					edulvl,inhaitancystatus,ficpsnaddr,spousename,spouseprofes,spouseunit,spouseyealypay,familialmainasset,familialmaindebt,
					regtype,licence,to_char(decode(regdate,0,null,date(regdate)),'%Y-%m-%d'),to_char(decode(licencevaldate,0,null,date(licencevaldate)),'%Y-%m-%d'),licenceadm,licencead2,regcurrent,regcapital,licenseregaddr,
					untmanagei,taxcode,taxorgan,cuntaxid,regtaxid,fxlicenceid,chargedepart,ecotype,managerange,concurrentlyrange,manageitem,mainprod,
					mainvictualer,mainclient,offarea,offbelong,totalemployee,manager,organcode,to_char(decode(untcreatedate,0,null,date(untcreatedate)),'%Y-%m-%d'),unttype,caltype1,caltype2,
					caltype3,caltype4,untsize,organaddr,tel,untemail,cwblxfs,jckflag,ssgsflag,stockcode,stocktradesite,jtflag,sjgsmc,sjgsdkkh,sjgsdm,
					opnadmid,supopnadmid,supficpsn,supcerttype,supcertno,sjjbkhhmc from entcustinf"


# 只需执行一次 反洗钱科目字典
exec_sql1 "unload to S_CORE_SKMZD_AML.del delimiter ',' select kmh,kmm,zl FROM SKMZD WHERE (zl[1] in ( '1','2','3','4') AND length(kmh)=4) or kmh in ('1110') order by zl"



echo 卸数完毕, 当前时间: `date +%Y-%m-%d_%T` 
