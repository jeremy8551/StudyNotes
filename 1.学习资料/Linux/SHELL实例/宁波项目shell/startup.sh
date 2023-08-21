#!/bin/sh
# 功    能：启动报送系统后台程序
# 开 发 人：吕钊军
# 开发时间：2011-03-18
# 所属公司：北京宇信易诚科技有限公司

echo " "
echo `date +%Y-%m-%d_%T` 初始化环境变量 ..

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


echo RPT_HOME = $RPT_HOME
echo RPT_BIN = $RPT_BIN
echo RPT_FILE = $RPT_FILE
echo RPT_SRC = $RPT_SRC
echo RPT_TEMP = $RPT_TEMP
echo RPT_LOGS = $RPT_LOGS
echo RPT_CONF = $RPT_CONF
echo RPT_LIB = $RPT_LIB


# 如果文件夹不存在，则新建
if [ ! -d $RPT_HOME ]; then
mkdir $RPT_HOME
mkdir $RPT_BIN
mkdir $RPT_FILE
mkdir $RPT_SRC
mkdir $RPT_TEMP
mkdir $RPT_LOGS
mkdir $RPT_CONF
mkdir $RPT_LIB
exit 0
fi


# 打印JVM参数与环境变量
java -cp $RPT_LIB/etl.jar com.yc.tls.JvmConfig

###############################################################################

# 进入可执行文件目录
cd $RPT_BIN


# 创建守护进程日志
daemon_log=$RPT_LOGS/daemon_`date +%Y-%m-%d`.log


echo `date +%Y-%m-%d_%T` 正在启动备份存量数据守护进程 ..
nohup sh daemon.sh -s 600 -c $RPT_BIN/backup.sh -l "${RPT_LOGS}/backup"   -x -k  >> ${daemon_log} 2>&1 & 
if [ $? -ne 0 ]; then
    echo 启动备份存量数据守护进程失败!
    exit 3
fi


echo `date +%Y-%m-%d_%T` 正在启动核心EASYCORE卸数守护进程 ..
nohup sh daemon.sh -s 1200 -c $RPT_BIN/easycore/export_easycore.sh -l "${RPT_LOGS}/export_easycore" -x -k    >> ${daemon_log} 2>&1 & 
if [ $? -ne 0 ]; then
    echo 启动核心EASYCORE卸数守护进程失败！
    exit 1
fi


echo `date +%Y-%m-%d_%T` 正在启动核心EASYHIS卸数守护进程 ..
nohup sh daemon.sh -s 6 -c $RPT_BIN/easycore/export_easyhis.sh -l "${RPT_LOGS}/export_easyhis" -x -k    >> ${daemon_log} 2>&1 & 
if [ $? -ne 0 ]; then
    echo 启动核心EASYHIS卸数守护进程失败！
    exit 1
fi


echo `date +%Y-%m-%d_%T` 正在启动反洗钱接口守护进程 ..
nohup sh daemon.sh -s 6 -c $RPT_BIN/aml/export_aml_itf.sh -l "${RPT_LOGS}/export_aml_itf"   -x -k    >> ${daemon_log} 2>&1 & 
if [ $? -ne 0 ]; then
    echo 启动反洗钱接口守护进程失败！
    exit 2
fi

echo `date +%Y-%m-%d_%T` 正在启动非现场监管报送接口守护进程 ..
nohup sh daemon.sh -s 6 -c $RPT_BIN/oss/export_oss_itf.sh -l "${RPT_LOGS}/export_oss_itf"   -x -k    >> ${daemon_log} 2>&1 & 
if [ $? -ne 0 ]; then
    echo 启动反洗钱接口守护进程失败！
    exit 4
fi


echo `date +%Y-%m-%d_%T` 报送系统后台程序启动成功！

exit 0



