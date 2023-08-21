#!/bin/sh
# 功    能：加载核心数据文本
# 开 发 人：吕钊军
# 开发时间：2011-03-18
# 所属公司：北京宇信易诚科技有限公司


func_usage()
{
    echo "  aml_load_easycore.sh -p 文本所在目录            "
    echo "  退出状态:                                   "
    echo "      =0 执行成功                             "
    echo "      >0 发生错误!                            "
    exit 99
}

func_excsql() 
{
echo "执行命令: $2"
dbaccess $1 << !
$2;
!
if [ $? -ne 0 ]; then
    echo "连接数据 $1, 执行SQL: $2 发生错误!"
    exit 1
fi
}


# 判断环境变量是否存在
if [ "$RPT_HOME" == "" ]; then 
# 根目录
export RPT_HOME=$HOME/rptsys
# 可执行程序目录
export RPT_BIN=$RPT_HOME/bin
# 文本存放目录
export RPT_FILE=$RPT_HOME/file
# 源程序存放目录
export RPT_SRC=$RPT_HOME/src
# 临时文件存放目录
export RPT_TEMP=$RPT_HOME/temp
# 日志存放目录
export RPT_LOGS=$RPT_HOME/logs
# 配置文件存放目录
export RPT_CONF=$RPT_HOME/conf
# jar包目录
export RPT_LIB=$RPT_HOME/lib
# java class文件存放目录
export RPT_CLASSES=$RPT_HOME/classes
fi


# 循环读取参数
while getopts "p:" name;
do
case $name in
p)  
    loadfilepath=$OPTARG
    ;;
?)  
    func_usage 
esac
done

if [ "$loadfilepath" == "" ]; then
    func_usage
fi

# 判断文本所在目录是否存在
if [ ! -d $loadfilepath ]; then
    func_usage
fi


# 获取反洗钱数据库的账户信息
idsCfg=`sh $RPT_BIN/getIDScfg.sh -n report`
if [ $? -ne 0 ]; then
    echo 获取反洗钱数据库账户信息错误!
    exit 2
fi


echo " "
echo " "
echo "========== 开始加载核心文本数据" `date +%Y-%m-%d_%T` 

# 删表
dbaccess ${idsCfg} << !
drop table s_core_llszhls                ;
drop table s_core_kzrlsb                 ;
drop table s_core_dyjhkdjb               ;
drop table s_core_bzfbwlsb               ;
drop table s_core_zfxt_zb                ;
drop table s_core_sys                    ;
drop table s_core_sxxbm                  ;
drop table s_core_skmzd                  ;
drop table s_core_pricustinf             ;
drop table s_core_organinfo              ;
drop table s_core_llstctrls              ;
drop table s_core_fzrmx                  ;
drop table s_core_fhqfh                  ;
drop table s_core_ffhz                   ;
drop table s_core_entcustinf             ;
drop table s_core_dysjzdjb               ;
drop table s_core_dyhhpdjb               ;
drop table s_core_dyhbpdjb               ;
drop table s_core_dwlls                  ;
drop table s_core_dhpqfdjb               ;
drop table s_core_custinfo               ;
drop table s_core_ddljyxxdjb             ;
drop table s_core_sjymb                  ;

drop table aml_itf_acct_m                ;
drop table aml_itf_cstm_m                ;
drop table aml_itf_trans_m               ;
drop table aml_itf_acct_dyn              ;
drop table aml_itf_acct_m_tmp            ;
drop table aml_itf_trans_dyn             ;
!


# 建表
dbaccess ${idsCfg} << !
/**
 * 交易代码标
 */
CREATE TABLE s_core_sjymb ( 
    wbjym INTEGER NOT NULL, 
    jym INTEGER NOT NULL, 
    jymc CHAR(20) NOT NULL, 
    jymjb INTEGER NOT NULL, 
    jyzb INTEGER NOT NULL, 
    lb INTEGER NOT NULL, 
    sqgylx INTEGER NOT NULL, 
    yxgyzl CHAR(20) NOT NULL, 
    zy CHAR(4) NOT NULL, 
    kzz CHAR(3) NOT NULL, 
    jymxz INTEGER NOT NULL, 
    fjym CHAR(100) NOT NULL, 
    jykz CHAR(20) NOT NULL 
) in repdatadbs;
    
/**
 * @brief 030220 代理交易信息登记簿
 *
 * <pre>
 * －Indexes
 *   . ix_dljyxxdjb (Unique) : jyrq, jygy, gylsh
 * </pre>
 */
CREATE TABLE s_core_ddljyxxdjb ( 
    jyrq INTEGER NOT NULL, 
    jym INTEGER NOT NULL, 
    jygy CHAR(8) NOT NULL, 
    gylsh INTEGER NOT NULL, 
    dlrmc CHAR(40) NOT NULL, 
    dlrzjzl INTEGER NOT NULL, 
    dlrzjhm CHAR(20) NOT NULL 
)in repdatadbs;

/**
 * @brief 160401汇票签发登记簿
 *
 * <pre>
 * －Indexes
 *   . ix_hpqfdjb (Unique) : hphm
 *   . ix_hpqfdjb2 : cprq, hbh, cpje
 * </pre>
 */
CREATE TABLE s_core_dhpqfdjb ( 
    jgm CHAR(4) NOT NULL, 
    sqshm CHAR(16) NOT NULL, 
    zt CHAR(1) NOT NULL, 
    sqrkhh CHAR(1) NOT NULL, 
    zjly CHAR(1) NOT NULL, 
    sqrzh CHAR(32), 
    sqrmc CHAR(60) NOT NULL, 
    sqrdz CHAR(60) NOT NULL, 
    fqhhh CHAR(12) NOT NULL, 
    qfhhh CHAR(12) NOT NULL, 
    hplb CHAR(1) NOT NULL, 
    cprq INTEGER NOT NULL, 
    hbh INTEGER NOT NULL, 
    cpje DECIMAL(16,2) NOT NULL, 
    hphm CHAR(8) NOT NULL, 
    hpmy CHAR(10) NOT NULL, 
    xjhpdfh CHAR(12) NOT NULL, 
    hpskrmc CHAR(60) NOT NULL, 
    fy CHAR(60) NOT NULL, 
    qfbz CHAR(1) NOT NULL, 
    dycs INTEGER NOT NULL, 
    wzlsh INTEGER NOT NULL, 
    fbrq INTEGER NOT NULL, 
    dysqgy CHAR(8) NOT NULL, 
    qfgyh CHAR(8) NOT NULL, 
    fhgyh CHAR(8) NOT NULL, 
    fhgylsh INTEGER NOT NULL, 
    fsczgy CHAR(8) NOT NULL, 
    dfbz CHAR(1) NOT NULL, 
    sbrq INTEGER NOT NULL, 
    tsfkrq INTEGER NOT NULL, 
    sjjsje DECIMAL(16,2) NOT NULL, 
    dykje DECIMAL(16,2) NOT NULL, 
    dffqhhh CHAR(12) NOT NULL, 
    zhcprkhhh CHAR(12) NOT NULL, 
    zhcprzh CHAR(32), 
    zhcprmc CHAR(60) NOT NULL, 
    lbzfjyxh CHAR(8) NOT NULL, 
    lzlsh INTEGER NOT NULL, 
    gsrq INTEGER NOT NULL, 
    gsgyh CHAR(8) NOT NULL, 
    gssqsbh CHAR(8) NOT NULL, 
    jgrq INTEGER NOT NULL, 
    jggyh CHAR(8) NOT NULL, 
    yjhkdjh CHAR(8) NOT NULL, 
    skhhh CHAR(12) NOT NULL, 
    skrzh CHAR(32), 
    skhmc CHAR(60) NOT NULL, 
    thzfxh CHAR(8) NOT NULL, 
    thczy CHAR(8) NOT NULL, 
    thlrrq INTEGER NOT NULL, 
    yjclbz CHAR(1) NOT NULL 
) in repdatadbs;

/**
 * @brief 110306约时进账登记簿
 *
 * <pre>
 * －Indexes
 *   . ind_ysjz1 (Unique) : djh
 * </pre>
 */
