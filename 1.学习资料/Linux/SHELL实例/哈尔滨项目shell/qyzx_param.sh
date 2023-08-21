#!/bin/sh

# 企业征信接口程序目录[企业征信接口程序根目录]
qyzx_dir=$HOME/shell/qyzx

# 企业征信中间表的数据文本[用来剥离增量数据]
qyzx_m_dir=${qyzx_dir}/m_file

# 企业征信O层表数据文本[可以把数据源回档到某个时点]
qyzx_o_dir=${qyzx_dir}/o_file

# 企业征信JAVA 程序目录
#qyzx_java_dir=${qyzx_dir}/java

# 企业征信日志目录
qyzx_log_dir=${qyzx_dir}/log

# 卸载中间表的日志
qyzx_m_log=${qyzx_log_dir}/qyzx_m_log.log

# 卸载数据源文本的日志
qyzx_o_log=${qyzx_log_dir}/qyzx_o_log.log

# 剥离增量配置文件
qyzx_incr_cfg=${qyzx_dir}/QYZX.cfg

# 企业征信系统日志
qyzx_log=${qyzx_dir}/sys.log

# 企业征信用到的信贷表
qyzx_crd[0]="O_LNA_CM_CSTAPPLY"
qyzx_crd[1]="O_LNA_CM_CSTBASE"
qyzx_crd[2]="O_LNA_CM_CAPITALSTR"
qyzx_crd[3]="O_LNA_CM_MEMORABILIA"
qyzx_crd[4]="O_LNA_CM_ARTIFICAL"
qyzx_crd[5]="O_LNA_CM_INCSTRU"
qyzx_crd[6]="O_LNA_CM_INVESTPOOL"
qyzx_crd[7]="O_LNA_CM_SUITINFO"
qyzx_crd[8]="O_LNA_CM_PRINNAME"

qyzx_crd[9]="O_LNA_LA_LOANCONTR"
qyzx_crd[10]="O_LNA_LA_DUEBILL"
qyzx_crd[11]="O_LNA_LA_REPAY"
qyzx_crd[12]="O_LNA_LA_EXTENDCONTR"
qyzx_crd[13]="O_LNA_LA_OWEINTEREST"

qyzx_crd[14]="O_LNA_LA_IMPORTPUR"
qyzx_crd[15]="O_LNA_LA_EXPORTPUR"
qyzx_crd[16]="O_LNA_LA_PACKLOAN"

qyzx_crd[17]="O_LNA_LA_DRAFTCONT"
qyzx_crd[18]="O_LNA_LA_DRAFTCONTR"
qyzx_crd[19]="O_LNA_LA_LGCONTR"
qyzx_crd[20]="O_LNA_AF_CREDITDETAIL"

qyzx_crd[21]="O_LNA_LA_ASSURECONTR"
qyzx_crd[22]="O_LNA_LA_ASSURECOLLATE"
qyzx_crd[23]="O_LNA_AF_CAUTIONER"
qyzx_crd[24]="O_LNA_AF_ASSUREPAWN"
qyzx_crd[25]="O_LNA_AF_RIGHTPAWN"
qyzx_crd[26]="O_LNA_AF_PAWN"
qyzx_crd[27]="O_LNA_LA_LETTERCREDIT"
qyzx_crd[28]="O_LNA_CM_CARDCHANGE"

# 数据源[从数据源中生成中间表的数据]
for i in "${!qyzx_crd[@]}"; do
  qyzx_src[$i]="${qyzx_crd[$i]}_QYZX"
done

# 数据源中文含义
qyzx_src_note[0]="客户登记表"
qyzx_src_note[1]="客户基本信息表"
qyzx_src_note[2]="企业资本结构表"
qyzx_src_note[3]="客户大事记与违规记录表"
qyzx_src_note[4]="法人代表家族成员信息"
qyzx_src_note[5]="公司结构情况表"
qyzx_src_note[6]="投资联营概况表"
qyzx_src_note[7]="借款人诉讼信息表"
qyzx_src_note[8]="主要负责人信息表"
                 
