#! /usr/bin/ksh

# 循环备份数据 
# 如果备份数据的文件夹数量已经达到10次 自动删除最早保存的数据

cday=`date +%Y%m%d`


if [ -d jgjrtj${cday} ]; then
  mv jgjrtj${cday} jgjrtj${cday}-`date +%s` 
fi
mkdir jgjrtj${cday}


# 获取当前已保存多少天数据
fn=`ls -l|egrep jgjrtj[0-9]{8}$|wc -l`
if [ $fn -gt 10 ]; then 
  minDir=`ls -lc|egrep jgjrtj[0-9]{8}$|sed -n 1p|awk -F" " '{print $9}'`
  if [ -d $minDir ]; then 
    echo 删除目录 $minDir
    rm -rf $minDir
  fi
fi

echo exit