CREATE TABLE s_core_dysjzdjb ( 
    djh INTEGER NOT NULL, 
    hbh INTEGER NOT NULL, 
    rzzh CHAR(16), 
    rzxh INTEGER, 
    rzhm CHAR(60), 
    fkrzh CHAR(36) NOT NULL, 
    fkrmc CHAR(60) NOT NULL, 
    skrzh CHAR(36) NOT NULL, 
    skrmc CHAR(60) NOT NULL, 
    je DECIMAL(16,2) NOT NULL, 
    pjlx INTEGER NOT NULL, 
    pjhm CHAR(20) NOT NULL, 
    cphh CHAR(12) NOT NULL, 
    cphm CHAR(60) NOT NULL, 
    djrq INTEGER NOT NULL, 
    jfrq INTEGER NOT NULL, 
    djgy CHAR(8) NOT NULL, 
    djlsh INTEGER NOT NULL, 
    djjg CHAR(4) NOT NULL, 
    jfgy CHAR(8), 
    jflsh INTEGER, 
    jfjg CHAR(4) NOT NULL, 
    zt INTEGER NOT NULL 
) in repdatadbs;


/**
 * @brief 110303银行本票登记簿
 *
 * <pre>
 * －Indexes
 *   . ind_yhbpdjb1 : bphm, qfrq
 *   . ind_yhbpdjb2 : qfrq, hbh, je
 *   . ind_yhbpdjb3 : bphm, zt
 * </pre>
 */
CREATE TABLE s_core_dyhbpdjb ( 
    bphm CHAR(20) NOT NULL, 
    qfrq INTEGER NOT NULL, 
    hbh INTEGER NOT NULL, 
    je DECIMAL(16,2) NOT NULL, 
    cphhh CHAR(12) NOT NULL, 
    cphhm CHAR(60) NOT NULL, 
    fkrzh CHAR(36), 
    fkrmc CHAR(60) NOT NULL, 
    qfkhlx INTEGER NOT NULL, 
    dffs INTEGER NOT NULL, 
    dfhhh CHAR(12) NOT NULL, 
    dfhhm CHAR(60) NOT NULL, 
    skrzh CHAR(36), 
    skrmc CHAR(60) NOT NULL, 
    skkhlx INTEGER NOT NULL, 
    my CHAR(10) NOT NULL, 
    yt CHAR(20) NOT NULL, 
    bz CHAR(60) NOT NULL, 
    zt INTEGER NOT NULL, 
    dfrq INTEGER NOT NULL, 
    jgm CHAR(4) NOT NULL, 
    czgy CHAR(8) NOT NULL, 
    fhgy CHAR(8) NOT NULL, 
    jqtphh CHAR(12) NOT NULL, 
    jqtphm CHAR(60) NOT NULL, 
    jqtprq INTEGER NOT NULL, 
    jqtpgy CHAR(8) NOT NULL, 
    sqgy CHAR(8) NOT NULL 
)in repdatadbs ;


/**
 * @brief 110102历史转汇流水表
 *
 * <pre>
 * －Indexes
 *   . ix_lszhls (Unique) : jyrq, gylsh, gy1
 *   . ix_lszhls2 (Unique) : zhdjh, jyrq
 *   . ix_lszhls3 : tqrq
 * </pre>
 */

CREATE TABLE s_core_llszhls ( 
    jym INTEGER NOT NULL, 
    jgm CHAR(4) NOT NULL, 
    zhdjh INTEGER NOT NULL, 
    gylsh INTEGER NOT NULL, 
    hbh INTEGER NOT NULL, 
    jzzhkh CHAR(20) NOT NULL, 
    jzzhxh INTEGER, 
    jzkhlx INTEGER NOT NULL, 
    fkzh CHAR(36), 
    fkzhm CHAR(60) NOT NULL, 
    fkkhlx INTEGER NOT NULL, 
    skzh CHAR(36), 
    skzhm CHAR(60) NOT NULL, 
    skkhlx INTEGER NOT NULL, 
    dfhh CHAR(12), 
    dfhm CHAR(60) NOT NULL, 
    jyrq INTEGER NOT NULL, 
    fse DECIMAL(16,2) NOT NULL, 
    zy INTEGER, 
    pzzl INTEGER NOT NULL, 
    pzhm CHAR(20) NOT NULL, 
    hkyt CHAR(30) NOT NULL, 
    pjzl INTEGER NOT NULL, 
    pjhm CHAR(20) NOT NULL, 
    pjrq INTEGER NOT NULL, 
    zt CHAR(1) NOT NULL, 
    fhbz CHAR(1) NOT NULL, 
    gy1 CHAR(8) NOT NULL, 
    gy2 CHAR(8) NOT NULL, 
    tqgy CHAR(8) NOT NULL, 
    tqlsh INTEGER NOT NULL, 
    tqrq INTEGER NOT NULL, 
    dycs INTEGER NOT NULL, 
    zhbz CHAR(8) NOT NULL, 
    zrjg CHAR(4) NOT NULL, 
    pc INTEGER NOT NULL 
)in repdatadbs ;


/**
 * @brief 110301银行汇票登记簿
 *
 * <pre>
 * －Indexes
 *   . ix_yhhpdjb2 : qfrq, hbh, je
 *   . ind_yhhpdjb1 (Unique) : hphm, hplx
 * </pre>
 */
CREATE TABLE s_core_dyhhpdjb ( 
    hphm CHAR(20) NOT NULL, 
    qfrq INTEGER NOT NULL, 
    hplx INTEGER NOT NULL, 
    hbh INTEGER NOT NULL, 
    je DECIMAL(16,2) NOT NULL, 
    cphhh CHAR(12) NOT NULL, 
    cphhm CHAR(60) NOT NULL, 
    fkrzh CHAR(36), 
    fkrmc CHAR(60) NOT NULL, 
    fkkhlx INTEGER NOT NULL, 
    dffs INTEGER NOT NULL, 
    dlfkhhh CHAR(12) NOT NULL, 
    dlfkhhm CHAR(60) NOT NULL, 
    skrzh CHAR(36), 
    skrmc CHAR(60) NOT NULL, 
    skkhlx INTEGER NOT NULL, 
    my CHAR(10) NOT NULL, 
    yt CHAR(20) NOT NULL, 
    bz CHAR(60) NOT NULL, 
    zt INTEGER NOT NULL, 
    dfrq INTEGER NOT NULL, 
    dfje DECIMAL(16,2) NOT NULL, 
    jyje DECIMAL(16,2) NOT NULL, 
    jgm CHAR(4) NOT NULL, 
    czgy CHAR(8) NOT NULL, 
    fhgy CHAR(8) NOT NULL, 
    sqgy CHAR(8) NOT NULL, 
    jqtpgy CHAR(8) NOT NULL, 
    jqtprq INTEGER NOT NULL, 
    jqtphm CHAR(60) NOT NULL, 
    jqtphh CHAR(12) NOT NULL 
) in repdatadbs ;

/**
 * @brief 150103 卡昨日流水表
 *
 * <pre>
 * 卡交易昨日流水信息
 * 
 * －Indexes
 *   . ix_kzrlsb : ykh
 *   . ix_kzrlsb1 : zdjyrq, sdhhh, zdh, zdlsh
 *   . ix_kzrlsb2 : yyrq, gyh, gylsh
 *   . ix_kzrlsb3 : hbh, jyje, jym
 * </pre>
 */