qyzx_src_note[9]="公司贷款合同表"
qyzx_src_note[10]="借据信息表"
qyzx_src_note[11]="还本还息信息表"
qyzx_src_note[12]="展期合同表"
qyzx_src_note[13]="欠息信息表"
                 
qyzx_src_note[14]="进口押汇信息表"
qyzx_src_note[15]="出口押汇信息表"
qyzx_src_note[16]="打包放款信息表"
                 
qyzx_src_note[17]="汇票表"
qyzx_src_note[18]="汇票合同表"
qyzx_src_note[19]="保函合同表"
qyzx_src_note[20]="授信额度明细表"
                 
qyzx_src_note[21]="担保合同台账"
qyzx_src_note[22]="担保合同对接表"
qyzx_src_note[23]="担保人信息表"
qyzx_src_note[24]="担保抵质押物对照表"
qyzx_src_note[25]="质押物信息表"
qyzx_src_note[26]="抵押物信息表"
qyzx_src_note[27]="信用证合同信息表"
qyzx_src_note[28]="贷款卡编码变更表"

# 存储过程
proc_id[0]="PROC_QYZX_INIT"
proc_id[1]="PROC_QYZX_LOAN_ALL"            
proc_id[2]="PROC_QYZX_ECC_LACKOFINTERESTS" 
#proc_id[3]="PROC_QYZX_FINANCE_ALL"         
proc_id[4]="PROC_QYZX_ECC_BANKACCEPTS"     
proc_id[5]="PROC_QYZX_ECC_BAOHANS"         
#proc_id[6]="PROC_QYZX_ECC_CREDITBUSINESS"  
#proc_id[18]="PROC_QYZX_ECC_OPENAWARDTRUSTS"

proc_id[7]="PROC_QYZX_ECC_BORROWERS"        
proc_id[8]="PROC_QYZX_ECC_BINVCAPITALS"     
proc_id[9]="PROC_QYZX_ECC_EVENTINFORMATION" 
proc_id[10]="PROC_QYZX_ECC_FAMILYMEMBERS"    
proc_id[11]="PROC_QYZX_ECC_FINANCECONTACTS"  
proc_id[12]="PROC_QYZX_ECC_GRPCORPS"         
proc_id[13]="PROC_QYZX_ECC_INVCAPITALS"      
#proc_id[14]="PROC_QYZX_ECC_LAWINFORMATION"   
proc_id[15]="PROC_QYZX_ECC_REGCAPITALS"      
proc_id[16]="PROC_QYZX_ECC_STOCKS"          
proc_id[17]="PROC_QYZX_ECC_SUPERMANS"

proc_id[19]="PROC_QYZX_ECC_ENSURECONTRACTS"
proc_id[20]="PROC_QYZX_ECC_IMPAWNCONTRACT"
proc_id[21]="PROC_QYZX_ECC_PLEDGECONTRACTS"
proc_id[22]="PROC_QYZX_ECC_DKMESSAGES"

proc_id[23]="PROC_QYZX_STOP"

# 存储过程含义
proc_name[0]="初始化操作"
proc_name[1]="贷款业务信"
proc_name[2]="欠息业务信息"
#proc_name[3]="贸易融资"
proc_name[4]="汇票业务信息"
proc_name[5]="保函业务信息"
#proc_name[6]="信用证信息"
#proc_name[18]="授信业务信息"

proc_name[7]="借款人概况信息"
proc_name[8]="出资资本构成情况"
proc_name[9]="大事信息"
proc_name[10]="法人代表家族企业成员情况"
proc_name[11]="财务部联系方式"
proc_name[12]="集团公司信息"
proc_name[13]="对外投资情况"
#proc_name[14]="诉讼信息"
proc_name[15]="借款人注册资本情况"
proc_name[16]="股票信息"
proc_name[17]="高级管理人情况"

proc_name[19]="保证合同信息"
proc_name[20]="质押合同信息"
proc_name[21]="抵押合同信息"
proc_name[22]="垫款信息"

proc_name[23]="存储过程执行完毕,执行的操作"

