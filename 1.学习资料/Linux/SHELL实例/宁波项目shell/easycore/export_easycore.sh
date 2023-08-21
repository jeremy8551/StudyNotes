#!/bin/sh
# 功    能：从核心系统卸载数据文本，这个脚本是单线程的！
# 开 发 人：吕钊军
# 开发时间：2011-03-29
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


# 开始卸数
java -cp $RPT_JARS \
	 -Dfile.encoding=GBK adaptor.Main \
     -adaper adaptor.impl.EasycoreAdaptor \
     -sysTag EASYCORE \
     -jdbc $RPT_CONF/rptdb_jdbc.properties \
     -export $RPT_CONF/easycore/export.xml \
     -fileDir $RPT_FILE/EASYCORE \
     -auto 
     
if [ $? -ne 0 ]; then
    echo 卸载数据发生错误!
    exit 1
fi


exit 0