CREATE TABLE s_core_kzrlsb ( 
    jylx INTEGER NOT NULL, 
    jym INTEGER NOT NULL, 
    czbz CHAR(1) NOT NULL, 
    dljg CHAR(4) NOT NULL, 
    jgm CHAR(4) NOT NULL, 
    fkhhh CHAR(12) NOT NULL, 
    sdhhh CHAR(12) NOT NULL, 
    ykh CHAR(19) NOT NULL, 
    ykzzh CHAR(16) NOT NULL, 
    yzhxh INTEGER NOT NULL, 
    hm CHAR(60) NOT NULL, 
    cdxx2 CHAR(40) NOT NULL, 
    cdxx3 CHAR(107) NOT NULL, 
    zrkh CHAR(19) NOT NULL, 
    zrzzh CHAR(16) NOT NULL, 
    zrzhxh INTEGER NOT NULL, 
    hbh INTEGER NOT NULL, 
    jyje DECIMAL(16,2) NOT NULL, 
    zdlx CHAR(1) NOT NULL, 
    zdh CHAR(8) NOT NULL, 
    zdjyrq INTEGER NOT NULL, 
    zdjysj CHAR(6) NOT NULL, 
    zdlsh INTEGER NOT NULL, 
    yzdlsh INTEGER NOT NULL, 
    shlx CHAR(4), 
    shh CHAR(15) NOT NULL, 
    shmc CHAR(60) NOT NULL, 
    sxf DECIMAL(16,2) NOT NULL, 
    yhsxf DECIMAL(16,2) NOT NULL, 
    bhzdbz CHAR(1) NOT NULL, 
    bhkbz CHAR(1) NOT NULL, 
    khbz CHAR(1) NOT NULL, 
    qsrq INTEGER NOT NULL, 
    sqm CHAR(6) NOT NULL, 
    yyrq INTEGER NOT NULL, 
    jzsj CHAR(6) NOT NULL, 
    gyh CHAR(8) NOT NULL, 
    gylsh INTEGER NOT NULL, 
    jyzt CHAR(1) NOT NULL, 
    qzlsh INTEGER DEFAULT 0 
) in repdatadbs ;

/**
 * @brief 110305应解汇款登记簿
 *
 * <pre>
 * －Indexes
 *   . ix_yjhkdjb : pzzl, pzhm
 * </pre>
 */
CREATE TABLE s_core_dyjhkdjb ( 
    djh INTEGER NOT NULL, 
    jgm CHAR(4) NOT NULL, 
    hbh INTEGER NOT NULL, 
    jfjg CHAR(4) NOT NULL, 
    zczh CHAR(36) NOT NULL, 
    zchm CHAR(60) NOT NULL, 
    pzzl INTEGER NOT NULL, 
    pzhm CHAR(20) NOT NULL, 
    je DECIMAL(16,2) NOT NULL, 
    rq INTEGER NOT NULL, 
    jfrq INTEGER NOT NULL, 
    gy CHAR(8) NOT NULL, 
    jfgy CHAR(8) NOT NULL, 
    gylsh INTEGER NOT NULL, 
    jfgylsh INTEGER NOT NULL, 
    fkrzh CHAR(36) NOT NULL, 
    fkrmc CHAR(60) NOT NULL, 
    skrzh CHAR(36) NOT NULL, 
    skrmc CHAR(60) NOT NULL, 
    hchhh CHAR(20) NOT NULL, 
    hchhm CHAR(60) NOT NULL, 
    zt CHAR(1) NOT NULL, 
    bz CHAR(60) NOT NULL 
)in repdatadbs ;


/**
 * @brief 小额支付报文流水表
 *
 * <pre>
 * －Indexes
 *   . zfbwlsb_idx1 (Unique) : lsh, jyrq
 *   . zfbwlsb_idx2 : bwtrq, bfqqshhh, blxh, bxh
 *   . zfbwlsb_idx3 : wtrq, fqhhh, zfjyxh, ywysjh, ywlxh
 *   . zfbwlsb_idx4 : wlbz, bxh
 *   . zfbwls_ix5 : yblxh, ybfqqshhh, ybwtrq, yzfjyxh
 * </pre>
 */
CREATE TABLE s_core_bzfbwlsb ( 
    lsh INTEGER, 
    ylsh INTEGER, 
    blsh INTEGER, 
    jgm CHAR(4) NOT NULL, 
    dljgm CHAR(4) NOT NULL, 
    jyrq INTEGER NOT NULL, 
    fssj CHAR(6), 
    wlbz CHAR(1), 
    ssplbz CHAR(1), 
    lrgyh CHAR(8) NOT NULL, 
    lrgylsh INTEGER, 
    fhgyh CHAR(8) NOT NULL, 
    fhgylsh INTEGER, 
    fsgyh CHAR(8) NOT NULL, 
    zfrq INTEGER NOT NULL, 
    dycs INTEGER, 
    ywzt INTEGER, 
    zt INTEGER, 
    dzbz INTEGER, 
    jdbz CHAR(1), 
    yxj INTEGER, 
    bwclm CHAR(8), 
    bwckh CHAR(20), 
    yxsj CHAR(4), 
    tjsj CHAR(6), 
    hydm CHAR(8), 
    hyxx CHAR(80), 
    hysj CHAR(6), 
    bdqsczt INTEGER, 
    hszh CHAR(32), 
    blxh CHAR(3), 
    bfqqshhh CHAR(12) NOT NULL, 
    bjsqshhh CHAR(12) NOT NULL, 
    bwtrq INTEGER NOT NULL, 
    yblxh CHAR(3), 
    ybfqqshhh CHAR(12) NOT NULL, 
    ybjsqshhh CHAR(12) NOT NULL, 
    ybwtrq INTEGER NOT NULL, 
    hzqx INTEGER NOT NULL, 
    bywhzzt INTEGER, 
    bxh INTEGER, 
    ybxh INTEGER, 
    bmy CHAR(40), 
    mxywzbs INTEGER, 
    mxywzje DECIMAL(16,2) NOT NULL, 
    mxywcgbs INTEGER, 
    mxywcgje DECIMAL(16,2) NOT NULL, 
    bfqjdh CHAR(12), 
    bjsjdh CHAR(12), 
    gcjdlx INTEGER, 
    xnffbz CHAR(1), 
    mxxxsm INTEGER, 
    gcrq INTEGER NOT NULL, 
    gccc INTEGER, 
    bfbz INTEGER, 
    qsrq INTEGER NOT NULL, 
    bclzt INTEGER, 
    bfjsj CHAR(128), 
    ywysjh CHAR(3), 
    ywlxh CHAR(5), 
    ywxh CHAR(8), 
    fqhhh CHAR(12) NOT NULL, 
    jshhh CHAR(12) NOT NULL, 
    wtrq INTEGER NOT NULL, 
    zfjyxh CHAR(8), 
    yywlxh CHAR(5), 
    yfqhhh CHAR(12) NOT NULL, 
    yjshhh CHAR(12) NOT NULL, 
    ywtrq INTEGER NOT NULL, 
    yzfjyxh CHAR(8), 
    je DECIMAL(16,2) NOT NULL, 
    fkrkhhhh CHAR(12) NOT NULL, 
    fkrzh CHAR(32), 
    fkrmc CHAR(60), 
    fkrdz CHAR(60), 
    skrkhhhh CHAR(12) NOT NULL, 
    skrzh CHAR(32), 
    skrmc CHAR(60), 
    skrdz CHAR(60), 
    ywzl CHAR(12), 
    thyy CHAR(2), 
    fy CHAR(60), 
    ywhzzt INTEGER, 
    hth CHAR(60), 
    sfkrsm INTEGER, 
    kkrq INTEGER NOT NULL, 
    kfhsxf DECIMAL(16,2) NOT NULL, 
    fjsjcd INTEGER, 
    fjsj CHAR(255), 
    dfxyh CHAR(60), 
    s_demo1 CHAR(60), 
    s_demo2 CHAR(60), 
    s_demo3 CHAR(60), 
    s_demo4 CHAR(60), 
    s_demo5 CHAR(60), 
    l_demo6 INTEGER, 
    l_demo7 INTEGER, 
    d_demo8 DECIMAL(16,2) NOT NULL, 
    d_demo9 DECIMAL(16,2) NOT NULL 
) in repdatadbs;


/**
 * @brief 020115信息编码表
 *
 * <pre>
 * 用来存储系统的一些标准信息，如摘要、凭证种类等
 * 
 * －Indexes
 *   . ix_xxbm (Unique) : zlbz, bh
 * </pre>
 */
