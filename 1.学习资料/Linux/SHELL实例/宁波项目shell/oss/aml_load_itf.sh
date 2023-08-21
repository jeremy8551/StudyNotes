#!/bin/sh
# 功    能：反洗钱前台系统 -> 系统数据生成 -> 执行接口程序，调用这个SHELL 加载ITF下的数据
# 开 发 人：吕钊军
# 开发时间：2011-03-18
# 所属公司：北京宇信易诚科技有限公司

func_usage()
{
    echo "  aml_load_itf.sh 文本所在目录                "
    echo "  退出状态:                                   "
    echo "      =0 执行成功                             "
    echo "      >0 发生错误!                            "
    exit 99
}

func_excsql() 
{
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


# 接口文本所在目录
filedirdate=$1
if [ "$filedirdate" == "" ]; then
    func_usage
fi
if [ ! -d $filedirdate ]; then
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
echo "========== 开始非现场监管报送接口文本数据" `date +%Y-%m-%d_%T` 


# 先清空数据
func_excsql "${idsCfg}" "delete from AML_ITF_TRANS   "
func_excsql "${idsCfg}" "delete from AML_ITF_ACCT    "
func_excsql "${idsCfg}" "delete from AML_ITF_CSTM    "
func_excsql "${idsCfg}" "delete from DMD_BANK_INFO   "


# 加载反洗钱接口数据
func_excsql "${idsCfg}" "load from ${filedirdate}/aml_itf_trans_m.txt   insert into AML_ITF_TRANS   "
func_excsql "${idsCfg}" "load from ${filedirdate}/aml_itf_acct_m.txt    insert into AML_ITF_ACCT    "
func_excsql "${idsCfg}" "load from ${filedirdate}/aml_itf_cstm_m.txt    insert into AML_ITF_CSTM    "
func_excsql "${idsCfg}" "load from ${filedirdate}/dmd_bank_info_m.txt   insert into DMD_BANK_INFO    "

echo "========== 开始反洗钱接口文本数据完毕!" `date +%Y-%m-%d_%T`
echo " "
echo " "

exit 0
