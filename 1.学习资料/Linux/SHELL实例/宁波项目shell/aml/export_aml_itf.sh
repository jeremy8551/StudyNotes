#!/bin/sh
# 功    能：根据业务系统数据生成反洗钱接口文本
#           1. 根据核心数据日期、反洗钱接口文本数据日期 比较判断是否生成 反洗钱接口数据文本
#           2. 加载指定日期的核心数据
#           3. 执行 aml_itf_batchsql.xml 中的SQL语句，加工生成接口数据
#           4. 把经过加工的接口数据卸载到 文件存贮区
#           5. 把接口数据文本的状态更新到 文本贮存区状态表（rpt_sysfile）
#           6. 如果接口数据保存成功, 则在文本目录下添加一个SUCCESS文件（前台系统根据这个文本判断“接口数据文本”是否准备完毕）
# 开 发 人：吕钊军
# 开发时间：2011-03-18
# 所属公司：北京宇信易诚科技有限公司

# 判断是否重复执行多次
ps -ef|grep "sh $0"|while read line 
do 
    # 进程号
    kpid=`echo $line|awk -F" " 'NR==1,NR==1 {print $2}'`
    # 父进程号
    kppid=`echo $line|awk -F" " 'NR==1,NR==1 {print $3}'`
    
    if [ "$kpid" != "$$" -a "$kppid" != "$$" ]; then 
        echo $line
        echo 不能同时重复执行多次!
        exit 0
    fi
done


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
# 报送系统所有JAR包
RPT_JARS=
for i in "$RPT_LIB"/*.jar; do
  RPT_JARS="$RPT_JARS":"$i"
done
export RPT_JARS
fi



# 生成反洗钱接口数据文件
java -cp $RPT_JARS \
     -Dfile.encoding=GBK itf.AmlItfAdaptor \
     -systag AML \
     -jdbc $RPT_CONF/rptdb_jdbc.properties \
     -load $RPT_CONF/aml/load.xml \
     -batch $RPT_CONF/aml/batchSql.xml \
     -export $RPT_CONF/aml/export.xml \
     -depend EASYCORE,EASYHIS \
     -req 0 \
     
if [ $? -ne 0 ]; then
    exit 1
fi


exit 0
