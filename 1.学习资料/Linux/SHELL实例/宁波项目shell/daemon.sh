#!/bin/sh
# ��    �ܣ�����һ���ػ�����, ѭ��ִ��ָ����shell����
# �� �� �ˣ����Ⱦ�
# ����ʱ�䣺2011-03-18
# ������˾�����������׳ϿƼ����޹�˾

func_usage()
{
    echo "  daemon.sh -s ���� -c shell -l ��־ [-x] [-k]                                                    "
    echo "  -s ��ѡ ѭ�����ִ��һ�ε�����                                                                  "
    echo "  -c ��ѡ shell�ű��ľ���·��                                                                     "
    echo "  -l ָ����־·��                                                                                 "
    echo "  -x ��ѡ ����ִ��[-c]����ָ����shell�ű�                                                         "
    echo "  -k ��ѡ ���[-c]����ָ����shell�����Ѿ��������ػ����̣���ɱ���ػ�����֮���ٴ���һ�����ػ�����   "
    echo "  �˳�״̬:                                                                                       "
    echo "      =0 ִ�гɹ�                                                                                 "
    echo "      >0 ��������!                                                                                "
    exit 99
}

# ���ִ��SHELL���������
slpSec=0
# �Ƿ�����ִ��shell����
excfst=0
# shell����ľ���·��
execmd=""
# �Ƿ���ɱ���ظ����ػ�����
killcmd=0
# ��־Ŀ¼
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


# �������Ƿ���ȷ
if [ $slpSec -le 0 ]; then 
    echo ��-s�� ����ֵ�������0!
    func_usage
elif [ ! -f "$execmd" ]; then 
    echo ��$execmd����һ����Ч�� shell �ű�!
    func_usage
elif [ "$daemonlogdir" == "" ]; then 
    echo ��-l����������Ϊ�գ�
    func_usage
fi


# �ж� -k ѡ���Ƿ���Ч
if [ $killcmd -eq 1 ]; then
    # ɱ�������Ѿ�ִ�е���ͬSHELL�ű�
    ps -ef|grep daemon.sh|grep "\-c"|grep "\-s"|grep ${execmd}|while read line 
    do 
        kpid=`echo $line|awk -F" " 'NR==1,NR==1 {print $2}'`
        if [ "$kpid" != "$$" ]; then 
            echo "�ر��ػ����� $kpid"
            kill -9 $kpid
        fi
    done 
fi


# ѭ��ִ��shell����
while true 
do
    # ��־
    shelllogpath=${daemonlogdir}_`date +%Y-%m-%d`.log
    if [ $excfst -eq 1 ]; then 
        sh $execmd >> ${shelllogpath} 2>&1 &
        if [ $? -ne 0 ]; then
            echo "sh $execmd ��������! ������:$rsfg "
        fi
        sleep $slpSec 
    else 
        sleep $slpSec 
        sh $execmd >> ${shelllogpath} 2>&1 &
        if [ $? -ne 0 ]; then
            echo "sh $execmd ��������! ������:$rsfg "
        fi
    fi
    
    
done


exit 0



