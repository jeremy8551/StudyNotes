#!/bin/sh
#功    能：删除数据仓库与个人征信中间表的数据
#参    数：无
#开发时间：2009-6-25
#  开发人：吕钊军
#所属公司：宇信易诚

# 记录执行位置
count=0


# 链接UDSF数据库
db2 +o connect to $db2_connect_str
return_val=$?
if [ $return_val -ne 0 ]; then
   echo "链接UDSF数据库失败"
   exit $return_val
fi


_propress()
{
((count=count+1))
echo "the proess $1 is running!" 
result=`db2 "load from /dev/null of del replace into $1"`
if [ result -ne 0 -a result -ne 2 ]; then
echo "deal with the proess called $1 is wrong and return code is $?"
db2 +o connect reset
exit $count
fi
}


# 个人客户资料表
_propress 'grzx_pcc_customer' 

# 贷款资料接口表
_propress 'grzx_pcc_loan' 

# 贷款台帐接口表
_propress 'grzx_pcc_loan_fact' 

# 贷款担保接口表
_propress 'grzx_pcc_loan_grnt' 
 
# 贷款还款明细
_propress 'grzx_pcc_loan_repay' 


echo "ok, all process execute successfully! "
db2 +o connect reset 
exit 0
