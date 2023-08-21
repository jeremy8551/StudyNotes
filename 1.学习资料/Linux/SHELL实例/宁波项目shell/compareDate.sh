#!/bin/sh
# ��    �ܣ��Ƚ����ڴ�С
# �� �� �ˣ����Ⱦ�
# ����ʱ�䣺2011-03-18
# ������˾�����������׳ϿƼ����޹�˾

# 
func_usage()
{
    echo "  compareDate.sh -d date1 -c date2           "
    echo "  ���ڸ�ʽ: yyyy-mm-dd                       "
    echo "  �˳�״̬:                                  "
    echo "      =0 ���                                "
    echo "      =1 date1 ���� date2                    "
    echo "      =2 date1 С�� date2                    "
    echo "      >2 ��������                            "
    exit 99
}

while getopts "d:c:" name;
do
case $name in
d)  
    dt1=$OPTARG
    ;;
c)  
    dt2=$OPTARG
    ;;
?)  
    func_usage 
esac
done

# �жϲ����Ƿ�Ϸ�
if [ "$dt1" == "" -o "$dt2" == "" ]; then 
    func_usage
    exit 4  
fi

# ����
dt1_yy=`echo $dt1|awk -F"-" '{print $1}'`
dt1_mm=`echo $dt1|awk -F"-" '{print $2}'`
dt1_dd=`echo $dt1|awk -F"-" '{print $3}'`

dt2_yy=`echo $dt2|awk -F"-" '{print $1}'`
dt2_mm=`echo $dt2|awk -F"-" '{print $2}'`
dt2_dd=`echo $dt2|awk -F"-" '{print $3}'`


# �����������
if [ "$dt1" == "$dt2" ]; then 
exit 0  
fi

# �Ƚ����
if [ $dt1_yy -gt $dt2_yy ]; then
exit 1  
fi
if [ $dt1_yy -lt $dt2_yy ]; then
exit 2  
fi

# �Ƚ��·�
if [ $dt1_mm -gt $dt2_mm ]; then
exit 1  
fi
if [ $dt1_mm -lt $dt2_mm ]; then
exit 2  
fi

# �Ƚ���
if [ $dt1_dd -gt $dt2_dd ]; then
exit 1  
fi
if [ $dt1_dd -lt $dt2_dd ]; then
exit 2  
fi

echo "�Ƚ����� $dt1  $dt2 ��������! "
exit 3