CREATE TABLE s_core_sxxbm ( 
    zlbz CHAR(1) NOT NULL, 
    bh INTEGER NOT NULL, 
    mc CHAR(30) NOT NULL, 
    sx CHAR(20) NOT NULL, 
    zymc CHAR(12) NOT NULL 
) in repdatadbs;


/**
 * @brief 020101科目字典
 *
 * <pre>
 * －Indexes
 *   . ix_kmzd (Unique) : kmh
 *   . ix_kmzd1 (Unique) : kmxh
 * </pre>
 */    
CREATE TABLE s_core_skmzd ( 
    kmxh INTEGER NOT NULL, 
    kmh CHAR(10) NOT NULL, 
    kmm CHAR(30) NOT NULL, 
    zl CHAR(1) NOT NULL, 
    yef CHAR(1) NOT NULL, 
    kmbz CHAR(20) NOT NULL, 
    dycdzh INTEGER NOT NULL, 
    cdzh INTEGER NOT NULL, 
    hzkmh CHAR(10) NOT NULL, 
    cbbz INTEGER NOT NULL 
) in repdatadbs;


-- 核心机构表
CREATE TABLE s_core_organinfo ( 
    organno CHAR(4) NOT NULL, 
    suporganno CHAR(4) NOT NULL, 
    organname CHAR(40) NOT NULL, 
    organshortform CHAR(20) NOT NULL, 
    enname CHAR(40) NOT NULL, 
    locate CHAR(100) NOT NULL, 
    orderno INTEGER NOT NULL, 
    distno INTEGER NOT NULL, 
    launchdate INTEGER NOT NULL, 
    organtype INTEGER NOT NULL, 
    organlevel INTEGER NOT NULL, 
    fincode CHAR(21) NOT NULL, 
    state INTEGER NOT NULL, 
    organchief CHAR(60) NOT NULL, 
    telnum CHAR(21) NOT NULL, 
    address CHAR(61) NOT NULL, 
    postcode CHAR(10) NOT NULL, 
    memo CHAR(60) NOT NULL, 
    pk1 CHAR(100) NOT NULL 
) in repdatadbs;

-- 核心系统表
CREATE TABLE s_core_sys ( 
    pk1 CHAR(100) NOT NULL, 
    cnname CHAR(100) NOT NULL, 
    version CHAR(100) NOT NULL, 
    sysdesc CHAR(100) NOT NULL, 
    property CHAR(100) NOT NULL, 
    openday INTEGER NOT NULL, 
    lstopenday INTEGER NOT NULL, 
    pininvalid INTEGER NOT NULL, 
    memo CHAR(100) NOT NULL, 
    flag CHAR(100) NOT NULL 
) in repdatadbs;

/**
 * @brief 020201分户账基表
 *
 * <pre>
 * －Indexes
 *   . ix_ffhz (Unique) : zh
 *   . ix_ffhz_1 : jgm
 *   . ix_ffhz_2 : khdh
 * </pre>
 */
CREATE TABLE s_core_ffhz ( 
    jgm CHAR(4) NOT NULL, 
    khdh CHAR(16) NOT NULL, 
    hbh INTEGER NOT NULL, 
    kmh CHAR(10) NOT NULL, 
    zh CHAR(16) NOT NULL, 
    hm CHAR(60) NOT NULL, 
    kzz CHAR(15) NOT NULL, 
    khrq INTEGER NOT NULL, 
    xhrq INTEGER NOT NULL, 
    yef CHAR(1) NOT NULL, 
    zrye DECIMAL(16,2) NOT NULL, 
    ye DECIMAL(16,2) NOT NULL, 
    fkyje DECIMAL(16,2) NOT NULL, 
    cbbz INTEGER NOT NULL, 
    dac CHAR(16) NOT NULL 
) in repdatadbs;


/**
 * @brief 010104客户信息基表
 *
 * <pre>
 * －Indexes
 *   . idx_cust_pk1 (Unique) : pk1
 *   . idx_cust_no (Unique) : custno, orgofcustm, custmgr
 *   . idx_cust_name : custname, orgofcustm, custmgr
 *   . idx_cust_certno : certno, certtype, orgofcustm, custmgr
 *   . idx_cust_term : custterm, openorg, orgofcustm, custmgr
 *   . idx_cust_assactor : assactor
 * </pre>
 */
CREATE TABLE s_core_custinfo ( 
    pk1 CHAR(36) NOT NULL, 
    reader VARCHAR(255) DEFAULT 'all', 
    writer VARCHAR(255) DEFAULT 'all', 
    custno CHAR(16) NOT NULL, 
    custname CHAR(60) NOT NULL, 
    custshortform CHAR(60) NOT NULL, 
    enname CHAR(60), 
    country CHAR(3), 
    relation CHAR(8), 
    certtype INTEGER NOT NULL, 
    certno CHAR(20) NOT NULL, 
    telnum CHAR(20), 
    postcode CHAR(6), 
    netaddr CHAR(40), 
    email CHAR(40), 
    faxnum CHAR(20), 
    acctopenor CHAR(60), 
    acctno CHAR(30), 
    createdate INTEGER NOT NULL, 
    openactor CHAR(8) NOT NULL, 
    openorg CHAR(4) NOT NULL, 
    assactor CHAR(8), 
    abolishdate INTEGER, 
    closeactor CHAR(8), 
    custmgr CHAR(8), 
    orgofcustm CHAR(4), 
    distno CHAR(10), 
    vocationcode CHAR(6), 
    address CHAR(60), 
    servtype CHAR(20), 
    creditlvl CHAR(3), 
    crdassdate INTEGER, 
    custtype CHAR(10), 
    clsdate INTEGER, 
    control CHAR(10) NOT NULL, 
    custterm INTEGER NOT NULL, 
    dkjsh CHAR(20), 
    regionalism CHAR(20), 
    memo CHAR(60), 
    rgje DECIMAL(16,2), 
    rgsj INTEGER, 
    sflag VARCHAR(3), 
    glbm VARCHAR(50) 
) in repdatadbs;

/**
 * @brief 020202 活期分户
 *
 * <pre>
 * 一般活期存折户/支票
 * 
 * －Indexes
 *   . ix_fhqfh (Unique) : zh
 *   . ix_fhqfh_1 : jgm
 * </pre>
 */
CREATE TABLE s_core_fhqfh ( 
    jgm CHAR(4) NOT NULL, 
    zh CHAR(16) NOT NULL, 
    zhkz CHAR(15) NOT NULL, 
    czh INTEGER NOT NULL, 
    sjyye DECIMAL(16,2) NOT NULL, 
    czye DECIMAL(16,2) NOT NULL, 
    tcje DECIMAL(16,2) NOT NULL, 
    tdxj DECIMAL(16,2) NOT NULL, 
    bsxj DECIMAL(16,2) NOT NULL, 
    tzed DECIMAL(16,2) NOT NULL, 
    nsbh CHAR(20) NOT NULL, 
    zhmm CHAR(8) NOT NULL, 
    zjlb INTEGER NOT NULL, 
    zjh CHAR(20) NOT NULL, 
    bz CHAR(60) NOT NULL, 
    jyrq INTEGER NOT NULL, 
    qxr INTEGER NOT NULL, 
    sjyrq INTEGER NOT NULL, 
    bdhrq INTEGER NOT NULL, 
    js DECIMAL(16,2) NOT NULL, 
    tzjs DECIMAL(16,2) NOT NULL, 
    ll DECIMAL(9,6) NOT NULL, 
    tzll DECIMAL(9,6) NOT NULL, 
    sjyjs DECIMAL(16,2) NOT NULL, 
    jxbh INTEGER NOT NULL, 
    czcdlx INTEGER NOT NULL, 
    czcdh CHAR(20) NOT NULL, 
    dyyh INTEGER NOT NULL, 
    dyhh INTEGER NOT NULL, 
    wdzxs INTEGER NOT NULL, 
    llfdb DECIMAL(9,6) NOT NULL, 
    cbdac CHAR(16) NOT NULL 
) in repdatadbs;


