#!/bin/sh
# 功    能：创建一个守护进程, 循环执行指定的shell程序
# 开 发 人：吕钊军
# 开发时间：2011-03-18
# 所属公司：北京宇信易诚科技有限公司

func_usage()
{
    echo "  daemon.sh -s 秒数 -c shell -l 日志 [-x] [-k]                                                    "
    echo "  -s 必选 循环间隔执行一次的秒数                                                                  "
    echo "  -c 必选 shell脚本的绝对路径                                                                     "
    echo "  -l 指定日志路径                                                                                 "
    echo "  -x 可选 立即执行[-c]参数指定的shell脚本                                                         "
    echo "  -k 可选 如果[-c]参数指定的shell程序已经创建了守护进程，则杀掉守护进程之后再创建一个新守护进程   "
    echo "  退出状态:                                                                                       "
    echo "      =0 执行成功                                                                                 "
    echo "      >0 发生错误!                                                                                "
    exit 99
}

# 间隔执行SHELL程序的秒数
slpSec=0
# 是否立即执行shell程序
excfst=0
# shell程序的绝对路径
execmd=""
# 是否先杀掉重复的守护进程
killcmd=0
# 日志目录
daemonlogdir=


while getopts "s:c:l:xk" name;
do
case $name in
s)  
    slpSec=$OPTARG
    ;;
c)  
    execmd=$OPTARG
    ;;
l)
    daemonlogdir=$OPTARG
    ;;
x)  
    excfst=1
    ;;
k)  
    killcmd=1
    ;;
?)  
    func_usage 
esac
done


# 检查参数是否正确
if [ $slpSec -le 0 ]; then 
    echo 【-s】 参数值必须大于0!
    func_usage
elif [ ! -f "$execmd" ]; then 
    echo 【$execmd】是一个无效的 shell 脚本!
    func_usage
elif [ "$daemonlogdir" == "" ]; then 
    echo 【-l】参数不能为空！
    func_usage
fi


# 判断 -k 选项是否有效
if [ $killcmd -eq 1 ]; then
    # 杀掉所有已经执行的相同SHELL脚本
    ps -ef|grep daemon.sh|grep "\-c"|grep "\-s"|grep ${execmd}|while read line 
    do 
        kpid=`echo $line|awk -F" " 'NR==1,NR==1 {print $2}'`
        if [ "$kpid" != "$$" ]; then 
            echo "关闭守护进程 $kpid"
            kill -9 $kpid
        fi
    done 
fi


# 循环执行shell程序
while true 
do
    # 日志
    shelllogpath=${daemonlogdir}_`date +%Y-%m-%d`.log
    if [ $excfst -eq 1 ]; then 
        sh $execmd >> ${shelllogpath} 2>&1 &
        if [ $? -ne 0 ]; then
            echo "sh $execmd 发生错误! 错误码:$rsfg "
        fi
        sleep $slpSec 
    else 
        sleep $slpSec 
        sh $execmd >> ${shelllogpath} 2>&1 &
        if [ $? -ne 0 ]; then
            echo "sh $execmd 发生错误! 错误码:$rsfg "
        fi
    fi
    
    
done


exit 0



