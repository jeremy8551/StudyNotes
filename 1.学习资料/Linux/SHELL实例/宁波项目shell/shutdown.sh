#!/bin/sh
# 功    能：杀掉所有的守护进程
# 开 发 人：吕钊军
# 开发时间：2011-03-18
# 所属公司：北京宇信易诚科技有限公司


# 杀掉所有已经执行的相同daemon.sh脚本
ps -ef|grep daemon.sh|grep "\-c"|grep "\-s"|while read line 
do 
    kpid=`echo $line|awk -F" " 'NR==1,NR==1 {print $2}'`
    if [ "$kpid" != "$$" ]; then 
        echo "关闭守护进程 $kpid"
        kill -9 $kpid
    fi
done

exit 0

