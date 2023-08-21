#!/bin/sh
# 功    能：比较日期大小
# 开 发 人：吕钊军
# 开发时间：2011-03-18
# 所属公司：北京宇信易诚科技有限公司

# 
func_usage()
{
    echo "  compareDate.sh -d date1 -c date2           "
    echo "  日期格式: yyyy-mm-dd                       "
    echo "  退出状态:                                  "
    echo "      =0 相等                                "
    echo "      =1 date1 大于 date2                    "
    echo "      =2 date1 小于 date2                    "
    echo "      >2 发生错误                            "
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

# 判断参数是否合法
if [ "$dt1" == "" -o "$dt2" == "" ]; then 
    func_usage
    exit 4  
fi

# 解析
dt1_yy=`echo $dt1|awk -F"-" '{print $1}'`
dt1_mm=`echo $dt1|awk -F"-" '{print $2}'`
dt1_dd=`echo $dt1|awk -F"-" '{print $3}'`

dt2_yy=`echo $dt2|awk -F"-" '{print $1}'`
dt2_mm=`echo $dt2|awk -F"-" '{print $2}'`
dt2_dd=`echo $dt2|awk -F"-" '{print $3}'`


# 二个日期相等
if [ "$dt1" == "$dt2" ]; then 
exit 0  
fi

# 比较年份
if [ $dt1_yy -gt $dt2_yy ]; then
exit 1  
fi
if [ $dt1_yy -lt $dt2_yy ]; then
exit 2  
fi

# 比较月份
if [ $dt1_mm -gt $dt2_mm ]; then
exit 1  
fi
if [ $dt1_mm -lt $dt2_mm ]; then
exit 2  
fi

# 比较日
if [ $dt1_dd -gt $dt2_dd ]; then
exit 1  
fi
if [ $dt1_dd -lt $dt2_dd ]; then
exit 2  
fi

echo "比较日期 $dt1  $dt2 发生错误! "
exit 3