# 初始化中间表的卸数参数
function _init_ecc() {
ecc_id=( ECC_BORROWERS ECC_FINANCECONTACTS ECC_STOCKS ECC_REGCAPITALS ECC_BINVCAPITALS ECC_INVCAPITALS ECC_GRPCORPS ECC_SUPERMANS ECC_FAMILYMEMBERS ECC_BSS ECC_PROFITS ECC_CASHS ECC_LAWINFORMATION ECC_EVENTINFORMATION ECC_BILLEXPS ECC_LOANBILLS ECC_LOANCONTRACTS ECC_LOANMONEYS ECC_LOANRETURNS ECC_BAOLIS ECC_BILLDISCOUNTS ECC_FINANCEBUSINESS ECC_FINANCEEXPS ECC_FINANCEMONEYS ECC_FINANCEPROTOS ECC_FINANCERETURNS ECC_CREDITBUSINESS ECC_BAOHANS ECC_BANKACCEPTS ECC_OPENAWARDTRUSTS ECC_ENSURECONTRACTS ECC_IMPAWNCONTRACT ECC_PLEDGECONTRACTS ECC_DKMESSAGES ECC_DKRETURNS ECC_LACKOFINTERESTS)

qyzx_ecc_id[1]="QYZX_ECC_BORROWERS"
qyzx_ecc_id[2]="QYZX_ECC_FINANCECONTACTS"
qyzx_ecc_id[3]="QYZX_ECC_STOCKS"
qyzx_ecc_id[4]="QYZX_ECC_REGCAPITALS"
qyzx_ecc_id[5]="QYZX_ECC_BINVCAPITALS"
qyzx_ecc_id[6]="QYZX_ECC_INVCAPITALS"
qyzx_ecc_id[7]="QYZX_ECC_GRPCORPS"
qyzx_ecc_id[8]="QYZX_ECC_SUPERMANS"
qyzx_ecc_id[9]="QYZX_ECC_FAMILYMEMBERS"
qyzx_ecc_id[10]="QYZX_ECC_LAWINFORMATION"
qyzx_ecc_id[11]="QYZX_ECC_EVENTINFORMATION"
qyzx_ecc_id[12]="QYZX_ECC_BILLEXPS"
qyzx_ecc_id[13]="QYZX_ECC_LOANBILLS"
qyzx_ecc_id[14]="QYZX_ECC_LOANCONTRACTS"
qyzx_ecc_id[15]="QYZX_ECC_LOANMONEYS"
qyzx_ecc_id[16]="QYZX_ECC_LOANRETURNS"
qyzx_ecc_id[17]="QYZX_ECC_BAOLIS"
qyzx_ecc_id[18]="QYZX_ECC_BILLDISCOUNTS"
qyzx_ecc_id[19]="QYZX_ECC_FINANCEBUSINESS"
qyzx_ecc_id[20]="QYZX_ECC_FINANCEEXPS"
qyzx_ecc_id[21]="QYZX_ECC_FINANCEMONEYS"
qyzx_ecc_id[22]="QYZX_ECC_FINANCEPROTOS"
qyzx_ecc_id[23]="QYZX_ECC_FINANCERETURNS"
qyzx_ecc_id[24]="QYZX_ECC_CREDITBUSINESS"
qyzx_ecc_id[25]="QYZX_ECC_BAOHANS"
qyzx_ecc_id[26]="QYZX_ECC_BANKACCEPTS"
qyzx_ecc_id[27]="QYZX_ECC_OPENAWARDTRUSTS"
qyzx_ecc_id[28]="QYZX_ECC_ENSURECONTRACTS"
qyzx_ecc_id[29]="QYZX_ECC_IMPAWNCONTRACT"
qyzx_ecc_id[30]="QYZX_ECC_PLEDGECONTRACTS"
qyzx_ecc_id[31]="QYZX_ECC_DKMESSAGES"
qyzx_ecc_id[32]="QYZX_ECC_DKRETURNS"
qyzx_ecc_id[33]="QYZX_ECC_LACKOFINTERESTS"

# 中间表说明
qyzx_ecc_name[1]="借款人基本信息"
qyzx_ecc_name[2]="借款人财务部联系方式"
qyzx_ecc_name[3]="借款人股票信息"
qyzx_ecc_name[4]="借款人注册资本信息"
qyzx_ecc_name[5]="借款人出资资本构成信息"
qyzx_ecc_name[6]="借款人对外投资信息"
qyzx_ecc_name[7]="集团公司信息"
qyzx_ecc_name[8]="高级管理人信息"
qyzx_ecc_name[9]="法人代表家族企业成员信息"
qyzx_ecc_name[10]="诉讼信息"
qyzx_ecc_name[11]="其他大事信息"
qyzx_ecc_name[12]="借据展期信息"
qyzx_ecc_name[13]="借据信息"
qyzx_ecc_name[14]="贷款合同信息"
qyzx_ecc_name[15]="贷款合同金额"
qyzx_ecc_name[16]="借据还款信息"
qyzx_ecc_name[17]="保理信息"
qyzx_ecc_name[18]="贴现业务信息"
qyzx_ecc_name[19]="融资业务信息"
qyzx_ecc_name[20]="融资展期信息"
qyzx_ecc_name[21]="融资协议金额"
qyzx_ecc_name[22]="融资协议信息"
qyzx_ecc_name[23]="融资业务还款明细"
qyzx_ecc_name[24]="信用证信息"
qyzx_ecc_name[25]="保函信息"
qyzx_ecc_name[26]="银行承兑汇票信息"
qyzx_ecc_name[27]="公开授信"
qyzx_ecc_name[28]="保证合同信息"
qyzx_ecc_name[29]="质押合同信息"
qyzx_ecc_name[30]="抵押合同信息"
qyzx_ecc_name[31]="垫款信息"
qyzx_ecc_name[32]="垫款还款"
qyzx_ecc_name[33]="欠息业务"

qyzx_ecc_sql[1]="select orgcode,rtrim(card_no),rtrim(ywdate),operation_type,name_cn,name_ucn,country,certify_code,jkr_create_year,regist_type,regist_code,regist_date,licence_maturity,gsh_login_no,dsh_login_n,jkr_kind,trade_code,intrade_num,district_code,jkr_inpress,jkr_phone,jkr_regist_addr,jkr_fax,jkr_email,jkr_url,jkr_comm_addr,postcode,mainproducts,field_area,ownership,group_flag,impexp_flag,inmarket_flag,traceno,realywdate,incenter,rptdate,certify_type,orgcodechg,orgcodeold,cardnochg,card_noold,rpttype,deal_flag,check_flag,id,reserve from qyzx_ecc_borrowers order by card_no,ywdate"
qyzx_ecc_sql[2]="select rtrim(card_no),orgcode,finance_link_mode,operation_type,rtrim(ywdate),incenter,deal_flag,check_flag,realywdate,rptdate,rpttype,id,mainid,reserve from qyzx_ecc_financecontacts order by card_no,ywdate"
qyzx_ecc_sql[3]="select operation_type,rtrim(card_no),orgcode,rtrim(stock_code),market_addr,rtrim(ywdate),incenter,deal_flag,check_flag,realywdate,rptdate,rpttype,id,mainid,reserve from qyzx_ecc_stocks order by card_no, stock_code,ywdate"
qyzx_ecc_sql[4]="select orgcode,rtrim(card_no),rtrim(ywdate),operation_type,traceno,money_kind,money,rpttype,realywdate,incenter,rptdate,orgcodechg,orgcodeold,cardnochg,card_noold,deal_flag,check_flag,id,reserve from qyzx_ecc_regcapitals order by card_no,ywdate"
qyzx_ecc_sql[5]="select orgcode,rtrim(card_no),rtrim(serial_no),investor,investor_card,certifycode,certifytype,regcode,investor_orgcode,money_kind,money,operation_type,rtrim(ywdate),incenter,deal_flag,check_flag,realywdate,rptdate,rpttype,id,mainid,reserve from qyzx_ecc_binvcapitals order by card_no,serial_no,ywdate"
qyzx_ecc_sql[6]="select orgcode,rtrim(card_no),toinvest,toinvest_card,rtrim(toinvest_orgcode),money_kind,money,operation_type,moneykind3,moneykind2,money3,money2,rtrim(ywdate),regcode,certifycode,certifytype,incenter,deal_flag,check_flag,realywdate,rptdate,rpttype,id,mainid,reserve from qyzx_ecc_invcapitals order by card_no, toinvest_orgcode,ywdate"
qyzx_ecc_sql[7]="select orgcode,rtrim(card_no),super_name,super_card,super_orgcode,operation_type,rtrim(ywdate),incenter,check_flag,deal_flag,realywdate,rptdate,rpttype,id,mainid,reserve from qyzx_ecc_grpcorps order by card_no,ywdate"
qyzx_ecc_sql[8]="select orgcode,rtrim(card_no),super_name,certify_type,certify_code,super_kind,super_sex,super_birthday,super_edu,super_exp,operation_type,rtrim(ywdate),incenter,check_flag,deal_flag,realywdate,rptdate,rpttype,id,mainid,reserve from qyzx_ecc_supermans order by card_no,certify_code,ywdate"
qyzx_ecc_sql[9]="select orgcode,rtrim(card_no),membername,certify_type,rtrim(certify_code),relation,in_corp,corp_card,operation_type,rtrim(ywdate),incenter,deal_flag,check_flag,realywdate,rptdate,rpttype,id,mainid,reserve from qyzx_ecc_familymembers order by card_no, certify_code,ywdate"
qyzx_ecc_sql[10]="select orgcode,card_no,rtrim(serial_no),name,lawname,money_kind,judge_money,judge_date,result,reason,(ywdate),operation_type,traceno,rpttype,realywdate,incenter,rptdate,orgcodechg,orgcodeold,serial_nochg,serial_noold,deal_flag,check_flag,id,reserve from qyzx_ecc_lawinformation order by serial_no,ywdate"
qyzx_ecc_sql[11]="select orgcode,rtrim(card_no),name,rtrim(ywdate),operation_type,traceno,rtrim(serial_no),description,rpttype,realywdate,incenter,rptdate,orgcodechg,orgcodeold,serial_nochg,serial_noold,deal_flag,check_flag,id,reserve from qyzx_ecc_eventinformation order by card_no,serial_no,ywdate"
qyzx_ecc_sql[12]="select orgcode,card_no,rtrim(loancont_no),rtrim(bill_no),rtrim(ywdate),operation_type,exp_times,exp_money,start_date,end_date,traceno,exp_balance,rpttype,exptimeschg,exp_timesold,realywdate,incenter,rptdate,bill_id,deal_flag,check_flag,id,reserve from qyzx_ecc_billexps order by loancont_no,bill_no,exp_times,ywdate"
qyzx_ecc_sql[13]="select orgcode,card_no,rtrim(loancont_no),rtrim(bill_no),rtrim(ywdate),operation_type,money_kind,bill_money,bill_ye,create_date,maturity_date,loan_oper_kind,loan_type,loan_property,loan_where,loan_kind,exp_flag,four_class,five_class,traceno,rpttype,billnochg,bill_noold,realywdate,incenter,rptdate,contract_id,deal_flag,check_flag,id,reserve from qyzx_ecc_loanbills order by loancont_no,bill_no,ywdate"
qyzx_ecc_sql[14]="select orgcode,rtrim(loancont_no),card_no,name,rtrim(ywdate),operation_type,start_date,end_date,yintuan_flag,assure_flag,effect_flag,traceno,trust,rpttype,orgcodechg,orgcodeold,loancontnochg,loancont_noold,realywdate,incenter,rptdate,deal_flag,check_flag,id,reserve from qyzx_ecc_loancontracts order by loancont_no,ywdate"
qyzx_ecc_sql[15]="select orgcode,rtrim(loancont_no),card_no,money_kind,money,useable_money,operation_type,rtrim(ywdate),incenter,deal_flag,check_flag,realywdate,rptdate,rpttype,id,mainid,reserve from qyzx_ecc_loanmoneys order by loancont_no,ywdate"
qyzx_ecc_sql[16]="select orgcode,card_no,rtrim(loancont_no),rtrim(bill_no),rtrim(ywdate),operation_type,return_date,return_times,return_mode,return_money,traceno,rpttype,realywdate,incenter,rptdate,bill_id,deal_flag,check_flag,id,reserve from qyzx_ecc_loanreturns order by loancont_no,bill_no,return_times,ywdate"
qyzx_ecc_sql[17]="select orgcode,rtrim(loancont_no),card_no,name,rtrim(ywdate),operation_type,baoli_type,baoli_status,money_kind,money,loancont_date,loancont_balance,balance_date,assure_flag,diankuanflag,four_class,five_class,traceno,trustno,rpttype,orgcodechg,orgcodeold,loancontnochg,loancont_noold,realywdate,incenter,rptdate,deal_flag,check_flag,id,reserve from qyzx_ecc_baolis order by loancont_no,ywdate"
qyzx_ecc_sql[18]="select orgcode,rtrim(bill_no),card_no,rtrim(ywdate),operation_type,bill_kind,proposer_name,acceptor_name,acceptor_card,acceptororgcode,money_kind,discount_money,discount_date,accept_date,bill_money,bill_status,four_class,five_class,trust,traceno,rpttype,orgcodechg,orgcodeold,billnochg,bill_noold,realywdate,incenter,rptdate,deal_flag,check_flag,id,reserve from qyzx_ecc_billdiscounts order by bill_no,ywdate"
qyzx_ecc_sql[19]="select orgcode,rtrim(proto_no),card_no,rtrim(ywdate),operation_type,rtrim(yw_no),yw_kind,money_kind,finance_money,finance_balance,exp_flag,four_class,five_class,start_date,end_date,traceno,name,rpttype,realywdate,incenter,rptdate,ywnochg,ywnoold,deal_flag,check_flag,id,reserve from qyzx_ecc_financebusiness order by proto_no,ywdate,yw_no"
qyzx_ecc_sql[20]="select orgcode,rtrim(proto_no),card_no,rtrim(ywdate),operation_type,rtrim(yw_no),exp_times,exp_money,start_date,end_date,traceno,name,rpttype,realywdate,incenter,rptdate,financebusinessid,exp_timesold,exptimechg,deal_flag,check_flag,id,reserve from qyzx_ecc_financeexps order by proto_no,yw_no,exp_times,ywdate"
qyzx_ecc_sql[21]="select orgcode,rtrim(proto_no),card_no,money_kind,proto_money,proto_balance,operation_type,rtrim(ywdate),incenter,deal_flag,check_flag,realywdate,rptdate,rpttype,id,mainid,reserve from qyzx_ecc_financemoneys order by proto_no,ywdate"
qyzx_ecc_sql[22]="select orgcode,rtrim(proto_no),card_no,name,(ywdate),operation_type,start_date,end_date,assure_flag,proto_status,traceno,trustno,rpttype,orgcodechg,orgcodeold,protonochg,proto_noold,realywdate,incenter,rptdate,deal_flag,check_flag,id,reserve from qyzx_ecc_financeprotos order by proto_no,ywdate"
qyzx_ecc_sql[23]="select orgcode,rtrim(proto_no),card_no,rtrim(ywdate),operation_type,rtrim(yw_no),return_times,return_money,return_date,return_way,traceno,name,rpttype,realywdate,incenter,rptdate,financebusinessid,deal_flag,check_flag,id,reserve from qyzx_ecc_financereturns  order by proto_no,yw_no,return_times,ywdate"
qyzx_ecc_sql[24]="select orgcode,rtrim(credit_no),card_no,name,rtrim(ywdate),operation_type,money_kind,init_money,init_date,validity_period,pay_limit,deposit_scale,assure_flag,diankuanflag,credit_status,logout_date,credit_balance,balance_report_date,five_class,trust,traceno,rpttype,orgcodechg,orgcodeold,creditnochg,credit_noold,realywdate,incenter,rptdate,deal_flag,check_flag,id,reserve from qyzx_ecc_creditbusiness order by credit_no,ywdate"
qyzx_ecc_sql[25]="select orgcode,rtrim(baohan_no),card_no,name,rtrim(ywdate),operation_type,baohan_kind,baohan_status,money_kind,baohan_money,start_date,end_date,deposit_scale,assure_flag,diankuanflag,baohan_balance,balance_date,five_class,traceno,trustno,rpttype,orgcodechg,orgcodeold,baohannochg,baohan_noold,realywdate,incenter,rptdate,deal_flag,check_flag,id,reserve from qyzx_ecc_baohans order by baohan_no,ywdate"
qyzx_ecc_sql[26]="select orgcode,card_no,proto_no,rtrim(bill_no),rtrim(ywdate),operation_type,remitter_name,money_kind,bill_money,accept_date,maturity_date,pay_date,deposit_scale,assure_flag,diankuanflag,bill_status,five_class,traceno,trustno,rpttype,orgcodechg,orgcodeold,protonochg,proto_noold,billnochg,bill_noold,realywdate,incenter,rptdate,deal_flag,check_flag,id,reserve from qyzx_ecc_bankaccepts order by bill_no,ywdate"
qyzx_ecc_sql[27]="select orgcode,rtrim(proto_no),card_no,name,rtrim(ywdate),operation_type,money_kind,sxjy,start_date,end_date,logout_date,logout_reason,traceno,rpttype,orgcodeold,orgcodechg,protonoold,protonochg,realywdate,incenter,rptdate,deal_flag,check_flag,id,reserve from qyzx_ecc_openawardtrusts order by proto_no,ywdate"
qyzx_ecc_sql[28]="select orgcode,contract_no,card_no,rtrim(ywdate),operation_type,trustloan_type,ensure_no,ensure_name,ensure_card,money_kind,ensure_money,sign_date,ensure_style,valid_status,traceno,name,ensure_num,certify_type,certify_no,rpttype,orgcodeold,orgcodechg,ensurenoold,ensurenochg,realywdate,incenter,rptdate,deal_flag,check_flag,rtrim(gty_id),id,reserve from qyzx_ecc_ensurecontracts order by gty_id,ywdate"
qyzx_ecc_sql[29]="select orgcode,contract_no,card_no,rtrim(ywdate),operation_type,trustloan_type,impawn_no,impawn_num,impawn_name,impawn_card,eval_kind,eval_val,sign_date,impawn_kind,money_kind,impawn_money,valid_status,traceno,name,rpttype,orgcodeold,orgcodechg,impawnnoold,impawnnochg,impawnnumold,impawnnumchg,realywdate,incenter,rptdate,deal_flag,check_flag,rtrim(gty_id),id,reserve from qyzx_ecc_impawncontract order by gty_id,ywdate"
qyzx_ecc_sql[30]="select orgcode,contract_no,card_no,rtrim(ywdate),operation_type,trustloan_type,pledge_no,pledge_num,pledge_name,pledge_card,eval_money_kind,pledge_val,eval_date,eval_orgname,eval_orgcode,sign_date,pledge_kind,money_kind,pledge_money,login_org,login_date,pledge_desc,valid_status,traceno,name,rpttype,orgcodeold,orgcodechg,pledgenoold,pledgenochg,pledgenumold,pledgenumchg,realywdate,incenter,rptdate,deal_flag,check_flag,rtrim(gty_id),id,reserve from qyzx_ecc_pledgecontracts order by gty_id,ywdate"
qyzx_ecc_sql[31]="select orgcode,rtrim(dkyw_no),card_no,name,traceno,rtrim(ywdate),operation_type,dkkind,oldyw_no,money_kind,dkmoney,dkdate,dk_balance,balance_date,return_type,four_class,five_class,rpttype,orgcodeold,orgcodechg,dkywnoold,dkywnochg,realywdate,incenter,rptdate,deal_flag,check_flag,id,reserve from qyzx_ecc_dkmessages order by dkyw_no,ywdate"
qyzx_ecc_sql[32]="select orgcode,rtrim(dkyw_no),card_no,return_no,return_money,money_kind,return_date,return_style,dkkind,rtrim(ywdate),delstats,traceno,return_times,operation_type,rpttype,realywdate,incenter,rptdate,deal_flag,check_flag,id,reserve from qyzx_ecc_dkreturns order by dkyw_no,return_times,ywdate"
qyzx_ecc_sql[33]="select orgcode,qxyw_no,rtrim(card_no),rtrim(ywdate),operation_type,rtrim(money_kind),qxyu,rtrim(qxtype),change_date,traceno,qxdesc,name,rpttype,orgcodeold,orgcodechg,cardnoold,cardnochg,realywdate,incenter,rptdate,deal_flag,check_flag,id,reserve from qyzx_ecc_lackofinterests order by card_no,money_kind,qxtype,ywdate"

}

