#!/bin/sh
# ��    �ܣ�ɱ�����е��ػ�����
# �� �� �ˣ����Ⱦ�
# ����ʱ�䣺2011-03-18
# ������˾�����������׳ϿƼ����޹�˾


# ɱ�������Ѿ�ִ�е���ͬdaemon.sh�ű�
ps -ef|grep daemon.sh|grep "\-c"|grep "\-s"|while read line 
do 
    kpid=`echo $line|awk -F" " 'NR==1,NR==1 {print $2}'`
    if [ "$kpid" != "$$" ]; then 
        echo "�ر��ػ����� $kpid"
        kill -9 $kpid
    fi
done

exit 0