/**
 * @brief 010108单位客户信息表
 *
 * <pre>
 * －Indexes
 *   . index_dgkh (Unique) : custno
 *   . index_dgkhkh : custno, loancardid
 *   . idx_ent_licence : licence
 *   . idx_ent_organcode : organcode
 * </pre>
 */
CREATE TABLE s_core_entcustinf ( 
    custno CHAR(16) NOT NULL, 
    untcha CHAR(8), 
    loancardid CHAR(19), 
    loanadmaud CHAR(10), 
    ficpsn CHAR(20), 
    ficpsnidty CHAR(20), 
    ficpsnid CHAR(20), 
    yearsoftrade VARCHAR(10), 
    marrystatus CHAR(8), 
    edulvl CHAR(8), 
    inhaitancystatus CHAR(8), 
    ficpsnaddr VARCHAR(100), 
    spousename VARCHAR(60), 
    spouseprofes CHAR(8), 
    spouseunit VARCHAR(60), 
    spouseyealypay DECIMAL(16,2), 
    familialmainasset VARCHAR(10), 
    familialmaindebt VARCHAR(10), 
    regtype CHAR(8), 
    licence VARCHAR(30), 
    regdate INTEGER, 
    licencevaldate INTEGER, 
    licenceadm CHAR(20), 
    licencead2 CHAR(60), 
    regcurrent INTEGER, 
    regcapital DECIMAL(16,2), 
    licenseregaddr VARCHAR(80), 
    untmanagei CHAR(40), 
    taxcode CHAR(20), 
    taxorgan CHAR(30), 
    cuntaxid VARCHAR(50), 
    regtaxid VARCHAR(50), 
    fxlicenceid CHAR(20), 
    chargedepart CHAR(20), 
    ecotype CHAR(8), 
    managerange VARCHAR(255), 
    concurrentlyrange VARCHAR(255), 
    manageitem CHAR(400), 
    mainprod VARCHAR(10), 
    mainvictualer VARCHAR(10), 
    mainclient VARCHAR(10), 
    offarea DECIMAL(16,0), 
    offbelong CHAR(1), 
    totalemployee INTEGER, 
    manager CHAR(20), 
    organcode CHAR(20), 
    untcreatedate INTEGER, 
    unttype CHAR(2), 
    caltype1 CHAR(8), 
    caltype2 CHAR(8), 
    caltype3 CHAR(8), 
    caltype4 CHAR(8), 
    untsize CHAR(8), 
    organaddr CHAR(40), 
    tel CHAR(20), 
    untemail CHAR(40), 
    cwblxfs CHAR(100), 
    jckflag CHAR(1), 
    ssgsflag CHAR(1), 
    stockcode CHAR(10), 
    stocktradesite CHAR(10), 
    jtflag CHAR(1), 
    sjgsmc VARCHAR(64), 
    sjgsdkkh CHAR(19), 
    sjgsdm VARCHAR(20), 
    opnadmid CHAR(20), 
    sfdbgs VARCHAR(10), 
    licencedate INTEGER, 
    cuntaxdate INTEGER, 
    regtaxdate INTEGER, 
    orgdate INTEGER, 
    operatorlicence VARCHAR(20), 
    quallevel VARCHAR(10), 
    landplancode VARCHAR(20), 
    concode VARCHAR(20), 
    landusecode VARCHAR(20), 
    conplancode VARCHAR(20), 
    presalecode VARCHAR(20), 
    fundsour VARCHAR(100), 
    sponsor VARCHAR(100), 
    regmanorg VARCHAR(100), 
    certdate INTEGER, 
    pricecode VARCHAR(20), 
    pricecopycode VARCHAR(20), 
    pricedate INTEGER, 
    managecode VARCHAR(20), 
    acctdate INTEGER, 
    dkkzt CHAR(1), 
    acctopenor VARCHAR(60), 
    acctno VARCHAR(20), 
    managestime INTEGER, 
    manageetime INTEGER, 
    sszb DECIMAL(16,2) 
) in repdatadbs;


/**
 * @brief 010107个人客户信息表
 *
 * <pre>
 * －Indexes
 *   . index_grkh (Unique) : custno
 * </pre>
 */
CREATE TABLE s_core_pricustinf ( 
    custno CHAR(16) NOT NULL, 
    sex CHAR(1), 
    nativeplac CHAR(20), 
    nation CHAR(8), 
    birthday INTEGER, 
    organdistno CHAR(20), 
    cardorgan CHAR(60), 
    loancardid CHAR(19), 
    loanadmaud CHAR(10), 
    profession CHAR(8), 
    duty CHAR(8), 
    techtitle CHAR(8), 
    responsibility CHAR(40), 
    monthlypay DECIMAL(16,2), 
    marrystatus CHAR(8), 
    spousename CHAR(60), 
    spousecerttype INTEGER, 
    spousecertno CHAR(20), 
    spouseprofes CHAR(8), 
    spouseunit CHAR(60), 
    spousemonthlypay DECIMAL(16,2), 
    spouseotherthing CHAR(40), 
    spousetel CHAR(20), 
    familialmainasset VARCHAR(200), 
    familialmaindebt VARCHAR(200), 
    hostholdaddr CHAR(60), 
    homeaddress CHAR(60), 
    homepostcode CHAR(6), 
    hometel CHAR(30), 
    officetel CHAR(30), 
    mobiletel CHAR(20), 
    mobiletel1 CHAR(20), 
    mobiletel2 CHAR(20), 
    familymonthlypay DECIMAL(16,2), 
    graduateschool CHAR(60), 
    graduateyear INTEGER, 
    edulvl CHAR(8), 
    degree CHAR(8), 
    inhaitancystatus CHAR(8), 
    djkkh CHAR(19), 
    worktype CHAR(8), 
    unit CHAR(40), 
    untcha CHAR(8), 
    indepartment VARCHAR(60), 
    unttel CHAR(20), 
    untaddr CHAR(60), 
    untpostcod CHAR(6), 
    untcal CHAR(8), 
    untopenyea INTEGER, 
    managecha CHAR(8), 
    manageuntname CHAR(60), 
    custposition CHAR(8), 
    stockshare DECIMAL(16,2), 
    manageuntaddr CHAR(60), 
    manageuntpostcod CHAR(6), 
    manageuntcha CHAR(8), 
    manageuntsize CHAR(8), 
    partnernumber INTEGER, 
    totalemployee INTEGER, 
    practicetime INTEGER, 
    managerange VARCHAR(255), 
    concurrentlyrange VARCHAR(255), 
    mainvictualer VARCHAR(200), 
    mainclient VARCHAR(200), 
    manageuntcodecer CHAR(40), 
    licenceid CHAR(40), 
    licenceval INTEGER, 
    cuntaxid CHAR(20), 
    regtaxid CHAR(20), 
    khsflb CHAR(1), 
    regcapital DECIMAL(16,2), 
    regcurrent INTEGER, 
    dkye DECIMAL(16,2), 
    yqhkcs INTEGER, 
    brgzkhh VARCHAR(100), 
    brgzzh VARCHAR(50), 
    pogzkhh VARCHAR(100), 
    pogzzh VARCHAR(50), 
    jydwkhh VARCHAR(100), 
    jydwzh VARCHAR(50), 
    dkjshkhh VARCHAR(100), 
    dkjshzh VARCHAR(50), 
    isfarmer VARCHAR(2) 
) in repdatadbs;


/**
 * @brief 020402昨日明细表
 *
 * <pre>
 * 日切时drop昨日明细，rename 当日明细成为昨日明细，再create 当日明细
 * 
 * －Indexes
 *   . ix_fzrmx : dljg
 *   . ix_fzrmx_1 : gy1, gylsh
 *   . ix_fzrmx_2 (Unique) : zxlsh
 *   . ix_fzrmx_3 : zhkh, xh
 *   . ix_fzrmx_4 : hbh, jyje
 * </pre>
 */