# 对字符串split操作,返回数组
function _str_split() {
  # 字符串
  str_tmp=$1
  # 字符串分隔符
  str_split_tag=$2
  if [ "$str_tmp" != "" ]; then
    str_end=`expr index "$str_tmp" "$str_split_tag"`
    while [ $str_end -gt 1 ]; do
      ((str_end=str_end-1))
      arr_num=`expr substr "$str_tmp" 1 $str_end`
      str_array[$arr_num]=$arr_num

      ((str_end=str_end+2))
      str_length=`expr length "$str_tmp"`
      str_tmp=`expr substr "$str_tmp" $str_end $str_length`
      str_end=`expr index "$str_tmp" ","`
    done
    
    str_length=`expr length "$str_tmp"`
    if [ $str_length -gt 0 ]; then
       str_array[$str_tmp]=$str_tmp
    fi
  fi
}

# 执行命令
function _ddl_cmd() {
  tmp_str=$1
  ermsg=`db2 -x "$tmp_str"`
  rs=$?
  if [ $rs -ne 0 -a $rs -ne 2 ]; then
    echo "发生错误: [$ermsg]"
    echo "错误命令: [$tmp_str]"
    db2 +o connect reset 
    exit 122
  fi
  return 0
}

# 链接UDSF数据库
function _open_db() {
  db2 +o connect to $db2_connect_str
  return_val=$?
  if [ $return_val -ne 0 ]; then
    echo "链接UDSF数据库失败, 返回值: $return_val"
    echo "使用默认连接"
    db2 +o connect to udsfdb user udsfadm using udsfadm
    return_val=$?
    if [ $return_val -ne 0 ]; then
      echo "连接失败, 返回值: $return_val 退出.."
      exit 120
    fi
  fi
}