CREATE TABLE s_core_fzrmx ( 
    kmh CHAR(10) NOT NULL, 
    dfkmh CHAR(10) NOT NULL, 
    hbh INTEGER NOT NULL, 
    khdh CHAR(16) NOT NULL, 
    zzh CHAR(16) NOT NULL, 
    zhkh CHAR(20) NOT NULL, 
    xh INTEGER NOT NULL, 
    hszh CHAR(16) NOT NULL, 
    dljg CHAR(4) NOT NULL, 
    jgm CHAR(4) NOT NULL, 
    xtrq INTEGER NOT NULL, 
    jyrq INTEGER NOT NULL, 
    zxlsh SERIAL NOT NULL, 
    gylsh INTEGER NOT NULL, 
    jym INTEGER NOT NULL, 
    jyje DECIMAL(16,2) NOT NULL, 
    ye DECIMAL(16,2) NOT NULL, 
    js DECIMAL(16,2) NOT NULL, 
    pzbz CHAR(1) NOT NULL, 
    tdbz CHAR(1) NOT NULL, 
    zy INTEGER NOT NULL, 
    sqm CHAR(8) NOT NULL, 
    pzzl INTEGER NOT NULL, 
    pzhm CHAR(20) NOT NULL, 
    jdbz CHAR(1) NOT NULL, 
    pj DECIMAL(16,4) NOT NULL, 
    gy1 CHAR(8) NOT NULL, 
    gy2 CHAR(8) NOT NULL, 
    dyzzh CHAR(16) NOT NULL, 
    dyzhkh CHAR(20) NOT NULL, 
    dyxh INTEGER NOT NULL, 
    dfhszh CHAR(16) NOT NULL, 
    jysj CHAR(8) NOT NULL, 
    cngy CHAR(8) NOT NULL, 
    bz CHAR(16) NOT NULL 
) in repdatadbs;


/**
 * @brief 160201现代化支付往来流水
 *
 * <pre>
 * －Indexes
 *   . ix_dwlls (Unique) : lsh
 *   . ix_dwlls2 : zfjyxh, wlbz
 *   . ix_dwlls3 : jgm, zfjyxh, wlbz, ywzt, zt
 *   . ix_dwlls4 : wtrq, fqhhh, zfjyxh
 * </pre>
 */
CREATE TABLE s_core_dwlls ( 
    lsh INTEGER NOT NULL, 
    yslsh INTEGER NOT NULL, 
    jyrq INTEGER NOT NULL, 
    fssj CHAR(6) NOT NULL, 
    bwlx CHAR(3) NOT NULL, 
    jdbz CHAR(1) NOT NULL, 
    wlbz CHAR(1) NOT NULL, 
    jgm CHAR(4) NOT NULL, 
    wtrq INTEGER NOT NULL, 
    hbh INTEGER NOT NULL, 
    je DECIMAL(16,2) NOT NULL, 
    fqqshhh CHAR(12) NOT NULL, 
    fqhhh CHAR(12) NOT NULL, 
    fkrkhhhh CHAR(12) NOT NULL, 
    fkrzh CHAR(32), 
    fkrmc CHAR(60) NOT NULL, 
    fkrdz CHAR(60) NOT NULL, 
    jsqshhh CHAR(12) NOT NULL, 
    jshhh CHAR(12) NOT NULL, 
    skrkhhhh CHAR(12) NOT NULL, 
    skrzh CHAR(32), 
    skrmc CHAR(60) NOT NULL, 
    skrdz CHAR(60) NOT NULL, 
    ywzl CHAR(2) NOT NULL, 
    zfjyxh CHAR(8) NOT NULL, 
    fbzxdm CHAR(4) NOT NULL, 
    sbzxdm CHAR(4) NOT NULL, 
    fy CHAR(60) NOT NULL, 
    bz CHAR(60) NOT NULL, 
    ywzt INTEGER NOT NULL, 
    zt INTEGER NOT NULL, 
    dycs INTEGER NOT NULL, 
    hydm CHAR(8) NOT NULL, 
    hyxx CHAR(80) NOT NULL, 
    hysj CHAR(14) NOT NULL, 
    pzzl CHAR(2) NOT NULL, 
    pzhm CHAR(20) NOT NULL, 
    pjrq INTEGER NOT NULL, 
    pjhm CHAR(20) NOT NULL, 
    pcjje DECIMAL(16,2) NOT NULL, 
    jfje DECIMAL(16,2) NOT NULL, 
    cjll DECIMAL(9,6) NOT NULL, 
    cjqx INTEGER NOT NULL, 
    bwlsh INTEGER NOT NULL, 
    rzzh CHAR(32), 
    dljgm CHAR(4) NOT NULL, 
    lrgy CHAR(8) NOT NULL, 
    fhgy CHAR(8) NOT NULL, 
    fhgylsh INTEGER NOT NULL, 
    jzgy CHAR(8) NOT NULL, 
    yxj INTEGER NOT NULL, 
    yjhkdjh CHAR(8) NOT NULL, 
    zzlx CHAR(1) NOT NULL, 
    fslsh INTEGER NOT NULL, 
    fsgy CHAR(8) NOT NULL, 
    fsgylsh INTEGER 
) in repdatadbs;

/**
 * @brief 110203历史同城提入流水表
 *
 * <pre>
 * －Indexes
 *   . ind_tctrls1 : jgm, bddjh
 *   . ind_tctrls2 : jhrq, jhcc
 *   . ind_tctrls3 : jyrq, je
 * </pre>
 */
CREATE TABLE s_core_llstctrls ( 
    jgm CHAR(4) NOT NULL, 
    bddjh INTEGER NOT NULL, 
    jhrq INTEGER NOT NULL, 
    jhcc INTEGER NOT NULL, 
    tchh CHAR(12) NOT NULL, 
    tchm CHAR(60) NOT NULL, 
    je DECIMAL(16,2) NOT NULL, 
    skrzh CHAR(36), 
    skrmc CHAR(60) NOT NULL, 
    skrlx CHAR(1) NOT NULL, 
    fkrzh CHAR(36), 
    fkrmc CHAR(60) NOT NULL, 
    fkrlx CHAR(1) NOT NULL, 
    pzlx INTEGER NOT NULL, 
    pzhm CHAR(20) NOT NULL, 
    lrgy CHAR(8) NOT NULL, 
    fhgy CHAR(8) NOT NULL, 
    jyrq INTEGER NOT NULL, 
    lrlsh INTEGER NOT NULL, 
    fhlsh INTEGER NOT NULL, 
    zt CHAR(1) NOT NULL, 
    fhbz CHAR(1) NOT NULL, 
    dycs INTEGER NOT NULL, 
    sljg CHAR(4) NOT NULL, 
    zhjg CHAR(4), 
    hkyt CHAR(30) 
) in repdatadbs;

/**
 * @brief 160103支付系统主表
 *
 * <pre>
 * －Indexes
 *   . ix_zfxtzb (Unique) : bnkcode
 * </pre>
 */
CREATE TABLE s_core_zfxt_zb ( 
    bnkcode CHAR(12) NOT NULL, 
    status CHAR(1) NOT NULL, 
    category CHAR(2) NOT NULL, 
    clscode CHAR(3) NOT NULL, 
    dreccode CHAR(12) NOT NULL, 
    nodecode CHAR(5) NOT NULL, 
    suprlist CHAR(130) NOT NULL, 
    pbccode CHAR(12) NOT NULL, 
    citycode CHAR(4) NOT NULL, 
    acctstatus CHAR(1) NOT NULL, 
    asaltdt CHAR(8) NOT NULL, 
    asalttm CHAR(14) NOT NULL, 
    lname CHAR(60) NOT NULL, 
    sname CHAR(20) NOT NULL, 
    addr CHAR(60) NOT NULL, 
    postcode CHAR(6) NOT NULL, 
    tel CHAR(30) NOT NULL, 
    email CHAR(30) NOT NULL, 
    alteffdate CHAR(9) NOT NULL, 
    invdate CHAR(9) NOT NULL, 
    altdate CHAR(19) NOT NULL, 
    alttype CHAR(1) NOT NULL, 
    altissno CHAR(8) NOT NULL, 
    bz CHAR(60) NOT NULL 
) in repdatadbs;


CREATE TABLE AML_ITF_ACCT_M  (
          ACCOUNT_ID CHAR(32) NOT NULL , 
          ACCOUNT_GROUP_ID CHAR(32) , 
          ACCOUNT_SUSPEND_CODE CHAR(2) , 
          OWNER_ORG_ID CHAR(20) , 
          ACCOUNT_ORG_ID CHAR(20) , 
          MANAGE_ORG_ID CHAR(20) , 
          ACCOUNT_OPEN_DATE DATE , 
          ACCOUNT_CLOSE_DATE DATE , 
          ACCOUNT_EXPIRE_DATE DATE , 
          PRODUCT_ID CHAR(10) , 
          PRODUCT_INNER_ID CHAR(16) , 
          CURRENCY_CODE CHAR(3) , 
          TERMS INTEGER , 
          ACCT_STATUS CHAR(2) , 
          ACCT_CATA CHAR(2) , 
          ACCT_TYPE_CODE CHAR(4) , 
          ACCOUNT_BALANCE DECIMAL(16,2) , 
          ACCOUNT_NAME VARCHAR(60) , 
          CUSTOMER_ID CHAR(20) , 
          ACCOUNT_FROZE_CODE CHAR(2) , 
          BASE_INTEREST_RATE DECIMAL(8,6) , 
          FLOAT_INTEREST_RATE DECIMAL(6,4) , 
          INTEREST_RATE_UNIT_CODE CHAR(2) , 
          INTEREST_MODE_CODE CHAR(2) , 
          UPDA_DATE DATE 
)in repdatadbs;
ALTER TABLE AML_ITF_ACCT_M ADD CONSTRAINT PRIMARY KEY (ACCOUNT_ID);
CREATE INDEX acct_custid ON AML_ITF_ACCT_M (CUSTOMER_ID) ;

CREATE TABLE AML_ITF_CSTM_M  (
          CUSTOMER_ID CHAR(20) NOT NULL , 
          BANK_ORG_ID CHAR(20) , 
          CUSTOMER_TYPE CHAR(1) , 
          CUSTOMER_NAME CHAR(60) , 
          START_DATE DATE , 
          ISSUE_DATE DATE , 
          CREDIT_RATE_CODE CHAR(2) , 
          SERVICE_CLASS_CODE CHAR(2) , 
          CRTFT_TYPE CHAR(2) , 
          CRTFT_NUMBER CHAR(20) , 
          POST_CODE CHAR(6) , 
          NATIONALITY_CODE CHAR(4) , 
          LOCATION_CODE CHAR(12) , 
          LOCATION_NAME VARCHAR(128) , 
          PHONE_NUMBER CHAR(24) , 
          CELL_PHONE CHAR(24) , 
          INDUSTRY_CODE CHAR(2) , 
          RGST_CAPITAL DECIMAL(20,2) , 
          LGMAN_NAME CHAR(20) , 
          LGMAN_CRTF_TYPE CHAR(2) , 
          LGMAN_CRTF_NUM CHAR(20) , 
          UPDA_DATE DATE , 
          RISKS_RATE_CODE CHAR(2) , 
          RISKS_CONTENTS CHAR(200) , 
          OPER_ID CHAR(10) , 
          OPER_NAME CHAR(20) , 
          B_FLAG CHAR(2) 
)in repdatadbs;
ALTER TABLE AML_ITF_CSTM_M ADD CONSTRAINT PRIMARY KEY (CUSTOMER_ID);


CREATE TABLE AML_ITF_TRANS_M  (
          RECORD_DATE CHAR(26) NOT NULL , 
          TRANSACTION_ID CHAR(20) NOT NULL , 
          TRAN_SERIAL_ID INTEGER NOT NULL , 
          BANK_ORG_ID CHAR(12) , 
          TRANS_TYPE_CODE CHAR(10) , 
          ACCOUNT_ID CHAR(32) , 
          ACCOUNT_NAME CHAR(64) , 
          OWNER_ORG_ID CHAR(12) , 
          MANAGE_ORG_ID CHAR(12) , 
          CURRENCY_CODE CHAR(3) , 
          PRODUCT_ID CHAR(10) , 
          OTHER_ACCOUNT_ID CHAR(32) , 
          OTHER_ACCT_ATTRIB CHAR(4) , 
          OTHER_NAME CHAR(64) , 
          OTHER_CUSTOMER_ID CHAR(20) , 
          OTHER_CRTF_TYPE CHAR(2) , 
          OTHER_CRTF_NUMBER CHAR(20) , 
          OTHER_CURRENCY_CODE CHAR(3) , 
          OTHER_PRODUCT_ID CHAR(10) , 
          OTHER_BANK_ID CHAR(12) , 
          OTHER_BRANCH_NAME CHAR(64) , 
          DOCUMENT_TYPE_CODE CHAR(5) , 
          DOCUMENT_NUMBER CHAR(20) , 
          TRANS_BRIEF_CODE CHAR(10) , 
          TRANS_BRIEF_DESC VARCHAR(128) , 
          TRANS_CHARA_CODE CHAR(2) , 
          CREDIT_DEBIT_CODE CHAR(2) , 
          CREDIT_AMT DECIMAL(16,2) , 
          DEBIT_AMT DECIMAL(16,2) , 
          TRANS_BALANCE DECIMAL(16,2) , 
          TRANS_BANK_CHARGE DECIMAL(16,2) , 
          CHANNEL_ID CHAR(20) , 
          AGENT_ID CHAR(20) , 
          AGENT_NAME CHAR(20) , 
          AGENT_CRTFT_TYPE CHAR(2) , 
          AGENT_CRTFT_NUM CHAR(20) , 
          AGENT_NATION CHAR(4) , 
          FUND_PURPOSE CHAR(128) , 
          TRANS_PROP CHAR(8) 
) in repdatadbs;
ALTER TABLE AML_ITF_TRANS_M ADD  CONSTRAINT PRIMARY KEY (RECORD_DATE, TRANSACTION_ID,TRAN_SERIAL_ID);


-- 创建临时表（用于更新流水表中的对手账户信息）
CREATE TABLE aml_itf_acct_m_tmp( 
        account_id CHAR(32) NOT NULL, 
        account_group_id CHAR(32), 
        acct_type_code CHAR(4),
        customer_id CHAR(20),
        currency_code CHAR(3),
        product_id CHAR(10),
        owner_org_id CHAR(20), 
        bank_org_name VARCHAR(60)
)in repdatadbs;
create INDEX acct_m_tmp_accid on aml_itf_acct_m_tmp (account_id);


CREATE TABLE AML_ITF_ACCT_DYN  (
    ACCOUNT_ID CHAR(32) NOT NULL 
) in repdatadbs;
ALTER TABLE AML_ITF_ACCT_DYN ADD CONSTRAINT PRIMARY KEY (ACCOUNT_ID);

CREATE TABLE AML_ITF_TRANS_DYN  (
          RECORD_DATE CHAR(26) NOT NULL , 
          TRANSACTION_ID CHAR(20) NOT NULL , 
          TRAN_SERIAL_ID INTEGER NOT NULL , 
          BANK_ORG_ID CHAR(12) , 
          TRANS_TYPE_CODE CHAR(10) , 
          ACCOUNT_ID CHAR(32) , 
          ACCOUNT_NAME CHAR(64) , 
          OWNER_ORG_ID CHAR(12) , 
          MANAGE_ORG_ID CHAR(12) , 
          CURRENCY_CODE CHAR(3) , 
          PRODUCT_ID CHAR(10) , 
          OTHER_ACCOUNT_ID CHAR(32) , 
          OTHER_ACCT_ATTRIB CHAR(4) , 
          OTHER_NAME CHAR(64) , 
          OTHER_CUSTOMER_ID CHAR(20) , 
          OTHER_CRTF_TYPE CHAR(2) , 
          OTHER_CRTF_NUMBER CHAR(20) , 
          OTHER_CURRENCY_CODE CHAR(3) , 
          OTHER_PRODUCT_ID CHAR(10) , 
          OTHER_BANK_ID CHAR(12) , 
          OTHER_BRANCH_NAME CHAR(64) , 
          DOCUMENT_TYPE_CODE CHAR(5) , 
          DOCUMENT_NUMBER CHAR(20) , 
          TRANS_BRIEF_CODE CHAR(10) , 
          TRANS_BRIEF_DESC VARCHAR(128) , 
          TRANS_CHARA_CODE CHAR(2) , 
          CREDIT_DEBIT_CODE CHAR(2) , 
          CREDIT_AMT DECIMAL(16,2) , 
          DEBIT_AMT DECIMAL(16,2) , 
          TRANS_BALANCE DECIMAL(16,2) , 
          TRANS_BANK_CHARGE DECIMAL(16,2) , 
          CHANNEL_ID CHAR(20) , 
          AGENT_ID CHAR(20) , 
          AGENT_NAME CHAR(20) , 
          AGENT_CRTFT_TYPE CHAR(2) , 
          AGENT_CRTFT_NUM CHAR(20) , 
          AGENT_NATION CHAR(4) , 
          FUND_PURPOSE CHAR(128) , 
          TRANS_PROP CHAR(8) 
) in repdatadbs;
ALTER TABLE AML_ITF_TRANS_DYN ADD  CONSTRAINT PRIMARY KEY (RECORD_DATE, TRANSACTION_ID, TRAN_SERIAL_ID);