# 创建目录
function _mk_dir() {
  tmp_dir=$1
  if [ ! -d $tmp_dir ]; then
    echo "____新建目录【$tmp_dir】"
    mkdir $tmp_dir
    rs_tmp=$?
    if [ $rs_tmp -ne 0 ]; then
      echo "____建立目录【$tmp_dir】失败,返回代码=$rs_tmp"
      exit 123
    fi
  fi 
}

# 新建文件
function _mk_file() {
  _mk_file_name=$1
  if [ ! -c $_mk_file_name ]; then
    echo "____新建文件: $_mk_file_name"
    touch $_mk_file_name
    rs_tmp=$?
    if [ $rs_tmp -ne 0 ]; then
      echo "____新建文件【$tmp_dir】失败,返回代码=$rs_tmp"
      exit 124
    fi
  fi
}

# 备份日志
function _mk_log() {
  if [ ! -f $qyzx_log ]; then
    echo 新建日志: $qyzx_log
    touch $qyzx_log
  fi  
  msg=`wc -c $qyzx_log`
  fsize=`echo ${msg} | awk -F" " '{print $1}'`
  # 1048576 = 1M 如果日志大于25600字节,则备份到相应目录
  if [ $fsize -ge 25600 ]; then 
    qyzx_back_log=${qyzx_log_dir}/`date +%Y-%m-%d_%H:%M:%S`.log
    echo 备份日志到: $qyzx_back_log
    mv ${qyzx_log} ${qyzx_back_log}
  fi
}

_mk_dir "$qyzx_m_dir"
_mk_dir "$qyzx_o_dir"
_mk_dir "$qyzx_log_dir"
#_mk_dir "$qyzx_java_dir"