!
if [ $? -ne 0 ]; then 
    echo 创建源表发生错误
    exit 3
fi


# 先清空数据
# func_excsql "${idsCfg}" "delete from s_core_organinfo   "
# func_excsql "${idsCfg}" "delete from s_core_sys         "
# func_excsql "${idsCfg}" "delete from s_core_ffhz        "
# func_excsql "${idsCfg}" "delete from s_core_custinfo    "
# func_excsql "${idsCfg}" "delete from s_core_fhqfh       "
# func_excsql "${idsCfg}" "delete from s_core_entcustinf  "
# func_excsql "${idsCfg}" "delete from s_core_pricustinf  "
# func_excsql "${idsCfg}" "delete from s_core_fzrmx       "
# func_excsql "${idsCfg}" "delete from s_core_dwlls       "
# func_excsql "${idsCfg}" "delete from s_core_llstctrls   "
# func_excsql "${idsCfg}" "delete from s_core_sxxbm       "
# func_excsql "${idsCfg}" "delete from s_core_skmzd       "
# func_excsql "${idsCfg}" "delete from s_core_zfxt_zb     "
# func_excsql "${idsCfg}" "delete from s_core_dyhbpdjb    "
# func_excsql "${idsCfg}" "delete from s_core_dyhhpdjb    "
# func_excsql "${idsCfg}" "delete from s_core_dysjzdjb    "
# func_excsql "${idsCfg}" "delete from s_core_bzfbwlsb    "
# func_excsql "${idsCfg}" "delete from s_core_dyjhkdjb    "
# func_excsql "${idsCfg}" "delete from s_core_kzrlsb      "
# func_excsql "${idsCfg}" "delete from s_core_llszhls     "
# func_excsql "${idsCfg}" "delete from s_core_dhpqfdjb    "
# func_excsql "${idsCfg}" "delete from s_core_ddljyxxdjb  "
# func_excsql "${idsCfg}" "delete from s_core_sjymb       "

# 装载数据文本
func_excsql "${idsCfg}" "load from ${loadfilepath}/s_core_organinfo.txt  insert into s_core_organinfo   "
func_excsql "${idsCfg}" "load from ${loadfilepath}/s_core_sys.txt        insert into s_core_sys         "
func_excsql "${idsCfg}" "load from ${loadfilepath}/s_core_ffhz.txt       insert into s_core_ffhz        "
func_excsql "${idsCfg}" "load from ${loadfilepath}/s_core_custinfo.txt   insert into s_core_custinfo    "
func_excsql "${idsCfg}" "load from ${loadfilepath}/s_core_fhqfh.txt      insert into s_core_fhqfh       "
func_excsql "${idsCfg}" "load from ${loadfilepath}/s_core_entcustinf.txt insert into s_core_entcustinf  "
func_excsql "${idsCfg}" "load from ${loadfilepath}/s_core_pricustinf.txt insert into s_core_pricustinf  "
func_excsql "${idsCfg}" "load from ${loadfilepath}/s_core_fzrmx.txt      insert into s_core_fzrmx       "
func_excsql "${idsCfg}" "load from ${loadfilepath}/s_core_dwlls.txt      insert into s_core_dwlls       "
func_excsql "${idsCfg}" "load from ${loadfilepath}/s_core_llstctrls.txt  insert into s_core_llstctrls   "
func_excsql "${idsCfg}" "load from ${loadfilepath}/s_core_sxxbm.txt      insert into s_core_sxxbm       "
func_excsql "${idsCfg}" "load from ${loadfilepath}/s_core_skmzd.txt      insert into s_core_skmzd       "
func_excsql "${idsCfg}" "load from ${loadfilepath}/s_core_zfxt_zb.txt    insert into s_core_zfxt_zb     "
func_excsql "${idsCfg}" "load from ${loadfilepath}/s_core_dyhbpdjb.txt   insert into s_core_dyhbpdjb    "
func_excsql "${idsCfg}" "load from ${loadfilepath}/s_core_dyhhpdjb.txt   insert into s_core_dyhhpdjb    "
func_excsql "${idsCfg}" "load from ${loadfilepath}/s_core_dysjzdjb.txt   insert into s_core_dysjzdjb    "
func_excsql "${idsCfg}" "load from ${loadfilepath}/s_core_bzfbwlsb.txt   insert into s_core_bzfbwlsb    "
func_excsql "${idsCfg}" "load from ${loadfilepath}/s_core_dyjhkdjb.txt   insert into s_core_dyjhkdjb    "
func_excsql "${idsCfg}" "load from ${loadfilepath}/s_core_kzrlsb.txt     insert into s_core_kzrlsb      "
func_excsql "${idsCfg}" "load from ${loadfilepath}/s_core_llszhls.txt    insert into s_core_llszhls     "
func_excsql "${idsCfg}" "load from ${loadfilepath}/s_core_dhpqfdjb.txt   insert into s_core_dhpqfdjb    "
func_excsql "${idsCfg}" "load from ${loadfilepath}/s_core_ddljyxxdjb.txt insert into s_core_ddljyxxdjb  "
func_excsql "${idsCfg}" "load from ${loadfilepath}/s_core_sjymb.txt      insert into s_core_sjymb       "

# drop INDEX fzrmx_zh
# drop INDEX fzrmx_dfkmh
# drop INDEX sxxbm_id
# drop INDEX ffhz_zh
# drop INDEX ffhz_khdh

# 创建索引
func_excsql "${idsCfg}" "create INDEX fzrmx_dfkmh               on s_core_fzrmx (dfkmh)                         "
func_excsql "${idsCfg}" "create INDEX sxxbm_id                  on s_core_sxxbm (zlbz, bh)                      "
func_excsql "${idsCfg}" "create UNIQUE INDEX ffhz_zh            on s_core_ffhz (zh)                             "
func_excsql "${idsCfg}" "create INDEX ffhz_khdh                 on s_core_ffhz (khdh)                           "
func_excsql "${idsCfg}" "create INDEX CUSTINFO_id               on s_core_custinfo (custno, orgofcustm, custmgr)"
func_excsql "${idsCfg}" "create UNIQUE INDEX entcustinf_custno  on s_core_entcustinf (custno)                   "
func_excsql "${idsCfg}" "create UNIQUE INDEX bnkcode_idx        on s_core_zfxt_zb (bnkcode)                     "
func_excsql "${idsCfg}" "create INDEX fzrmx_zh                  on s_core_fzrmx (zhkh, xh)                      "
func_excsql "${idsCfg}" "create UNIQUE INDEX fhqfh_zh           on s_core_fhqfh (zh)                            "
func_excsql "${idsCfg}" "create UNIQUE INDEX pricustinf_custno  on s_core_pricustinf (custno)                   "


echo "========== 加载核心文本数据完毕!" `date +%Y-%m-%d_%T`
echo " "
echo " "

exit 0




